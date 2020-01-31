
Asteroid = ScriptObject()

function Asteroid:Start()
    -- local numVertices = 3
    -- local numIndexes = 3
    -- local vertexData = {
    --     -- Position          Normal
    --     0.0, -1.5, 0.0,   0.0, 0.0, 1.0,
    --     -1.0, 0.5, 0.0,   0.0, 0.0, 1.0,
    --     1.0, 0.5, 0.0,   0.0, 0.0, 1.0
    -- }

    -- local indexData = {
    --     0, 1, 2
    -- }

    -- -- Create model, buffers and geometry without garbage collection, as they will be managed
    -- -- by the StaticModel component once assigned to it
    -- local fromScratchModel = Model:new()
    -- local vb = VertexBuffer:new()
    -- local ib = IndexBuffer:new()
    -- local geom = Geometry:new()

    -- -- Shadowed buffer needed for raycasts to work, and so that data can be automatically restored on device loss
    -- vb.shadowed = true
    -- -- We could use the "legacy" element bitmask to define elements for more compact code, but let's demonstrate
    -- -- defining the vertex elements explicitly to allow any element types and order
    -- local elements = {
    --     VertexElement(TYPE_VECTOR3, SEM_POSITION),
    --     VertexElement(TYPE_VECTOR3, SEM_NORMAL)
    -- }
    -- vb:SetSize(numVertices, elements)
    -- local temp = VectorBuffer()
    -- for i = 1, numVertices * 6 do
    --     temp:WriteFloat(vertexData[i])
    -- end
    -- vb:SetData(temp)

    -- ib.shadowed = true
    -- ib:SetSize(numVertices, false)
    -- temp:Clear()
    -- for i = 1, numVertices do
    --     temp:WriteUShort(indexData[i])
    -- end
    -- ib:SetData(temp)

    -- geom:SetVertexBuffer(0, vb)
    -- geom:SetIndexBuffer(ib)
    -- geom:SetDrawRange(TRIANGLE_LIST, 0, numVertices)

    -- fromScratchModel.numGeometries = 1
    -- fromScratchModel:SetGeometry(0, 0, geom)
    -- fromScratchModel.boundingBox = BoundingBox(Vector3(-1.0, -1.0, -1.0), Vector3(1.0, 1.0, 1.0))

    -- -- Though not necessary to render, the vertex & index buffers must be listed in the model so that it can be saved properly
    -- local vertexBuffers = {}
    -- local indexBuffers = {}
    -- table.insert(vertexBuffers, vb)
    -- table.insert(indexBuffers, ib)
    -- -- Morph ranges could also be not defined. Here we simply define a zero range (no morphing) for the vertex buffer
    -- local morphRangeStarts = {}
    -- local morphRangeCounts = {}
    -- table.insert(morphRangeStarts, 0)
    -- table.insert(morphRangeCounts, 0)
    -- fromScratchModel:SetVertexBuffers(vertexBuffers, morphRangeStarts, morphRangeCounts)
    -- fromScratchModel:SetIndexBuffers(indexBuffers)

    --local enemyNode = scene_:CreateChild("Enemy")
    --enemyNode.position = Vector3(2.5, 0.0, 0.0)
    --enemyNode.scale = Vector3(0.3, 0.3, 0.3)
    --local enemyModel = enemyNode:CreateComponent("StaticModel")
    --enemyModel.model = fromScratchModel
    --enemyModel.material = cache:GetResource("Material", "Materials/Red.xml")
end


return Asteroid
