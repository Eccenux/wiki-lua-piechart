local p = {}

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
	-- local json_data = trim(frame.args[1])
	-- local html = renderPie(json_data)
	return "kopytko"
end

--[[
	Render piechart.
	
	@param json_data JSON string with pie data.
]]
function renderPie(json_data)
	local html = ""
	local sum = 0;
	local data = mw.text.jsonDecode( json_data )
	for _, entry in ipairs(data) do
	    html = html .. renderSlice(entry, sum)
    	sum = sum + value
	end
	return html
end

--[[
	Render a single slice.
	
	@param entry Current entry.
	@param entry Sum up-until now (in 2-pie that would be % for first value).
]]
function renderSlice(entry, sum)
	-- local label = entry.label:gsub("%$v", entry.value)
	local label = string.format("%.1f", entry.value) .. "%"
	
	local value = entry.value
	if entry.value < 0 then
        value = 100 - sum
	end

	local html =  "<p>" .. "Label: " .. label  .. "; value: " .. value  .. "</p>"
	
	return html
end