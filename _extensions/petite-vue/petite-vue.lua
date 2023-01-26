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

local function createKVPairs(inputstr)
  inputstr = string.gsub(inputstr, "[{}]", "")
  ---@type table<number, string>
  local rows = {}
  ---@type table<string, string>
  local kvPairs = {}
  --- Split string into rows separated by commas
  for str in string.gmatch(inputstr, "([^,]+)") do
    table.insert(rows, str)
  end
  --- Split rows into key value pairs separated by colons
  for _, v in pairs(rows) do
    ---@type table<string>
    local x, y = string.match(v, '"(.+)":"(.+)"');
    kvPairs[x] = y;
  end
  return kvPairs;
end

---Fixes attributes that are of the form foo:bar:baz
---@param div pandoc.Div
---@return pandoc.Div
local function fixColonAttributes(div)
  local vbind = div.attributes["v-bind"];
  local von = div.attributes["v-on"];
  if (vbind) then
    local values = createKVPairs(vbind)
    for k, v in pairs(values) do
      div.attributes["v-bind:" ..  string.gsub(k, '"', "")] = string.gsub(v, '"', "");
    end
  end
  if (von) then
    local values = createKVPairs(von)
    for k, v in pairs(values) do
      div.attributes["v-on:" .. string.gsub(k, '"', "")] = string.gsub(v, '"', "");
    end
  end
  return div;
end

function Header(el)
  if kIsHTML then
    return fixColonAttributes(el);
  else
    return el;
  end
end

function Div(el)
  if kIsHTML then
    return fixColonAttributes(el);
  else
    return el;
  end
end
