# smartjump.nvim

Advanced `gf` command for neovim.

`smartjump.nvim` will lookup the filename under the cursor in `vim.o.path`.

## Screenshot

There are several `main.go` file in the project, smartjump will find it in all folders defined by `path` variable, and show them with line number awareness.

![smartjump](https://user-images.githubusercontent.com/3747445/173917178-22eabbd8-4f07-4e76-98c9-ba4528c0e243.gif)

## Installation and Setup

Using packer:

```lua
use {"moevis/smartjump.nvim", requires = "nvim-telescope/telescope.nvim"}
```

Default setup (optional):

```lua
require("smartjump").setup({
  -- telescope config
  telescope = {
    prompt_title = "Go To File",
  },
  -- or require("telescope.themes").get_dropdown()/.get_ivy()/.get_cursor()
  theme = nil,
})
```

Set keymap (by lua):

```lua
-- maping to 'gl'
vim.keymap.set("n", "gl", ":GoToFile<cr>", nil)

-- or you can replace default 'gf' command
vim.keymap.set("n", "gf", ":GoToFile<cr>", nil)
```

## Command and Setup

Key mapping (Telescope default behaviors):
  - `<Enter>`: open the file in current buffer.
  - `<C-t>`: open the file in new tab.
  - `<C-x>`: open file in horizontal window.
  - `<C-v>`: open file in vertical window.

## Tips

You can define a custom `vim.o.path` for your project by adding a local `.vimrc` in your project root.

```vimscript
set path=/usr/include,/usr/local/include
```

And remember add these lines in your init.vim:

```vimscript
set exrc " equal to vim.opt.exrc = true
set secure " equal to vim.opt.secure = true
```
