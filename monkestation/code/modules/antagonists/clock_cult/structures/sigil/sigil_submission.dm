/obj/structure/destructible/clockwork/sigil/submission
	name = "sigil of submission"
	desc = "A strange sigil, with otherworldy drawings on it."
	clockwork_desc = "A sigil pulsating with a glorious light. Anyone held on top of this for 8 seconds will become a loyal servant of Rat'var."
	icon_state = "sigilsubmission"
	effect_stand_time = 8 SECONDS
	idle_color = "#FFFFFF"
	invocation_color = "#e042d8"
	pulse_color = "#EBC670"
	fail_color = "#d43333"

/obj/structure/destructible/clockwork/sigil/submission/can_affect(mob/living/checked_mob)
	. = ..()
	if(!.)
		return FALSE

	if(IS_CLOCK(checked_mob))
		return FALSE

	return is_convertable_to_cult(checked_mob, for_clock_cult = TRUE)

/obj/structure/destructible/clockwork/sigil/submission/apply_effects(mob/living/converted_mob)
	. = ..()
	if(!.)
		converted_mob.visible_message(span_warning("[converted_mob] resists conversion!"))
		return FALSE

	if(converted_mob.client)
		var/previous_colour = converted_mob.client.color
		converted_mob.client.color = LIGHT_COLOR_CLOCKWORK
		animate(converted_mob.client, color = previous_colour, time = 1 SECONDS)

	GLOB.main_clock_cult?.check_member_distribution()
	if(isdrone(converted_mob) && (GLOB.cogscarabs.len < MAXIMUM_COGSCARABS))
		var/mob/living/basic/drone/cogscarab/cogger = new /mob/living/basic/drone/cogscarab(get_turf(src))
		cogger.key = converted_mob.key
		cogger.mind?.add_antag_datum(/datum/antagonist/clock_cultist)
		cogger.visible_message("A light envelops \the [converted_mob]! As the light fades you see it has become a cogscarab!",
							   span_brass("Rat'var has granted you your freedom, you must protect the ark at all costs!"))
		qdel(converted_mob)
		return TRUE

	else if(((GLOB.main_clock_cult?.human_servants.len < GLOB.main_clock_cult?.max_human_servants) && ishuman(converted_mob)) || !ishuman(converted_mob))
		var/datum/antagonist/clock_cultist/servant_datum = new
		servant_datum.give_slab = FALSE
		converted_mob.mind.add_antag_datum(servant_datum)
		converted_mob.Paralyze(5 SECONDS)
		if(ishuman(converted_mob))
			var/mob/living/carbon/human/human_converted = converted_mob
			human_converted.uncuff()
			new /obj/item/clockwork/clockwork_slab(get_turf(src))

		var/brutedamage = converted_mob.getBruteLoss()
		var/burndamage = converted_mob.getFireLoss()
		if(brutedamage || burndamage)
			converted_mob.adjustBruteLoss(-(round(brutedamage * 0.75)))
			converted_mob.adjustFireLoss(-(round(burndamage * 0.75)))

		converted_mob.visible_message(span_warning("[converted_mob] sits completely motionless as \
	 												[(brutedamage || burndamage) ? "a birght light pours from [converted_mob.p_their()] wounds as they close." \
													: "as the sigil below [converted_mob.p_them()] glows brightly."]!"),
									 span_bigbrass("<i>You feel a flash of light and the world spin around you!</i>"))
		send_clock_message(null, "[converted_mob] has been converted!")
		return TRUE

	visible_message(span_warning("\The [src] falters as though it cannot support more servants."))
	return FALSE
