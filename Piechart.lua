local p = {}
local priv = {} -- private functions scope
-- expose private for easy testing/debugging
p.__priv = priv

-- require exact colors for printing
local forPrinting = "-webkit-print-color-adjust: exact; print-color-adjust: exact;"
--[[
	Smooth piechart module.

	Draws charts in HTML with an accessible legend (optional).
	A list of all features is in the "TODO" section of the main `p.pie` function.

	Use with a helper template that adds required CSS.

	{{{1}}}:
	[
		{ "label": "pie: $v", "color": "wheat", "value": 40 },
		{ "label": "cheese pizza $v", "color": "#fc0", "value": 20 },
		{ "label": "mixed pizza: $v", "color": "#f60", "value": 20 },
		{ "label": "raw pizza $v", "color": "#f30" }
	]
	Where $v is a formatted number (see `function prepareLabel`).

	{{{meta}}}:
		{"size":200, "autoscale":false, "legend":true}
	All meta options are optional (see `function p.setupOptions`).
]]
-- Author: [[User:Nux|Maciej Nux]] (pl.wikipedia.org).

--[[
	Debug:
	
	-- labels and auto-value
	local json_data = '[{"label": "k: $v", "value": 33.1}, {"label": "m: $v", "value": -1}]'
	local html = p.renderPie(json_data)
	mw.logObject(html)
	
	-- autoscale values
	local json_data = '[{"value": 700}, {"value": 300}]'
	local html = p.renderPie(json_data, options)
	mw.logObject(html)	
	
	-- size option
	local json_data = '[{"label": "k: $v", "value": 33.1}, {"label": "m: $v", "value": -1}]'
	local options = '{"size":200}'
	local html = p.renderPie(json_data, options)
	mw.logObject(html)	

	-- custom colors
	local json_data = '[{"label": "k: $v", "value": 33.1, "color":"black"}, {"label": "m: $v", "value": -1, "color":"green"}]'
	local html = p.renderPie(json_data)
	mw.logObject(html)
	
	-- 4-cuts
	local entries = {
		'{"label": "ciastka: $v", "value": 2, "color":"goldenrod"}',
		'{"label": "słodycze: $v", "value": 4, "color":"darkred"}',
		'{"label": "napoje: $v", "value": 1, "color":"lightblue"}',
		'{"label": "kanapki: $v", "value": 3, "color":"wheat"}'
	}
	local json_data = '['..table.concat(entries, ',')..']'
	local html = p.renderPie(json_data, '{"autoscale":true}')
	mw.logObject(html)

	-- colors
	local fr = { args = { " 123 " } }
	local ret = p.color(fr)
]]

--[[
	Color for a slice (defaults).

	{{{1}}}: slice number
]]
function p.color(frame)
	local index = tonumber(priv.trim(frame.args[1]))
	return ' ' .. priv.defaultColor(index)
end

--[[
	Piechart.
	
	TODO:
	- [x] basic 2-element pie chart
		- read json
		- calculate value with -1
		- generate html
		- new css + tests
		- provide dumb labels (just v%)
	- [x] colors in json
	- [x] 1st value >= 50%
	- [x] custom labels support
	- [x] pie size from 'meta' param (options json)
	- [x] pl formatting for numbers?
	- [x] support undefined value (instead of -1)
	- [x] undefined in any order
	- [x] scale values to 100% (autoscale)
	- [x] order values clockwise (not left/right)
	- [x] multi-cut pie
	- [x] sanitize user values
	- [x] auto colors
	- [x] function to get color by number (for custom legend)
	- [x] remember and show autoscaled data
	- [x] generate a legend
	- [x] simple legend positioning by (flex-)direction
	- legend2: customization
		- (?) itemTpl support
			- replace default item with tpl
			- can I / should I sanitize it?
			- support for $v, $d, $p
		- (?) custom head
	- (?) validation of input
		- check if required values are present
		- message showing whole entry, when entry is invalid
		- pre-sanitize values?
		- sane info when JSON fails? Maybe dump JSON and show example with quotes-n-all...
	- (?) option to sort entries by value
]] 
function p.pie(frame)
	local json_data = priv.trim(frame.args[1])
	local options = {}
	if (frame.args.meta) then
		options.meta = priv.trim(frame.args.meta)
	end

	local html = p.renderPie(json_data, options)
	return priv.trim(html)
