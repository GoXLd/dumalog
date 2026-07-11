You are analyzing existing posts of a Jekyll blog to produce a reusable
writing-and-formatting guide that future posts of this blog must follow.

From the sample posts below, extract and document:

1. **Front matter template** — every field these posts use, as a fenced
   YAML block, with a short comment per field describing the convention
   (how titles are phrased, how tags/categories are chosen, when optional
   fields like `mermaid` or `image` appear).
2. **Formatting idioms** — the exact syntax the theme uses: callouts /
   prompt boxes, tables and their alignment, images with captions, code
   block style, diagrams. Quote the syntax literally so it can be copied.
3. **Structure recipe** — the typical section flow of a post (hook,
   starting point, method, measurements, honest part, summary...), scaled
   note for short posts.
4. **Tone and style** — person, register, how numbers and claims are
   presented, what is avoided.
5. **Hard rules** that visibly hold across all posts (language, file
   naming, what is never done).

Write the guide in the same language the posts are written in.
Be concrete and compact (aim for under 150 lines). Output ONLY the guide
as markdown — no preamble, no commentary about your analysis.

<posts>
{{POSTS}}
</posts>
