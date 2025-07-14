-- ✅ RAGDOLL UNIVERSAL SCRIPT (FE / SOUND FOR ALL)

local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local Debris = game:GetService("Debris")
local player = Players.LocalPlayer

local ragdolled = false
local storedMotors = {}

local SLIP_SOUNDS = {
	"rbxassetid://7142741022",
	"rbxassetid://70557734865364",
	"rbxassetid://7903203218",
	"rbxassetid://127268090779418",
	"rbxassetid://7772283448",
	"rbxassetid://100404548892841"
}

local LAUGH_SOUNDS = {
	"rbxassetid://9114012077",
	"rbxassetid://9114011999",
	"rbxassetid://109738960586112"
}

local function playSound(soundId, parent)
	local s = Instance.new("Sound")
	s.SoundId = soundId
	s.Volume = 1
	s.RollOffMaxDistance = 100
	s.Parent = parent
	s:Play()
	Debris:AddItem(s, 5)
end

local function enableRagdoll(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	local root = character:FindFirstChild("HumanoidRootPart")
	if not humanoid or not root then return end

	local slip = SLIP_SOUNDS[math.random(1, #SLIP_SOUNDS)]
	playSound(slip, root)

	task.delay(0.5, function()
		local laugh = LAUGH_SOUNDS[math.random(1, #LAUGH_SOUNDS)]
		playSound(laugh, root)
	end)

	humanoid.AutoRotate = false
	humanoid.PlatformStand = true

	for _, m in ipairs(character:GetDescendants()) do
		if m:IsA("Motor6D") then
			local a1 = Instance.new("Attachment", m.Part0)
			a1.CFrame = m.C0
			local a2 = Instance.new("Attachment", m.Part1)
			a2.CFrame = m.C1

			local socket = Instance.new("BallSocketConstraint")
			socket.Attachment0 = a1
			socket.Attachment1 = a2
			socket.Parent = m.Part0

			socket.TwistLimitsEnabled = true
			socket.TwistLowerAngle = -45
			socket.TwistUpperAngle = 45
			socket.LimitsEnabled = true
			socket.UpperAngle = 45

			storedMotors[m.Name] = {
				Part0 = m.Part0,
				Part1 = m.Part1,
				C0 = m.C0,
				C1 = m.C1,
				Name = m.Name
			}

			m:Destroy()
		end
	end

	humanoid:ChangeState(Enum.HumanoidStateType.Physics)
	ragdolled = true
end

local function disableRagdoll(character)
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	for _, obj in ipairs(character:GetDescendants()) do
		if obj:IsA("BallSocketConstraint") or obj:IsA("Attachment") then
			obj:Destroy()
		end
	end

	for _, data in pairs(storedMotors) do
		local m = Instance.new("Motor6D")
		m.Name = data.Name
		m.Part0 = data.Part0
		m.Part1 = data.Part1
		m.C0 = data.C0
		m.C1 = data.C1
		m.Parent = data.Part0
	end

	humanoid.AutoRotate = true
	humanoid.PlatformStand = false
	humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

	storedMotors = {}
	ragdolled = false
end

UIS.InputBegan:Connect(function(input, gpe)
	if gpe then return end
	if input.KeyCode == Enum.KeyCode.R then
		local character = player.Character
		if not character then return end

		if ragdolled then
			disableRagdoll(character)
		else
			enableRagdoll(character)
		end
	end
end)
