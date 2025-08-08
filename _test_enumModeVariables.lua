-- include this library
local mw = require("mw/mw")

-- replace require to support namespace removal
local originalRequire = require
function require(moduleName)
	moduleName = moduleName:gsub("Modu[^:]+:", "")
	return originalRequire(moduleName)
end

-- Load a copy of a module
-- Note that this loads "Piechart.lua" file (a local file).
local p = require('Module:Piechart')

local user_options = {}
user_options.meta = '{"legend":true, "autoscale":true}'

-- should result in 25% (1/4) parts
print ("should result in 25% (1/4) parts")
local args = {
	value1 = 1,
	value2 = 1,
	value3 = 1,
	value4 = 1,
	label1 = 'label using "$ v": $v [end]',
	label2 = 'label using "$ d": $d [end]',
	label3 = 'label using "$ p": $p [end]',
	label4 = 'label without value variable [end]'
}

-- check parseEnumParams directly
parsedParams = p.__priv.parseEnumParams(args)
mw.logObject(mw.text.jsonDecode(parsedParams))
-- render
html = p.renderPie(parsedParams, user_options)
print(html)
