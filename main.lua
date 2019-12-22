require("vector")
require("mover")

function love.load()
    width = love.graphics.getWidth()
    height = love.graphics.getHeight()

    local location = Vector:create(width / 3, 200)
    local velocity = Vector:create(0, 0)
    rect1 = Mover:create(location, velocity, 100, 100, -45)

    local location = Vector:create(width / 3, height - height / 3)
    local velocity = Vector:create(0, 0)
    ground1 = Mover:create(location, velocity, 200, 50, -25)

    gravity = Vector:create(0, 0.01)
end

function dot(v1, v2)
    return v1.x * v2.x + v1.y * v2.y
end

-- Получение нормалей. DEPRECATED
function getAxis(c1, c2)
    local axisRes = {}

    -- Ось, параллельная верхней части первого объекта
    local v = c1[2]
    v:sub(c1[1])
    v:norm()
    table.insert(axisRes, v)

    -- Ось, параллельная левой части первого объекта
    local v = c1[4]
    v:sub(c1[1])
    v:norm()
    table.insert(axisRes, v)

    -- Ось, параллельная верхней части второго объекта
    local v = c2[2]
    v:sub(c2[1])
    v:norm()
    table.insert(axisRes, v)

    -- Ось, параллельная левой части второго объекта
    local v = c2[4]
    v:sub(c2[1])
    v:norm()
    table.insert(axisRes, v)
    return axisRes
end

-- DEPRECATED
function drawAxis()
    local from = rect1.location
    if (not axis) then
        return 
    end
    r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(1, 0, 1, 1)

    love.graphics.circle("line", from.x, from.y, 50)

    love.graphics.line(from.x, from.y, from.x + axis[1].x * 100, from.y + axis[1].y * 100)
    love.graphics.line(from.x, from.y, from.x + axis[2].x * 100, from.y + axis[2].y * 100)

    local from = ground1.location
    love.graphics.line(from.x, from.y, from.x + axis[3].x * 100, from.y + axis[3].y * 100)
    love.graphics.line(from.x, from.y, from.x + axis[4].x * 100, from.y + axis[4].y * 100)

    love.graphics.setColor(r, g, b, a)
end

function getAxes(angle)
    local arad = math.rad(angle)
    local arad2 = math.rad(angle + 90)
    local res = {
        Vector:create(math.cos(arad), math.sin(arad)),
        Vector:create(math.cos(arad2), math.sin(arad2)),
    }
    return res
end

function collide(m1, m2)
    local c1, c2 = m1:getCorners(), m2:getCorners()
    axis = {}
    table.insert(axis, getAxes(rect1.angle)[1])
    table.insert(axis, getAxes(rect1.angle)[2])
    table.insert(axis, getAxes(ground1.angle)[1])
    table.insert(axis, getAxes(ground1.angle)[2])

    -- minimum translation vectors
    local mtvs = {}
    for i = 1, #axis do
        -- Проекции на оси
        local scalars1, scalars2 = {}, {}
        for k = 1, 4 do
            table.insert(scalars1, dot(axis[i], c1[k]))
            table.insert(scalars2, dot(axis[i], c2[k]))
        end

        local s1max, s1min = math.max(unpack(scalars1)), math.min(unpack(scalars1))
        local s2max, s2min = math.max(unpack(scalars2)), math.min(unpack(scalars2))
        -- io.write(s1min .. " " .. s1max .. " [] " .. s2min .. " " .. s2max)
        -- print()

        if s2min > s1max or s2max < s1min then
            return false, Vector:create(0, 0);
        end

        local overlap = s1max > s2max and -(s2max - s1min) or (s1max - s2min)
        table.insert(mtvs, axis[i] * overlap)
    end

    table.sort(mtvs, function(a, b) return a:mag() < b:mag() end)
    return true, mtvs[1]
end

-- DEPRECATED
function getRotateSide()
    local c1 = rect1:getCorners()

    axis = getAxes(rect1.angle)[1]

    local min = 9999
    local corn = nil
    for k = 1, 4 do
        local d = math.abs(dot(axis, c1[k]))
        if (d < min) then
            min = d
            corn = c1[k]
        end
    end

    return corn
end

function love.update(dt)
    local isColliding, mtv = collide(rect1, ground1)
    if isColliding == true then
       local delta = ground1.angle - rect1.angle
       delta = delta / math.abs(delta)
       rect1.angle = rect1.angle + ground1.angle / 8 
       rect1.velocity = Vector:create(-2 * delta, 1)
    else
        rect1.angle = rect1.angle + ground1.angle / 16 
        rect1:applyForce(gravity)
    end 

    rect1:update();
end


function love.draw()
    rect1:draw()
    ground1:draw();
end

