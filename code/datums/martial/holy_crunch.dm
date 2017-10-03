/datum/martial_art/hand_of_god
	name = "Hand of God"
	deflection_chance = 0
	no_guns = TRUE
	allow_temp_override = FALSE

/datum/martial_art/hand_of_god/harm_act(mob/living/carbon/human/A, mob/living/carbon/human/D)
	A.do_attack_animation(D, ATTACK_EFFECT_PUNCH)
	var/attack_type = pick("brute", "burn", "toxin", "knockdown")
	if(attack_type == "brute")
		var/atk_verb = pick("power word: fracture", "power word: break", "power word: crack", "power word: snap", "power word: fissure")
		D.visible_message("<span class='danger'>[A] uses [atk_verb] on [D]!</span>", \
					  "<span class='userdanger'>[A] uses [atk_verb] on you!</span>")
		D.apply_damage(10, BRUTE)
		playsound(get_turf(D), 'sound/magic/repulse.ogg', 25, 1, -1)
		add_logs(A, D, " used [atk_verb] (Hand of God) on")
		return TRUE
	if(attack_type == "burn")
		var/atk_verb = pick("power word: scorch", "power word: sear", "power word: burn", "power word: fireball", "power word: combust")
		D.visible_message("<span class='danger'>[A] uses [atk_verb] on [D]!</span>", \
					  "<span class='userdanger'>[A] uses [atk_verb] on you!</span>")
		D.apply_damage(10, BURN)
		playsound(get_turf(D), 'sound/magic/teleport_app.ogg', 25, 1, -1)
		add_logs(A, D, " used [atk_verb] (Hand of God) on")
		return TRUE
	if(attack_type == "toxin")
		var/atk_verb = pick("power word: impair", "power word: afflict", "power word: debilitate", "power word: hurt", "power word: diminish", )
		D.visible_message("<span class='danger'>[A] uses [atk_verb] on [D]!</span>", \
					  "<span class='userdanger'>[A] uses [atk_verb] on you!</span>")
		D.apply_damage(10, TOX)
		playsound(get_turf(D), 'sound/effects/bamf.ogg', 25, 1, -1)
		add_logs(A, D, " used [atk_verb] (Hand of God) on")
		return TRUE
	if(attack_type == "knockdown")
		var/atk_verb = pick("power word: stasis", "power word: daze", "power word: tranquilise", "power word: benumb", "power word: ban", )
		D.visible_message("<span class='danger'>[A] uses [atk_verb] on [D]!</span>", \
					  "<span class='userdanger'>[A] uses [atk_verb] on you!</span>")
		if(prob(D.getBruteLoss()) && !D.lying)
			D.visible_message("<span class='warning'>[A] sends [D] to the ground with holy energies!</span>", "<span class='userdanger'>An unseen force sends swipes you off your feet!</span>")
			D.Knockdown(80)
			playsound(D), 'sound/effects/pray.ogg', 25, 1, -1)
			add_logs(A, D, " used [atk_verb] (Hand of God) on")
			return TRUE
		playsound(get_turf(D), 'sound/weapons/punchmiss.ogg', 25, 1, -1)
		add_logs(A, D, " used [atk_verb] (Hand of God) on")
		return TRUE

