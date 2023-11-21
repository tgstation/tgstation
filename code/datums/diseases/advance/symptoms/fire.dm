/**Spontaneous Combustion
 * Slightly hidden.
 * Lowers resistance tremendously.
 * Decreases stage speed tremendously.
 * Decreases transmittablity tremendously.
 * Fatal level
 * Bonus: Ignites infected mob.
 */

/datum/symptom/fire
	name = "Spontaneous Combustion"
	desc = "The virus turns fat into an extremely flammable compound, and raises the body's temperature, making the host burst into flames spontaneously."
	illness = "Spontaneous Combustion"
	stealth = -1
	resistance = -4
	stage_speed = -3
	transmittable = -4
	level = 6
	severity = 5
	base_message_chance = 20
	symptom_delay_min = 20
	symptom_delay_max = 75
	var/infective = FALSE
	threshold_descs = list(
		"Stage Speed 4" = "Increases the intensity of the flames.",
		"Stage Speed 8" = "Further increases flame intensity.",
		"Transmission 8" = "Host will spread the virus through skin flakes when bursting into flame.",
		"Stealth 4" = "The symptom remains hidden until active.",
	)

/datum/symptom/fire/Start(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	if(A.totalStageSpeed() >= 4)
		power = 1.5
	if(A.totalStageSpeed() >= 8)
		power = 2
	if(A.totalStealth() >= 4)
		suppress_warning = TRUE
	if(A.totalTransmittable() >= 8) //burning skin spreads the virus through smoke
		infective = TRUE

/datum/symptom/fire/Activate(datum/disease/advance/A)
	. = ..()
	if(!.)
		return
	var/mob/living/living_mob = A.affected_mob
	switch(A.stage)
		if(1 to 2)
			return
		if(3)
			if(prob(base_message_chance) && !suppress_warning)
				warn_mob(living_mob)
		else
			var/advanced_stage = A.stage > 4
			living_mob.adjust_fire_stacks((advanced_stage ? 3 : 1) * power)
			living_mob.take_overall_damage(burn = ((advanced_stage ? 5 : 3) * power), required_bodytype = BODYTYPE_ORGANIC)
			living_mob.ignite_mob(silent = TRUE)
			if(living_mob.on_fire) //check to make sure they actually caught on fire, or if it was prevented cause they were wet.
				living_mob.visible_message(span_warning("[living_mob] catches fire!"), ignored_mobs = living_mob)
				to_chat(living_mob, span_userdanger((advanced_stage ? "Your skin erupts into an inferno!" : "Your skin bursts into flames!")))
				living_mob.emote("scream")
			else if(!suppress_warning)
				warn_mob(living_mob)

			if(infective)
				A.spread(advanced_stage ? 4 : 2)

/datum/symptom/fire/proc/warn_mob(mob/living/living_mob)
	if(prob(33.33))
		living_mob.audible_message(self_message = "You hear a crackling noise.")
	else
		to_chat(living_mob, span_warning("[pick("You feel hot.", "You smell smoke.")]"))
