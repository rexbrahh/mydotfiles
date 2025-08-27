return {
  "echasnovski/mini.icons",
  enabled = true, -- Enable the icon pack
  opts = {},
  specs = {
    { "nvim-tree/nvim-web-devicons", enabled = true, optional = true },
  },
  init = function()
    package.preload["nvim-web-devicons"] = function()
      require("mini.icons").mock_nvim_web_devicons()
      return package.loaded["nvim-web-devicons"]
    end
  end,
  config = function()
    require("mini.icons").setup({
      file = {
        [".env"] = { glyph = "󰛸", hl = "MiniIconsBlue" },
        [".envrc"] = { glyph = "󰛸", hl = "MiniIconsBlue" },
        [".env.test"] = { glyph = "󰛸", hl = "MiniIconsBlue" },
        [".env.local"] = { glyph = "󰛸", hl = "MiniIconsBlue" },
        [".env.example"] = { glyph = "󰛸", hl = "MiniIconsBlue" },
        [".env.template"] = { glyph = "󰛸", hl = "MiniIconsBlue" },

        ["LICENSE"] = { glyph = "󰿃" },
      },
      filetype = {
        -- typescript = { glyph = "" },
        -- javascript = { glyph = "" },

        markdown = { glyph = "" },

        json = { glyph = "" },
        jsonc = { glyph = "" },

        hurl = { glyph = "", hl = "MiniIconsRed" },
        sh = { glyph = "󰐣", hl = "MiniIconsBlue" },
        zsh = { glyph = "󰐣" },
        bash = { glyph = "󰐣" },

        gomod = { glyph = "" },
        gosum = { glyph = "" },
      },
      extension = {
        conf = { glyph = "󰛸", hl = "MiniIconsBlue" },
        go = { glyph = "" },
      },
    })
  end,
}
