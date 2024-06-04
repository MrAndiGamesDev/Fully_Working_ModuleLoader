local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")
local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts

local Server = RunService:IsServer()
local RootDirectory = if Server then ServerScriptService else Players.LocalPlayer:WaitForChild("PlayerScripts")
local ModuleDirectory = if Server then RootDirectory.Services else RootDirectory:WaitForChild("Controllers")

local ModuleLoader = {}

function ModuleLoader.Start()
     local self = setmetatable({}, ModuleLoader)
     
     self:RequireDescendants()
     self:DescendantLoader()
     self:RequireModule()
     self:CheckLoader()
     self:DestroyScripts()
     
     return self
end

function ModuleLoader:DescendantLoader()
     return ModuleDirectory:GetDescendants()
end

function ModuleLoader:RequireModule(Module)
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
     for _, Descendant in self:DescendantLoader() do
          self:RequireModule(Descendant)
     end
end

function ModuleLoader:DestroyScripts(Module)
     if Module:IsA("ModuleScript") and Module:IsA("Script") and Module:IsA("LocalScript") then
          return
     end
     
     for _, Descendant in self:DescendantLoader() do
          Descendant:Destroy()
     end
end

function ModuleLoader:RequireDescendants()
     self:CheckLoader()

     if not Server then
          ModuleDirectory.DescendantAdded:Connect(function(Descendant)
               self:RequireModule(Descendant)
          end)

          ModuleDirectory.DescendantRemoving:Connect(function(Descendant)
               self:DestroyScripts(Descendant)
          end)
     end
end

return function ()
     local self = ModuleLoader and ModuleLoader:RequireDescendants() and ModuleLoader.Start()
     return self
end
