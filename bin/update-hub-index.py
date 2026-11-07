#!/usr/bin/env python3
"""Regenerate the plain-text Index block in every hub of an Obsidian vault.

A hub is any note containing a callout that starts with `> [!hm-index]`.
Its children are the notes whose `parents` frontmatter links to the hub.
Only the Index callout is rewritten; nothing else in any file is touched,
and files are only written when the Index actually changes.

Usage: update-hub-index.py /path/to/vault
"""
import os
import re
import sys

SKIP_DIRS = {".git", ".obsidian", ".trash", "templates", "archive", "attachments", "daily"}
INDEX_START = re.compile(r"^> \[!hm-index\][+-]?.*$")
FRONTMATTER = re.compile(r"\A---\n(.*?)\n---\n", re.S)
WIKILINK = re.compile(r"\[\[([^\]|#]+)")


def frontmatter(text):
    m = FRONTMATTER.match(text)
    return m.group(1) if m else ""


def field_block(fm, key):
    """Return the raw text of one top-level YAML key (inline value plus indented lines)."""
    lines = fm.split("\n")
    out, inside = [], False
    for line in lines:
        if re.match(rf"^{re.escape(key)}:", line):
            inside = True
            out.append(line[len(key) + 1:])
        elif inside and (line.startswith(" ") or line.startswith("\t") or line.strip() == ""):
            out.append(line)
        elif inside:
            break
    return "\n".join(out)


def scalar(fm, key):
    m = re.search(rf"^{re.escape(key)}:\s*(.*)$", fm, re.M)
    return m.group(1).strip().strip("\"'") if m else ""


def collect(vault):
    notes = []
    for root, dirs, files in os.walk(vault):
        rel_root = os.path.relpath(root, vault)
        top = rel_root.split(os.sep)[0]
        if top in SKIP_DIRS:
            dirs[:] = []
            continue
        dirs[:] = [d for d in dirs if d not in SKIP_DIRS and not d.startswith(".")]
        for f in files:
            if not f.endswith(".md"):
                continue
            path = os.path.join(root, f)
            with open(path, encoding="utf-8") as fh:
                text = fh.read()
            fm = frontmatter(text)
            parents = {os.path.basename(p.strip()) for p in WIKILINK.findall(field_block(fm, "parents"))}
            notes.append({
                "path": path,
                "stem": f[:-3],
                "folder": top if rel_root != "." else "",
                "type": scalar(fm, "type"),
                "parents": parents,
                "text": text,
            })
    return notes


def link(note):
    stem = note["stem"]
    label = stem[1:] if stem.startswith("_") else stem
    out = f"[[{stem}|{label}]]" if label != stem else f"[[{stem}]]"
    if note["folder"] == "inbox":
        out += " (draft, in inbox)"
    return out


def build_index(header, children):
    subs = sorted((c for c in children if c["stem"].startswith("_") or c["type"] == "hub"),
                  key=lambda c: c["stem"].lstrip("_").lower())
    rest = sorted((c for c in children if c not in subs), key=lambda c: c["stem"].lower())
    parts = []
    if subs:
        parts.append("> **Sub-topics**\n" + "\n".join(f"> - {link(c)}" for c in subs))
    if rest:
        parts.append("> **Notes**\n" + "\n".join(f"> - {link(c)}" for c in rest))
    body = "\n>\n".join(parts) if parts else "> _No notes yet._"
    return header + "\n" + body


def update(note, children):
    lines = note["text"].split("\n")
    start = next((i for i, l in enumerate(lines) if INDEX_START.match(l)), None)
    if start is None:
        return False
    end = start + 1
    while end < len(lines) and lines[end].startswith(">"):
        end += 1
    new_block = build_index(lines[start], children).split("\n")
    if lines[start:end] == new_block:
        return False
    new_text = "\n".join(lines[:start] + new_block + lines[end:])
    tmp = note["path"] + ".tmp-hub-index"
    with open(tmp, "w", encoding="utf-8") as fh:
        fh.write(new_text)
    os.replace(tmp, note["path"])
    return True


def main():
    if len(sys.argv) != 2 or not os.path.isdir(sys.argv[1]):
        sys.exit("usage: update-hub-index.py /path/to/vault")
    notes = collect(sys.argv[1])
    changed = 0
    for hub in notes:
        if "[!hm-index]" not in hub["text"]:
            continue
        children = [n for n in notes if hub["stem"] in n["parents"] and n is not hub]
        if update(hub, children):
            changed += 1
            print(f"updated index: {os.path.relpath(hub['path'], sys.argv[1])}")
    print(f"hub indexes updated: {changed}")


if __name__ == "__main__":
    main()
