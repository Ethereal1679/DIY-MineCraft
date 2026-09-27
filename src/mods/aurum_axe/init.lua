-- 奥金之斧：使用木斧配方，保留斧头伐木能力，但拥有极高的近战伤害。
-- SPDX-License-Identifier: GPL-3.0-or-later

local item_name = "aurum_axe:axe"

core.register_tool(item_name, {
	description = "奥金之斧",
	inventory_image = "default_tool_goldaxe.png",
	groups = {
		axe = 1,
		tool = 1,
		dig_speed_class = 2,
		enchantability = 15,
		offhand_item = 1,
	},
	tool_capabilities = {
		full_punch_interval = 1.25,
		max_drop_level = 1,
		punch_attack_uses = 30,
		damage_groups = { fleshy = 500 },
	},
	_mcl_diggroups = {
		axey = { speed = 2, level = 1, uses = 30 },
	},
	_mcl_toollike_wield = true,
	_repair_material = "group:wood",
	_doc_items_longdesc = "奥金之斧可以砍伐木制方块，也能造成 500 点近战伤害。",
	_doc_items_usagehelp = "手持奥金之斧左键攻击或砍伐方块；右键可以执行普通斧头操作。",
	on_place = mcl_tools.get_default_tool_place_func("axe"),
	sound = { breaks = "default_tool_breaks" },
	wield_scale = mcl_vars.tool_wield_scale,
	_placement_def = "placeable_on_actionable",
})

-- 与木斧相同的两种镜像配方：两块木材、两根木棍。
core.register_craft({
	output = item_name,
	recipe = {
		{ "group:wood", "group:wood" },
		{ "mcl_core:stick", "" },
		{ "mcl_core:stick", "" },
	},
})

core.register_craft({
	output = item_name,
	recipe = {
		{ "group:wood", "group:wood" },
		{ "", "mcl_core:stick" },
		{ "", "mcl_core:stick" },
	},
})
