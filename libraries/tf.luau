-- tableformat (tf)
local _, stdio = pcall(function()
	return require("@lune/stdio")
end)

local DefaultFormatOptions = {
	Prefix = nil,
	ArrayStartIndex = 1,
}

export type TableFormatOptions = {
	Prefix: string?,
	ArrayStartIndex: number?,
}

local function getMemoryAddress(target)
	local address_grabber_pattern = "table: ...([%w]+)"
	local address = tostring(target):match(address_grabber_pattern)
	if not address then -- table has a tostring metamethod we need to temporarily neutralize
		local temp_meta = getmetatable(target)
		setmetatable(target, nil)
		address = tostring(target):match(address_grabber_pattern)
		setmetatable(target, temp_meta)
	end
	return address
end

local tf = {}
function tf.format(t, pretty: boolean?, indent: number?, FormatOptions: TableFormatOptions?, memoized_addresses: any?)
	local pretty = pretty or false
	local indent = indent or 1
	
	local style = stdio.style
	local reset = style("reset")
	local bold = style("bold")
	local dim = style("dim")
	
	local clear = stdio.color("reset")
	local cyan = stdio.color("cyan")
	local blue = stdio.color("blue")
	local purple = stdio.color("purple")
	local red = stdio.color("red")
	local yellow = stdio.color("yellow")
	local green = stdio.color("green")
	local white = stdio.color("white")
	
	if typeof(t) ~= "table" then
		return (
			(if typeof(t) == "string" then
				(if pretty then
					dim .. '"' .. reset .. yellow .. t .. clear .. dim .. '"' .. reset
				else 
					'"' .. t .. '"'
				)
			elseif pretty and typeof(t) == "number" then
				blue .. tostring(t) .. clear
			elseif pretty and typeof(t) == "boolean" then
				yellow .. tostring(t) .. clear
			elseif typeof(t) == "nil" then
				red .. tostring(t) .. clear
			elseif type(t) == "userdata" and pretty then
				dim .. "<" .. reset .. purple .. tostring(t) .. dim .. ">" .. reset
			else
				"<" .. tostring(t) .. ">"
			)
		)
	end

	local memo = {[getMemoryAddress(t)] = "recursive top level"} do
		if memoized_addresses then
			for addy, id in memoized_addresses do
				memo[addy] = id
			end
		end
	end

	if indent > 6 then
		return if pretty then 
			dim ..  "{ ... }" .. reset 
		else 	"{ ... }"
	end
	
	local options = FormatOptions or DefaultFormatOptions
	local prefix = options.Prefix
	
	local result = if prefix then
		if pretty then
			dim .. "[" .. reset .. prefix .. dim .. "]: " .. reset
		else `[{prefix}]: `
	else ""
	
	result ..= "{\n"
	
	local indentation = string.rep(" ", indent * 4)
	local line_terminator = ",\n"
	
	local function_replace = if pretty then
		dim .. purple .. "<" .. clear .. red .. "function" .. clear .. purple .. dim .. ">" .. reset .. clear
	else "<function>"
	local string_left_delim = cyan .. dim .. '"' .. reset .. clear
	local string_right_delim = clear .. dim .. '"' .. reset .. clear
	local left_bracket = cyan .. dim .. '[' .. reset
	local right_bracket = dim .. ']' .. reset .. clear
	
	for key, value in t do
		if typeof(key) == "number" then
			key -= (1 - options.ArrayStartIndex)
		end
		result ..= indentation
		result ..= (
			(if typeof(key) == "function" then
				function_replace
			elseif typeof(key) == "vector" or typeof(key) == "Vector3" then
				(if pretty then
					red .. `[{typeof(key)}({key}])]` .. clear
				else 
					`[{typeof(key)}({key}])]`
				)
			elseif typeof(key) == "string" then
				(if key:match("^[%w]+$") then -- {key = value} vs {["spaced key"] = value}
					if pretty and typeof(value) == "table" then 
						bold .. key .. reset
					elseif pretty and typeof(value) == "function" then
						purple .. key .. clear
					elseif pretty then
						clear .. key .. clear
					else key
				else
					if pretty then
						left_bracket .. string_left_delim .. (if typeof(value) == "function" then purple else cyan) .. key .. string_right_delim .. right_bracket
						-- cyan .. dim .. '["' .. reset .. key .. dim .. '"]' .. reset .. clear
					else "[" .. key .. "]"
				)
			elseif typeof(key) == "number" then
				(if #t > 10 and key < 10 then -- adds a buffer space to single digit keys of arrays w/ 10+ elements
					" "
				else
					""
				) ..	
				(if pretty then
					blue .. "[" .. reset .. blue .. tostring(key) .. blue .. "]" .. reset
				else 
					"[" .. tostring(key) .. "]"
				)
			else
				"[" .. tostring(key) .. "]"
			)
		)
		result ..= " = " .. (
			(if typeof(value) == "table" then
				if (value == t) or memo[getMemoryAddress(value)] then
					if pretty then 
						dim .. `\{ {memo[getMemoryAddress(value)] or "recursive table"} \}` .. reset
					else `\{ {memo[getMemoryAddress(value)] or "recursive table"} \}`
				else tf.format(value, pretty, indent + 1, nil, (function()
						memo[getMemoryAddress(value)] = if pretty then
							'.' .. reset .. bold .. key .. reset .. dim .. ' '
						else "[" .. key .. "]"
						return memo
					end)()
				)
			elseif typeof(value) == "function" then
				function_replace
			elseif typeof(value) == "string" then
				if pretty then
					string_left_delim .. green .. value .. string_right_delim
				else '"' .. value .. '"'
			elseif typeof(value) == "boolean" or typeof(value) == "number" then
				if pretty and typeof(value) == "boolean" then 
					yellow .. tostring(value) .. clear
				elseif pretty and typeof(value) == "number" then
					blue .. tostring(value) .. clear
				else tostring(value)
			elseif typeof(value) == "vector" then
				purple .. "<" .. "vector(" .. purple .. tostring(value) .. ")>"  .. reset .. clear
			elseif type(value) == "userdata" then
				"<" .. reset .. purple .. "buffer" .. clear .. dim .. ">" .. reset
			else
				`{typeof(value)}({tostring(value)})`
			)
		)
		result ..= line_terminator
	end
	local closing_indent = if indent == 1 then 0 else indent - 1
	result ..= string.rep(" ", closing_indent * 4) .. '}'
	return result
end

function tf.run(t, to_stdout: boolean?, options: FormatOptions?)
	if not to_stdout then
		return tf.format(t)
	else
		return tf.format(t, stdio ~= nil, nil, options)
	end
end

function tf.ptf(t, ...)
	print(tf.run(t, true))
	local args = {...}
	if args then
		for _, val in args do
			print(tf.run(val, true))
		end
	end
end
-- tf.run({
-- 	["do something fun"] = function(x, y) return x + y end,
-- 	[1] = "hehe mized table moment",
-- 	[2] = false,
-- 	normal = 3,z e
-- }, true)

return tf.run, tf.ptf