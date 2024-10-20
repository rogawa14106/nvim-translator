# Requirements
* dependencies  
curl -- Required to hit the API  

* Supported versions  
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

# TODO (Features planned to be implemented in the future)
* Avoid relying on curl  
* Ability to view translation history  
* Timeout when translation fails

