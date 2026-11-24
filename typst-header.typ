#show link: set text(fill: rgb("#6a3dc4"))
#show table: set par(justify: false)
#show table: set text(size: 0.92em)
#show raw: set text(font: "DejaVu Sans Mono", size: 0.85em)
#show raw.where(block: true): block.with(
  fill: rgb("#f6f6f8"),
  stroke: 0.5pt + rgb("#e4e4ea"),
  inset: 8pt,
  radius: 4pt,
  width: 100%,
)
#show raw.where(block: false): box.with(
  fill: rgb("#f3f1f8"),
  inset: (x: 2pt),
  outset: (y: 2pt),
  radius: 2pt,
)
#set table(stroke: 0.5pt + rgb("#cccccc"), inset: 6pt)
#show table.cell.where(y: 0): set text(weight: "bold")
#show heading.where(level: 1): it => block(above: 1.4em, below: 0.7em, it)
#show outline.entry.where(level: 1): it => {
  v(0.4em, weak: true)
  strong(it)
}
