---
name: dumalog
description: "Write a Jekyll blog post from the user's dev-chat history: search memPalace for context, follow the dumalog writing guide, commit on a post/ branch."
version: 1.0.0
platforms: [linux, macos]
metadata:
  hermes:
    tags: [blog, jekyll, writing, mempalace, post, dumalog, github-pages]
    related_skills: []
---

# dumalog — dev chats to blog posts

Turn the user's real engineering work (mined from Claude Code / Codex
sessions into memPalace) into a publish-ready Jekyll blog post.

## Setup facts

- Blog registry: `~/.dumalog/config.json` — maps blog name → repo `path`,
  `posts_dir`, and `example` (the reference post). Use `default_blog` unless
  the user names another.
- Writing guide (hard rules + structure + style): `~/.dumalog/app/prompts/write-post.md`.
  **Read it and follow it; its rules override your defaults.**
- Context search: `mempalace search "<topic>" --results 8` (CLI, in
  `~/.local/bin`). Run 2–3 searches with different phrasings of the topic.

## Workflow

1. Read `~/.dumalog/config.json`; resolve the blog repo path and example post.
2. Read the example post — mirror its language, front matter field set, and
   formatting idioms exactly.
3. Search memPalace for the topic; optionally cross-check numbers against
   `git log` in the repos the story is about. Numbers from git/measurements
   outrank chat recollections. **Never invent a number.**
4. Write ONE post in `<posts_dir>/<YYYY-MM-DD>-<slug>.md` following the
   writing guide.
5. Commit and push according to the `branch` setting in
   `~/.dumalog/config.json`:
   - absent or `"main"` (default) → commit directly to the default branch
     (main) and push;
   - `"pr"` → commit on a new branch `post/<slug>`, never on main, open a
     PR if `gh` is available;
   - any other value → commit to that branch (create from main if needed),
     never to main.
   **Never edit existing posts.**

## Safety

- Anonymize: no tokens, IPs, internal domains, database names.
- If context is insufficient for a factual post, say so and list what's
  missing instead of writing fiction.
