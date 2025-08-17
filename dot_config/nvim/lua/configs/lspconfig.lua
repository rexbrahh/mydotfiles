-- load defaults i.e lua_lsp
local lspconfig = require("lspconfig")
require('mason').setup()

require('mason-lspconfig').setup({
  ensure_installed = { "lua_ls", "pyright", "tsserver" },  -- List your desired LSP servers here
  automatic_installation = true,
})

require('mason-lspconfig').setup_handlers({
  function(server_name) -- default handler
    lspconfig[server_name].setup({})
  end,
})
require('lspconfig').lua_ls.setup {
  settings = {
    Lua = {
      diagnostics = {
        globals = { 'vim' }
      }
    }
  }
}
require("nvchad.configs.lspconfig").defaults()
local lspconfig = require "lspconfig"

-- EXAMPLE
local servers = { "html", "cssls" }
local nvlsp = require "nvchad.configs.lspconfig"

-- lsps with default config
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = nvlsp.on_attach,
    on_init = nvlsp.on_init,
    capabilities = nvlsp.capabilities,
  }
end

-- configuring single server, example: typescript
-- lspconfig.ts_ls.setup {
--   on_attach = nvlsp.on_attach,
--   on_init = nvlsp.on_init,
--   capabilities = nvlsp.capabilities,
-- }
