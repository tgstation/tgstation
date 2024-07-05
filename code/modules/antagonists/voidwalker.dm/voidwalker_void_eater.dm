/**
 * An armblade that pops windows
 */
/obj/item/void_eater
	name = "void eater" //as opposed to full eater
	icon = 'icons/obj/weapons/voidwalker_items.dmi'
	icon_state = "arm_blade"
	inhand_icon_state = "arm_blade"
	force = 25
	armour_penetration = 35
	lefthand_file = 'icons/mob/inhands/antag/voidwalker_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/voidwalker_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL
	resistance_flags = INDESTRUCTIBLE | ACID_PROOF | FIRE_PROOF | LAVA_PROOF | UNACIDABLE
	w_class = WEIGHT_CLASS_HUGE
	sharpness = SHARP_EDGED
	tool_behaviour = TOOL_MINING
	hitsound = 'sound/weapons/bladeslice.ogg'
	wound_bonus = -30
	bare_wound_bonus = 20

/obj/item/void_eater/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/butchering, \
	speed = 8 SECONDS, \
	effectiveness = 70, \
	)

	AddComponent(/datum/component/temporary_glass_shatterer)

/obj/item/void_eater/attack(mob/living/target_mob, mob/living/user, params)
	if(!ishuman(target_mob))
		return ..()

	var/mob/living/carbon/human/hewmon = target_mob

	if(hewmon.has_trauma_type(/datum/brain_trauma/voided))
		// explode into glass wooooohhoooo
		var/static/list/shards = list(/obj/item/shard = 2, /obj/item/shard/plasma = 1, /obj/item/shard/titanium = 1, /obj/item/shard/plastitanium = 1)
		for(var/i in 1 to rand(4, 6))
			var/shard_type = pick_weight(shards)
			var/obj/shard = new shard_type (get_turf(hewmon))
			shard.pixel_x = rand(-16, 16)
			shard.pixel_y = rand(-16, 16)

		var/obj/item/organ/brain = hewmon.get_organ_by_type(/obj/item/organ/internal/brain)
		if(brain)
			brain.Remove(hewmon)
			brain.forceMove(get_turf(hewmon))

		playsound(get_turf(hewmon), SFX_SHATTER, 100)
		qdel(hewmon)

	if(hewmon.stat == HARD_CRIT)
		target_mob.balloon_alert(user, "is in crit!")
		return COMPONENT_CANCEL_ATTACK_CHAIN
	return ..()

/datum/component/temporary_glass_shatterer/Initialize(...)
	. = ..()

	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(on_tap))

/datum/component/temporary_glass_shatterer/proc/on_tap(obj/item/parent, mob/tapper, atom/target)
	SIGNAL_HANDLER

	if(istype(target, /obj/structure/window))
		var/obj/structure/window/window = target
		window.temporary_shatter()
	else if(istype(src, /obj/structure/grille))
		var/obj/structure/grille/grille = target
		grille.temporary_shatter()
	else
		return
	return COMPONENT_CANCEL_ATTACK_CHAIN
