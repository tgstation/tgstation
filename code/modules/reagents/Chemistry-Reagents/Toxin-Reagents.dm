
//////////////////////////Poison stuff (Toxins & Acids)///////////////////////

/datum/reagent/toxin
	name = "Toxin"
	id = "toxin"
	description = "A toxic chemical."
	color = "#CF3600" // rgb: 207, 54, 0
	var/toxpwr = 1.5

/datum/reagent/toxin/on_mob_life(var/mob/living/M as mob)
	if(toxpwr)
		M.adjustToxLoss(toxpwr*REM)
	..()
	return

/datum/reagent/toxin/amatoxin
	name = "Amatoxin"
	id = "amatoxin"
	description = "A powerful poison derived from certain species of mushroom."
	color = "#792300" // rgb: 121, 35, 0
	toxpwr = 1

/datum/reagent/toxin/mutagen
	name = "Unstable mutagen"
	id = "mutagen"
	description = "Might cause unpredictable mutations. Keep away from children."
	color = "#13BC5E" // rgb: 19, 188, 94
	toxpwr = 0

/datum/reagent/toxin/mutagen/reaction_mob(var/mob/living/carbon/M, var/method=TOUCH, var/volume)
	if(!..())
		return
	if(!istype(M) || !M.dna)
		return  //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	src = null
	if((method==TOUCH && prob(33)) || method==INGEST)
		randmuti(M)
		if(prob(98))
			randmutb(M)
		else
			randmutg(M)
		domutcheck(M, null)
		updateappearance(M)
	return

/datum/reagent/toxin/mutagen/on_mob_life(var/mob/living/carbon/M)
	if(istype(M))
		M.apply_effect(5,IRRADIATE,0)
	..()
	return

/datum/reagent/toxin/plasma
	name = "Plasma"
	id = "plasma"
	description = "Plasma in its liquid form."
	color = "#500064" // rgb: 80, 0, 100
	toxpwr = 3

/datum/reagent/toxin/plasma/on_mob_life(var/mob/living/M as mob)
	if(holder.has_reagent("epinephrine"))
		holder.remove_reagent("epinephrine", 2*REM)
	..()
	return

/datum/reagent/toxin/plasma/reaction_obj(var/obj/O, var/volume)
	src = null
	/*if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/egg/slime))
		var/obj/item/weapon/reagent_containers/food/snacks/egg/slime/egg = O
		if (egg.grown)
			egg.Hatch()*/
	if((!O) || (!volume))	return 0
	O.atmos_spawn_air(SPAWN_TOXINS|SPAWN_20C, volume)

/datum/reagent/toxin/plasma/reaction_turf(var/turf/simulated/T, var/volume)
	src = null
	if(istype(T))
		T.atmos_spawn_air(SPAWN_TOXINS|SPAWN_20C, volume)
	return

/datum/reagent/toxin/plasma/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//Splashing people with plasma is stronger than fuel!
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH)
		M.adjust_fire_stacks(volume / 5)
		return

/datum/reagent/toxin/lexorin
	name = "Lexorin"
	id = "lexorin"
	description = "Lexorin temporarily stops respiration. Causes tissue damage."
	color = "#C8A5DC" // rgb: 200, 165, 220
	toxpwr = 0

/datum/reagent/toxin/lexorin/on_mob_life(var/mob/living/M as mob)
	if(M.stat != DEAD)
		if(prob(33))
			M.take_organ_damage(1*REM, 0)
		M.adjustOxyLoss(3)
		if(prob(20))
			M.emote("gasp")
	..()
	return

/datum/reagent/toxin/slimejelly
	name = "Slime Jelly"
	id = "slimejelly"
	description = "A gooey semi-liquid produced from one of the deadliest lifeforms in existence. SO REAL."
	color = "#801E28" // rgb: 128, 30, 40
	toxpwr = 0

