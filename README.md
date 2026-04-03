# softwrap

Soft-wrap focused reading views for Neovim. Open the current buffer in a centered
floating window or pad the current split to a fixed text width, with wrap
settings applied automatically.

## Features
- Centered floating reading view with dimmed backdrop
- Fixed-width split reading view with padding buffer
- Automatically enables `wrap`, `linebreak`, `breakindent`, and `colorcolumn`

## Requirements
- Neovim 0.8+ (uses Lua APIs)

## Installation

Lazy.nvim:

```lua
{
  "softwrap",
  dir = "~/personal/dev/softwrap",
}
```

## Usage

```lua
local softwrap = require("softwrap")

-- Toggle floating reading view (default width 80)
softwrap.toggle_float()
softwrap.toggle_float(100)

-- Toggle split reading view (default width 80)
softwrap.toggle_split()
softwrap.toggle_split(90)
```

## Example config

Full file from `~/.config/nvim/lua/plugins/softwrap.lua`:

```lua
return {
  {
    "softwrap",
    dir = vim.fn.expand("~/personal/dev/softwrap"),
    config = function()
      vim.api.nvim_create_user_command("SoftWrap80Float", function()
        require("softwrap").toggle_float(80)
      end, {})
      vim.api.nvim_create_user_command("SoftWrap80Split", function()
        require("softwrap").toggle_split(80)
      end, {})
    end,
    keys = {
      { "<leader>zf", "<cmd>SoftWrap80Float<cr>", desc = "Soft wrap @ 80 (float)" },
      { "<leader>zs", "<cmd>SoftWrap80Split<cr>", desc = "Soft wrap @ 80 (split)" },
    },
  },
}
```

## Notes
- Press `<Esc>` to close the floating view.
- The floating dim highlight group is `SoftWrapDim`. Customize it if desired:

```lua
vim.api.nvim_set_hl(0, "SoftWrapDim", { bg = "#000000", fg = "#000000" })
```
