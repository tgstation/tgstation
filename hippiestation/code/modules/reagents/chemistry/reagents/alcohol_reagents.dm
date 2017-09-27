/datum/reagent/consumable/ethanol/impalco
	name = "Impure Superhol"
	id = "impalco"
	description = "An impure solution of superhol, still very strong!"
	color = "#CAD15A"
	boozepwr = 100
	taste_description = "brain damage"
	glass_name = "Cloudy Superhol"
	glass_desc = "Despite being obviously impure and revolting the vapours are still intense enough to make you feel tipsy"
	metabolization_rate = 2 * REAGENTS_METABOLISM

/datum/reagent/consumable/ethanol/alco
	name = "Superhol"
	id = "alco"
	description = "An incredibly potent form of synthetic ethanol"
	color = "#CAD15A"
	boozepwr = 350
	taste_description = "brain death"
	taste_mult = 2
	glass_name = "Superhol"
	glass_desc = "Just looking at it is making you dizzy!"

/datum/reagent/consumable/ethanol/alco/on_mob_life(mob/living/carbon/M)
	if(istype(M))
		switch(current_cycle)
			if(1 to 15)
				M.adjustBrainLoss(3)
				if(prob(15))
					M.vomit(20)
			if(20 to INFINITY)
				M.adjustBrainLoss(5)
				if(prob(30))
					M.vomit(20, 0, 8)
					if(prob(10))
						M.spew_organ()
	..()

/datum/reagent/consumable/ethanol/isopropyl
	name = "Isopropyl alcohol"
	id = "isopropyl"
	description = "Can make you sick and drunk at the same time. Amazing!"
	color = "#C8A5DC"

/datum/reagent/consumable/ethanol/isoproyl/on_mob_life(mob/living/M)
	M.adjustToxLoss(1)
	..()
	
/datum/reagent/consumable/ethanol/ale
	nutriment_factor = 1 * REAGENTS_METABOLISM
	
/datum/reagent/consumable/ethanol/beer/on_mob_life(mob/living/M)
	M.jitteriness = max(0,M.jitteriness-5)
	..()
	. = 1
	
/datum/reagent/consumable/ethanol/whiskey/on_mob_life(mob/living/M)
	if(ishuman(M) && M.job in list("Detective"))
		M.adjustBruteLoss(-0.5, 0)
		. = 1
	..()
	
/datum/reagent/consumable/ethanol/threemileisland/on_mob_life(mob/living/M)
	M.radiation = max(M.radiation-4,0)
	M.set_drugginess(50)
	return ..()
	
/datum/reagent/consumable/ethanol/gin/on_mob_life(mob/living/M)
	M.hallucination = max(0, M.hallucination - 4)
	. = 1
	..()
	
/datum/reagent/consumable/ethanol/vermouth/on_mob_life(mob/living/M)
	M.metabolism_efficiency = 1.30
	. = 1
	..()
	
/datum/reagent/consumable/ethanol/wine/on_mob_life(mob/living/M)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.blood_volume < BLOOD_VOLUME_NORMAL)
			C.blood_volume += 0.5
	..()
	
/datum/reagent/consumable/ethanol/grappa/on_mob_life(mob/living/M)
	M.metabolism_efficiency = 1.30
	..()
	
/datum/reagent/consumable/ethanol/cognac/on_mob_life(mob/living/M)
	if(ishuman(M) && M.job in list("Mime"))
		M.heal_bodypart_damage(0.5,0.5, 0)
		. = 1
	..()
	
/datum/reagent/consumable/ethanol/hooch/on_mob_life(mob/living/M)
	if(prob(10))
		M.emote("scream")
	..()
	
/datum/reagent/consumable/ethanol/whiskey_cola/on_mob_life(mob/living/M)
	if(ishuman(M) && M.job in list("Detective"))
		M.adjustFireLoss(-0.5, 0)
		. = 1
	..()
	
/datum/reagent/consumable/ethanol/white_russian/on_mob_life(mob/living/M)
	var/light_amount = 0
	if(isturf(M.loc))
		var/turf/T = M.loc
		light_amount = min(1,T.get_lumcount()) - 0.5
		if(light_amount > 0.2)
			M.adjustToxLoss(-1)
			M.adjustOxyLoss(-1)
			M.adjustStaminaLoss(-1*REM, 0)
		..()
		
/datum/reagent/consumable/ethanol/booger/on_mob_life(mob/living/M)
	if(prob(30))
		M.emote("sneeze")
		M.say(pick("ACHOO!!","ACHNK!!","ASNRK!!","CHU!","ACHOOEY!!","ACHSK!!"))
		. = 1
	..()

