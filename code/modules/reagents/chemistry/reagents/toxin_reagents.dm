
//////////////////////////Poison stuff (Toxins & Acids)///////////////////////

/datum/reagent/toxin
	name = "Toxin"
	id = "toxin"
	description = "A toxic chemical."
	color = "#CF3600" // rgb: 207, 54, 0
	var/toxpwr = 1.5

/datum/reagent/toxin/on_mob_life(mob/living/M)
	if(toxpwr)
		M.adjustToxLoss(toxpwr*REM, 0)
		. = 1
	..()

/datum/reagent/toxin/amatoxin
	name = "Amatoxin"
	id = "amatoxin"
	description = "A powerful poison derived from certain species of mushroom."
	color = "#792300" // rgb: 121, 35, 0
	toxpwr = 2.5

/datum/reagent/toxin/mutagen
	name = "Unstable mutagen"
	id = "mutagen"
	description = "Might cause unpredictable mutations. Keep away from children."
	color = "#00FF00"
	toxpwr = 0

/datum/reagent/toxin/mutagen/reaction_mob(mob/living/carbon/M, method=TOUCH, reac_volume)
	if(!..())
		return
	if(!M.has_dna())
		return  //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	if((method==VAPOR && prob(min(33, reac_volume))) || method==INGEST || method==PATCH || method==INJECT)
		randmuti(M)
		if(prob(98))
			randmutb(M)
		else
			randmutg(M)
		M.updateappearance()
		M.domutcheck()
	..()

/datum/reagent/toxin/mutagen/on_mob_life(mob/living/carbon/M)
	if(istype(M))
		M.apply_effect(5,IRRADIATE,0)
	return ..()

/datum/reagent/toxin/plasma
	name = "Plasma"
	id = "plasma"
	description = "Plasma in its liquid form."
	color = "#8228A0"
	toxpwr = 3

/datum/reagent/toxin/plasma/on_mob_life(mob/living/M)
	if(holder.has_reagent("epinephrine"))
		holder.remove_reagent("epinephrine", 2*REM)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.adjustPlasma(20)
	return ..()

/datum/reagent/toxin/plasma/reaction_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))
		return 0
	O.atmos_spawn_air("plasma=[reac_volume];TEMP=[T20C]")

/datum/reagent/toxin/plasma/reaction_turf(turf/open/T, reac_volume)
	if(istype(T))
		T.atmos_spawn_air("plasma=[reac_volume];TEMP=[T20C]")
	return

/datum/reagent/toxin/plasma/reaction_mob(mob/living/M, method=TOUCH, reac_volume)//Splashing people with plasma is stronger than fuel!
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH || method == VAPOR)
		M.adjust_fire_stacks(reac_volume / 5)
		return
	..()

/datum/reagent/toxin/lexorin
	name = "Lexorin"
	id = "lexorin"
	description = "A powerful poison used to stop respiration."
	color = "#7DC3A0"
	toxpwr = 0

/datum/reagent/toxin/lexorin/on_mob_life(mob/living/M)
	. = TRUE
	var/mob/living/carbon/C
	if(iscarbon(M))
		C = M
		CHECK_DNA_AND_SPECIES(C)
		if(NOBREATH in C.dna.species.specflags)
			. = FALSE

	if(.)
		M.adjustOxyLoss(5, 0)
		if(C)
			C.losebreath += 2
		if(prob(20))
			M.emote("gasp")
	..()

/datum/reagent/toxin/slimejelly
	name = "Slime Jelly"
	id = "slimejelly"
	description = "A gooey semi-liquid produced from one of the deadliest lifeforms in existence. SO REAL."
	color = "#801E28" // rgb: 128, 30, 40
	toxpwr = 0

/datum/reagent/toxin/slimejelly/on_mob_life(mob/living/M)
	if(prob(10))
		M << "<span class='danger'>Your insides are burning!</span>"
		M.adjustToxLoss(rand(20,60)*REM, 0)
		. = 1
	else if(prob(40))
		M.heal_organ_damage(5*REM,0, 0)
		. = 1
	..()

