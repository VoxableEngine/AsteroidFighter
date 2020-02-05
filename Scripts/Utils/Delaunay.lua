
local Class = require("CoreLib.SimpleLuaClasses.Class")

local Edge = require("Utils.Edge")
local Triangle = require("Utils.Triangle")

local Delaunay = Class()

function Delaunay:init(vertices, min, max)
    self.vertices = vertices
    self.triangles = {}
    self.edges = {}

    --local startTime = time:GetSystemTime()

    local range = max - min

    -- find super triangle
    local minX = self.vertices[1].x
    local minY = self.vertices[1].y
    local maxX = minX;
    local maxY = minY;

    for index,vertex in ipairs(self.vertices) do
        if vertex.x < minX then minX = vertex.x end
        if vertex.y < minY then minY = vertex.y end
        if vertex.x > maxX then maxX = vertex.x end
        if vertex.y > maxY then maxY = vertex.y end
    end

    local dx = maxX - minX
    local dy = maxY - minY
    local deltaMax = Max(dx, dy)
    local midX = (minX + maxX) * 0.5
    local midY = (minY + maxY) * 0.5

    local p1 = Vector3(midX - range * deltaMax, midY - deltaMax, 0)
    local p2 = Vector3(midX, midY + range * deltaMax, 0)
    local p3 = Vector3(midX + range * deltaMax, midY - deltaMax, 0)

    table.insert(self.triangles, Triangle(p1, 0, p2, 0, p3, 0))

    for vIndex, vertex in ipairs(self.vertices) do
        local polygon = {}

        -- find bad triangles and add their edges to the polygon data
        for tIndex, tri in ipairs(self.triangles) do
            if tri:CircumCircleContains(vertex) then
                tri.isBad = true
                table.insert(polygon, Edge(tri.a, tri.ai, tri.b, tri.bi))
                table.insert(polygon, Edge(tri.b, tri.bi, tri.c, tri.ci))
                table.insert(polygon, Edge(tri.c, tri.ci, tri.a, tri.ai))
            end
        end

        --remove bad triangles
        for tIndex=#self.triangles, 1, -1 do
            if self.triangles[tIndex].isBad then
                table.remove(self.triangles, tIndex)
            end
        end

        -- find bad edges in polygon data
        for eIndex1=1, #polygon, 1 do
            for eIndex2=eIndex1+1, #polygon, 1 do
                local edge1 = polygon[eIndex1]
                local edge2 = polygon[eIndex2]
                if edge1:Equals(edge2) then
                    edge1.isBad = true
                    edge2.isBad = true
                end
            end
        end

        -- remove bad edges
        for eIndex=#polygon, 1, -1 do
            if polygon[eIndex].isBad then
                table.remove(polygon, eIndex)
            end
        end

        -- add new generated triangles for next iteration that are left
        for eIndex, edge in ipairs(polygon) do
            table.insert(self.triangles, Triangle(edge.v, edge.vi, edge.w, edge.wi, vertex, vIndex))
        end
    end

    --remove triangles that contain super triangle vertices
    -- for tIndex=#self.triangles, 1, -1 do
    --     local tri = self.triangles[tIndex]
    --     local superContained = 0
    --     if tri:ContainsVertex(p1) then superContained = superContained + 1 end
    --     if tri:ContainsVertex(p2) then superContained = superContained + 1 end
    --     if tri:ContainsVertex(p3) then superContained = superContained + 1 end

    --     if superContained > 1 then
    --         table.remove(self.triangles, tIndex)
    --     end
    -- end
    local keptTris = {}
    for tIndex, tri in ipairs(self.triangles) do
        if (tri:ContainsVertex(p1) or tri:ContainsVertex(p2) or tri:ContainsVertex(p3)) == false then
            table.insert(keptTris, tri)
        end
    end
    self.triangles = keptTris

    for tIndex, tri in ipairs(self.triangles) do
        table.insert(self.edges, Edge(tri.a, tri.ai, tri.b, tri.bi))
        table.insert(self.edges, Edge(tri.b, tri.bi, tri.c, tri.ci))
        table.insert(self.edges, Edge(tri.c, tri.ci, tri.a, tri.ai))
    end

    --local endTime = time:GetSystemTime()

    --print("RunTime: " .. (endTime-startTime))
    --print("Vertices: " .. #self.vertices)
    --print("Edges: " .. #self.edges)
    --print("Triangles: " .. #self.triangles)
end

return Delaunay
