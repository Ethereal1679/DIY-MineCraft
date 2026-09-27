-- 方块世界: offline single-player menu. SPDX-License-Identifier: GPL-3.0-or-later
local E = core.formspec_escape
local root = core.get_user_path()
local game = root .. "/games/mineclonia"
local state = {
 page="home", selected=1, host_selected=1, name="新的世界", seed="",
 creative=false, gen="自然世界", message="",
 host_name="Player", host_port="30000", host_password="",
 join_address="", join_port="30000", join_name="Player", join_password=""
}
local worlds = {}
local profiles = {
 ["柔和光影"]={enable_dynamic_shadows=true,enable_water_reflections=true,enable_bloom=true,enable_volumetric_lighting=true,tone_mapping=true,enable_waving_water=true,enable_waving_leaves=true,enable_waving_plants=true,enable_translucent_foliage=true,viewing_range=128,shadow_map_texture_size=2048,shadow_map_max_distance=100},
 ["高画质"]={enable_dynamic_shadows=true,enable_water_reflections=true,enable_bloom=true,enable_volumetric_lighting=true,tone_mapping=true,enable_waving_water=true,enable_waving_leaves=true,enable_waving_plants=true,enable_translucent_foliage=true,viewing_range=192,shadow_map_texture_size=4096,shadow_map_max_distance=160},
 ["流畅"]={enable_dynamic_shadows=false,enable_water_reflections=false,enable_bloom=false,enable_volumetric_lighting=false,tone_mapping=false,enable_waving_water=false,enable_waving_leaves=false,enable_waving_plants=false,enable_translucent_foliage=false,viewing_range=80,shadow_map_texture_size=1024,shadow_map_max_distance=60},
}
core.set_clouds(true)
core.set_sky_color("#82b5dc")
core.set_clouds_color("#f1f4fa")
local panorama = root .. "/../../src/panorama.png"
local panorama_file=io.open(panorama,"rb")
if panorama_file then panorama_file:close();core.set_background("background", panorama) else core.set_background("overlay", game .. "/menu/overlay.3.png") end
core.set_topleft_text("")
-- Actual upstream texture path varies; use the engine's native raised buttons here.
local function btn(x,y,w,name,label)
 return ("button[%s,%s;%s,0.65;%s;%s]"):format(x,y,w,name,E(label))
end
local function title(text)
 return "hypertext[0,0.15;12,0.8;heading;<global halign=center color=#FFFFFF size=24><b>"..E(text).."</b>]"
