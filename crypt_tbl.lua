--[[/*
 * ========================================================================
 *
 *       Filename:  crypt_tbl.lua
 *
 *    Description:  auto hide value table
 *
 *        Created:  2017-11-29
 *
 *         Author:  Elliott    https://github.com/chengdd1987
 *        Company:  https://github.com/firedg
 *
 * ========================================================================
 */]]

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