# tiny-devicons-auto-colors.nvim

This is a Neovim plugin that automatically assigns colors to devicons based on their nearest color in a predefined color palette. 

#### Without plugin:

![image](https://github.com/rachartier/tiny-devicons-auto-colors.nvim/assets/2057541/0130c1d8-12c7-495e-a22a-cb1d8aae7eb1)


#### With plugin (catppuccin macchiato theme):

![image](https://github.com/rachartier/tiny-devicons-auto-colors.nvim/assets/2057541/9cdaac63-14ec-4ba4-a143-242cb8d97bd2)



## Installation

With Lazy.nvim:

```lua
{
    "rachartier/tiny-devicons-auto-colors.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons"
    },
    event = "VeryLazy",
    config = function()
        require('tiny-devicons-auto-colors').setup()
    end
}
```

##  Setup

You must call `setup` to enable the plugin. Also, you should provide a color palette for the plugin to use, as the default color palette is to warn you that you need to provide one!

Here is an example with catppuccin theme:

```lua

-- You can add as many colors as you like. More colors is better to estimate the nearest color for each devicon.
local theme_colors = require("catppuccin.palettes").get_palette("macchiato")

require('tiny-devicons-auto-colors').setup({
    colors = theme_colors,
})
```

It should work with any theme that provides a color palette. If you want to use a custom color palette, you can define it yourself:

```lua
require('tiny-devicons-auto-colors').setup({
    colors = {
        "#0000ff",
        "#00ffe6",
        "#00ff00",
        "#ff00ff",
        "#ff8000",
        "#6e00ff",
        "#ff0000",
        "#ffffff",
        "#ffff00",
        "#00a1ff",
        "#00ffe6"
    },
})
```

The order of colors does not matter. You can also add as many colors as you want, as more colors results in better color matching.

### Options

- `colors`: A table of color codes that the plugin will use to assign colors to devicons. The plugin will choose the nearest color in this palette for each devicon.

- `bias`: A table of three numbers that represent the bias for the Lab color space. This affects how the "nearest color" is calculated. The default is `{1, 1, 1}`. Should be used carefully...

After calling `setup`, the plugin will automatically assign colors to all devicons. You do not need to do anything

### Thanks

![devicon-colorscheme.nvim](https://github.com/dgox16/devicon-colorscheme.nvim) for the idea!
