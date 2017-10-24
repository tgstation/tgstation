/datum/reagent/medicine/synaptizine/on_mob_life(mob/living/M)
	M.drowsyness = max(M.drowsyness-5, 0)
	if(holder.has_reagent("mindbreaker"))
		holder.remove_reagent("mindbreaker", 5)
	M.hallucination = max(0, M.hallucination - 10)
	if(prob(30))
		M.adjustToxLoss(1, 0)
	return FINISHONMOBLIFE(M)

/datum/reagent/medicine/ephedrine/on_mob_life(mob/living/M)
	M.status_flags |= GOTTAGOFAST
	M.reagents.remove_reagent("nutriment", rand(0,3))
	M.reagents.remove_reagent("vitamin", rand(0,3))
	if(prob(34))
		M.nutrition = max(M.nutrition - rand(0,10), 1) //Cannot go below 1.
	return FINISHONMOBLIFE(M)

/datum/reagent/medicine/atropine/on_mob_life(mob/living/M)
	M.reagents.remove_all_type(/datum/reagent/toxin/sarin, 1*REM, 0, 1)
	M.reagents.remove_all_type(/datum/reagent/toxin/tabun, 1*REM, 0, 1)
	M.reagents.remove_all_type(/datum/reagent/toxin/sarin_a, 1*REM, 0, 1)
	M.reagents.remove_all_type(/datum/reagent/toxin/sarin_b, 1*REM, 0, 1)

	if(M.health < 0)
		M.adjustToxLoss(-2*REM, 0)
		M.adjustBruteLoss(-2*REM, 0)
		M.adjustFireLoss(-2*REM, 0)
		M.adjustOxyLoss(-5*REM, 0)
		. = 1
	M.losebreath = 0
	if(prob(20))
		M.Dizzy(5)
		M.Jitter(5)
	return FINISHONMOBLIFE(M)

/datum/reagent/medicine/superzine
	name = "Superzine"
	id = "superzine"
	description = "An extremely effective muscle stimulant and stamina restorer."
	color = "#C8A5DC" // rgb: 200, 165, 220
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	overdose_threshold = 40

datum/reagent/medicine/superzine/on_mob_life(mob/living/M as mob)
	if(prob(15))
		M.emote(pick("twitch","blink_r","shiver"))
	M.status_flags |= GOTTAGOFAST
	M.adjustStaminaLoss(-5)
	if(prob(2))
		M<<"<span class='danger'>You collapse suddenly!"
		M.emote("collapse")
		M.Knockdown(30, 0)
	..()

/datum/reagent/medicine/superzine/overdose_process(mob/living/M)
	if(prob(5))//changed from gib to heart attack
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			if(!H.undergoing_cardiac_arrest() && H.can_heartattack())
				H.set_heartattack(TRUE)
				if(H.stat == CONSCIOUS)
					H.visible_message("<span class='userdanger'>[H] clutches at [H.p_their()] chest as if [H.p_their()] heart stopped!</span>")

/datum/reagent/medicine/defib
	name = "Exstatic mixture"
	id = "defib"
	description = "An amazing chemical that can bring the dead back to life!"
	color = "#C8A5DC" // rgb: 200, 165, 220
	metabolization_rate = 4 * REAGENTS_METABOLISM
	taste_description = "electricity"

/datum/reagent/medicine/defib/on_mob_life(mob/living/M, reac_volume)
	M.electrocute_act((reac_volume * 0.5), "exstatic mixture")//changed from being instant death to those who are still alive
	..()

/datum/reagent/medicine/defib/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(M.stat == DEAD)
		M.electrocute_act(1, "exstatic mixture")
		if(!M.suiciding && !(M.disabilities & NOCLONE) && !M.hellbound)
			if(!M)
				return
			if(M.notify_ghost_cloning(source = M))
				spawn (100) //so the ghost has time to re-enter
					return
			else
				holder.clear_reagents()
				M.revive(full_heal = TRUE)
				M.adjustToxLoss(95)//you get revived near crit
				M.updatehealth()
				M.emote("gasp")
				add_logs(M, M, "revived", src)

/datum/reagent/medicine/sodiumf
	name = "Sodium fluoride"
	id = "sodiumf"
	description = "A powerful antitoxin"
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/medicine/sodiumf/on_mob_life(mob/living/M)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(prob(5))
			C.vomit(20)//no longer oxyloss deathchem
		C.reagents.remove_all_type(/datum/reagent/toxin, 1*REM, 0, 1)
		C.hallucination = max(0, M.hallucination - 5*REM)
		C.adjustToxLoss(-7*REM)
	else
		return
	..()

