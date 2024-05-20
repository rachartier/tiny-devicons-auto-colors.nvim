# tiny-devicons-auto-colors.nvim

A Neovim plugin that automatically assigns colors to devicons based on their nearest color in a predefined color palette.

## Images

Without             |  With Plugin
:-------------------------:|:-------------------------:
![image](https://github.com/rachartier/tiny-devicons-auto-colors.nvim/assets/2057541/0130c1d8-12c7-495e-a22a-cb1d8aae7eb1) |  ![image](https://github.com/rachartier/tiny-devicons-auto-colors.nvim/assets/2057541/9cdaac63-14ec-4ba4-a143-242cb8d97bd2)


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

You must call `setup` to enable the plugin. A color palette is not needed, but it can greatly improve the results.

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

## Options

```lua
-- Default configuration
require('tiny-devicons-auto-colors').setup({
    -- A table of color codes that the plugin will use to assign colors to devicons.
    -- It is preferable to use a color palette from a theme, but you can also define it yourself.
    -- If not provided, the plugin will fetch highlights from the current theme to generate a color palette.
    -- colors = theme_colors,

    -- Adjusts factors to get a better color matching.
    factors = {
        lightness = 1.75, -- Adjust the lightness factor.
        chroma = 1,       -- Adjust the chroma factor.
        hue = 1.25, 	  -- Adjust the hue factor.
    },

    -- Cache greatly improve the performance of the plugin. It saves all the matchings in a file.
    cache = {
        enabled = true,
        path = vim.fn.stdpath("cache") .. "/tiny-devicons-auto-colors-cache.json",
    },

    -- Automatically reload the colors when the colorscheme changes.
    -- Warning: when reloaded, it overrides the colors that you set in `colors`.
    -- It can produce varying results according to the colorscheme, so if you always use the same colorscheme, you can keep it disabled.
    autoreload = false,
})
```

After calling `setup`, the plugin will automatically assign colors to all devicons. You do not need to do anything

## API

- `require("tiny-devicons-auto-colors").apply(colors_table)`: apply a new colorscheme on devicons. It can be useful if you want to apply the new colors when you change the colorscheme.


## FAQ

#### My devicons have strange colors...

You may need to adjust the factors (`lightness`, `chroma` and `hue`) as it can be very sensitive to the colors you provide. I've tried to find a good balance, but it may not work for all colorscheme...


## Thanks

![devicon-colorscheme.nvim](https://github.com/dgox16/devicon-colorscheme.nvim) for the idea!
