# Signals Module Documentation

## Overview
The `Signals` module provides a simple way to manage and track Roblox events (`RBXScriptSignal`s) with unique identifiers. This allows developers to easily add, reference, and destroy connections without manually handling each `:Connect` object.

---

## Usage
You can also say /signals to pull up a Signals GUI to easily check every existing signal and easily destroy/kill them there and see how many your script uses and easily debug if you experience issues with your signals.
```lua
local SignalManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/IdkRandomUsernameok/PublicModules/refs/heads/main/Modules/Signals.lua"))()
local connection;

connection = workspace.ChildAdded:Connect(function()
    warn("hi")
end)

local uid = SignalManager.AddSignal(connection, "ChildAdded") -- define the said signal and what it is
SignalManager.DestroySignal(uid) -- destroy/stop it whenever you want in the future of the script

