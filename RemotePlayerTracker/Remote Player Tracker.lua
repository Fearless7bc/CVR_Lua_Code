UnityEngine = require("UnityEngine")
CVR = require "CVR"

-- Start is called before the first frame update
function Start()
    CurrentPlayers = PlayerAPI.AllPlayers
    TrackerRoot = BoundObjects.TrackerRoot
    Search = BoundObjects.Search
end
-- Function to get the angle between two vectors
function GetAngleBetweenVectors(vec1, vec2)
    local dotProduct = UnityEngine.Vector3.Dot(vec1, vec2)
    local magnitudeProduct = vec1.magnitude * vec2.magnitude
    return math.acos(dotProduct / magnitudeProduct) * (180 / math.pi)
end

-- Function to get the player your gun is aiming at within a 25-degree angle
function GetTargetedPlayer(GunPosition, GunForward, MaxAngle)
    local targetedPlayer = nil
    local players = PlayerAPI.AllPlayers

    for _, player in ipairs(players) do
        --if not player.IsLocal then
            local playerPosition = player.GetPosition()
            local directionToPlayer = (playerPosition - GunPosition).normalized
            local angle = GetAngleBetweenVectors(GunForward, directionToPlayer)

            if angle <= MaxAngle then
                targetedPlayer = player
                break
            end
        --end
    end

    return targetedPlayer
end

-- Update is called once per frame
function Update()
    -- Only run every 200 frames
    if UnityEngine.Time.frameCount % 200 ~= 0 then
        return
    end

    -- Usage
    GunPosition = Search.transform.position-- your gun's position
    GunForward = Search.transform.forward-- your gun's forward direction
    MaxAngle = 25

    local player = GetTargetedPlayer(GunPosition, GunForward, MaxAngle)
    if player then
        print("Player aimed at: " .. player.Username)
    else
        print("No player within the aiming angle.")
    end
end