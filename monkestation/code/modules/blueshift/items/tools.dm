// Like the power drill, except no speed buff but has wirecutters as well? Just trust me on this one.

/obj/item/screwdriver/omni_drill
	name = "powered driver"
	desc = "The ultimate in multi purpose construction tools. With heads for wire cutting, bolt driving, and driving \
		screws, what's not to love? Well, the slow speed. Compared to other power drills these tend to be \
		<b>not much quicker than unpowered tools</b>."
	icon = 'monkestation/code/modules/blueshift/icons/tools.dmi'
	icon_state = "drill"
	belt_icon_state = null
	inhand_icon_state = "drill"
	worn_icon_state = "drill"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.75,
		/datum/material/silver = HALF_SHEET_MATERIAL_AMOUNT * 1.5,
		/datum/material/titanium = HALF_SHEET_MATERIAL_AMOUNT,
	)
	force = 10
	throwforce = 8
	throw_speed = 2
	throw_range = 3
	attack_verb_continuous = list("drills", "screws", "jabs", "whacks")
	attack_verb_simple = list("drill", "screw", "jab", "whack")
	hitsound = 'sound/items/drill_hit.ogg'
	usesound = 'sound/items/drill_use.ogg'
	w_class = WEIGHT_CLASS_SMALL
	toolspeed = 1
	random_color = FALSE
	greyscale_config = null
	greyscale_config_belt = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	/// Used on Initialize, how much time to cut cable restraints and zipties.
	var/snap_time_weak_handcuffs = 0 SECONDS
	/// Used on Initialize, how much time to cut real handcuffs. Null means it can't.
	var/snap_time_strong_handcuffs = null

/obj/item/screwdriver/omni_drill/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)

/obj/item/screwdriver/omni_drill/get_all_tool_behaviours()
	return list(TOOL_WIRECUTTER, TOOL_SCREWDRIVER, TOOL_WRENCH)

/obj/item/screwdriver/omni_drill/examine(mob/user)
	. = ..()
	. += span_notice("Use <b>in hand</b> to switch configuration.\n")
	. += span_notice("It functions as a <b>[tool_behaviour]</b> tool.")

/obj/item/screwdriver/omni_drill/update_icon_state()
	. = ..()
	switch(tool_behaviour)
		if(TOOL_SCREWDRIVER)
			icon_state = initial(icon_state)
		if(TOOL_WRENCH)
			icon_state = "[initial(icon_state)]_bolt"
		if(TOOL_WIRECUTTER)
			icon_state = "[initial(icon_state)]_cut"

/obj/item/screwdriver/omni_drill/attack_self(mob/user, modifiers)
	. = ..()
	if(!user)
		return
	var/list/tool_list = list(
		"Screwdriver" = image(icon = icon, icon_state = "drill"),
		"Wrench" = image(icon = icon, icon_state = "drill_bolt"),
		"Wirecutters" = image(icon = icon, icon_state = "drill_cut"),
	)
	var/tool_result = show_radial_menu(user, src, tool_list, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user) || !tool_result)
		return
	RemoveElement(/datum/element/cuffsnapping, snap_time_weak_handcuffs, snap_time_strong_handcuffs)
	switch(tool_result)
		if("Wrench")
			tool_behaviour = TOOL_WRENCH
			sharpness = NONE
		if("Wirecutters")
			tool_behaviour = TOOL_WIRECUTTER
			sharpness = NONE
			AddElement(/datum/element/cuffsnapping, snap_time_weak_handcuffs, snap_time_strong_handcuffs)
		if("Screwdriver")
			tool_behaviour = TOOL_SCREWDRIVER
			sharpness = SHARP_POINTY
	playsound(src, 'sound/items/change_drill.ogg', 50, vary = TRUE)
	update_appearance(UPDATE_ICON)

/obj/item/screwdriver/omni_drill/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

// Just a completely normal crowbar except it's bulky sized and can force doors like jaws of life can.

/obj/item/crowbar/large/doorforcer
	name = "prybar"
	desc = "A large, sturdy crowbar, painted orange. This one just happens to be tough enough to \
		survive <b>forcing doors open</b>."
	icon = 'monkestation/code/modules/blueshift/icons/tools.dmi'
	icon_state = "prybar"
	toolspeed = 1.3
	w_class = WEIGHT_CLASS_BULKY
	force_opens = TRUE
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.75,
		/datum/material/titanium = HALF_SHEET_MATERIAL_AMOUNT,
	)

