import requests
from pathlib import Path
import subprocess
import re
import yaml
import sys
import json

# Paramètres Modifiables
COURSE_CODE = ( sys.argv[1] if len(sys.argv) > 1 else "SC-500T00" )
OUTPUT_PROFILE = ( sys.argv[2] if len(sys.argv) > 2 else "Lecture" )


# Paramètres du script
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

def clean_markdown(md):
    if md.startswith("---"):
        parts = md.split("---", 2)
        if len(parts) >= 3: md = parts[2]
    return md.strip()

STRUCTURE_FILE = (CACHE_FOLDER / COURSE_CODE / "structure.json")
with open(STRUCTURE_FILE, "r", encoding="utf-8-sig") as f: course_structure = json.load(f)
learning_paths = (course_structure["LearningPaths"])
print(f"{len(learning_paths)} Learning Paths trouvés")
all_content = []
first_learning_path = True
for lp_index, lp in enumerate( learning_paths, start=1):
    print(f"[LP {lp_index}/{len(learning_paths)}] {lp['Title']}")
    modules = lp['Modules']
    if not first_learning_path: all_content.append("\n\n\\newpage\n\n")
    first_learning_path = False
    all_content.append( f"# {lp['Title']}\n\n" )
    for mod_index, module in enumerate( modules, start=1 ):
        print( f"    [{mod_index}/{len(modules)}] {module['Title']}" )
        if (mod_index > 1): all_content.append( "\n\n\\newpage\n\n" )
        all_content.append( f"## {module['Title']}\n\n" )
        module_file = Path(module["File"])
        print(f"Lecture cache module : {module_file}")
        for unit in module["Units"]:
            unit_file = Path(unit["File"])
            unit_title = unit["Title"]
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
            print(f"           - {unit_title}")
            try:
                md = unit_file.read_text(encoding="utf-8")
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