end

-- Setup chart options.
function p.setupOptions(user_options)
	local options = {
		-- circle size in [px]
		size = 100,
		-- autoscale values (otherwise assume they sum up to 100)
		autoscale = false,
		-- hide chart for screen readers (when you have a table, forced for legend)
		ariahidechart = false,
		-- show legend (defaults to the left side)
		legend = false,
		-- direction of legend-chart flexbox (flex-direction)
		direction = "",
		-- width of the main container
		-- when direction is used defaults to max-width, otherwise it's not added
		width = "",
		-- caption above the labels
		caption = "",
		-- footer below the labels
		footer = "",
	}
	-- internals
	options.style = ""
	if user_options.meta then
		local rawOptions = mw.text.jsonDecode(user_options.meta, mw.text.JSON_TRY_FIXING)
		if rawOptions then
			if type(rawOptions.size) == "number" then
				options.size = math.floor(rawOptions.size)
			end
			options.autoscale = rawOptions.autoscale or false 
			if rawOptions.legend then
				options.legend = true
			end
			if rawOptions.ariahidechart then
				options.ariahidechart = true
			end
			if (type(rawOptions.direction) == "string") then
				-- Remove unsafe/invalid characters
				local sanitized = rawOptions.direction:gsub("[^a-z0-9%-]", "")
				-- also adjust width so that row-reverse won't push things to the right
				options.direction = 'flex-direction: ' .. sanitized .. ';'
				options.width = 'width: max-content;'
			end
			if (type(rawOptions.width) == "string") then
				-- note, this intentionaly overwrites what was set for direction
				local sanitized = rawOptions.width:gsub("[^a-z0-9%-]", "")
				options.width = 'width: ' .. sanitized .. ';'
			end
			if (type(rawOptions.caption) == "string") then
				options.caption = rawOptions.caption
			end
			if (type(rawOptions.footer) == "string") then
				options.footer = rawOptions.footer
			end
		end
		-- build style
		if options.width ~= "" then
			options.style = options.style .. options.width
		end
		if options.direction ~= "" then
			options.style = options.style .. options.direction
		end
	end
	if (options.legend) then
		options.ariahidechart = true
	end
	return options
end

--[[
	Render piechart.
	
	@param json_data JSON string with pie data.
]]
function p.renderPie(json_data, user_options)
	local data = mw.text.jsonDecode(json_data, mw.text.JSON_TRY_FIXING)
	local options = p.setupOptions(user_options)

	-- prepare
	local ok, total = p.prepareEntries(data, options)

	-- init render
	local html = "<div class='smooth-pie-container' style='"..options.style.."'>"

	-- error info
	if not ok then
		html = html .. priv.renderErrors(data)
	end

	-- render legend
	if options.legend then
		html = html .. p.renderLegend(data, options)
	end

	-- render items
	local header, items, footer = p.renderEntries(ok, total, data, options)
	html = html .. header .. items .. footer

	-- end .smooth-pie-container
	html = html .. "\n</div>"

	return html
end

-- Check if sum will trigger autoscaling
function priv.willAutoscale(sum)
	-- Compare with a number larger then 100% to avoid floating-point precision problems
	return sum - 100 > 1e-4
end

-- Prepare data (slices etc)
function p.prepareEntries(data, options)
	local sum = priv.sumValues(data);
	-- force autoscale when over 100
	if priv.willAutoscale(sum) then
		options.autoscale = true
	end
	-- pre-format entries
	local ok = true
	local no = 0
	local total = #data
	for index, entry in ipairs(data) do
		no = no + 1
		if not priv.prepareSlice(entry, no, sum, total, options) then
			no = no - 1
			ok = false
		end
	end
	total = no -- total valid

	return ok, total
end

function priv.sumValues(data)
	local sum = 0;
	for _, entry in ipairs(data) do
		local value = entry.value
		if not (type(value) ~= "number" or value < 0) then
			sum = sum + value
		end
	end
	return sum
end

-- render error info
function priv.renderErrors(data)
	local html = "\n<ol class='chart-errors' style='display:none'>"
	for _, entry in ipairs(data) do
		if entry.error then
			local entryJson = mw.text.jsonEncode(entry)
			html = html .. "\n<li>".. entryJson .."</li>"
		end
	end
	return html .. "\n</ol>\n"
end

