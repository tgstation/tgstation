/obj/item/storage/toolbox/emergency/turret
	desc = "You feel a strange urge to hit this with a wrench."

/obj/item/storage/toolbox/emergency/turret/PopulateContents()
	new /obj/item/screwdriver(src)
	new /obj/item/wrench/combat(src)
	new /obj/item/weldingtool(src)
	new /obj/item/crowbar(src)
	new /obj/item/analyzer(src)
	new /obj/item/wirecutters(src)

/obj/item/storage/toolbox/emergency/turret/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/wrench/combat))
		return NONE
	if(!user.combat_mode)
		return NONE
	if(!tool.toolspeed)
		return ITEM_INTERACT_BLOCKING
	balloon_alert(user, "constructing...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 20))
		return ITEM_INTERACT_BLOCKING

	balloon_alert(user, "constructed!")
	user.visible_message(
		span_danger("[user] bashes [src] with [tool]!"),
		span_danger("You bash [src] with [tool]!"),
		null,
		COMBAT_MESSAGE_RANGE,
	)

	playsound(src, 'sound/items/tools/drill_use.ogg', 80, TRUE, -1)
	var/obj/machinery/porta_turret/syndicate/toolbox/turret = new(get_turf(loc))
	set_faction(turret, user)
	turret.toolbox = src
	forceMove(turret)
	return ITEM_INTERACT_SUCCESS


/obj/item/storage/toolbox/emergency/turret/proc/set_faction(obj/machinery/porta_turret/turret, mob/user)
	turret.faction = list("[REF(user)]")

/obj/item/storage/toolbox/emergency/turret/nukie/set_faction(obj/machinery/porta_turret/turret, mob/user)
	turret.faction = list(ROLE_SYNDICATE)

/obj/machinery/porta_turret/syndicate/toolbox
	icon_state = "toolbox_off"
	base_icon_state = "toolbox"

/obj/machinery/porta_turret/syndicate/toolbox/Initialize(mapload)
	. = ..()
	underlays += image(icon = icon, icon_state = "[base_icon_state]_frame")
