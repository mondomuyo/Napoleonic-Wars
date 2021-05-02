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


function equipHand(player, item_id)
    if(game.player_is_active(player)) then
        local agent_id = game.player_get_agent_id(0, player)
        if(agent_id > 0 and game.agent_is_alive(agent_id)) then
            game.agent_equip_item(agent_id, item_id)
            if(game.agent_has_item_equipped(agent_id, item_id)) then
                game.agent_set_wielded_item(agent_id, item_id)
            end
        end
    end
end

function costumeGetSlot(item)
    return game.item_get_type(0, item) - 8
end

function equipCostume(player, item_id)
    if(game.player_is_active(player)) then
        local agent_id = game.player_get_agent_id(0, player)
        local slot_id = costumeGetSlot(item_id)
        game.player_set_slot(player, slot_id + 2, item_id)
        if(agent_id > 0 and game.agent_is_alive(agent_id)) then
            local cur_item_id = game.agent_get_item_slot(0, agent_id, slot_id)
            if(cur_item_id > -1) then
                game.agent_unequip_item(agent_id, cur_item_id, slot_id)
            end
            game.agent_equip_item(agent_id, item_id)
            for curPlayer in game.playersI(1) do
                if(game.player_is_active(curPlayer)) then
                    game.multiplayer_send_3_int_to_player(curPlayer, game.const.common.multiplayer_event_return_agent_set_item, agent_id, item_id, slot_id)
                end
            end
        end
    end
end

function getSceneItemsById(id)
    local index = 0
    local count = game.scene_item_get_num_instances(0, id)
    return function()
        if index < count then
            return game.scene_item_get_instance(0, id, index)
        end
        index = index + 1
    end
end

function getSpawnedItemsById(id)
    local index = 0
    local count = game.scene_spawned_item_get_num_instances(0, id)
    return function()
        if index < count then
            return game.scene_spawned_item_get_instance(0, id, index)
        end
        index = index + 1
    end
end

function getScenePropsById(id)
    local index = 0
    local count = game.scene_prop_get_num_instances(0, id)
    return function()
        if index < count then
            return game.scene_prop_get_instance(0, id, index)
        end
        index = index + 1
    end
end