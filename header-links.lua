-- HTML only: make each section heading a link to itself, so readers can copy a
-- direct URL to any section. Pandoc strips these links from the TOC entries.
function Header(h)
  if FORMAT:match("html") and h.identifier ~= "" then
    h.content = { pandoc.Link(h.content, "#" .. h.identifier, "", { class = "header-link" }) }
  end
  return h
end