/datum/reagent/toxin/minttoxin
	name = "Mint Toxin"
	id = "minttoxin"
	description = "Useful for dealing with undesirable customers."
	color = "#CF3600" // rgb: 207, 54, 0
	toxpwr = 0

/datum/reagent/toxin/minttoxin/on_mob_life(mob/living/M)
	if(M.disabilities & FAT)
		M.gib()
	return ..()

/datum/reagent/toxin/carpotoxin
	name = "Carpotoxin"
	id = "carpotoxin"
	description = "A deadly neurotoxin produced by the dreaded spess carp."
	color = "#003333" // rgb: 0, 51, 51
	toxpwr = 2

/datum/reagent/toxin/zombiepowder
	name = "Zombie Powder"
	id = "zombiepowder"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0
	toxpwr = 0.5

/datum/reagent/toxin/zombiepowder/on_mob_life(mob/living/carbon/M)
	M.status_flags |= FAKEDEATH
	M.adjustOxyLoss(0.5*REM, 0)
	M.Weaken(5, 0)
	M.silent = max(M.silent, 5)
	M.tod = worldtime2text()
	..()
	. = 1

/datum/reagent/toxin/zombiepowder/on_mob_delete(mob/M)
	M.status_flags &= ~FAKEDEATH
	..()

/datum/reagent/toxin/mindbreaker
	name = "Mindbreaker Toxin"
	id = "mindbreaker"
	description = "A powerful hallucinogen. Not a thing to be messed with."
	color = "#B31008" // rgb: 139, 166, 233
	toxpwr = 0

/datum/reagent/toxin/mindbreaker/on_mob_life(mob/living/M)
	M.hallucination += 10
	return ..()

/datum/reagent/toxin/plantbgone
	name = "Plant-B-Gone"
	id = "plantbgone"
	description = "A harmful toxic mixture to kill plantlife. Do not ingest!"
	color = "#49002E" // rgb: 73, 0, 46
	toxpwr = 1

/datum/reagent/toxin/plantbgone/reaction_obj(obj/O, reac_volume)
	if(istype(O,/obj/structure/alien/weeds))
		var/obj/structure/alien/weeds/alien_weeds = O
		alien_weeds.take_damage(rand(15,35), BRUTE, 0) // Kills alien weeds pretty fast
	else if(istype(O,/obj/effect/glowshroom)) //even a small amount is enough to kill it
		qdel(O)
	else if(istype(O,/obj/effect/spacevine))
		var/obj/effect/spacevine/SV = O
		SV.on_chem_effect(src)

/datum/reagent/toxin/plantbgone/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == VAPOR)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(!C.wear_mask) // If not wearing a mask
				var/damage = min(round(0.4*reac_volume, 0.1),10)
				C.adjustToxLoss(damage)

/datum/reagent/toxin/plantbgone/weedkiller
	name = "Weed Killer"
	id = "weedkiller"
	description = "A harmful toxic mixture to kill weeds. Do not ingest!"
	color = "#4B004B" // rgb: 75, 0, 75

/datum/reagent/toxin/pestkiller
	name = "Pest Killer"
	id = "pestkiller"
	description = "A harmful toxic mixture to kill pests. Do not ingest!"
	color = "#4B004B" // rgb: 75, 0, 75
	toxpwr = 1

/datum/reagent/toxin/pestkiller/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == VAPOR)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(!C.wear_mask) // If not wearing a mask
				var/damage = min(round(0.4*reac_volume, 0.1),10)
				C.adjustToxLoss(damage)

/datum/reagent/toxin/spore
	name = "Spore Toxin"
	id = "spore"
	description = "A natural toxin produced by blob spores that inhibits vision when ingested."
	color = "#9ACD32"
	toxpwr = 1

