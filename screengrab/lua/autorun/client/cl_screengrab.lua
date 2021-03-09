local Capture = render.Capture

local function admin_check(ply)
    if ply:IsAdmin() or ply:IsSuperAdmin() or table.HasValue(screengrab.config.allowed_groups, ply:GetNWString("usergroup")) then
        return true
    else
        return false
    end
end

function OpenSGMenu()
    local main = vgui.Create( "SG_GUI_Frame" )
    main:SetSize(500,300)
    main:Center()
    main:SetTitle("Screen Grab Menu")
    main:SetDraggable(true)
    main:MakePopup()

    local plys = vgui.Create("DComboBox", main)
    plys:SetPos(5,40)
    plys:SetSize(150,25)
    plys:SetValue("Select a Player")

    plys.curChoice = nil

    for k, v in next, player.GetHumans() do
        plys:AddChoice(v:Nick(), v)
    end

    plys.OnSelect = function(pnl, index, value)
        local ent = plys.Data[index]
        plys.curChoice = ent
    end

    local quality_slider = vgui.Create("Slider", main)
    quality_slider:SetPos(5, 95)
    quality_slider:SetWide(180)
    quality_slider:SetMin(0)
    quality_slider:SetMax(100)
    quality_slider:SetDecimals(0)
    quality_slider:SetValue(screengrab.config.default_quality)

    local screen_grab = vgui.Create("DButton", main)
    screen_grab:SetPos(5, 75)
    screen_grab:SetSize(150, 25)
    screen_grab:SetText("Screen Grab")
    screen_grab.Think = function()
        local cur = plys.curChoice
        if cur and not isstring(cur) then
            screen_grab:SetDisabled(false)
        else
            screen_grab:SetDisabled(true)
        end
    end

    screen_grab.DoClick = function()
        net.Start("ScreenGrab:ScreenGrab_Palyer")
            net.WriteEntity(plys.curChoice)
            net.WriteInt(quality_slider:GetValue(),8)
        net.SendToServer()
    end

end

concommand.Add(screengrab.config.concommand, function(ply,cmd,args)
    if ply:IsValid() and admin_check(ply) then
        if args[1] != nil then
            local victim = nil

            for _, v in pairs(player.GetHumans()) do
                if v:Nick() == args[1] or v:SteamID() == args[1] or v:SteamID64() == args[1] then
                    victim = v
                end
            end

            if victim != nil then
                MsgC(Color(0,255,0),"Screen Grabbing\n")
                local q = screengrab.config.default_quality
                if args[2] then
                    if tonumber(args[2]) == nil or tonumber(args[2]) > 100 or tonumber(args[2]) < 0 then
                        MsgC(Color(255,0,0),"Quality not Valid 0 to 100\n")
                        return
                    end
                    q = tonumber(args[2])
                end

                net.Start("ScreenGrab:ScreenGrab_Palyer")
                    net.WriteEntity(victim)
                    net.WriteInt(q,8)
                net.SendToServer()
            else
                MsgC(Color(255,0,0),"Player Not Found\n")
            end

        else
            OpenSGMenu()
        end
    end
end)

