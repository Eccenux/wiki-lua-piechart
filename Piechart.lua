local p = {}
--[[
	Debug:
	
	local json_data = '[{"label": "k: $v", "value": 33.1}, {"label": "m: $v", "value": -1}]'
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
    - 2-element pie chart
        - read json
        - calculate value with -1
        - generate html
        - new css + tests
        - provide dumb labels (just v%)
    - custom labels support
    - pie radius from a 2nd param?
    - colors in json
    - pl formatting for numbers?
    - support undefined value? (instead of -1)
    - scale values to 100%
    	- values: 10, 30 -> total = 40; values: 10/40, 30/40
    	- (?) values: 10, -1, total: 40
    - generate a legend
    	- (?) $info: $values.join(separator)
    	- (?) or a list with css formatting (that could be overriden)
    - 3-element pie chart
    - (?) option to sort entries by value
]] 
function p.pie(frame)
	local json_data = trim(frame.args[1])
	local html = p.renderPie(json_data)
	return html
end

--[[
	Render piechart.
	
	@param json_data JSON string with pie data.
]]
function p.renderPie(json_data)
	local html = ""
	local sum = 0;
	local data = mw.text.jsonDecode( json_data )
	local size = 100 -- [px]
	for _, entry in ipairs(data) do
	    html = html .. '\n\t' .. renderSlice(entry, sum, size)
    	sum = sum + entry.value
	end
	
	-- first label
	local label = formatValue(data[1].label, data[1].value)
	
	html = [[
<div class="smooth-pie"
     style="width: ]]..size..[[px; height: ]]..size..[[px; background-color: #347BFF;"
     title="]]..label..[["
>]]
	.. html 
	.. '\n</div>'

	return html
end

--[[
	Render a single slice.
	
	@param entry Current entry.
	@param entry Sum up-until now (in 2-pie that would be % for first value).
]]
function renderSlice(entry, sum, size)
	local value = entry.value
	if entry.value < 0 then
        value = 100 - sum
	end

	local label = formatValue(entry.label, value)
	
	-- local html =  "<p>" .. "Label: " .. label  .. "; value: " .. value  .. "</p>"
	local html =  ""
	
	local trans = string.format("translatex(%.0fpx)", size/2)
	local back = 'background-color: #1a3d7f'
	if (value < 50) then
		local rotate = string.format("rotate(-%.3fturn)", value/100)
		html = html .. '<div class="piemask"><div class="slice" style="transform: scale(-1, 1) ' .. rotate .. trans ..'; ' .. back .. ';" title="' .. label  .. '"></div></div>'
	end

	return html
end

function formatValue(label, value)
	-- local label = entry.label:gsub("%$v", value)
	return string.format("%.1f", value) .. "%"
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