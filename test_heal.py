#!/usr/bin/env python3
"""Self-check for dumalog's palace FTS5 heal (bin/dumalog heal_palace).

Builds a tiny chroma-shaped DB, desyncs its FTS5 index the same way real
corruption looks (mempalace's SQLite reports "malformed inverted index"),
then asserts heal_palace rebuilds it. Needs mempalace installed; skips otherwise.
"""
import importlib.machinery, importlib.util, pathlib, shutil, sqlite3, subprocess, sys, tempfile

loader = importlib.machinery.SourceFileLoader(
    "dumalog", str(pathlib.Path(__file__).parent / "bin" / "dumalog"))
spec = importlib.util.spec_from_loader("dumalog", loader)
d = importlib.util.module_from_spec(spec)
loader.exec_module(d)

exe = shutil.which("mempalace")
if not exe or not (pathlib.Path(exe).resolve().parent / "python").exists():
    print("SKIP: mempalace not installed")
    sys.exit(0)
mp_py = str(pathlib.Path(exe).resolve().parent / "python")

with tempfile.TemporaryDirectory() as tmp:
    db_path = pathlib.Path(tmp) / "chroma.sqlite3"
    db = sqlite3.connect(db_path)
    db.execute("CREATE VIRTUAL TABLE embedding_fulltext_search "
               "USING fts5(string_value, tokenize='trigram')")
    db.execute("INSERT INTO embedding_fulltext_search VALUES ('hello palace')")
    db.commit()
    # desync: write to the content shadow table behind FTS5's back
    db.execute("INSERT INTO embedding_fulltext_search_content(c0) VALUES ('ghost')")
    db.commit()
    db.close()

    def quick_check():
        return subprocess.run(
            [mp_py, "-c", "import sqlite3,sys;"
             "print(sqlite3.connect(sys.argv[1]).execute('PRAGMA quick_check').fetchone()[0])",
             str(db_path)], capture_output=True, text=True).stdout.strip()

    assert quick_check() != "ok", "test setup failed to desync the FTS5 index"

    d.PALACE_DB = db_path
    d.heal_palace()  # calls sys.exit(2) on failure

    assert quick_check() == "ok", "heal_palace did not fix the index"
    assert list(db_path.parent.glob("*.pre-heal-*")), "no pre-heal backup created"
    print("PASS: heal_palace detects, backs up, and rebuilds a desynced FTS5 index")
