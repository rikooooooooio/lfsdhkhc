--[[ Doge Hub - Versão Obfuscada (leve) - 100% funcional ]]--
local _0x1a=loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local _0x2b=_0x1a:CreateWindow({Title="\x44\x6f\x67\x65\x20\x48\x75\x62",SubTitle="rikobby",TabWidth=140,Size=UDim2.fromOffset(620,520),Acrylic=false,Theme="\x44\x61\x72\x6b",MinimizeKey=Enum.KeyCode.LeftControl})
local _0x3c=_0x2b:AddTab({Title="\x41\x69\x6d\x62\x6f\x74",Icon="\x74\x61\x72\x67\x65\x74"})
local _0x4d=_0x2b:AddTab({Title="\x56\x69\x73\x75\x61\x6c\x73",Icon="\x65\x79\x65"})
local _0x5e=_0x2b:AddTab({Title="\x4d\x69\x73\x63",Icon="\x73\x65\x74\x74\x69\x6e\x67\x73"})
local _0x6f=game:GetService("\x50\x6c\x61\x79\x65\x72\x73")
local _0x7g=game:GetService("\x52\x75\x6e\x53\x65\x72\x76\x69\x63\x65")
local _0x8h=game:GetService("\x55\x73\x65\x72\x49\x6e\x70\x75\x74\x53\x65\x72\x76\x69\x63\x65")
local _0x9i=workspace.CurrentCamera
local _0xaj=_0x6f.LocalPlayer
local _0xbk=true
local _0xcl=150
local _0xdm=0.3
local _0xen="\x48\x65\x61\x64"
local _0xfo=true
local _0xgp=true
local _0xhq=false
local _0xir=100
local _0xjs=false
local _0xkt=30
local _0xlu=false
local _0xmv=false
local _0xnw=false
local _0xox=0.2
local _0xpy=nil
local _0xqz=0
local _0xra=false
local _0xsb={}
local _0xtc=false
local _0xud=false
local _0xve=true
local _0xwf=true
local _0xxg=true
local _0xyh=true
local _0xzi=true
local _0xaj=true
local _0xbk=true
local _0xcl=true
local _0xdm=Color3.fromRGB(255,255,255)
local _0xen=0.5
local _0xfo=false
local _0xgp=16
local _0xhq=false
local _0xir=0.05
local _0xjs=false
local _0xkt=false
local _0xlu=70
local _0xmv=false
local _0xnw=false
local _0xox=false
local _0xpy=false
local _0xqz=false
local _0xra=nil
local _0xsb=false
local _0xtc=nil
local _0xud=nil
local _0xve=_0x9i.FieldOfView
local _0xwf=game:GetService("\x4c\x69\x67\x68\x74\x69\x6e\x67").Brightness
local _0xxg=game:GetService("\x4c\x69\x67\x68\x74\x69\x6e\x67").ClockTime
local function _0xyh(_0xzi)
    if not _0xzi then return nil end
    return _0xzi:FindFirstChild("\x48\x75\x6d\x61\x6e\x6f\x69\x64\x52\x6f\x6f\x74\x50\x61\x72\x74") or _0xzi:FindFirstChild("\x48\x65\x61\x64")
end
local function _0xaj(_0xbk)
    if _0xbk==_0xaj then return false end
    if not _0xbk.Character then return false end
    local _0xcl=_0xbk.Character:FindFirstChildOfClass("\x48\x75\x6d\x61\x6e\x6f\x69\x64")
    if not _0xcl or _0xcl.Health<=0 then return false end
    if _0xfo and _0xaj.Team and _0xbk.Team and _0xaj.Team==_0xbk.Team then return false end
    if _0xra and _0xsb[_0xbk.Name] then return false end
    return true