/datum/reagent/toxin/spore/on_mob_life(mob/living/M)
	M.damageoverlaytemp = 60
	M.update_damage_hud()
	M.blur_eyes(3)
	return ..()

/datum/reagent/toxin/spore_burning
	name = "Burning Spore Toxin"
	id = "spore_burning"
	description = "A natural toxin produced by blob spores that induces combustion in its victim."
	color = "#9ACD32"
	toxpwr = 0.5

/datum/reagent/toxin/spore_burning/on_mob_life(mob/living/M)
	M.adjust_fire_stacks(2)
	M.IgniteMob()
	return ..()

/datum/reagent/toxin/chloralhydrate
	name = "Chloral Hydrate"
	id = "chloralhydrate"
	description = "A powerful sedative that induces confusion and drowsiness before putting its target to sleep."
	reagent_state = SOLID
	color = "#000067" // rgb: 0, 0, 103
	toxpwr = 0
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/toxin/chloralhydrate/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 10)
			M.confused += 2
			M.drowsyness += 2
		if(10 to 50)
			M.Sleeping(2, 0)
			. = 1
		if(51 to INFINITY)
			M.Sleeping(2, 0)
			M.adjustToxLoss((current_cycle - 50)*REM, 0)
			. = 1
	..()

/datum/reagent/toxin/chloralhydrate/delayed
	id = "chloralhydrate2"

/datum/reagent/toxin/chloralhydrate/delayed/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 10)
			return
		if(10 to 20)
			M.confused += 1
			M.drowsyness += 1
		if(20 to INFINITY)
			M.Sleeping(2, 0)
	..()

/datum/reagent/toxin/beer2	//disguised as normal beer for use by emagged brobots
	name = "Beer"
	id = "beer2"
	description = "A specially-engineered sedative disguised as beer. It induces instant sleep in its target."
	color = "#664300" // rgb: 102, 67, 0
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/toxin/beer2/on_mob_life(mob/living/M)
	switch(current_cycle)
		if(1 to 50)
			M.Sleeping(2, 0)
		if(51 to INFINITY)
			M.Sleeping(2, 0)
			M.adjustToxLoss((current_cycle - 50)*REM, 0)
	return ..()

/datum/reagent/toxin/coffeepowder
	name = "Coffee Grounds"
	id = "coffeepowder"
	description = "Finely ground coffee beans, used to make coffee."
	reagent_state = SOLID
	color = "#5B2E0D" // rgb: 91, 46, 13
	toxpwr = 0.5

/datum/reagent/toxin/teapowder
	name = "Ground Tea Leaves"
	id = "teapowder"
	description = "Finely shredded tea leaves, used for making tea."
	reagent_state = SOLID
	color = "#7F8400" // rgb: 127, 132, 0
	toxpwr = 0.5

/datum/reagent/toxin/mutetoxin //the new zombie powder.
	name = "Mute Toxin"
	id = "mutetoxin"
	description = "A nonlethal poison that inhibits speech in its victim."
	color = "#F0F8FF" // rgb: 240, 248, 255
	toxpwr = 0

/datum/reagent/toxin/mutetoxin/on_mob_life(mob/living/carbon/M)
	M.silent = max(M.silent, 3)
	..()

/datum/reagent/toxin/staminatoxin
	name = "Tirizene"
	id = "tirizene"
	description = "A nonlethal poison that causes extreme fatigue and weakness in its victim."
	color = "#6E2828"
	data = 13
	toxpwr = 0

/datum/reagent/toxin/staminatoxin/on_mob_life(mob/living/carbon/M)
	M.adjustStaminaLoss(REM * data, 0)
	data = max(data - 1, 3)
	..()
	. = 1

/datum/reagent/toxin/heparin //Based on a real-life anticoagulant. I'm not a doctor, so this won't be realistic.
	name = "Heparin"
	id = "heparin"
	description = "A powerful anticoagulant. Victims will bleed uncontrollably and suffer scaling bruising."
	reagent_state = LIQUID
	color = "#C8C8C8" //RGB: 200, 200, 200
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	toxpwr = 0

