```lua

local vfxHandler = {}

local replicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")

function vfxHandler:PlayEffect(effectProperties, partToWeld, EmitBool)
    local effectName = effectProperties.Name
    local effectDuration = effectProperties.Duration or 5  -- Default duration is 5 seconds

    local VFXFolder = replicatedStorage.VFX

    local foundVFX

    for _, v in pairs(VFXFolder:GetDescendants()) do
        if v.Name == effectName then
            foundVFX = v:Clone()
            break
        end
    end

    if foundVFX then
        local VFXFolderClone = Instance.new("Folder")
        VFXFolderClone.Name = player.Name .. "Folder"
        VFXFolderClone.Parent = Workspace

        local function cleanup()
            if VFXFolderClone then
                VFXFolderClone:Destroy()
            end
        end

        -- Connect cleanup function to player's death and character removal
        local connections = {}

        connections[1] = humanoid.Died:Connect(cleanup)
        connections[2] = character.AncestryChanged:Connect(function()
            if not character.Parent then
                cleanup()
            end
        end)

        -- Clone and place each child of the original VFX into VFXFolderClone
        foundVFX.Parent = VFXFolderClone

        -- Weld the cloned child if it's a part and partToWeld is specified
        if partToWeld and foundVFX:IsA("BasePart") then
            local weld = Instance.new("Weld")
            weld.Part0 = character[partToWeld]
            weld.Part1 = foundVFX
            weld.Parent = foundVFX
        end

        -- Start emitting particles if ParticleEmitters are present in VFXFolderClone
        if EmitBool == true then
            for _, child in pairs(VFXFolderClone:GetChildren()) do
                if child:IsA("ParticleEmitter") then
                    -- Attach to the HumanoidRootPart
                    child.Parent = humanoid.Parent:FindFirstChild("HumanoidRootPart") or humanoid.Parent
                    child:Emit(child:GetAttribute("EmitCount"))
                end
            end
        end
        
        task.delay(effectDuration, function()
            VFXFolderClone:Destroy() -- Cleanup the weld and VFX
        end)

        return VFXFolderClone, connections
    else
        warn("VFX not found for effect: " .. tostring(effectName))
        return nil, nil
    end
end

return vfxHandler
```
