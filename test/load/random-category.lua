-- Lighting [1..3]
-- wheels and tires [4..10]
-- brakes [11..12]
-- batteries [13..15]
-- oil [16..18]

products = { {1,2,3}, {4,5,6,7,8,9,10}, {11,12}, {13,14,15}, {16,17,18} }
weightedCategory = 3
weightedPercentage = 75

-- to pass args, use `-- arg1 arg2` at the end of the wrk command
-- e.g. wrk -t1 -c1 -d10 -R10 -s random-category.lua http://localhost:1337 -- arg1 arg2
-- 1st arg is weighted category (or -1 for none)
-- 2nd arg is weighted percentage
function init(args) 
    if table.getn(args) == 2 then
        weightedCategory = tonumber(args[1])
        weightedPercentage = tonumber(args[2])
    end
    print("using " .. weightedCategory .. " as weighted category")
    print("using " .. weightedPercentage .. " as weighted percentage")
end

function getRandomProduct()
    local catId = weightedCategory
    if weightedCategory == -1 or math.random() * 100 < weightedPercentage then catId = math.random(table.getn(products)) end
    return products[catId][math.random(table.getn(products[catId]))]
end

-- add a random product to the end of the request
request = function()
    local path = wrk.path .. getRandomProduct(weightedCategory, weightedPercentage)
    -- print(path)
    return wrk.format(wrk.method, path, wrk.headers, wrk.body)
end