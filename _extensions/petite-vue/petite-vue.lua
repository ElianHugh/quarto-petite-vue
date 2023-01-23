local kIsHTML = quarto.doc.is_format("html:js");

if (kIsHTML) then
  quarto.doc.add_html_dependency({
    name = "petite-vue",
    version = "0.2.2",
    scripts = {
      {
        path = "resources/scripts/fix-attrs.js"
      },
      {
        path = "resources/scripts/petite-vue.iife.js",
      }
    }
  })
end
