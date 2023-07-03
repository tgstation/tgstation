/obj/structure/altar_of_gods
	name = "\improper Altar of the Gods"
	desc = "An altar which allows the head of the church to choose a sect of religious teachings as well as provide sacrifices to earn favor."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "convertaltar"
	density = TRUE
	anchored = TRUE
	layer = TABLE_LAYER
	pass_flags_self = PASSSTRUCTURE | PASSTABLE | LETPASSTHROW
	can_buckle = TRUE
	buckle_lying = 90 //we turn to you!
	///Avoids having to check global everytime by referencing it locally.
	var/datum/religion_sect/sect_to_altar

/obj/structure/altar_of_gods/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/religious_tool, ALL, FALSE, CALLBACK(src, PROC_REF(reflect_sect_in_icons)))
	reflect_sect_in_icons()
	GLOB.chaplain_altars += src
	AddElement(/datum/element/climbable)

/obj/structure/altar_of_gods/Destroy()
	GLOB.chaplain_altars -= src
	return ..()

/obj/structure/altar_of_gods/update_overlays()
	var/list/new_overlays = ..()
	if(GLOB.religious_sect)
		return new_overlays
	new_overlays += "convertaltarcandle"
	return new_overlays

/obj/structure/altar_of_gods/attack_hand(mob/living/user, list/modifiers)
	if(!Adjacent(user) || !user.pulling)
		return ..()
	if(!isliving(user.pulling))
		return ..()
	var/mob/living/pushed_mob = user.pulling
	if(pushed_mob.buckled)
		to_chat(user, span_warning("[pushed_mob] is buckled to [pushed_mob.buckled]!"))
		return ..()
	to_chat(user, span_notice("You try to coax [pushed_mob] onto [src]..."))
	if(!do_after(user,(5 SECONDS),target = pushed_mob))
		return ..()
	pushed_mob.forceMove(loc)
	return ..()

/obj/structure/altar_of_gods/examine_more(mob/user)
	if(!isobserver(user))
		return ..()
	. = list(span_notice("<i>You examine [src] closer, and note the following...</i>"))
	if(GLOB.religion)
		. += list(span_notice("Deity: [GLOB.deity]."))
		. += list(span_notice("Religion: [GLOB.religion]."))
		. += list(span_notice("Bible: [GLOB.bible_name]."))
	if(GLOB.religious_sect)
		. += list(span_notice("Sect: [GLOB.religious_sect]."))
		. += list(span_notice("Favor: [GLOB.religious_sect.favor]."))
	var/chaplains = get_chaplains()
	if(isAdminObserver(user) && chaplains)
		. += list(span_notice("Chaplains: [chaplains]."))

/obj/structure/altar_of_gods/proc/reflect_sect_in_icons()
	if(GLOB.religious_sect)
		sect_to_altar = GLOB.religious_sect
		if(sect_to_altar.altar_icon)
			icon = sect_to_altar.altar_icon
		if(sect_to_altar.altar_icon_state)
			icon_state = sect_to_altar.altar_icon_state
	update_appearance() //Light the candles!

/obj/structure/altar_of_gods/proc/get_chaplains()
	var/chaplain_string = ""
	for(var/mob/living/carbon/human/potential_chap in GLOB.player_list)
		if(potential_chap.key && is_chaplain_job(potential_chap.mind?.assigned_role))
			if(chaplain_string)
				chaplain_string += ", "
			chaplain_string += "[potential_chap] ([potential_chap.key])"
	return chaplain_string

/obj/item/ritual_totem
	name = "ritual totem"
	desc = "A wooden totem with strange carvings on it."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "ritual_totem"
	inhand_icon_state = "sheet-wood"
	lefthand_file = 'icons/mob/inhands/items/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/sheets_righthand.dmi'
	//made out of a single sheet of wood
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT)
	item_flags = NO_PIXEL_RANDOM_DROP

/obj/item/ritual_totem/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, \
		antimagic_flags = MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY, \
		charges = 1, \
		expiration = CALLBACK(src, PROC_REF(expire)), \
	)
	AddComponent(/datum/component/religious_tool, RELIGION_TOOL_INVOKE, FALSE)

/// When the ritual totem is depleted of antimagic
/obj/item/ritual_totem/proc/expire(mob/user)
	to_chat(user, span_warning("[src] consumes the magic within itself and quickly decays into rot!"))
	new /obj/effect/decal/cleanable/ash(drop_location())
	qdel(src)

/obj/item/ritual_totem/can_be_pulled(user, grab_state, force)
	. = ..()
	return FALSE //no

/obj/item/ritual_totem/examine(mob/user)
	. = ..()
	var/is_holy = user.mind?.holy_role
	if(is_holy)
		. += span_notice("[src] can only be moved by important followers of [GLOB.deity].")

/obj/item/ritual_totem/pickup(mob/taker)
	var/initial_loc = loc
	var/holiness = taker.mind?.holy_role
	var/no_take = FALSE
	if(holiness == NONE)
		to_chat(taker, span_warning("Try as you may, you're seemingly unable to pick [src] up!"))
		no_take = TRUE
	else if(holiness == HOLY_ROLE_DEACON) //deacons cannot pick them up either
		no_take = TRUE
		to_chat(taker, span_warning("You cannot pick [src] up. It seems you aren't important enough to [GLOB.deity] to do that."))
	..()
	if(no_take)
		taker.dropItemToGround(src)
		forceMove(initial_loc)
