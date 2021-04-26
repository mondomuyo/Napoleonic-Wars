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