
local custom_buttons = {}
-- a list of custom buttons to perform multiple scene item operations, indexed by buttons' instance ids
-- custom buttons assets:
    --button_type : the type of this custom button i.e. how it is used.
    --item_type : the type of the item to spawn

local SPAWN_ITEM = 1

local spr_custom_button_1_second = 1605

function spawnCustomButtonForItem(instance_id, item_type)
    game.prop_instance_get_position(54, instance_id)
    game.set_spawn_position(54)
    game.spawn_scene_prop(spr_custom_button_1_second)
    local button_instance_id = game.reg[0]
    custom_buttons[button_instance_id] = {}
    custom_buttons[button_instance_id]["button type"] = SPAWN_ITEM
    custom_buttons[button_instance_id]["item type"] = item_type
end

function customButtonSpawnItem(user_agent_id, instance_id)
    if(user_agent_id > 0 and game.agent_is_alive(user_agent_id)) then
        game.agent_equip_item(user_agent_id, custom_buttons[instance_id]["item type"])
        if(game.agent_has_item_equipped(user_agent_id, custom_buttons[instance_id]["item type"])) then
            game.agent_set_wielded_item(user_agent_id, custom_buttons[instance_id]["item type"])
        end
    end
end

function customButtomUsed(user_agent_id, instance_id)
    if custom_buttons[instance_id] ~= nil then
        if custom_buttons[instance_id]["button type"] == SPAWN_ITEM then
            customButtonSpawnItem(user_agent_id, instance_id)
        end
    end
end

function buttonDebug()
    return #custom_buttons
end