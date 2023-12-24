
local _
local addonName, platerInternal = ...

--namespaces
platerInternal.Scripts = {}
platerInternal.Mods = {}
platerInternal.Events = {}
platerInternal.Comms = {}
platerInternal.Frames = {}
platerInternal.Data = {}
platerInternal.Date = {}
platerInternal.Logs = {}
platerInternal.Audio = {}

platerInternal.RemoveColor = "!removecolor"
platerInternal.NoColor = "no color"

platerInternal.Defaults = {
    dropdownStatusBarTexture = [[Interface\Tooltips\UI-Tooltip-Background]],
    dropdownStatusBarColor = {.1, .1, .1, .8},
}

function platerInternal.CreateDataTables(Plater)
    --addon comm
    Plater.COMM_PLATER_PREFIX = "PLT"
    Plater.COMM_SCRIPT_GROUP_EXPORTED = "GE"
    Plater.COMM_SCRIPT_MSG = "PLTM"
    Plater.COMM_NPC_NAME_EXPORTED = "NN"
    Plater.COMM_NPC_COLOR_EXPORTED = "NC"
    Plater.COMM_NPC_OR_CAST_CUSTOMIZATION = "NCC"

    --unit reaction (saved 3 global locals)
    Plater.UnitReaction = {
        UNITREACTION_HOSTILE = 3,
        UNITREACTION_NEUTRAL = 4,
        UNITREACTION_FRIENDLY = 5,
    }

    --namespaces
    Plater.Resources = {}
    Plater.Auras = {}

    --store spell cache. spell cache is loaded when adding new auras to track
    Plater.SpellHashTable = {}
    Plater.SpellIndexTable = {}
    Plater.SpellSameNameTable = {}

    --export strings identification
    Plater.Export_CastColors = "CastColor"
    Plater.Export_CastSoundAlerts = "CastSounds"
    Plater.Export_NpcColors = "NpcColor"

    --these tables store all bars created by boss mods
    Plater.BossModsTimeBarDBM = {}
    Plater.BossModsTimeBarBW = {}

    --icon texcoords
    Plater.WideIconCoords = {.1, .9, .1, .6} --used in extra icons frame, constant,  can be changed with scripts
    Plater.BorderLessIconCoords = {.1, .9, .1, .9} --used in extra icons frame,constant, can be changed with scripts
    --note: regular icons has their texcoords automatically adjusted

    --limit the cast bar text to this (this is dynamically adjusted at run time)
    Plater.MaxCastBarTextLength = nil -- global overwrite
    --auras
    Plater.MaxAurasPerRow = 10 --can change during runtime

	Plater.ForceInCombatUnits = {
		--[] = true, --
		[168326] = true, --Shattered Visage, Mueh'zala De Other Side
		[170927] = true, --Erupting Ooze, Doctor Ickus Plaguefall
		[171887] = true, --Slimy Smorgasbord, Globgrog Plaguefall
		[164362] = true, --Slimy Morsel, Globgrog Plaguefall
		[169159] = true, --Unstable Canister, Plaguefall
		[168394] = true, --Slimy Morsel, Plaguefall
		[176581] = true, --Spiked Ball, Painsmith Raznal SoD
		[176920] = true, --Domination Arrow, Sylvanas SoD
		[178008] = true, --Decrepit Orb, Sylvanas SoD
		[179963] = true, --Terror Orb, Sylvanas SoD
		[175861] = true, --Glacial Spike, Kel'Thusad SoD
		[182778] = true, --Collapsing Quasar, Rygelon SotFO
		[182823] = true, --Cosmic Core, Rygelon SotFO
		[183945] = true, --Unstable Matter, Rygelon SotFO
		[183745] = true, --Protoform Schematic, Lihuvim SotFO
		[188302] = true, --Reconfiguration Emitter, Shadowlands S4 Fated affix
		[188703] = true, --Protoform Barrier, Shadowlands S4 Fated affix
		[176026] = true, --Dancing Fools, Council of Blood CN
		[195318] = true,
		[195580] = true,
		[195820] = true,
		[196642] = true,
		[189886] = true,
		[192955] = true,
		[194806] = true,
		[196548] = true,
		[197398] = true,
		[112668] = true,
		[96608] = true,
		[102019] = true,
		[189893] = true, --187894?
		[75966] = true, --75451?
		[75899] = true,
		[76518] = true,
		[56792] = true,
		[196559] = true,
		[190187] = true,
		[195138] = true,
		[195821] = true,
		[99922] = true,
		[104822] = true,
		[120651] = true, --explosives (M+)
		[190381] = true, --Rotburst Totem
		[130896] = true, --Blackout Barrel
		[129758] = true, --Irontide Grenadier
		[196712] = true, --Nullification Device
		[195399] = true, --Curious Swoglet
		[196043] = true, --Primalist Infuser
		[97720] = true, --Blightshard Skitter
		[98081] = true, --Bellowing Idol
		[101075] = true, --Wormspeaker Devout
		[101476] = true, --Molten Charskin
		[192464] = true, --Raging Ember
		[186696] = true, --Quaking Totem
		[186107] = true, --Vault Keeper
		[413263] = true, --Skyfall Nova
		[202824] = true, --Erratic Remnant
		[203230] = true, --Dragonfire Golem
		[203812] = true, --Voice From Beyond
		[100818] = true, -- Bellowing Idol
		[92538] = true, -- Tarspitter Grub
        [136330] = true, -- Soul Thorns
        [136541] = true, -- Bile Oozeling
        [133361] = true, -- Wasting Servant
        [99664] = true, -- Restless Soul
        [101008] = true, -- Stinging Swarm
        [213219] = true, -- Bubbling Ooze
        [214117] = true, -- Stormflurry Totem
        [84400] = true, -- Flourishing Ancient
        [100991] = true, -- Strangling Roots
        [131009] = true, -- Spirit of Gold
        [127315] = true, -- Reanimation Totem
        [127315] = true, -- Reanimation Totem
        [125828] = true, -- Soulspawn
        [205212] = true, -- Infinite Keeper
        [205265] = true, -- Time-Displaced Trooper
	}

    --textures used in the cooldown animation, scripts can add more values to it, profile holds only the path to it
    Plater.CooldownEdgeTextures = {
        [[Interface\AddOns\Plater\images\cooldown_edge_1]],
        [[Interface\AddOns\Plater\images\cooldown_edge_2]],
        "Interface\\Cooldown\\edge",
        "Interface\\Cooldown\\edge-LoC",
        "Interface\\GLUES\\loadingOld",
    }

    --textures used in the castbar, scripts can add more values to it, profile holds only the path to it
    Plater.SparkTextures = {
        [[Interface\AddOns\Plater\images\spark1]],
        [[Interface\AddOns\Plater\images\spark2]],
        [[Interface\AddOns\Plater\images\spark3]],
        [[Interface\AddOns\Plater\images\spark4]],
        [[Interface\AddOns\Plater\images\spark5]],
        [[Interface\AddOns\Plater\images\spark6]],
        [[Interface\AddOns\Plater\images\spark7]],
        [[Interface\AddOns\Plater\images\spark8]],
    }

    --textures used to indicate which nameplate is the current target, scripts can add more values to it, profile holds only the path to it
    Plater.TargetHighlights = {
        [[Interface\AddOns\Plater\images\selection_indicator1]],
        [[Interface\AddOns\Plater\images\selection_indicator2]],
        [[Interface\AddOns\Plater\images\selection_indicator3]],
        [[Interface\AddOns\Plater\images\selection_indicator4]],
        [[Interface\AddOns\Plater\images\selection_indicator5]],
        [[Interface\AddOns\Plater\images\selection_indicator6]],
        [[Interface\AddOns\Plater\images\selection_indicator7]],
        [[Interface\AddOns\Plater\images\selection_indicator8]],
    }

    --icons available for any purpose
    Plater.Media = {
        Icons = {
            [[Interface\AddOns\Plater\media\arrow_apple_64]],
            [[Interface\AddOns\Plater\media\arrow_double_right_64]],
            [[Interface\AddOns\Plater\media\arrow_right_64]],
            [[Interface\AddOns\Plater\media\arrow_simple_right_64]],
            [[Interface\AddOns\Plater\media\arrow_single_right_64]],
            [[Interface\AddOns\Plater\media\arrow_thin_right_64]],
            [[Interface\AddOns\Plater\media\blocked_center_64]],
            [[Interface\AddOns\Plater\media\crown_64]],
            [[Interface\AddOns\Plater\media\drop_64]],
            [[Interface\AddOns\Plater\media\duck_64]],
            [[Interface\AddOns\Plater\media\exclamation_64]],
            [[Interface\AddOns\Plater\media\exclamation2_64]],
            [[Interface\AddOns\Plater\media\fire_64]],
            [[Interface\AddOns\Plater\media\glasses_64]],
            [[Interface\AddOns\Plater\media\glow_horizontal_256]],
            [[Interface\AddOns\Plater\media\glow_radial_128]],
            [[Interface\AddOns\Plater\media\glow_square_64]],
            [[Interface\AddOns\Plater\media\hat_64]],
            [[Interface\AddOns\Plater\media\heart_center_64]],
            [[Interface\AddOns\Plater\media\line_horizontal_256]],
            [[Interface\AddOns\Plater\media\line_vertical_256]],
            [[Interface\AddOns\Plater\media\radio_64]],
            [[Interface\AddOns\Plater\media\skullbones_64]],
            [[Interface\AddOns\Plater\media\stop_64]],
            [[Interface\AddOns\Plater\media\star_empty_64]],
            [[Interface\AddOns\Plater\media\star_full_64]],
            [[Interface\AddOns\Plater\media\x_64]],
            [[Interface\AddOns\Plater\media\checked_64]],
            [[Interface\AddOns\Plater\media\sphere_full_64]],
            [[Interface\AddOns\Plater\media\eye_64]],
            [[Interface\AddOns\Plater\media\cross_64]],
        },
    }

    --these are the images shown in the nameplate of the current target, they are placed in the left and right side of the health bar, scripts can add more options
    --if the coords has 2 tables, it uses two textures attach in the left and right sides of the health bar
    --if the coords has 4 tables, it uses 4 textures attached in top left, bottom left, top right and bottom right corners
    Plater.TargetIndicators = {
        ["NONE"] = {
            path = [[Interface\ACHIEVEMENTFRAME\UI-Achievement-WoodBorder-Corner]],
            coords = {{.9, 1, .9, 1}, {.9, 1, .9, 1}, {.9, 1, .9, 1}, {.9, 1, .9, 1}}, --texcoords, support 4 or 8 coords method
            desaturated = false,
            width = 10,
            height = 10,
            x = 1, --offset
            y = 1, --offset
        },

        ["Magneto"] = {
            path = [[Interface\Artifacts\RelicIconFrame]],
            coords = {{0, .5, 0, .5}, {0, .5, .5, 1}, {.5, 1, .5, 1}, {.5, 1, 0, .5}},
            desaturated = false,
            width = 8,
            height = 10,
            autoScale = true,
            --scale = 1,
            x = 2,
            y = 2,
        },

        ["Gray Bold"] = {
            path = [[Interface\ContainerFrame\UI-Icon-QuestBorder]],
            coords = {{0, .5, 0, .5}, {0, .5, .5, 1}, {.5, 1, .5, 1}, {.5, 1, 0, .5}},
            desaturated = true,
            width = 10,
            height = 10,
            autoScale = true,
            --scale = 1,
            x = 2,
            y = 2,
        },

        ["Pins"] = {
            path = [[Interface\ITEMSOCKETINGFRAME\UI-ItemSockets]],
            coords = {{145/256, 161/256, 3/256, 19/256}, {145/256, 161/256, 19/256, 3/256}, {161/256, 145/256, 19/256, 3/256}, {161/256, 145/256, 3/256, 19/256}},
            desaturated = 1,
            width = 4,
            height = 4,
            autoScale = false,
            --scale = 1,
            x = 2,
            y = 2,
        },

        ["Silver"] = {
            path = [[Interface\PETBATTLES\PETBATTLEHUD]],
            coords = {
                {848/1024, 868/1024, 454/512, 474/512},
                {848/1024, 868/1024, 474/512, 495/512},
                {868/1024, 889/1024, 474/512, 495/512},
                {868/1024, 889/1024, 454/512, 474/512}
            }, --848 889 454 495
            desaturated = false,
            width = 6,
            height = 6,
            autoScale = true,
            --scale = 1,
            x = 1,
            y = 1,
        },

        ["Ornament"] = {
            path = [[Interface\PETBATTLES\PETJOURNAL]],
            coords = {
                {124/512, 161/512, 71/1024, 99/1024},
                {119/512, 156/512, 29/1024, 57/1024}
            },
            desaturated = false,
            width = 18,
            height = 12,
            wscale = 1,
            hscale = 1.2,
            autoScale = true,
            --scale = 1,
            x = 14,
            y = 0,
        },

        ["Golden"] = {
            path = [[Interface\Artifacts\Artifacts]],
            coords = {
                {137/1024, (137+29)/1024, 920/1024, 978/1024},
                {(137+30)/1024, 195/1024, 920/1024, 978/1024},
            },
            desaturated = false,
            width = 8,
            height = 12,
            wscale = 1,
            hscale = 1.2,
            autoScale = true,
            --scale = 1,
            x = 0,
            y = 0,
        },

        ["Ornament Gray"] = {
            path = [[Interface\Challenges\challenges-besttime-bg]],
            coords = {
                {89/512, 123/512, 0, 1},
                {123/512, 89/512, 0, 1},
            },
            desaturated = false,
            width = 8,
            height = 12,
            alpha = 0.7,
            wscale = 1,
            hscale = 1.2,
            autoScale = true,
            --scale = 1,
            x = 0,
            y = 0,
            color = "red",
        },

        ["Epic"] = {
            path = [[Interface\UNITPOWERBARALT\WowUI_Horizontal_Frame]],
            coords = {
                {30/256, 40/256, 15/64, 49/64},
                {40/256, 30/256, 15/64, 49/64},
            },
            desaturated = false,
            width = 6,
            height = 12,
            wscale = 1,
            hscale = 1.2,
            autoScale = true,
            --scale = 1,
            x = 3,
            y = 0,
            blend = "ADD",
        },

        ["Arrow"] = {
            path = [[Interface\AddOns\Plater\media\arrow_single_right_64]],
            coords = {
                {0, 1, 0, 1},
                {1, 0, 0, 1}
            },
            desaturated = false,
            width = 20,
            height = 20,
            x = 28,
            y = 0,
            wscale = 1.5,
            hscale = 2,
            autoScale = true,
            --scale = 1,
            blend = "ADD",
            color = "white",
        },

        ["Arrow Thin"] = {
            path = [[Interface\AddOns\Plater\media\arrow_thin_right_64]],
            coords = {
                {0, 1, 0, 1},
                {1, 0, 0, 1}
            },
            desaturated = false,
            width = 20,
            height = 20,
            x = 28,
            y = 0,
            wscale = 1.5,
            hscale = 2,
            autoScale = true,
            --scale = 1,
            blend = "ADD",
            color = "white",
        },

        ["Double Arrows"] = {
            path = [[Interface\AddOns\Plater\media\arrow_double_right_64]],
            coords = {
                {0, 1, 0, 1},
                {1, 0, 0, 1}
            },
            desaturated = false,
            width = 20,
            height = 20,
            x = 28,
            y = 0,
            wscale = 1.5,
            hscale = 2,
            autoScale = true,
            --scale = 1,
            blend = "ADD",
            color = "white",
        },
    }

    --which specs each class has available
    Plater.SpecList = { --private
        ["DEMONHUNTER"] = {
            [577] = true,
            [581] = true,
        },
        ["DEATHKNIGHT"] = {
            [250] = true,
            [251] = true,
            [252] = true,
        },
        ["WARRIOR"] = {
            [71] = true,
            [72] = true,
            [73] = true,
        },
        ["MAGE"] = {
            [62] = true,
            [63] = true,
            [64] = true,
        },
        ["ROGUE"] = {
            [259] = true,
            [260] = true,
            [261] = true,
        },
        ["DRUID"] = {
            [102] = true,
            [103] = true,
            [104] = true,
            [105] = true,
        },
        ["HUNTER"] = {
            [253] = true,
            [254] = true,
            [255] = true,
        },
        ["SHAMAN"] = {
            [262] = true,
            [263] = true,
            [264] = true,
        },
        ["PRIEST"] = {
            [256] = true,
            [257] = true,
            [258] = true,
        },
        ["WARLOCK"] = {
            [265] = true,
            [266] = true,
            [267] = true,
        },
        ["PALADIN"] = {
            [65] = true,
            [66] = true,
            [70] = true,
        },
        ["MONK"] = {
            [268] = true,
            [269] = true,
            [270] = true,
        },
        ["EVOKER"] = {
            [1467] = true,
            [1468] = true,
            [1473] = true,
        },
    }

    --default ranges to use in the range check proccess against enemies, player can select a different range in the options panel
    Plater.DefaultSpellRangeList = {
        --classes
        [1] = 10, --Warrior
        [2] = 30, --Paladin
        [3] = 30, --Hunter
        [4] = 10, --Rogue
        [5] = 30, --Priest
        [6] = 10, --DeathKnight
        [7] = 30, --Shaman
        [8] = 30, --Mage
        [9] = 30, --Warlock
        [10] = 10, --Monk
        [11] = 30, --Druid
        [12] = 10, --DH

        [577] = 30, --> havoc demon hunter
        [581] = 30, --> vengeance demon hunter

        [250] = 30, --> blood dk
        [251] = 30, --> frost dk
        [252] = 30, --> unholy dk

        [102] = 45, -->  druid balance
        [103] = 40, -->  druid feral
        [104] = 30, -->  druid guardian
        [105] = 40, -->  druid resto

        [253] = 40, -->  hunter bm - Cobra Shot
        [254] = 40, --> hunter marks - Aimed Shot
        [255] = 40, --> hunter survivor - Serpent Sting

        [62] = 40, --> mage arcane
        [63] = 40, --> mage fire
        [64] = 40, --> mage frost

        [268] = 30 , --> monk bm
        [269] = 40, --> monk ww
        [270] = 40, --> monk mw

        [65] = 40, --> paladin holy
        [66] = 30, --> paladin protect
        [70] = 30, --> paladin ret

        [256] = 40, --> priest disc
        [257] = 40, --> priest holy
        [258] = 40, --> priest shadow

        [259] = 30, --> rogue assassination
        [260] = 20, --> rogue outlaw
        [261] = 30, --> rogue sub

        [262] = 40, --> shaman elemental
        [263] = 40, --> shaman enhancement
        [264] = 40, --> shaman resto

        [265] = 40, --> warlock aff
        [266] = 40, --> warlock demo
        [267] = 40, --> warlock destro

        [71] = 30, --> warrior arms
        [72] = 30, --> warrior fury
        [73] = 30, --> warrior protect

        [1467] = 25, --> evoker devastation
        [1468] = 25, --> evoker preservation
        [1473] = 25, --> evoker augmentation

        -- low-level (without spec)
        [1444] = 40, --> Initial SHAMAN
        [1446] = 40, --> Initial WARRIOR
        [1447] = 40, --> Initial DRUID
        [1448] = 40, --> Initial HUNTER
        [1449] = 40, --> Initial MAGE
        [1450] = 40, --> Initial MONK
        [1451] = 40, --> Initial PALADIN
        [1452] = 40, --> Initial PRIEST
        [1453] = 40, --> Initial ROGUE
        [1454] = 40, --> Initial WARLOCK
        [1455] = 40, --> Initial DK
        [1456] = 40, --> Initial DH
    }

    --default ranges to use in the range check proccess against friendlies, player can select a different range in the options panel
    Plater.DefaultSpellRangeListF = {
        --classes
        [1] = 30, --Warrior
        [2] = 40, --Paladin
        [3] = 40, --Hunter
        [4] = 10, --Rogue
        [5] = 40, --Priest
        [6] = 30, --DeathKnight
        [7] = 40, --Shaman
        [8] = 40, --Mage
        [9] = 40, --Warlock
        [10] = 40, --Monk
        [11] = 40, --Druid
        [12] = 30, --DH

        [577] = 30, --> havoc demon hunter
        [581] = 30, --> vengeance demon hunter

        [250] = 30, --> blood dk
        [251] = 30, --> frost dk
        [252] = 30, --> unholy dk

        [102] = 45, -->  druid balance
        [103] = 40, -->  druid feral
        [104] = 30, -->  druid guardian
        [105] = 40, -->  druid resto

        [253] = 40, -->  hunter bm - Cobra Shot
        [254] = 40, --> hunter marks - Aimed Shot
        [255] = 40, --> hunter survivor - Serpent Sting

        [62] = 40, --> mage arcane
        [63] = 40, --> mage fire
        [64] = 40, --> mage frost

        [268] = 30 , --> monk bm
        [269] = 40, --> monk ww
        [270] = 40, --> monk mw

        [65] = 40, --> paladin holy
        [66] = 30, --> paladin protect
        [70] = 30, --> paladin ret

        [256] = 40, --> priest disc
        [257] = 40, --> priest holy
        [258] = 40, --> priest shadow

        [259] = 10, --> rogue assassination
        [260] = 10, --> rogue outlaw
        [261] = 10, --> rogue sub

        [262] = 40, --> shaman elemental
        [263] = 40, --> shaman enhancement
        [264] = 40, --> shaman resto

        [265] = 40, --> warlock aff
        [266] = 40, --> warlock demo
        [267] = 40, --> warlock destro

        [71] = 30, --> warrior arms
        [72] = 30, --> warrior fury
        [73] = 30, --> warrior protect

        [1467] = 25, --> evoker devastation
        [1468] = 25, --> evoker preservation
        [1473] = 25, --> evoker augmentation

        -- low-level (without spec)
        [1444] = 40, --> Initial SHAMAN
        [1446] = 40, --> Initial WARRIOR
        [1447] = 40, --> Initial DRUID
        [1448] = 40, --> Initial HUNTER
        [1449] = 40, --> Initial MAGE
        [1450] = 40, --> Initial MONK
        [1451] = 40, --> Initial PALADIN
        [1452] = 40, --> Initial PRIEST
        [1453] = 40, --> Initial ROGUE
        [1454] = 40, --> Initial WARLOCK
        [1455] = 40, --> Initial DK
        [1456] = 40, --> Initial DH
    }

    --types of codes for each script in the Scripting tab (do not change these inside scripts)
    Plater.CodeTypeNames = { --private
        [1] = "UpdateCode",
        [2] = "ConstructorCode",
        [3] = "OnHideCode",
        [4] = "OnShowCode",
        [5] = "Initialization",
    }

    --hook options
    --types of codes available to add in a script in the Hooking tab
    Plater.HookScripts = { --private
        "Initialization",
        "Deinitialization",
        "Constructor",
        "Destructor",
        "Nameplate Created",
        "Nameplate Added",
        "Nameplate Removed",
        "Nameplate Updated",
        "Cast Start",
        "Cast Update",
        "Cast Stop",
        "Target Changed",
        "Raid Target",
        "Enter Combat",
        "Leave Combat",
        "Player Power Update",
        "Player Talent Update",
        "Health Update",
        "Zone Changed",
        "Name Updated",
        "Load Screen",
        "Player Logon",
        "Receive Comm Message",
        "Send Comm Message",
        "Option Changed",
        "Mod Option Changed",
    }

    Plater.HookScriptsDesc = { --private
        ["Initialization"] = "Executed once for the mod every time it is loaded or compiled. Used to initialize the global mod environment 'modTable'.",
        ["Deinitialization"] = "Executed once for the mod every time it is unloaded. Used to de-initialize the global mod environment 'modTable' and the mod.",
        ["Constructor"] = "Executed once when the nameplate run the hook for the first time.\n\nUse to initialize configs in the environment.\n\nAlways receive unitFrame in 'self' parameter.",
        ["Destructor"] = "Run when the hook is Disabled or unloaded due to Load Conditions.\n\nUse to hide all frames created.\n\n|cFF44FF44Run on all nameplates shown in the screen|r.",
        ["Nameplate Created"] = "Executed when a nameplate is created.\n\nRequires a |cFFFFFF22/reload|r after changing the code.",
        ["Nameplate Added"] = "Run after a nameplate is added to the screen.",
        ["Nameplate Removed"] = "Run when the nameplate is removed from the screen.",
        ["Nameplate Updated"] = "Run after the nameplate gets an updated from Plater.\n\n|cFFFFFF22Important:|r doesn't run every frame.",

        ["Cast Start"] = "When the unit starts to cast a spell.\n\n|cFFFFFF22self|r is unitFrame.castBar",
        ["Cast Update"] = "When the cast bar receives an update from Plater.\n\n|cFFFFFF22Important:|r doesn't run every frame.\n\n|cFFFFFF22self|r is unitFrame.castBar",
        ["Cast Stop"] = "When the cast is finished for any reason or the nameplate has been removed from the screen.\n\n|cFFFFFF22self|r is unitFrame.castBar",

        ["Target Changed"] = "Run after the player selects a new target.\n\n|cFF44FF44Run on all nameplates shown in the screen|r.",
        ["Raid Target"] = "A raid target mark has added, modified or removed (skull, cross, etc).\n\n|cFF44FF44Run on all nameplates shown in the screen|r.",
        ["Enter Combat"] = "Executed shortly after the player enter combat.\n\n|cFF44FF44Run on all nameplates shown in the screen|r.",
        ["Leave Combat"] = "Executed shortly after the player leave combat.\n\n|cFF44FF44Run on all nameplates shown in the screen|r.",

        ["Player Power Update"] = "Run when the player power, such as combo points, gets an update.\n\n|cFF44FF44Run only on the nameplate of your current target|r.",
        ["Player Talent Update"] = "When the player changes a talent or specialization.\n\n|cFF44FF44Run on all nameplates shown in the screen|r.",

        ["Health Update"] = "When the health of the unit changes.",
        ["Zone Changed"] = "Run when the player enter into a new zone.\n\n|cFF44FF44Run on all nameplates already created, on screen or not|r.",
        ["Name Updated"] = "Executed when the name of the unit shown in the nameplate receives an update.",
        ["Load Screen"] = "Run when a load screen finishes.\n\nUse to change settings for a specific area or map.\n\n|cFF44FF44Do not run on nameplates|r.",
        ["Player Logon"] = "Run when the player login into the game.\n\nUse to register textures, indicators, etc.\n\n|cFF44FF44Do not run on nameplates,\nrun only once after login\nor /reload|r.",
        ["Receive Comm Message"] = "Executed when a comm is received, a comm can be sent using Plater.SendComm(payload) in 'Send Comm Message' hook.",
        ["Send Comm Message"] = "Executed on an internal timer for each mod. Used to send comm data via Plater.SendComm(payload).",
        ["Option Changed"] = "Executed when a option in the options panel has changed",
        ["Mod Option Changed"] = "Executed when a option in the mod options panel has changed",
    }

    --all functions below can be overridden by scripts, hooks or any external code
    --this allows the user to fully modify Plater at a high level
    --how to override a function:
    --create a script in the hooking tab, add a 'Constructor' and a 'Nameplate Created'
    --copy the entire function from this file and paste in the constructor, hit save.
    --then when the first nameplate appears in the screen the function get rewritten
    --for fast debugging is recomended to paste the function in a 'Nameplate Updated' hook so just by saving the script (SHIFT + ENTER) you get the function to update immediately.
    Plater.CanOverride_Functions = {
        RefreshDBUpvalues = true, --refresh cache
        RefreshDBLists = true, --refresh cache
        UpdateAuraCache = true, --refresh cache

        CreateShowAuraIconAnimation = true, --creates the animation for aura icons played when they are shown
        GetHealthCutoffValue = true, --check if the character has a execute range and enable or disable the health cut off indicators
        CheckRange = true, --check if the player is in range of the unit
        GetSpellForRangeCheck = true, --get a spell to be used in the range check
        SetFontOutlineAndShadow = true, --apply the outline and shadow of a text
        UpdatePersonalBar = true, --update the personal bar
        UpdateResourceFrame = true, --anchors the resource frame (soul shards, combo points, etc)
        UpdateCastbarTargetText = true, --update the settings of the cast target (font color, size, etc)
        UpdateSpellNameSize = true, --receive a fontString and set the length of the spell name size in the cast bar
        QuickHealthUpdate = true, --update the health bar during NAMEPLATE_ADDED
        OnUpdateHealth = true, --when the healthbar get a new health value
        OnUpdateHealthMax = true, --when the maxhealth of the healthbar get updated
        UpdateIconAspecRatio = true, --adjust the icon texcoords depending on its size
        FormatTime = true, --get a number and return it formated into time, e.g. 63 return "1m" 1 minute
        FormatTimeDecimal = true, --get a number and return it formated into time with decimals below 10sec, e.g. 9.5 return "9.5s"
        GetAuraIcon = true, --return an icon to be use to show an aura
        AddAura = true, --adds an aura into the nameplate, require all the aura data and an icon
        AddExtraIcon = true, --adds an aura into the extra buff row of icons, require the aura data
        HideNonUsedAuraIcons = true, --after an aura refresh, hide all non used icons in the aura container
        ResetAuraContainer = true, --reset the aura container to be ready to a refresh
        TrackSpecificAuras = true, --refresh the aura container using a list of auras to track
        UpdateAuras_Manual = true, --start an aura refresh for manual aura tracking
        UpdateAuras_Automatic = true, --start an aura refresh for automatic aura tracking
        UpdateAuras_Self_Automatic = true, --start an aura refresh on the personal bar nameplate

        ColorOverrider = true, --control which color que nameplate will have when the Override Default Colors are enabled
        FindAndSetNameplateColor = true, --Plater tries to find a color for the nameplate
        SetTextColorByClass = true, --adds the class color into a text with scape sequence

        UpdatePlateSize = true, --control the size of health, cast, power bars
        SetPlateBackground = true, --set the backdrop when showing the nameplate area
        UpdateNameplateThread = true, --change the nameplate color based on threat
        UpdateTargetHighlight = true, --adjust the highlight on the player target nameplate
        UpdateTargetIndicator = true, --adjust the target indicator on the player target nameplate
        UpdateLifePercentVisibility = true, --control when the life percent text is shown
        UpdateLifePercentText = true, --update the health shown in the nameplate
        AddGuildNameToPlayerName = true, --adds the guild name into the player name
        UpdateUnitName = true, --update the unit name
        UpdateUnitNameTextSize = true, --controls the length of the unit name text
        UpdateBorderColor = true, --update the color of the border
        UpdatePlateBorderThickness = true, --adjust how thick is the border around the health bar
        UpdatePlateRaidMarker = true, --update the raid marker in the nameplate
        UpdateIndicators = true, --check which indicators will be shown in the nameplate (rare, elite, etc)
        AddIndicator = true, --adds an indicator
        ClearIndicators = true, --clear all indicators in the nameplate
        GetPlateAlpha = true, --get the absolute alpha amount for the nameplate (when in range)
        CheckHighlight = true, --check if the mouse is over the nameplate and show the highlight
        EnableHighlight = true, --enable the highlight check
        DisableHighlight = true, --disable the highlight check
        GetUnitType = true, --return if an unit is a pet, minor or regular

        AnimateLeftWithAccel = true, --move the health bar to left when health animation is enabled
        AnimateRightWithAccel = true, --move the health bar to right when health animation is enabled
        IsQuestObjective = true, --check if the npc from the nameplate is a quest mob
    }

    --store functions and members which can be overridden by scripts
    Plater.CanOverride_Members = {
        TargetIndicators = true, --table with all options for target indicators
        TargetHighlights = true, --table with all options for target highlight
        SparkTextures = true, --table with all textures available for castbar sparks
        CooldownEdgeTextures = true, --table with all textures available for cooldown edges
        AurasHorizontalPadding = true, --space in pixels between each row of buffs
        WideIconCoords = true, --used on buff special icons, are the texcoordinates when using wide icons
        BorderLessIconCoords = true, --used on buff special icons, when not using wide icons
        PlayerIsTank = true, --for aggro checks, if true the function will consider the player as tank
        CombatTime = true, --GetTime() of when the player entered in combat, affect aggro animations
        CurrentEncounterID = true, --store the current encounter ID if in combat and fighiting a boss
        LatestEncounter = true, --store time() from the latest ENCOUNTER_END
        ZoneInstanceType = true, --from GetInstanceInfo zone type, can be party, raid, arena, pvp, none
        ZonePvpType = true, --from GetZonePVPInfo
        PlayerGuildName = true, --name of the player's guild
        SpellForRangeCheck = true, --spell name used for range check
        PlayerGUID = true, --store the GUID of the player
        PlayerClass = true, --store the name for the player (non localized)
    }


end