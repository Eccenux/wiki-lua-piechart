-- include this library
local mw = require("mw/mw")

function formatNum(value)
	local lang = mw.language.getContentLanguage()
	-- add thusands separators
	local v = lang:formatNum(value)
	return v
end
print(formatNum(4))
print(formatNum(40))
print(formatNum(400))
print(formatNum(4000))
print(formatNum(40000))
print(formatNum(400000))
print(formatNum(4000000))
print(formatNum(4000000.123))
