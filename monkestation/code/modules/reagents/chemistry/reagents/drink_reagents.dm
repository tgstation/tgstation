/datum/reagent/consumable/baja_blast
	name = "Baja Blast"
	description = "A substance applied to the skin by gamers to lighten the skin."
	color = "#63FFE0" // Teal
	metabolization_rate = 10 * REAGENTS_METABOLISM // very fast, so it can be applied rapidly.  But this changes on an overdose
	overdose_threshold = 11 //Slightly more than one un-nozzled spraybottle.
	taste_description = "lime and the tropics"

/datum/reagent/consumable/baja_blast/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	if(ishuman(M))
		if(method == PATCH || method == VAPOR)
			var/mob/living/carbon/human/N = M
			if(ishumanbasic(M)) //Lighten skin
				switch(N.skin_tone)
					if("african2")
						N.skin_tone = "african1"
					if("african1")
						N.skin_tone = "indian"
					if("indian")
						N.skin_tone = "arab"
					if("arab")
						N.skin_tone = "asian2"
					if("asian2")
						N.skin_tone = "asian1"
					if("african1")
						N.skin_tone = "mediterranean"
					if("latino", "mediterranean","caucasian3")
						N.skin_tone = "caucasian2"
					if("caucasian2")
						N.skin_tone = "caucasian1"
					if("caucasian1")
						N.skin_tone = "albino"

			if(MUTCOLORS in N.dna.species.species_traits)
				N.dna.features["mcolor"] = random_short_color()

			N.regenerate_icons()
	..()

/datum/reagent/consumable/baja_blast/overdose_process(mob/living/M)
	metabolization_rate = 1 * REAGENTS_METABOLISM
	if(prob(3))
		M.say(pick(	"Poggers.", "Swag.", "Bruh.", "You're such a bot.", "You need a nerf, bro.",
					"I need a buff, bro.", "Stop cheesing.", "Rush B.", "Rush A.",
					"No camping.", "Look, an easter egg.", "GG no RE!", "Damn RNG!",
					"Noob.", "POGCHAMP!!", "A new PB!"), forced = /datum/reagent/consumable/baja_blast) //This doesn't deserve a string file. I have to repress gamers.
		return
	if(prob(3))
		M.visible_message("<span class = 'warning'>[pick("[M] flexes their gamer skills.",
														"[M] looks incredibly smug.",
														"The scent of soda hangs in the air around [M]",
														"[M] turns to face a precise angle for a glitch skip.",
														"[M] T-poses threateningly.",
														"[M] begins building momentum.",
														"[M] prepares for an accelerated back hop.",
														"[M] splits the segment here.")]</span>")
		return
	..()
	return
/datum/reagent/consumable/baja_blast/on_mob_life(mob/living/carbon/M)
	M.Jitter(20)
	M.dizziness = min(5,M.dizziness+1)
	M.drowsyness = 0
	M.AdjustSleeping(-40)
	M.adjust_bodytemperature(-5 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/baja_blast/on_mob_metabolize(mob/living/L)
	..()
	if(ismonkey(L))
		L.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=-0.75, blacklisted_movetypes=(FLYING|FLOATING))

/datum/reagent/consumable/baja_blast/on_mob_end_metabolize(mob/living/L)
	L.remove_movespeed_modifier(type)
	..()

/datum/reagent/consumable/baja_blast/overdose_start(mob/living/M)
	. = ..()
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	if(!(HAIR in H.dna.species.species_traits)) //No hair? No problem!
		H.dna.species.species_traits += HAIR
	H.hair_style = "Spiky"
	H.facial_hair_style = "Shaved"
	H.facial_hair_color = "000"
	H.hair_color = "0ff"
	if(SKINTONES in H.dna.species.species_traits)
		H.skin_tone = "caucasian1"
	else if(MUTCOLORS in H.dna.species.species_traits)
		H.dna.features["mcolor"] = "fffbf5"
	H.regenerate_icons()
	H.grant_language(/datum/language/zoomercant, TRUE, TRUE, "spray")

/datum/reagent/consumable/monkey_energy
	overdose_threshold = 30

/datum/reagent/consumable/monkey_energy/overdose_start(mob/living/M)
	. = ..()
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	if(!(HAIR in H.dna.species.species_traits)) //No hair? No problem!
		H.dna.species.species_traits += HAIR
	H.hair_style = "Balding Hair"
	H.facial_hair_style = "Shaved"
	H.facial_hair_color = "000"
	H.hair_color = "000"
	if(SKINTONES in H.dna.species.species_traits)
		H.skin_tone = "albino"
	else if(MUTCOLORS in H.dna.species.species_traits)
		H.dna.features["mcolor"] = "fff"
	H.regenerate_icons()
	H.grant_language(/datum/language/sippins, TRUE, TRUE, "spray")
