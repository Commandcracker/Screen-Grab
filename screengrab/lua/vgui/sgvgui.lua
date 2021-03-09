surface.CreateFont("SG_GUI_Font_Default",{
	font = "Roboto",
    extended = true,
    size = 16
})

local PANEL = {}

function PANEL:Init()
    self.lblTitle:SetTextColor(Color(255,255,255))
	self.lblTitle:SetFont("SG_GUI_Font_Default")
    self.lblTitle:Hide()
    
    self.btnMaxim:Hide()
    self.btnMinim:Hide()
    self.btnClose:Hide()

    self.CloseButton = vgui.Create("DButton",self)
    self.CloseButton:SetText("")

    self.CloseButton.colorv = Color(255,255,255)
    self.CloseButton.Paint = function()
        surface.SetFont("SG_GUI_Font_Default")
        surface.SetTextColor(self.CloseButton.colorv)
        surface.SetTextPos(19,4)
        surface.DrawText("X")
    end

    self.CloseButton.OnCursorEntered = function() self.CloseButton.colorv = Color(255,75,0) end
    self.CloseButton.OnCursorExited = function() self.CloseButton.colorv = Color(255,255,255) end
    self.CloseButton.OnMousePressed = function() self.CloseButton.colorv = Color(200,0,0) end
    self.CloseButton.OnMouseReleased = function() self:Close() end

	self.FullscreenButton = vgui.Create("DButton",self)
	self.FullscreenButton:SetSize(12,12)

    self.FullscreenButton.activated = false

    self.FullscreenButton:SetText("")
    self.FullscreenButton.text = "1"

    self.FullscreenButton.Paint = function()
        draw.SimpleText(self.FullscreenButton.text,"Marlett",10,8,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
    end

	self.FullscreenButton.DoClick = function()
        if self.FullscreenButton.activated then
            self:SetMouseInputEnabled(false)
            self:SetKeyboardInputEnabled(false)
            self:SetDraggable(false)
            self:Stop()
            self:MoveTo(self:GetPos(),ScrH(),0.5,0,-1,function()
                self:SetSize(self.FullscreenButton.oldx, self.FullscreenButton.oldy)
                self:CenterHorizontal()
                self.FullscreenButton.text = "1"
                self:MoveTo(self:GetPos(),(ScrH()/2)-(self:GetTall()/2),0.5,0,-1,function()
                    self:SetMouseInputEnabled(true)
                    self:SetKeyboardInputEnabled(true)
                    self:SetDraggable(true)
                    self.FullscreenButton.activated = false
                end)
            end)
        else
            self.FullscreenButton.oldx = self:GetWide()
            self.FullscreenButton.oldy = self:GetTall()

            self:SetMouseInputEnabled(false)
            self:SetKeyboardInputEnabled(false)
            self:SetDraggable(false)
            self:Stop()

            self:MoveTo(self:GetPos(),ScrH(),0.5,0,-1,function()
                self:SetSize(ScrW(), ScrW())
                self:CenterHorizontal()
                self.FullscreenButton.text = "2"
                self:MoveTo(0,0,0.5,0,-1,function()
                    self:SetMouseInputEnabled(true)
                    self:SetKeyboardInputEnabled(true)
                    self.FullscreenButton.activated = true
                end)
            end)

        end
	end

end

function PANEL:Paint()
	surface.SetDrawColor(Color(255,255,255))
	surface.DrawRect(0,0,self:GetWide(),self:GetTall())
    surface.SetDrawColor(Color(0,150,255))
    surface.DrawRect(0,0,self:GetWide(),25)
    draw.SimpleText(self.lblTitle:GetText(),"SG_GUI_Font_Default",self:GetWide()/2,12.5,Color(255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
end

function PANEL:PerformLayout()
    self.FullscreenButton:SetPos(self:GetWide()-50,5)
    self.FullscreenButton:SetSize(15,15)

    self.CloseButton:SetPos(self:GetWide()-40,0)
    self.CloseButton:SetSize( 31, 24 )
end

function PANEL:Close()
	self:SetMouseInputEnabled(false)
	self:SetKeyboardInputEnabled(false)
	local x = self:GetPos()
	self:Stop()
	self:MoveTo(x,ScrH(),0.5,0,-1,function()
		self:Remove()
	end)

	if (self.OnClose ~= nil) then
		self.OnClose()
	end
end

derma.DefineControl("SG_GUI_Frame",nil,PANEL,"DFrame")
