local M = {}

local cache_utils = require("tiny-devicons-auto-colors.cache")
local lab_utils = require("tiny-devicons-auto-colors.lab_utils")
local utils = require("tiny-devicons-auto-colors.color_utils")

local default_config = {
	colors = {},
	factors = {
		lightness = 1.75,
		chroma = 1,
		hue = 1.25,
	},
	cache = {
		enabled = true,
		path = vim.fn.stdpath("cache") .. "/tiny-devicons-auto-colors.cache",
	},
	precise_search = {
		enabled = true,
		iteration = 10,
		precision = 20,
		threshold = 23,
	},
	ignore = {},
	autoreload = false,
}

function M.setup(opts)
	local custom_hl = require("tiny-devicons-auto-colors.custom_hl")

	if opts == nil then
		opts = {}
	end

	if opts.colors == nil then
		default_config.colors = custom_hl.get_custom_colors()
	end

	default_config = vim.tbl_deep_extend("force", default_config, opts)

	if default_config.autoreload then
		vim.api.nvim_create_autocmd("Colorscheme", {
			group = vim.api.nvim_create_augroup("custom_devicons_on_colorscheme", { clear = true }),
			callback = function()
				local colors = {}

				colors = custom_hl.get_custom_colors()

				M.apply(colors)
			end,
		})
	end

	M.apply(default_config.colors)
end

local function prepare_cache(hash_colors, bypass_cache)
	local cache = nil
	local use_cache = false

	if bypass_cache then
		return {
			hash_colors = hash_colors,
			colors = {},
		}, false
	end

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

	return cache, use_cache
end

local function filter_devicons(devicons)
	if #default_config.ignore > 0 then
		local filtered_devicons = {}

		for ignore_key, ignore_value in pairs(default_config.ignore) do
			default_config.ignore[ignore_key] = ignore_value:lower()
		end

		filtered_devicons = vim.tbl_filter(function(icon)
			return not vim.tbl_contains(default_config.ignore, icon.name:lower())
		end, devicons)

		return filtered_devicons
	end

	return devicons
end

local function convert_colors_table_to_lab(colors_table)
	local new_colors_table = {}

	for _, value in pairs(colors_table) do
		if type(value) == "string" then
			value = value:lower()
			if value ~= "none" and value ~= "null" then
				local rgb = utils.hex_to_rgb(value)
				local lab = lab_utils.rgb_to_lab(rgb[1], rgb[2], rgb[3])

				new_colors_table[value] = lab
			end
		end
	end

	return new_colors_table
end

function M.apply(colors, bypass_cache)
	if bypass_cache == nil then
		bypass_cache = false
	end

	local ok, devicons = pcall(require("nvim-web-devicons").get_icons)

	if not ok then
		vim.api.nvim_err_writeln("Error getting icons. Cannot find nvim-web-devicons.")
		return
	end

	local colorspace = require("tiny-devicons-auto-colors.lab_utils")
	local hash = require("tiny-devicons-auto-colors.hash")
	local hash_colors = hash.hash_table(colors)

	local icons = {}
	local cache = nil
	local use_cache = false

	cache, use_cache = prepare_cache(hash_colors, bypass_cache)
	devicons = filter_devicons(devicons)

	if not use_cache then
		colors = convert_colors_table_to_lab(colors)
	end

	for key_icon, icon_object in pairs(devicons) do
		local nearest_color = nil
		local default_icon_color = icon_object.color
		local cached_icon = cache.colors[default_icon_color]

		if use_cache or cached_icon then
			nearest_color = cached_icon
		else
			nearest_color = colorspace.match_color(
				default_icon_color,
				colors,
				default_config.factors,
				default_config.precise_search
			)
			cache.colors[default_icon_color] = nearest_color
		end

		icons[key_icon] = {
			icon = icon_object.icon,
			name = icon_object.name,
			color = nearest_color,
			cterm_color = icon_object.cterm_color,
		}
	end

	if bypass_cache == false and default_config.cache.enabled and not use_cache then
		cache.hash_colors = hash_colors
		cache_utils.write_cache(default_config.cache.path, cache)
	end

	ok, _ = pcall(require("nvim-web-devicons").set_icon, icons)
	if not ok then
		vim.api.nvim_err_writeln("Error setting icons.")
	end
end

function M.apply_no_cache(colors)
	M.apply(colors, true)
end

return M
