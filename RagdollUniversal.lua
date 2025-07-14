-- ✅ RAGDOLL UNIVERSAL SCRIPT (FE / SOUND FOR ALL)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Debris = game:GetService("Debris")

local remote = ReplicatedStorage:FindFirstChild("RagdollTrigger")
if not remote then
	remote = Instance.new("RemoteEvent", ReplicatedStorage)
	remote.Name = "RagdollTrigger"
end

-- === Списки звуков
local SLIP_SOUNDS = {
	"rbxassetid://7142741022",
	"rbxassetid://7903203218",
	"rbxassetid://1163884784",
	"rbxassetid://9118823100",
	"rbxassetid://6026984224"
}

local LAUGH_SOUNDS = {
	"rbxassetid://9114012077",
	"rbxassetid://9114011999",
	"rbxassetid://183763512"
}

local ragdollStates = {}

local function playSoundGlobal(soundId, position)
	local s = Instance.new("Sound")
	s.SoundId = soundId
	s.Volume = 1
	s.EmitterSize = 10
	s.RollOffMaxDistance = 100
	s.Position = position
	s.Parent = workspace
	s:Play()
	Debris:AddItem(s, 5)
end

local function enableRagdoll(character)
	local motors = {}
	for _, m in ipairs(character:GetDescendants()) do
		if m:IsA("Motor6D") then
			local a1 = Instance.new("Attachment", m.Part0)
			local a2 = Instance.new("Attachment", m.Part1)
			a1.CFrame = m.C0
			a2.CFrame = m.C1
			local socket = Instance.new("BallSocketConstraint")
			socket.Attachment0 = a1
			socket.Attachment1 = a2
			socket.TwistLimitsEnabled = true
			socket.TwistLowerAngle = -45
			socket.TwistUpperAngle = 45
			socket.LimitsEnabled = true
			socket.UpperAngle = 45
			socket.Parent = m.Part0

			table.insert(motors, {
				Name = m.Name,
				Part0 = m.Part0,
				Part1 = m.Part1,
				C0 = m.C0,
				C1 = m.C1
			})

			m:Destroy()
		end
	end

	local hum = character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = true
		hum.AutoRotate = false
		hum:ChangeState(Enum.HumanoidStateType.Physics)
	end

	return motors
end

local function disableRagdoll(character, motors)
	for _, obj in ipairs(character:GetDescendants()) do
		if obj:IsA("BallSocketConstraint") or obj:IsA("Attachment") then
			obj:Destroy()
		end
	end

	for _, m in ipairs(motors) do
		local newMotor = Instance.new("Motor6D")
		newMotor.Name = m.Name
		newMotor.Part0 = m.Part0
		newMotor.Part1 = m.Part1
		newMotor.C0 = m.C0
		newMotor.C1 = m.C1
		newMotor.Parent = m.Part0
	end

	local hum = character:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.PlatformStand = false
		hum.AutoRotate = true
		hum:ChangeState(Enum.HumanoidStateType.GettingUp)
	end
end

remote.OnServerEvent:Connect(function(player)
	local char = player.Character
	if not char then return end
	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	if ragdollStates[player] then
		disableRagdoll(char, ragdollStates[player])
		ragdollStates[player] = nil
	else
		local motors = enableRagdoll(char)
		ragdollStates[player] = motors

		local slip = SLIP_SOUNDS[math.random(1, #SLIP_SOUNDS)]
		playSoundGlobal(slip, root.Position)

		task.delay(0.5, function()
			local laugh = LAUGH_SOUNDS[math.random(1, #LAUGH_SOUNDS)]
			playSoundGlobal(laugh, root.Position)
		end)
	end
end)

Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function()
		local ps = player:WaitForChild("PlayerScripts")

		local localScript = Instance.new("LocalScript")
		localScript.Name = "RagdollClient"
		localScript.Source = [[
			local UIS = game:GetService("UserInputService")
			local remote = game:GetService("ReplicatedStorage"):WaitForChild("RagdollTrigger")
			UIS.InputBegan:Connect(function(input, gpe)
				if gpe then return end
				if input.KeyCode == Enum.KeyCode.R then
					remote:FireServer()
				end
			end)
		]]
		localScript.Parent = ps
	end)
end)
