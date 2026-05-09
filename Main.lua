 -- COMMUNISM.GG - OUR GAME                                 
                                  
--            @@@@@@@@@@@@@         
--                      @@@@@       
--                        @@@@      
--                         @@@@     
--                @@@@@@    @@@@    
--              @@@@@@@     @@@@    
--             @@@@@@@      @@@@    
--              @@@@@@@@   @@@@@    
--                @    @@@@@@@@     
--                       @@@@@      
--         @@@        @@@@@@@@@     
--      @@@@@ @@@@@@@@@@@   @@@@@  
--      @@@@@                  @@   
--    @@@@@@                        
--   @@@@@@                         
--   @@@@@                          
-- COMMUNISM.GG - THE SOVIET UNION IS COMING TO ROBLOX
local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()
local Window = Rayfield:CreateWindow({
   Name = "Communism.GG",
   Icon = 0, -- Icon in Topbar. Can use Lucide Icons (string) or Roblox Image (number). 0 to use no icon (default).
   LoadingTitle = "Communism.GG",
   LoadingSubtitle = "OUR script",
   ShowText = "Communism.GG", -- for mobile users to unhide Rayfield, change if you'd like
   Theme = "AmberGlow", -- Check https://docs.sirius.menu/rayfield/configuration/themes

   ToggleUIKeybind = "K", -- The keybind to toggle the UI visibility (string like "K" or Enum.KeyCode)

   DisableRayfieldPrompts = false,
   DisableBuildWarnings = false, -- Prevents Rayfield from emitting warnings when the script has a version mismatch with the interface.

   -- ScriptID = "sid_xxxxxxxxxxxx", -- Your Script ID from developer.sirius.menu — enables analytics, managed keys, and script hosting

   ConfigurationSaving = {
      Enabled = true,
      FolderName = nil, -- Create a custom folder for your hub/game
      FileName = "Communism.GG"
   },

   Discord = {
      Enabled = false, -- Prompt the user to join your Discord server if their executor supports it
      Invite = "noinvitelink", -- The Discord invite code, do not include Discord.gg/. E.g. Discord.gg/ABCD would be ABCD
      RememberJoins = true -- Set this to false to make them join the Discord every time they load it up
   },

   KeySystem = false, -- Set this to true to use our key system
   KeySettings = {
      Title = "Untitled",
      Subtitle = "Key System",
      Note = "No method of obtaining the key is provided", -- Use this to tell the user how to get a key
      FileName = "Key", -- It is recommended to use something unique, as other scripts using Rayfield may overwrite your key file
      SaveKey = true, -- The user's key will be saved, but if you change the key, they will be unable to use your script
      GrabKeyFromSite = false, -- If this is true, set Key below to the RAW site you would like Rayfield to get the key from
      Key = {"Hello"} -- List of keys that the system will accept, can be RAW file links (pastebin, github, etc.) or simple strings ("hello", "key22")
   }
})


local MainTab = Window:CreateTab("Movement", "axis-3d")
local VisualTab = Window:CreateTab("Visual", "eye")


local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local flying = false
local speed = 50

local linearVelocity
local alignOrientation
local attachment
local flyConnection
local deathConnection

local function stopFly()
	flying = false

	if flyConnection then
		flyConnection:Disconnect()
		flyConnection = nil
	end

	if deathConnection then
		deathConnection:Disconnect()
		deathConnection = nil
	end

	local character = player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")

		if humanoid then
			humanoid.PlatformStand = false
			humanoid.AutoRotate = true
		end
	end

	if linearVelocity then
		linearVelocity:Destroy()
		linearVelocity = nil
	end

	if alignOrientation then
		alignOrientation:Destroy()
		alignOrientation = nil
	end

	if attachment then
		attachment:Destroy()
		attachment = nil
	end
end

