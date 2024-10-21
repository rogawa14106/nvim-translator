# Requirements
* dependencies  
curl or wget -- Required to hit the translate API  

* Supported versions  
Neovim only.  
Neovim version >= 0.9.0  

# Feature
nvim-translator is a language translation tool with asynchronous implementation.  
and pritty load spinner.  


https://github.com/user-attachments/assets/57feaed5-6830-457e-bb58-9c9504dc39ea


# Installation
* vim-plug  

``` vim
Plug 'rogawa14106/nvim-translator'
lua << EOF
    require('nvim-translator').setup()
EOF
```

* Lazy  

``` lua
return {
    'rogawa14106/nvim-translator',
    config = function()
        require('nvim-translator').setup()
    end,
}
```

* Packer  

``` lua
use {
    'rogawa14106/nvim-translator',
    config = function()
        require('nvim-translator').setup()
    end,
}
```

# Usage
1. select text on visual mode  
2. Press configured keymap

# keymap
## default
* Press \<Leader\>? on visual mode  
Selected English texts translate to Japanese.  

* Press \<Leader\>g? on visual mode  
Selected Japanese texts translate to English.  

## user setting

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

# TODO
## Features planned to be implemented in the future)
* Ability to display the untranslated text side by side.  
* Timeout when translation fails.  
* Avoid relying on curl/wget.  
* Ability to view translation history.  