end
local function refresh()
 worlds = core.get_worlds()
 state.selected = math.min(math.max(state.selected,1),math.max(#worlds,1))
 state.host_selected = math.min(math.max(state.host_selected,1),math.max(#worlds,1))
 local f="formspec_version[6]size[12,8]padding[0.05,0.05]bgcolor[#111820A0;true]"..
  "style_type[button;bgcolor=#797979;textcolor=#FFFFFF;border=true;font_size=18]"..
  "style_type[field;bgcolor=#191919;textcolor=#FFFFFF]style_type[label;textcolor=#FFFFFF]"
 if state.page=="home" then
  f=f.."hypertext[0,0.8;12,1.7;logo;<global halign=center color=#2b3035 size=58><b>方 块 世 界</b>]"..
   "hypertext[0,0.7;12,1.7;logo2;<global halign=center color=#eeeeee size=58><b>方 块 世 界</b>]"..
   "hypertext[0,2.3;12,0.5;sub;<global halign=center color=#FFE873 size=18>每一个方块，都有新的可能。]"..
   btn(3,3.0,6,"single","单人游戏")..btn(3,3.8,6,"multiplayer","多人游戏")..btn(3,4.6,6,"options","选项…")..btn(3,5.4,6,"help","操作说明")..btn(3,6.2,6,"exit","退出游戏")..
   "label[0,7.7;方块世界 0.1.0 · 离线单机]label[7.3,7.7;Luanti / Mineclonia 开源版]"
 elseif state.page=="multiplayer" then
  f=f..title("多人游戏")..
   btn(2,1.55,8,"host","创建联机世界")..
   btn(2,2.55,8,"join","加入服务器")..
   "textarea[1,4.0;10,1.8;;;"..E("创建联机世界：朋友可以通过局域网地址加入；配置路由器端口转发后，也可以通过公网 IP 或域名加入。\n加入服务器：输入主机地址和端口。默认端口为 UDP 30000。").."]"..
   btn(3,6.8,6,"back","返回")
 elseif state.page=="host" then
  f=f..title("创建联机世界")
  local labels={}
  for _,w in ipairs(worlds) do
   local s=Settings(w.path.."/world.mt")
   labels[#labels+1]=E(w.name .. "  ·  " .. (s:get_bool("creative_mode") and "创造模式" or "生存模式"))
  end
  f=f.."label[0.7,1.05;选择要开放的世界]"..
   "textlist[0.7,1.35;5.0,3.7;hostworlds;"..table.concat(labels,",")..";"..state.host_selected..";false]"..
   "field[6.3,1.45;4.8,0.7;host_name;主机玩家名;"..E(state.host_name).."]field_close_on_enter[host_name;false]"..
   "field[6.3,2.35;4.8,0.7;host_port;端口（UDP）;"..E(state.host_port).."]field_close_on_enter[host_port;false]"..
   "pwdfield[6.3,3.25;4.8,0.7;host_password;主机账号密码]"..
   "textarea[6.3,4.35;4.8,1.3;;;"..E("默认监听 0.0.0.0，局域网和端口转发后的公网连接都可用。\n建议使用非空密码。").."]"..
   btn(0.7,6.7,5.0,"start_host","启动主机并进入")..btn(6.3,6.7,4.8,"back","返回")
 elseif state.page=="join" then
  f=f..title("加入服务器")..
   "field[2.0,1.65;8.0,0.7;join_address;服务器地址（IP 或域名）;"..E(state.join_address).."]field_close_on_enter[join_address;false]"..
   "field[2.0,2.65;8.0,0.7;join_port;端口（UDP）;"..E(state.join_port).."]field_close_on_enter[join_port;false]"..
   "field[2.0,3.65;8.0,0.7;join_name;玩家名;"..E(state.join_name).."]field_close_on_enter[join_name;false]"..
   "pwdfield[2.0,4.65;8.0,0.7;join_password;账号密码]"..
   "textarea[2.0,5.55;8.0,0.8;;;"..E("首次连接时，如果服务器允许注册，可以使用新的账号密码。").."]"..
   btn(2.0,6.8,3.8,"join_server","连接")..btn(6.2,6.8,3.8,"back","返回")
 elseif state.page=="worlds" then
  f=f..title("选择世界")
  local labels={}
  for _,w in ipairs(worlds) do
   local s=Settings(w.path.."/world.mt")
   labels[#labels+1]=E(w.name .. "  ·  " .. (s:get_bool("creative_mode") and "创造模式" or "生存模式"))
  end
  f=f.."textlist[0.7,1.35;10.6,4.6;worlds;"..table.concat(labels,",")..";"..state.selected..";false]"
  if #worlds>0 then f=f..btn(0.7,6.2,5.2,"play","进入选中的世界") end
  f=f..btn(6.1,6.2,5.2,"new","创建新的世界")..btn(0.7,7.1,5.2,"openworlds","打开存档文件夹")..btn(6.1,7.1,5.2,"back","返回")
 elseif state.page=="new" then
  f=f..title("创建新的世界")..
   "field[1.5,1.65;9,0.7;worldname;世界名称;"..E(state.name).."]field_close_on_enter[worldname;false]"..
   "field[1.5,2.9;9,0.7;seed;世界种子（留空为随机）;"..E(state.seed).."]field_close_on_enter[seed;false]"..
   btn(1.5,4.0,9,"mode","游戏模式："..(state.creative and "创造" or "生存"))..
   "hypertext[1.5,4.8;9,0.7;modehelp;<global halign=center color=#dddddd size=15>"..(state.creative and "无限方块 · 自由飞行 · 专心建造" or "采集资源 · 制作工具 · 抵御饥饿和怪物").."]"..
   btn(1.5,5.6,9,"generator","世界类型："..state.gen)..btn(1.5,6.8,4.35,"create","创建世界")..btn(6.15,6.8,4.35,"cancel","取消")
 elseif state.page=="options" then
  f=f..title("选项")..btn(2,1.55,8,"quality","画质："..(core.settings:get("local_quality") or "柔和光影"))..
   btn(2,2.55,8,"range","渲染距离："..(core.settings:get("viewing_range") or "128").." 格")..
   btn(2,3.55,8,"volume","音量："..math.floor(100*(tonumber(core.settings:get("sound_volume")) or 0.6)).."%")..
   btn(2,4.55,8,"fullscreen","全屏："..(core.settings:get_bool("fullscreen") and "开" or "关"))..
   "hypertext[1.5,5.5;9,0.8;tip;<global halign=center color=#dddddd size=15>画质在下次进入世界时应用；全屏在重新启动后应用。\n游戏中按 Esc 可使用引擎完整设置与按键编辑。]"..btn(3,6.8,6,"back","完成")
 elseif state.page=="help" then
  f=f..title("操作说明").."textarea[1,1.3;10,5.4;;;"..E("W A S D：移动    鼠标：视角\n空格：跳跃    Shift：潜行    Ctrl：疾跑\n左键按住：挖掘 / 攻击    右键：放置 / 使用\nE：背包    1–9 / 滚轮：选择快捷栏    Q：丢弃\nF5：切换视角    F2：截图    F3：性能信息    Esc：暂停\n\n生存第一天：砍树 → 原木放进 2×2 合成栏 → 木板 → 工作台。\n右键工作台打开 3×3 合成栏，制作木棍和木镐。\n采石制作熔炉和石器，寻找食物，入夜前建好庇护所。\n背包中的配方书可查合成方法；所有物品来自真实游戏系统。\n\n创造模式：双击空格切换飞行，空格上升，Shift 下降。\n退出时请使用“退出到主菜单”或“退出游戏”，等待存档完成。\n每次关闭游戏后自动备份，保存在项目 backups 文件夹。").."]"..btn(3,6.9,6,"back","返回")
 end
 if state.message~="" then f=f.."hypertext[0,7.85;12,0.45;message;<global halign=center color=#FFD981 size=14>"..E(state.message).."]" end
 if gamedata.errormessage then f=f.."textarea[0.5,0.5;11,6;error;运行错误;"..E(gamedata.errormessage).."]"..btn(3,6.6,6,"clearerror","返回菜单") end
 core.update_formspec(f)
end
local function play(index)
 local w=worlds[index]; if not w then return end
 local s=Settings(w.path.."/world.mt")
 core.settings:set_bool("enable_server",false)
 core.settings:set_bool("server_announce",false)
 core.settings:set_bool("creative_mode",s:get_bool("creative_mode",false))
 core.settings:set_bool("enable_damage",s:get_bool("enable_damage",true))
 core.settings:set("local_last_world",w.name)
 core.settings:set("mainmenu_last_selected_world",tostring(index))
 core.settings:write()
 gamedata.selected_world=index
 gamedata.mode="singleplayer"
 gamedata.address=""
 core.start()
end
local function parse_port(raw)
 local text=tostring(raw or ""):trim()
 if not text:match("^%d+$") then return nil end
 local port=tonumber(text)
 if not port or port<1 or port>65535 then return nil end
 return port
end
local function start_host()
 local w=worlds[state.host_selected]
 local name=tostring(state.host_name or ""):trim()
 local password=tostring(state.host_password or "")
 local port=parse_port(state.host_port)
 if not w then state.message="请先创建至少一个世界。"; return end
 if name=="" or name:find("[%c]") then state.message="请输入有效的主机玩家名。"; return end
 if password=="" then state.message="为了避免公网服务器被滥用，请设置非空账号密码。"; return end
 if not port then state.message="端口必须是 1 到 65535 之间的数字。"; return end
 local s=Settings(w.path.."/world.mt")
 core.settings:set_bool("creative_mode",s:get_bool("creative_mode",false))
 core.settings:set_bool("enable_damage",s:get_bool("enable_damage",true))
 core.settings:set_bool("enable_server",true)
 core.settings:set_bool("server_announce",false)
 core.settings:set("bind_address","0.0.0.0")
 core.settings:set("port",tostring(port))
 core.settings:set("server_name","方块世界多人服务器")
 core.settings:set("motd","方块世界 · 请遵守主机规则")
 core.settings:set_bool("disallow_empty_password",true)
 core.settings:write()
 gamedata.selected_world=state.host_selected
 gamedata.mode="host"
 gamedata.address=""
 gamedata.port=port
 gamedata.playername=name
 gamedata.password=password
 gamedata.allow_login_or_register="any"
 core.start()
end
local function join_server()
 local address=tostring(state.join_address or ""):trim()
 local name=tostring(state.join_name or ""):trim()
 local port=parse_port(state.join_port)
 if address=="" or address:find("[%c%s]") then state.message="请输入有效的服务器 IP 或域名。"; return end
 if name=="" or name:find("[%c]") then state.message="请输入有效的玩家名。"; return end
 if not port then state.message="端口必须是 1 到 65535 之间的数字。"; return end
 core.settings:set_bool("enable_server",false)
 core.settings:set("address",address)
 core.settings:set("remote_port",tostring(port))
 core.settings:write()
 gamedata.selected_world=0
 gamedata.mode="join"
 gamedata.address=address
 gamedata.port=port
 gamedata.playername=name
 gamedata.password=tostring(state.join_password or "")
 gamedata.allow_login_or_register="any"
 core.start()
end
core.button_handler=function(fields)
 state.message=""
 if fields.worldname then state.name=fields.worldname end
 if fields.seed then state.seed=fields.seed end
 if fields.host_name then state.host_name=fields.host_name end
 if fields.host_port then state.host_port=fields.host_port end
 if fields.host_password then state.host_password=fields.host_password end
 if fields.join_address then state.join_address=fields.join_address end
 if fields.join_port then state.join_port=fields.join_port end
 if fields.join_name then state.join_name=fields.join_name end
 if fields.join_password then state.join_password=fields.join_password end
 if fields.exit then core.close(); return end
 if fields.single then state.page="worlds" end
 if fields.multiplayer then state.page="multiplayer" end
 if fields.host then state.page="host"; state.host_selected=state.selected end
 if fields.join then state.page="join" end
 if fields.options then state.page="options" end
 if fields.help then state.page="help" end
 if fields.back then state.page="home" end
 if fields.cancel then state.page="worlds" end
 if fields.new then state.page="new" end
 if fields.hostworlds then local ev=core.explode_textlist_event(fields.hostworlds); state.host_selected=ev.index or state.host_selected end
 if fields.start_host then start_host(); return end
 if fields.join_server then join_server(); return end
 if fields.mode then state.creative=not state.creative end
 if fields.generator then state.gen=state.gen=="自然世界" and "超平坦" or "自然世界" end
 if fields.worlds then local ev=core.explode_textlist_event(fields.worlds); state.selected=ev.index or state.selected; if ev.type=="DCL" then play(state.selected); return end end
 if fields.play then play(state.selected); return end
 if fields.openworlds then core.create_dir(root.."/worlds"); core.open_dir(root.."/worlds") end
 if fields.create then
  local name=state.name:trim()
  if name=="" or name:find('[\\/:*?"<>|%c]') or name=="." or name==".." then state.message="请使用有效的世界名称。"
  else
   local exists=false; for _,w in ipairs(worlds) do if w.name==name then exists=true end end
   if exists then state.message="这个世界名称已存在，请换一个。"
   else
    core.settings:set_bool("creative_mode",state.creative)
    core.settings:set_bool("enable_damage",not state.creative)
    local err=core.create_world(name,"mineclonia",{fixed_map_seed=state.seed,mg_name=state.gen=="超平坦" and "flat" or "v7",mg_flags="caves,dungeons,light,decorations,biomes,ores",mgv7_spflags="mountains,ridges,caverns",mcl_superflat_classic=state.gen=="超平坦" and "true" or "false"})
    if err then state.message=tostring(err) else
     worlds=core.get_worlds()
     for i,w in ipairs(worlds) do if w.name==name then
      local s=Settings(w.path.."/world.mt");s:set_bool("creative_mode",state.creative);s:set_bool("enable_damage",not state.creative);s:set("backend","sqlite3");s:set("player_backend","sqlite3");s:set("auth_backend","sqlite3");s:set("mod_storage_backend","sqlite3");s:write()
      state.selected=i;play(i);return
     end end
    end
   end
  end
 end
 if fields.quality then
  local names={"柔和光影","高画质","流畅"}; local ix=table.indexof(names,core.settings:get("local_quality") or "柔和光影");local name=names[ix%3+1]
  for k,v in pairs(profiles[name]) do core.settings:set(k,tostring(v)) end
  core.settings:set("local_quality",name)
 end
 if fields.range then local n=tonumber(core.settings:get("viewing_range")) or 128;core.settings:set("viewing_range",tostring(n>=192 and 64 or n+32)) end
 if fields.volume then local v=tonumber(core.settings:get("sound_volume")) or 0.6;core.settings:set("sound_volume",tostring(v>=0.99 and 0 or math.min(1,v+0.2))) end
 if fields.fullscreen then core.settings:set_bool("fullscreen",not core.settings:get_bool("fullscreen")) end
 if fields.clearerror then gamedata.errormessage=nil;state.page="home" end
 core.settings:write();refresh()
end
core.event_handler=function(event) if event=="MenuQuit" then if state.page=="home" then core.close() else state.page="home";refresh() end elseif event=="Refresh" then refresh() end end
refresh()
