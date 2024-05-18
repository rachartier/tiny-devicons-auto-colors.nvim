local M = {}

function M.atan2(y, x)
	local theta = math.atan(y / x)
	if x < 0 then
		theta = theta + math.pi
	end
	if theta < 0 then
		theta = theta + 2 * math.pi
	end
	return theta
end

--- Converts a hexadecimal color value to RGB.
--- The hexadecimal value should start with a '#' and be followed by 6 hexadecimal digits.
--- The returned RGB values are in the range [0, 255].
--- @param hex string: Hexadecimal value of the color.
--- @return table: RGB values of the color.
function M.hex_to_rgb(hex)
	hex = hex:gsub("#", "")
	return {
		tonumber(hex:sub(1, 2), 16),
		tonumber(hex:sub(3, 4), 16),
		tonumber(hex:sub(5, 6), 16),
	}
end

--- Converts RGB color values to hexadecimal.
--- @param rgb table: RGB values of the color.
--- @return string: Hexadecimal value of the color.
function M.rgb_to_hex(rgb)
	return string.format("#%02x%02x%02x", rgb[3], rgb[2], rgb[1])
end

return M
