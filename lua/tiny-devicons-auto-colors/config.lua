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

	local devicons = require("nvim-web-devicons").get_icons()
	local lab_utils = require("tiny-devicons-auto-colors.lab_utils")

	for key_icon, icon_object in pairs(devicons) do
		local nearest_color = lab_utils.get_nearest_color(icon_object.color, default_config.colors, default_config.bias)

		require("nvim-web-devicons").set_icon({
			[key_icon] = {
				icon = icon_object.icon,
				color = nearest_color,
				cterm_color = icon_object.cterm_color,
				name = icon_object.name,
			},
		})
	end
end

return M