local function startFly()
	if flying then return end
	flying = true

	local character = player.Character or player.CharacterAdded:Wait()
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")

	humanoid.PlatformStand = true
	humanoid.AutoRotate = false

	attachment = Instance.new("Attachment")
	attachment.Parent = rootPart

	linearVelocity = Instance.new("LinearVelocity")
	linearVelocity.Attachment0 = attachment
	linearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
	linearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Vector
	linearVelocity.MaxForce = math.huge
	linearVelocity.Parent = rootPart

	alignOrientation = Instance.new("AlignOrientation")
	alignOrientation.Attachment0 = attachment
	alignOrientation.Mode = Enum.OrientationAlignmentMode.OneAttachment
	alignOrientation.MaxTorque = math.huge
	alignOrientation.Responsiveness = 15
	alignOrientation.Parent = rootPart

	deathConnection = humanoid.Died:Connect(function()
		stopFly()
	end)

	flyConnection = RunService.RenderStepped:Connect(function()
		if not flying then return end

		local moveDirection = Vector3.new(
			(UIS:IsKeyDown(Enum.KeyCode.A) and -1 or 0) + (UIS:IsKeyDown(Enum.KeyCode.D) and 1 or 0),
			(UIS:IsKeyDown(Enum.KeyCode.Space) and 1 or 0) + (UIS:IsKeyDown(Enum.KeyCode.LeftShift) and -1 or 0),
			(UIS:IsKeyDown(Enum.KeyCode.W) and -1 or 0) + (UIS:IsKeyDown(Enum.KeyCode.S) and 1 or 0)
		)

		if moveDirection.Magnitude > 0 then
			local worldDirection = camera.CFrame:VectorToWorldSpace(moveDirection)

			linearVelocity.VectorVelocity = worldDirection.Unit * speed

			alignOrientation.CFrame = CFrame.lookAt(
				rootPart.Position,
				rootPart.Position + Vector3.new(worldDirection.X, 0, worldDirection.Z)
			)
		else
			linearVelocity.VectorVelocity = Vector3.zero
		end
	end)
end

-- RAYFIELD FLIGHT TOGGLE

MainTab:CreateToggle({
	Name = "Flight",
	CurrentValue = false,
	Flag = "FlyToggle",
	Callback = function(Value)
		if Value then
			startFly()
		else
			stopFly()
		end
	end,
})


local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera

local LocalPlayer = Players.LocalPlayer

local espEnabled = false
local espCache = {}
local renderConnection

local function createESP(player)
	if player == LocalPlayer then return end

	local box = Drawing.new("Square")
	box.Thickness = 1
	box.Filled = false
	box.Visible = false

	local tracer = Drawing.new("Line")
	tracer.Thickness = 1
	tracer.Visible = false

	local name = Drawing.new("Text")
	name.Size = 13
	name.Center = true
	name.Outline = true
	name.Visible = false
	name.Text = player.Name

	espCache[player] = {
		Box = box,
		Tracer = tracer,
		Name = name
	}
end

local function removeESP(player)
	if espCache[player] then
		for _, drawing in pairs(espCache[player]) do
			drawing:Remove()
		end

		espCache[player] = nil
	end
end

local function enableESP()
	for _, player in ipairs(Players:GetPlayers()) do
		createESP(player)
	end

	renderConnection = RunService.RenderStepped:Connect(function()
		for player, drawings in pairs(espCache) do
			local character = player.Character
			local root = character and character:FindFirstChild("HumanoidRootPart")
			local humanoid = character and character:FindFirstChild("Humanoid")

			if character and root and humanoid and humanoid.Health > 0 then
				local pos, onScreen = Camera:WorldToViewportPoint(root.Position)

				if onScreen then
					local scale = 1 / (pos.Z * math.tan(math.rad(Camera.FieldOfView * 0.5)) * 2) * 100
					local width = math.floor(35 * scale)
					local height = math.floor(55 * scale)

					-- BOX
					drawings.Box.Size = Vector2.new(width, height)
					drawings.Box.Position = Vector2.new(
						pos.X - width / 2,
						pos.Y - height / 2
					)
					drawings.Box.Visible = true

					-- TRACER
					drawings.Tracer.From = Vector2.new(
						Camera.ViewportSize.X / 2,
						Camera.ViewportSize.Y
					)

					drawings.Tracer.To = Vector2.new(pos.X, pos.Y)
					drawings.Tracer.Visible = true

					-- NAME
					drawings.Name.Position = Vector2.new(
						pos.X,
						pos.Y - height / 2 - 14
					)

					drawings.Name.Visible = true
				else
					drawings.Box.Visible = false
					drawings.Tracer.Visible = false
					drawings.Name.Visible = false
				end
			else
				drawings.Box.Visible = false
				drawings.Tracer.Visible = false
				drawings.Name.Visible = false
			end
		end
	end)
end

