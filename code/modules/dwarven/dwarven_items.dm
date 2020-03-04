/obj/item/book_of_babel/dwarven_guide
	name = "Brokering 101: Dwarven guide"
	desc = "An ancient tome written dwarven"
	icon = 'icons/obj/library.dmi'
	icon_state = "book1"
	w_class = 2

/obj/item/book_of_babel/dwarven_guide/attack_self(mob/living/carbon/human/user)
	if(!user.has_language(/datum/language/dwarven))
		return FALSE
	user.remove_blocked_language(/datum/language/common)
	. = ..()

/obj/item/war_hammer
	name = "dwarven warhammer"
	desc = "A heavy hammer. Apply to skull."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "greyscale_dwarven_warhammer0"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	flags_1 = CONDUCT_1
	material_flags = MATERIAL_ADD_PREFIX | MATERIAL_COLOR
	force = 15
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	slot_flags = BOD
	custom_materials = list(/datum/material/iron = 20000)
	attack_verb = list("smashed", "dented", "bludeoned")
	hitsound = 'sound/weapons/smash.ogg'
	sharpness = IS_BLUNT
	var/wielded = FALSE

/obj/item/war_hammer/Initialize()
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, .proc/on_wield)
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, .proc/on_unwield)


/obj/item/war_hammer/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/two_handed, force_multiplier=1.25, icon_wielded="greyscale_dwarven_warhammer1")

/// triggered on wield of two handed item
/obj/item/war_hammer/proc/on_wield(obj/item/source, mob/user)
	wielded = TRUE

/// triggered on unwield of two handed item
/obj/item/war_hammer/proc/on_unwield(obj/item/source, mob/user)
	wielded = FALSE

/obj/item/hatchet/dwarven
	name = "dwarven"
	desc = "What am i looking at?"
	icon = 'icons/obj/items_and_weapons.dmi'
	flags_1 = CONDUCT_1
	material_flags = MATERIAL_ADD_PREFIX | MATERIAL_COLOR

/obj/item/hatchet/dwarven/axe
	name = "dwarven hand axe"
	desc = "A very sharp axe blade made with finest dwarven metallurgy."
	icon_state = "greyscale_dwarven_axe"
	item_state = "greyscale_dwarven_axe"
	lefthand_file = 'icons/mob/inhands/weapons/axes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/axes_righthand.dmi'
	custom_materials = list(/datum/material/iron = 10000)
	force = 15
	throwforce = 16

/obj/item/hatchet/dwarven/javelin
	name = "dwarven javelin"
	desc = "A very sharp javelin"
	icon_state = "greyscale_dwarven_javelin"
	item_state = "greyscale_dwarven_javelin"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	attack_verb = list("attacked", "poked", "jabbed", "tore", "gored")
	custom_materials = list(/datum/material/iron = 10000)
	force = 7
	throwforce = 18
	throw_speed = 4
	throw_range = 5
	embedding = list("embedded_pain_multiplier" = 4, "embed_chance" = 80, "embedded_fall_chance" = 20)

/obj/item/dwarven
	name = "dorf"
	desc = "am a manly dorf."
	icon = 'icons/obj/dwarven.dmi'

/obj/item/dwarven/rune_stone
	name = "rune stone"
	desc = "Dwarven magical artifact, looks fragile."
	icon = 'icons/obj/dwarven.dmi'
	icon_state = "runestone"
	var/overlay_state
	var/mutable_appearance/overlay

/obj/item/dwarven/rune_stone/Initialize()
	. = ..()
	if(overlay_state != null)
		overlay = mutable_appearance(icon, overlay_state)
		overlay.appearance_flags = RESET_COLOR
		add_overlay(overlay)

/// Proc that does something when you attack with the item
/obj/item/dwarven/rune_stone/proc/apply(atom/target, mob/user)

	return

/obj/item/dwarven/rune_stone/afterattack(atom/target, mob/user, proximity_flag)
	. = ..()
	if(overlay_state == null)
		user.visible_message("<span class='warning'>The runestone is out of charge!</span>")
		return
	if(proximity_flag)
		apply(target, user)
		overlay_state = null
		cut_overlays()