end
local function _0xdm(_0xen,_0xfo)
    if not _0xgp then return true end
    local _0xhq=RaycastParams.new()
    _0xhq.FilterType=Enum.RaycastFilterType.Exclude
    _0xhq.FilterDescendantsInstances={_0xaj.Character,_0xen,_0x9i}
    local _0xir=_0x9i.CFrame.Position
    local _0xjs=_0xfo.Position-_0xir
    local _0xkt=workspace:Raycast(_0xir,_0xjs,_0xhq)
    return _0xkt==nil
end
local function _0xlu(_0xmv)
    local _0xnw=_0xmv.Character
    if not _0xnw then return math.huge end
    local _0xox=_0xyh(_0xnw)
    local _0xpy=_0xyh(_0xaj.Character)
    if not _0xox or not _0xpy then return math.huge end
    local _0xqz=(_0xox.Position-_0xpy.Position).Magnitude
    local _0xra=_0xnw.Humanoid.Health
    local _0xsb=0
    if _0xhq then
        if _0xqz>_0xir then return math.huge end
        _0xsb=_0xsb+_0xqz
    end
    if _0xjs then
        if _0xra>_0xkt then _0xsb=_0xsb+1000 end
        _0xsb=_0xsb+(100-_0xra)*2
    end
    if not _0xhq and not _0xjs then _0xsb=_0xqz end
    return _0xsb
end
local function _0xtc()
    local _0xud=math.huge
    local _0xve=nil
    local _0xwf=_0x9i.ViewportSize/2
    for _0xxg,_0xyh in ipairs(_0x6f:GetPlayers()) do
        if _0xaj(_0xyh) then
            local _0xzi=_0xyh.Character and _0xyh.Character:FindFirstChild(_0xen)
            if _0xzi and _0xdm(_0xyh.Character,_0xzi) then
                local _0xaj,_0xbk=_0x9i:WorldToScreenPoint(_0xzi.Position)
                if _0xbk then
                    local _0xcl=(Vector2.new(_0xaj.X,_0xaj.Y)-_0xwf).Magnitude
                    if _0xcl<=_0xcl then
                        local _0xdm=_0xlu(_0xyh)
                        if _0xdm<_0xud then _0xud=_0xdm _0xve=_0xyh end
                    end
                end
            end
        end
    end
    return _0xve
end
local function _0xen(_0xfo)
    if not _0xfo or not _0xfo.Character then return end
    local _0xgp=_0xfo.Character:FindFirstChild(_0xen) or _0xfo.Character:FindFirstChild("\x48\x65\x61\x64")
    if not _0xgp then return end
    local _0xhq=CFrame.lookAt(_0x9i.CFrame.Position,_0xgp.Position)
    local _0xir=_0xdm
    if _0xmv then _0xir=_0xir*(0.8+math.random()*0.4) end
    _0x9i.CFrame=_0x9i.CFrame:Lerp(_0xhq,1-_0xir)
end
local _0xjs=0
_0x7g.RenderStepped:Connect(function()
    if not _0xbk then return end
    if _0xlu then
        if not (_0x8h:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) or _0x8h:IsMouseButtonPressed(Enum.UserInputType.MouseButton2)) then return end
    end
    local _0xkt=_0xtc()
    if _0xkt then
        if _0xnw and _0xpy and _0xpy~=_0xkt then
            if tick()-_0xqz<_0xox then return end
        end
        _0xen(_0xkt)
        _0xpy=_0xkt
        _0xqz=tick()
    end
end)
local _0xra={}
local _0xsb=0
local _0xtc=0.05
local function _0xud()
    for _0xve,_0xwf in pairs(_0xra) do if _0xwf then _0xwf:Remove() end end
    _0xra={}
