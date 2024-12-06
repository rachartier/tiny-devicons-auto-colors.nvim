local M = {}

local color_utils = require("tiny-devicons-auto-colors.color_utils")

local function get_hl(name)
	local hl = vim.api.nvim_get_hl(0, {
		name = name,
	})

	return color_utils.number_to_hex(hl.fg), color_utils.number_to_hex(hl.bg)
end

function M.get_custom_colors()
	local colors = {
		get_hl("ConcealCurSearch"),
		get_hl("CursorlCursorCursorIM"),
		get_hl("CursorColumn"),
		get_hl("CursorLine"),
		get_hl("Directory"),
		get_hl("DiffAddDiffChange"),
		get_hl("DiffDelete"),
		get_hl("DiffText"),
		get_hl("EndOfBuffer"),
		get_hl("TermCursor"),
		get_hl("ErrorMsg"),
		get_hl("WinSeparator"),
		get_hl("FoldedFoldColumn"),
		get_hl("SignColumn"),
		get_hl("IncSearch"),
		get_hl("Substitute"),
		get_hl("LineNrLineNrAbove"),
		get_hl("LineNrBelow"),
		get_hl("CursorLineNr"),
		get_hl("CursorLineFold"),
		get_hl("CursorLineSign"),
		get_hl("MatchParen"),
		get_hl("ModeMsgMsgAreaMsgSeparator"),
		get_hl("MoreMsgNonTextNormalNormalFloat"),
		get_hl("FloatBorder"),
		get_hl("FloatTitle"),
		get_hl("FloatFooter"),
		get_hl("PmenuPmenuSel"),
		get_hl("PmenuThumb"),
		get_hl("Question"),
		get_hl("QuickFixLine"),
		get_hl("SearchSnippetTabstop"),
		get_hl("SpecialKey"),
		get_hl("SpellBad"),
		get_hl("SpellCap"),
		get_hl("SpellLocal"),
		get_hl("SpellRare"),
		get_hl("StatusLine"),
		get_hl("TabLineTabLineFill"),
		get_hl("TabLineSel"),
		get_hl("TitleVisualVisualNOS"),
		get_hl("WarningMsg"),
		get_hl("Whitespace"),
		get_hl("WildMenu"),
	}

	local seen = {}
	local indexes = {}

	for i, v in ipairs(colors) do
		if seen[v] then
			table.insert(indexes, i)
		end
		seen[v] = true
	end

	for i = #indexes, 1, -1 do
		table.remove(colors, indexes[i])
	end

	return colors
end

return M
