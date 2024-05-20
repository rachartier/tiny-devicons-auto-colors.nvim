local M = {}

local function compute_hash(s)
	local p = 31
	local m = 1e9 + 9
	local hash_value = 0
	local p_pow = 1
	for i = 1, #s do
		local c = s:sub(i, i)
		hash_value = (hash_value + (string.byte(c) - string.byte("a") + 1) * p_pow) % m
		p_pow = (p_pow * p) % m
	end
	return hash_value
end

function M.hash_table(t)
	local hash = 0
	for k, v in pairs(t) do
		hash = hash + compute_hash(tostring(k) .. tostring(v))
	end
	return tostring(hash)
end

return M
