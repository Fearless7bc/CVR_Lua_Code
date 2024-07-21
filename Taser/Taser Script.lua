UnityEngine = require("UnityEngine")
CVR = require "CVR"
-- Start is called before the first frame update
function Start()
    Taser = BoundObjects.Taser
    Target = BoundObjects.Target
    Animator = BoundObjects.Animator
    Spawnable = BoundObjects.Spawnable
end

-- Function to get the player your gun is aiming at within a N-degree angle
function DistanceSort(a, b)
    return (a.distance < b.distance)
end

function GetTargetedPlayer(position, forward, maxAngle)
    -- Fill own table and sort players by distance from close to far away
    local distanceTable = {}
    for _,v in ipairs(PlayerAPI.AllPlayers) do -- v is the player
        --if not v.IsLocal then
            local playerPoint = (v.GetPosition() + v.GetViewPointPosition()) * 0.5 -- player's center
            local playerDistance = UnityEngine.Vector3.Distance(playerPoint, position)
            table.insert(distanceTable, { player = v, point = playerPoint, distance = playerDistance })
        --end
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
    local gunPosition = BoundObjects.Taser.transform.position-- your gun's position
    local gunForward = BoundObjects.Taser.transform.forward-- your gun's forward direction (it returns)
    local maxAngle = 30

    if Animator.GetBool("LockPlayer") == false then
        Player = GetTargetedPlayer(gunPosition, gunForward, maxAngle)
    end

    

    if(Player) then

        PlayerPos = Player.GetPosition()
        PlayerViewPos = Player.GetViewPointPosition()
        PlayerMiddle = (PlayerViewPos.y - PlayerPos.y) / 2
        Target.transform.position = UnityEngine.NewVector3(PlayerPos.x, PlayerPos.y + PlayerMiddle, PlayerPos.z)

        DistanceBetween = UnityEngine.Vector3.Distance(Taser.transform.position, Player.GetPosition())
        MaxRange = 6

        if DistanceBetween <= MaxRange then
            Spawnable.SetValue(1,1)
        else
            Target.transform.position = Taser.transform.position
            Spawnable.SetValue(0,0)
            Spawnable.SetValue(1,0)
            Spawnable.SetValue(2,0)
        end
    else
        --print("No player within the aiming angle.")
        Target.transform.position = Taser.transform.position
        Spawnable.SetValue(0,0)
        Spawnable.SetValue(1,0)
        Spawnable.SetValue(2,0)
    end

end