local function disableESP()
	if renderConnection then
		renderConnection:Disconnect()
		renderConnection = nil
	end

	for player in pairs(espCache) do
		removeESP(player)
	end
end

Players.PlayerAdded:Connect(function(player)
	if espEnabled then
		createESP(player)
	end
end)

Players.PlayerRemoving:Connect(function(player)
	removeESP(player)
end)

-- RAYFIELD TOGGLE

VisualTab:CreateToggle({
	Name = "ESP",
	CurrentValue = false,
	Flag = "ESPToggle",
	Callback = function(Value)
		espEnabled = Value

		if Value then
			enableESP()
		else
			disableESP()
		end
	end,
})


local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local playerList = {}

local function refreshPlayerList()
	table.clear(playerList)

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			table.insert(playerList, player.Name)
		end
	end
end

refreshPlayerList()

Players.PlayerAdded:Connect(refreshPlayerList)
Players.PlayerRemoving:Connect(refreshPlayerList)

local TeleportDropdown = MainTab:CreateDropdown({
	Name = "Teleport To Player",
	Options = playerList,
	CurrentOption = {},
	MultipleOptions = false,
	Flag = "PlayerTeleportDropdown",
	Callback = function(selected)
		local targetName = typeof(selected) == "table" and selected[1] or selected
		local target = Players:FindFirstChild(targetName)

		if not target then return end
		if not target.Character then return end

		local targetRoot = target.Character:FindFirstChild("HumanoidRootPart")
		local localCharacter = LocalPlayer.Character

		if targetRoot and localCharacter then
			local localRoot = localCharacter:FindFirstChild("HumanoidRootPart")

			if localRoot then
				localRoot.CFrame = targetRoot.CFrame + Vector3.new(0, 3, 0)
			end
		end
	end,
})
local Divider = MainTab:CreateDivider()


-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local LocalPlayer = Players.LocalPlayer

-- State
local targetPlayer = nil
local flingConnection = nil
local flingActive = false
local angle = 0

local function getPlayerNames()
	local names = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p ~= LocalPlayer then
			table.insert(names, p.Name)
		end
	end
	return names
end

local function startFling()
	if flingConnection then flingConnection:Disconnect() end
	flingActive = true

	flingConnection = RunService.Heartbeat:Connect(function(dt)
		if not flingActive or not targetPlayer then return end

		local targetChar = targetPlayer.Character
		local localChar = LocalPlayer.Character
		if not targetChar or not localChar then return end

		local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
		local localRoot = localChar:FindFirstChild("HumanoidRootPart")
		if not targetRoot or not localRoot then return end

		angle = angle + dt * 2000

		local yBounce = math.sin(math.rad(angle)) * 10
		local jitter = Vector3.new(
			math.random(-3, 3),
			yBounce,
			math.random(-3, 3)
		)

		local randomRotation = CFrame.Angles(
			math.rad(math.random(0, 360)),
			math.rad(math.random(0, 360)),
			math.rad(math.random(0, 360))
		)

		localRoot.CFrame = CFrame.new(targetRoot.Position + jitter) * randomRotation
	end)
end

local function stopFling()
	flingActive = false
	if flingConnection then
		flingConnection:Disconnect()
		flingConnection = nil
	end
end

local FlingToggle

local PlayerDropdown = MainTab:CreateDropdown({
	Name = "Select Player",
	Options = getPlayerNames(),
	CurrentOption = {""},
	MultipleOptions = false,
	Flag = "TargetPlayer",
	Callback = function(options)
		local found = Players:FindFirstChild(options[1])
		stopFling()
		targetPlayer = nil
		angle = 0

		if not found or found == LocalPlayer then
			if FlingToggle then FlingToggle:Set(false) end
			return
		end

		targetPlayer = found
	end,
})

FlingToggle = MainTab:CreateToggle({
	Name = "Enable Fling",
	CurrentValue = false,
	Flag = "FlingToggle",
	Callback = function(value)
		if value then
			if targetPlayer then
				startFling()
			else
				FlingToggle:Set(false)
			end
		else
			stopFling()
		end
	end,
})

Players.PlayerRemoving:Connect(function(p)
	if p == targetPlayer then
		stopFling()
		targetPlayer = nil
		FlingToggle:Set(false)
		PlayerDropdown:Refresh(getPlayerNames())
	end
end)

