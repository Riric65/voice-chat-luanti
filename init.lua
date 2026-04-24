local storage = minetest.get_mod_storage()
local check_interval = 0.5
local timer = 0

-- This mod calculates distances between players and exposes it
-- so a client-side bridge or external server can handle the audio.
voice_chat = {
    players = {} -- { [name] = {pos=pos, channel=ch} }
}

minetest.register_globalstep(function(dtime)
    timer = timer + dtime
    if timer < check_interval then return end
    timer = 0

    local current_players = {}
    for _, player in ipairs(minetest.get_connected_players()) do
        local name = player:get_player_name()
        local pos = player:get_pos()
        current_players[name] = {
            x = math.floor(pos.x * 10) / 10,
            y = math.floor(pos.y * 10) / 10,
            z = math.floor(pos.z * 10) / 10,
        }
    end
    
    -- Store data in mod_storage for external tools to read if they have access
    -- or just keep it in memory for API calls.
    voice_chat.players = current_players
end)

minetest.register_chatcommand("voice_status", {
    description = "Check voice chat status",
    func = function(name)
        return true, "Voice Chat mod is active. Proximity tracking is running."
    end,
})

-- Generate a unique Voice Token for each player session
minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local token = math.random(100000, 999999)
    storage:set_int("voice_token:" .. name, token)
    minetest.chat_send_player(name, "[VoiceChat] Your session token: " .. token)
end)
