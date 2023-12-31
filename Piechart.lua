local p = {}
--[[
	Debug:
	
	local json_data = '[{"label": "k: $v", "value": 33.1}, {"label": "m: $v", "value": -1}]'
	local html = p.renderPie(json_data)
	mw.logObject(html)
	
	local json_data = '[{"label": "k: $v", "value": 33.1}, {"label": "m: $v", "value": -1}]'
	local options = '{"size":200}'
	local html = p.renderPie(json_data, options)
	mw.logObject(html)	

	local json_data = '[{"label": "k: $v", "value": 33.1, "color":"black"}, {"label": "m: $v", "value": -1, "color":"green"}]'
	local html = p.renderPie(json_data)
	mw.logObject(html)
]]

--[[
	Piechart.
	
	{{{1}}}:
	[
        { "label": "k: $v", "value": 33.1  },
        { "label": "m: $v", "value": -1  },
    ]
    where $v is a formatted label

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
    - generate a legend
    	- (?) $info: $values.join(separator)
    	- (?) or a list with css formatting (that could be overriden)
    - scale values to 100%
    	- values: 10, 30 -> total = 40; values: 10/40, 30/40
    	- (?) values: 10, -1, total: 40
    - 3-element pie chart
    - (?) option to sort entries by value
]] 
function p.pie(frame)
	local json_data = trim(frame.args[1])
	local options = nil
	if (frame.args.meta) then
		options = trim(frame.args.meta)
	end
	
	local html = p.renderPie(json_data, options)
	return html
end

--[[
	Render piechart.
	
	@param json_data JSON string with pie data.
]]
function p.renderPie(json_data, json_options)
	local data = mw.text.jsonDecode(json_data)
	local options = nil
	if json_options then
		options = mw.text.jsonDecode(json_options)
	end
	local size = options and options.size or 100 -- [px]

	local html = ""
	local sum = sumValues(data);
	for index, entry in ipairs(data) do
	    local html_slice, value = renderSlice(entry, sum, size, index)
	    html = html .. html_slice
	end
	html = html .. '\n</div>'

	return html
end

function sumValues(data)
	local sum = 0;
	for _, entry in ipairs(data) do
		local value = entry.value
		if not (value == nil or value < 0) then
		    sum = sum + value
		end
	end
	return sum
end

--[[
	Render a single slice.
	
	@param entry Current entry.
	@param entry Sum up-until now (in 2-pie that would be % for first value).
]]
function renderSlice(entry, sum, size, no)
	local value = entry.value
	if value == nil or value < 0 then
        value = 100 - sum
	end

	local label = formatValue(entry.label, value)
	local bcolor = backColor(entry, no)
	
	-- local html =  "<p>" .. "Label: " .. label  .. "; value: " .. value  .. "</p>"
	local html =  ""
	
	-- first label (left side)
	if (no==1) then
		local style = 'width:'..size..'px; height:'..size..'px;'..bcolor
		html = [[
<div class="smooth-pie"
     style="]]..style..[["
     title="]]..label..[["
>]]
		return html, value
	end
	
	-- no>1
	local trans = string.format("translatex(%.0fpx)", size/2)
	if (value < 50) then
		local rotate = string.format("rotate(-%.3fturn)", value/100)
		local transform = 'transform: scale(-1, 1) ' .. rotate .. ' ' .. trans ..';'
		html = html .. '\n\t<div class="piemask"><div class="slice" style="'..transform..' '..bcolor..'" title="'..label..'"></div></div>'
	else
		-- 50%
		html = html .. '\n\t<div class="piemask"><div class="slice" style="'..bcolor..'" title="'..label..'"></div></div>'
		-- value overflowing 50% (extra slice)
		if (value > 50) then
			local rotate = string.format("rotate(-%.3fturn)", (value-50)/100)
			local maskTransform = 'transform: rotate(0.5turn);'
			local transform = 'transform: scale(-1, 1) ' .. rotate .. ' ' .. trans ..';'
			html = html .. '\n\t<div class="piemask" style="'..maskTransform..'"><div class="slice" style="'..transform..' '..bcolor..'" title="'..label..'"></div></div>'
		end
	end

	return html, value
end

function formatValue(label, value)
	local lang = mw.language.getContentLanguage()
	local v = lang:formatNum(value) --string.format("%.1f", value)
	local l = "" 
	if label then
		l = label:gsub("%$v", v..'%%')
	else
		l = v .. "%"
	end
	return l
end
-- #no for later - get deafult form a pallete of colors (probably looping around)
function backColor(entry, no)
    if entry.color then
        return 'background-color: ' .. entry.color
    else
        return ''
    end
end

--[[
	trim string
	
	note:
	`(s:gsub(...))` returns only a string
	`s:gsub(...)` returns a string and a number
]]
function trim(s)
	return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

return p