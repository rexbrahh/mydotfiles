-- This file needs to have same structure as nvconfig.lua 
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :( 
-- luacheck:globals vim
---@type ChadrcConfig
local M = {}

M.base46 = {
	theme = "onedark",

	-- hl_override = {
	-- 	Comment = { italic = true },
	-- 	["@comment"] = { italic = true },
	-- },
}

--M.ui = {
-- Add this to your init.lua or chadrc.lua
vim.opt.cursorline = false
M.ui = {
  theme = "onedark",
  hl_override = require "custom.highlights",
  transparency = true,
  telescope = { style = "borderless" }, 
  statusline = {
    theme = "minimal", -- or "default"
    separator_style = "block", -- or "round"
  },
}  
M.nvdash = {
  load_on_startup = true
}
  -- statusline = {
  -- 	theme = "default",
  -- 	hl = "StatusLine",
  -- },
  -- tabline = {
  -- 	theme = "default",
  -- 	hl = "TabLine",
  -- },
--}
--vim.api.nvim_create_autocmd("ColorScheme", {
  --pattern = "*",
  --callback = function()
    --vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
    --vim.api.nvim_set_hl(0, "NormalNC", { bg = "none" })
    --vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    --vim.api.nvim_set_hl(0, "FloatBorder", { bg = "none" })
    --vim.api.nvim_set_hl(0, "Pmenu", { bg = "none" })
    --vim.api.nvim_set_hl(0, "NvimTreeNormal", { bg = "none" })
    --vim.api.nvim_set_hl(0, "AlphaNormal", { bg = "none" })
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
 local groups = {
      "Normal", "NormalNC", "NormalFloat", "FloatBorder", "Pmenu", "PmenuSbar",
      "PmenuSel", "PmenuThumb", "StatusLine", "LineNr", "SignColumn",
      "CursorLineNr", "VertSplit", "TabLine", "TabLineFill", "TabLineSel",
      "WinSeparator", "NvimTreeNormal", "NvimTreeEndOfBuffer", "AlphaNormal",
      "TelescopeNormal", "TelescopeBorder", "TelescopePromptNormal", "TelescopePromptBorder",
      "TelescopePromptTitle", "TelescopeResultsBorder", "TelescopeResultsNormal",
      "TelescopePreviewBorder", "TelescopePreviewNormal", "TelescopePreviewTitle",
      "NeoTreeNormal", "NeoTreeNormalNC", "NeoTreeEndOfBuffer", "CmpItemMenu",
      "CursorLine", "CursorColumn", "ColorColumn",
      "Folded", "FoldColumn", "LineNrAbove", "LineNrBelow",
      "GitSignsAdd", "GitSignsChange", "GitSignsDelete",
      "DiagnosticSignError", "DiagnosticSignWarn", "DiagnosticSignInfo", "DiagnosticSignHint",
        -- Add these markdown-specific ones:
     "markdownH1", "markdownH2", "markdownH3", "markdownH4", "markdownH5", "markdownH6",
     "markdownCode", "markdownCodeBlock", "markdownCodeDelimiter",
     "markdownHeadingDelimiter", "markdownRule",
     "@markup.heading.1.markdown", "@markup.heading.2.markdown", "@markup.heading.3.markdown",
     "@markup.heading.4.markdown", "@markup.heading.5.markdown", "@markup.heading.6.markdown",
     "@markup.raw.block.markdown", "@markup.raw.markdown",
     "htmlH1", "htmlH2", "htmlH3", "htmlH4", "htmlH5", "htmlH6"
    }    
    for _, group in ipairs(groups) do
      vim.api.nvim_set_hl(0, group, { bg = "none" })
    end
  end,
})

-- Additional autocmd specifically for markdown transparency
vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
  pattern = "*.md",
  callback = function()
    -- Force remove all backgrounds for markdown files
    vim.cmd([[
      highlight markdownH1 guibg=NONE ctermbg=NONE
      highlight markdownH2 guibg=NONE ctermbg=NONE  
      highlight markdownH3 guibg=NONE ctermbg=NONE
      highlight markdownH4 guibg=NONE ctermbg=NONE
      highlight markdownH5 guibg=NONE ctermbg=NONE
      highlight markdownH6 guibg=NONE ctermbg=NONE
      highlight @markup.heading.1.markdown guibg=NONE ctermbg=NONE
      highlight @markup.heading.2.markdown guibg=NONE ctermbg=NONE
      highlight @markup.heading.3.markdown guibg=NONE ctermbg=NONE
      highlight @markup.heading.4.markdown guibg=NONE ctermbg=NONE
      highlight @markup.heading.5.markdown guibg=NONE ctermbg=NONE
      highlight @markup.heading.6.markdown guibg=NONE ctermbg=NONE
    ]])
  end,
})


return M
