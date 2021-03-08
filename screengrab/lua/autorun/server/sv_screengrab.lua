util.AddNetworkString("ScreenGrab:ScreenGrab_Palyer")
util.AddNetworkString("ScreenGrab:ScreenGrab")
util.AddNetworkString("ScreenGrab:Finished")
util.AddNetworkString("ScreenGrab:Display")
util.AddNetworkString("ScreenGrab:Error")

local sessions = {}

local function admin_check(ply)
    if ply:IsAdmin() or ply:IsSuperAdmin() or table.HasValue(screengrab.config.allowed_groups, ply:GetNWString("usergroup")) then
        return true
    else
        return false
    end
end

net.Receive("ScreenGrab:Error", function(_,victim)
    if IsValid(victim) then
        local message = net.ReadString()
        if message != nil and sessions[victim:SteamID64()] != nil then
            for _,v in pairs(sessions[victim:SteamID64()]) do
                if player.GetBySteamID64(v) != false then
                    net.Start("ScreenGrab:Error")
                        net.WriteString(message)
                    net.Send(player.GetBySteamID64(v))
                end
            end
            sessions[victim:SteamID64()] = nil
        end
    end
end)

net.Receive("ScreenGrab:ScreenGrab_Palyer", function(_,ply)
    if IsValid(ply) and admin_check(ply) then
        local victim = net.ReadEntity()
        local quality = net.ReadInt(8)

        if IsValid(victim) and quality != nil then
            if sessions[victim:SteamID64()] == nil then
                sessions[victim:SteamID64()] = {ply:SteamID64()}
                net.Start("ScreenGrab:ScreenGrab")
                    net.WriteInt(quality,8)
                net.Send(victim)
            else
                if table.HasValue(sessions[victim:SteamID64()],ply:SteamID64()) then
                    net.Start("ScreenGrab:Error")
                        net.WriteString("You are Already Screen Grabbing this user!")
                    net.Send(ply)
                else
                    table.insert(sessions[victim:SteamID64()],#sessions[victim:SteamID64()],ply:SteamID64())
                end
            end
        end
    end
end)

net.Receive("ScreenGrab:Finished", function(_,victim)
    local data = net.ReadString()
    local anti_screengrab = net.ReadBool()

    if IsValid(victim) and data != nil then
        if sessions[victim:SteamID64()] != nil then
            for _,v in pairs(sessions[victim:SteamID64()]) do
                if player.GetBySteamID64(v) != false then
                    net.Start("ScreenGrab:Display")
                        net.WriteString(data)
                        net.WriteBool(anti_screengrab)
                        net.WriteEntity(victim)
                    net.Send(player.GetBySteamID64(v))
                end
            end
            sessions[victim:SteamID64()] = nil
        end
    end
end)

hook.Add("PlayerDisconnected","ScreenGrab:Update", function(pl)
    if IsValid(pl) then
        if sessions[pl:SteamID64()] != nil then
            for _,v in pairs(sessions[pl:SteamID64()]) do
                if player.GetBySteamID64(v) != false then
                    net.Start("ScreenGrab:Error")
                        net.WriteString("Player Disconnected!")
                    net.Send(player.GetBySteamID64(v))
                end
            end
            sessions[pl:SteamID64()] = nil
        end
    end
end)