/datum/reagent/toxin/slimejelly/on_mob_life(var/mob/living/M as mob)
	if(prob(10))
		M << "<span class='danger'>Your insides are burning!</span>"
		M.adjustToxLoss(rand(20,60)*REM)
	else if(prob(40))
		M.heal_organ_damage(5*REM,0)
	..()
	return

/datum/reagent/toxin/minttoxin
	name = "Mint Toxin"
	id = "minttoxin"
	description = "Useful for dealing with undesirable customers."
	color = "#CF3600" // rgb: 207, 54, 0
	toxpwr = 0

/datum/reagent/toxin/minttoxin/on_mob_life(var/mob/living/M as mob)
	if (FAT in M.mutations)
		M.gib()
	..()
	return

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

/datum/reagent/toxin/zombiepowder/on_mob_life(var/mob/living/carbon/M as mob)
	M.status_flags |= FAKEDEATH
	M.adjustOxyLoss(0.5*REM)
	M.Weaken(5)
	M.silent = max(M.silent, 5)
	M.tod = worldtime2text()
	..()
	return

/datum/reagent/toxin/zombiepowder/on_mob_delete(mob/M)
	M.status_flags &= ~FAKEDEATH
	..()

/datum/reagent/toxin/mindbreaker
	name = "Mindbreaker Toxin"
	id = "mindbreaker"
	description = "A powerful hallucinogen. Not a thing to be messed with."
	color = "#B31008" // rgb: 139, 166, 233
	toxpwr = 0

/datum/reagent/toxin/mindbreaker/on_mob_life(var/mob/living/M)
	M.hallucination += 10
	..()
	return

/datum/reagent/toxin/plantbgone
	name = "Plant-B-Gone"
	id = "plantbgone"
	description = "A harmful toxic mixture to kill plantlife. Do not ingest!"
	color = "#49002E" // rgb: 73, 0, 46
	toxpwr = 1

/datum/reagent/toxin/plantbgone/reaction_obj(var/obj/O, var/volume)
	if(istype(O,/obj/structure/alien/weeds/))
		var/obj/structure/alien/weeds/alien_weeds = O
		alien_weeds.health -= rand(15,35) // Kills alien weeds pretty fast
		alien_weeds.healthcheck()
	else if(istype(O,/obj/effect/glowshroom)) //even a small amount is enough to kill it
		qdel(O)
	else if(istype(O,/obj/effect/spacevine))
		var/obj/effect/spacevine/SV = O
		SV.on_chem_effect(src)

/datum/reagent/toxin/plantbgone/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	src = null
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(!C.wear_mask) // If not wearing a mask
			C.adjustToxLoss(2) // 4 toxic damage per application, doubled for some reason

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

/datum/reagent/toxin/pestkiller/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	src = null
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(!C.wear_mask) // If not wearing a mask
			C.adjustToxLoss(2) // 4 toxic damage per application, doubled for some reason

/datum/reagent/toxin/spore
	name = "Spore Toxin"
	id = "spore"
	description = "A toxic spore cloud which blocks vision when ingested."
	color = "#9ACD32"
	toxpwr = 0.5

/datum/reagent/toxin/spore/on_mob_life(var/mob/living/M as mob)
	M.damageoverlaytemp = 60
	M.eye_blurry = max(M.eye_blurry, 3)
	..()
	return


/datum/reagent/toxin/spore_burning
	name = "Burning Spore Toxin"
	id = "spore_burning"
	description = "A burning spore cloud."
	color = "#9ACD32"
	toxpwr = 0.5

/datum/reagent/toxin/spore_burning/on_mob_life(var/mob/living/M as mob)
	..()
	M.adjust_fire_stacks(2)
	M.IgniteMob()