-- Prepare single slice data (modifies entry).
-- @param no = 1..total
function priv.prepareSlice(entry, no, sum, total, options)
	local autoscale = options.autoscale
	local value = entry.value
	if (type(value) ~= "number" or value < 0) then
		if autoscale then
			entry.error = "cannot autoscale unknown value"
			return false
		end
		value = 100 - sum
	end
	-- entry.raw only when scaled
	if autoscale then
		entry.raw = value
		value = (value / sum) * 100
	end
	entry.value = value

	-- prepare final label
	entry.label = priv.prepareLabel(entry.label, entry)
	-- background, but also color for MW syntax linter
	entry.bcolor = priv.backColor(entry, no, total) .. ";color:#000"

	return true
end

-- render legend for pre-processed entries
function p.renderLegend(data, options)
	local html = ""
	if options.caption ~= "" or options.footer ~= "" then
		html = "\n<div class='smooth-pie-legend-container'>"
	end
	if options.caption ~= "" then
		html = html .. "<div class='smooth-pie-caption'>" .. options.caption .. "</div>"
	end
	html = html .. "\n<ol class='smooth-pie-legend'>"
	for _, entry in ipairs(data) do
		if not entry.error then
			html = html .. priv.renderLegendItem(entry, options)
		end
	end
	html = html .. "\n</ol>\n"
	if options.footer ~= "" then
		html = html .. "<div class='smooth-pie-footer'>" .. options.footer .. "</div>"
	end
	if options.caption ~= "" or options.footer ~= "" then
		html = html .. "</div>\n"
	end
	return html
end
-- render legend item
function priv.renderLegendItem(entry, options)
	-- invisible value (for a11y reasons this should not be used for important values!)
	if entry.visible ~= nil and entry.visible == false then
		return ""
	end

	local label = entry.label
	local bcolor = entry.bcolor
	local html = "\n<li>"
	html = html .. '<span class="l-color" style="'..forPrinting..bcolor..'"></span>'
	html = html .. '<span class="l-label">'..label..'</span>'
	return html .. "</li>"
end

-- Prepare data (slices etc)
function p.renderEntries(ok, total, data, options)
	-- cache for some items (small slices)
	p.cuts = mw.loadJsonData('Module:Piechart/cuts.json')

	local first = true
	local previous = 0
	local no = 0
	local items = ""
	local header = ""
	for index, entry in ipairs(data) do
		if not entry.error then
			no = no + 1
			if no == total then
				header = priv.renderFinal(entry, options)
			else
				items = items .. priv.renderOther(previous, entry, options)
			end
			previous = previous + entry.value
		end
	end
	local footer = '\n</div>'

	return header, items, footer
end
-- final, but header...
function priv.renderFinal(entry, options)
	local label = entry.label
	local bcolor = entry.bcolor
	local size = options.size

	-- hide chart for readers, especially when legend is there
	local aria = ""
	if (options.ariahidechart) then
		aria = 'aria-hidden="true"'
	end

	-- slices container and last slice
	local style = 'width:'..size..'px;height:'..size..'px;'..bcolor..';'..forPrinting
	local html = [[
<div class="smooth-pie"
	style="]]..style..[["
	title="]]..p.extract_text(label)..[["
	]]..aria..[[
>]]
	return html
end
-- any other then final
function priv.renderOther(previous, entry, options)
	local value = entry.value
	local label = entry.label
	local bcolor = entry.bcolor

	-- value too small to see
	if (value < 0.03) then
		mw.log('value too small', value, label)
		return ""
	end
	
	local html =  ""
	
	local size = ''
	-- mw.logObject({'v,p,l', value, previous, label})
	if (value >= 50) then
		html = priv.sliceWithClass('pie50', 50, value, previous, bcolor, label)
	elseif (value >= 25) then
		html = priv.sliceWithClass('pie25', 25, value, previous, bcolor, label)
	elseif (value >= 12.5) then
		html = priv.sliceWithClass('pie12-5', 12.5, value, previous, bcolor, label)
	elseif (value >= 7) then
		html = priv.sliceWithClass('pie7', 7, value, previous, bcolor, label)
	elseif (value >= 5) then
		html = priv.sliceWithClass('pie5', 5, value, previous, bcolor, label)
	else
		-- 0-5%
		local cutIndex = priv.round(value*10)
		if cutIndex < 1 then
			cutIndex = 1
		end
		local cut = p.cuts[cutIndex]
		local transform = priv.rotation(previous)
		html = priv.sliceX(cut, transform, bcolor, label)
	end	
	-- mw.log(html)

	return html
