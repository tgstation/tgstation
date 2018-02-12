--THIS IS A MODIFIED VERSION OF MY DMETOOL MADE FOR GIT CONFLICT HOOKS

local ours = arg[3]
local theirs = arg[4]
local output = arg[1]

if(not ours or not theirs) then
	print("Uhhh, theirs/ours/output didn't exist!")
	return 1
end

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
<<<<<<< HEAD
	table.sort(DME.includes, cmp)
=======
	table.sort(DME.includes, function(a, b) return tostring(a) < tostring(b) end)
>>>>>>> 91b6145f11884260c572414bcd979cd4feb93bdb
	for k,v in pairs(DME.includes) do
		thing[start_defines+k] = "#include \""..v.."\""
	end
	thing[#thing+1] = "// END_INCLUDE"
	return thing
end

local inn = dme_parse(theirs)
local int = dme_parse(ours)
local differences = 0
for k,v in pairs(int.includes) do
	if(not table_has_thing(inn.includes, v))then
		inn.includes[#inn.includes+1] = v
		differences = differences+1
	end
end
local out = construct_file_out(inn)
local fa = io.open(output, "w") --clear out the file!
<<<<<<< HEAD
fa:write("")
=======
fa:write(" ")
>>>>>>> 91b6145f11884260c572414bcd979cd4feb93bdb
fa:close()
local fb = io.open(output, "a")
for k,v in pairs(out) do
	fb:write(v, "\n")
end
fb:close()
print(theirs.." merged into "..ours.." and outputted into "..output.."!")
print("There were "..tostring(differences).." differences!")
