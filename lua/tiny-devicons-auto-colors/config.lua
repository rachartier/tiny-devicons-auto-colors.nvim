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
	},
	bias = {
		1,
		1,
		1,
	},
}

function M.setup(opts)
	if opts == nil then
		return
	end

	if opts.colors ~= nil then
		default_config.colors = opts.colors
	end

	if opts.bias ~= nil then
		default_config.bias = opts.bias
	end

	if opts.use_cache ~= nil then
		default_config.use_cache = opts.use_cache
	end

	local devicons = require("nvim-web-devicons").get_icons()
	local lab_utils = require("tiny-devicons-auto-colors.lab_utils")

	local cache = {}
	local icons = {}

	for key_icon, icon_object in pairs(devicons) do
		local nearest_color = nil

		if icon_object.color ~= nil then
			nearest_color = icon_object.color
		else
			if cache[icon_object.color] then
				nearest_color = cache[icon_object.color]
			else
				nearest_color =
					lab_utils.get_nearest_color(icon_object.color, default_config.colors, default_config.bias)
				cache[icon_object.color] = nearest_color
			end
		end

		icons[key_icon] = {
			icon = icon_object.icon,
			color = nearest_color,
			cterm_color = icon_object.cterm_color,
			name = icon_object.name,
		}
	end

	require("nvim-web-devicons").set_icon(icons)
end

M.setup(default_config)

return M