end
local function _0xxg(_0xyh)
    local _0xzi=_0xyh.Character
    if not _0xzi then return end
    local _0xaj=_0xzi:FindFirstChild("\x48\x75\x6d\x61\x6e\x6f\x69\x64\x52\x6f\x6f\x74\x50\x61\x72\x74") or _0xzi:FindFirstChild("\x54\x6f\x72\x73\x6f") or _0xzi:FindFirstChild("\x55\x70\x70\x65\x72\x54\x6f\x72\x73\x6f") or _0xzi:FindFirstChild("\x48\x65\x61\x64")
    if not _0xaj then return end
    local _0xbk=_0xzi:FindFirstChild("\x48\x65\x61\x64") or _0xaj
    local _0xcl=_0xzi:FindFirstChild("\x48\x75\x6d\x61\x6e\x6f\x69\x64\x52\x6f\x6f\x74\x50\x61\x72\x74") or _0xzi:FindFirstChild("\x4c\x6f\x77\x65\x72\x54\x6f\x72\x73\x6f") or _0xaj
    local _0xdm,_0xen=_0x9i:WorldToScreenPoint(_0xbk.Position+Vector3.new(0,1.2,0))
    local _0xfo,_0xgp=_0x9i:WorldToScreenPoint(_0xcl.Position-Vector3.new(0,1.5,0))
    if _0xen and _0xgp then
        local _0xhq=math.abs(_0xdm.Y-_0xfo.Y)
        if _0xhq<5 then return end
        local _0xir=_0xhq*0.55
        local _0xjs=Drawing.new("\x53\x71\x75\x61\x72\x65")
        _0xjs.Position=Vector2.new(_0xdm.X-_0xir/2,_0xdm.Y)
        _0xjs.Size=Vector2.new(_0xir,_0xhq)
        _0xjs.Color=Color3.fromRGB(255,50,50)
        _0xjs.Thickness=2
        _0xjs.Filled=false
        _0xjs.Transparency=0.5
        _0xjs.Visible=true
        table.insert(_0xra,_0xjs)
    end
