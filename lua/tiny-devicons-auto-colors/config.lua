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
}

function M.setup(opts)
	default_config = vim.tbl_deep_extend("force", default_config, opts)

	M.apply(default_config.colors)
end

function M.apply(colors)
	local devicons = require("nvim-web-devicons").get_icons()
	local colorspace = require("tiny-devicons-auto-colors.lab_utils")

	local cache = {}
	local icons = {}

	for key_icon, icon_object in pairs(devicons) do
		local nearest_color = nil
		local default_icon_color = icon_object.color

		if default_config ~= nil then
			if cache[default_icon_color] then
				nearest_color = cache[default_icon_color]
			else
				nearest_color = colorspace.get_nearest_color(default_icon_color, colors)
				cache[default_icon_color] = nearest_color
			end

			icons[key_icon] = {
				icon = icon_object.icon,
				color = nearest_color,
				cterm_color = icon_object.cterm_color,
				name = icon_object.name,
			}
		end
	end

	require("nvim-web-devicons").set_icon(icons)
end

return M
