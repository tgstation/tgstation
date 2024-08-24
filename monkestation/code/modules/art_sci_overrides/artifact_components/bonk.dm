/datum/artifact_effect/bonk
	weight = ARTIFACT_UNCOMMON
	type_name = "Slammer Effect"
	activation_message = "opens up!"
	deactivation_message = "closes up."
	valid_activators = list(
		/datum/artifact_activator/touch/carbon,
		/datum/artifact_activator/touch/silicon
	)
	///force of the hit
	var/hit_power = 1
	COOLDOWN_DECLARE(bonk_cooldown)

	examine_discovered = span_warning("It appears to bonk those with heads on said head.")

/datum/artifact_effect/bonk/setup()
	hit_power = rand(0,35)
	potency += hit_power

/datum/artifact_effect/bonk/effect_touched(mob/living/user)
	if(!COOLDOWN_FINISHED(src, bonk_cooldown))
		return

	if(iscarbon(user))
		var/mob/living/carbon/carbon = user
		if(!carbon.get_bodypart(BODY_ZONE_HEAD))
			our_artifact.holder.say("My condolences to your missing head.") //they can speak uhh galactic common because alien tech idk
			our_artifact.holder.visible_message(span_notice("[our_artifact.holder] shakes [user][p_s()] hands with an apparatus."))
			playsound(get_turf(our_artifact.holder), 'sound/weapons/thudswoosh.ogg', 50, TRUE, -1)
			our_artifact.artifact_deactivate()
			return
		else
			carbon.apply_damage(hit_power, BRUTE, BODY_ZONE_HEAD, carbon.run_armor_check(BODY_ZONE_HEAD, MELEE))
			our_artifact.holder.visible_message(span_danger("[our_artifact.holder] hits [carbon] over the head!"))
	else
		our_artifact.holder.visible_message(span_danger("[our_artifact.holder] slams [user]!"))
		user.adjustBruteLoss(hit_power)
	playsound(get_turf(our_artifact.holder), 'sound/misc/bonk.ogg', 80, FALSE)
	COOLDOWN_START(src, bonk_cooldown, 1.5 SECONDS)
