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
	obj_flags = CONDUCTS_ELECTRICITY
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
	/// Can it butcher?
	var/butcher = TRUE
	/// Do you ALWAYS need 2 hands to hold it?
	var/is_only_two_handed = FALSE

/datum/armor/item_fireaxe
	fire = 100
	acid = 30

/obj/item/fireaxe/Initialize(mapload)
	. = ..()
	if(butcher)
		AddComponent(/datum/component/butchering, \
			speed = 10 SECONDS, \
			effectiveness = 80, \
			bonus_modifier = 0 , \
			butcher_sound = hitsound, \
		)
	//axes are not known for being precision butchering tools
	AddComponent(/datum/component/two_handed, force_unwielded=force_unwielded, force_wielded=force_wielded, require_twohands = is_only_two_handed, icon_wielded="[base_icon_state]1")

/obj/item/fireaxe/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()

/obj/item/fireaxe/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] axes [user.p_them()]self from head to toe! It looks like [user.p_theyre()] trying to commit suicide!"))
	return BRUTELOSS

/obj/item/fireaxe/afterattack(atom/target, mob/user, click_parameters)
	if(!HAS_TRAIT(src, TRAIT_WIELDED)) //destroys windows and grilles in one hit
		return
	if(target.resistance_flags & INDESTRUCTIBLE)
		return
	if(istype(target, /obj/structure/window) || istype(target, /obj/structure/grille))
		target.atom_destruction("fireaxe")

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

/*
 * Boarding Axe
 */
/obj/item/fireaxe/boardingaxe
	icon_state = "boarding_axe0"
	base_icon_state = "boarding_axe"
	name = "boarding axe"
	desc = "A hulking cleaver that feels like a burden just looking at it. Seems excellent at halving obstacles like windows, airlocks, barricades and people."
	force_unwielded = 5
	force_wielded = 30
	demolition_mod = 3

/*
 * Battering Ram
 */
/obj/item/fireaxe/batteringram
	icon_state = "battering_ram0"
	base_icon_state = "battering_ram"
	name = "battering ram"
	desc = "An extremely heavy and unwieldy hunk of metal used to break down airlocks. Why would anyone ram a sliding airlock?"

	w_class = WEIGHT_CLASS_HUGE
	item_flags = SLOWS_WHILE_IN_HAND | IMMUTABLE_SLOW
	sharpness = NONE
	butcher = FALSE
	is_only_two_handed = TRUE

	force_wielded = 18
	demolition_mod = 1.5
	wound_bonus = 20 // RIP bones
	bare_wound_bonus = 0

	slowdown = 1
	drag_slowdown = 1.5 // So you cannot circumvent the slowdown
	throw_range = 2

	attack_verb_continuous = list("slams", "breaks", "demolishes", "rams", "batters", "breaches")
	attack_verb_simple = list("slam", "break", "demolish", "ram", "batter", "breach")

	hitsound = 'sound/effects/bang.ogg'
	pickup_sound = 'sound/items/handling/heavy_pickup.ogg'
	drop_sound = 'sound/items/handling/heavy_drop.ogg'

/obj/item/fireaxe/batteringram/attack(mob/living/target_mob, mob/living/user, params)
	. = ..()
	if(!target_mob.anchored && target_mob.body_position == STANDING_UP)
		var/no_gravity = FALSE
		if(!has_gravity()) // Should've learned physics
			var/user_throwtarget = get_step(user, get_dir(target_mob, user))
			user.safe_throw_at(user_throwtarget, 1, 1, force = MOVE_FORCE_NORMAL)
			no_gravity = TRUE
		var/throwtarget = get_step(target_mob, get_dir(user, target_mob))
		target_mob.safe_throw_at(throwtarget, 1, 1, force = MOVE_FORCE_NORMAL, spin = no_gravity) // Same force as shove

/obj/item/fireaxe/batteringram/afterattack(atom/target, mob/user, click_parameters)
	. = ..()
	if(!isliving(target))
		playsound(target, hitsound, 100, TRUE)
		for(var/mob/bystanders in urange(2, target))
			if(!bystanders.stat && !isAI(bystanders))
				shake_camera(bystanders, 1, 0.5)

	var/mob/living/living_user = user
	if(!living_user)
		return

	if((HAS_TRAIT(living_user, TRAIT_CLUMSY)) && prob(30)) // https://tenor.com/view/police-raid-fall-out-funny-gif-9719355
		var/throwtarget = get_step(living_user, get_dir(target, living_user))
		living_user.Knockdown(3 SECONDS)
		living_user.safe_throw_at(throwtarget, 1, 1, force = MOVE_FORCE_STRONG)

		to_chat(living_user, span_userdanger("You try to [pick(attack_verb_simple)] [target], but slip and fall due inertia!"))
		visible_message(span_warning("[living_user] slips!"))
		playsound(living_user, 'sound/misc/slip.ogg', 100)

/obj/item/fireaxe/batteringram/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] [pick(attack_verb_continuous)] [user.p_them()]self open! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(user, hitsound, 100, ignore_walls = FALSE)
	return BRUTELOSS
