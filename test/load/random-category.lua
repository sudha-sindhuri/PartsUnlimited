products = { 
    {1,2,3}, -- lighting
    {4,5,6,7,8,9,10}, -- wheels and tires
    {11,12}, -- brakes
    {13,14,15}, -- batteries
    {16,17,18}  -- oil
}
weightedCategory = 3
weightedPercentage = 75
threads = {}

function setup(thread)
    table.insert(threads, thread)
end

function getRandomProduct()
    local catId = weightedCategory
    local randomNum = math.random() * 100
    if weightedCategory == 0 or randomNum > weightedPercentage then catId = math.random(#products) end
    catCounter[catId] = catCounter[catId] + 1
    local category = products[catId]
    return category[math.random(#category)]
end

-- to pass args, use `-- arg1 arg2` at the end of the wrk command
-- e.g. wrk -t1 -c1 -d10 -R10 -s random-category.lua http://localhost:1337 -- arg1 arg2
-- 1st arg is weighted category (1-indexed) [or 0 for none]
-- 2nd arg is weighted percentage
function init(args)
    catCounter = { 0, 0, 0, 0, 0 }
    if #args == 2 then
        weightedCategory = tonumber(args[1])
        weightedPercentage = tonumber(args[2])
    end
    print("using " .. weightedCategory .. " as weighted category")
    print("using " .. weightedPercentage .. " as weighted percentage")

    -- Initialize the pseudo random number generator correctly
    math.randomseed( os.time() )
    math.random(); math.random(); math.random()
end

-- add a random product to the end of the request
request = function()
    local path = wrk.path .. getRandomProduct(weightedCategory, weightedPercentage)
    print(path)
    return wrk.format(wrk.method, path, wrk.headers, wrk.body)
end

done = function()
    -- display the distribution of random requests
    local totalCounter = { 0, 0, 0, 0, 0 }
    local total = 0
    for i, thread in ipairs(threads) do
        local tCatCounter = thread:get("catCounter")
        for i, c in ipairs(tCatCounter) do
            totalCounter[i] = totalCounter[i] + c
            total = total + c
        end
    end

    for i, c in ipairs(totalCounter) do
        percentage = c / total * 100
        print (string.format("Category %d percentage %.2f", i, percentage))
    end
    print "done!"
end