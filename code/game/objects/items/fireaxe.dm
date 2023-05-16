/*
 * Fireaxe
 */
/obj/item/fireaxe  // DEM AXES MAN, marker -Agouri
	icon = 'icons/obj/weapons/fireaxe.dmi'
	icon_state = "fireaxe0"
	base_icon_state = "fireaxe"
	lefthand_file = 'icons/mob/inhands/weapons/axes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/axes_righthand.dmi'
	name = "fire axe"
	desc = "Truly, the weapon of a madman. Who would think to fight fire with an axe?"
	force = 5
	throwforce = 15
	demolition_mod = 1.25
	w_class = WEIGHT_CLASS_BULKY
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	attack_verb_continuous = list("attacks", "chops", "cleaves", "tears", "lacerates", "cuts")
	attack_verb_simple = list("attack", "chop", "cleave", "tear", "lacerate", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP_EDGED
	armor_type = /datum/armor/item_fireaxe
	resistance_flags = FIRE_PROOF
	wound_bonus = -15
	bare_wound_bonus = 20
	/// How much damage to do unwielded
	var/force_unwielded = 5
	/// How much damage to do wielded
	var/force_wielded = 24

/datum/armor/item_fireaxe
	fire = 100
	acid = 30

/obj/item/fireaxe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, \
		speed = 10 SECONDS, \
		effectiveness = 80, \
		bonus_modifier = 0 , \
		butcher_sound = hitsound, \
	)
	var/datum/callback/door_start_trap_callback = CALLBACK(src, PROC_REF(start_trapping_door))
	var/datum/callback/airlock_tip_callback = CALLBACK(src, PROC_REF(on_airlock_tip))

	AddComponent(/datum/component/airlock_tip, 1 MINUTES, door_start_trap_callback, airlock_tip_callback)
	//axes are not known for being precision butchering tools
	AddComponent(/datum/component/two_handed, force_unwielded=force_unwielded, force_wielded=force_wielded, icon_wielded="[base_icon_state]1")

/obj/item/fireaxe/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()

/obj/item/fireaxe/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] axes [user.p_them()]self from head to toe! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/fireaxe/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(HAS_TRAIT(src, TRAIT_WIELDED)) //destroys windows and grilles in one hit
		if(istype(A, /obj/structure/window) || istype(A, /obj/structure/grille))
			if(!(A.resistance_flags & INDESTRUCTIBLE))
				var/obj/structure/W = A
				W.atom_destruction("fireaxe")

/// Rig to airlock
/obj/item/fireaxe/proc/start_trapping_door(mob/living/prankster, obj/machinery/door/trapped_airlock)
	prankster.visible_message(span_danger("[prankster] begins rigging [src] to [trapped_airlock]..."), span_warning("You begin rigging [src] to [trapped_airlock]..."), vision_distance = COMBAT_MESSAGE_RANGE)

/// Whack
/obj/item/fireaxe/proc/on_airlock_tip(atom/movable/victim, obj/machinery/door/trapped_airlock)
	if(iscarbon(victim))
		forceMove(get_turf(victim))
		var/mob/living/carbon/carbon_victim = victim
		var/obj/item/bodypart/chop_part = carbon_victim.get_bodypart(BODY_ZONE_HEAD) || carbon_victim.get_bodypart(BODY_ZONE_CHEST)
		victim.visible_message(span_danger("[src] falls from [trapped_airlock], chopping into [victim]'s [chop_part.plaintext_zone]!"), span_userdanger("[src] falls from [trapped_airlock], chopping into your [chop_part.plaintext_zone]!"), vision_distance = COMBAT_MESSAGE_RANGE)
		chop_part.receive_damage(force, updating_health = TRUE, wound_bonus = wound_bonus, bare_wound_bonus = bare_wound_bonus)
		add_mob_blood(victim)
		var/turf/location = get_turf(victim)
		carbon_victim.add_splatter_floor(location)
		playsound(src, hitsound, 100)
	else
		victim.visible_message(span_danger("[src] falls from [trapped_airlock], chopping into [victim]!"), span_userdanger("[src] falls off of [trapped_airlock], chopping into you!"), vision_distance = COMBAT_MESSAGE_RANGE)
		forceMove(get_turf(victim))
		//victim.apply_damage(force, damtype, attacking_item = src)
		playsound(src, hitsound, 100)

/*
 * Bone Axe
 */
/obj/item/fireaxe/boneaxe  // Blatant imitation of the fireaxe, but made out of bone.
	icon_state = "bone_axe0"
	base_icon_state = "bone_axe"
	name = "bone axe"
	desc = "A large, vicious axe crafted out of several sharpened bone plates and crudely tied together. Made of monsters, by killing monsters, for killing monsters."
	force_unwielded = 5
	force_wielded = 23

/*
 * Metal Hydrogen Axe
 */
/obj/item/fireaxe/metal_h2_axe
	icon_state = "metalh2_axe0"
	base_icon_state = "metalh2_axe"
	name = "metallic hydrogen axe"
	desc = "A lightweight crowbar with an extreme sharp fire axe head attached. It trades it's hefty as a weapon by making it easier to carry around when holstered to suits without having to sacrifice your backpack."
	force_unwielded = 5
	force_wielded = 15
	demolition_mod = 2
	tool_behaviour = TOOL_CROWBAR
	toolspeed = 1
	usesound = 'sound/items/crowbar.ogg'
