require "server"
-- ft7(first to seven) main logic

local ft7_players = {}
-- a list of players participate in ft7 mode, subscripted by temporary player ids.
-- ft7 player assets:
    --score : player's score.
    --opponent : the temporary id of the player's opponent, nil if there isn't one.
    --visited : used in "listFt7", to iterate all ongoing fights.

function checkDuelValid(player1, player2)
    if(player2 == nil) then
        if(ft7_players[player1] ~= nil) then
            sendServerMessage(player1, "You are in FT7 mode, you cannot duel a bot!")
            return false
        else
            return true
        end
    end
    local player2_name = getPlayerName(player2)
    if(ft7_players[player1] == nil and ft7_players[player2] == nil) then
        return true
    elseif(ft7_players[player1] == nil and ft7_players[player2] ~= nil) then
        sendServerMessage(player1, player2_name .. "is in FT7 mode, duel someone else!")
        return false
    elseif(ft7_players[player1] ~= nil and ft7_players[player2] == nil) then
        sendServerMessage(player1, "You are currently in FT7 mode, you can only duel with players who is also in this mode!")
        return false
    else
        if(ft7_players[player1]["opponent"] == nil and ft7_players[player2]["opponent"] == nil) then
            return true
        elseif(ft7_players[player1]["opponent"] == player2 and ft7_players[player2]["opponent"] == player1) then
            return true
        else
            sendServerMessage(player1, "You can only duel with your opponent")
            return false
        end
    end

end

function refreshScore(winner, loser)
    if(ft7_players[winner] == nil or ft7_players[winner]["opponent"] ~= loser) then
        return nil
    end
    ft7_players[winner]["score"] = ft7_players[winner]["score"] + 1
    local winner_name = getPlayerName(winner)
    local loser_name = getPlayerName(loser)
    sendServerMessage(winner, winner_name .. ": " .. ft7_players[winner]["score"] .. "  " .. loser_name .. ": " .. ft7_players[loser]["score"] .. ".")
    sendServerMessage(loser, winner_name .. ": " .. ft7_players[winner]["score"] .. "  " .. loser_name .. ": " .. ft7_players[loser]["score"] .. ".")
    if(ft7_players[winner]["score"] == 7) then
        broadcast(winner_name .. " has won a First to Seven against " .. loser_name .. "! Score: 7-" .. ft7_players[loser]["score"] .. ".")
        ft7_players[winner] = nil
        ft7_players[loser] = nil
    end
end

function ft7Check(player)
    if(ft7_players[player] ~= nil) then
    else
        sendServerMessage(player, "You have not entered First to Seven mode yet.")
	return nil
    end
    local opponent = ft7_players[player]["opponent"]
    if(opponent == nil) then
        sendServerMessage(player, "You have not started a First to Seven Duel match yet.")
    else
        local opponent_name = getPlayerName(opponent)
        sendServerMessage(player, "You are currently having a First to Seven Duel match with " .. opponent_name .. ".")
        sendServerMessage(player, "Your score: " .. ft7_players[player]["score"] .. ". Your opponent's score: " .. ft7_players[opponent]["score"] .. ".")
    end
end

function startFt7Relationship(player1, player2)
    if(ft7_players[player1] == nil or ft7_players[player2] == nil) then
	    return nil
    end
    if(ft7_players[player1]["opponent"] == nil and ft7_players[player2]["opponent"] == nil) then
        ft7_players[player1]["opponent"] = player2
        ft7_players[player2]["opponent"] = player1
        local player1_name = getPlayerName(player1)
        local player2_name = getPlayerName(player2)
        sendServerMessage(player1, "Starting First to Seven with " .. player2_name .. ".")
        sendServerMessage(player2, "Starting First to Seven with " .. player1_name .. ".")
    end
end

function playerEnterFt7(player)
    if(ft7_players[player] == nil) then
        ft7_players[player] = {}
        ft7_players[player]["score"] = 0
        ft7_players[player]["opponent"] = nil
        sendServerMessage(player, "You are ready for a First to Seven duel match, find another FT7 player to duel or cancel this by hitting the snowy barrel again.")
    else
        sendServerMessage(player, "You already entered First to Seven mode!")
    end
end

function playerLeaveFt7(player)
    if(ft7_players[player] ~= nil) then
        local opponent = ft7_players[player]["opponent"]
        if(opponent ~= nil) then
            local player_name = getPlayerName(player)
            sendServerMessage(opponent, "First to Seven with " .. player_name .. " cancelled.")
            sendServerMessage(opponent, "First to Seven Mode cancelled.")
            ft7_players[opponent] = nil
        end
        ft7_players[player] = nil
        sendServerMessage(player, "First to Seven Mode cancelled.")
    else
        sendServerMessage(player, "You have not entered First to Seven mode yet!")
    end
end

function listFt7(player)
    sendColoredMessage(player, "[!]: Players looking for FT7 matches:", 0x8CE8FF)
    for ft7_player_id, ft7_player in pairs(ft7_players) do
        ft7_player["visited"] = false
        if(ft7_player["opponent"] == nil) then
            ft7_player["visited"] = true
            local ft7_player_name = getPlayerName(ft7_player_id)
            sendColoredMessage(player, "     **" .. ft7_player_name .. "**", 0x8CE8FF)
        end
    end
    sendColoredMessage(player, "[!]: Ongoing FT7 matches:", 0xF28F24)
    for ft7_player_id, ft7_player in pairs(ft7_players) do
        if(ft7_player["visited"] == false) then
            opponent = ft7_player["opponent"]
            ft7_player["visited"] = true
            ft7_players[opponent]["visited"] = true
            local player1_name = getPlayerName(ft7_player_id)
            local player2_name = getPlayerName(opponent)
            sendColoredMessage(player, "     **" .. player1_name .. " " .. ft7_players[ft7_player_id]["score"] .. "-" .. ft7_players[opponent]["score"] .. " " .. player2_name .. "**", 0xF28F24)
        end
    end
end

function getRevivePosition(player)
    if(ft7_players[player] == nil) then
        return nil
    end
    return ft7_players[player]["opponent"]
end

function playerFt7ModeSwitch(player)
    if(ft7_players[player] == nil) then
        playerEnterFt7(player)
    else
        playerLeaveFt7(player)
    end
end

function ft7Clear()
    ft7_players = {}
end
