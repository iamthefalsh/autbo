-- ⚡ AutoBuy (Tech)
-- Ideia por Patinzera | Versão com Prioridade de Distância + Detecção Dinâmica

-- 🧱 GUI Criação
local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
ScreenGui.Name = "AutoBuyUI"

local Frame = Instance.new("Frame", ScreenGui)
Frame.Size = UDim2.new(0, 340, 0, 260)
Frame.Position = UDim2.new(0.35, 0, 0.25, 0)
Frame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
Frame.BorderSizePixel = 0
Frame.Active = true
Frame.Draggable = true
Instance.new("UICorner", Frame).CornerRadius = UDim.new(0, 12)

local Title = Instance.new("TextLabel", Frame)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.Font = Enum.Font.GothamBold
Title.Text = "⚡ AutoBuy (Tech)"
Title.TextColor3 = Color3.fromRGB(0, 255, 120)
Title.TextSize = 20

local Status = Instance.new("TextLabel", Frame)
Status.Size = UDim2.new(1, 0, 0, 25)
Status.Position = UDim2.new(0, 0, 0, 30)
Status.BackgroundTransparency = 1
Status.Text = "Status: STOPPED"
Status.Font = Enum.Font.Gotham
Status.TextColor3 = Color3.fromRGB(255, 60, 60)
Status.TextSize = 16

local InputBox = Instance.new("TextBox", Frame)
InputBox.Size = UDim2.new(0.9, 0, 0, 30)
InputBox.Position = UDim2.new(0.05, 0, 0, 65)
InputBox.PlaceholderText = "Exemplo: Baddie Fenix"
InputBox.Font = Enum.Font.Gotham
InputBox.TextSize = 14
InputBox.TextColor3 = Color3.new(1,1,1)
InputBox.BackgroundColor3 = Color3.fromRGB(20, 30, 20)
Instance.new("UICorner", InputBox).CornerRadius = UDim.new(0, 8)

local StartButton = Instance.new("TextButton", Frame)
StartButton.Size = UDim2.new(0.43, 0, 0, 35)
StartButton.Position = UDim2.new(0.05, 0, 0, 105)
StartButton.Text = "▶ Start"
StartButton.Font = Enum.Font.GothamBold
StartButton.TextSize = 16
StartButton.TextColor3 = Color3.fromRGB(0, 255, 100)
StartButton.BackgroundColor3 = Color3.fromRGB(0, 50, 0)
Instance.new("UICorner", StartButton).CornerRadius = UDim.new(0, 8)

local StopButton = Instance.new("TextButton", Frame)
StopButton.Size = UDim2.new(0.43, 0, 0, 35)
StopButton.Position = UDim2.new(0.52, 0, 0, 105)
StopButton.Text = "■ Stop"
StopButton.Font = Enum.Font.GothamBold
StopButton.TextSize = 16
StopButton.TextColor3 = Color3.fromRGB(255, 80, 80)
StopButton.BackgroundColor3 = Color3.fromRGB(40, 0, 0)
Instance.new("UICorner", StopButton).CornerRadius = UDim.new(0, 8)

local LogBox = Instance.new("ScrollingFrame", Frame)
LogBox.Size = UDim2.new(0.9, 0, 0, 80)
LogBox.Position = UDim2.new(0.05, 0, 0, 150)
LogBox.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
LogBox.BorderSizePixel = 0
LogBox.ScrollBarThickness = 4
Instance.new("UICorner", LogBox).CornerRadius = UDim.new(0, 8)

local Logs = Instance.new("TextLabel", LogBox)
Logs.Size = UDim2.new(1, 0, 1, 0)
Logs.BackgroundTransparency = 1
Logs.TextColor3 = Color3.fromRGB(200, 255, 200)
Logs.Font = Enum.Font.Code
Logs.TextSize = 14
Logs.Text = "⚙️ Aguardando início..."
Logs.TextYAlignment = Enum.TextYAlignment.Top
Logs.TextWrapped = true

