# Translation Module Documentation

## Overview
This module is pretty self explanatory you can easily define a language and then it'll translate it to that said language under ``Google Translate``

---

## Usage
```lua
local Translate = loadstring(game:HttpGet("https://raw.githubusercontent.com/IdkRandomUsernameok/PublicModules/refs/heads/main/Modules/TranslationModule.lua"))()

local text = Translator.translate("Hello, World!", "ja") -- first is the text and the second is the language if you wanna see all that are supported just check the source

warn(text)