/obj/item/dwarven/rune_stone/attack_self(mob/user)
	if(overlay_state == null)
		user.visible_message("<span class='warning'>The runestone is out of charge!</span>")
		return
	if(user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		apply(user, user)
		overlay_state = null
		cut_overlays()

/obj/item/dwarven/rune_stone/blitz
	name = "blitz runestone"
	desc = "Dwarven magical artifact, looks fragile. This one creates a 3x1 forcewall"
	overlay_state = "blitz_rune"
	var/wall_type = /obj/effect/forcefield

/obj/item/dwarven/rune_stone/blitz/apply(atom/target, mob/user)
	new wall_type(get_turf(user),user)
	if(user.dir == SOUTH || user.dir == NORTH)
		new wall_type(get_step(user, EAST),user)
		new wall_type(get_step(user, WEST),user)
	else
		new wall_type(get_step(user, NORTH),user)
		new wall_type(get_step(user, SOUTH),user)
	..()


/obj/item/dwarven/rune_stone/earth
	name = "earth runestone"
	overlay_state = "earth_rune"
	desc = "Dwarven magical artifact, looks fragile. This one throws away anything on targeted turf"
	var/maxthrow = 5

/obj/item/dwarven/rune_stone/earth/apply(atom/target, mob/user)
	var/stun_amt = 40
	var/list/thrownatoms = list()
	var/atom/throwtarget
	var/distfromcaster
	for(var/turf/T in list(get_turf(target))) //Done this way so things don't get thrown all around hilariously.
		for(var/atom/movable/AM in T)
			thrownatoms += AM

	for(var/am in thrownatoms)
		var/atom/movable/AM = am
		if(AM == user || AM.anchored)
			continue

		if(ismob(AM))
			var/mob/M = AM
			if(M.anti_magic_check())
				continue

		throwtarget = get_edge_target_turf(user, get_dir(user, get_step_away(AM, user)))
		distfromcaster = get_dist(user, AM)
		if(distfromcaster == 0)
			if(isliving(AM))
				var/mob/living/M = AM
				M.Paralyze(100)
				M.adjustBruteLoss(5)
				to_chat(M, "<span class='userdanger'>You're slammed into the floor by [user]!</span>")
		else
			if(isliving(AM))
				var/mob/living/M = AM
				M.Paralyze(stun_amt)
				to_chat(M, "<span class='userdanger'>You're thrown back by [user]!</span>")
			AM.safe_throw_at(throwtarget, ((clamp((maxthrow - (clamp(distfromcaster - 2, 0, distfromcaster))), 3, maxthrow))), 1,user, force = MOVE_FORCE_EXTREMELY_STRONG)//So stuff gets tossed around at the same time.
	..()

/obj/item/dwarven/rune_stone/air
	name = "air runestone"
	overlay_state = "air_rune"
	desc = "Dwarven magical artifact, looks fragile. This one teleports to a random nearby location"

/obj/item/dwarven/rune_stone/air/apply(atom/target, mob/user)
	if(ismob(target))
		var/mob/M = target
		if(M.anti_magic_check())
			M.visible_message("<span class='warning'>[src] fizzles on contact with [target]!</span>")
			return BULLET_ACT_BLOCK
		var/teleammount = 0
		var/teleloc = target
		if(!isturf(target))
			teleloc = target.loc
		for(var/atom/movable/stuff in teleloc)
			if(!stuff.anchored && stuff.loc && !isobserver(stuff))
				if(do_teleport(stuff, stuff, 10, channel = TELEPORT_CHANNEL_MAGIC))
					teleammount++
					var/datum/effect_system/smoke_spread/smoke = new
					smoke.set_up(max(round(4 - teleammount),0), stuff.loc) //Smoke drops off if a lot of stuff is moved for the sake of sanity
					smoke.start()
	..()

/obj/item/dwarven/mallet
	name = "dwarven mallet"
	desc = "Dwarven mallet, easy to make , easy to use, other than the fact it is absolutely tiny."
	icon_state = "mallet"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/dwarven/blueprint
	name = "structure print"
	desc = "Dwarven instructions on how to build a dwarven structure, includes materials how neat. Click with it on an adjacent turf to build the structure"
	icon_state = "structure_print"
	w_class = WEIGHT_CLASS_SMALL
	var/obj/structure/destructible/dwarven/structure

/obj/item/dwarven/blueprint/New(loc,_structure)
	if(_structure)
		structure = _structure
	name = "structure print of" + initial(structure.name)
	. = ..()

/obj/item/dwarven/blueprint/afterattack(atom/target, mob/user, proximity_flag, click_parameters)

	if(!proximity_flag)
		return
	if(isclosedturf(target) ||  isgroundlessturf(target))
		return FALSE
	if(!do_after(user, 15, TRUE, user))
		return FALSE
	var/turf/place = isopenturf(target) ? target : get_turf(target)
	new structure(place)
	qdel(src)
	. = ..()

/obj/item/dwarven/blueprint/anvil
	structure = /obj/structure/destructible/dwarven/workshop/anvil

/obj/item/dwarven/blueprint/workshop
	structure = /obj/structure/destructible/dwarven/workshop

/obj/item/dwarven/blueprint/forge
	structure = /obj/structure/destructible/dwarven/lava_forge

/obj/item/dwarven/blueprint/press
	structure = /obj/structure/destructible/dwarven/mythril_press

/obj/item/dwarven/upgrade_kit
	name = "dwarven modification kit"
	desc = "Dwarven instructions on how to modify a weapon."
	icon_state = "structure_print"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/dwarven/upgrade_kit/attackby(obj/item/I, mob/living/user, params)
	var/mob/living/carbon/human/H = user
	I.add_creator(H)
	new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)
	. = ..()


