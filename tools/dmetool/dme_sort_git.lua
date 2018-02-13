--THIS IS A MODIFIED VERSION OF MY DMETOOL MADE FOR GIT CONFLICT HOOKS


local input = arg[1]

local function dme_parse(file)
	local file = io.open(file, "r")
	local arr = {}
	local DME = {
		comments = {},
		defines = {},
		includes = {}
	}
	local linenum = 1
	for line in file:lines() do
		if(tostring(line:sub(1,2)) == "//" and type(line:sub(3)) == "string" and not string.find(tostring(line), "_INCLUDE")) then
			DME.comments[linenum] = tostring(line:sub(3))
		elseif(tostring(line:sub(1, 7)) == "#define" and type(line:sub(8)) == "string") then
			DME.defines[linenum] = tostring(line:sub(8))
		elseif(tostring(line:sub(1, 8)) == "#include" and type(line:sub(9)) == "string") then
			local thing = tostring(line:sub(9)):gsub("\"", "") 
			if(thing:sub(1,1) == " ")then
				thing = thing:sub(2)
			end
			DME.includes[#DME.includes+1] = thing
		end
		linenum = linenum+1
	end
	return DME
end

local function get_highest_key(tab)
	local highest_key = 1
	for k,v in pairs(tab) do
		if(type(k) == "number")then
			if(k > highest_key) then
				highest_key = k
			end
		end
	end
	return highest_key
end

local function table_has_thing(tab, thing)
	for k,v in pairs(tab) do
		if(v == thing) then
			return true
		end
	end
	return false
end

local function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
         table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

local function cmp(a,b) --thank you RhodiumToad on freenode's #lua for this!
    local f1,s1,p1 = string.gmatch(a,"([^\\/]*[\\/]?)")
    local f2,s2,p2 = string.gmatch(b,"([^\\/]*[\\/]?)")
    repeat
        p1 = f1(s1,p1)
        p2 = f2(s2,p2)
    until p1 ~= p2 or p1 == nil
    if p1 == nil or p2 == nil then return p2 ~= nil end
    if p2:sub(-1):match("[\\/]") ~= p1:sub(-1):match("[\\/]") then
        return p2:sub(-1):match("[\\/]")
    end
    return (p1 < p2)
end

local function construct_file_out(DME)
	local thing = {}
	for k,v in pairs(DME.comments) do
		thing[k] = "//"..v
	end
	for k,v in pairs(DME.defines) do
		thing[k] = "#define"..v
	end
	local start_defines = get_highest_key(thing)+1
	thing[start_defines] = "// BEGIN_INCLUDE"
	table.sort(DME.includes, cmp)
	for k,v in pairs(DME.includes) do
		thing[start_defines+k] = "#include \""..v.."\""
	end
	thing[#thing+1] = "// END_INCLUDE"
	return thing
end

local abcd = construct_file_out(dme_parse(input))
local fa = io.open(input, "w")--clear out the file
fa:write("")
fa:close()
local file = io.open(input, "a")
for k,v in pairs(abcd) do
	file:write(v, "\n")
end
file:close()
print(tostring(input).." sorted!")

