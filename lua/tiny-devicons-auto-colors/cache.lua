local M = {}

--- Read cache from file
--- @param path string: Path to cache file
--- @return table: Cache table
function M.read_cache(path)
	if vim.fn.filereadable(path) == 1 then
		local f = io.open(path, "r")
		if f == nil then
			return {}
		end

		local json = vim.json.decode(f:read("*all"))
		f:close()

		return json
	end

	return {}
end

--- Write cache to file
--- @param path string: Path to cache file
--- @param cache table: Cache table
function M.write_cache(path, cache)
	local f = io.open(path, "w")
	local encoded_json = vim.json.encode(cache)

	if f == nil then
		return
	end

	f:write(encoded_json)
	f:close()
end

return M
