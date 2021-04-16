-- server calls

function sendServerMessage(player, message)
    if(game.player_is_active(player)) then
        game.multiplayer_send_string_to_player(player, game.const.common.multiplayer_event_show_server_message, message)
    end
end

function sendColoredMessage(player, message, color)
    if(game.player_is_active(player)) then
        local trp_custom_string_1 = 462
        local mod_variable_custom_string_troop_id = 44
        game.multiplayer_send_3_int_to_player(player, game.const.common.multiplayer_event_return_mod_variable, mod_variable_custom_string_troop_id, trp_custom_string_1, 0)
        game.multiplayer_send_string_to_player(player, game.const.common.multiplayer_event_return_custom_string, message)
        game.multiplayer_send_3_int_to_player(player, game.const.common.multiplayer_event_show_multiplayer_message, game.const.common.multiplayer_message_type_message_custom_color, trp_custom_string_1, color)
    end
end

function broadcast(message)
    for curPlayer in game.playersI(1) do
        if(game.player_is_active(curPlayer)) then
            game.multiplayer_send_string_to_player(curPlayer, game.const.common.multiplayer_event_show_server_message, message)
        end
    end
end

function getPlayerName(player)
    game.str_store_player_username(37, player)
    local name = game.sreg[37]
    return name
end
