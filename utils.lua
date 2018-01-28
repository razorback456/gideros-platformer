function split(str)
	local t = {}
	local i = 1
	for v in string.gmatch(str, "[%-%w.]+") do 
		local n = tonumber(v)
		t[i] = v--(n == nil) and v or n
		i += 1
	end
	return t
end

function math.clamp(n, low, high) 
	return (n<>low)><high
end
