-- local handler = require("event_handler")
-- handler.add_lib(require("freeplay"))

-- if script.active_mods["space-age"] then
--   handler.add_lib(require("space-finish-script"))
-- else
--   handler.add_lib(require("silo-script"))
-- end


-- 地图生成
require("script.map_generator")

-- 玩家UI
require("script.player_ui")
