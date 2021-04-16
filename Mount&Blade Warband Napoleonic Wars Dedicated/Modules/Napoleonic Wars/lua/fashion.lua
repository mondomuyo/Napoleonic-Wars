require "str"

local script_create_menu = game.getScriptNo("multiplayer_agent_create_custom_order_menu")
local script_close_menu = game.getScriptNo("multiplayer_agent_close_custom_order_menu")

local fashion_menus = {}
local curflag = 111
local flags = {}

local fashion_types = {"uniform", "boots", "hats"}
local factions = {"austrian", "british", "french", "prussian", "russian", "rhine"}

for _, fashion_type in pairs(fashion_types) do
    flags[fashion_type] = {}
    for _, faction in pairs(factions) do
        flags[fashion_type][faction] = curflag
        local i = 0
        local file = io.open("./data/" .. fashion_type .. "_" .. faction .. ".txt", "r")
        for line in file:lines() do
            if(#line > 0) then
                local argc, item = split(line, " ")
                if(argc == 2) then
                    if(fashion_menus[curflag] == nil) then
                        fashion_menus[curflag] = {}
                        fashion_menus[curflag]["flag"] = flag
                        fashion_menus[curflag]["size"] = 0
                        fashion_menus[curflag]["options"] = {}
                    end
                    i = i + 1
                    fashion_menus[curflag]["options"][i] = {}
                    fashion_menus[curflag]["options"][i]["message"] = i .. "." ..item[1]
                    fashion_menus[curflag]["options"][i]["item_id"] = tonumber(item[2])
                    if(i == 8) then
                        fashion_menus[curflag]["options"][9] = {}
                        fashion_menus[curflag]["options"][0] = {}
                        fashion_menus[curflag]["options"][9]["message"] = "9.next"
                        fashion_menus[curflag]["options"][9]["item_id"] = -1
                        fashion_menus[curflag]["options"][0]["message"] = "0.exit"
                        fashion_menus[curflag]["options"][0]["item_id"] = -1
                        fashion_menus[curflag]["size"] = 8
                        i = 0
                        curflag = curflag + 1
                    end
                end
            end
        end
        if(fashion_menus[curflag] == nil) then
            fashion_menus[curflag] = {}
            fashion_menus[curflag]["flag"] = flag
            fashion_menus[curflag]["size"] = 0
            fashion_menus[curflag]["options"] = {}
        end
        fashion_menus[curflag]["options"][i + 1] = {}
        fashion_menus[curflag]["options"][i + 1]["message"] = (i + 1) .. ".exit"
        fashion_menus[curflag]["options"][i + 1]["item_id"] = -1
        fashion_menus[curflag]["size"] = i
        curflag = curflag + 1
        io.close(file)
    end
end

flags["gloves"] = curflag
local i = 0
local file = io.open("./data/gloves.txt", "r")
for line in file:lines() do
    if(#line > 0) then
        local argc, item = split(line, " ")
        if(argc == 2) then
            if(fashion_menus[curflag] == nil) then
                fashion_menus[curflag] = {}
                fashion_menus[curflag]["flag"] = curflag
                fashion_menus[curflag]["size"] = 0
                fashion_menus[curflag]["options"] = {}
            end
            i = i + 1
            fashion_menus[curflag]["options"][i] = {}
            fashion_menus[curflag]["options"][i]["message"] = i .. "." ..item[1]
            fashion_menus[curflag]["options"][i]["item_id"] = tonumber(item[2])
            if(i == 8) then
                fashion_menus[curflag]["options"][9] = {}
                fashion_menus[curflag]["options"][0] = {}
                fashion_menus[curflag]["options"][9]["message"] = "9.next"
                fashion_menus[curflag]["options"][9]["item_id"] = -1
                fashion_menus[curflag]["options"][0]["message"] = "0.exit"
                fashion_menus[curflag]["options"][0]["item_id"] = -1
                fashion_menus[curflag]["size"] = 8
                i = 0
                curflag = curflag + 1
            end
        end
    end
end
if(fashion_menus[curflag] == nil) then
    fashion_menus[curflag] = {}
    fashion_menus[curflag]["flag"] = curflag
    fashion_menus[curflag]["size"] = 0
    fashion_menus[curflag]["options"] = {}
end
fashion_menus[curflag]["options"][i + 1] = {}
fashion_menus[curflag]["options"][i + 1]["message"] = (i + 1) .. ".exit"
fashion_menus[curflag]["options"][i + 1]["item_id"] = -1
fashion_menus[curflag]["size"] = i
io.close(file)

function fashionGetSlot(item)
    return game.item_get_type(0, item) + 8
end

function processFashionMenu(player, flag, key)
    if(flag == 101) then
        if(key == 4) then
            showFashionMenu(player, flags["gloves"])
        else
            showFashionMenu(player, 101 + key)
        end
    elseif(flag <= 110) then
        showFashionMenu(player, flags[fashion_types[flag-101]][factions[key]])
    else
        if(0 < key and key <= fashion_menus[flag]["size"]) then
            if(game.player_is_active(player)) then
                local agent_id = game.player_get_agent_id(0, player)
                local item_id = fashion_menus[flag]["options"][key]["item_id"]
                local slot_id = fashionGetSlot(item_id)
                game.player_set_slot(player, slot_id + 2, item_id)
                if(agent_id > 0 and game.agent_is_alive(agent_id)) then
                    local cur_item_id = game.agent_get_item_slot(0, agent_id, slot_id)
                    if(cur_item_id > -1) then
                        game.agent_unequip_item(agent_id, cur_item_id, slot_id)
                    end
                    game.agent_equip_item(agent_id, fashion_menus[flag]["options"][key]["item_id"])
                    for curPlayer in game.playersI(1) do
                        if(game.player_is_active(curPlayer)) then
                            game.multiplayer_send_3_int_to_player(curPlayer, game.const.common.multiplayer_event_return_agent_set_item, agent_id, item_id, slot_id)
                        end
                    end
                end
            end
        elseif(key == 9 and fashion_menus[flag]["size"] == 8) then
            showFashionMenu(player, flag + 1)
        elseif(key == fashion_menus[flag]["size"] + 1 or (key == 0 and fashion_menus[flag]["size"] == 8)) then
            game.call_script(script_close_menu, player)
        end
    end
end


function showFashionMenu(player, flag)
    local menustr
    if(flag == 101) then
        menustr = "Fashion Menu^1.uniform^2.boots^3.hats^4.gloves"
        game.sreg[61] = menustr
        game.call_script(script_create_menu, player, flag, 4)
    elseif(flag <= 110) then
        menustr = "Fashion Menu^1.austrain^2.british^3.french^4.prussian^5.russian^6.rhine"
        game.sreg[61] = menustr
        game.call_script(script_create_menu, player, flag, 6)
    else
        menustr = "Fashion Menu#" .. (flag - 110)
        for i = 1, fashion_menus[flag]["size"] + 1 do
            menustr = menustr .. "^" .. fashion_menus[flag]["options"][i]["message"]
        end
        if(fashion_menus[flag]["size"] == 8) then
            menustr = menustr .. "^" .. fashion_menus[flag]["options"][0]["message"]
            game.sreg[61] = menustr
            game.call_script(script_create_menu, player, flag, fashion_menus[flag]["size"] + 2)
        else
            game.sreg[61] = menustr
            game.call_script(script_create_menu, player, flag, fashion_menus[flag]["size"] + 1)
        end
    end
end