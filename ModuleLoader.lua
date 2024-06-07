local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")
local RunService = game:GetService("RunService")
local StarterPlayer = game:GetService("StarterPlayer")

local StarterPlayerScripts = StarterPlayer.StarterPlayerScripts
local Player = Players.LocalPlayer

local ModuleLoader = {}
ModuleLoader.__index = ModuleLoader

ModuleLoader.Server = RunService:IsServer()
ModuleLoader.Client = RunService:IsClient()

ModuleLoader.RootDirectory = if ModuleLoader.Server then ServerScriptService else StarterPlayerScripts or Player:WaitForChild("PlayerScripts")
ModuleLoader.ModuleDirectory = if ModuleLoader.Server then ModuleLoader.RootDirectory.Services else ModuleLoader.RootDirectory:WaitForChild("Controllers")

function ModuleLoader:Start()
     local self = setmetatable({}, ModuleLoader)
     
     self.Server = self.Server
     self.Client = self.Client
     
     self.RootDirectory = self.RootDirectory
     self.ModuleDirectory = self.ModuleDirectory
     
     self:RequireDescendants()
     self:DescendantLoader()
     self:RequireModule()
     self:CheckLoader()
     self:LoadModule()
     self:DestroyScripts()
     self:NewPrint()
     self:NewWarn()
     
     return self
end

function ModuleLoader:NewPrint(...)
     print(...)
end

function ModuleLoader:NewWarn(...)
     warn(...)
end

function ModuleLoader:DescendantLoader()
     return self.ModuleDirectory:GetDescendants()
end

function ModuleLoader:RequireModule(Module : any)
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

function ModuleLoader:DestroyScripts(Module : any)
     if Module:IsA("ModuleScript") and Module:IsA("Script") and Module:IsA("LocalScript") then
          return
     end

     for _, Descendant in self:DescendantLoader() do
          Descendant:Destroy()
     end
end

function ModuleLoader:RequireDescendants()
     self:CheckLoader()

     if not self.Server and self.Client then
          self.ModuleDirectory.DescendantAdded:Connect(function(Descendant)
               self:RequireModule(Descendant)
          end)

          self.ModuleDirectory.DescendantRemoving:Connect(function(Descendant)
               self:DestroyScripts(Descendant)
          end)
     end
end

function ModuleLoader:Calulate(...)
     local StartTime = tick()
     local EndTime = tick()
     local Format = ("(took %.3f seconds)"):format(EndTime - StartTime)
     self:NewWarn(`>> Loaded Module Took {Format} To Get Every Script {...} <<`)
end

function ModuleLoader:LoadModule()
     local Success, Result = pcall(function()
          return (self or ModuleLoader) and self:RequireDescendants() and self:Start()
     end)
     if Success then
          self:Calulate("Fully Loaded")
     else
          if not Success then
               self:NewWarn("Failed To Run A Module Loader")
          end
     end
end

return function ()
     coroutine.wrap(function()
          ModuleLoader:LoadModule()
     end)()
end
