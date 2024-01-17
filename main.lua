--scripted by Colshawott, the best scripter. Inno sucks lol.
local rs = game:GetService("RunService")
local mps = game:GetService("MarketplaceService")

local toppingLimitGP = (24010324)--gamepass id
local increasedTopping = 15--how many toppings you want for people with the extra topping gamepass.

local bp = script.BurgerParts
local ui
local burger = {}
burger.Ui = {}
local name
local default = "Chicken Burger"
local chat = game:GetService("Chat")
local last
local first
local remotes = script.Parent.Parent.Remotes

local whitelist = {
	["Cooked Patty"] = 1;
	["Fried Patty"] = 2;
	["Grilled Patty"] = 3;
}

local sessions = {
	["1"] = {
		["plrName"] = "",
		["last"] = "",
		["env"] = "",
		["ui"] = "",
		["limit"] = 7,
		["current"] = 0,
		["key"] = 1,
	},
	["2"] = {
		["plrName"] = "",
		["last"] = "",
		["env"] = "",
		["ui"] = "",
		["limit"] = 7,
		["current"] = 0,
		["key"] = 1,
	},
	["template"] = {
		["plrName"] = "",
		["last"] = "",
		["env"] = "",
		["ui"] = "",
		["limit"] = 7,
		["current"] = 0,
		["key"] = 1,
	},
}

if rs:IsServer() then
	--local key
	local env --this is what is causing the incompatability of multiple sessions at one time, find a fix if you haven't already.
	local limit = 7--7 
	local current = 0
	----------[Normal Funcs]----------

	function burger:CreateSession(plr,key)
		local session = sessions[key]
		if mps:UserOwnsGamePassAsync(plr.UserId,toppingLimitGP) then
			session.limit = increasedTopping
		end
		session.plrName = plr.Name
		session.env = workspace.CookingSys.hamborger:WaitForChild(key)
		return session
	end

	function burger:sInit(plr,hb)
		local key = hb.Name:split("_")[2]
		hb:SetAttribute("plrUsing",plr.Name)
		warn(key,plr)
		local session = burger:CreateSession(plr,key)
		print(session)
		session.ui = script.BurgerUi:Clone()
		session.ui.Parent = plr.PlayerGui
		burger:Start(hb,plr,session)

		for i,v in pairs(burger.Ui) do
			spawn(function()
				v(plr,plr,session)	
			end)
		end
		local pp = plr.Character.PrimaryPart
		local mag = (pp.Position-hb.Position).magnitude
		if mag >=15 then
			plr:Kick("Exploit detected, can't use the burger system from the other side of the map!")
			hb:SetAttribute("InUse",false)
		end
	end

	function burger:Start(hb,plr,session)
		print(hb)
		local clone = bp.bun_b:Clone()
		clone.Position = hb.Position - Vector3.new(0,1,0)
		clone.Parent = session.env
		session.last = clone
	end

	function burger:Create(item,plr,session)
		if session.current <session.limit then
			local selected = bp[item]:Clone()
			print(session.last,selected)
			selected.Parent = session.env
			selected.Position = session.last.Position + Vector3.new(0,0.1,0)
			local ori = session.last.Orientation
			selected.Orientation =  Vector3.new(ori.X,math.random(0,360),ori.Z)
			local p0 = session.last
			local p1 = selected
			local weld = burger:Weld(p0,p1)
			session.current +=1
			session.last = selected
		end
	end

	function burger:Finish(plr,session)
		local tool = script.tool:Clone()
		local clone = bp.bun_t:Clone()
		clone.Position = session.last.Position + Vector3.new(0,0.3,0)
		clone.Parent = session.env
		local p0 = session.last 
		local p1 = clone
		burger:Weld(p0,p1)
		current = 0
		workspace.CookingSys.hb:WaitForChild("hb_"..tostring(session.key)):SetAttribute("InUse",false)
		for i,v in pairs(session.env:GetChildren())do
			if v:IsA("BasePart") then
				v.Parent = tool
				v.Anchored = false
				if v.Name == "bun_b" then
					v.Name = "Handle"
				end
			end
		end
		print(plr)
		session = sessions.template
		print(session)
		remotes.endSignal:FireClient(plr,session.ui)
		burger:Filter(plr,tool,session.ui)
	end

	function burger:Filter(plr,tool,ui)
		remotes.filterName.OnServerEvent:Connect(function(p,msg)
			warn(plr,msg)
			local filtered =  chat:FilterStringForBroadcast(msg,plr)
			if p == plr then
				tool.Name = filtered
				warn(filtered)

				if #plr.Backpack:GetChildren() <=15 and p == plr then
					tool.Parent = plr.Backpack
				end
				--plr.Backpack.CookedPatty:Destroy()
				plr.PlayerGui.BurgerUi:Destroy()
			end

			return 
		end)


	end

	function burger:Weld(p0,p1)
		local weld = Instance.new("WeldConstraint", p1)
		weld.Part0 = p0
		weld.Part1 = p1
		return "Weld Created";
	end
	----------[Ui functions]----------

	function burger.Ui:SelectTopping(plr,session)

		local function connect(bttn)
			local item = bttn:GetAttribute("Item")
			burger:Create(item,plr,session)
		end

		local frame = session.ui.OuterFrame.Main.Stuff
		for i,v in pairs(frame:GetChildren())do
			if v:IsA("ImageButton") then
				v.MouseButton1Down:Connect(function()
					connect(v)
				end)
				v.TouchTap:Connect(function()
					connect(v)
				end)
			end
		end
	end

	function burger.Ui:GetEnd(plr,session)
		warn(plr)
		local bttn = session.ui.OuterFrame.Main.Frame.bttn
		local function kill()
			burger:Finish(plr,session)
		end
		bttn.MouseButton1Down:Connect(kill) bttn.TouchTap:Connect(kill)
	end