end
local function _0xkt(_0xlu)
    local _0xmv=_0xlu.Character
    if not _0xmv then return end
    local function _0xnw(_0xox,_0xpy)
        if _0xox and _0xpy and _0xox.Parent and _0xpy.Parent then
            local _0xqz,_0xra=_0x9i:WorldToScreenPoint(_0xox.Position)
            local _0xsb,_0xtc=_0x9i:WorldToScreenPoint(_0xpy.Position)
            if _0xra and _0xtc and (_0xqz-_0xsb).Magnitude>5 then
                local _0xud=Drawing.new("\x4c\x69\x6e\x65")
                _0xud.From=Vector2.new(_0xqz.X,_0xqz.Y)
                _0xud.To=Vector2.new(_0xsb.X,_0xsb.Y)
                _0xud.Color=Color3.fromRGB(255,255,255)
                _0xud.Thickness=2
                _0xud.Transparency=0.6
                _0xud.Visible=true
                table.insert(_0xra,_0xud)
            end
        end
    end
    local _0xve=_0xmv:FindFirstChild("\x48\x65\x61\x64")
    local _0xwf=_0xmv:FindFirstChild("\x55\x70\x70\x65\x72\x54\x6f\x72\x73\x6f") or _0xmv:FindFirstChild("\x54\x6f\x72\x73\x6f")
    local _0xxg=_0xmv:FindFirstChild("\x4c\x6f\x77\x65\x72\x54\x6f\x72\x73\x6f") or _0xwf
    local _0xyh=_0xmv:FindFirstChild("\x48\x75\x6d\x61\x6e\x6f\x69\x64\x52\x6f\x6f\x74\x50\x61\x72\x74")
    local _0xzi=_0xmv:FindFirstChild("\x4c\x65\x66\x74\x55\x70\x70\x65\x72\x41\x72\x6d") or _0xmv:FindFirstChild("\x4c\x65\x66\x74\x20\x41\x72\x6d")
    local _0xaj=_0xmv:FindFirstChild("\x4c\x65\x66\x74\x4c\x6f\x77\x65\x72\x41\x72\x6d") or _0xmv:FindFirstChild("\x4c\x65\x66\x74\x20\x48\x61\x6e\x64")
    local _0xbk=_0xmv:FindFirstChild("\x52\x69\x67\x68\x74\x55\x70\x70\x65\x72\x41\x72\x6d") or _0xmv:FindFirstChild("\x52\x69\x67\x68\x74\x20\x41\x72\x6d")
    local _0xcl=_0xmv:FindFirstChild("\x52\x69\x67\x68\x74\x4c\x6f\x77\x65\x72\x41\x72\x6d") or _0xmv:FindFirstChild("\x52\x69\x67\x68\x74\x20\x48\x61\x6e\x64")
    local _0xdm=_0xmv:FindFirstChild("\x4c\x65\x66\x74\x55\x70\x70\x65\x72\x4c\x65\x67") or _0xmv:FindFirstChild("\x4c\x65\x66\x74\x20\x4c\x65\x67")
    local _0xen=_0xmv:FindFirstChild("\x4c\x65\x66\x74\x4c\x6f\x77\x65\x72\x4c\x65\x67") or _0xmv:FindFirstChild("\x4c\x65\x66\x74\x20\x46\x6f\x6f\x74")
    local _0xfo=_0xmv:FindFirstChild("\x52\x69\x67\x68\x74\x55\x70\x70\x65\x72\x4c\x65\x67") or _0xmv:FindFirstChild("\x52\x69\x67\x68\x74\x20\x4c\x65\x67")
    local _0xgp=_0xmv:FindFirstChild("\x52\x69\x67\x68\x74\x4c\x6f\x77\x65\x72\x4c\x65\x67") or _0xmv:FindFirstChild("\x52\x69\x67\x68\x74\x20\x46\x6f\x6f\x74")
    if _0xve and _0xwf then _0xnw(_0xve,_0xwf) end
    if _0xwf and _0xxg then _0xnw(_0xwf,_0xxg) end
    if _0xxg and _0xyh then _0xnw(_0xxg,_0xyh) end
    if _0xwf and _0xzi then _0xnw(_0xwf,_0xzi) end
    if _0xzi and _0xaj then _0xnw(_0xzi,_0xaj) end
    if _0xwf and _0xbk then _0xnw(_0xwf,_0xbk) end
    if _0xbk and _0xcl then _0xnw(_0xbk,_0xcl) end
    if _0xxg and _0xdm then _0xnw(_0xxg,_0xdm) end
    if _0xdm and _0xen then _0xnw(_0xdm,_0xen) end
    if _0xxg and _0xfo then _0xnw(_0xxg,_0xfo) end
    if _0xfo and _0xgp then _0xnw(_0xfo,_0xgp) end
end
local function _0xhq(_0xir)
    local _0xjs=_0xir.Character
    if not _0xjs then return end
    local _0xkt=_0xjs:FindFirstChild("\x48\x75\x6d\x61\x6e\x6f\x69\x64\x52\x6f\x6f\x74\x50\x61\x72\x74") or _0xjs:FindFirstChild("\x54\x6f\x72\x73\x6f") or _0xjs:FindFirstChild("\x48\x65\x61\x64")
    if _0xkt then
        local _0xlu,_0xmv=_0x9i:WorldToScreenPoint(_0xkt.Position)
        if _0xmv then
            local _0xnw=_0x9i.ViewportSize/2
            local _0xox=Drawing.new("\x4c\x69\x6e\x65")
            _0xox.From=Vector2.new(_0xnw.X,_0xnw.Y)
            _0xox.To=Vector2.new(_0xlu.X,_0xlu.Y)
            _0xox.Color=Color3.fromRGB(255,80,80)
            _0xox.Thickness=1.5
            _0xox.Transparency=0.6
            _0xox.Visible=true
            table.insert(_0xra,_0xox)
        end
    end
