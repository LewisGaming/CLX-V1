local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/LewisGaming/UI/main/MainFile"))()
local Window = Library.CreateLib("CLX Gui", "Ocean")

-->> Game Functions <<--
local Game = Window:NewTab("Game")
local GameSection = Game:NewSection("Auto Functions")

local AutoClick
local AutoClaimChest

GameSection:NewButton("Auto Click Enable", "Auto Click/Auto Grind", function()	
	AutoClick = true
	repeat
			game.ReplicatedStorage.GameClient.Events.RemoteEvent.Click:FireServer(game.Players.LocalPlayer,"Normal")
			game.ReplicatedStorage.GameClient.Events.RemoteEvent.Click:FireServer(game.Players.LocalPlayer,"Normal")
			game.ReplicatedStorage.GameClient.Events.RemoteEvent.Click:FireServer(game.Players.LocalPlayer,"Normal")
			game:GetService("RunService").RenderStepped:Wait()
	until AutoClick == false
end)

GameSection:NewButton("Auto Click Disable", "Auto Click/Auto Grind", function()	
	AutoClick = false
end)

GameSection:NewButton("Auto Claim Chest Enable", "Auto Claim Chest", function()	
	AutoClaimChest = true
	repeat
		for i,v in pairs(workspace.Chests:GetChildren()) do
			game.ReplicatedStorage.GameClient.Events.RemoteEvent.CollectChest:FireServer(v.Name)
		end
		game:GetService("RunService").RenderStepped:Wait()
	until AutoClaimChest == false
end)

GameSection:NewButton("Auto Claim Chest Disable", "Auto Claim Chest", function()	
	AutoClaimChest = false
end)

-->> Hatching <<--
local Hatching = Window:NewTab("Hatching")
local Player = game.Players.LocalPlayer
local PlayerScripts = Player.PlayerScripts
local ClientModules = PlayerScripts.Load.Modules.ClientModules
local EggService = require(ClientModules.EggHandler.EggService)
local PetStats = require(game.ReplicatedStorage.GameClient.Modules.Utilities.PetStats)
local EggStats = require(game.ReplicatedStorage.GameClient.Modules.Utilities.EggStats)
local BuyEggEvent = game.ReplicatedStorage.GameClient.Events.RemoteFunction.BuyEgg

local HatcherSection = Hatching:NewSection("Auto Egg Hatch")
local Egg
local AutoHatchEgg
local BuyType

local oldList = {
	"None"
}
local newList = {}

local dropdown = HatcherSection:NewDropdown("Get Valid Eggs", "Gets all valid eggs and adds to the dropdown", oldList, function(currentOption)
	Egg = currentOption
end)


HatcherSection:NewButton("Update Valid Eggs", "Refreshes Dropdown", function()

	oldList = {"None"}
	newList = {}

	for i,v in pairs(EggStats) do
		if not newList[i] then
			table.insert(newList, i)
		end
	end
	dropdown:Refresh(newList)
end)


local dropdown = HatcherSection:NewDropdown("Auto Hatch Type", "Auto Hatch Type", {"Buy1", "Buy3"}, function(currentOption)
	BuyType = currentOption
end)

HatcherSection:NewButton("Auto Hatch Egg Enable", "Enables Auto Egg (Must Be Close To Egg)", function()	
	AutoHatchEgg = true	
	repeat
		local Egg = workspace:WaitForChild("Eggs"):FindFirstChild(Egg)
		BuyEggEvent:InvokeServer(Egg, BuyType)
		task.wait(1)
	until AutoHatchEgg == false
end)

HatcherSection:NewButton("Auto Hatch Egg Disable", "Disables Auto Egg", function()	
	AutoHatchEgg = false	
end)

local FakeHatcherSection = Hatching:NewSection("Fake Hatch")
local PetName
local PetType
local Eggs
local EggToHatch

function CheckExistingPet(petName)
	if petName == "" then
		for i,v in pairs(EggStats) do
			local Pets = v.Rarities
			return "Dog"
		end
	else
		return petName
	end
end

