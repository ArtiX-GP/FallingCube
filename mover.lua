Mover = {}
Mover.__index = Mover

function Mover:create(location, velocity, width, height, angle)
    local mover = {}
    setmetatable(mover, Mover)
    mover.location = location
    mover.velocity = velocity
    mover.aVelocity = 0
    mover.aAcceleration = 0
    mover.acceleration = Vector:create(0, 0)
    mover.width = width
    mover.height = height
    mover.angle = angle or 0
    mover.active = false

    mover.isFall = false
    return mover
end

function Mover:draw()
    love.graphics.push()
    love.graphics.translate(self.location.x, self.location.y)
    love.graphics.rotate(math.rad(self.angle))
    
    r, g, b, a = love.graphics.getColor()
    
    love.graphics.rectangle("fill", -self.width / 2, -self.height / 2, self.width, self.height)

    
    love.graphics.pop()

    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.circle("fill", self.location.x, self.location.y, 10)

    love.graphics.setColor(0, 1, 0, 1)
    -- local points = self:getCorners()
    -- if (#points > 0) then
    --     love.graphics.line(self.location.x, self.location.y, points[1].x, points[1].y)
    --     love.graphics.line(self.location.x, self.location.y, points[2].x, points[2].y)
    --     love.graphics.line(self.location.x, self.location.y, points[3].x, points[3].y)
    --     love.graphics.line(self.location.x, self.location.y, points[4].x, points[4].y)
    -- end

    love.graphics.setColor(r, g, b, a)

end

function Mover:applyForce(force)
    self.acceleration:add(force)
end

function Mover:getCorners()
    local corners = {}
    local rot = math.rad(self.angle)
    local center = self.location
    local points = {
        Vector:create(self.location.x - self.width / 2, self.location.y - self.height / 2), -- Левый верхний
        Vector:create(self.location.x + self.width / 2, self.location.y - self.height / 2), -- Правый верхний
        Vector:create(self.location.x + self.width / 2, self.location.y + self.height / 2), -- Правый нижний
        Vector:create(self.location.x - self.width / 2, self.location.y + self.height / 2) -- Левый нижний
    }

    for i, corner in ipairs(points) do
        local x = center.x + (corner.x - center.x) * math.cos(rot) - (corner.y - center.y) * math.sin(rot)
        local y = center.y + (corner.x - center.x) * math.sin(rot) + (corner.y - center.y) * math.cos(rot)
        corners[i] = Vector:create(x, y)
    end

    return corners
end

-- DEPRECATED
function Mover:getDownCorn()
    local cors = self:getCorners()

    local min = 9999
    local cor = nil

    for i = 1, #cors do
        if cors[i].y < min then
            cor = cors[i]
        end
    end

    return cor
end

-- DEPRECATED
function Mover:rotateAfterFall(ground)
    if (self.isFall == true) then
        return
    end

    self.velocity = Vector:create(0, 0)

    print("Diff: " .. (self.angle - ground.angle))
    local haed = getRotateSide():heading()
    print("Corn:" .. math.deg(haed))
    print(self.location)
    print(getRotateSide())

    local v = (self.location - getRotateSide())
    v:norm()
    print(v)
    -- self.angle = self.angle +  getRotateSide()
    -- self.angle = rect1.angle - ground.angle

    self.isFall = true
end

function Mover:checkBoundaries()
    if self.location.x < 0 then
        self.location.x = width
    end
    if self.location.x > width then
        self.location.x = 0
    end
    if self.location.y < 0 then
        self.location.y = height
    end
    if self.location.y > height then
        self.location.y = 0
    end
end

function Mover:update()
    self.velocity = self.velocity + self.acceleration
    self.location = self.location + self.velocity
    self.acceleration:mul(0)
end

