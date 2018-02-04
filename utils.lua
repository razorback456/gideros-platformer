function split(str)
	local t = {}
	local i = 1
	for v in string.gmatch(str, "[%-%w.]+") do 
		local n = tonumber(v)
		t[i] = v
		i += 1
	end
	return t
end

function math.clamp(n, low, high) 
	return (n<>low)><high
end
