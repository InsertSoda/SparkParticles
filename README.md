# SparkParticles Decal Fork
Fork of SparkParticles that uses decals instead of parts

Example:
```lua
local spark = SparkParticle()
local imageParticle = spark:NewSpark()

imageParticle.Configs = {
    Pivot = script.Parent,
    Lifetime = spark:RandomNumber(1,2),
    Gravity = spark:Vector3Sequence({Vector3.New(0, 0, 0), Vector3.New(1, 0, -1)}),
    ForceForward = spark:NumberSequence({4, 6}),
    AngularVelocity = spark:NumberSequence({0,2}),
    Size = spark:NumberSequence({4, 0}),
    SpawnInterval = 0.25,
    SpeedMultiplier = 2,
    Spread = Vector3.New(90, 90, 90),
    ImageID = 30061,
    ImageType = ImageType.Asset
}

imageParticle:Play()
```
