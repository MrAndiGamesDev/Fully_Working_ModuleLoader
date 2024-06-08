local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts
local Player = Players.LocalPlayer

local Server = RunService:IsServer()
local Client = RunService:IsClient()

local ShortIdentifier = if Client then "[C]" else "[S]"

local RootDirectory = if Server then ServerScriptService else StarterPlayerScripts or Player:WaitForChild("PlayerScripts")
local ModuleDirectory = if Server then RootDirectory.Services else RootDirectory:WaitForChild("Controllers")

local ModuleLoader = {}
ModuleLoader.__index = ModuleLoader

function ModuleLoader:Start()
     local self = setmetatable({}, ModuleLoader)

     self:LoadModule()

     return self
end

function ModuleLoader:RequireModule(Module: ModuleScript)
     if not Module:IsA("ModuleScript") then
          return
     end

     local AutoRequire = require(Module)
     local Started = AutoRequire.OnStart

     if Started then
          task.spawn(Started)
     end
end

function ModuleLoader:NewPrint(...)
     print(ShortIdentifier, ...)
end

function ModuleLoader:NewWarn(...)
     warn(ShortIdentifier, ...)
end

function ModuleLoader:LoadModule()
     for _, Descendant: ModuleScript in ModuleDirectory:GetDescendants() do
          self:NewPrint(Descendant)
          self:RequireModule(Descendant)
     end
     
     if not Server and Client then
          ModuleDirectory.DescendantAdded:Connect(function(Descendant: ModuleScript)
               self:RequireModule(Descendant)
          end)
     end
end

return function()
     local Success, Result = pcall(function()
          return ModuleLoader
     end)
     if Success then
          Result:Start()
     else
          if not Success then
               Result:NewWarn(`Failed To Load`)
          end
     end
end
