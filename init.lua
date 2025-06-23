-- Basic settings
vim.o.shell = 'fish'
vim.o.hidden = true
vim.o.wrap = false
vim.cmd('filetype plugin indent on')
vim.cmd('syntax on')
vim.cmd('runtime macros/matchit.vim')
vim.o.laststatus = 2
vim.o.history = 200
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.infercase = true

vim.o.number = true
vim.opt.clipboard:append('unnamedplus')
vim.o.fileformat = 'unix'
vim.o.encoding = 'utf-8'
vim.o.fileencoding = 'utf-8'
vim.o.colorcolumn = '80'
vim.o.termguicolors = true

-- Remember cursor positions
vim.o.viminfo = "'25,\"50,n~/.viminfo"

-- Colorscheme
vim.cmd('colorscheme nord')

-- Lightline configuration
vim.g.lightline = { colorscheme = 'nord' }

-- Search settings
vim.o.incsearch = true
vim.o.hlsearch = true

-- Don't show vim mode in writing
vim.o.showmode = false

-- Key mappings
vim.g.mapleader = ' '  -- Set leader key to space

-- Clear search highlighting
vim.keymap.set('n', '<leader>/', ':noh<CR>', { silent = true })

-- Window navigation
vim.keymap.set('n', '<leader>k', ':wincmd k<CR>', { silent = true })
vim.keymap.set('n', '<leader>j', ':wincmd j<CR>', { silent = true })
vim.keymap.set('n', '<leader>h', ':wincmd h<CR>', { silent = true })
vim.keymap.set('n', '<leader>l', ':wincmd l<CR>', { silent = true })

-- Window management
vim.keymap.set('n', '<leader>x', ':close<CR>', { silent = true })
vim.keymap.set('n', '<leader>d', ':bp\\|bd #<CR>', { silent = true })

-- File navigation and completion
vim.opt.path:append('**')
vim.o.wildmenu = true

-- File operations
vim.keymap.set('n', '<leader>f', ':Files<CR>', { silent = true })
vim.keymap.set('n', '<leader>b', ':Buffers<CR>', { silent = true })
vim.keymap.set('n', '<leader><S-f>', ':edit.<CR>', { silent = true })

-- Location list navigation
vim.keymap.set('n', '<leader>n', ':lnext<CR>', { silent = true })
vim.keymap.set('n', '<leader>p', ':lprev<CR>', { silent = true })

-- Copy/paste mappings
vim.keymap.set('v', '<C-c>', '"+y')
vim.keymap.set('v', '<C-x>', '"+c')
vim.keymap.set('v', '<C-v>', 'c<ESC>"+p')
vim.keymap.set('i', '<C-v>', '<ESC>"+pa')

-- Terminal
vim.keymap.set('n', '<leader>t', ':stop<CR>', { silent = true })

-- File path expansion
vim.keymap.set('c', '%%', function()
  if vim.fn.getcmdtype() == ':' then
    return vim.fn.expand('%:h') .. '/'
  else
    return '%%'
  end
end, { expr = true })

-- Mouse support
vim.o.mouse = 'a'
vim.g.is_mouse_enabled = 1

-- Netrw settings
vim.g.netrw_altv = 1
vim.g.netrw_dirhistmax = 0

-- Repeat last substitute
vim.keymap.set('n', '&', ':&&<CR>')
vim.keymap.set('x', '&', ':&&<CR>')

-- File operations
vim.keymap.set('n', '<leader>s', ':update<CR>', { silent = true })
vim.keymap.set('n', '<leader>e', ':edit!<CR>', { silent = true })
vim.keymap.set('n', '<leader>w', ':w !sudo tee % > /dev/null<CR>', { silent = true })
vim.keymap.set('n', '<leader>p', ':!pandoc -i % --toc -o %<.pdf --pdf-engine=xelatex<CR>', { silent = true })

-- Command abbreviations
vim.cmd('cnoreabbrev H vert h')

-- Center search results
vim.keymap.set('n', 'n', 'nzzzv')
vim.keymap.set('n', 'N', 'Nzzzv')

-- Plugin settings
vim.g.vim_markdown_folding_disabled = 1
vim.g.ranger_map_keys = 0
vim.g.suda_smart_edit = 1

-- Compatibility
vim.o.compatible = false

-- Ranger mapping
vim.keymap.set('n', '<leader>r', ':Ranger<CR>', { silent = true })

-- COC tab completion
vim.keymap.set('i', '<TAB>', function()
  if vim.fn['coc#pum#visible']() == 1 then
    return vim.fn['coc#pum#confirm']()
  else
    return vim.api.nvim_replace_termcodes('<C-g>u<TAB>', true, true, true)
  end
end, { silent = true, expr = true })

-- User commands
vim.api.nvim_create_user_command('MakeTags', '!ctags -R .', {})

-- Autocommands
-- Restore cursor position
vim.api.nvim_create_autocmd('BufReadPost', {
  pattern = '*',
  callback = function()
    local line = vim.fn.line("'\"")
    if line > 1 and line <= vim.fn.line("$") then
      vim.cmd("normal! g'\"")
    end
  end,
})

-- Lexical group
local lexical_group = vim.api.nvim_create_augroup('lexical', { clear = true })
vim.api.nvim_create_autocmd('FileType', {
  pattern = { 'markdown', 'mkd' },
  callback = function()
    vim.fn['lexical#init']()
  end,
  group = lexical_group,
})

-- Metals configuration (nvim-metals setup)
local metals_config = require("metals").bare_config()

-- Basic on_attach function
metals_config.on_attach = function(client, bufnr)
  -- Add basic keymaps (customize as needed)
  vim.keymap.set("n", "gd", vim.lsp.buf.definition, { buffer = bufnr })
  vim.keymap.set("n", "K", vim.lsp.buf.hover, { buffer = bufnr })
  vim.keymap.set("n", "gr", vim.lsp.buf.references, { buffer = bufnr })
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

-- Import config
require('metals-config')
