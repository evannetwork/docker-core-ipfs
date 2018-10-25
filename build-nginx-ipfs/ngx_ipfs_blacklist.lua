local redis_host                 = "172.16.0.5"
local redis_port                 = 6379
local redis_key                  = "ipfs_hash_blacklist"
local hash                       = ngx.var.uri:sub(-46)  -- that's how long ipfs hashes are
local redis_connection_timeout   = 100
local redis_idle_timeout         = 2000
local redis_connection_pool_size = 5

-- every worker thread needs own connection
local red                        = ngx.shared.redis_connections:get(ngx.worker.id())

local redis = require "resty.redis"

if not red then
   red = redis:new()
   red:set_timeout(redis_connection_timeout)
   ngx.shared.redis_connections:add(ngx.worker.id(), red)
end

ok, err = red:connect(redis_host, redis_port)
if not ok then
   ngx.log(ngx.CRIT, "Cannot connect to REDIS: " .. err)
   ngx.exit(ngx.HTTP_FORBIDDEN)
end

local blacklisted = red:sismember(redis_key, hash) == 1
red:set_keepalive(redis_idle_timeout, redis_connection_pool_size)

if blacklisted then
   ngx.log(ngx.INFO, "Blacklisted IPFS Hash requested and denied: " .. hash)
   ngx.exit(ngx.HTTP_GONE)
end


