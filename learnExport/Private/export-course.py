from pathlib import Path
import subprocess
import re
import sys
import json

# Paramètres Modifiables
COURSE_CODE = ( sys.argv[1] if len(sys.argv) > 1 else "SC-500T00" )
OUTPUT_PROFILE = ( sys.argv[2] if len(sys.argv) > 2 else "Lecture" )


# Paramètres du script
CACHE_FOLDER = Path("./cache")
EXPORT_FOLDER = Path("./exports")
CACHE_FOLDER.mkdir(exist_ok=True)
EXPORT_FOLDER.mkdir(exist_ok=True)
OUTPUT_MD = CACHE_FOLDER / f"{COURSE_CODE}-{OUTPUT_PROFILE}.md"
OUTPUT_HTML = EXPORT_FOLDER / f"{COURSE_CODE}-{OUTPUT_PROFILE}.html"
if OUTPUT_PROFILE == "Lecture":
    KEEP_INTRODUCTION = False
    KEEP_SUMMARY = False
    KEEP_EXERCISES = False
elif OUTPUT_PROFILE == "Complet":
    KEEP_INTRODUCTION = True
    KEEP_SUMMARY = True
    KEEP_EXERCISES = True
else:
    raise ValueError( f"Profil inconnu : {OUTPUT_PROFILE}" )

def cleanup_learn_content(md):
    patterns = [ r"Completed\s*\n\s*~\s*\d+\s*minutes?",  r"Completed\s*\n\s*~\s*\d+\s*minute",  r"Completed", ]
    for pattern in patterns:
        md = re.sub( pattern, "", md, flags=re.IGNORECASE )
    md = re.sub( r"-\s*\d+\s*minutes?", "", md, flags=re.IGNORECASE )
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
                md = cleanup_learn_content(md)
                all_content.append(md)
            except Exception as e: print( f"             ERREUR unité : {e}" )
print()
print("Création du Markdown...")
with open( OUTPUT_MD, "w", encoding="utf-8" ) as f:
    f.write( "\n\n".join(all_content) )
print( f"Markdown créé : {OUTPUT_MD}")
print()
print("Création du HTML...")
result = subprocess.run(["pandoc", OUTPUT_MD, "-s", "-o", OUTPUT_HTML])
if result.returncode == 0:
    print(f"Fichier HTML créé : {OUTPUT_HTML}")
else:
    print("ERREUR lors de la création du fichier HTML")