/datum/reagent/medicine/aluminiumf
	name = "Aluminium fluorate"
	id = "aluminiumf"
	description = "A powerful burn and brute healing chemical that is slightly toxic"
	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/medicine/aluminiumf/on_mob_life(mob/living/M)
	M.adjustToxLoss(1)//deals minor toxin damage  designed to be very potent
	M.hallucination++ //just a weeny bit
	M.adjustFireLoss(-5 * REM)
	M.adjustBruteLoss(-5 * REM)
	..()

/datum/reagent/medicine/liquid_life
	name = "Liquid Life"
	id = "liquid_life"
	description = "The purest form of healing avaliable, unfortunately extremely painful for the user when regenerating"
	color = "#C8A5DC" // rgb: 200, 165, 220
	overdose_threshold = 40 //gib nuke
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	taste_description = "the tastiest taste"
	var/message= TRUE

/datum/reagent/medicine/liquid_life/on_mob_life(mob/living/M)//rebalanced to cripple the person being healed essentially acting as a sort of hunker down chem
	if(M.getBruteLoss() != 0 || M.getFireLoss() != 0 || M.getToxLoss() != 0)
		if(message == TRUE)
			to_chat(M, "<span class='warning'>You double over in pain as you begin to violently regenerate!</span>")
			M.emote("scream")
			message = FALSE
		M.setStaminaLoss(40)//or your devil
		M.drowsyness = max(M.drowsyness, 1)
		M.setToxLoss(0)//i can be yuor angle
		M.hallucination = 0
		M.adjustFireLoss(-10)
		M.adjustBruteLoss(-10)
	..()

/datum/reagent/medicine/liquid_life/overdose_process(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/turf/T = M.loc

		switch(current_cycle)
			if(4)
				to_chat(M, "<span class='warning'>You start to feel very bloated!</span>")
				H.resize = 1.1
				H.update_transform()

			if(8)
				to_chat(M, "<span class='userdanger'>Immense pain surges through your expanding body!</span>")
				H.bleed_rate = 8
				H.resize = 1.2
				H.update_transform()


			if(14)
				to_chat(M, "<span class='userdanger'>YOU FEEL LIKE YOU ARE ABOUT TO EXPLODE!</span>")
				H.vomit(20, 1, 5)
				H.resize = 1.4
				H.update_transform()

			if(20)
				H.vomit(20, 1, 5)
				M.Knockdown(100, 0)
				H.resize = 1.5
				H.update_transform()

			if(24)
				playsound(T, 'sound/magic/disintegrate.ogg', 200, 1, 8)
				for(var/I in 1 to 30)
					var/gibtype = pick(/obj/effect/decal/cleanable/blood/gibs/up, /obj/effect/decal/cleanable/blood/gibs/down, /obj/effect/decal/cleanable/blood/gibs, /obj/effect/decal/cleanable/blood/gibs, /obj/effect/decal/cleanable/blood/gibs/body, /obj/effect/decal/cleanable/blood/gibs/limb, /obj/effect/decal/cleanable/blood/gibs/core)
					var/obj/effect/decal/cleanable/blood/gibs/G = new gibtype(T)
					G.throw_at(get_edge_target_turf(T, pick(GLOB.alldirs)), rand(1,20), 1)

				for(var/turf/C in oview(T, 8))
					new /obj/effect/decal/cleanable/blood/splatter(C)
				var/datum/effect_system/reagents_explosion/e = new()
				e.set_up(5, T, 1, 2)
				e.start()
				holder.clear_reagents()
				M.gib()
				return ..()
	..()

datum/reagent/medicine/virogone
	name = "Cyclo-bromazine"
	id = "virogone"
	description = "Potent anti viral chemical that puts the user to sleep while purging nearly any viral agents very quickly"
	color = "#C8A5DC" // rgb: 200, 165, 220
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

datum/reagent/medicine/virogone/on_mob_life(mob/living/M)//cures viruses very effectively but puts you to sleep while doing so
	if(current_cycle <= 20)
		M.adjustToxLoss(0.5)
		for(var/datum/disease/D in M.viruses)
			if(D.severity == VIRUS_SEVERITY_NONTHREAT || D.agent == "N-G-T"|| !(D.disease_flags & 1))//last one checks if it's curable
				continue
			M.Sleeping(600, 0)//only puts to sleep if viruses are actually present so it isn't just instant chloral memes
			D.spread_text = "Remissive"
			D.stage--
			if(D.stage < 1)
				D.cure()
	..()

/datum/reagent/medicine/salglu_solution
	overdose_threshold = 0 //seriously fuck whoever thought this was a good idea.