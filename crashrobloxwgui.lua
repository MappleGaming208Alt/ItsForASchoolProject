-- Create the GUI and the button in the Player's PlayerGui

local player = game.Players.LocalPlayer
local screenGui = Instance.new("ScreenGui")
screenGui.Parent = player:WaitForChild("PlayerGui")

-- Create the button for starting the stress test
local button = Instance.new("TextButton")
button.Size = UDim2.new(0, 200, 0, 50)  -- Size of the button
button.Position = UDim2.new(0.5, -100, 0.5, -25)  -- Centering the button
button.Text = "Start Stress Test"
button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- Black background
button.TextColor3 = Color3.fromRGB(255, 255, 255)  -- White text
button.Font = Enum.Font.SourceSansBold
button.TextSize = 14
button.FontFace = Enum.Font.SourceSansBold
button.Parent = screenGui  -- Add the button to the GUI

-- Hover effect (for mouse users)
button.MouseEnter:Connect(function()
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)  -- Darker color on hover
end)

button.MouseLeave:Connect(function()
    button.BackgroundColor3 = Color3.fromRGB(0, 0, 0)  -- Back to original color
end)

-- Stress test logic
local stressTestActive = false
local memoryTable = {}
local numObjects = 1000000
local cpuThread = nil
local memoryThread = nil

-- Function to simulate extreme CPU load with nested loops and heavy calculations
local function generateCPULoad()
    local counter = 0
    local bigNumber = 10^9
    while stressTestActive do
        -- Complex operations: Fibonacci calculation, sorting large arrays, and more
        local fib = 0
        local a, b = 0, 1
        for i = 1, 50 do  -- Increased Fibonacci loop depth
            fib = a + b
            a = b
            b = fib
        end

        -- Sorting large arrays and matrix multiplication (CPU-intensive tasks)
        local largeArray = {}
        for i = 1, 10000 do
            table.insert(largeArray, math.random(1, 100000))
        end
        table.sort(largeArray)

        -- Complex calculations involving trigonometric and logarithmic functions
        local calc = math.sqrt(math.sin(counter) * math.log(counter + 1) * bigNumber)
        counter = counter + 1
    end
end

-- Function to simulate extreme memory fill with large, nested data structures
local function generateMemoryFill()
    for i = 1, numObjects do
        -- Create a table with deep nesting
        local newObject = {
            id = i,
            value = math.random(1, 100),
            name = "Object_" .. i,
            data = string.rep("a", 1000),  -- Larger strings
            nestedData = {
                subId = i * 2,
                subValue = math.random(100, 200),
                subString = string.rep("b", 5000),
                subNestedData = {
                    extraSubId = i * 3,
                    extraSubValue = math.random(1000, 5000),
                    extraSubString = string.rep("c", 20000)
                }
            }
        }

        -- Add the object to the memory table
        table.insert(memoryTable, newObject)

        -- Randomly add even more large nested data to further consume memory
        if i % 1000 == 0 then
            local additionalObject = {}
            for j = 1, 5000 do
                table.insert(additionalObject, math.random(1, 5000))
            end
            newObject.nestedData.extraData = additionalObject
        end
    end
end

-- Function to create large number of visual elements to increase GPU load
local function generateGPUStress()
    local numElements = 5000  -- Create 5000 dynamic elements (adjust for higher GPU load)
    for i = 1, numElements do
        local box = Instance.new("Frame")
        box.Size = UDim2.new(0, 10, 0, 10)
        box.Position = UDim2.new(math.random(), 0, math.random(), 0)
        box.BackgroundColor3 = Color3.fromRGB(math.random(0, 255), math.random(0, 255), math.random(0, 255))
        box.Parent = screenGui

        -- Move boxes in a continuous loop
        spawn(function()
            while stressTestActive do
                box.Position = UDim2.new(math.random(), 0, math.random(), 0)
                wait(0.01)  -- Move the boxes every 10ms to keep GPU busy
            end
        end)
    end
end

-- Start the extreme stress test (one-way, cannot be turned off)
button.MouseButton1Click:Connect(function()
    if not stressTestActive then
        -- Activate the stress test
        stressTestActive = true
        button.Text = "Stress Test Running..."
        button.Visible = false  -- Hide button after activation

        -- Start Memory Load in a separate thread
        local success, message = pcall(function()
            memoryThread = spawn(function()
                generateMemoryFill()
            end)
        end)
        if not success then
            print("Error during memory generation: " .. message)
        end
        
        -- Start CPU Load in a separate thread
        success, message = pcall(function()
            cpuThread = spawn(function()
                generateCPULoad()
            end)
        end)
        if not success then
            print("Error during CPU load generation: " .. message)
        end
        
        -- Start GPU Load (create visual elements)
        success, message = pcall(function()
            spawn(function()
                generateGPUStress()
            end)
        end)
        if not success then
            print("Error during GPU load generation: " .. message)
        end

        print("Extreme Stress Test started! Memory, CPU, and GPU load are now active.")
    end
end)

-- Optional: Print memory usage status after a delay to track potential memory overflow
spawn(function()
    while true do
        wait(5)  -- Check memory usage every 5 seconds
        local memoryUsed = collectgarbage("count")
        
        -- Print memory usage in KB
        print("Current memory usage: " .. memoryUsed .. " KB")
        
        -- You can add a check to stop stress if memory usage exceeds a threshold
        if memoryUsed > 50000 then  -- Example threshold: 50MB
            print("Warning: Extremely high memory usage detected!")
        end
    end
end)

-- Optional: Check CPU load
spawn(function()
    while true do
        wait(5)  -- Check CPU usage every 5 seconds
        if stressTestActive then
            print("CPU stress test is running...")
        end
    end
end)
