/**
 * Caltrop element; for hurting people when they walk over this.
 *
 * Used for broken glass, cactuses and four sided dice.
 */
/datum/element/caltrop
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2

	///Minimum damage done when crossed
	var/min_damage

	///Maximum damage done when crossed
	var/max_damage

	///Probability of actually "firing", stunning and doing damage
	var/probability

	///Miscelanous caltrop flags; shoe bypassing, walking interaction, silence
	var/flags

/datum/element/caltrop/Attach(datum/target, min_damage = 0, max_damage = 0, probability = 100, flags = NONE)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	src.min_damage = min_damage
	src.max_damage = max(min_damage, max_damage)
	src.probability = probability
	src.flags = flags

	RegisterSignal(target, COMSIG_MOVABLE_CROSSED, .proc/Crossed)

/datum/element/caltrop/proc/Crossed(atom/caltrop, atom/movable/AM)
	SIGNAL_HANDLER

	if(!prob(probability))
		return

	if(!ishuman(AM))
		return

	var/mob/living/carbon/human/H = AM
	if(HAS_TRAIT(H, TRAIT_PIERCEIMMUNE))
		return

	if((flags & CALTROP_IGNORE_WALKERS) && H.m_intent == MOVE_INTENT_WALK)
		return

	if(H.movement_type & (FLOATING|FLYING)) //check if they are able to pass over us
		//gravity checking only our parent would prevent us from triggering they're using magboots / other gravity assisting items that would cause them to still touch us.
		return

	if(H.buckled) //if they're buckled to something, that something should be checked instead.
		return

	if(H.body_position == LYING_DOWN) //if we're not standing we cant step on the caltrop
		return

	var/picked_def_zone = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/bodypart/O = H.get_bodypart(picked_def_zone)
	if(!istype(O))
		return

	if(O.status == BODYPART_ROBOTIC)
		return

	if (!(flags & CALTROP_BYPASS_SHOES))
		if ((H.wear_suit?.body_parts_covered | H.w_uniform?.body_parts_covered | H.shoes?.body_parts_covered) & FEET)
			return

	var/damage = rand(min_damage, max_damage)
	if(HAS_TRAIT(H, TRAIT_LIGHT_STEP))
		damage *= 0.75


	if(!(flags & CALTROP_SILENT) && !H.has_status_effect(/datum/status_effect/caltropped))
		H.apply_status_effect(/datum/status_effect/caltropped)
		H.visible_message("<span class='danger'>[H] steps on [caltrop].</span>", \
					"<span class='userdanger'>You step on [caltrop]!</span>")

	H.apply_damage(damage, BRUTE, picked_def_zone, wound_bonus = CANT_WOUND)
	H.Paralyze(60)
