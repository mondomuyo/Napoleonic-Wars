require "misc"
require "fashion"

local script_create_menu = game.getScriptNo("multiplayer_agent_create_custom_order_menu")
local script_close_menu = game.getScriptNo("multiplayer_agent_close_custom_order_menu")


function processMainMenu(player, flag, key)
    if(key == 1) then
        showMenu(player, 11)
    elseif(key == 2) then
        showMenu(player, 101)
    elseif(key == 3) then
        game.call_script(script_close_menu, player)
    end
end

function showMainMenu(player, flag)
    local menustr = "Main Menu^1.misc^2.fashion^3.exit"
    game.sreg[61] = menustr
    game.call_script(script_create_menu, player, flag, 3)
end

function closeMenu(player)
    game.call_script(script_close_menu, player)
end

function processMenuOption(player, flag, key)
    if(flag <= 10) then
        processMainMenu(player, flag, key)
    elseif(flag <=100) then
        processMiscMenu(player, flag, key)
    elseif(flag <= 1000) then
        processFashionMenu(player, flag, key)
    end
end

function showMenu(player, flag)
    if(flag <= 10) then
        showMainMenu(player, flag)
    elseif(flag <=100) then
        showMiscMenu(player, flag)
    elseif(flag <= 1000) then
        showFashionMenu(player, flag)
    end
end