/datum/reagent/toxin/heparin/on_mob_life(mob/living/M)
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.blood_max += 2
		H.adjustBruteLoss(1, 0) //Brute damage increases with the amount they're bleeding
		. = 1
	return ..() || .

/datum/reagent/toxin/teslium //Teslium. Causes periodic shocks, and makes shocks against the target much more effective.
	name = "Teslium"
	id = "teslium"
	description = "An unstable, electrically-charged metallic slurry. Periodically electrocutes its victim, and makes electrocutions against them more deadly."
	reagent_state = LIQUID
	color = "#20324D" //RGB: 32, 50, 77
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	toxpwr = 0
	var/shock_timer = 0

/datum/reagent/toxin/teslium/on_mob_life(mob/living/M)
	shock_timer++
	if(shock_timer >= rand(5,30)) //Random shocks are wildly unpredictable
		shock_timer = 0
		M.electrocute_act(rand(5,20), "Teslium in their body", 1, 1) //Override because it's caused from INSIDE of you
		playsound(M, "sparks", 50, 1)
	..()


//ACID


/datum/reagent/toxin/acid
	name = "Sulphuric acid"
	id = "sacid"
	description = "A strong mineral acid with the molecular formula H2SO4."
	color = "#00FF32"
	toxpwr = 1
	var/acidpwr = 10 //the amount of protection removed from the armour

/datum/reagent/toxin/acid/reaction_mob(mob/living/carbon/C, method=TOUCH, reac_volume)
	if(!istype(C))
		return
	reac_volume = round(reac_volume,0.1)
	if(method == INGEST)
		C.adjustBruteLoss(min(6*toxpwr, reac_volume * toxpwr))
		return
	if(method == INJECT)
		C.adjustBruteLoss(1.5 * min(6*toxpwr, reac_volume * toxpwr))
		return
	C.acid_act(acidpwr, toxpwr, reac_volume)

/datum/reagent/toxin/acid/reaction_obj(obj/O, reac_volume)
	if(istype(O.loc, /mob)) //handled in human acid_act()
		return
	reac_volume = round(reac_volume,0.1)
	O.acid_act(acidpwr, reac_volume)

/datum/reagent/toxin/acid/reaction_turf(turf/T, reac_volume)
	if (!istype(T))
		return
	reac_volume = round(reac_volume,0.1)
	for(var/obj/O in T)
		O.acid_act(acidpwr, reac_volume)

/datum/reagent/toxin/acid/fluacid
	name = "Fluorosulfuric acid"
	id = "facid"
	description = "Fluorosulfuric acid is a an extremely corrosive chemical substance."
	color = "#5050FF"
	toxpwr = 2
	acidpwr = 42.0

/datum/reagent/toxin/acid/fluacid/on_mob_life(mob/living/M)
	M.adjustFireLoss(current_cycle/10, 0) // I rode a tank, held a general's rank
	. = 1 // When the blitzkrieg raged and the bodies stank
	..() // Pleased to meet you, hope you guess my name

/datum/reagent/toxin/peaceborg/confuse
	name = "Dizzying Solution"
	id = "dizzysolution"
	description = "Makes the target off balance and dizzy"
	toxpwr = 0
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/toxin/peaceborg/confuse/on_mob_life(mob/living/M)
	M.confused += 1
	M.Dizzy(1)
	if(prob(20))
		M << "You feel confused and disorientated."
	..()

/datum/reagent/toxin/peaceborg/tire
	name = "Tiring Solution"
	id = "tiresolution"
	description = "An extremely weak stamina-toxin that tires out the target. Completely harmless."
	toxpwr = 0
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/toxin/peaceborg/tire/on_mob_life(mob/living/M)
	if(M.staminaloss < 50)
		M.adjustStaminaLoss(10)
	if(prob(30))
		M << "You should sit down and take a rest..."
	..()