elseif rs:IsClient() then
	local plr = game.Players.LocalPlayer


	----------[Ui functions]----------

	function burger.Ui:GetInv()

		spawn(function()
			local c = 0
			local count = 0
			local count2 = 0
			for i,v in pairs(plr.Backpack:GetChildren(),plr.Character:GetChildren())do
				count +=1 
				warn("Jamarvin Classic")
				if whitelist[v.Name] and v:IsA("Tool") then
					c+=1
					print(i)
				end

				if count >= #plr.Backpack:GetChildren() + #plr.Character:GetChildren() then
					print("balls mchenry")
					--ui.OuterFrame.Main.Stuff["1_PattyFrame"].TextLabel.Text = "Inventory: "..c
				end
			end
		end)
	end



	----------[Normal Funcs]----------
	function burger:SpawnUi(hb,p)
		--ui = script.BurgerUi:Clone()
		--ui.Parent = plr.PlayerGui
		if p.Name == plr.Name then
			for i,v in pairs(burger.Ui) do
				v()
			end
			burger:Name()
			script.Parent.Parent.Remotes.toServer:FireServer(hb)
			burger:CreateCamera(hb)
			return "Ui Created"
		end

	end



	function burger:CreateCamera(hb)
		local args = hb.Name:split("_")
		local num = args[2]
		for i,v in pairs(hb.Parent.Parent.cp:GetChildren())do
			if v.Name:split("_")[2] == num then
				local camera = workspace.CurrentCamera
				camera.CFrame = v.CFrame
				camera.CameraType = Enum.CameraType.Scriptable
				plr.Character:SetPrimaryPartCFrame(workspace.CurrentCamera.CFrame-Vector3.new(1,0,0))
				plr.Character.PrimaryPart.Anchored = true
			end
		end
	end

	function burger:EndCamera()
		plr.Character.PrimaryPart.Anchored = false
		workspace.CurrentCamera.CameraType = Enum.CameraType.Custom
	end

	function burger:Name()
		local function ballTorture(n)
			remotes.filterName:FireServer(n,plr)
			burger:EndCamera()
		end

		remotes.endSignal.OnClientEvent:Connect(function()
			local u  = plr.PlayerGui.BurgerUi
			local box = u.OuterFrame.Main.Frame.TextBox
			if box.Text == nil then
				name = default
				ballTorture(name)
			else
				name = "burger"--box.Text
				ballTorture(name)
			end
		end)
		return true
	end
end

return burger
