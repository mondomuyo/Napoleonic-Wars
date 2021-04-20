require "str"
require "server"
require "ft7"
require "menu"
require "interactive_items"

local CUSTOM_MENU_ENABLED = true

local debug_function_call_times = 0
function onInteractiveItemLoaded(instance_id, item_type)
    debug_function_call_times = debug_function_call_times + 1
    spawnCustomButtonForItem(instance_id, item_type)
end

function onCustomButtonUsed(user_agent_id, instance_id)
    customButtomUsed(user_agent_id, instance_id)
end

function onOtherMenuActive(player, flag, other_flag)
    if(flag ~= other_flag) then
        closeMenu(player)
        showMenu(player, flag)
    end
end

function onCustomMenuSelected(player, flag, key)
    processMenuOption(player, flag, key)
end

function onCustomMenuInit(player)
    if(CUSTOM_MENU_ENABLED) then
        showMenu(player, 1)
    end
end

function onDuelModeEndOrMapChange()
    ft7Clear()
end

function onPlayerHitsTable(player)
    listFt7(player)
end

function onPlayerHitsSnowyBarrel(player)
    playerFt7ModeSwitch(player)
end

function onPlayerRevivedDuel(player)
    local temp = getRevivePosition(player)
    if(temp == nil) then
        game.fail()
    else
        game.reg[37] = temp
    end
end

function onDuelBetweenPlayersBegin(player1, player2)
    startFt7Relationship(player1, player2)
end

function onDuelBetweenPlayersEnd(winner, loser)
    if(winner ~= loser) then
        refreshScore(winner, loser)
    end
end

function onPlayerExitServer(player)
    playerLeaveFt7(player)
end

function onOfferDuel(player1, receiver_agent)
    local is_bot = game.agent_is_non_player(receiver_agent)
    if(is_bot) then
        if(checkDuelValid(player1, nil) == false) then
            game.fail()
        end
    else
        local player2 = game.agent_get_player_id(0, receiver_agent)
        if(checkDuelValid(player1, player2) == false) then
            game.fail()
        end
    end
end


function receivePlayerCommand(player, command, gametype)
    --sendColoredMessage(player, "测 试 成 功", 0x87CEFA)
    local argc, argv = split(command, " ")
    if (argc == 0) then
        return nil
    end
    if(argv[1] == "echo") then
        if(argc == 1) then
            return nil
        end
        sendServerMessage(player, argv[2])
        --echo end
    elseif(argv[1] == "list") then
        if(argc == 1) then
            sendServerMessage(player, "argument needed")
            return nil
        end
        if(argv[2] == "commands") then
            sendServerMessage(player, "echo")
            sendServerMessage(player, "list")
            sendServerMessage(player, "ft7")
        elseif(argv[2] == "players") then
            for curPlayer in game.playersI(1) do
                local name = getPlayerName(curPlayer)
                local uid = game.player_get_unique_id(0, curPlayer)
                sendServerMessage(player, "name:" .. name .. " uid:" .. uid)
            end
        elseif(argv[2] == "admins") then
            for curPlayer in game.playersI(1) do
                local isAdmin = game.player_is_admin(curPlayer)
                if(isAdmin) then
                    local name = getPlayerName(curPlayer)
                    local uid = game.player_get_unique_id(0, curPlayer)
                    sendServerMessage(player, "name:" .. name .. " uid:" .. uid)
                end
            end
        elseif(argv[2] == "ft7") then
            listFt7(player)
        else
            sendServerMessage(player, "undefined argument")
        end
        --list end
    elseif(argv[1] == "ft7") then
        if(argc == 1) then
            sendServerMessage(player, "argument needed")
            return nil
        end
        if(gametype ~= game.const.common.multiplayer_game_type_duel) then
            sendServerMessage(player, "Not in duel mode!")
            return nil
        end
        if(argv[2] == "on") then
            playerEnterFt7(player)
        elseif(argv[2] == "off") then
            playerLeaveFt7(player)
        elseif(argv[2] == "stats") then
            ft7Check(player)
        else
            sendServerMessage(player, "undefined argument")
        end
        --ft7 end
    elseif(argv[1] == "debug") then
        sendServerMessage(player, "Debug " .. buttonDebug())
        sendServerMessage(player, "Debug " .. debug_function_call_times)
    else
        sendServerMessage(player, "undefined command")
    end
end
