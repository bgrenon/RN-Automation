local p = {} -- p stands for package
local cargo = mw.ext.cargo

-- merge function copied from Frame description: https://river.me/blog/frame-wtf/#frameexpandtemplate
local function merge()
    local f = mw.getCurrentFrame()
    local origArgs = f.args
    local parentArgs = f:getParent().args
    local args = {}
    for k, v in pairs(origArgs) do
        v = mw.text.trim(tostring(v))
        if v ~= '' then
            args[k] = v
        end
    end
    for k, v in pairs(parentArgs) do
        v = mw.text.trim(v)
        if v ~= '' then
            args[k] = v
        end
    end
    return args
end

local function overwrite(f)
    local origArgs = f.args
    local parentArgs = f:getParent().args
    local args = {}
    for k, v in pairs(parentArgs) do
        v = mw.text.trim(v)
        args[k] = v
    end
    for k, v in pairs(origArgs) do
        v = mw.text.trim(tostring(v))
        args[k] = v
    end
    return args
end
-- finish copied code from https://river.me/blog/frame-wtf/#frameexpandtemplate


-- helpful function to see table contents. Source: https://stackoverflow.com/a/27028488
local function dump(o)
   if type(o) == 'table' then
      local s = '{ '
      for k,v in pairs(o) do
         if type(k) ~= 'number' then k = '"'..k..'"' end
         s = s .. '['..k..'] = ' .. dump(v) .. ','
      end
      return s .. '} '
   else
      return tostring(o)
   end
end

-- helpful function to split strings. Source: https://stackoverflow.com/questions/1426954
local function split(pString, pPattern)
   local Table = {} 
   local fpat = "(.-)" .. pPattern
   local last_end = 1
   local s, e, cap = pString:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
     table.insert(Table,cap)
      end
      last_end = e+1
      s, e, cap = pString:find(fpat, last_end)
   end
   if last_end <= #pString then
      cap = pString:sub(last_end)
      table.insert(Table, cap)
   end
   return Table
end

local function getWikiContent ()
    local mwtitle = mw.title.getCurrentTitle()
    return mwtitle:getContent()
end

local function getTemplateArgs (TemplateName, ArgName)
    -- get MW page content
    local mwcontent = getWikiContent()
    -- get content from inside template
    -- note that this current won't work if there are multiple instance of the template, returning only the first value in that case...
    i, j = string.find(mwcontent, TemplateName)
    if i == nil then
        -- can't find the template; return nil
        return "err: can't find template for: " .. TemplateName
    else
        -- remove any wikitext content outside the template
        local templatecontent = string.match(mwcontent, '%b{}', i-2)
        templatecontent = string.sub(templatecontent, 3, -3)
        if templatecontent == nil then
            -- this shouldn't really happen?
            return "err: no template content found"
        else
            if ArgName == nil then
                -- if no ArgName specified, I guess return a table with all arguments?
                return split(templatecontent, '\|')
            else
                -- try to pull out just the matching value for ArgName
                return string.match(templatecontent, "\|" .. ArgName .. "=([^\|]+)|")
            end
        end
    end
end

function p.findNumberOfSections (frame)
-- ED: TESTING MY CODE HERE
    local args = getTemplateArgs('ArticlePEServiceArchitecture2', 'NumberOfSections')
    return dump(args)
-- Barry's code
    -- local args = overwrite(frame)
    -- return 'number of sections: ' .. dump(args) --.NumberOfSections
-- Old tests
    --local x = frame:expandTemplate{ title = 'ArticlePEServiceArchitecture2', args = NumberOfSections= }
    --for k, v in pairs (x) do 
    --return k,v 
    --end
end
    --local x = mw.getCurrentFrame():getParent().args
   -- return "test: " .. x


--function p.printSection ()
 --  local a = findNumberOfSections
 --      out = ''
--    for i = 1, a do
--        out = out .. "Test" .. i
--    end
--    return out
--end

-- find images
function p.findImages () 
       tables = 'ArticlePEServiceArchitecture,ArticlePEServiceArchitecture__Images'
       fields = 'ArticlePEServiceArchitecture__Images._value=Image'
       local args = {
           join = 'ArticlePEServiceArchitecture._ID=ArticlePEServiceArchitecture__Images._rowID',
           where = 'ArticlePEServiceArchitecture._pageName = "' .. mw.title.getCurrentTitle().prefixedText .. '"',
        }
       local result = cargo.query( tables, fields, args )
       local text = ''
     for i, row in ipairs(result) do
             text =  text .. "[[File:" .. row.Image .. "]]"
         end
         return text
end




--find how many connections for an architecture image
function p.findConnections () 
       tables = 'PEArchitectureSection'
       fields = 'NumberOfConnections'
       local args = {
        where = 'PEArchitectureSection._pageName = "' .. mw.title.getCurrentTitle().prefixedText .. '"',
        }
       local result = cargo.query( tables, fields, args )
     for i, row in ipairs(result) do
             text =  row.NumberOfConnections
         end
        return text
end
--query to build a table based on NumberOfConnections in PEArchitectureSection
function p.printConnections (frame,args) 
local a = frame.args[1]
    local out = "<h2>Connection table</h2><table><tr><th>Connection</th><th>Included Service</th><th>Protocol</th><th>Port</th><th>Connected to</th><th>Data type</th></tr>"
        local x ="</table>"
    for i = 0, a, 1  do
        out = out .. "<tr><td>" .. i + 1 .. "</td>" .. "<td>{{{field|" .. i .. "Service}}}</td>" .. "<td>{{{field|" .. i .. "Protocol}}}</td>".. "</tr>"
    end
    return out,x
end

return p