/datum/reagent/toxin/chloralhydrate
	name = "Chloral Hydrate"
	id = "chloralhydrate"
	description = "A powerful sedative."
	reagent_state = SOLID
	color = "#000067" // rgb: 0, 0, 103
	toxpwr = 0
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/toxin/chloralhydrate/on_mob_life(var/mob/living/M as mob)
	switch(current_cycle)
		if(1 to 10)
			M.confused += 2
			M.drowsyness += 2
		if(10 to 50)
			M.sleeping += 1
		if(51 to INFINITY)
			M.sleeping += 1
			M.adjustToxLoss((current_cycle - 50)*REM)
	..()
	return

/datum/reagent/toxin/beer2	//disguised as normal beer for use by emagged brobots
	name = "Beer"
	id = "beer2"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	color = "#664300" // rgb: 102, 67, 0
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/toxin/beer2/on_mob_life(var/mob/living/M as mob)
	switch(current_cycle)
		if(1 to 50)
			M.sleeping += 1
		if(51 to INFINITY)
			M.sleeping += 1
			M.adjustToxLoss((current_cycle - 50)*REM)
	..()
	return

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
	description = "A toxin that temporarily paralyzes the vocal cords."
	color = "#F0F8FF" // rgb: 240, 248, 255
	toxpwr = 0

/datum/reagent/toxin/mutetoxin/on_mob_life(mob/living/carbon/M)
	M.silent = max(M.silent, 3)
	..()

/datum/reagent/toxin/staminatoxin
	name = "Tirizene"
	id = "tirizene"
	description = "A toxin that affects the stamina of a person when injected into the bloodstream."
	color = "#6E2828"
	data = 13
	toxpwr = 0

/datum/reagent/toxin/staminatoxin/on_mob_life(mob/living/carbon/M)
	M.adjustStaminaLoss(REM * data)
	data = max(data - 1, 3)
	..()

/datum/reagent/toxin/polonium
	name = "Polonium"
	id = "polonium"
	description = "Cause significant Radiation damage over time."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.125 * REAGENTS_METABOLISM
	toxpwr = 0

/datum/reagent/toxin/polonium/on_mob_life(var/mob/living/M as mob)
	M.radiation += 4
	..()

/datum/reagent/toxin/histamine
	name = "Histamine"
	id = "histamine"
	description = "A dose-dependent toxin, ranges from annoying to incredibly lethal."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30
	toxpwr = 0

/datum/reagent/toxin/histamine/on_mob_life(var/mob/living/M as mob)
	if(prob(50))
		switch(pick(1, 2, 3, 4))
			if(1)
				M << "<span class='danger'>You can barely see!</span>"
				M.eye_blurry = 3
			if(2)
				M.emote("cough")
			if(3)
				M.emote("sneeze")
			if(4)
				if(prob(75))
					M << "You scratch at an itch."
					M.adjustBruteLoss(2*REM)
	..()

/datum/reagent/toxin/histamine/overdose_process(var/mob/living/M as mob)
	M.adjustOxyLoss(1*REM)
	M.adjustBruteLoss(1*REM)
	M.adjustToxLoss(1*REM)
	..()

/datum/reagent/toxin/formaldehyde
	name = "Formaldehyde"
	id = "formaldehyde"
	description = "Deals a moderate amount of Toxin damage over time. 10% chance to decay into 10-15 histamine."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	toxpwr = 0.5

/datum/reagent/toxin/formaldehyde/on_mob_life(var/mob/living/M as mob)
	if(prob(5))
		M.reagents.add_reagent("histamine",pick(5,15))
		M.reagents.remove_reagent("formaldehyde",1)
	..()

/datum/reagent/toxin/venom
	name = "Venom"
	id = "venom"
	description = "Will deal scaling amounts of Toxin and Brute damage over time. 15% chance to decay into 5-10 histamine."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	toxpwr = 0

/datum/reagent/toxin/venom/on_mob_life(var/mob/living/M as mob)
	toxpwr = 0.05*volume
	M.adjustBruteLoss((0.1*volume)*REM)
	if(prob(15))
		M.reagents.add_reagent("histamine",pick(5,10))
		M.reagents.remove_reagent("venom",1)
	..()

