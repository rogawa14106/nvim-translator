# Requirements
* dependencies  
curl -- to hit translation API
* version  
Neovim only.  
Neovim version >= 0.9.0  

# Feature
nvim-translator is a language translation tool with asynchronous implementation.  
and pritty load spinner.  

# Installation
* vim-plug

``` vim
Plug 'rogawa14106/nvim-translator'
```

* Lazy

``` lua
return {
    'rogawa14106/nvim-translator'
}
```

* Packer

``` lua
use {
    'rogawa14106/nvim-translator'
}
```

# Usage
1. select text on visual mode  
2. Press configured keymap

## default keymap
* <Leader>? visual-mode  
selected English texts translate to Japanese.  

* <Leader>g? visual-mode  
selected Japanese texts translate to English.  

## user configuration

``` lua
require('nvim-translator')setup({
    -- You can customize the keymap settings.(visual mode only)
    keymap = {
        {
            src = "ja", -- translation source
            dst = "en", -- translation destination
            key = "<Space>tj", -- key
        },
        -- add keymap settings here
        -- ...
    },
})
```

# TODO (features that implement not yet)
* Avoid relying on curl  
* history(map <Leader>H)  
* translate ja -> en (may be gas side bug)  
* timeout  

