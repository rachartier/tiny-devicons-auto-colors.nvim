local M = {}

local color_utils = require("tiny-devicons-auto-colors.color_utils")

local function get_hl(name, bg)
	local hl = vim.api.nvim_get_hl(0, {
		name = name,
	})

	if hl == nil or hl.fg == nil then
		return nil
	end

	if bg and hl.bg ~= nil then
		return color_utils.number_to_hex(hl.bg)
	end

	return color_utils.number_to_hex(hl.fg)
end

local function get_hl_colors()
	return {
		get_hl("WarningMsg"),
		get_hl("DiffAdd"),
		get_hl("DiagnosticSignOk"),
		get_hl("DiagnosticSignWarn"),
		get_hl("DiagnosticSignError"),
		get_hl("DiagnosticSignHint"),
		get_hl("DiffAdd", true),
		get_hl("DiffChange", true),
		get_hl("DiffDelete", true),
		get_hl("Function"),
		get_hl("Identifier"),
		get_hl("LineNr"),
		get_hl("Include"),
		get_hl("Label"),
		get_hl("WinBar"),
		get_hl("Pmenu"),
		get_hl("ErrorMsg"),
		get_hl("MoreMsg"),
		get_hl("Comment"),
		get_hl("Type"),
		get_hl("Identifier"),
		get_hl("Constant"),
		get_hl("ModeMsg"),
		get_hl("Normal"),
		get_hl("TabLineSel"),
	}
end

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
	autoreload = false,
}

function M.setup(opts)
	if opts == nil then
		opts = {}
	end

	if opts.colors == nil then
		default_config.colors = get_hl_colors()
	end

	default_config = vim.tbl_deep_extend("force", default_config, opts)

	if default_config.autoreload then
		vim.api.nvim_create_autocmd("Colorscheme", {
			group = vim.api.nvim_create_augroup("custom_devicons_on_colorscheme", { clear = true }),
			callback = function()
				local colors = {}

				colors = get_hl_colors()

				M.apply(colors)
			end,
		})
	end

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

	ok, _ = pcall(require("nvim-web-devicons").set_icon, icons)
	if not ok then
		vim.api.nvim_err_writeln("Error setting icons.")
	end
end

return M
