require "str"
require "server"
--todo : add horses

-- constants
local SUBMENU = 0
local EQUIP_HAND = 1
local EQUIP_COSTUME = 2
local SPAWN = 3
local EXIT = 4

-- Module System scripts
local script_create_menu = game.getScriptNo("multiplayer_agent_create_custom_order_menu")
local script_close_menu = game.getScriptNo("multiplayer_agent_close_custom_order_menu")

local menus = {}
-- All menus form a tree, each menu is a list of options, plus a menu string(to show the users their options).
-- An option is either a flag indexes to a submenu, or a leaf node that actually does something (change clothes, spawn weapons etc.).
-- In this menus table, a menu is indexed by its flag.
-- The flag of the root menu is 1, flag 2-10 are reserved.
-- Flag 11-100 are for menus that spawn misc items.
-- Flag 101 is the root menu for changing clothes, flag 102-110 is for menu that chooses costume factions.
-- Flag 111-1000 are menus that change the users' costumes.

function initMenu(flag, title)
    if(menus[flag] == nil) then
        menus[flag] = {}
        menus[flag]["menustr"] = title
        menus[flag]["len"] = 0
    else
        print("menu error: trying to init an existing menu")
    end
end

function addOption(flag, option, optionname)
    if(menus[flag] ~= nil) then
        menus[flag]["len"] = menus[flag]["len"] + 1
        menus[flag]["menustr"] = menus[flag]["menustr"] .. "^" .. menus[flag]["len"] .. "." .. optionname
        menus[flag][menus[flag]["len"]] = option
    else
        print("menu error: trying to add option to an unexisting menu")
    end
end

function loadMenu(filename, begFlag, menuname, menutype)
    -- Load item names and their item id from a .txt file in the data folder.
    -- These item names and id forms an array of menus, the flag of the fist menu is begFlag, each menu increase the flag by 1.
    -- A menu could contain 7 items at most. Option 0 is not used. The last option is "exit" and the second last option is "next menu".
    -- IMPORTANT : returns the flag of the next menu plus one.
    local i = 1
    local file = io.open(filename, "r")
    for line in file:lines() do
        if(#line > 0) then
            local argc, item = split(line, " ")
            if(argc == 2) then
                if(menus[begFlag] == nil) then
                    initMenu(begFlag, menuname .. "#" .. begFlag)
                end
                addOption(begFlag, {type = menutype, item_id = tonumber(item[2])}, item[1])
                if(menus[begFlag]["len"] == 7) then
                    addOption(begFlag, {type = SUBMENU, flag = begFlag + 1}, "next")
                    addOption(begFlag, {type = EXIT}, "exit")
                    begFlag = begFlag + 1
                end
            end
        end
    end
    if(menus[begFlag] == nil) then
        initMenu(begFlag, "No More")
    end
    addOption(begFlag, {type = EXIT}, "exit")
    return begFlag + 1
end

function showMenu(player, flag)
    game.sreg[61] = menus[flag]["menustr"]
    game.call_script(script_create_menu, player, flag, menus[flag]["len"])
end

function closeMenu(player)
    game.call_script(script_close_menu, player)
end

function processMenuOption(player, flag, key)
    if(menus[flag] == nil) then
        print("menu error: menu not existed")
    else
        local option = menus[flag][key]
        if(option["type"] == SUBMENU) then
            showMenu(player, option["flag"])
        elseif(option["type"] == EQUIP_HAND) then
            equipHand(player, option["item_id"])
        elseif(option["type"] == EQUIP_COSTUME) then
            equipCostume(player, option["item_id"])
        elseif(option["type"] == SPAWN) then
            --todo: add horses
        elseif(option["type"] == EXIT) then
            closeMenu(player)
        end
    end
end

-- add root menu
initMenu(1, "Main Menu")
addOption(1, {type = SUBMENU, flag = 11}, "misc")
addOption(1, {type = SUBMENU, flag = 101}, "fashion")
addOption(1, {type = EXIT}, "exit")

-- add misc menus
loadMenu("./data/misc.txt", 11, "Misc", EQUIP_HAND)

-- add fashion root menu
initMenu(101, "Fashion Menu") 
addOption(101, {type = SUBMENU, flag = 102}, "uniforms")
addOption(101, {type = SUBMENU, flag = 103}, "boots")
addOption(101, {type = SUBMENU, flag = 104}, "hats")

-- add fashion root menu for different types
initMenu(102, "Uniforms")
initMenu(103, "Boots")
initMenu(104, "Hats")

-- add fashion menus
do
    local fashion_types = {"uniform", "boots", "hats"}
    local factions = {"austrian", "british", "french", "prussian", "russian", "rhine"}
    local curFlag = 111
    for fashion_type_offset, fashion_type in ipairs(fashion_types) do
        for _, faction in ipairs(factions) do
            addOption(101 + fashion_type_offset, {type = SUBMENU, flag = curFlag}, faction)
            filename = "./data/" .. fashion_type .. "_" .. faction .. ".txt"
            curFlag = loadMenu(filename, curFlag, fashion_type .. "-" .. faction, EQUIP_COSTUME)
        end
    end
    -- add gloves
    addOption(101, {type = SUBMENU, flag = curFlag}, "gloves")
    loadMenu("./data/gloves.txt", curFlag, "gloves", EQUIP_COSTUME)
end -- fashion menus added