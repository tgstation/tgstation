/datum/smite/testicular_torsion
	name = "Testicular Torsion"

/datum/smite/testicular_torsion/effect(client/user, mob/living/target)
	. = ..()

	if (!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return

	var/mob/living/carbon/carbon_target = target
	carbon_target.apply_damage(rand(20, 40), BRUTE, BODY_ZONE_L_LEG, wound_bonus = rand(35,60), forced = TRUE)
	carbon_target.apply_damage(rand(20, 40), BRUTE, BODY_ZONE_R_LEG, wound_bonus = rand(35,60), forced = TRUE)
	carbon_target.emote("scream")
	var/list/phrase = world.file2list("massmeta/strings/balls_phrases.txt")
	carbon_target.say(pick(phrase))
	carbon_target.Paralyze(15 SECONDS)

	playsound(target, 'massmeta/sounds/smites/testicular_torsion.ogg', 60)
	to_chat(target, span_userdanger("You feel like your balls are being crushed!"))
