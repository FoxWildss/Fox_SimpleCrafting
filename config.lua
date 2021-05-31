Config = {}
Config.Locale = 'en'

Config.EnableBlip = true

Config.BlipID = 303

Config.Color = 1

Crafting = {}
Crafting.Positions = {
    [1] = {x = 605.45, y= -3095.12, z= 6.07}, -- you can configure to another location
}

Crafting.Items = {
    ["clip"] = {
        label = "Clip",
        needs = {                                           
            ["iron"] = {label = "Iron", count = 4},
            ["gold"] = {label = "Gold", count = 3},
        },
        threshold = 0, --percentage of success (higher more difficult)
    },
    ["bulletproof"] = {
        label = "Bulletproof",
        needs = {
            ["diamond"] = {label = "Diamond", count = 4},
            ["stone"] = {label = "Stone", count = 3},
        },
        threshold = 0, --percentage of success (higher more difficult)
    },
}