local function DisplayError(message)
    local main = vgui.Create("SG_GUI_Frame", vgui.GetWorldPanel())
    main:SetSize(500,100)
    main:Center()
    main:SetTitle("Error")
    main:SetDraggable(true)
    main.FullscreenButton:Hide()
    main:MakePopup()
    surface.SetFont("Marlett")
    main.PaintOver = function()
        draw.SimpleText(message,"SG_GUI_Font_Default",main:GetWide()/2,60,Color(255,0,0),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

end

local function DisplayData(id,play,anti_screengrab)
    local main = vgui.Create("SG_GUI_Frame", vgui.GetWorldPanel())
    main:SetSize(ScrW()/2, (ScrH()/2)+50)
    main:Center()
    main:SetTitle('Screen Grab of "'..play:Nick()..'" ('..play:SteamID()..')')
    main:SetDraggable(true)

    local DermaButton = vgui.Create("DButton",main)
    DermaButton:SetText("")
    DermaButton:SetPos((ScrW()/2)-(surface.GetTextSize("https://i.imgur.com/"..id..".jpeg")/2)-25, main:GetTall()-25)
    DermaButton:SetSize((surface.GetTextSize("https://i.imgur.com/"..id..".jpeg")/2)+30,30)
    DermaButton.DoClick = function()
        chat.PlaySound()
        SetClipboardText("https://i.imgur.com/"..id..".jpeg")
    end

    DermaButton.Paint = function() end

    main.PaintOver = function()
        surface.SetDrawColor(Color(0,150,255))
        surface.DrawRect(0,main:GetTall()-25,main:GetWide(),25)

        if anti_screengrab then
            surface.SetFont("SG_GUI_Font_Default")
            surface.SetTextPos(5, main:GetTall()-20)
            surface.SetTextColor(255,255,0)
            surface.DrawText("This user is using Some Anti Screen Grab Cheat!")
        end

        surface.SetFont("SG_GUI_Font_Default")
        surface.SetTextPos((ScrW()/2)-surface.GetTextSize("https://i.imgur.com/"..id..".jpeg")-5, main:GetTall()-20)
        surface.SetTextColor(0,0,255)
        surface.DrawText("https://i.imgur.com/"..id..".jpeg")
    end

    main:MakePopup()

    local html = vgui.Create("HTML", main)
    html:SetPos(0,25)
    html:SetHTML(
        [[<style>
        html,body {margin: 0;height:100%;}
        img {display:block;width:100%; height:100%;object-fit: cover;}
        </style>]]..
        [[ <img src=" ]] .. "https://i.imgur.com/"..id..".jpeg" .. [["/> ]]
    )

    html:SetSize(ScrW()/2,ScrH()/2)

    html.Paint = function()
        if main.FullscreenButton.activated then
            html:SetSize(ScrW(),ScrH()-25)
        else
            html:SetSize(ScrW()/2,ScrH()/2)
        end
    end

end

local shouldScreengrab = false
local quality = nil

net.Receive("ScreenGrab:Error", function()
    local message = net.ReadString()

    if message != nil then
        DisplayError(message)
    end
end)

net.Receive("ScreenGrab:ScreenGrab", function()
    quality = net.ReadInt(8)
    if quality != nil then
        shouldScreengrab = true
    end
end)

net.Receive("ScreenGrab:Display", function()
    local id = net.ReadString()
    local anti_screengrab = net.ReadBool()
    local victim = net.ReadEntity()

    if id != nil and IsValid(victim) then
        DisplayData(id, victim, anti_screengrab)
    end
end)

hook.Add("PostRender","ScreenGrab", function()
	if ( !shouldScreengrab ) then return end
	shouldScreengrab = false

    local data = Capture({
        format="jpeg",
        h=ScrH(),
        w=ScrW(),
        quality=quality,
        x=0,
        y=0
    })

    if data != nil then
        HTTP({
            url = "https://api.imgur.com/3/image",
            method = "post",
            headers = {
                ["Authorization"] = "Client-ID ae4e39b8d0ca268"
            },
            success = function(_,body,_,_)
                local body_json = util.JSONToTable(body)
                if body_json != nil then
                    net.Start("ScreenGrab:Finished")
                        net.WriteString(body_json.data.id)
                        net.WriteBool(render.Capture != Capture)
                    net.SendToServer()
                else
                    if body_json.error.message != nil then
                        net.Start("ScreenGrab:Error")
                            net.WriteString(body_json.error.message)
                        net.SendToServer()
                    else
                        net.Start("ScreenGrab:Error")
                            net.WriteString("Unknown Error!")
                        net.SendToServer()
                    end
                end
            end,
            failed = function(_)
                net.Start("ScreenGrab:Error")
                    net.WriteString("Failed to connect to imgur.com!")
                net.SendToServer()
            end,
            parameters = {
                image = util.Base64Encode(data)
            },
        })
    else
        net.Start("ScreenGrab:Error")
            net.WriteString("Failed to bypass users Anti Screen Grab Cheat!")
        net.SendToServer()
    end
end)
