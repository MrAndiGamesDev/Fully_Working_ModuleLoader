local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

local Server = RunService:IsServer()
local RootDirectory = if Server then ServerScriptService else Players.LocalPlayer:WaitForChild("PlayerScripts")
local ModuleDirectory = if Server then RootDirectory.Services else RootDirectory:WaitForChild("Controllers")

local ModuleLoader = {}
ModuleLoader.__index = ModuleLoader

function ModuleLoader:New()
     local self = setmetatable({}, ModuleLoader)
     
     self.Client = not Server
     
     self:RequireModule()

     return self
end

function ModuleLoader:DescendantLoader()
     return ModuleDirectory:GetDescendants()
end

function ModuleLoader:RequireModule(Module : (ModuleScript))
     if not Module:IsA("ModuleScript") then
          return
     end
     
     local Import = require(Module)
     local RunModule = Import.OnStart
     
     if RunModule then
          task.spawn(RunModule)
     end
end

function ModuleLoader:CheckLoader()
     for _, Descendant : (ModuleScript) in pairs(self:DescendantLoader()) do
          self:RequireModule(Descendant)
     end
end

function ModuleLoader:Run()
     self:CheckLoader()

     if self.Client then
          ModuleDirectory.DescendantAdded:Connect(function(Descendant : (ModuleScript))
               self:RequireModule(Descendant)
          end)
     end
end

function ModuleLoader:RequireDescendants()
     self:CheckLoader()

     if self.Client then
          ModuleDirectory.DescendantAdded:Connect(function(Descendant : (ModuleScript))
               self:RequireModule(Descendant)
          end)
     end
end

return function()
     ModuleLoader:RequireDescendants()
end