end

-- round to int
function priv.round(number)
	return math.floor(number + 0.5)
end

-- render full slice with specific class
function priv.sliceWithClass(sizeClass, sizeStep, value, previous, bcolor, label)
	local transform = priv.rotation(previous)
	local html =  ""
	html = html .. priv.sliceBase(sizeClass, transform, bcolor, label)
	-- mw.logObject({'sliceWithClass:', sizeClass, sizeStep, value, previous, bcolor, label})
	if (value > sizeStep) then
		local extra = value - sizeStep
		transform = priv.rotation(previous + extra)
		-- mw.logObject({'sliceWithClass; extra, transform', extra, transform})
		html = html .. priv.sliceBase(sizeClass, transform, bcolor, label)
	end
	return html
end

-- render single slice
function priv.sliceBase(sizeClass, transform, bcolor, label)
	local style = bcolor
	if transform ~= "" then
		style = style .. '; ' .. transform
	end
	return '\n\t<div class="'..sizeClass..'" style="'..style..'" title="'..p.extract_text(label)..'"></div>'
end

-- small slice cut to fluid size.
-- range in theory: 0 to 24.(9)% reaching 24.(9)% for cut = +inf
-- range in practice: 0 to 5%
function priv.sliceX(cut, transform, bcolor, label)
	local path = 'clip-path: polygon(0% 0%, '..cut..'% 0%, 0 100%)'
	return '\n\t<div style="'..transform..'; '..bcolor..'; '..path..'" title="'..p.extract_text(label)..'"></div>'
end

-- translate value to turn rotation
function priv.rotation(value)
	if (value > 0) then
		return string.format("transform: rotate(%.3fturn)", value/100)
	end
	return ''
end

-- Language sensitive float, small numbers.
function priv.formatNum(value)
	local lang = mw.language.getContentLanguage()
	
	-- doesn't do precision :(
	-- local v = lang:formatNum(value)
	
	local v = ""
	if (value < 10) then
		v = string.format("%.2f", value)
	else
		v = string.format("%.1f", value)
	end
	if (lang:getCode() == 'pl') then
		v = v:gsub("%.", ",")
	end
	return v
end

-- Format large values.
function priv.formatLargeNum(value)
	local lang = mw.language.getContentLanguage()
	-- add thusands separators
	local v = lang:formatNum(value)
	return v
end
-- Testing formatLargeNum.
-- p.__priv.test_formatLargeNum()
function priv.test_formatLargeNum()
	mw.log("must not add fractional part")
	mw.log( p.__priv.formatLargeNum(12) )
	mw.log( p.__priv.formatLargeNum(123) )

	mw.log("should preserve fractional part for small numbers")
	mw.log( p.__priv.formatLargeNum(1.1) )
	mw.log( p.__priv.formatLargeNum(1.12) )
	mw.log( p.__priv.formatLargeNum(12.1) )
	mw.log("can preserve long fractional part")
	mw.log( p.__priv.formatLargeNum(1.1234) )
	mw.log( p.__priv.formatLargeNum(1.12345) )
	
	mw.log("should add separators above 1k")
	mw.log( p.__priv.formatLargeNum(999) )
	mw.log( p.__priv.formatLargeNum(1234) )
	mw.log( p.__priv.formatLargeNum(12345) )
	mw.log( p.__priv.formatLargeNum(123456) )
	mw.log( p.__priv.formatLargeNum(1234567) )

	mw.log("must handle large float, but might round values")
	mw.log( p.__priv.formatLargeNum(1234.123) )
	mw.log( p.__priv.formatLargeNum(12345.123) )
	mw.log( p.__priv.formatLargeNum(123456.123) )
	mw.log( p.__priv.formatLargeNum(1234567.123) )
end

