local M = {}

--- Read cache from file
--- @param path string: Path to cache file
--- @return table: Cache table
function M.read_cache(path)
	local cache = nil

	if vim.fn.filereadable(path) == 1 then
		local f = io.open(path, "r")
		local json = vim.json.decode(f:read("*all"))
		cache = json
		f:close()
	end

	return cache
end

--- Write cache to file
--- @param path string: Path to cache file
--- @param cache table: Cache table
function M.write_cache(path, cache)
	local f = io.open(path, "w")
	local encoded_json = vim.json.encode(cache)
	f:write(encoded_json)
	f:close()
end

return M
