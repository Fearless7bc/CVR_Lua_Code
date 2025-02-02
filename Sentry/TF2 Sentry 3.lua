UnityEngine = require("UnityEngine")
CVR = require("CVR")

-- Start is called before the first frame update
function Start()
    Sight = BoundObjects.Sight
    Animator = BoundObjects.Animator
    Spawnable = BoundObjects.Spawnable
    Target1 = BoundObjects.Target1
    Target2 = BoundObjects.Target2
    Target3 = BoundObjects.Target3
    RaycastChecker = BoundObjects.RaycastChecker.transform
    SyncAttach = BoundObjects.SyncAttach.Attach()
    MaxRange = 15
    MaxAngle = 40
    TargetSpawner = false
end

-- Function to get the player your gun is aiming at within a N-degree angle
function DistanceSort(a, b)
    return (a.distance < b.distance)
end

function GetTargetedPlayer(position, forward, maxAngle)
    -- Fill own table and sort players by distance from close to far away
    local distanceTable = {}
    for _,v in ipairs(PlayerAPI.AllPlayers) do -- v is the player
        if v.IsLocal == false and TargetSpawner == false then -- Targets remote players only
            local playerPoint = (v.GetPosition() + v.GetViewPointPosition()) * 0.5 -- player's center
            local playerDistance = UnityEngine.Vector3.Distance(playerPoint, position)
            table.insert(distanceTable, { player = v, point = playerPoint, distance = playerDistance })
        elseif TargetSpawner == true then -- Targets
            local playerPoint = (v.GetPosition() + v.GetViewPointPosition()) * 0.5 -- player's center
            local playerDistance = UnityEngine.Vector3.Distance(playerPoint, position)
            table.insert(distanceTable, { player = v, point = playerPoint, distance = playerDistance })
        end
    end
    table.sort(distanceTable, DistanceSort)
    
    local targetedPlayer = false
    for _,v in ipairs(distanceTable) do -- v is the player
        RaycastChecker.transform.rotation = UnityEngine.Quaternion.LookRotation(v.point - RaycastChecker.transform.position)

        local hitInfo = Raycast()
        local playerAngle = UnityEngine.Vector3.Angle(forward, v.point - position)
        if hitInfo == false then --if raycast hits nothing, then nothing between player and turret, return targeted player
            if playerAngle <= maxAngle then
                targetedPlayer = v.player
                return targetedPlayer
            end
            return
        end
        local hitPoint = hitInfo.point
        local distanceRaycastCheck = UnityEngine.Vector3.Distance(RaycastChecker.position, hitPoint)
        local distancePlayer = UnityEngine.Vector3.Distance(RaycastChecker.position, v.player.GetPosition())
        -- Raycast checks if it lands farther than the player, if it does it has LOS. If it lands shorter then it hit a wall.
        if distanceRaycastCheck >= distancePlayer and playerAngle <= maxAngle then
            targetedPlayer = v.player
            return targetedPlayer
        end
    end
end

local onlyDefaultMask = bit32.lshift(1, CVR.CVRLayers.Default)

function Raycast()
    -- Define the maximum distance for the raycast (this should be greater than your max range)
    local maxDistance = MaxRange + 100.0
    local origin = RaycastChecker.position
    local forward = RaycastChecker.rotation * UnityEngine.Vector3.forward
    -- Shoot a raycast from the playe's view point, that can hit the layers Default and remotePlayers, and hits colliders with IsTrigger enabled
    local hit, hitInfo = UnityEngine.Physics.Raycast(origin, forward, maxDistance, onlyDefaultMask, UnityEngine.QueryTriggerInteraction.Ignore)
    -- Check if the raycast hit something
    if hit == false then
        --print("Raycast failed.")
        return hitInfo
    end
    if hit == true then
        --print("Raycast hit an object!")        
        --print("Hit point: " .. hitPoint.ToString() .. " | Hit normal: " .. hitNormal.ToString() .. " | Hit distance: " .. hitDistance)
        return hitInfo
    end
end

-- Update is called once per frame
function Update()
    -- Usage
    local gunPosition = BoundObjects.Sight.transform.position-- your gun's position
    local gunForward = BoundObjects.Sight.transform.forward-- your gun's forward direction (it returns)
    
    Player = GetTargetedPlayer(gunPosition, gunForward, MaxAngle)

    if(Player) then -- If player is returned from GetTargetPlayer function
        local playerPos = Player.GetPosition()
        local playerViewPos = Player.GetViewPointPosition()
        local playerMiddle = (playerViewPos.y - playerPos.y) / 2
        local distanceFrom = UnityEngine.Vector3.Distance(playerPos, Sight.transform.position) -- Distance from turret
        if Animator.GetFloat("State") <= 1 then -- If in search or locked state, target nearest player within LOS
            if distanceFrom <= MaxRange then -- If within range target player
                Spawnable.SetValue(1,1) -- If in range, locks onto player
                Target1.transform.position = UnityEngine.NewVector3(playerPos.x, playerPos.y + playerMiddle, playerPos.z)
                Target2.transform.position = UnityEngine.NewVector3(playerPos.x, playerPos.y + playerMiddle, playerPos.z)
                Target3.transform.position = UnityEngine.NewVector3(playerPos.x, playerPos.y + playerMiddle, playerPos.z)
            else
                Spawnable.SetValue(1,0)-- If out of range, unlocks from player, enters search
            end
        end
        --print("Player aimed at: " .. player.Username)
        --print(player.GetPosition().ToString())
    else
        Spawnable.SetValue(1,0) -- If no player is given, stays in search
        --print("No player within the aiming angle.")
    end
end