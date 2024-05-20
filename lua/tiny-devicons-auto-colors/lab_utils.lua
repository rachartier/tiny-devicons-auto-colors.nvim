local M = {}

local utils = require("tiny-devicons-auto-colors.color_utils")

--- Converts RGB color values to XYZ.
--- The RGB values should be in the range [0, 255] and they will be scaled down to the range [0, 1].
--- The conversion formula includes a gamma correction.
--- The returned XYZ values are in the range [0, 100].
--- @param r number: Red component of the color.
--- @param g number: Green component of the color.
--- @param b number: Blue component of the color.
--- @return number: X component of the color.
--- @return number: Y component of the color.
--- @return number: Z component of the color.
function M.rgb_to_xyz(r, g, b)
	local function pivot_rgb(n)
		return n > 0.04045 and ((n + 0.055) / 1.055) ^ 2.4 or n / 12.92
	end

	r, g, b = pivot_rgb(r / 255), pivot_rgb(g / 255), pivot_rgb(b / 255)

	local x = r * 0.4124564 + g * 0.3575761 + b * 0.1804375
	local y = r * 0.2126729 + g * 0.7151522 + b * 0.0721750
	local z = r * 0.0193339 + g * 0.1191920 + b * 0.9503041

	return x * 100, y * 100, z * 100
end

--- Converts XYZ color values to LAB.
--- The XYZ values should be in the range [0, 100] and they will be scaled down to the range [0, 1].
--- The returned LAB values are in the range [0, 100] for L and [-128, 127] for A and B.
--- @param x number: X component of the color.
--- @param y number: Y component of the color.
--- @param z number: Z component of the color.
--- @return number: L component of the color.
--- @return number: A component of the color.
--- @return number: B component of the color.
function M.xyz_to_lab(x, y, z)
	local function pivot_XYZ(n)
		return n > 0.008856 and n ^ (1 / 3) or (7.787 * n) + (16 / 116)
	end

	local refX, refY, refZ = 95.047, 100.000, 108.883
	x, y, z = x / refX, y / refY, z / refZ

	x, y, z = pivot_XYZ(x), pivot_XYZ(y), pivot_XYZ(z)

	local l = (116 * y) - 16
	local a = 500 * (x - y)
	local b = 200 * (y - z)

	return l, a, b
end

function M.rgb_to_lab(r, g, b)
	local x, y, z = M.rgb_to_xyz(r, g, b)
	return M.xyz_to_lab(x, y, z)
end

--- Computes the distance between two colors.
--- @param color1 table: RGB values of the first color.
--- @param color2 table: RGB values of the second color.
--- @param bias table: Bias for each color component.
--- @return number: Distance between the two colors.
function M.color_distance(color1, color2, bias)
	local l1, a1, b1 = M.rgb_to_lab(color1[1], color1[2], color1[3])
	local l2, a2, b2 = M.rgb_to_lab(color2[1], color2[2], color2[3])

	local dl = math.abs(l2 - l1) * bias[1]
	local da = math.abs(a2 - a1) * bias[2]
	local db = math.abs(b2 - b1) * bias[3]

	return math.sqrt(dl * dl + da * da + db * db)
end

