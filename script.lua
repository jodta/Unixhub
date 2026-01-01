local Config = {
	MaxRootTables = 2000,
	MaxSubTables = 100,
	MaxStringSize = 1024 * 4,
	SpawnRate = 0.02,
	MaxCoroutines = 200,
	RampMultiplier = 1.05,
	EnableCycles = true,
	EnableRetention = true,
	EnableThreadSpam = true,
	RuntimeSeconds = 300
}

local roots = {}
local threads = {}
local startTime = os.clock()
local ramp = 1

-- Utility
local function clamp(n, max)
	if n > max then return max end
	return n
end

local function makeString(size)
	return ("X"):rep(size)
end

local function makeTable(depth, size)
	local t = {}
	for i = 1, depth do
		t[i] = makeString(size)
	end
	return t
end

local function makeCyclicTable(depth, size)
	local t = makeTable(depth, size)
	if Config.EnableCycles then
		t.self = t
	end
	return t
end

local function memoryPhase()
	while os.clock() - startTime < Config.RuntimeSeconds do
		local block = {}

		for i = 1, clamp(ramp, Config.MaxSubTables) do
			block[i] = makeCyclicTable(i, clamp(Config.MaxStringSize * ramp, Config.MaxStringSize))
		end

		if Config.EnableRetention then
			roots[#roots + 1] = block
			if #roots > Config.MaxRootTables then
				table.remove(roots, 1)
			end
		end

		ramp *= Config.RampMultiplier
		task.wait(Config.SpawnRate)
	end
end

local function gcPhase()
	while os.clock() - startTime < Config.RuntimeSeconds do
		local tmp = {}
		for i = 1, 500 do
			tmp[i] = tostring(i) .. tostring(os.clock())
		end
		task.wait()
	end
end

local function spawnPhase()
	while os.clock() - startTime < Config.RuntimeSeconds do
		if #threads < Config.MaxCoroutines and Config.EnableThreadSpam then
			local th = task.spawn(function()
				while true do
					local t = {}
					for i = 1, 100 do
						t[i] = makeString(256)
					end
					task.wait()
				end
			end)
			threads[#threads + 1] = th
		end
		task.wait(0.1)
	end
end

local function depthPhase()
	while os.clock() - startTime < Config.RuntimeSeconds do
		local root = {}
		local current = root
		for i = 1, 200 do
			current.next = {}
			current = current.next
		end
		task.wait()
	end
end

task.spawn(memoryPhase)
task.spawn(gcPhase)
task.spawn(spawnPhase)
task.spawn(depthPhase)

task.spawn(function()
	while os.clock() - startTime < Config.RuntimeSeconds do
		print(
			"[STRESS]",
			"Roots:", #roots,
			"Threads:", #threads,
			"Ramp:", math.floor(ramp)
		)
		task.wait(5)
	end
	print("Stress test completed")
end)