/datum/reagent/toxin/neurotoxin2
	name = "Neurotoxin"
	id = "neurotoxin2"
	description = "Deals toxin and brain damage up to 60 before it slows down, causing confusion and a knockout after 18 elapsed cycles."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	toxpwr = 0

/datum/reagent/toxin/neurotoxin2/on_mob_life(var/mob/living/M as mob)
	if(M.brainloss + M.toxloss <= 60)
		M.adjustBrainLoss(1*REM)
		M.adjustToxLoss(1*REM)
	if(current_cycle >= 18)
		M.sleeping += 1
	..()

/datum/reagent/toxin/cyanide
	name = "Cyanide"
	id = "cyanide"
	description = "Deals toxin damage, alongside some oxygen loss. 8% chance of stun and some extra toxin damage."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.125 * REAGENTS_METABOLISM
	toxpwr = 0.75

/datum/reagent/toxin/cyanide/on_mob_life(var/mob/living/M as mob)
	if(prob(5))
		M.losebreath += 1
	if(prob(4))
		M << "You feel horrendously weak!"
		M.Stun(2)
		M.adjustToxLoss(2*REM)
	..()

/datum/reagent/toxin/questionmark // food poisoning
	name = "Bad Food"
	id = "????"
	description = "????"
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	toxpwr = 0.5

/datum/reagent/toxin/itching_powder
	name = "Itching Powder"
	id = "itching_powder"
	description = "Lots of annoying random effects, chances to do some brute damage from scratching. 6% chance to decay into 1-3 units of histamine."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.4 * REAGENTS_METABOLISM
	toxpwr = 0

/datum/reagent/toxin/itching_powder/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(method == TOUCH)
		M.reagents.add_reagent("itching_powder", volume)
		return

/datum/reagent/toxin/itching_powder/on_mob_life(var/mob/living/M as mob)
	if(prob(15))
		M << "You scratch at your head."
		M.adjustBruteLoss(0.2*REM)
	if(prob(15))
		M << "You scratch at your leg."
		M.adjustBruteLoss(0.2*REM)
	if(prob(15))
		M << "You scratch at your arm."
		M.adjustBruteLoss(0.2*REM)
	if(prob(3))
		M.reagents.add_reagent("histamine",rand(1,3))
		M.reagents.remove_reagent("itching_powder",1)
	..()

/datum/reagent/toxin/initropidril
	name = "Initropidril"
	id = "initropidril"
	description = "Causes some toxin damage, 5% chances to cause stunning, suffocation, or immediate heart failure."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	toxpwr = 2.5

/datum/reagent/toxin/initropidril/on_mob_life(var/mob/living/M as mob)
	if(prob(5))
		var/picked_option = rand(1,3)
		switch(picked_option)
			if(1)
				M.Stun(3)
				M.Weaken(3)
			if(2)
				M.losebreath += 10
				M.adjustOxyLoss(rand(5,25))
			if(3)
				var/mob/living/carbon/human/H = M
				if(!H.heart_attack)
					H.visible_message("<span class = 'userdanger'>[H] clutches at their chest as if their heart stopped!</span>")
					H.heart_attack = 1 // rip in pepperoni
				else
					H.losebreath += 10
					H.adjustOxyLoss(rand(5,25))
	..()

/datum/reagent/toxin/pancuronium
	name = "Pancuronium"
	id = "pancuronium"
	description = "Knocks you out after 10 seconds, 7% chance to cause some oxygen loss."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	toxpwr = 0

/datum/reagent/toxin/pancuronium/on_mob_life(var/mob/living/M as mob)
	if(current_cycle >= 10)
		M.SetParalysis(1)
	if(prob(7))
		M.losebreath += 4
	..()

/datum/reagent/toxin/sodium_thiopental
	name = "Sodium Thiopental"
	id = "sodium_thiopental"
	description = "Puts you to sleep after 30 seconds, along with some major stamina loss."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	toxpwr = 0

