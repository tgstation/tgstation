/obj/structure/destructible/clockwork/sigil/submission
	name = "sigil of submission"
	desc = "A strange sigil, with otherworldy drawings on it."
	clockwork_desc = "A sigil pulsating with a glorious light. Anyone held on top of this will become a loyal servant of Rat'var."
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

	if(GLOB.main_clock_cult?.human_servants < GLOB.main_clock_cult?.max_human_servants)
		var/datum/antagonist/clock_cultist/servant_datum = new
		servant_datum.give_slab = FALSE
		converted_mob.mind.add_antag_datum(servant_datum)
		new /obj/item/clockwork/clockwork_slab(get_turf(src))
		converted_mob.Paralyze(5 SECONDS)

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
	else
		visible_message(span_warning("\The [src] falters as though it cannot support more servants."))
		return FALSE
