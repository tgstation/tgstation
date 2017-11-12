

/obj/item/holotool
	name = "experimental holotool"
	desc = "A highly experimental holographic tool projector."
	icon = 'hippiestation/icons/obj/tools.dmi'
	icon_state = "holotool"
	slot_flags = SLOT_BELT
	usesound = 'sound/items/pshoom.ogg'
	lefthand_file = 'hippiestation/icons/mob/inhands/lefthand.dmi'
	righthand_file = 'hippiestation/icons/mob/inhands/righthand.dmi'
	actions_types = list(/datum/action/item_action/change_tool, /datum/action/item_action/change_ht_color)

	var/obj/item/current_tool = 0
	var/current_color = "#48D1CC" //mediumturquoise

/obj/item/holotool/proc/AddTool(typee, namee)
	var/obj/item/WR = new typee(src)
	WR.forceMove(src)
	WR.name = namee
	WR.usesound = usesound //use the same sound as we do
	WR.toolspeed = 0.55
	WR.flags_1 = NODROP_1

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
	if(current_tool)
		current_tool.attack_self(user)
	update_icons()

/obj/item/holotool/ui_action_click(mob/user, datum/action/action)
	if(istype(action, /datum/action/item_action/change_tool))
		var/chosen = input("Choose tool settings", "Tool", null, null) as null|anything in contents
		if(!chosen)
			return
		current_tool = chosen
		playsound(loc, 'sound/items/rped.ogg', get_clamped_volume(), 1, -1)
		update_icons()
	else
		var/C = input(user, "Select Color", "Select color", "#48D1CC") as null|color
		if(!C || QDELETED(src))
			return
		current_color = C
		update_icons()
	action.UpdateButtonIcon()
	update_icons()

/obj/item/holotool/proc/update_icons()
	cut_overlays()
	if(current_tool)
		var/mutable_appearance/holo_item = mutable_appearance(icon, current_tool.name)
		holo_item.color = current_color
		item_state = current_tool.name
		add_overlay(holo_item)
		set_light(3, null, current_color)
	else
		item_state = "holotool"
		icon_state = "holotool"
		set_light(0)

	for(var/datum/action/A in actions)
		A.UpdateButtonIcon()

/obj/item/holotool/emag_act(mob/user)
	if(!(/obj/item/holoknife in GetAllContents(src)))
		to_chat(user, "<span class='danger'>ZZT- ILLEGAL BLUEPRINT UNLOCKED- CONTACT !#$@^%$# NANOTRASEN SUPPORT-@*%$^%!</span>")
		var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread()
		sparks.set_up(5, 0, loc)
		sparks.start()
		AddTool(/obj/item/holoknife, "holo-knife")


/obj/item/holotool/melee_attack_chain(mob/user, atom/target, params)
	var/obj/item/use_item = src
	if(current_tool)
		use_item = current_tool
	if(pre_attackby(target, user, params))
		// Return 1 in attackby() to prevent afterattack() effects (when safely moving items for example)
		var/resolved = target.attackby(use_item, user, params)
		if(!resolved && target && !QDELETED(use_item))
			afterattack(target, user, 1, params) // 1: clicking something Adjacent


/obj/item/holoknife
	name = "holo-knife"
	force = 5
	flags_1 = NODROP_1
	armour_penetration = 10
	sharpness = IS_SHARP
	attack_verb = list("attacked", "chopped", "cleaved", "torn", "cut")
	hitsound = 'sound/weapons/blade1.ogg'


/obj/structure/closet/secure_closet/RD/PopulateContents()
	. = ..()
	new /obj/item/holotool(src)
