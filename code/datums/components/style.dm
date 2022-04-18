/datum/component/style

/obj/item/style_meter
	name = "style meter attachment"
	desc = "Attach this to a pair of glasses to install a style meter system in them. \
		You get style points from performing stylish acts and lose them for breaking your style. \
		The style affects the quality of your mining, with you being able to mine ore better during a good chain."
	icon_state = "style_meter"
	icon = 'icons/obj/clothing/glasses.dmi'
	var/datum/component/style/style_meter

/obj/item/style_meter/attack_atom(atom/attacked_atom, mob/living/user, params)
	if(istype(attacked_atom, /obj/item/clothing/glasses))
		forceMove(attacked_atom)
		attacked_atom.vis_contents += src
		RegisterSignal(attacked_atom, COMSIG_CLICK_ALT, .proc/unattach)
		RegisterSignal(attacked_atom, COMSIG_ITEM_EQUIPPED, .proc/check_wearing)
		RegisterSignal(attacked_atom, COMSIG_ITEM_DROPPED, .proc/on_drop)
		balloon_alert(user, "style meter attached")
		playsound(src, 'sound/machines/click.ogg', 30, TRUE)
		if(!iscarbon(attacked_atom.loc))
			return
		var/mob/living/carbon/carbon_wearer = attacked_atom.loc
		if(carbon_wearer.glasses != attacked_atom)
			return
		style_meter = AddComponent(equipper, /datum/component/style)
	else
		return ..()

/obj/item/style_meter/Moved(atom/old_loc, Dir)
	. = ..()
	if(!istype(old_loc, /obj/item/clothing/glasses))
		return
	clean_up(old_loc)

/obj/item/style_meter/Destroy(force)
	if(istype(loc, /obj/item/clothing/glasses))
		clean_up(loc)
	return ..()

/obj/item/style_meter/proc/check_wearing(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(!(slot & ITEM_SLOT_EYES))
		if(style_meter)
			QDEL_NULL(style_meter)
		return
	style_meter = AddComponent(equipper, /datum/component/style)

/obj/item/style_meter/proc/unattach(atom/source, mob/user)
	SIGNAL_HANDLER

	if(!user.put_in_hands(src))
		forceMove(drop_location())
	balloon_alert(user, "style meter removed")
	playsound(src, 'sound/machines/click.ogg', 30, TRUE)

/obj/item/style_meter/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!style_meter)
		return
	QDEL_NULL(style_meter)

/obj/item/style_meter/proc/clean_up(old_location)
	old_location.vis_contents -= src
	UnregisterSignal(old_location, COMSIG_CLICK_ALT)
	UnregisterSignal(old_location, COMSIG_ITEM_EQUIPPED)
	QDEL_NULL(style_meter)
