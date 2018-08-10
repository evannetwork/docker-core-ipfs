--[[
  Copyright (C) 2018-present evan GmbH. 
  
  This program is free software: you can redistribute it and/or modify it
  under the terms of the GNU Affero General Public License, version 3, 
  as published by the Free Software Foundation. 
  
  This program is distributed in the hope that it will be useful, 
  but WITHOUT ANY WARRANTY; without even the implied warranty of 
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
  See the GNU Affero General Public License for more details. 
  
  You should have received a copy of the GNU Affero General Public License along with this program.
  If not, see http://www.gnu.org/licenses/ or write to the
  
  Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA, 02110-1301 USA,
  
  or download the license from the following URL: https://evan.network/license/ 
  
  You can be released from the requirements of the GNU Affero General Public License
  by purchasing a commercial license.
  Buying such a license is mandatory as soon as you use this software or parts of it
  on other blockchains than evan.network. 
  
  For more information, please contact evan GmbH at this address: https://evan.network/license/ 
]]--

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


