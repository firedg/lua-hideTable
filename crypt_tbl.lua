--[[
The MIT License (MIT)

Copyright (c) 2012-2017 codingnow.com

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of
the Software, and to permit persons to whom the Software is furnished to do so,
subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS
FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR
COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER
IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.


1.使用范围:
用于某些数据需要客户端自行保存计算 并且敏感的 Number or string 类型
防止类似于八门神器 烧饼修改器等锁定内存数据进行修改

2.使用影响:
在保存数据的时候使用AES对数据进行加密后存储
秘钥的生成为md5时间戳,时间戳的生成为第一次require时的
由于采用AES加密以及元表代理的形式处理数据 对于数据的读写性能并不优,若不是敏感数据不要用来加密

3.使用方式:
local cryptTbl = require("lib.crypt_tbl")
local attrTbl = cryptTbl.createCtyptTbl()
attrTbl.attack = 100                -- 加密
attrTbl.default = 20                -- 加密
attrTbl.name = "weqwe1"             -- 加密
attrTbl.friendIdList = {}           -- 非加密  错误的使用方式
attrTbl.friendIdList = cryptTbl.createCtyptTbl()           -- 加密
attrTbl.friendIdList[1] = 123123    -- 加密
attrTbl = {}        -- 错误的清空方式
attrTbl = cryptTbl.createCtyptTbl()        -- 正确的清空方式
attrTbl.Func = function(a,b) return a,b end -- 可用 但不会对函数进行加密
attrTbl.Func()                      -- 可用 但不会对函数进行加密

local otherTbl = attrTbl -- 可用
local otherCopyTbl = clone(attrTbl) -- 错误 拿不到正确数据
local otherCopyTbl = copy(attrTbl) -- 错误 拿不到正确数据

4.调试方法
dump - ctyptTbl.__debugRawget(t, dump)

pairs - ctyptTbl.__debugRawget(t, pairs)
for k, v in pairs(ctyptTbl.__debugRawget(t, pairs)) do
    print (k, v)
end
]]

local aeslua = require("lib.aeslua")
local md5 = require("lib.md5")
local ctyptTbl = {}

-- 创建一个加密的table
function ctyptTbl.createCtyptTbl()
    local bcTbl = {}
    local aesTbl = {}
    local cryKey = md5.sumhexa(os.time())
    local mt = {
        __bcTbl = bcTbl,
        __cryKey = cryKey,
        __index = function (t, k)
            if nil == bcTbl[k] then
                return nil
            end
            if bcTbl[k].valueType == "string" then
                return aeslua.decrypt(cryKey, bcTbl[k].value)
            elseif bcTbl[k].valueType == "number" then
                return tonumber(aeslua.decrypt(cryKey, bcTbl[k].value))
            else
                return bcTbl[k].value
            end
        end,

        __newindex = function (t, k, v)
            bcTbl[k] = {
                valueType = type(v)
            }
            local valueType = type(v)
            if valueType == "string" or valueType == "number" then
                bcTbl[k].value = aeslua.encrypt(cryKey, v)
            else
                bcTbl[k].value = v
            end
        end
    }
    setmetatable(aesTbl, mt)
    return aesTbl
end

-- debug调试用接口 支持获取元数据
function ctyptTbl.__debugRawget(t, rawFunc)
    local getValue = function (v)
        local cryKey = getmetatable(t).__cryKey
        if v.valueType == "string" then
            return aeslua.decrypt(cryKey, v.value)
        elseif v.valueType == "number" then
            return tonumber(aeslua.decrypt(cryKey, v.value))
        else
            return v.value
        end
    end
    local tmpTbl = {}
    for k, v in pairs(getmetatable(t).__bcTbl) do
        tmpTbl[k] = getValue(v)
    end
    return rawFunc(tmpTbl)
end
return ctyptTbl