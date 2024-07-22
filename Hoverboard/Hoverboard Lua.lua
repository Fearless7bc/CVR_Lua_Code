UnityEngine = require("UnityEngine")
CVR = require "CVR"

function Start()
    print("Starting hoverboard raycast")
    RaycastRoot = BoundObjects.RaycastRoot
    RaycastHit = BoundObjects.RaycastHit
    JetboardRoot = BoundObjects.JetboardRoot
    JetboardPhysicsInfluencer = BoundObjects.JetboardPhysicsInfluencer
    FixSteer = BoundObjects.FixSteer
    Animator = BoundObjects.Animator
    Spawnable = gameObject.GetComponentInParent("ABI.CCK.Components.CVRSpawnable")
    IsUsing = false
end

function HoverOn()
    print("Hover on called")
    IsUsing = true
end

function SteerFix()
    print("Fix Steer Called")
    --print(JetboardRoot.transform.eulerAngles.ToString())
    Spawnable.SetValue(3, 1)
    PlayerForward = PlayerAPI.LocalPlayer.GetForward()
    FixSteer.transform.forward = PlayerForward
    --print(FixSteer.transform.eulerAngles.ToString())
    Spawnable.SetValue(3, 2)
end

-- The bit32 is exposed without importing. It's useful to calculate bit operations

-- Calculate the layer mask for Default
local onlyDefaultMask = bit32.lshift(1, CVR.CVRLayers.Default)
-- Calculate the layer mask for Water
local onlyWaterMask = bit32.lshift(1, CVR.CVRLayers.Water)
-- Calculate the layer mask for the remote players
local onlyRemotePlayerMask = bit32.lshift(1, CVR.CVRLayers.PlayerNetwork)

-- Combine both masks into a single one
local onlyDefaultAndWaterMask = bit32.bor(onlyDefaultMask, onlyWaterMask)

-- Define the maximum distance for the raycast
local maxDistance = 7.0

function OnPostLateUpdate()
    if IsUsing == false then
        return
    end
    -- Only raycast every x frames
    if UnityEngine.Time.frameCount % 1 ~= 0 then
        return
    end
    
    -- Rotate the raycast to point "down" for the gravity direction
    RaycastRoot.transform.up = -JetboardPhysicsInfluencer.GetAppliedGravityDirection()

    local origin = RaycastRoot.transform.position
    local forward = RaycastRoot.transform.rotation * -UnityEngine.Vector3.up

    -- Shoot a raycast from the RaycastRoot object, that can hit the layers Default and Water, and hits colliders with IsTrigger enabled
    local hit, hitInfo = UnityEngine.Physics.Raycast(origin, forward, maxDistance, onlyDefaultAndWaterMask, UnityEngine.QueryTriggerInteraction.Collide)
 
    -- Check if the raycast hit something
    if hit == false then
        --print("Raycast failed.")
        -- Set an animator value to know when raycast hit nothing, or is out of range
        Spawnable.SetValue(0, -1)
    end

    if hit == true then
        --print("Raycast hit an object!")

        -- Access the hit information
        local hitPoint = hitInfo.point
        local hitNormal = hitInfo.normal
        local hitDistance = hitInfo.distance
        
        --print("Hit point: " .. hitPoint.ToString() .. " | Hit normal: " .. hitNormal.ToString() .. " | Hit distance: " .. hitDistance)
        -- Setting an object to where the raycast hit, and to normal direction of surface (used for particle effects on ground)
        RaycastHit.transform.position = hitPoint
        RaycastHit.transform.rotation = UnityEngine.Quaternion.Slerp(RaycastHit.transform.rotation, UnityEngine.Quaternion.FromToRotation(UnityEngine.Vector3.up, hitNormal), 0.25)
        --Angle = UnityEngine.Vector3.Angle(hitNormal, JetboardRoot.transform.forward)
        if Animator.GetBool("isVR") == false then
            --JetboardRoot.transform.rotation = UnityEngine.Quaternion.FromToRotation(JetboardRoot.transform.up, hitNormal) * JetboardRoot.transform.rotation;
            -- Used to rotate the hoverboard to raycast normal, for desktop users to go up slopes
            L_target = UnityEngine.Quaternion.FromToRotation(JetboardRoot.transform.up, hitNormal) * JetboardRoot.transform.rotation;
            JetboardRoot.transform.rotation = UnityEngine.Quaternion.Slerp(JetboardRoot.transform.rotation, L_target, UnityEngine.Mathf.Clamp01(15 * UnityEngine.Time.deltaTime));
        end
        -- Set a variable for the animator to know the height, used to adjust phsyics for hover
        Spawnable.SetValue(0, hitDistance)
    end
end