local Footer = Instance.new("TextLabel", Frame)
Footer.Size = UDim2.new(1, 0, 0, 20)
Footer.Position = UDim2.new(0, 0, 1, -22)
Footer.BackgroundTransparency = 1
Footer.Text = "💡 Ideia por Patinzera"
Footer.Font = Enum.Font.Gotham
Footer.TextSize = 13
Footer.TextColor3 = Color3.fromRGB(0, 255, 120)

-- ⚙️ Lógica principal
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local running = false
local speed = 25

local knownThings = {} -- coisas já conhecidas
local activeTarget = nil

local function log(msg)
	Logs.Text = Logs.Text .. "\n" .. msg
	LogBox.CanvasSize = UDim2.new(0, 0, 0, Logs.TextBounds.Y)
end

-- 🔍 Atualiza lista de "Things" a cada 2s
local function updateKnownThings()
	while running do
		local folder = workspace:FindFirstChild("Things")
		if folder then
			for _, thing in ipairs(folder:GetChildren()) do
				if not knownThings[thing] then
					knownThings[thing] = true
					log("🔎 Novo alvo detectado: " .. thing.Name)
				end
			end
		end
		task.wait(2)
	end
end

-- 🧭 Seleciona o mais próximo do jogador
local function getClosestThing(names)
	local folder = workspace:FindFirstChild("Things")
	local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not folder or not HRP then return nil end

	local closest, minDist = nil, math.huge
	for thing in pairs(knownThings) do
		if thing and thing.Parent == folder then
			for _, rawName in ipairs(names) do
				local name = rawName:match("^%s*(.-)%s*$")
				if string.find(thing.Name:lower(), name:lower()) then
					local part = thing:FindFirstChild("HumanoidRootPart") or thing:FindFirstChildWhichIsA("BasePart")
					if part then
						local dist = (HRP.Position - part.Position).Magnitude
						if dist < minDist then
							minDist = dist
							closest = thing
						end
					end
				end
			end
		end
	end
	return closest
end

-- 🏃 Seguir e comprar
local function followAndBuy(thing)
	local HRP = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
	if not HRP or not thing then return end

	activeTarget = thing
	log("➡ Indo para: " .. thing.Name)

	while running and thing.Parent == workspace:FindFirstChild("Things") do
		local part = thing:FindFirstChild("HumanoidRootPart") or thing:FindFirstChildWhichIsA("BasePart")
		if not part then break end

		local dist = (HRP.Position - part.Position).Magnitude
		local timeToReach = dist / speed

		local tween = TweenService:Create(HRP, TweenInfo.new(timeToReach, Enum.EasingStyle.Linear), {
			CFrame = part.CFrame * CFrame.new(0, 0, -2)
		})
		tween:Play()

		-- Compra instantânea
		for _, prompt in ipairs(thing:GetDescendants()) do
			if prompt:IsA("ProximityPrompt") then
				prompt.HoldDuration = 0
				fireproximityprompt(prompt)
				log("💰 Comprado: " .. thing.Name)
			end
		end

		task.wait(0.3) -- Atualiza a cada 0.3s
	end

	activeTarget = nil
end

-- ▶ Controle principal
local function startAutoBuy()
	if running then return end
	running = true
	Status.Text = "Status: RUNNING"
	Status.TextColor3 = Color3.fromRGB(0, 255, 120)
	log("▶ AutoBuy iniciado!")

	task.spawn(updateKnownThings)

	while running do
		local names = string.split(InputBox.Text, ",")
		local target = getClosestThing(names)
		if target and not activeTarget then
			followAndBuy(target)
		end
		task.wait(0.5)
	end
end

local function stopAutoBuy()
	running = false
	Status.Text = "Status: STOPPED"
	Status.TextColor3 = Color3.fromRGB(255, 60, 60)
	activeTarget = nil
	log("⛔ AutoBuy parado.")
end

StartButton.MouseButton1Click:Connect(startAutoBuy)
StopButton.MouseButton1Click:Connect(stopAutoBuy)
