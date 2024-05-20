local M = {}

local default_config = {
	colors = {
		"#0000ff",
		"#00ffe6",
		"#00ff00",
		"#ff00ff",
		"#ff8000",
		"#6e00ff",
		"#ff0000",
		"#ffffff",
		"#ffff00",
		"#00a1ff",
		"#00ffe6",
		"#7f7f7f",
		"#1e1e1e",
	},
	factors = {
		lightness = 1.75,
		chroma = 1,
		hue = 1.25,
	},
	cache = {
		enabled = true,
		path = vim.fn.stdpath("cache") .. "/tiny-devicons-auto-colors.cache",
	},
}

function M.setup(opts)
	if opts == nil then
		opts = {}
	end

	default_config = vim.tbl_deep_extend("force", default_config, opts)

	M.apply(default_config.colors)
end

function M.apply(colors)
	local ok, devicons = pcall(require("nvim-web-devicons").get_icons)

	if not ok then
		vim.api.nvim_err_writeln("Error getting icons. Cannot find nvim-web-devicons.")
		return
	end

	local colorspace = require("tiny-devicons-auto-colors.lab_utils")
	local hash = require("tiny-devicons-auto-colors.hash")
	local cache_utils = require("tiny-devicons-auto-colors.cache")
	local hash_colors = hash.hash_table(colors)

	local icons = {}
	local cache = nil
	local use_cache = false

	if default_config.cache.enabled then
		cache = cache_utils.read_cache(default_config.cache.path)
	end

	if cache and cache.hash_colors == hash_colors then
		use_cache = true
	else
		cache = {
			hash_colors = hash_colors,
			colors = {},
		}
	end

	for key_icon, icon_object in pairs(devicons) do
		local nearest_color = nil
		local default_icon_color = icon_object.color

		if use_cache or cache.colors[default_icon_color] then
			nearest_color = cache.colors[default_icon_color]
		else
			nearest_color = colorspace.get_nearest_color(default_icon_color, colors, default_config.factors)
			cache.colors[default_icon_color] = nearest_color
		end

		icons[key_icon] = {
			icon = icon_object.icon,
			name = icon_object.name,
			color = nearest_color,
			cterm_color = icon_object.cterm_color,
		}
	end

	if default_config.cache.enabled and not use_cache then
		cache.hash_colors = hash_colors
		cache_utils.write_cache(default_config.cache.path, cache)
	end

	local ok, _ = pcall(require("nvim-web-devicons").set_icon, icons)
	if not ok then
		vim.api.nvim_err_writeln("Error setting icons.")
	end
end

return M