function Triple(eggName, petName, shiny, newPet)
	for i = 1, 3 do
		do
			local num = i - 2
			local offset = CFrame.new(0, 0, -4.5) * CFrame.Angles(0, math.rad(180), 0)
			spawn(function()
				pcall(function()
					if eggName ~= "" or eggName ~= " " or eggName ~= nil then
						local PetName = petName
						if shiny == "Shiny" then
							PetName = "Shiny "..petName
						end
						EggService:HatchEgg(eggName, PetName, newPet, offset + Vector3.new(2.5 * num, 0, 0), tonumber(i), shiny, false, false)
					end
				end)
			end)
		end
	end
end

function Single(eggName, petName, shiny, newPet)
	pcall(function()
		if eggName ~= "" or eggName ~= " " or eggName ~= nil then
			if shiny == "Shiny" then
				PetName = "Shiny "..petName
			end
			EggService:HatchEgg(eggName, PetName, newPet, nil, nil, shiny, false, nil)
		end
	end)
end

local db = false
FakeHatcherSection:NewButton("Fake Hatch Pet/Egg", "It Hatches Fake Pets Of Choice", function()	
	if not db then
		db = true
		if tonumber(Eggs) == 1 then
			local eggName, petName, shiny, newPet = EggToHatch, CheckExistingPet(PetName), PetType, false
			Single(eggName, petName, shiny, newPet)
		else
			local eggName, petName, shiny, newPet = EggToHatch, CheckExistingPet(PetName), PetType, false
			Triple(eggName, petName, shiny, newPet)
		end
	end
	task.wait(3)
	db = false
end)

local oldPets = {
	"None"
}
local newPets = {}

local dropdown = FakeHatcherSection:NewDropdown("Get Valid Pets", "Gets all valid pets and adds to the dropdown", oldPets, function(currentOption)
	PetName = currentOption
	for i,v in pairs(EggStats) do
		local Pets = v.Rarities
		if Pets[currentOption] then
			EggToHatch = i
		end
	end
end)

FakeHatcherSection:NewButton("Update Valid Pets", "Refreshes Dropdown", function()

	oldPets = {"None"}
	newPets = {}

	for i,v in pairs(PetStats) do
		if not newPets[i] then
			table.insert(newPets, i)
		end
	end
	dropdown:Refresh(newPets)
end)

local dropdown = FakeHatcherSection:NewDropdown("Pet Type", "Type Of Pet To Hatch", {"Normal", "Shiny"}, function(currentOption)
	PetType = currentOption
end)

local dropdown = FakeHatcherSection:NewDropdown("Egg Option", "Egg Options", {"Buy1", "Buy3"}, function(currentOption)
	Eggs = currentOption
end)

-->> Player <<--

local Player = Window:NewTab("Player")
local PlayerSection = Player:NewSection("Player")

PlayerSection:NewSlider("WalkSpeed", "Sets Player WalkSpeed", 500, 16, function(s)
	game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = s
end)

PlayerSection:NewSlider("JumpPower", "Sets Player JumpPower", 350, 50, function(s)
	game.Players.LocalPlayer.Character.Humanoid.JumpPower = s
end)

PlayerSection:NewButton("Reset Player WalkSpeed", "Resets The Player WalkSpeed", function()
	game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = 16
end)

PlayerSection:NewButton("Reset Player JumpPower", "Resets The Player JumpPower", function()
	game.Players.LocalPlayer.Character.Humanoid.JumpPower = 50
end)

-->> Credits <<--

local Other = Window:NewTab("Other")
local OtherSection = Other:NewSection("Other")

OtherSection:NewLabel("Gui Made By: ZuprizeDev")

local AntiAFK

OtherSection:NewButton("Enable Anti AFK", "Stay AFK For As Long As You Want", function()
	AntiAFK = true
	repeat 
		game.Players.LocalPlayer.Idled = false
		game:GetService("RunService").RenderStepped:Wait()
	until AntiAFK == false
end)

OtherSection:NewButton("Disable Anti AFK", "Disables Anti AFK", function()
	AntiAFK = false
end)
