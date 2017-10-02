/datum/martial_art/holy_crunch
	name = "Holy Crunch"
	deflection_chance = 5
	no_guns = TRUE
	allow_temp_override = FALSE

/datum/martial_art/holy_crunch/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/atk_verb = pick("power word: grail", "power word: justice", "power word: purge", "power word: judicator", "power word: banish")
	D.visible_message("<span class='danger'>[A] uses [atk_verb] on [D]!</span>", \
					  "<span class='userdanger'>[A] uses [atk_verb] on you!</span>")
	D.apply_damage(10, BRUTE)
	playsound(get_turf(D), 'sound/magic/clockwork/ratvar_attack.ogg', 25, 1, -1)
	if(prob(D.getBruteLoss()) && !D.lying)
		D.visible_message("<span class='warning'>[A] sends [D] to the ground with holy energies!</span>", "<span class='userdanger'>An unseen force sends swipes you off your feet!</span>")
		D.Knockdown(80)
	add_logs(A, D, " used [atk_verb] (Holy Crunch) on")
	return 1