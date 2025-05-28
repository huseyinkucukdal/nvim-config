# nvim-config

## Setup

1. Clone this repo into your Neovim config folder
   ```bash
   git clone https://github.com/huseyinkucukdal/nvim-config ~/.config/nvim
   ```
   Open Neovim and run one command:

```
:PackerSync
```

:PackerSync will

- remove plugins that are no longer listed (clean),

- install or update missing/out-of-date plugins, and

- generate the packer_compiled.lua cache for faster startup.

When the process finishes, restart Neovim.
All LSP, Telescope, Treesitter, and other plugins should now be fully
functional.
