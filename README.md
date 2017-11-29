# lua-hideTable
## 使用范围:
用于某些数据需要客户端自行保存计算 并且敏感的 Number or string 类型
防止类似于八门神器 烧饼修改器等锁定内存数据进行修改

## 使用影响:
在保存数据的时候使用AES对数据进行加密后存储
秘钥的生成为md5时间戳,时间戳的生成为第一次require时的
由于采用AES加密以及元表代理的形式处理数据 对于数据的读写性能并不优,若不是敏感数据不要用来加密

## 使用方式:
```
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
local otherCopyTbl = copy(attrTbl) -- 错误 拿不到正确数据``
```
## 调试方法
dump - ctyptTbl.__debugRawget(t, dump)
pairs - ctyptTbl.__debugRawget(t, pairs)
for k, v in pairs(ctyptTbl.__debugRawget(t, pairs)) do
    print (k, v)
end
