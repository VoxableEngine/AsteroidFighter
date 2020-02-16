
local AsteroidModel = {}

function AsteroidModel.Create(meshData)

    local vertexData = {}
    local lastVertex = 1
    local boundingBox = BoundingBox()
    for vIndex, vertex in ipairs(meshData.vertices) do

        boundingBox:Merge(vertex)

        -- position
        vertexData[lastVertex] = vertex.x
        vertexData[lastVertex+1] = vertex.y
        vertexData[lastVertex+2] = vertex.z

        -- normal
        vertexData[lastVertex+3] = Random(-0.5, 0)
        vertexData[lastVertex+4] = Random(-0.5, 0)
        vertexData[lastVertex+5] = -1

        vertexData[lastVertex+6] = vertex.x
        vertexData[lastVertex+7] = vertex.y

        lastVertex = lastVertex + 8
    end

    local indexData = {}
    local lastIndex = 1
    for tIndex, tri in ipairs(meshData.triangles) do
        indexData[lastIndex] = tri.ai-1
        indexData[lastIndex+1] = tri.bi-1
        indexData[lastIndex+2] = tri.ci-1

        lastIndex = lastIndex + 3
    end

    local numVertices = #meshData.vertices
    local numIndexes = #indexData

    -- Create model, buffers and geometry without garbage collection, as they will be managed
    -- by the StaticModel component once assigned to it
    local fromScratchModel = Model:new()
    local vb = VertexBuffer:new()
    local ib = IndexBuffer:new()
    local geom = Geometry:new()

    -- Shadowed buffer needed for raycasts to work, and so that data can be automatically restored on device loss
    vb.shadowed = true
    -- We could use the "legacy" element bitmask to define elements for more compact code, but let's demonstrate
    -- defining the vertex elements explicitly to allow any element types and order
    local elements = {
        VertexElement(TYPE_VECTOR3, SEM_POSITION),
        VertexElement(TYPE_VECTOR3, SEM_NORMAL),
        VertexElement(TYPE_VECTOR2, SEM_TEXCOORD)
    }
    vb:SetSize(numVertices, elements)

    local temp = VectorBuffer()
    for i = 1, numVertices * 8 do
        temp:WriteFloat(vertexData[i])
    end
    vb:SetData(temp)

    ib.shadowed = true
    ib:SetSize(numIndexes, false)
    temp:Clear()
    for i = 1, numIndexes do
        temp:WriteUShort(indexData[i])
    end
    ib:SetData(temp)

    geom:SetVertexBuffer(0, vb)
    geom:SetIndexBuffer(ib)
    geom:SetDrawRange(TRIANGLE_LIST, 0, numIndexes)

    fromScratchModel.numGeometries = 1
    fromScratchModel:SetGeometry(0, 0, geom)
    fromScratchModel.boundingBox = boundingBox

    -- Though not necessary to render, the vertex & index buffers must be listed in the model so that it can be saved properly
    local vertexBuffers = {}
    local indexBuffers = {}
    table.insert(vertexBuffers, vb)
    table.insert(indexBuffers, ib)
    -- Morph ranges could also be not defined. Here we simply define a zero range (no morphing) for the vertex buffer
    local morphRangeStarts = {}
    local morphRangeCounts = {}
    table.insert(morphRangeStarts, 0)
    table.insert(morphRangeCounts, 0)
    fromScratchModel:SetVertexBuffers(vertexBuffers, morphRangeStarts, morphRangeCounts)
    fromScratchModel:SetIndexBuffers(indexBuffers)

    return fromScratchModel
end

return AsteroidModel
