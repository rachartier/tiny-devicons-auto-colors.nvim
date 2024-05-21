local M = {}
M.__depth = 0

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

--- Converts RGB color values to LAB.
--- @param r number: Red component of the color.
--- @param g number: Green component of the color.
--- @param b number: Blue component of the color.
--- @return number: L component of the color.
--- @return number: A component of the color.
--- @return number: B component of the color.
function M.rgb_to_lab(r, g, b)
	local x, y, z = M.rgb_to_xyz(r, g, b)
	return M.xyz_to_lab(x, y, z)
end

--- Computes the CIEDE2000 color difference between two colors.
--- @param lab1 table: LAB values of the first color.
--- @param lab2 table: LAB values of the second color.
--- @param factors table: Factors for LAB colorspace.
--- @return number: CIEDE2000 color difference between the two colors.
function M.ciede2000(lab1, lab2, factors)
	local l1, a1, b1 = lab1[1], lab1[2], lab1[3]
	local l2, a2, b2 = lab2[1], lab2[2], lab2[3]

	local k_l, k_c, k_h = factors.lightness, factors.chroma, factors.hue

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

--- Converts LAB color values to XYZ.
--- The LAB values should be in the range [0, 100] for L and [-128, 127] for A and B.
--- The returned XYZ values are in the range [0, 100].
--- @param l number: L component of the color.
--- @param a number: A component of the color.
--- @param b number: B component of the color.
--- @return number: X component of the color.
--- @return number: Y component of the color.
--- @return number: Z component of the color.
function M.lab_to_xyz(l, a, b)
	local y = (l + 16) / 116
	local x = a / 500 + y
	local z = y - b / 200

	local function pivot_lab(n)
		return n > 0.206893034 and n ^ 3 or (n - 16 / 116) / 7.787
	end

	x, y, z = pivot_lab(x), pivot_lab(y), pivot_lab(z)

	local refX, refY, refZ = 95.047, 100.000, 108.883
	return x * refX, y * refY, z * refZ
end

--- Converts XYZ color values to RGB.
--- The XYZ values should be in the range [0, 100] and they will be scaled down to the range [0, 1].
--- The conversion formula includes a gamma correction.
--- The returned RGB values are in the range [0, 255].
--- @param x number: X component of the color.
--- @param y number: Y component of the color.
--- @param z number: Z component of the color.
--- @return number: Red component of the color.
--- @return number: Green component of the color.
--- @return number: Blue component of the color.
function M.xyz_to_rgb(x, y, z)
	x = x / 100
	y = y / 100
	z = z / 100

	local r = x * 3.2406 + y * -1.5372 + z * -0.4986
	local g = x * -0.9689 + y * 1.8758 + z * 0.0415
	local b = x * 0.0557 + y * -0.2040 + z * 1.0570

	local function gamma_correct(n)
		return n > 0.0031308 and 1.055 * (n ^ (1 / 2.4)) - 0.055 or 12.92 * n
	end

	r, g, b = gamma_correct(r), gamma_correct(g), gamma_correct(b)

	r = math.max(0, math.min(255, r * 255))
	g = math.max(0, math.min(255, g * 255))
	b = math.max(0, math.min(255, b * 255))

	return r, g, b
end

--- Converts LAB color values to RGB.
--- @param l number: L component of the color.
--- @param a number: A component of the color.
--- @param b number: B component of the color.
--- @return number: Red component of the color.
--- @return number: Green component of the color.
--- @return number: Blue component of the color.
function M.lab_to_rgb(l, a, b)
	local x, y, z = M.lab_to_xyz(l, a, b)
	return M.xyz_to_rgb(x, y, z)
end

local function get_nearest_color(lab, colors_table, factors)
	local nearest_color = "#FFFFFF"
	local nearest_distance = math.huge

	for _, value in pairs(colors_table) do
		if type(value) == "string" then
			value = value:lower()

			if value ~= "none" and value ~= "null" then
				local rgb_value = utils.hex_to_rgb(value)
				local l2, a2, b2 = M.rgb_to_lab(rgb_value[1], rgb_value[2], rgb_value[3])

				local distance = M.ciede2000(lab, { l2, a2, b2 }, factors)

				if distance < nearest_distance then
					nearest_color = value
					nearest_distance = distance
				end
			end
		end
	end

	return nearest_color, nearest_distance
end

local function precise_search(lab, colors_table, factors, opts)
	local nearest_color = "#FFFFFF"
	local nearest_distance = math.huge
	local i = 0

	local t = 0

	while nearest_distance > opts.threshold and i < opts.iteration do
		local offset = 1 / opts.precision
		t = t + offset

		factors.lightness = factors.lightness + offset
		factors.hue = factors.hue + offset / 4

		nearest_color, nearest_distance = get_nearest_color(lab, colors_table, factors)

		i = i + 1
	end

	return nearest_color
end

--- Finds the nearest color in a table of colors to a given color.
--- @param color string: Hexadecimal value of the color.
--- @param colors_table table: Table of colors to compare with.
--- @param factors table: Factors for LAB colorspace.
--- @return string: Hexadecimal value of the nearest color.
function M.match_color(color, colors_table, factors, precise_search_opts)
	if precise_search_opts == nil then
		precise_search_opts = {}
	end

	local nearest_color = "#FFFFFF"
	local nearest_distance = math.huge
	local rgb_color = utils.hex_to_rgb(color)
	local l1, a1, b1 = M.rgb_to_lab(rgb_color[1], rgb_color[2], rgb_color[3])

	nearest_color, nearest_distance = get_nearest_color({ l1, a1, b1 }, colors_table, factors)

	local threshold = precise_search_opts.threshold
	if nearest_distance > threshold and precise_search_opts.enabled == true then
		return precise_search({ l1, a1, b1 }, colors_table, factors, precise_search_opts)
	end

	return nearest_color
end

return M
