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
local json_data = '[{"label": "k: $v", "value": 3.2}, {"label": "m: $v", "value": -1}]'
local user_options = {}
user_options.meta = '{"legend":true}'
-- html = p.renderPie(json_data, user_options)
-- -- mw.logObject(html)
-- print(html)

function test_prepareLabel(tpl, entry)
	print( string.format("[L:%s][t:%s]", tostring(entry.label), tostring(tpl)), '->', p.__priv.prepareLabel(tpl, entry) )
end

mw.logObject ({value= 3.2})
test_prepareLabel("", {label= "k: $v", value= 3.2})
test_prepareLabel("$L: $v", {label= "k", value= 3.2})
test_prepareLabel("$v", {label= "k", value= 3.2})
test_prepareLabel("$auto", {label= "k", value= 3.2})
test_prepareLabel("$auto: $L", {label= "k", value= 3.2})
test_prepareLabel("$auto: $label", {label= "k", value= 3.2})
test_prepareLabel("$percent [$value]: $label", {label= "k", value= 3.2})

-- raw is required for $d to work properly
-- raw is added when autoscale is on
mw.logObject ({label= "k", value= 25, raw=4})
test_prepareLabel("d=$d, p=$p", {label= "k", value= 25, raw=4})
test_prepareLabel("v=$v, d=$d, p=$p", {label= "k", value= 25, raw=4})
test_prepareLabel("L=$L, v=$v, d=$d, p=$p", {label= "k", value= 25, raw=4})
-- without raw this should at least give something
mw.logObject ({info="same without raw"})
test_prepareLabel("d=$d, p=$p", {label= "k", value= 25})
test_prepareLabel("v=$v, d=$d, p=$p", {label= "k", value= 25})
test_prepareLabel("L=$L, v=$v, d=$d, p=$p", {label= "k", value= 25})
