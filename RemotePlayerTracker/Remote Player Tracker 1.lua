UnityEngine = require("UnityEngine")
CVR = require("CVR")

-- Start is called before the first frame update
function Start()
    TrackerRoot = BoundObjects.TrackerRoot --The object that gets set to the tracked player's position
    Search = BoundObjects.Search -- The object whose forward direction it is searching from
    Animator = BoundObjects.Animator -- The animator for the whole prop, used to lock target
end

-- Function to get the player your gun is aiming at within a N-degree angle
function DistanceSort(a, b)
    return (a.distance < b.distance)
end

function GetTargetedPlayer(position, forward, maxAngle)
    -- Fill own table and sort players by distance from close to far away
    local distanceTable = {}
    for _,v in ipairs(PlayerAPI.AllPlayers) do -- v is the player
        if not v.IsLocal then --This "if" will prevent it from tracking prop spawner, comment out to track yourself
            local playerPoint = (v.GetPosition() + v.GetViewPointPosition()) * 0.5 -- player's center
            local playerDistance = UnityEngine.Vector3.Distance(playerPoint, position)
            table.insert(distanceTable, { player = v, point = playerPoint, distance = playerDistance })
        end
    end
    table.sort(distanceTable, DistanceSort)
    
    local targetedPlayer = false
    for _,v in ipairs(distanceTable) do -- v is the player
        local playerAngle = UnityEngine.Vector3.Angle(forward, v.point - position)
        if(playerAngle <= maxAngle) then -- First nearest player in angle range is what we can get
            targetedPlayer = v.player
            break
        end
    end
    -- Specific case when it can fail: first nearest player is shorter than second nearest player
    return targetedPlayer
end

-- Update is called once per frame
function Update()
    -- Only run every x frames
    if UnityEngine.Time.frameCount % 1 ~= 0 then
        return
    end

    -- Usage
    local gunPosition = BoundObjects.Search.transform.position-- your gun's position
    local gunForward = BoundObjects.Search.transform.forward-- your gun's forward direction (it returns)
    local maxAngle = 25 -- The angle it will use to determine the "cone" shape

    --Set this bool in an animator to make it lock onto the player it is tracking
    -- or comment out to always track just within the "cone"
    if Animator.GetBool("LockPlayer") == false then
        Player = GetTargetedPlayer(gunPosition, gunForward, maxAngle)
    end

    if(Player) then
        --print("Player aimed at: " .. player.Username)
        --print(player.GetPosition().ToString())
        TrackerRoot.transform.position = Player.GetPosition()
    else
        --print("No player within the aiming angle.")
    end
end