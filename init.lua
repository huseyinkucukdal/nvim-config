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

  if packer_bootstrap then
    require("packer").sync()
  end
end)

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

lspconfig.omnisharp.setup({
  cmd = { "omnisharp", "--languageserver" , "--hostPID", tostring(vim.fn.getpid()) },
  filetypes = { "cs", "vb" },
  root_dir = lspconfig.util.root_pattern(".sln", ".csproj")
})

-- lspconfig.tsserver.setup({})
lspconfig.tsserver = nil
lspconfig.ts_ls.setup({})

-- Otomatik Tamamlama
local cmp = require("cmp")
cmp.setup({
  mapping = cmp.mapping.preset.insert({
    ["<Tab>"] = cmp.mapping.select_next_item(),
    ["<S-Tab>"] = cmp.mapping.select_prev_item(),
    ["<CR>"] = cmp.mapping.confirm({ select = true }),
  }),
  sources = {
    { name = "nvim_lsp" }
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