/datum/reagent/consumable/ethanol/manly_dorf/on_mob_add(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.facial_hair_style = "Dwarf Beard"
		H.update_hair()
		if(H.dna.check_mutation(DWARFISM))
			to_chat(H, "<span class='notice'>Now THAT is MANLY!</span>")
			boozepwr = 5 //We've had worse in the mines
			dorf_mode = TRUE
		..()

/datum/reagent/consumable/ethanol/moonshine/on_mob_life(mob/living/M)
	if(prob(20))
		M.say(pick("YEE HAW!!","YEEE HAAW!!","YEEEE HAAAW!!","YEEEEE HAAAAW!!","YEEEEEE HAAAAAW!!","YEEEEEEE HAAAAAAW!!","YEEEEEEEE HAAAAAAAW!!"))
	..()
	
/datum/reagent/consumable/ethanol/black_russian/on_mob_life(mob/living/M)
	var/light_amount = 0
	if(isturf(M.loc))
		var/turf/T = M.loc
		light_amount = min(1,T.get_lumcount()) - 0.5
		if(light_amount < 0.2)
			M.adjustToxLoss(-1)
			M.adjustOxyLoss(-1)
			M.adjustStaminaLoss(-1*REM, 0)
		..()
		
/datum/reagent/consumable/ethanol/manhattan/on_mob_life(mob/living/M)
	if(prob(20)) //may cause involuntary brawls
		M.say(pick("FUCKIN' SHIT!!","JESUS CHRIST!!","AAASSSSSS!!","FUCKER!!","SHITBIRD!!","FUCK YOURSELF!!","GET OFF THE FUCKIN' ROAD!!","EAT SHIT!!","EAT A DICK, PAL!!","GET FUCKED!!","TRY ME, COCKSUCKER!!","JUMP UP YOUR OWN ASS!!","BADA BING!!","YOU TALKIN' TO ME?!!","FUCK OUTTA HERE!!","EY, I'M WALKIN' HERE!!"))
	..()
	
/datum/reagent/consumable/ethanol/whiskeysoda/on_mob_life(mob/living/M)
	if(ishuman(M) && M.job in list("Detective"))
		M.adjustToxLoss(-0.5, 0)
		. = 1
	..()
	
/datum/reagent/consumable/ethanol/bahama_mama/on_mob_life(mob/living/M)
	M.stuttering = 0
	M.slurring = 0
	..()
	
/datum/reagent/consumable/ethanol/singulo/on_mob_life(mob/living/M)
	for(var/datum/reagent/R in M.reagents.reagent_list)
		if(R != src)
			M.reagents.remove_reagent(R.id,2)
		. = 1
		..()

/datum/reagent/consumable/ethanol/mead/on_mob_life(mob/living/M)
	if(prob(10))
		M.reagents.add_reagent("honey",2)
	..()
	
/datum/reagent/consumable/ethanol/grog/on_mob_life(mob/living/M)
	if (M.bodytemperature < 330)
		M.bodytemperature = min(330, M.bodytemperature + (20 * TEMPERATURE_DAMAGE_COEFFICIENT))
	return ..()
	
/datum/reagent/consumable/ethanol/aloe/on_mob_life(mob/living/M)
	M.adjustFireLoss(-1*REM, 0)
	..()
	. = 1
	
/datum/reagent/consumable/ethanol/acid_spit/on_mob_life(mob/living/M)
	M.nutrition = max(M.nutrition - 1.5, 0)
	M.overeatduration = 0
	return ..()
	
/datum/reagent/consumable/ethanol/irishcarbomb/on_mob_life(mob/living/M) //sorry, irish
	if(prob(5))
		playsound(get_turf(M), 'sound/effects/explosionfar.ogg', 100, 1)
	return ..()
	
/datum/reagent/consumable/ethanol/driestmartini/reaction_turf(turf/open/T, reac_volume)
	if(istype(T) && T.wet)
		T.wet_time = max(0, T.wet_time-reac_volume*5)
		T.HandleWet()
		
/datum/reagent/consumable/ethanol/martini/on_mob_life(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(istype(H) && istype(H.wear_suit, /obj/item/clothing/under/suit_jacket))
			M.adjustBruteLoss(-0.25, 0)
			M.adjustFireLoss(-0.25, 0)
			M.adjustToxLoss(-0.25, 0)
			M.adjustOxyLoss(-0.25, 0)
			. = 1
		..()
