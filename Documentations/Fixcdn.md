# FixCDN Module Documentation

## Overview
The `FixCDN` module is a module designed for the simple fix of letting developers download the desired content they want from an expired discord cdn link.

It could be useful if you're working on something and need to store a song or video and don't wanna worry about the possibility of it becoming unavailable in the future.
---

## Usage

```lua
local FixCDN = loadstring(game:HttpGet("https://raw.githubusercontent.com/IdkRandomUsernameok/PublicModules/refs/heads/main/Modules/FixCDN.lua"))()

local function EnsureAssetDownloaded(filename, originalURL) -- a simple download function
    local success, _ = pcall(readfile, filename)
    if success then return end

    local finalURL = FixCDN(originalURL)
    local assetData = game:HttpGet(finalURL)

    writefile(filename, assetData)
end

EnsureAssetDownloaded(
    "MUI.mp3", -- the files name
    "https://cdn.discordapp.com/attachments/1048878667750703108/1378992293155045506/MUI.mp3" -- the discord download link
)