--- Computes the CIEDE2000 color difference between two colors.
--- @param rgb1 table: RGB values of the first color.
--- @param rgb2 table: RGB values of the second color.
--- @return number: CIEDE2000 color difference between the two colors.
function M.ciede2000(rgb1, rgb2)
	local l1, a1, b1 = M.rgb_to_lab(rgb1[1], rgb1[2], rgb1[3])
	local l2, a2, b2 = M.rgb_to_lab(rgb2[1], rgb2[2], rgb2[3])

	local k_l, k_c, k_h = 1, 1, 1

	local delta_l = l2 - l1

	local c1 = math.sqrt(a1 * a1 + b1 * b1)
	local c2 = math.sqrt(a2 * a2 + b2 * b2)
	local c_bar = (c1 + c2) / 2

	local a_prime1 = a1 + (a1 / 2) * (1 - math.sqrt((c_bar ^ 7) / (c_bar ^ 7 + 25 ^ 7)))
	local a_prime2 = a2 + (a2 / 2) * (1 - math.sqrt((c_bar ^ 7) / (c_bar ^ 7 + 25 ^ 7)))

	local c_prime1 = math.sqrt(a_prime1 * a_prime1 + b1 * b1)
	local c_prime2 = math.sqrt(a_prime2 * a_prime2 + b2 * b2)

	local h_prime1 = utils.atan2(b1, a_prime1)
	local h_prime2 = utils.atan2(b2, a_prime2)

	h_prime1 = h_prime1 < 0 and h_prime1 + 2 * math.pi or h_prime1
	h_prime2 = h_prime2 < 0 and h_prime2 + 2 * math.pi or h_prime2

	local delta_h_prime = math.abs(h_prime1 - h_prime2) <= math.pi and h_prime2 - h_prime1
		or h_prime2 <= h_prime1 and h_prime2 - h_prime1 + 2 * math.pi
		or h_prime2 - h_prime1 - 2 * math.pi

	local delta_c_prime = c_prime2 - c_prime1
	local delta_h = 2 * math.sqrt(c_prime1 * c_prime2) * math.sin(delta_h_prime / 2)

	local l_prime_bar = (l1 + l2) / 2
	local c_prime_bar = (c_prime1 + c_prime2) / 2

	local h_prime_bar = math.abs(h_prime1 - h_prime2) > math.pi and (h_prime1 + h_prime2 + 2 * math.pi) / 2
		or (h_prime1 + h_prime2) / 2

	local t = 1
		- 0.17 * math.cos(h_prime_bar - math.pi / 6)
		+ 0.24 * math.cos(2 * h_prime_bar)
		+ 0.32 * math.cos(3 * h_prime_bar + math.pi / 30)
		- 0.20 * math.cos(4 * h_prime_bar - 63 * math.pi / 180)

	local delta_theta = 30 * math.pi / 180 * math.exp(-((h_prime_bar - 275 * math.pi / 180) / (25 * math.pi / 180)) ^ 2)
	local r_c = 2 * math.sqrt((c_prime_bar ^ 7) / (c_prime_bar ^ 7 + 25 ^ 7))
	local s_l = 1 + (0.015 * (l_prime_bar - 50) ^ 2) / math.sqrt(20 + (l_prime_bar - 50) ^ 2)
	local s_c = 1 + 0.045 * c_prime_bar
	local s_h = 1 + 0.015 * c_prime_bar * t
	local r_t = -math.sin(2 * delta_theta) * r_c

	local delta_e = math.sqrt(
		(delta_l / (k_l * s_l)) ^ 2
			+ (delta_c_prime / (k_c * s_c)) ^ 2
			+ (delta_h / (k_h * s_h)) ^ 2
			+ r_t * (delta_c_prime / (k_c * s_c)) * (delta_h / (k_h * s_h))
	)

	return delta_e
end

--- Computes the nearest color from the default colors.
--- @param color string: Hexadecimal value of the color.
--- @param colors_table table: Table of colors to compare with.
--- @return string: Hexadecimal value of the nearest color.
function M.get_nearest_color(color, colors_table)
	local nearest_color = "#FFFFFF"
	local nearest_distance = math.huge
	local rgb_color = utils.hex_to_rgb(color)

	for _, value in pairs(colors_table) do
		if type(value) == "string" then
			value = value:lower()

			if value ~= "none" and value ~= "null" then
				local rgb_value = utils.hex_to_rgb(value)

				local distance = M.ciede2000(rgb_color, rgb_value)

				if distance < nearest_distance then
					nearest_color = value
					nearest_distance = distance
				end
			end
		end
	end

	return nearest_color
end

return M
