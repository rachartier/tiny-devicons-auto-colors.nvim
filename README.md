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

## Options

- `colors`: A table of color codes that the plugin will use to assign colors to devicons. The plugin will choose the nearest color in this palette for each devicon.
- `factors`: A table of factors: `lightness`, `chroma` and `hue`. You can adjust them to get better results. The default values are `1.75`, `1` and `1.25` respectively.
- `cache` greatly improve the performance of the plugin.
	- `enabled`: Enable or disable caching. Default is `true`.
    - `path`: The path where the cache will be stored. Default is `vim.fn.stdpath("cache") .. "/tiny-devicons-auto-colors-cache.json"`.

Example:

```lua
require('tiny-devicons-auto-colors').setup({
    colors = theme_colors,
    factors = {
        lightness = 1.45,
        chroma = 1,
        hue = 1.25,
    },
    cache = {
        enabled = true,
        path = vim.fn.stdpath("cache") .. "/tiny-devicons-auto-colors-cache.json",
    },
})
```

After calling `setup`, the plugin will automatically assign colors to all devicons. You do not need to do anything

## API

- `require("tiny-devicons-auto-colors").apply(colors_table)`: apply a new colorscheme on devicons. It can be useful if you want to apply the new colors when you change the colorscheme.

## Misc

You can do auto-reload on your side if you switch theme with `colorscheme` command:

```lua
{
    "rachartier/tiny-devicons-auto-colors.nvim",
    dependencies = {
        "nvim-tree/nvim-web-devicons"
    },
    event = "VeryLazy",
    config = function()
        -- you may need to redefine colors depending on your colorscheme (catppuccin, tokyonight...)
        -- require('tiny-devicons-auto-colors').setup({
        --     colors = ...
        -- }) 
        require('tiny-devicons-auto-colors').setup() 

        local function number_to_hex(number)
            number = math.max(0, math.min(16777215, number))
            local hex = string.format("%06X", number)
            return "#" .. hex
        end
        
        local function get_hl(name)
            local hl = vim.api.nvim_get_hl(0, {
                name = name,
            })
        
            return number_to_hex(hl.fg)
        end
        
        vim.api.nvim_create_autocmd("Colorscheme", {
            group = vim.api.nvim_create_augroup("custom_devicons_on_colorscheme", { clear = true }),
            callback = function()
                local colors = {
                    get_hl("WarningMsg"),
                    get_hl("ErrorMsg"),
                    get_hl("MoreMsg"),
                    get_hl("Comment"),
                    get_hl("Type"),
                    get_hl("Identifier"),
                    get_hl("Constant"),
                    -- add more...
                }
        
        
                require("tiny-devicons-auto-colors").apply(colors)
            end,
        })
    end
}
```

## FAQ

#### Why do I need to provide a color palette?

The plugin needs a color palette to assign colors to devicons. It cannot deduce colors from the colorscheme itself, as colorscheme are vastly different from one another,
and what may be a good color for one colorscheme may not be for another.

#### My devicons have strange colors...

You may need to adjust the factors (`lightness`, `chroma` and `hue`) as it can be very sensitive to the colors you provide. I've tried to find a good balance, but it may not work for all colorscheme...


## Thanks

![devicon-colorscheme.nvim](https://github.com/dgox16/devicon-colorscheme.nvim) for the idea!
