/obj/item/singularityhammer
	name = "singularity hammer"
	desc = "The pinnacle of close combat technology, the hammer harnesses the power of a miniaturized singularity to deal crushing blows."
	icon = 'icons/obj/weapons/hammer.dmi'
	icon_state = "singularity_hammer0"
	base_icon_state = "singularity_hammer"
	icon_angle = -45
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	worn_icon_state = "singularity_hammer"
	obj_flags = CONDUCTS_ELECTRICITY
	slot_flags = ITEM_SLOT_BACK
	force = 5
	throwforce = 15
	throw_range = 1
	w_class = WEIGHT_CLASS_HUGE
	armor_type = /datum/armor/item_singularityhammer
	resistance_flags = FIRE_PROOF | ACID_PROOF
	force_string = "LORD SINGULOTH HIMSELF"
	///Is it able to pull shit right now?
	var/charged = TRUE

/datum/armor/item_singularityhammer
	melee = 50
	bullet = 50
	laser = 50
	bomb = 50
	fire = 100
	acid = 100

/obj/item/singularityhammer/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/kneejerk)
	AddComponent(/datum/component/two_handed, \
		force_multiplier = 4, \
		icon_wielded = "[base_icon_state]1", \
	)

/obj/item/singularityhammer/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()

/obj/item/singularityhammer/proc/vortex(turf/pull, mob/wielder)
	for(var/atom/X in orange(5,pull))
		if(ismovable(X))
			var/atom/movable/A = X
			if(A == wielder)
				continue
			if(isliving(A))
				var/mob/living/vortexed_mob = A
				if(vortexed_mob.mob_negates_gravity())
					continue
				else
					vortexed_mob.Paralyze(2 SECONDS)
			if(!A.anchored && !isobserver(A))
				step_towards(A,pull)
				step_towards(A,pull)
				step_towards(A,pull)

/obj/item/singularityhammer/afterattack(atom/target, mob/user, click_parameters)
	if(!HAS_TRAIT(src, TRAIT_WIELDED))
		return
	if(!charged)
		return

	charged = FALSE
	if(isliving(target))
		var/mob/living/smacked = target
		smacked.take_bodypart_damage(20, 0)
	playsound(user, 'sound/items/weapons/marauder.ogg', 50, TRUE)
	vortex(get_turf(target), user)
	addtimer(VARSET_CALLBACK(src, charged, TRUE), 10 SECONDS)

/obj/item/mjollnir
	name = "Mjollnir"
	desc = "A weapon worthy of a god, able to strike with the force of a lightning bolt. It crackles with barely contained energy."
	icon = 'icons/obj/weapons/hammer.dmi'
	icon_state = "mjollnir0"
	base_icon_state = "mjollnir"
	worn_icon_state = "mjollnir"
	icon_angle = -45
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	obj_flags = CONDUCTS_ELECTRICITY
	slot_flags = ITEM_SLOT_BACK
	force = 5
	throwforce = 30
	throw_range = 7
	w_class = WEIGHT_CLASS_HUGE

/obj/item/mjollnir/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, \
		force_multiplier = 5, \
		icon_wielded = "[base_icon_state]1", \
		attacksound = SFX_SPARKS, \
	)

/obj/item/mjollnir/update_icon_state()
	icon_state = "[base_icon_state]0"
	return ..()

/obj/item/mjollnir/proc/shock(mob/living/target)
	target.Stun(1.5 SECONDS)
	target.Knockdown(10 SECONDS)
	var/datum/effect_system/lightning_spread/s = new /datum/effect_system/lightning_spread
	s.set_up(5, 1, target.loc)
	s.start()
	target.visible_message(span_danger("[target.name] is shocked by [src]!"), \
		span_userdanger("You feel a powerful shock course through your body sending you flying!"), \
		span_hear("You hear a heavy electrical crack!"))
	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	target.throw_at(throw_target, 200, 4)

/obj/item/mjollnir/attack(mob/living/target_mob, mob/user)
	..()
	if(QDELETED(target_mob))
		return
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		return
	if(HAS_TRAIT(src, TRAIT_WIELDED))
		shock(target_mob)

/obj/item/mjollnir/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!QDELETED(hit_atom) && isliving(hit_atom))
		shock(hit_atom)