/datum/reagent/toxin/sodium_thiopental/on_mob_life(var/mob/living/M as mob)
	if(current_cycle >= 10)
		M.sleeping += 1
	M.adjustStaminaLoss(5*REM)
	..()

/datum/reagent/toxin/sulfonal
	name = "Sulfonal"
	id = "sulfonal"
	description = "Deals some toxin damage, and puts you to sleep after 66 seconds."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.125 * REAGENTS_METABOLISM
	toxpwr = 0.5

/datum/reagent/toxin/sulfonal/on_mob_life(var/mob/living/M as mob)
	if(current_cycle >= 22)
		M.sleeping += 1
	..()

/datum/reagent/toxin/amanitin
	name = "Amanitin"
	id = "amanitin"
	description = "On the last second that it's in you, it hits you with a stack of toxin damage based on how long it's been in you. The more you use, the longer it takes before anything happens, but the harder it hits when it does."
	reagent_state = LIQUID
	color = "#CF3600"
	toxpwr = 0
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/toxin/amanitin/on_mob_delete(var/mob/living/M as mob)
	M.adjustToxLoss(current_cycle*3*REM)
	..()

/datum/reagent/toxin/lipolicide
	name = "Lipolicide"
	id = "lipolicide"
	description = "Deals some toxin damage unless they keep eating food. Will reduce nutrition values."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	toxpwr = 0.5

/datum/reagent/toxin/lipolicide/on_mob_life(var/mob/living/M as mob)
	if(!holder.has_reagent("nutriment"))
		M.adjustToxLoss(0.5*REM)
	M.nutrition -= 5 * REAGENTS_METABOLISM
	M.overeatduration = 0
	if(M.nutrition < 0)//Prevent from going into negatives.
		M.nutrition = 0
	..()

/datum/reagent/toxin/coniine
	name = "Coniine"
	id = "coniine"
	description = "Does moderate toxin damage and oxygen loss."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.06 * REAGENTS_METABOLISM
	toxpwr = 1

/datum/reagent/toxin/coniine/on_mob_life(var/mob/living/M as mob)
	M.losebreath += 3
	..()

/datum/reagent/toxin/curare
	name = "Curare"
	id = "curare"
	description = "Does some oxygen and toxin damage, weakens you after 11 seconds."
	reagent_state = LIQUID
	color = "#CF3600"
	metabolization_rate = 0.125 * REAGENTS_METABOLISM
	toxpwr = 0.5

/datum/reagent/toxin/curare/on_mob_life(var/mob/living/M as mob)
	if(current_cycle >= 11)
		M.Weaken(1)
	M.adjustOxyLoss(0.5*REM)
	..()


//ACID


/datum/reagent/toxin/acid
	name = "Sulphuric acid"
	id = "sacid"
	description = "A strong mineral acid with the molecular formula H2SO4."
	color = "#DB5008" // rgb: 219, 80, 8
	toxpwr = 1
	var/acidpwr = 10 //the amount of protection removed from the armour

/datum/reagent/toxin/acid/reaction_mob(var/mob/living/carbon/C, var/method=TOUCH, var/volume)
	if(!istype(C))
		return
	if(method != TOUCH)
		C.take_organ_damage(min(6*toxpwr, volume * toxpwr))
		return

	C.acid_act(acidpwr, toxpwr, volume)

/datum/reagent/toxin/acid/reaction_obj(var/obj/O, var/volume)
	if(istype(O.loc, /mob)) //handled in human acid_act()
		return
	O.acid_act(acidpwr, toxpwr, volume)

/datum/reagent/toxin/acid/fluacid
	name = "Fluorosulfuric acid"
	id = "facid"
	description = "Fluorosulfuric acid is a an extremely corrosive chemical substance."
	color = "#8E18A9" // rgb: 142, 24, 169
	toxpwr = 2
	acidpwr = 20

