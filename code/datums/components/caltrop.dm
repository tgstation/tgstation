/**
 * Caltrop element; for hurting people when they walk over this.
 *
 * Used for broken glass, cactuses and four sided dice.
 */
/datum/component/caltrop
	///Minimum damage done when crossed
	var/min_damage

	///Maximum damage done when crossed
	var/max_damage

	///Probability of actually "firing", stunning and doing damage
	var/probability

	///Amount of time the spike will paralyze
	var/paralyze_duration

	///Miscelanous caltrop flags; shoe bypassing, walking interaction, silence
	var/flags

	///The sound that plays when a caltrop is triggered.
	var/soundfile

	///given to connect_loc to listen for something moving over target
	var/static/list/crossed_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)

	///So we can update ant damage
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

/datum/component/caltrop/Initialize(min_damage = 0, max_damage = 0, probability = 100, paralyze_duration = 2 SECONDS, flags = NONE, soundfile = null)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.min_damage = min_damage
	src.max_damage = max(min_damage, max_damage)
	src.probability = probability
	src.paralyze_duration = paralyze_duration
	src.flags = flags
	src.soundfile = soundfile

	if(ismovable(parent))
		AddComponent(/datum/component/connect_loc_behalf, parent, crossed_connections)
	else
		RegisterSignal(get_turf(parent), COMSIG_ATOM_ENTERED, PROC_REF(on_entered))

// Inherit the new values passed to the component
/datum/component/caltrop/InheritComponent(datum/component/caltrop/new_comp, original, min_damage, max_damage, probability, flags, soundfile)
	if(!original)
		return
	if(min_damage)
		src.min_damage = min_damage
	if(max_damage)
		src.max_damage = max_damage
	if(probability)
		src.probability = probability
	if(flags)
		src.flags = flags
	if(soundfile)
		src.soundfile = soundfile

/datum/component/caltrop/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!prob(probability))
		return

	if(!ishuman(arrived))
		return

	var/mob/living/carbon/human/digitigrade_fan = arrived
	if(HAS_TRAIT(digitigrade_fan, TRAIT_PIERCEIMMUNE))
		return

	if((flags & CALTROP_IGNORE_WALKERS) && digitigrade_fan.move_intent == MOVE_INTENT_WALK)
		return

	if(digitigrade_fan.movement_type & MOVETYPES_NOT_TOUCHING_GROUND) //check if they are able to pass over us
		//gravity checking only our parent would prevent us from triggering they're using magboots / other gravity assisting items that would cause them to still touch us.
		return

	if(digitigrade_fan.buckled) //if they're buckled to something, that something should be checked instead.
		return

	if(digitigrade_fan.body_position == LYING_DOWN && !(flags & CALTROP_NOCRAWL)) //if we're not standing we cant step on the caltrop
		return

	var/picked_def_zone = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/bodypart/leg = digitigrade_fan.get_bodypart(picked_def_zone)
	if(!istype(leg))
		return

	if(!IS_ORGANIC_LIMB(leg))
		return

	if (!(flags & CALTROP_BYPASS_SHOES))
		if ((digitigrade_fan.wear_suit?.body_parts_covered | digitigrade_fan.w_uniform?.body_parts_covered | digitigrade_fan.shoes?.body_parts_covered) & FEET)
			return

	var/damage = rand(min_damage, max_damage)
	if(HAS_TRAIT(digitigrade_fan, TRAIT_LIGHT_STEP))
		damage *= 0.75


	if(!(flags & CALTROP_SILENT) && !digitigrade_fan.has_status_effect(/datum/status_effect/caltropped))
		digitigrade_fan.apply_status_effect(/datum/status_effect/caltropped)
		digitigrade_fan.visible_message(
			span_danger("[digitigrade_fan] steps on [parent]."),
			span_userdanger("You step on [parent]!")
		)

	digitigrade_fan.apply_damage(damage, BRUTE, picked_def_zone, wound_bonus = CANT_WOUND, attacking_item = parent)

	if(!(flags & CALTROP_NOSTUN)) // Won't set off the paralysis.
		if(!HAS_TRAIT(digitigrade_fan, TRAIT_LIGHT_STEP))
			digitigrade_fan.Paralyze(paralyze_duration)
		else
			digitigrade_fan.Knockdown(paralyze_duration)
	if(!soundfile)
		return
	playsound(digitigrade_fan, soundfile, 15, TRUE, -3)

/datum/component/caltrop/UnregisterFromParent()
	if(ismovable(parent))
		qdel(GetComponent(/datum/component/connect_loc_behalf))