--[[
	Prepare final label.

	Typical tpl:
		"Abc: $v"
	will result in:
		"Abc: 23%" -- when values are percentages
		"Abc: 1234 (23%)" -- when values are autoscaled
	
	Advanced tpl:
		"Abc: $d ($p)" -- only works with autoscale
]]
function priv.prepareLabel(tpl, entry)
	-- static tpl
	if tpl and not string.find(tpl, '$') then
		return tpl
	end

	-- format % value without %
	local p = priv.formatNum(entry.value)

	-- default template
	if not tpl then
		tpl = "$v"
	end
	
	local label = "" 
	if entry.raw then
		local d = priv.formatLargeNum(entry.raw)
		label = tpl:gsub("%$p", p .. "%%"):gsub("%$d", d):gsub("%$v", d .. " (" .. p .. "%%)")
	else
		label = tpl:gsub("%$v", p .. "%%")
	end
	return label
end

-- default colors
-- source: https://colorbrewer2.org/#type=diverging&scheme=PRGn&n=6
local colorGroupSize = 3 -- must be at least 3
local colorGroups = 4
local colorPalette = {
-- green (from dark)
'#1b7837',
'#7fbf7b',
'#d9f0d3',
-- violet
'#762a83',
'#af8dc3',
'#e7d4e8',
-- red
'#d73027',
'#fc8d59',
'#fee090',
-- blue
'#4575b4',
'#91bfdb',
'#e0f3f8',
}
local lastColor = '#fff'
-- background color from entry or the default colors
function priv.backColor(entry, no, total)
	if (type(entry.color) == "string") then
		-- Remove unsafe characters from entry.color
		local sanitizedColor = entry.color:gsub("[^a-zA-Z0-9#%-]", "")
		return 'background:' .. sanitizedColor
	else
		local color = priv.defaultColor(no, total)
		return 'background:' .. color
	end
end
-- color from the default colors
function priv.defaultColor(no, total)
	local color = lastColor
	if no <= 0 then
		return color
	end
	local size = #colorPalette
	if not total or total == 0 then
		total = size + 1
	end
	local colorNo = priv.defaultColorNo(no, total, size)
	if colorNo > 0 then
		color = colorPalette[colorNo]
	end
	return color
end
-- gets color number from default colors
-- trys to return a light color as the last one
-- 0 means white-ish color should be used
function priv.defaultColorNo(no, total, size)
	local color = 0 -- special, lastColor
	if total == 1 then
		color = 1
	elseif total <= colorGroupSize * (colorGroups - 1) then
		if no < total then
			color = no
		else
			local groupIndex = ((no - 1) % colorGroupSize)
			if groupIndex == 0 then -- dark
				color = no+1
			elseif groupIndex == 1 then -- med
				color = no+1
			else
				color = no
			end
		end
	elseif no < total then
		color = ((no - 1) % size) + 1
	end
	return color
end
--[[
	Testing defaultColorNo:
	p.__priv.test_defaultColorNo(1, 12)
	p.__priv.test_defaultColorNo(2, 12)
	p.__priv.test_defaultColorNo(3, 12)
	p.__priv.test_defaultColorNo(4, 12)
	p.__priv.test_defaultColorNo(5, 12)
	p.__priv.test_defaultColorNo(6, 12)
]]
function priv.test_defaultColorNo(total, size)
	for no=1,total do
		local color = priv.defaultColorNo(no, total, size)
		mw.logObject({no=no, color=color})
	end
end

