function SparkParticle()
    local rlib = {}
  
    local function NewEmitter()
        local tab = {
            Connections = {}
        }
        function tab:Connect(callback)
            tab.Connections[callback] = true
        end
        function tab:Disconnect(callback)
            tab.Connections[callback] = false
        end
        function tab:InvokeEvent()
            for k,v in pairs(tab.Connections) do
                if v then
                    k()
                end
            end
        end
        return tab
    end
    
    function rlib:NumberSequence(data)
        local lib = {}
    
        local points = data
    
        function lib:GetVal(t)
            if t <= 0 then
                return points[1]
            elseif t >= 1 then
                return points[#points]
            end
        
            local segmentIndex = math.floor(t * (#points - 1)) + 1
            local segmentT = t * (#points - 1) - segmentIndex + 1
        
            local startPoint = points[segmentIndex]
            local endPoint = points[segmentIndex + 1]
        
            return startPoint + (endPoint - startPoint) * segmentT
        end
    
        return lib
    end

    function rlib:Vector3Sequence(data)
        local lib = {
            data = {}
        }
    
        lib.data = data
    
        function LoadVectorChannels()
            lib.points = {
                x = {},
                y = {},
                z = {},
            }
            for _,v in pairs(lib.data) do
                table.insert(lib.points.x, v.x)
                table.insert(lib.points.y, v.y)
                table.insert(lib.points.z, v.z)
            end
        end
    
        LoadVectorChannels()
    
        function lib:GetVal(t)
            return Vector3.New(
                rlib:NumberSequence(lib.points.x):GetVal(t),
                rlib:NumberSequence(lib.points.y):GetVal(t),
                rlib:NumberSequence(lib.points.z):GetVal(t)
            )
        end
    
        return lib
    end

    function rlib:RandomNumber(min, max)
        local lib = {}
    
        function lib:GetVal(t)
            return math.random(min * 100, max * 100) / 100
        end
    
        return lib
    end

    local function GetValOfVai(v, ti)
        if type(v) == "number" or (type(v) == "userdata") then
            return v
        else
            return v:GetVal(ti)
        end
    end

    if not game['Environment'].Shared['SparkLog'] then
        game['Environment'].Shared['SparkLog'] = true
        print("\tSpark Particle v1")
        print("\tby devynawy")
    end

    function rlib:NewSpark()
        local mlib = {
            Configs = {}
        }
        local running = false

        local partCache = {}
        local function getPart()
            for i,v in pairs(partCache) do
                if v == true then
                    partCache[i] = false
                    return i
                end
            end

            local pa = Instance.New("Text3D")
            pa.Text = ""
            pa.FaceCamera = true
            local decal = Instance.New("Decal")
            decal.Name = "Image"
            decal.ImageID = mlib.Configs.ImageID
            decal.ImageType = mlib.Configs.ImageType or ImageType.Asset
            decal.Parent = pa
            partCache[pa] = false
            return pa
        end

        local function returnPart(pa)
            pa.Size = Vector3.New(0, 0, 0)
            partCache[pa] = true
        end

        mlib.BeforeCreate = NewEmitter()

        local function CreateParticle()
            spawn(function()
                local p = getPart()
                p["Image"].Size = Vector3.New(0, 0, 0)
                p.Position = mlib.Configs.Pivot.Position
                p.Rotation = mlib.Configs.Pivot.Rotation + Vector3.New(
                    math.random(mlib.Configs.Spread.x * -1, mlib.Configs.Spread.x),
                    math.random(mlib.Configs.Spread.y * -1, mlib.Configs.Spread.y),
                    math.random(mlib.Configs.Spread.z * -1, mlib.Configs.Spread.z)
                )
            
                local ti = 0
                local tiNz = 0
                local curSpeed = 1
                local gravi = Vector3.New(0, 0, 0)
                local lifetime = GetValOfVai(mlib.Configs.Lifetime, 0)
            
                local function updateParticle(deltaTime)
                    ti = ti + deltaTime
                    tiNzStatic = (ti / lifetime)

                    curSpeed = GetValOfVai(mlib.Configs.SpeedMultiplier, tiNzStatic)
                    tiNz = (ti / lifetime) * curSpeed
                
                    local scaleL = GetValOfVai(mlib.Configs.Size, tiNz)
                    gravi = gravi + (GetValOfVai(mlib.Configs.Gravity, tiNz) * (curSpeed * deltaTime)) / 4
                    p.Position = p.Position + (p.Forward * (GetValOfVai(mlib.Configs.ForceForward, tiNz) * deltaTime) * curSpeed) + gravi
                    p["Image"].LocalRotation = p["Image"].LocalRotation + Vector3.New(0,0, GetValOfVai(mlib.Configs.AngularVelocity, tiNz) * deltaTime * curSpeed)
                    p["Image"].Size = Vector3.New(scaleL, scaleL, scaleL)
                
                    if ti >= lifetime then
                        game.Rendered:Disconnect(updateParticle)
                        returnPart(p)
                    end
                end
            
                game.Rendered:Connect(updateParticle)
            end)
        end

        function mlib:Play()
            running = true
            spawn(function()
                while running do
                    mlib.BeforeCreate:InvokeEvent()
                    CreateParticle()
                
                    wait(mlib.Configs.SpawnInterval)
                end
            end)
        end

        function mlib:Stop()
            running = false
        end

        function mlib:DisposeCache()
            for i,v in pairs(partCache) do
                v:Destroy()
            end
            partCache = {}
        end

        function mlib:Emit(amount)
            mlib.BeforeCreate:InvokeEvent()

            for i = 1, amount do
                CreateParticle()
            end
        end

        return mlib
    end

    return rlib
end