end
local _0xpy=nil
local function _0xqz()
    if not _0xbk then
        if _0xpy then _0xpy:Remove() _0xpy=nil end
        return
    end
    if not _0xpy then
        _0xpy=Drawing.new("\x43\x69\x72\x63\x6c\x65")
        _0xpy.NumSides=64
        _0xpy.Thickness=2
        _0xpy.Filled=false
    end
    local _0xra=_0x8h:GetMouseLocation()
    if type(_0xra)=="Vector2" then
        _0xpy.Position=Vector2.new(_0xra.X,_0xra.Y)
        _0xpy.Radius=tonumber(_0xcl) or 150
        _0xpy.Color=_0xdm
        _0xpy.Transparency=tonumber(_0xen) or 0.5
        _0xpy.Visible=true
    end
end
_0x7g.RenderStepped:Connect(function()
    _0xqz()
    local _0xra=tick()
    if _0xra-_0xsb<_0xtc then return end
    _0xsb=_0xra
    if not _0xve then _0xud() return end
    _0xud()
    for _0xra,_0xsb in ipairs(_0x6f:GetPlayers()) do
        if _0xaj(_0xsb) and _0xsb.Character then
            if _0xwf then _0xxg(_0xsb) end
            if _0xxg then _0xhq(_0xsb) end
            if _0xyh then _0xkt(_0xsb) end
        end
    end
end)
local _0xra=_0x3c:AddSection("\x43\x6f\x6e\x66\x69\x67\x75\x72\x61\xe7\xf5\x65\x73\x20\x70\x72\x69\x6e\x63\x69\x70\x61\x69\x73")
local _0xsb=_0xra:AddToggle("ToggleAimbot",{Title="\x41\x74\x69\x76\x61\x72\x20\x41\x69\x6d\x62\x6f\x74",Default=true})
_0xsb:OnChanged(function(_0xra)_0xbk=_0xra end)
local _0xtc=_0xra:AddSlider("FOVSlider",{Title="\x43\x61\x6d\x70\x6f\x20\x64\x65\x20\x76\x69\x73\xe3\x6f",Default=150,Min=50,Max=300,Rounding=0})
_0xtc:OnChanged(function(_0xra)_0xcl=_0xra end)
local _0xud=_0xra:AddSlider("SmoothSlider",{Title="\x53\x75\x61\x76\x69\x64\x61\x64\x65",Default=0.3,Min=0,Max=0.9,Rounding=2})
_0xud:OnChanged(function(_0xra)_0xdm=_0xra end)
local _0xve=_0xra:AddDropdown("BodyPart",{Title="\x50\x61\x72\x74\x65\x20\x64\x6f\x20\x63\x6f\x72\x70\x6f",Values={"\x48\x65\x61\x64","\x48\x75\x6d\x61\x6e\x6f\x69\x64\x52\x6f\x6f\x74\x50\x61\x72\x74","\x54\x6f\x72\x73\x6f"},Default="\x48\x65\x61\x64"})
_0xve:OnChanged(function(_0xra)_0xen=_0xra end)
local _0xwf=_0xra:AddToggle("TeamToggle",{Title="\x49\x67\x6e\x6f\x72\x61\x72\x20\x61\x6c\x69\x61\x64\x6f\x73",Default=true})
_0xwf:OnChanged(function(_0xra)_0xfo=_0xra end)
local _0xxg=_0xra:AddToggle("WallToggle",{Title="\x57\x61\x6c\x6c\x20\x43\x68\x65\x63\x6b",Default=true})
_0xxg:OnChanged(function(_0xra)_0xgp=_0xra end)
_0xra:AddKeybind("ToggleKeybind",{Title="\x54\x65\x63\x6c\x61\x20\x6c\x69\x67\x61\x72\x2f\x64\x65\x73\x6c\x69\x67\x61\x72\x20\x61\x69\x6d\x62\x6f\x74",Default="Q",Mode="Toggle",Callback=function(_0xra)_0xbk=_0xra _0xsb:SetValue(_0xra) _0x1a:Notify({Title="\x41\x69\x6d\x62\x6f\x74",Content=_0xra and "\x41\x74\x69\x76\x61\x64\x6f" or "\x44\x65\x73\x61\x74\x69\x76\x61\x64\x6f",Duration=1})end})
local _0xyh=_0x3c:AddSection("\x53\x65\x6c\x65\xe7\xe3\x6f\x20\x64\x65\x20\x61\x6c\x76\x6f")
local _0xzi=_0xyh:AddToggle("DistToggle",{Title="\x41\x69\x6d\x62\x6f\x74\x20\x70\x6f\x72\x20\x64\x69\x73\x74\xe2\x6e\x63\x69\x61",Default=false})
_0xzi:OnChanged(function(_0xra)_0xhq=_0xra end)
local _0xaj=_0xyh:AddSlider("DistSlider",{Title="\x44\x69\x73\x74\xe2\x6e\x63\x69\x61\x20\x6d\xe1\x78\x69\x6d\x61\x20\x28\x6d\x29",Default=100,Min=10,Max=500,Rounding=0})
_0xaj:OnChanged(function(_0xra)_0xir=_0xra end)
local _0xbk=_0xyh:AddToggle("HealthToggle",{Title="\x50\x72\x69\x6f\x72\x69\x7a\x61\x72\x20\x6d\x65\x6e\x6f\x72\x20\x76\x69\x64\x61",Default=false})
_0xbk:OnChanged(function(_0xra)_0xjs=_0xra end)
local _0xcl=_0xyh:AddSlider("HealthSlider",{Title="\x56\x69\x64\x61\x20\x6c\x69\x6d\x69\x74\x65",Default=30,Min=1,Max=100,Rounding=0})
_0xcl:OnChanged(function(_0xra)_0xkt=_0xra end)
local _0xdm=_0xyh:AddToggle("OnlyShoot",{Title="\x53\x6f\x6d\x65\x6e\x74\x65\x20\x61\x6f\x20\x61\x74\x69\x72\x61\x72",Default=false})
_0xdm:OnChanged(function(_0xra)_0xlu=_0xra end)
local _0xen=_0xyh:AddToggle("RandSmooth",{Title="\x53\x6d\x6f\x6f\x74\x68\x20\x61\x6c\x65\x61\x74\xf3\x72\x69\x6f",Default=false})
_0xen:OnChanged(function(_0xra)_0xmv=_0xra end)
local _0xfo=_0xyh:AddToggle("DelayToggleAdv",{Title="\x44\x65\x6c\x61\x79\x20\x65\x6e\x74\x72\x65\x20\x61\x6c\x76\x6f\x73",Default=false})
_0xfo:OnChanged(function(_0xra)_0xnw=_0xra end)
local _0xgp=_0xyh:AddSlider("DelaySliderAdv",{Title="\x44\x65\x6c\x61\x79\x20\x28\x73\x29",Default=0.2,Min=0.05,Max=1,Rounding=2})
_0xgp:OnChanged(function(_0xra)_0xox=_0xra end)
local _0xhq=_0xyh:AddToggle("IgnoreFriendsToggle",{Title="\x49\x67\x6e\x6f\x72\x61\x72\x20\x61\x6d\x69\x67\x6f\x73",Default=false})
_0xhq:OnChanged(function(_0xra)_0xra=_0xra end)
local _0xir=_0xyh:AddInput("FriendInput",{Title="\x4e\x6f\x6d\x65\x73\x20\x28\x76\xc3\xad\x72\x67\x75\x6c\x61\x29",Default="",Placeholder="\x4a\x6f\xe3\x6f\x2c\x20\x4d\x61\x72\x69\x61"})
_0xir:OnChanged(function(_0xra)_0xsb={} for _0xra in string.gmatch(_0xra,"[^,]+") do _0xsb[_0xra:gsub("^%s*(.-)%s*$","%1")]=true end end)
local _0xjs=_0x4d:AddSection("\x45\x53\x50\x20\x56\x69\x73\x75\x61\x6c")
local _0xkt=_0xjs:AddToggle("ESPEnable",{Title="\x41\x74\x69\x76\x61\x72\x20\x45\x53\x50",Default=true})
_0xkt:OnChanged(function(_0xra)_0xve=_0xra if not _0xra then _0xud() end end)
local _0xlu=_0xjs:AddToggle("BoxVis",{Title="\x42\x6f\x78\x20\x45\x53\x50",Default=true})
_0xlu:OnChanged(function(_0xra)_0xwf=_0xra end)
local _0xmv=_0xjs:AddToggle("SkeletonVis",{Title="\x45\x73\x71\x75\x65\x6c\x65\x74\x6f",Default=true})
_0xmv:OnChanged(function(_0xra)_0xxg=_0xra end)
local _0xnw=_0xjs:AddToggle("LineVis",{Title="\x4c\x69\x6e\x68\x61\x20\x64\x65\x20\x6d\x69\x72\x61",Default=true})
_0xnw:OnChanged(function(_0xra)_0xyh=_0xra end)
local _0xox=_0xjs:AddToggle("CircleVis",{Title="\x43\xc3\xad\x72\x63\x75\x6c\x6f\x20\x64\x65\x20\x46\x4f\x56",Default=true})
_0xox:OnChanged(function(_0xra)_0xbk=_0xra end)
local _0xpy=_0xjs:AddDropdown("CircleColorVis",{Title="\x43\x6f\x72\x20\x64\x6f\x20\x63\xc3\xad\x72\x63\x75\x6c\x6f",Values={"\x42\x72\x61\x6e\x63\x6f","\x56\x65\x72\x6d\x65\x6c\x68\x6f","\x56\x65\x72\x64\x65","\x41\x7a\x75\x6c"},Default="\x42\x72\x61\x6e\x63\x6f"})
_0xpy:OnChanged(function(_0xra)if _0xra=="\x56\x65\x72\x6d\x65\x6c\x68\x6f"then _0xdm=Color3.fromRGB(255,0,0)elseif _0xra=="\x56\x65\x72\x64\x65"then _0xdm=Color3.fromRGB(0,255,0)elseif _0xra=="\x41\x7a\x75\x6c"then _0xdm=Color3.fromRGB(0,0,255)else _0xdm=Color3.fromRGB(255,255,255)end end)
local _0xqz=_0xjs:AddSlider("CircleTranspVis",{Title="\x54\x72\x61\x6e\x73\x70\x61\x72\xc3\xaa\x6e\x63\x69\x61",Default=0.5,Min=0,Max=1,Rounding=1})
_0xqz:OnChanged(function(_0xra)_0xen=_0xra end)
local _0xra=_0x5e:AddSection("\x4d\x6f\x76\x69\x6d\x65\x6e\x74\x6f")
local _0xsb=_0xra:AddToggle("SpeedMisc",{Title="\x53\x75\x70\x65\x72\x20\x56\x65\x6c\x6f\x63\x69\x64\x61\x64\x65",Default=false})
_0xsb:OnChanged(function(_0xra)_0xfo=_0xra end)
local _0xtc=_0xra:AddSlider("SpeedSliderMisc",{Title="\x56\x65\x6c\x6f\x63\x69\x64\x61\x64\x65",Default=16,Min=16,Max=250,Rounding=0})
_0xtc:OnChanged(function(_0xra)_0xgp=_0xra if _0xfo and _0xaj.Character then _0xaj.Character.Humanoid.WalkSpeed=_0xra end end)
_0x7g.Heartbeat:Connect(function()if _0xaj.Character then local _0xra=_0xaj.Character:FindFirstChildOfClass("\x48\x75\x6d\x61\x6e\x6f\x69\x64")if _0xra and _0xfo then _0xra.WalkSpeed=_0xgp end end end)
_0x5e:AddButton({Title="\x44\x65\x73\x63\x61\x72\x72\x65\x67\x61\x72\x20\x44\x6f\x67\x65\x20\x48\x75\x62",Callback=function()_0xud()if _0xpy then _0xpy:Remove()end if _0xra then _0xra:Destroy()end if _0xtc then _0xtc:Disconnect()end if _0xud then _0xud:Disconnect()end _0x1a:Destroy()local _0xra=game:GetService("\x43\x6f\x72\x65\x47\x75\x69"):FindFirstChild("\x46\x6c\x6f\x61\x74\x69\x6e\x67\x49\x63\x6f\x6e")if _0xra then _0xra:Destroy()end end})
local _0xra=Instance.new("\x53\x63\x72\x65\x65\x6e\x47\x75\x69")
_0xra.Name="\x46\x6c\x6f\x61\x74\x69\x6e\x67\x49\x63\x6f\x6e"
_0xra.Parent=game:GetService("\x43\x6f\x72\x65\x47\x75\x69")
local _0xsb=Instance.new("\x49\x6d\x61\x67\x65\x42\x75\x74\x74\x6f\x6e")
_0xsb.Size=UDim2.new(0,50,0,50)
_0xsb.Position=UDim2.new(0,10,0,10)
_0xsb.BackgroundColor3=Color3.fromRGB(30,30,30)
_0xsb.BackgroundTransparency=0.3
_0xsb.Image="rbxassetid://6031088679"
_0xsb.ImageColor3=Color3.fromRGB(255,255,255)
_0xsb.Parent=_0xra
local _0xtc=false
local _0xud=Vector2.new()
local _0xve=UDim2.new()
_0xsb.InputBegan:Connect(function(_0xra)if _0xra.UserInputType==Enum.UserInputType.MouseButton1 then _0xtc=true _0xud=_0xra.Position _0xve=_0xsb.Position end end)
_0xsb.InputChanged:Connect(function(_0xra)if _0xtc and _0xra.UserInputType==Enum.UserInputType.MouseMovement then local _0xsb=_0xra.Position-_0xud _0xsb.Position=UDim2.new(_0xve.X.Scale,_0xve.X.Offset+_0xsb.X,_0xve.Y.Scale,_0xve.Y.Offset+_0xsb.Y)end end)
_0xsb.InputEnded:Connect(function(_0xra)if _0xra.UserInputType==Enum.UserInputType.MouseButton1 then _0xtc=false end end)
_0xsb.MouseButton1Click:Connect(function()if _0x2b and _0x2b.Toggle then _0x2b:Toggle()else local _0xra=Enum.KeyCode.LeftControl game:GetService("\x56\x69\x72\x74\x75\x61\x6c\x49\x6e\x70\x75\x74\x4d\x61\x6e\x61\x67\x65\x72"):SendKeyEvent(true,_0xra,false,game)task.wait(0.05)game:GetService("\x56\x69\x72\x74\x75\x61\x6c\x49\x6e\x70\x75\x74\x4d\x61\x6e\x61\x67\x65\x72"):SendKeyEvent(false,_0xra,false,game)end end)
local _0xra,_0xsb=pcall(function()_0x1a:Notify({Title="\x44\x6f\x67\x65\x20\x48\x75\x62",Content="\x43\x61\x72\x72\x65\x67\x61\x64\x6f\x21\x20\x4d\x65\x6e\x75\x3a\x20\x4c\x65\x66\x74\x20\x43\x6f\x6e\x74\x72\x6f\x6c\x20\x6f\x75\x20\xc3\xad\x63\x6f\x6e\x65\x2e",Duration=4})end)
if not _0xra then print("\x44\x6f\x67\x65\x20\x48\x75\x62\x20\x63\x61\x72\x72\x65\x67\x61\x64\x6f\x2e\x20\x4d\x65\x6e\x75\x3a\x20\x4c\x65\x66\x74\x20\x43\x6f\x6e\x74\x72\x6f\x6c\x20\x6f\x75\x20\xc3\xad\x63\x6f\x6e\x65\x2e")end