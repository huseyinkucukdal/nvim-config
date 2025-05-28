vim.cmd("filetype plugin indent on")

-- Temel Ayarlar
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.mouse = "a"
vim.cmd("syntax on")
vim.cmd("filetype plugin indent on")

-- Packer Kurulum
local ensure_packer = function()
  local fn = vim.fn
  local install_path = fn.stdpath("data").."/site/pack/packer/start/packer.nvim"
  if fn.empty(fn.glob(install_path)) > 0 then
    fn.system({"git", "clone", "--depth", "1", "https://github.com/wbthomason/packer.nvim", install_path})
    vim.cmd("packadd packer.nvim")
    return true
  end
  return false
end
local packer_bootstrap = ensure_packer()

-- Pluginler
require("packer").startup(function(use)
    use "wbthomason/packer.nvim"
    use "nvim-treesitter/nvim-treesitter"
    use "neovim/nvim-lspconfig"
    use "hrsh7th/nvim-cmp"
    use "hrsh7th/cmp-nvim-lsp"
    use "nvim-lua/plenary.nvim"
    use "nvim-telescope/telescope.nvim"
    use "nvim-tree/nvim-tree.lua"
    use "nvim-tree/nvim-web-devicons"
    use "tpope/vim-fugitive"
    use "morhetz/gruvbox"
    use "mfussenegger/nvim-dap"
    use "rcarriga/nvim-dap-ui"
    use "nvim-neotest/nvim-nio"
    use "sbdchd/neoformat"
    use "nvim-lualine/lualine.nvim"
    use "akinsho/toggleterm.nvim"
    use "L3MON4D3/LuaSnip"
    use "windwp/nvim-autopairs"
    use "kylechui/nvim-surround"
    use "numToStr/Comment.nvim"
    use "hrsh7th/cmp-buffer"
    use "hrsh7th/cmp-path"
    use "saadparwaiz1/cmp_luasnip"

    use({
      "nvimtools/none-ls.nvim",
      requires = { "nvim-lua/plenary.nvim" },
    })
    
    require("null-ls").setup({
      sources = {
        require("null-ls").builtins.formatting.prettier,
        require("null-ls").builtins.formatting.csharpier,
      },
      on_attach = on_attach,
    })
    
    use {
      "williamboman/mason.nvim",
      config = function() require("mason").setup() end
    }
    use {
      "williamboman/mason-lspconfig.nvim",
      config = function()
        require("mason-lspconfig").setup({
          ensure_installed = { "tsserver", "omnisharp", "sqls" }
        })
      end
    }

  if packer_bootstrap then
    require("packer").sync()
  end
end)

require("nvim-treesitter.configs").setup({
  ensure_installed = { "typescript", "tsx", "javascript", "c_sharp", "sql", "lua", "json" },
  highlight = { enable = true }
})

-- Tema
vim.cmd("colorscheme gruvbox")

-- Statusline
require("lualine").setup {
  options = { theme = "gruvbox" }
}

-- Terminal
require("toggleterm").setup()
vim.api.nvim_set_keymap("n", "<leader>t", ":ToggleTerm<CR>", { noremap = true, silent = true })

-- Snippet
require("luasnip.loaders.from_vscode").lazy_load()

-- Autopairs
require("nvim-autopairs").setup {}

-- Surround
require("nvim-surround").setup {}

-- Comment
require("Comment").setup {}

-- LSP Ayarlari
local lspconfig = require("lspconfig")

local on_attach = function(_, bufnr)
  local opts = { noremap=true, silent=true, buffer=bufnr }
  local map = vim.keymap.set
  map('n', 'gd', vim.lsp.buf.definition, opts)
  map('n', 'gr', vim.lsp.buf.references,  opts)
  map('n', 'K',  vim.lsp.buf.hover,       opts)
  map('n', '<leader>rn', vim.lsp.buf.rename, opts)
end


lspconfig.omnisharp.setup({
  cmd = { "omnisharp", "--languageserver" , "--hostPID", tostring(vim.fn.getpid()) },
  filetypes = { "cs", "vb" },
  root_dir = lspconfig.util.root_pattern(".sln", ".csproj"),
  on_attach = on_attach
})

lspconfig.tsserver.setup({
  filetypes = { "typescript", "typescriptreact", "javascript", "javascriptreact" },
  root_dir  = lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git"),
  on_attach = on_attach
})

-- Otomatik Tamamlama
local cmp = require("cmp")
cmp.setup({  snippet = {
    expand = function(args) require("luasnip").lsp_expand(args.body) end,
  },
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    { name = "nvim_lsp" },
    { name = "luasnip"  },
    { name = "buffer"   },
    { name = "path"     }
  }
})

-- Format Kısayolları
vim.api.nvim_set_keymap("n", "<leader>f", ":Neoformat<CR>", { noremap = true, silent = true })

-- Debug Ayarları
local dap = require("dap")
local dapui = require("dapui")
dapui.setup()

vim.fn.sign_define("DapBreakpoint", {text="●", texthl="Error", linehl="", numhl=""})

dap.adapters.coreclr = {
  type = 'executable',
  command = '/usr/local/bin/netcoredbg',
  args = {'--interpreter=vscode'}
}
dap.configurations.cs = {
  {
    type = "coreclr",
    name = "Launch - netcoredbg",
    request = "launch",
    program = function()
      return vim.fn.input('Path to dll: ', vim.fn.getcwd() .. '/bin/Debug/net6.0/', 'file')
    end,
  },
}

vim.api.nvim_set_keymap("n", "<F5>", ":lua require'dap'.continue()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F10>", ":lua require'dap'.step_over()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F11>", ":lua require'dap'.step_into()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<F12>", ":lua require'dap'.step_out()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>db", ":lua require'dap'.toggle_breakpoint()<CR>", { noremap = true, silent = true })
vim.api.nvim_set_keymap("n", "<leader>du", ":lua require'dapui'.toggle()<CR>", { noremap = true, silent = true })
