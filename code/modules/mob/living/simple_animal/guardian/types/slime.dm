//Healer
/mob/living/simple_animal/hostile/guardian/slime
	a_intent = INTENT_HARM
	friendly_verb_continuous = "heals"
	friendly_verb_simple = "heal"
	speed = 0
	damage_coeff = list(BRUTE = 0.7, BURN = 0.7, TOX = 0.7, CLONE = 0.7, STAMINA = 0, OXY = 0.7)
	melee_damage_lower = 10
	melee_damage_upper = 10
	playstyle_string = "<span class='holoparasite'>As a <b>slime support</b> type, you may toggle your basic attacks to a healing mode. In addition, your attacks feed slimes.</span>"
	magic_fluff_string = "<span class='holoparasite'>..And draw the CMO, a potent force of life... and death.</span>"
	carp_fluff_string = "<span class='holoparasite'>CARP CARP CARP! You caught a support carp. It's a kleptocarp!</span>"
	tech_fluff_string = "<span class='holoparasite'>Boot sequence complete. Support modules active. Holoparasite swarm online.</span>"
	miner_fluff_string = "<span class='holoparasite'>You encounter... Bluespace, the master of support.</span>"
	toggle_button_type = /obj/screen/guardian/toggle_mode
	var/obj/structure/receiving_pad/beacon
	var/beacon_cooldown = 0
	var/toggle = FALSE

/mob/living/simple_animal/hostile/guardian/slime/Initialize()
	. = ..()
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(src)

/mob/living/simple_animal/hostile/guardian/slime/AttackingTarget()
	. = ..()
	if(isslime(target))
		var/mob/living/simple_animal/slime/slime = target
		slime.add_nutrition(rand(14, 30))
		return

	if(is_deployed() && toggle && iscarbon(target))
		var/mob/living/carbon/C = target
		C.adjustBruteLoss(-2.5)
		C.adjustFireLoss(-2.5)
		C.adjustOxyLoss(-2.5)
		C.adjustToxLoss(-2.5)
		var/obj/effect/temp_visual/heal/H = new /obj/effect/temp_visual/heal(get_turf(C))
		if(guardiancolor)
			H.color = guardiancolor
		if(C == summoner)
			update_health_hud()
			med_hud_set_health()
			med_hud_set_status()

/mob/living/simple_animal/hostile/guardian/slime/ToggleMode()
	if(src.loc == summoner)
		if(toggle)
			a_intent = INTENT_HARM
			speed = 0
			damage_coeff = list(BRUTE = 0.7, BURN = 0.7, TOX = 0.7, CLONE = 0.7, STAMINA = 0, OXY = 0.7)
			melee_damage_lower = 15
			melee_damage_upper = 15
			to_chat(src, "<span class='danger'><B>You switch to combat mode.</span></B>")
			toggle = FALSE
		else
			a_intent = INTENT_HELP
			speed = 1
			damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1)
			melee_damage_lower = 0
			melee_damage_upper = 0
			to_chat(src, "<span class='danger'><B>You switch to healing mode.</span></B>")
			toggle = TRUE
	else
		to_chat(src, "<span class='danger'><B>You have to be recalled to toggle modes!</span></B>")


