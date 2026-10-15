import requests
from bs4 import BeautifulSoup
from urllib.parse import urljoin
from pathlib import Path
import subprocess
import re
import yaml
import sys
import json

# Paramètres Modifiables
COURSE_CODE = ( sys.argv[1] if len(sys.argv) > 1 else "SC-500T00" )
OUTPUT_PROFILE = ( sys.argv[2] if len(sys.argv) > 2 else "Lecture" )
# TODO V2 : supprimée quand tous les téléchargements seront gérés par PowerShell
COURSE_URL = (f"https://learn.microsoft.com/en-us/training/courses/{COURSE_CODE}")

# Paramètres du script
SCRIPT_FOLDER = Path(__file__).parent
CACHE_FOLDER = Path("./cache")
EXPORT_FOLDER = Path("./exports")
IMAGE_FOLDER = Path(f"./{COURSE_CODE}-images")
CACHE_FOLDER.mkdir(exist_ok=True)
EXPORT_FOLDER.mkdir(exist_ok=True)
IMAGE_FOLDER.mkdir(exist_ok=True)
OUTPUT_MD = CACHE_FOLDER / f"{COURSE_CODE}-{OUTPUT_PROFILE}.md"
OUTPUT_HTML = EXPORT_FOLDER / f"{COURSE_CODE}-{OUTPUT_PROFILE}.html"
if OUTPUT_PROFILE == "Lecture":
    KEEP_INTRODUCTION = False
    KEEP_SUMMARY = False
    KEEP_EXERCISES = False
    KEEP_KNOWLEDGE_CHECK = True
elif OUTPUT_PROFILE == "Complet":
    KEEP_INTRODUCTION = True
    KEEP_SUMMARY = True
    KEEP_EXERCISES = True
    KEEP_KNOWLEDGE_CHECK = True
else:
    raise ValueError( f"Profil inconnu : {OUTPUT_PROFILE}" )
SHOW_KNOWLEDGE_CHECK_ANSWERS = ( OUTPUT_PROFILE == "Lecture" )

SESSION = requests.Session()

def is_knowledge_check(md):
    return "module_assessment: true" in md

def get_source_path(md):
    match = re.search( r"source_path:\s*(.+)", md )
    if match: return match.group(1).strip()
    return None

def get_yaml(url):
    response = SESSION.get(url, timeout=30)
    response.raise_for_status()
    return response.text

def get_knowledge_check(source_path):
    repos = [ "learn", "learn-m365-pr" ]
    for repo in repos:
        yaml_url = ( f"https://raw.githubusercontent.com/MicrosoftDocs/{repo}/main/{source_path}" )
        try:
            return yaml.safe_load(get_yaml(yaml_url))
        except Exception:
            pass
    raise Exception( f"Knowledge Check introuvable : {source_path}" )

def knowledge_check_to_markdown(source_path):
    data = get_knowledge_check(source_path)
    md = []
    md.append("## Module assessment\n")
    for index, question in enumerate( data["quiz"]["questions"], start=1 ):
        md.append(f"### Question {index}\n")
        md.append(question["content"])
        md.append("")
        for choice in question["choices"]:
            if choice["isCorrect"]:
                md.append( f"- **{choice['content']}**" )
                md.append( f"  - *{choice['explanation']}*" )
            else:  md.append( f"- {choice['content']}" )
        md.append("")
    return "\n".join(md)

def cleanup_learn_content(md):
    patterns = [ r"Completed\s*\n\s*~\s*\d+\s*minutes?",  r"Completed\s*\n\s*~\s*\d+\s*minute",  r"Completed", ]
    for pattern in patterns:
        md = re.sub( pattern, "", md, flags=re.IGNORECASE )
    md = re.sub( r"-\s*\d+\s*minutes?", "", md, flags=re.IGNORECASE )
    return md.strip()

def get_html(url):
    response = SESSION.get(url, timeout=30)
    response.raise_for_status()
    return response.text

def get_markdown(url):
    response = SESSION.get(url, timeout=30)
    response.raise_for_status()
    return response.text    

def clean_markdown(md):
    if md.startswith("---"):
        parts = md.split("---", 2)
        if len(parts) >= 3: md = parts[2]
    return md.strip()

def get_binary(url):
    response = SESSION.get(url, timeout=30)
    response.raise_for_status()
    return response.content

def process_images(markdown, module_soup):
    source_meta = module_soup.find( "meta", attrs={"name": "source_path"} )
    repo_meta = module_soup.find( "meta", attrs={"name": "github_feedback_content_git_url"} )
    if not source_meta or not repo_meta: return markdown
    source_path = source_meta["content"]
    repo_url = repo_meta["content"]
    repo_match = re.search( r"github\.com/([^/]+)/([^/]+)/blob/([^/]+)/", repo_url )
    if not repo_match: return markdown
    owner = repo_match.group(1)
    repo = repo_match.group(2)
    branch = repo_match.group(3)
    repo_prefix = repo + "/"
    if source_path.startswith(repo_prefix): source_path = source_path[len(repo_prefix):]
    module_folder = source_path.rsplit("/", 1)[0]
    pattern = r'!\[(.*?)\]\((.*?)\)'
    matches = re.findall(pattern, markdown)
    for alt_text, image_path in matches:
        if image_path.startswith("http"): continue
        if "media/" not in image_path:  continue
        image_filename = image_path.split("/")[-1]
        if image_filename.lower().endswith(".svg"):
            print( f"              SVG supprimé : {image_filename}" )
            markdown = re.sub( rf'!\[.*?\]\({re.escape(image_path)}\)','', markdown )
            continue
        local_file = IMAGE_FOLDER / image_filename
        raw_url = ( f"https://raw.githubusercontent.com/{owner}/{repo}/{branch}/{module_folder}/media/{image_filename}" )
        if not local_file.exists():
            try:
                with open(local_file, "wb") as f:
                    f.write(get_binary(raw_url))
            except Exception as e: print( f"                 ERREUR {e}" )
        if local_file.exists():
            markdown = markdown.replace( image_path, str(local_file).replace( "\\", "/" ))
        else: 
            print( f"              IMAGE INACCESSIBLE : {image_filename}" )
            markdown = re.sub( rf'!\[.*?\]\({re.escape(image_path)}\)', f'> *Image manquante à l\'impression : {image_filename}*',
            markdown )
    return markdown

