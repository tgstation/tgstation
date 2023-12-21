/obj/structure/injured_spawner
	name = "injured personell transporter"
	desc = "Sends over injured personell from other Centcomm facilities for you to treat."

	resistance_flags = INDESTRUCTIBLE
	anchored = TRUE

	icon = 'icons/obj/machines/restaurant_portal.dmi'
	icon_state = "portal"

	COOLDOWN_DECLARE(spawner_cooldown)


/obj/structure/injured_spawner/Initialize(mapload)
	. = ..()
	register_context()

/obj/structure/injured_spawner/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(COOLDOWN_FINISHED(src, spawner_cooldown))
		generate_and_equip()


/obj/structure/injured_spawner/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_LMB] = "Spawn Body"
	context[SCREENTIP_CONTEXT_RMB] = "Return Body (Drag Body)"
	return CONTEXTUAL_SCREENTIP_SET

/obj/structure/injured_spawner/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(!user.pulling)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/mob/living/carbon/human/injured/pullee = user.pulling
	if(!istype(pullee))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	user.stop_pulling()
	qdel(pullee)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/injured_spawner/proc/generate_and_equip()
	var/mob/living/carbon/human/injured/new_human = new()
	new_human.equipOutfit(/datum/outfit/beachbum)

	apply_wounds(new_human)
	rot_organs(new_human)
	new_human.forceMove(get_turf(src))
	COOLDOWN_START(src, spawner_cooldown, 20 SECONDS)

/obj/structure/injured_spawner/proc/apply_wounds(mob/living/carbon/human/victim)
	var/list/sharps = list(NONE, SHARP_EDGED, SHARP_POINTY, NONE)
	/// Since burn wounds need burn damage, duh
	var/list/dam_types = list(BRUTE, BRUTE, BRUTE, BURN)
	var/list/zones = list(BODY_ZONE_L_ARM,BODY_ZONE_R_ARM,BODY_ZONE_HEAD,BODY_ZONE_CHEST,BODY_ZONE_L_LEG,BODY_ZONE_R_LEG)
	var/obj/item/bodypart/tested_part
	var/list/iter_test_wound_list
	var/i = 1

	var/runs = 6
	while(runs > 0)
		runs--
		tested_part = victim.get_bodypart(pick(zones))
		i = 1
		for(iter_test_wound_list in list(list(/datum/wound/blunt/bone/moderate, /datum/wound/blunt/bone/severe, /datum/wound/blunt/bone/critical),\
										list(/datum/wound/slash/flesh/moderate, /datum/wound/slash/flesh/severe, /datum/wound/slash/flesh/critical),\
										list(/datum/wound/pierce/bleed/moderate, /datum/wound/pierce/bleed/severe, /datum/wound/pierce/bleed/critical),\
										list(/datum/wound/burn/flesh/moderate, /datum/wound/burn/flesh/severe, /datum/wound/burn/flesh/critical)))
			if(prob(20))
				continue

		var/datum/wound/iter_test_wound
		var/datum/wound_pregen_data/iter_pregen_data = GLOB.all_wound_pregen_data[iter_test_wound]
		var/threshold_penalty = 0

		for(iter_test_wound in iter_test_wound_list)
			var/threshold = iter_pregen_data.threshold_minimum - threshold_penalty // just enough to guarantee the next tier of wound, given the existing wound threshold penalty
			if(dam_types[i] == BRUTE)
				tested_part.receive_damage(WOUND_MINIMUM_DAMAGE, 0, wound_bonus = threshold, sharpness=sharps[i])
			else if(dam_types[i] == BURN)
				tested_part.receive_damage(0, WOUND_MINIMUM_DAMAGE, wound_bonus = threshold, sharpness=sharps[i])
			i++

/obj/structure/injured_spawner/proc/rot_organs(mob/living/carbon/human/victim)
	var/organs_to_rot = 6
	var/list/organ_slots = list(ORGAN_SLOT_BRAIN, ORGAN_SLOT_HEART, ORGAN_SLOT_EYES, ORGAN_SLOT_LIVER, ORGAN_SLOT_LUNGS, ORGAN_SLOT_STOMACH)
	while(organs_to_rot > 0)
		organs_to_rot--
		victim.adjustOrganLoss(pick(organ_slots), rand(50, 75))


/mob/living/carbon/human/injured

