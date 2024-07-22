-- Import necessary UnityEngine components
UnityEngine = require "UnityEngine"
local CVR   = require "CVR"

function Start()
    print("Starting the ViewPointRaycast example!")
    RaycastObjectTransform = BoundObjects.RaycastObject.transform
    HeadAttachTransform = BoundObjects.HeadAttach.transform
end

-- The bit32 is exposed without importing. It's useful to calculate bit operations

-- Calculate the layer mask for the default layer
local onlyDefaultMask = bit32.lshift(1, CVR.CVRLayers.Default)

-- Calculate the layer mask for the remote players
local onlyRemotePlayerMask = bit32.lshift(1, CVR.CVRLayers.PlayerNetwork)

-- Combine both masks into a single one
local onlyDefaultAndRemotePlayerMask = bit32.bor(onlyDefaultMask, onlyRemotePlayerMask)

-- Define the maximum distance for the raycast
local maxDistance = 100.0

function OnPostLateUpdate()

    -- Only raycast every x frames
    if UnityEngine.Time.frameCount % 10 ~= 0 then
        return
    end
    
    -- Get the position of the local player view point (this setup has mixed results for rotation of raycast)
    --local origin = PlayerAPI.LocalPlayer.GetViewPointPosition()
    -- Convert rotation to a forward direction vector
    --local forward = PlayerAPI.LocalPlayer.GetViewPointRotation() * UnityEngine.Vector3.forward

    -- Attaching the object the raycast comes from, to the head, results in consistent raycast direction
    local origin = HeadAttachTransform.position
    local forward = HeadAttachTransform.rotation * UnityEngine.Vector3.forward

    -- Shoot a raycast from the playe's view point, that can hit the layers Default and remotePlayers, and hits colliders with IsTrigger enabled
    local hit, hitInfo = UnityEngine.Physics.Raycast(origin, forward, maxDistance, onlyDefaultAndRemotePlayerMask, UnityEngine.QueryTriggerInteraction.Collide)
 
    -- Check if the raycast hit something
    if hit == false then
        print("Raycast failed.")
    end
    if hit == true then

        print("Raycast hit an object!")

        -- Access the hit information
        local hitPoint = hitInfo.point
        local hitNormal = hitInfo.normal
        local hitDistance = hitInfo.distance

        print("Hit point: " .. hitPoint.ToString() .. " | Hit normal: " .. hitNormal.ToString() .. " | Hit distance: " .. hitDistance)
        RaycastObjectTransform.position = hitPoint
    end
end
