/obj/item/book_of_babel/dwarven_guide
	name = "Brokering 101: Dwarven guide"
	desc = "An ancient tome written dwarven"
	icon = 'icons/obj/library.dmi'
	icon_state = "book1"
	w_class = 2

/obj/item/book_of_babel/dwarven_guide/attack_self(mob/living/carbon/human/user)
	if(!user.has_language(/datum/language/dwarven))
		return FALSE
	. = ..()

/obj/item/twohanded/war_hammer
	name = "dwarven warhammer"
	desc = "A very heavy warhammer, used to dent skulls unless they are already dented."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "greyscale_dwarven_warhammer0"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	flags_1 = CONDUCT_1
	material_flags = MATERIAL_ADD_PREFIX | MATERIAL_COLOR
	force = 14
	force_unwielded = 14
	force_wielded = 20
	armour_penetration = 20
	w_class = WEIGHT_CLASS_BULKY
	custom_materials = list(/datum/material/iron = 20000)
	attack_verb = list("smashed", "dented", "bludeoned")
	hitsound = 'sound/weapons/smash.ogg'
	sharpness = IS_BLUNT


/obj/item/twohanded/war_hammer/update_icon_state()
	icon_state = "greyscale_dwarven_warhammer[wielded]"

/obj/item/hatchet/dwarven
	name = "dwarven "
	desc = "Dwarf dwarf dwarf dwarf dwarf dwarf? DWARF!"
	icon = 'icons/obj/items_and_weapons.dmi'
	flags_1 = CONDUCT_1
	material_flags = MATERIAL_ADD_PREFIX | MATERIAL_COLOR

/obj/item/hatchet/dwarven/axe
	name = "dwarven hand axe"
	desc = "A very sharp axe blade made of greatest dwarven metal."
	icon_state = "greyscale_dwarven_axe"
	item_state = "greyscale_dwarven_axe"
	lefthand_file = 'icons/mob/inhands/weapons/axes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/axes_righthand.dmi'
	custom_materials = list(/datum/material/iron = 10000)
	force = 15
	throwforce = 16

/obj/item/hatchet/dwarven/javelin
	name = "dwarven javelin"
	desc = "A very sharp javelin made of greatest dwarven metal."
	icon_state = "greyscale_dwarven_javelin"
	item_state = "greyscale_dwarven_javelin"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	attack_verb = list("attacked", "poked", "jabbed", "torn", "gored")
	custom_materials = list(/datum/material/iron = 10000)
	force = 7
	throwforce = 18
	throw_speed = 4
	throw_range = 5
	embedding = list("embedded_pain_multiplier" = 4, "embed_chance" = 80, "embedded_fall_chance" = 20)

/obj/item/dwarven
	name = "dorf"
	desc = "am a manly dorf"
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
	var/maxthrow = 5

/obj/item/dwarven/rune_stone/earth/apply(atom/target, mob/user)
	var/stun_amt = 40
	var/list/thrownatoms = list()
	var/atom/throwtarget
	var/distfromcaster
	thrownatoms += get_turf(target)

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

/obj/item/dwarven/mold
	name = "dwarven mold"
	desc = "Dwarven mold, one of their great achievments. Allows for casting of very complex tools and armors"
	icon_state = "mold"
	w_class = WEIGHT_CLASS_SMALL
	var/mold_type

/obj/item/dwarven/mallet
	name = "dwarven mallet"
	desc = "Dwarven mallet, easy to make , easy to use, other than the fact it is absolutely tiny"
	icon_state = "mallet"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/dwarven/blueprint
	name = "dwarven structure print"
	desc = "Dwarven instructions on how to build a dwarven structure, includes materials how neat."
	icon_state = "structure_print"
	w_class = WEIGHT_CLASS_SMALL
	var/obj/structure/destructible/dwarven/structure

/obj/item/dwarven/blueprint/New(loc,_structure)
	structure = _structure
	. = ..()

/obj/item/dwarven/blueprint/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return
	if(isclosedturf(target) ||  isgroundlessturf(target))
		return FALSE
	if(!do_after(user, 60, TRUE, user))
		return FALSE
	var/turf/place = isopenturf(target) ? target : get_turf(target)
	new structure(place)
	qdel(src)
	. = ..()

/obj/item/dwarven/upgrade_kit
	name = "dwarven modification kit"
	desc = "Dwarven instructions on how to modify a weapon."
	icon_state = "structure_print"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/dwarven/upgrade_kit/attackby(obj/item/I, mob/living/user, params)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		I.add_creator(H)
		new /obj/effect/decal/cleanable/ash(get_turf(src))
	qdel(src)
	. = ..()

/obj/item/dwarven/upgrade_kit/debug/attackby(obj/item/I, mob/living/user, params)
	user?.mind.adjust_experience(/datum/skill/operating,100)
	. = ..()


