
local kUpVector = Vector(0, 1, 0)
local kCheckDistance = 0.8 -- bigger than onos
local kVerticalOffset = 0.3
local kVerticalSpace = 2

local kCheckDirections =
{
    Vector(kCheckDistance, 0, -kCheckDistance),
    Vector(kCheckDistance, 0, kCheckDistance),
    Vector(-kCheckDistance, 0, kCheckDistance),
    Vector(-kCheckDistance, 0, -kCheckDistance),
}

function GorgeTunnelAbility:GetDropRange()
    return 1.5
end

local kExtents = Vector(0.4, 0.5, 0.4) -- 0.5 to account for pathing being too high/too low making it hard to palce tunnels
local function IsPathable(position)
    local noBuild = Pathing.GetIsFlagSet(position, kExtents, Pathing.PolyFlag_NoBuild)
    local walk = Pathing.GetIsFlagSet(position, kExtents, Pathing.PolyFlag_Walk)
    return not noBuild and walk
end

local orig_GorgeTunnelAbility_GetIsPositionValid
orig_GorgeTunnelAbility_GetIsPositionValid = Class_ReplaceMethod("GorgeTunnelAbility", "GetIsPositionValid",
function (self, position, player, surfaceNormal)
    local valid = false

    --/ allow only on even surfaces
    if surfaceNormal then
        if surfaceNormal:DotProduct(kUpVector) > 0.9 then
            valid = true
            local startPos = position + Vector(0, kVerticalOffset, 0)
            for i = 1, #kCheckDirections do
                local traceStart = startPos + kCheckDirections[i]
                local trace = Shared.TraceRay(traceStart, traceStart - Vector(0, kVerticalOffset + 0.1, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, EntityFilterOneAndIsa(player, "Babbler"))

                if not IsPathable(position) then
                    valid = false
                end

                if trace.surface == "tunnel_allowed" then
                    valid = true
                end

                if trace.fraction < 0.55 or trace.fraction >= 1.0 then --the max splope a tunnel can be placed on. Previously 0.65, lowered to make it easier to place tunnels in places like Cave
                    valid = false
                    break
                end
            end
        end
    end

    -- check also if there is enough place above
    if valid then
        local extents = Vector(kCheckDistance, 0.5, kCheckDistance)
        local trace =  Shared.TraceBox(extents, position + Vector(0, 0.2, 0), position + Vector(0, kVerticalSpace, 0), CollisionRep.Move, PhysicsMask.Movement, EntityFilterAll())
        valid = valid and trace.fraction == 1
    end

    return valid
end)

