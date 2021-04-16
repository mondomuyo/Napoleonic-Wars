require "str"

local script_create_menu = game.getScriptNo("multiplayer_agent_create_custom_order_menu")
local script_close_menu = game.getScriptNo("multiplayer_agent_close_custom_order_menu")

local misc_menus = {}
local flag = 11
local i = 0
local file = io.open("./data/misc.txt", "r")
for line in file:lines() do
    if(#line > 0) then
        local argc, item = split(line, " ")
        if(argc == 2) then
            if(misc_menus[flag] == nil) then
                misc_menus[flag] = {}
                misc_menus[flag]["flag"] = flag
                misc_menus[flag]["size"] = 0
                misc_menus[flag]["options"] = {}
            end
            i = i + 1
            misc_menus[flag]["options"][i] = {}
            misc_menus[flag]["options"][i]["message"] = i .. "." ..item[1]
            misc_menus[flag]["options"][i]["item_id"] = tonumber(item[2])
            if(i == 8) then
                misc_menus[flag]["options"][9] = {}
                misc_menus[flag]["options"][0] = {}
                misc_menus[flag]["options"][9]["message"] = "9.next"
                misc_menus[flag]["options"][9]["item_id"] = -1
                misc_menus[flag]["options"][0]["message"] = "0.exit"
                misc_menus[flag]["options"][0]["item_id"] = -1
                misc_menus[flag]["size"] = 8
                i = 0
                flag = flag + 1
            end
        end
    end
end

if(misc_menus[flag] == nil) then
    misc_menus[flag] = {}
    misc_menus[flag]["flag"] = flag
    misc_menus[flag]["size"] = 0
    misc_menus[flag]["options"] = {}
end

misc_menus[flag]["options"][i + 1] = {}
misc_menus[flag]["options"][i + 1]["message"] = (i + 1) .. ".exit"
misc_menus[flag]["options"][i + 1]["item_id"] = -1
misc_menus[flag]["size"] = i

io.close(file)


function showMiscMenu(player, flag)
    local menustr = "Misc Menu#" .. (flag - 10)
    for i = 1, misc_menus[flag]["size"] + 1 do
        menustr = menustr .. "^" .. misc_menus[flag]["options"][i]["message"]
    end
    if(misc_menus[flag]["size"] == 8) then
        menustr = menustr .. "^" .. misc_menus[flag]["options"][0]["message"]
        game.sreg[61] = menustr
        game.call_script(script_create_menu, player, flag, misc_menus[flag]["size"] + 2)
    else
        game.sreg[61] = menustr
        game.call_script(script_create_menu, player, flag, misc_menus[flag]["size"] + 1)
    end
end

function processMiscMenu(player, flag, key)
    if(0 < key and key <= misc_menus[flag]["size"]) then
        if(game.player_is_active(player)) then
            local agent_id = game.player_get_agent_id(0, player)
            if(agent_id > 0 and game.agent_is_alive(agent_id)) then
                game.agent_equip_item(agent_id, misc_menus[flag]["options"][key]["item_id"])
                if(game.agent_has_item_equipped(agent_id, misc_menus[flag]["options"][key]["item_id"])) then
                    game.agent_set_wielded_item(agent_id, misc_menus[flag]["options"][key]["item_id"])
                end
            end
        end
    elseif(key == 9 and misc_menus[flag]["size"] == 8) then
        showMiscMenu(player, flag + 1)
    elseif(key == misc_menus[flag]["size"] + 1 or (key == 0 and misc_menus[flag]["size"] == 8)) then
        game.call_script(script_close_menu, player)
    end
end