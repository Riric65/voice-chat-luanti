local check_interval = 0.5
local timer = 0
local positions_file = "/tmp/luanti_voice_positions.json"

voice_chat = {
    players = {}
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
    
    voice_chat.players = current_players
    
    -- Export to file for Node.js bridge
    local file = io.open(positions_file, "w")
    if file then
        file:write(minetest.write_json(current_players))
        file:close()
    end
end)

minetest.register_on_joinplayer(function(player)
    local name = player:get_player_name()
    local token = math.random(100000, 999999)
    -- Store token in mod_storage for the bridge to verify
    minetest.get_mod_storage():set_int("voice_token:" .. name, token)
    minetest.chat_send_player(name, minetest.colorize("#00FFFF", "[VoiceChat] Use this token in the web bridge: " .. token))
end)
