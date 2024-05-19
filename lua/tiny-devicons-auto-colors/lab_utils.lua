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

	local kL, kC, kH = 1, 1, 1

	local deltaL = l2 - l1

	local c1 = math.sqrt(a1 * a1 + b1 * b1)
	local c2 = math.sqrt(a2 * a2 + b2 * b2)
	local cBar = (c1 + c2) / 2

	local aPrime1 = a1 + (a1 / 2) * (1 - math.sqrt((cBar ^ 7) / (cBar ^ 7 + 25 ^ 7)))
	local aPrime2 = a2 + (a2 / 2) * (1 - math.sqrt((cBar ^ 7) / (cBar ^ 7 + 25 ^ 7)))

	local cPrime1 = math.sqrt(aPrime1 * aPrime1 + b1 * b1)
	local cPrime2 = math.sqrt(aPrime2 * aPrime2 + b2 * b2)

	local hPrime1 = utils.atan2(b1, aPrime1)
	local hPrime2 = utils.atan2(b2, aPrime2)

	hPrime1 = hPrime1 < 0 and hPrime1 + 2 * math.pi or hPrime1
	hPrime2 = hPrime2 < 0 and hPrime2 + 2 * math.pi or hPrime2

	local deltaHPrime = math.abs(hPrime1 - hPrime2) <= math.pi and hPrime2 - hPrime1
		or hPrime2 <= hPrime1 and hPrime2 - hPrime1 + 2 * math.pi
		or hPrime2 - hPrime1 - 2 * math.pi

	local deltaCPrime = cPrime2 - cPrime1
	local deltaH = 2 * math.sqrt(cPrime1 * cPrime2) * math.sin(deltaHPrime / 2)

	local lPrimeBar = (l1 + l2) / 2
	local cPrimeBar = (cPrime1 + cPrime2) / 2

	local hPrimeBar = math.abs(hPrime1 - hPrime2) > math.pi and (hPrime1 + hPrime2 + 2 * math.pi) / 2
		or (hPrime1 + hPrime2) / 2

	local t = 1
		- 0.17 * math.cos(hPrimeBar - math.pi / 6)
		+ 0.24 * math.cos(2 * hPrimeBar)
		+ 0.32 * math.cos(3 * hPrimeBar + math.pi / 30)
		- 0.20 * math.cos(4 * hPrimeBar - 63 * math.pi / 180)

	local deltaTheta = 30 * math.pi / 180 * math.exp(-((hPrimeBar - 275 * math.pi / 180) / (25 * math.pi / 180)) ^ 2)
	local rC = 2 * math.sqrt((cPrimeBar ^ 7) / (cPrimeBar ^ 7 + 25 ^ 7))
	local sL = 1 + (0.015 * (lPrimeBar - 50) ^ 2) / math.sqrt(20 + (lPrimeBar - 50) ^ 2)
	local sC = 1 + 0.045 * cPrimeBar
	local sH = 1 + 0.015 * cPrimeBar * t
	local rT = -math.sin(2 * deltaTheta) * rC

	local deltaE = math.sqrt(
		(deltaL / (kL * sL)) ^ 2
			+ (deltaCPrime / (kC * sC)) ^ 2
			+ (deltaH / (kH * sH)) ^ 2
			+ rT * (deltaCPrime / (kC * sC)) * (deltaH / (kH * sH))
	)

	return deltaE
end

--- Computes the nearest color from the default colors.
--- @param color string: Hexadecimal value of the color.
--- @param colors_table table: Table of colors to compare with.
--- @param bias table: Bias for each color component. Can be nil.
--- @return string: Hexadecimal value of the nearest color.
function M.get_nearest_color(color, colors_table, bias)
	local nearest_color = "#FFFFFF"
	local nearest_distance = math.huge
	local rgb_color = utils.hex_to_rgb(color)

	if bias == nil then
		bias = { 1, 1, 1 }
	end

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