/obj/item/crowbar/large/doorforcer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)

// Backpackable mining drill

/obj/item/pickaxe/drill/compact
	name = "compact mining drill"
	desc = "A powered mining drill, it drills all over the place. Compact enough to hopefully fit in a backpack."
	icon = 'monkestation/code/modules/blueshift/icons/tools.dmi'
	icon_state = "drilla"
	worn_icon_state = "drill"
	w_class = WEIGHT_CLASS_NORMAL
	toolspeed = 0.6
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/glass = HALF_SHEET_MATERIAL_AMOUNT,
	)

/obj/item/pickaxe/drill/compact/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)

// Electric welder but not quite as strong

/obj/item/weldingtool/electric/arc_welder
	name = "arc welding tool"
	desc = "A specialized welding tool utilizing high powered arcs of electricity to weld things together. \
		Compared to other electrically-powered welders, this model is slow and highly power inefficient, \
		but it still gets the job done and chances are you printed this bad boy off for free."
	icon = 'monkestation/code/modules/blueshift/icons/tools.dmi'
	icon_state = "arc_welder"
	usesound = 'monkestation/code/modules/blueshift/sounds/arc_welder/arc_welder.ogg'
	light_outer_range = 2
	light_power = 0.75
	toolspeed = 1
	power_use_amount = 100

/obj/item/weldingtool/electric/arc_welder/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)

/obj/item/weldingtool/electric
	name = "electrical welding tool"
	desc = "An experimental welding tool capable of welding functionality through the use of electricity. The flame seems almost cold."
	icon = 'monkestation/code/modules/blueshift/icons/tools.dmi'
	icon_state = "arc_welder"
	light_power = 1
	light_color = LIGHT_COLOR_HALOGEN
	tool_behaviour = NONE
	toolspeed = 0.2
	power_use_amount = 25
	// We don't use fuel
	change_icons = FALSE
	var/cell_override = /obj/item/stock_parts/cell/high
	var/powered = FALSE
	max_fuel = 20

/obj/item/weldingtool/electric/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cell, cell_override, CALLBACK(src, PROC_REF(switched_off)))

/obj/item/weldingtool/electric/attack_self(mob/user, modifiers)
	. = ..()
	if(!powered)
		if(!(item_use_power(power_use_amount, user, TRUE) & COMPONENT_POWER_SUCCESS))
			return
	powered = !powered
	playsound(src, 'sound/effects/sparks4.ogg', 100, TRUE)
	if(powered)
		to_chat(user, span_notice("You turn [src] on."))
		switched_on()
		return
	to_chat(user, span_notice("You turn [src] off."))
	switched_off()

/obj/item/weldingtool/electric/switched_on(mob/user)
	welding = TRUE
	tool_behaviour = TOOL_WELDER
	light_on = TRUE
	force = 15
	damtype = BURN
	hitsound = 'sound/items/welder.ogg'
	set_light_on(powered)
	update_appearance()
	START_PROCESSING(SSobj, src)

/obj/item/weldingtool/electric/switched_off(mob/user)
	powered = FALSE
	welding = FALSE
	light_on = FALSE
	force = initial(force)
	damtype = BRUTE
	set_light_on(powered)
	tool_behaviour = NONE
	update_appearance()
	STOP_PROCESSING(SSobj, src)

/obj/item/weldingtool/electric/process(seconds_per_tick)
	if(!powered)
		switched_off()
		return
	if(!(item_use_power(power_use_amount) & COMPONENT_POWER_SUCCESS))
		switched_off()
		return

// We don't need to know how much fuel it has, because it doesn't use any.
/obj/item/weldingtool/electric/examine(mob/user)
	. = ..()
	. -= "It contains [get_fuel()] unit\s of fuel out of [max_fuel]."

// This is what uses fuel in the parent. We override it here to not use fuel
/obj/item/weldingtool/electric/use(used = 0)
	return isOn()

/obj/item/weldingtool/electric/examine()
	. = ..()
	. += "[src] is currently [powered ? "powered" : "unpowered"]."

/obj/item/weldingtool/electric/update_icon_state()
	if(powered)
		inhand_icon_state = "[initial(inhand_icon_state)]1"
	else
		inhand_icon_state = "[initial(inhand_icon_state)]"
	return ..()

