

/obj/item/holotool
	name = "experimental holotool"
	desc = "A highly experimental holographic tool projector."
	icon = 'icons/obj/tools.dmi'
	icon_state = "holotool"
	slot_flags = SLOT_BELT
	usesound = 'sound/items/pshoom.ogg'
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	actions_types = list(/datum/action/item_action/change_tool, /datum/action/item_action/change_ht_color)

	var/on = FALSE
	var/obj/item/current_tool = 0
	var/current_color = "#48D1CC" //mediumturquoise

/obj/item/holotool/proc/AddTool(typee, namee)
	var/obj/item/WR = new typee(src)
	WR.forceMove(src)
	WR.name = namee
	WR.usesound = usesound //use the same sound as we do
	WR.toolspeed = 0.5

/obj/item/holotool/proc/AddTools()
	AddTool(/obj/item/wrench, "holo-wrench")
	AddTool(/obj/item/screwdriver, "holo-screwdriver")
	AddTool(/obj/item/wirecutters, "holo-wirecutters")
	AddTool(/obj/item/weldingtool/largetank, "holo-welder")
	AddTool(/obj/item/crowbar, "holo-crowbar")
	AddTool(/obj/item/device/multitool, "holo-multitool")

/obj/item/holotool/Initialize()
	. = ..()
	//create and rename tools
	AddTools()

/obj/item/holotool/attack_self(mob/living/user)
	to_chat(user, "<span class='notice'>You turn [src] [on ? "off" : "on"].</span>")
	on = !on
	update_icons()
	playsound(loc, 'sound/items/rped.ogg', get_clamped_volume(), 1, -1)

/obj/item/holotool/ui_action_click(mob/user, datum/action/action)
	if(istype(action, /datum/action/item_action/change_tool))
		var/chosen = input("Choose tool settings", "Tool", null, null) as null|anything in contents
		current_tool = chosen
		if(!chosen)
			return
		update_icons()
	else
		var/C = input(user, "Select Color", "Select color", "#48D1CC") as null|color
		if(!C || QDELETED(src))
			return
		current_color = C
		update_icons()

/obj/item/holotool/proc/update_icons()
	cut_overlays()
	if(on && current_tool)
		icon_state = "holotool_on"
		var/mutable_appearance/holo_item = mutable_appearance(icon, current_tool.name)
		holo_item.color = current_color
		item_state = current_tool.name
		add_overlay(holo_item)
		if(istype(current_tool, /obj/item/weldingtool))
			var/mutable_appearance/holo_weld = mutable_appearance(icon, "holo-welding")
			holo_weld.color = current_color
			add_overlay(holo_weld)
	else
		icon_state = "holotool"
		item_state = null

/obj/item/holotool/melee_attack_chain(mob/user, atom/target, params)
	var/obj/item/use_item = src
	if(current_tool && on)
		use_item = current_tool
	if(pre_attackby(target, user, params))
		// Return 1 in attackby() to prevent afterattack() effects (when safely moving items for example)
		var/resolved = target.attackby(use_item, user, params)
		if(!resolved && target && !QDELETED(use_item))
			afterattack(target, user, 1, params) // 1: clicking something Adjacent

