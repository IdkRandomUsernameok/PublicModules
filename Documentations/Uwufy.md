# Uwufy Module Documentation

## Overview
Simple text conversion module that can Uwufy any text on a basic degree or on a more advanced degree with customizable options

---

## Usage
```lua
local Uwufy = loadstring(game:HttpGet("https://raw.githubusercontent.com/IdkRandomUsernameok/PublicModules/refs/heads/main/Modules/Uwufy.lua"))()
local Simple = UwUfy.Simple
local Advanced = UwUfy.Advanced

local text = "Hello, World!"

Simple.uwufy(text)
-- Possible output: H-H-Hewwo W-Wowwd uwu

local uwu = Advanced:new({
    spaces = {faces=0.1, actions=0.1, stutters=0.2}, -- pretty simple to understand .1 = 10% .2 = 20% 1 = 100%
    words = 1,
    exclamations = 1 -- not shown in this example but when the text uses like ! or ? it can change to any of these possible ones: "!?", "?!!", "?!?1", "!!11", "?!?!"
})

uwu:uwuify(text)
-- Possible output: H-H-Hewwo >w< Wowwd *blushes*