COURSE_HTML_FILE = (CACHE_FOLDER / f"{COURSE_CODE}.html")
STRUCTURE_FILE = (CACHE_FOLDER / COURSE_CODE / "structure.json")
with open(STRUCTURE_FILE, "r", encoding="utf-8-sig") as f: course_structure = json.load(f)
print("Lecture du cours depuis le cache...")
course_html = COURSE_HTML_FILE.read_text(encoding="utf-8")
learning_paths = (course_structure["LearningPaths"])
print(f"{len(learning_paths)} Learning Paths trouvés")
all_content = []
first_learning_path = True
for lp_index, lp in enumerate( learning_paths, start=1):
    lp_file = Path(lp["File"])
    print(f"[LP {lp_index}/{len(learning_paths)}] {lp_file.stem}")
    try:
        modules = lp['Modules']
    except Exception as e:
        print( f"    ERREUR Learning Path : {e}" )
        continue
    if not first_learning_path: all_content.append("\n\n\\newpage\n\n")
    first_learning_path = False
    all_content.append( f"# {lp['Title']}\n\n" )
    modules = []
    for link in lp_soup.find_all( "a", href=True ):
        href = link["href"]
        if "modules" not in href: continue
        title = link.get_text( strip=True )
        if not title: continue
        if href.startswith( "../../modules/" ):
            href = href.replace( "../../modules/", "https://learn.microsoft.com/en-us/training/modules/" )
        elif href.startswith("/"): href = ( "https://learn.microsoft.com" + href )
        if href not in [
                m["url"]
                for m in modules ]:
            modules.append({ "title": title, "url": href })
    for mod_index, module in enumerate( modules, start=1 ):
        print( f"    [{mod_index}/{len(modules)}] {module['title']}" )
        if (mod_index > 1): all_content.append( "\n\n\\newpage\n\n" )
        all_content.append( f"## {module['title']}\n\n" )
        try:
            module_slug = (module["url"].rstrip("/").split("/")[-1])
            module_file = (CACHE_FOLDER / "modules" / f"{module_slug}.html")
            print(f"Lecture cache module : {module_file}")
            module_html = module_file.read_text(encoding="utf-8")
            module_soup = BeautifulSoup(module_html,"html.parser")
        except Exception as e:
            print( f"         ERREUR module : {e}" )
            continue
        units = module_soup.select( "#unit-list a.unit-title" )
        for unit in units:
            unit_title = unit.get_text( strip=True )
            if unit_title.lower() == "introduction":
                if not KEEP_INTRODUCTION:
                    print("             [Introduction ignorée]")
                    continue
            if unit_title.lower() == "summary":
                if not KEEP_SUMMARY:
                    print("             [Summary ignoré]")
                    continue
            if unit_title.lower().startswith("exercise"):
                if not KEEP_EXERCISES:
                    print("             [Exercises ignoré]")
                    continue
            unit_url = urljoin( module["url"].rstrip("/") + "/", unit["href"] )
            markdown_url = ( unit_url + "?accept=text/markdown" )
            print( f"           - {unit_title}" )
            try:
                md = get_markdown(markdown_url)
                if is_knowledge_check(md):
                    if KEEP_KNOWLEDGE_CHECK:
                        print("             Knowledge Check enrichi")
                        source_path = get_source_path(md)
                        if SHOW_KNOWLEDGE_CHECK_ANSWERS and source_path:
                            try:
                                md = knowledge_check_to_markdown( source_path )
                            except Exception as e:
                                print( f"             Knowledge Check inaccessible : {e}" )
                                md = clean_markdown(md)
                                md = cleanup_learn_content(md)
                        else:
                            md = clean_markdown(md)
                            md = cleanup_learn_content(md)
                    else:
                        print( "             Knowledge Check ignoré" )
                        continue
                else:
                    md = clean_markdown(md)
                    md = cleanup_learn_content(md)
                md = process_images( md, module_soup )
                all_content.append(md)
            except Exception as e: print( f"             ERREUR unité : {e}" )
print()
print("Création du Markdown...")
with open( OUTPUT_MD, "w", encoding="utf-8" ) as f:
    f.write( "\n\n".join(all_content) )
print( f"Markdown créé : {OUTPUT_MD}")
print()
print(f"Images téléchargées dans : {IMAGE_FOLDER}")
print()
print("Création du HTML...")
result = subprocess.run(["pandoc", OUTPUT_MD, "-s", "-o", OUTPUT_HTML])
if result.returncode == 0:
    print(f"Fichier HTML créé : {OUTPUT_HTML}")
else:
    print("ERREUR lors de la création du fichier HTML")
