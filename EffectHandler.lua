local vfxHandler = {}

local replicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

function vfxHandler:PlayEffect(player, remoteName, effectProperties, partToWeld, Offset, EmitBool)
    local effectName = effectProperties.Name
    local effectDuration = effectProperties.Duration or 5  -- Default duration is 5 seconds

    local VFXFolder = replicatedStorage.VFX

    local playerFolder = player:FindFirstChild(effectName)
    if not playerFolder then
        playerFolder = Instance.new("Folder")
        playerFolder.Name = player.Name .. "Folder" .. effectName
        playerFolder.Parent = workspace
        print("Made folder in player")
    end

    local foundVFX

    for i,v in pairs(VFXFolder:GetDescendants()) do
        if v.Name == effectName then
            foundVFX = v
            break
        end
    end

    if foundVFX then
        local VFXClone = foundVFX:Clone()

        if partToWeld and VFXClone:IsA("BasePart") then
            local weld = Instance.new("Weld")
            weld.Part0 = player.Character[partToWeld]
            weld.Part1 = VFXClone
            weld.Parent = VFXClone

            -- Apply the Offset to the VFX
            VFXClone.CFrame = player.Character:FindFirstChild("HumanoidRootPart").CFrame * Offset 
        end

        VFXClone.Parent = playerFolder

        if EmitBool then
            for _, child in pairs(VFXClone:GetDescendants()) do
                if child:IsA("ParticleEmitter") then
                    child.Parent = player.Character:FindFirstChild("HumanoidRootPart")
                    child:Emit(child:GetAttribute("EmitCount"))
                end
            end
        end

        task.delay(effectDuration, function()
            VFXClone:Destroy()
        end)

        local Remotes = replicatedStorage.Remotes
        for _, remote in pairs(Remotes:GetDescendants()) do
            if remote.Name == remoteName and remote:IsA("RemoteEvent") then
                remote:FireAllClients(player, effectName, effectProperties, partToWeld, Offset, EmitBool)
                print("Fired Remote :3")
            end
        end

        return VFXClone
    else
        warn("VFX not found for effect: " .. tostring(effectName))
        return nil
    end
end

return vfxHandler
