local kIsHTML = quarto.doc.is_format("html:js");

---@param opts table
local function createOptionsTag(opts)
  local tag = "<script id = 'petite-vue-data' type='application/json'>"
    .. quarto.json.encode(opts)
    .. "</script>";
  quarto.doc.include_text('in-header', tag);
end

---@param inputstr string
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
    ---@type string, string
    local x, y = string.match(v, '"(.+)":"(.+)"');
    kvPairs[x] = y;
  end
  return kvPairs;
end

---Fixes attributes that are of the form foo:bar:baz
---@param block pandoc.Block
---@return pandoc.Block
local function fixColonAttributes(block)
  if block.attributes then
    local vbind = block.attributes["v-bind"];
    local von = block.attributes["v-on"];
    if (vbind) then
      local values = createKVPairs(vbind)
      for k, v in pairs(values) do
        block.attributes["v-bind:" .. k] = v;
      end
    end
    if (von) then
      local values = createKVPairs(von)
      for k, v in pairs(values) do
        block.attributes["v-on:" .. k] = v;
      end
    end
  end
  return block;
end

if kIsHTML then
  return {
    {
      Meta = function(meta)
        local vueOptions = meta["petite-vue"];
        local kOpts = {};

        if vueOptions then
          local mountOption = vueOptions.mount;
          if mountOption then
            if mountOption == "auto" then
              kOpts["mount"] = "#quarto-content";
            else
              kOpts["mount"] = mountOption[1].text;
            end
            meta["petite-vue"]["mount"] = nil;
          end
          local scopeOption = vueOptions["v-scope"];
          if scopeOption then
            local scopeOpts = {};
            for k, v in pairs(scopeOption) do
              scopeOpts[k] = v[1].text;
            end
            kOpts["scope"] = scopeOpts;
          end
          meta["petite-vue"]["v-scope"] = nil;
        end
        createOptionsTag(kOpts);
        quarto.doc.add_html_dependency({
          name = "petite-vue",
          version = "0.2.2",
          scripts = {
            {
              path = "resources/scripts/mount-app.js"
            },
            {
              path = "resources/scripts/petite-vue.iife.js",
            }
          }
        })
      end
    },
    {
      Block = function(block)
        return fixColonAttributes(block);
      end
    }
  }
end
