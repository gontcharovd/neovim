-- Save this file as: ~/.config/nvim/lua/metals-config.lua
-- Then in your init.lua, add: require('metals-config')
--
-- Dependencies needed (install as git submodules):
-- - nvim-lua/plenary.nvim       (required by nvim-metals)
-- - scalameta/nvim-metals       (Scala LSP server)
-- - hrsh7th/nvim-cmp           (modern completion engine)
-- - hrsh7th/cmp-nvim-lsp       (LSP completion source)
-- - j-hui/fidget.nvim          (LSP progress notifications)
-- - mfussenegger/nvim-dap      (debugging support)

local map = vim.keymap.set
local fn = vim.fn

----------------------------------
-- GLOBAL OPTIONS ---------------
----------------------------------
vim.opt_global.completeopt = { "menuone", "noinsert", "noselect" }

----------------------------------
-- FIDGET SETUP ------------------
----------------------------------
-- Simple fidget setup for LSP progress notifications
require("fidget").setup({})

----------------------------------
-- NVIM-CMP SETUP ----------------
----------------------------------
local cmp = require("cmp")
cmp.setup({
  sources = {
    { name = "nvim_lsp" },
  },
  mapping = cmp.mapping.preset.insert({
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
  })
})

----------------------------------
-- NVIM-DAP SETUP ----------------
----------------------------------
-- Debug settings if you're using nvim-dap
local dap = require("dap")

dap.configurations.scala = {
  {
    type = "scala",
    request = "launch",
    name = "RunOrTest",
    metals = {
      runType = "runOrTestFile",
      --args = { "firstArg", "secondArg", "thirdArg" }, -- here just as an example
    },
  },
  {
    type = "scala",
    request = "launch",
    name = "Test Target",
    metals = {
      runType = "testTarget",
    },
  },
}

----------------------------------
-- NVIM-METALS SETUP -------------
----------------------------------
local metals_config = require("metals").bare_config()

-- Example of settings
metals_config.settings = {
  showImplicitArguments = true,
  excludedPackages = { "akka.actor.typed.javadsl", "com.github.swagger.akka.javadsl" },
}

-- *READ THIS*
-- I *highly* recommend setting statusBarProvider to either "off" or "on"
--
-- "off" will enable LSP progress notifications by Metals and you'll need
-- to ensure you have a plugin like fidget.nvim installed to handle them.
--
-- "on" will enable the custom Metals status extension and you *have* to have
-- a have settings to capture this in your statusline or else you'll not see
-- any messages from metals. There is more info in the help docs about this
metals_config.init_options.statusBarProvider = "off"

-- Example if you are using cmp how to make sure the correct capabilities for snippets are set
metals_config.capabilities = require("cmp_nvim_lsp").default_capabilities()

metals_config.on_attach = function(client, bufnr)
  require("metals").setup_dap()

  -- LSP mappings
  map("n", "gD", vim.lsp.buf.definition)
  map("n", "K", vim.lsp.buf.hover)
  map("n", "gi", vim.lsp.buf.implementation)
  map("n", "gr", vim.lsp.buf.references)
  map("n", "gds", vim.lsp.buf.document_symbol)
  map("n", "gws", vim.lsp.buf.workspace_symbol)
  map("n", "<leader>cl", vim.lsp.codelens.run)
  map("n", "<leader>sh", vim.lsp.buf.signature_help)
  map("n", "<leader>rn", vim.lsp.buf.rename)
  map("n", "<leader>f", vim.lsp.buf.format)
  map("n", "<leader>ca", vim.lsp.buf.code_action)

  map("n", "<leader>ws", function()
    require("metals").hover_worksheet()
  end)

  -- all workspace diagnostics
  map("n", "<leader>aa", vim.diagnostic.setqflist)

  -- all workspace errors
  map("n", "<leader>ae", function()
    vim.diagnostic.setqflist({ severity = "E" })
  end)

  -- all workspace warnings
  map("n", "<leader>aw", function()
    vim.diagnostic.setqflist({ severity = "W" })
  end)

  -- buffer diagnostics only
  map("n", "<leader>d", vim.diagnostic.setloclist)

  map("n", "[c", function()
    vim.diagnostic.goto_prev({ wrap = false })
  end)

  map("n", "]c", function()
    vim.diagnostic.goto_next({ wrap = false })
  end)

  -- Example mappings for usage with nvim-dap. If you don't use that, you can
  -- skip these
  map("n", "<leader>dc", function()
    require("dap").continue()
  end)

  map("n", "<leader>dr", function()
    require("dap").repl.toggle()
  end)

  map("n", "<leader>dK", function()
    require("dap.ui.widgets").hover()
  end)

  map("n", "<leader>dt", function()
    require("dap").toggle_breakpoint()
  end)

  map("n", "<leader>dso", function()
    require("dap").step_over()
  end)

  map("n", "<leader>dsi", function()
    require("dap").step_into()
  end)

  map("n", "<leader>dl", function()
    require("dap").run_last()
  end)
end

-- Auto-start metals for Scala files
local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "scala", "sbt", "java" },
  callback = function()
    require("metals").initialize_or_attach(metals_config)
  end,
  group = nvim_metals_group,
})

-- Set faster update time (default is 4000ms)
vim.opt.updatetime = 1000

-- Configure how diagnostics appear
vim.diagnostic.config({
  virtual_text = true,        -- Show error text inline
  signs = true,               -- Show error signs in gutter
  underline = true,           -- Underline errors
  update_in_insert = false,   -- Don't show while typing
  float = {
    border = 'rounded',
    source = 'always',
  },
})
