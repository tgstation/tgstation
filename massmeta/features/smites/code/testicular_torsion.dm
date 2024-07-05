/datum/smite/testicular_torsion
	name = "Testicular Torsion"

/datum/smite/testicular_torsion/effect(client/user, mob/living/target)
	. = ..()

	if (!iscarbon(target))
		to_chat(user, span_warning("This must be used on a carbon mob."), confidential = TRUE)
		return

	var/mob/living/carbon/carbon_target = target
	if (carbon_target.gender == FEMALE)
		to_chat(user, span_warning("Target has no balls!"), confidential = TRUE)
		return

	carbon_target.apply_damage(rand(20, 40), BRUTE, BODY_ZONE_L_LEG, wound_bonus = rand(35,60), forced = TRUE)
	carbon_target.apply_damage(rand(20, 40), BRUTE, BODY_ZONE_R_LEG, wound_bonus = rand(35,60), forced = TRUE)
	carbon_target.emote("scream")
	var/list/phrase = world.file2list("massmeta/features/smites/string/balls_phrases.txt")
	carbon_target.say(pick(phrase))
	carbon_target.Paralyze(15 SECONDS)

	playsound(target, 'massmeta/features/smites/sound/testicular_torsion.ogg', 60)
	carbon_target.visible_message(
		span_danger("You can see [carbon_target]'s balls being crushed by an unknown force! You can feel the pain just by looking at it."),
		span_userdanger("You can feel like your balls are being crushed!"),
		span_danger("You can hear someone's balls bursting like balloons!")
	)