--[[
	trim string
	
	note:
	`(s:gsub(...))` returns only a string
	`s:gsub(...)` returns a string and a number
]]
function priv.trim(s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

--[[
  Extract text from simple wikitext.
  
  For now only works with links.
]]
-- Tests:
-- mw.log(p.extract_text("[[candy|sweets]]: $v"))
-- mw.log(p.extract_text("[[sandwich]]es: $v"))
-- mw.log(p.extract_text("sandwich]]es: $v"))
-- mw.log(p.extract_text("sandwiches: $v"))
function p.extract_text(label)
	label = label
		-- replace links with pipe (e.g., [[candy|sweets]])
		:gsub("%[%[[^|%]]+|(.-)%]%]", "%1")
		-- replace simple links without pipe (e.g., [[sandwich]])
		:gsub("%[%[(.-)%]%]", "%1")
		-- remove templates?
		-- :gsub("{.-}", "")
		-- remove tags
		:gsub("<[^>]+>", "")
		-- escape special chars just in case
		:gsub("<", "&lt;"):gsub(">", "&gt;")
		:gsub("'", "&#39;"):gsub("\"", "&quot;")
	return label
end

--[[
  Parse classic template params into JSON.

From:  
|label1=cookies: $v |value1=11 |color1=goldenrod
|label2=sweets: $v |value2=20 |color2=darkred

To:
{"value":11,"color":"goldenrod","label":"cookies: $v"},
{"value":20,"color":"darkred","label":"sweets: $v"},

]]
function p.parseEnumParams(frame)
	local args = frame:getParent().args
	local result = {}
	
	local i = 1
	local sum = 0.0
	local hasCustomColor = false -- has last custom color
	while args["value" .. i] do
		-- value is required in this mode; it's also assumed to be 0..100
		local entry = { value = tonumber(args["value" .. i]) or 0 }
		-- label and color is optional
		local label = args["label" .. i]
		if label and label ~= "" then
			entry.label = label
		end
		hasCustomColor = false
		local color = args["color" .. i]
		if color and color ~= "" then
			entry.color = color
			hasCustomColor = true
		end
		table.insert(result, entry)
		sum = sum + entry.value
		i = i + 1
	end
	-- re-loop to set values in labels
	for _, entry in ipairs(result) do
		local label = entry.label
		if label and not label:find("%$v") then
			-- autoscale will be forced, so use $v in labels
			if priv.willAutoscale(sum) then
				entry.label = label .. " $v"
			else
				entry.label = label .. " (" .. entry.value .. "%)"
			end
		end
	end

	-- support other value mapping
	local lang = mw.language.getContentLanguage()
	local langOther = "Other"
	if (lang:getCode() == 'pl') then
		langOther = "Inne"
	end
	local colorOther = "#FEFDFD" -- white-ish for custom colors for best chance and contrast
	
	local otherValue = 100 - sum
	if args["other"] and args["other"] ~= "" then
		if otherValue < 0.001 then
			otherValue = 0
		end
		local otherEntry = { label = (args["other-label"] or langOther) .. " ("..priv.formatNum(otherValue).."%)" }
		if args["other-color"] and args["other-color"] ~= "" then
			otherEntry.color = args["other-color"]
		else
			otherEntry.color = colorOther
		end
		table.insert(result, otherEntry)
	elseif otherValue > 0.01 then
		if hasCustomColor then
			table.insert(result, {visible = false, label = langOther .. " ($v)", color = colorOther})
		else
			table.insert(result, {visible = false, label = langOther .. " ($v)"})
		end
	end
	
	local jsonString = mw.text.jsonEncode(result)
	return jsonString
end

-- Function to check if a value is true-ish
local trueValues = { ["true"] = true, ["1"] = true, ["on"] = true, ["yes"] = true }
function priv.isTrueishValue(value)
	-- should return nil for empty args (i.e. undefined i.e. default)
	if not value or value == "" then return nil end
	value = priv.trim(value)
	if value == "" then return nil end
	-- other non-empty are false
	return trueValues[value:lower()] or false
end

--[[
  Parse classic template params into JSON with chart meta data.
]]
function p.parseMetaParams(frame)
	local args = frame:getParent().args
	local meta = {}

	-- default meta for value1..n parameters
	-- ...and for thumb right/left
	local thumb = args["thumb"]
	if args["value1"] or (thumb and (thumb == "right" or thumb == "left")) then
		meta.size = 200
		meta.legend = true
	end

	-- explicit meta param
	if args["meta"] then
		meta = mw.text.jsonDecode(args["meta"], mw.text.JSON_TRY_FIXING)
	end


	if args["size"] then meta.size = tonumber(args["size"]) end
	if args["radius"] and tonumber(args["radius"]) then
		meta.size = 2 * tonumber(args["radius"])
	end
	if args["autoscale"] then meta.autoscale = priv.isTrueishValue(args["autoscale"]) end
	if args["legend"] then meta.legend = priv.isTrueishValue(args["legend"]) end
	if args["ariahidechart"] then meta.ariahidechart = priv.isTrueishValue(args["ariahidechart"]) end
	if args["direction"] and args["direction"] ~= "" then
		meta.direction = args["direction"]:gsub("[^a-z0-9%-]", "")
	end
	if args["width"] and args["width"] ~= "" then
		meta.width = args["width"]:gsub("[^a-z0-9%-]", "")
	end
	if args["caption"] and args["caption"] ~= "" then
		meta.caption = args["caption"]
	end
	if args["footer"] and args["footer"] ~= "" then
		meta.footer = args["footer"]
	end

	return mw.text.jsonEncode(meta)
end

return p