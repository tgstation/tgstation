
//////////////////////////Poison stuff (Toxins & Acids)///////////////////////

/datum/reagent/toxin
	name = "Toxin"
	id = "toxin"
	description = "A toxic chemical."
	color = "#CF3600" // rgb: 207, 54, 0
	taste_description = "bitterness"
	taste_mult = 1.2
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
	taste_description = "mushroom"

/datum/reagent/toxin/mutagen
	name = "Unstable mutagen"
	id = "mutagen"
	description = "Might cause unpredictable mutations. Keep away from children."
	color = "#00FF00"
	toxpwr = 0
	taste_description = "slime"
	taste_mult = 0.9

/datum/reagent/toxin/mutagen/reaction_mob(mob/living/carbon/M, method=TOUCH, reac_volume)
	if(!..())
		return
	if(!M.has_dna())
		return  //No robots, AIs, aliens, Ians or other mobs should be affected by this.
	if((method==VAPOR && prob(min(33, reac_volume))) || method==INGEST || method==PATCH || method==INJECT)
		M.randmuti()
		if(prob(98))
			M.randmutb()
		else
			M.randmutg()
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
	taste_description = "bitterness"
	taste_mult = 1.5
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
	if(!isliving(M))
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
	taste_description = "acid"

/datum/reagent/toxin/lexorin/on_mob_life(mob/living/M)
	. = TRUE
	var/mob/living/carbon/C
	if(iscarbon(M))
		C = M
		CHECK_DNA_AND_SPECIES(C)
		if(NOBREATH in C.dna.species.species_traits)
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
	taste_description = "slime"
	taste_mult = 1.3

/datum/reagent/toxin/slimejelly/on_mob_life(mob/living/M)
	if(prob(10))
		to_chat(M, "<span class='danger'>Your insides are burning!</span>")
		M.adjustToxLoss(rand(20,60)*REM, 0)
		. = 1
	else if(prob(40))
		M.heal_bodypart_damage(5*REM,0, 0)
		. = 1
	..()

/datum/reagent/toxin/minttoxin
	name = "Mint Toxin"
	id = "minttoxin"
	description = "Useful for dealing with undesirable customers."
	color = "#CF3600" // rgb: 207, 54, 0
	toxpwr = 0
	taste_description = "mint"

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
	taste_description = "fish"

/datum/reagent/toxin/zombiepowder
	name = "Zombie Powder"
	id = "zombiepowder"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0
	toxpwr = 0.5
	taste_description = "death"

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
	taste_description = "sourness"

/datum/reagent/toxin/mindbreaker/on_mob_life(mob/living/M)
	M.hallucination += 10
	return ..()

/datum/reagent/toxin/plantbgone
	name = "Plant-B-Gone"
	id = "plantbgone"
	description = "A harmful toxic mixture to kill plantlife. Do not ingest!"
	color = "#49002E" // rgb: 73, 0, 46
	toxpwr = 1
	taste_mult = 1

/datum/reagent/toxin/plantbgone/reaction_obj(obj/O, reac_volume)
	if(istype(O,/obj/structure/alien/weeds))
		var/obj/structure/alien/weeds/alien_weeds = O
		alien_weeds.take_damage(rand(15,35), BRUTE, 0) // Kills alien weeds pretty fast
	else if(istype(O,/obj/structure/glowshroom)) //even a small amount is enough to kill it
		qdel(O)
	else if(istype(O,/obj/structure/spacevine))
		var/obj/structure/spacevine/SV = O
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
	taste_description = "burning"

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
	taste_description = "piss water"
	glass_icon_state = "beerglass"
	glass_name = "glass of beer"
	glass_desc = "A freezing pint of beer."

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
	taste_description = "silence"

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

/datum/reagent/toxin/polonium
	name = "Polonium"
	id = "polonium"
	description = "An extremely radioactive material in liquid form. Ingestion results in fatal irradiation."
	reagent_state = LIQUID
	color = "#787878"
	metabolization_rate = 0.125 * REAGENTS_METABOLISM
	toxpwr = 0

/datum/reagent/toxin/polonium/on_mob_life(mob/living/M)
	M.radiation += 4
	..()

/datum/reagent/toxin/histamine
	name = "Histamine"
	id = "histamine"
	description = "Histamine's effects become more dangerous depending on the dosage amount. They range from mildly annoying to incredibly lethal."
	reagent_state = LIQUID
	color = "#FA6464"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	overdose_threshold = 30
	toxpwr = 0

/datum/reagent/toxin/histamine/on_mob_life(mob/living/M)
	if(prob(50))
		switch(pick(1, 2, 3, 4))
			if(1)
				to_chat(M, "<span class='danger'>You can barely see!</span>")
				M.blur_eyes(3)
			if(2)
				M.emote("cough")
			if(3)
				M.emote("sneeze")
			if(4)
				if(prob(75))
					to_chat(M, "You scratch at an itch.")
					M.adjustBruteLoss(2*REM, 0)
					. = 1
	..()

/datum/reagent/toxin/histamine/overdose_process(mob/living/M)
	M.adjustOxyLoss(2*REM, 0)
	M.adjustBruteLoss(2*REM, 0)
	M.adjustToxLoss(2*REM, 0)
	..()
	. = 1

/datum/reagent/toxin/formaldehyde
	name = "Formaldehyde"
	id = "formaldehyde"
	description = "Formaldehyde, on its own, is a fairly weak toxin. It contains trace amounts of Histamine, very rarely making it decay into Histamine.."
	reagent_state = LIQUID
	color = "#B4004B"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	toxpwr = 1

/datum/reagent/toxin/formaldehyde/on_mob_life(mob/living/M)
	if(prob(5))
		holder.add_reagent("histamine", pick(5,15))
		holder.remove_reagent("formaldehyde", 1.2)
	else
		return ..()

/datum/reagent/toxin/venom
	name = "Venom"
	id = "venom"
	description = "An exotic poison extracted from highly toxic fauna. Causes scaling amounts of toxin damage and bruising depending and dosage. Often decays into Histamine."
	reagent_state = LIQUID
	color = "#F0FFF0"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	toxpwr = 0

/datum/reagent/toxin/venom/on_mob_life(mob/living/M)
	toxpwr = 0.2*volume
	M.adjustBruteLoss((0.3*volume)*REM, 0)
	. = 1
	if(prob(15))
		M.reagents.add_reagent("histamine", pick(5,10))
		M.reagents.remove_reagent("venom", 1.1)
	else
		..()

/datum/reagent/toxin/neurotoxin2
	name = "Neurotoxin"
	id = "neurotoxin2"
	description = "Neurotoxin will inhibit brain function and cause toxin damage before eventually knocking out its victim."
	reagent_state = LIQUID
	color = "#64916E"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	toxpwr = 0

/datum/reagent/toxin/neurotoxin2/on_mob_life(mob/living/M)
	if(M.brainloss + M.toxloss <= 60)
		M.adjustBrainLoss(1*REM)
		M.adjustToxLoss(1*REM, 0)
		. = 1
	if(current_cycle >= 18)
		M.Sleeping(2, 0)
		. = 1
	..()

/datum/reagent/toxin/cyanide
	name = "Cyanide"
	id = "cyanide"
	description = "An infamous poison known for its use in assassination. Causes small amounts of toxin damage with a small chance of oxygen damage or a stun."
	reagent_state = LIQUID
	color = "#00B4FF"
	metabolization_rate = 0.125 * REAGENTS_METABOLISM
	toxpwr = 1.25

/datum/reagent/toxin/cyanide/on_mob_life(mob/living/M)
	if(prob(5))
		M.losebreath += 1
	if(prob(8))
		to_chat(M, "You feel horrendously weak!")
		M.Stun(2, 0)
		M.adjustToxLoss(2*REM, 0)
	return ..()

/datum/reagent/toxin/bad_food
	name = "Bad Food"
	id = "bad_food"
	description = "The result of some abomination of cookery, food so bad it's toxic."
	reagent_state = LIQUID
	color = "#d6d6d8"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	toxpwr = 0.5
	taste_description = "bad cooking"

/datum/reagent/toxin/itching_powder
	name = "Itching Powder"
	id = "itching_powder"
	description = "A powder that induces itching upon contact with the skin. Causes the victim to scratch at their itches and has a very low chance to decay into Histamine."
	reagent_state = LIQUID
	color = "#C8C8C8"
	metabolization_rate = 0.4 * REAGENTS_METABOLISM
	toxpwr = 0

/datum/reagent/toxin/itching_powder/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		M.reagents.add_reagent("itching_powder", reac_volume)

/datum/reagent/toxin/itching_powder/on_mob_life(mob/living/M)
	if(prob(15))
		to_chat(M, "You scratch at your head.")
		M.adjustBruteLoss(0.2*REM, 0)
		. = 1
	if(prob(15))
		to_chat(M, "You scratch at your leg.")
		M.adjustBruteLoss(0.2*REM, 0)
		. = 1
	if(prob(15))
		to_chat(M, "You scratch at your arm.")
		M.adjustBruteLoss(0.2*REM, 0)
		. = 1
	if(prob(3))
		M.reagents.add_reagent("histamine",rand(1,3))
		M.reagents.remove_reagent("itching_powder",1.2)
		return
	..()

/datum/reagent/toxin/initropidril
	name = "Initropidril"
	id = "initropidril"
	description = "A powerful poison with insidious effects. It can cause stuns, lethal breathing failure, and cardiac arrest."
	reagent_state = LIQUID
	color = "#7F10C0"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	toxpwr = 2.5

/datum/reagent/toxin/initropidril/on_mob_life(mob/living/M)
	if(prob(25))
		var/picked_option = rand(1,3)
		switch(picked_option)
			if(1)
				M.Stun(3, 0)
				M.Weaken(3, 0)
				. = 1
			if(2)
				M.losebreath += 10
				M.adjustOxyLoss(rand(5,25), 0)
				. = 1
			if(3)
				if(ishuman(M))
					var/mob/living/carbon/human/H = M
					if(!H.undergoing_cardiac_arrest() && H.can_heartattack())
						H.set_heartattack(TRUE)
						if(H.stat == CONSCIOUS)
							H.visible_message("<span class='userdanger'>[H] clutches at [H.p_their()] chest as if [H.p_their()] heart stopped!</span>")
					else
						H.losebreath += 10
						H.adjustOxyLoss(rand(5,25), 0)
						. = 1
	return ..() || .

/datum/reagent/toxin/pancuronium
	name = "Pancuronium"
	id = "pancuronium"
	description = "An undetectable toxin that swiftly incapacitates its victim. May also cause breathing failure."
	reagent_state = LIQUID
	color = "#195096"
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	toxpwr = 0
	taste_mult = 0 // undetectable, I guess?

/datum/reagent/toxin/pancuronium/on_mob_life(mob/living/M)
	if(current_cycle >= 10)
		M.Paralyse(2, 0)
		. = 1
	if(prob(20))
		M.losebreath += 4
	..()

/datum/reagent/toxin/sodium_thiopental
	name = "Sodium Thiopental"
	id = "sodium_thiopental"
	description = "Sodium Thiopental induces heavy weakness in its target as well as unconsciousness."
	reagent_state = LIQUID
	color = "#6496FA"
	metabolization_rate = 0.75 * REAGENTS_METABOLISM
	toxpwr = 0

/datum/reagent/toxin/sodium_thiopental/on_mob_life(mob/living/M)
	if(current_cycle >= 10)
		M.Sleeping(2, 0)
	M.adjustStaminaLoss(10*REM, 0)
	..()
	. = 1

/datum/reagent/toxin/sulfonal
	name = "Sulfonal"
	id = "sulfonal"
	description = "A stealthy poison that deals minor toxin damage and eventually puts the target to sleep."
	reagent_state = LIQUID
	color = "#7DC3A0"
	metabolization_rate = 0.125 * REAGENTS_METABOLISM
	toxpwr = 0.5

/datum/reagent/toxin/sulfonal/on_mob_life(mob/living/M)
	if(current_cycle >= 22)
		M.Sleeping(2, 0)
	return ..()

/datum/reagent/toxin/amanitin
	name = "Amanitin"
	id = "amanitin"
	description = "A very powerful delayed toxin. Upon full metabolization, a massive amount of toxin damage will be dealt depending on how long it has been in the victim's bloodstream."
	reagent_state = LIQUID
	color = "#FFFFFF"
	toxpwr = 0
	metabolization_rate = 0.5 * REAGENTS_METABOLISM

/datum/reagent/toxin/amanitin/on_mob_delete(mob/living/M)
	var/toxdamage = current_cycle*3*REM
	M.adjustToxLoss(toxdamage)
	if(M)
		add_logs(M, get_turf(M), "has taken [toxdamage] toxin damage from amanitin toxin")
	..()

/datum/reagent/toxin/lipolicide
	name = "Lipolicide"
	id = "lipolicide"
	description = "A powerful toxin that will destroy fat cells, massively reducing body weight in a short time. More deadly to those without nutriment in their body."
	taste_description = "mothballs"
	reagent_state = LIQUID
	color = "#F0FFF0"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	toxpwr = 0.5

/datum/reagent/toxin/lipolicide/on_mob_life(mob/living/M)
	if(M.nutrition <= NUTRITION_LEVEL_STARVING)
		M.adjustToxLoss(0.5*REM, 0)
	M.nutrition = max(M.nutrition - 3, 0) // making the chef more valuable, one meme trap at a time
	M.overeatduration = 0
	return ..()

/datum/reagent/toxin/coniine
	name = "Coniine"
	id = "coniine"
	description = "Coniine metabolizes extremely slowly, but deals high amounts of toxin damage and stops breathing."
	reagent_state = LIQUID
	color = "#7DC3A0"
	metabolization_rate = 0.06 * REAGENTS_METABOLISM
	toxpwr = 1.75

/datum/reagent/toxin/coniine/on_mob_life(mob/living/M)
	M.losebreath += 5
	return ..()

/datum/reagent/toxin/spewium
	name = "Spewium"
	id = "spewium"
	description = "A powerful emetic, causes uncontrollable vomiting.  May result in vomiting organs at high doses."
	reagent_state = LIQUID
	color = "#2f6617" //A sickly green color
	metabolization_rate = REAGENTS_METABOLISM
	overdose_threshold = 29
	toxpwr = 0
	taste_description = "vomit"

/datum/reagent/toxin/spewium/on_mob_life(mob/living/M)
	.=..()
	if(current_cycle >=11 && prob(min(50,current_cycle)) && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.vomit(lost_nutrition = 10, blood = prob(10), stun = prob(50), distance = rand(0,4), message = TRUE, toxic = prob(30))
		for(var/datum/reagent/toxin/R in M.reagents.reagent_list)
			if(R != src)
				H.reagents.remove_reagent(R.id,1)

/datum/reagent/toxin/spewium/overdose_process(mob/living/M)
	. = ..()
	if(current_cycle >=33 && prob(15) && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.spew_organ()
		H.vomit(lost_nutrition = 0, blood = 1, stun = 1, distance = 4)
		to_chat(H, "<span class='userdanger'>You feel something lumpy come up as you vomit.</span>")

/datum/reagent/toxin/curare
	name = "Curare"
	id = "curare"
	description = "Causes slight toxin damage followed by chain-stunning and oxygen damage."
	reagent_state = LIQUID
	color = "#191919"
	metabolization_rate = 0.125 * REAGENTS_METABOLISM
	toxpwr = 1

/datum/reagent/toxin/curare/on_mob_life(mob/living/M)
	if(current_cycle >= 11)
		M.Weaken(3, 0)
	M.adjustOxyLoss(1*REM, 0)
	. = 1
	..()

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
		H.bleed_rate = min(H.bleed_rate + 2, 8)
		H.adjustBruteLoss(1, 0) //Brute damage increases with the amount they're bleeding
		. = 1
	return ..() || .


/datum/reagent/toxin/rotatium //Rotatium. Fucks up your rotation and is hilarious
	name = "Rotatium"
	id = "rotatium"
	description = "A constantly swirling, oddly colourful fluid. Causes the consumer's sense of direction and hand-eye coordination to become wild."
	reagent_state = LIQUID
	color = "#AC88CA" //RGB: 172, 136, 202
	metabolization_rate = 0.6 * REAGENTS_METABOLISM
	toxpwr = 0.5
	taste_description = "spinning"

/datum/reagent/toxin/rotatium/on_mob_life(mob/living/M)
	if(M.hud_used)
		if(current_cycle >= 20 && current_cycle%20 == 0)
			var/list/screens = list(M.hud_used.plane_masters["[GAME_PLANE]"], M.hud_used.plane_masters["[LIGHTING_PLANE]"])
			var/rotation = min(round(current_cycle/20), 89) // By this point the player is probably puking and quitting anyway
			for(var/whole_screen in screens)
				animate(whole_screen, transform = matrix(rotation, MATRIX_ROTATE), time = 5, easing = QUAD_EASING, loop = -1)
				animate(transform = matrix(-rotation, MATRIX_ROTATE), time = 5, easing = QUAD_EASING)
	return ..()

/datum/reagent/toxin/rotatium/on_mob_delete(mob/living/M)
	if(M && M.hud_used)
		var/list/screens = list(M.hud_used.plane_masters["[GAME_PLANE]"], M.hud_used.plane_masters["[LIGHTING_PLANE]"])
		for(var/whole_screen in screens)
			animate(whole_screen, transform = matrix(), time = 5, easing = QUAD_EASING)
	..()

/datum/reagent/toxin/skewium
	name = "Skewium"
	id = "skewium"
	description = "A strange, dull coloured liquid that appears to warp back and forth inside its container. Causes any consumer to experience a visual phenomena similar to said warping."
	reagent_state = LIQUID
	color = "#ADBDCD"
	metabolization_rate = 0.8 * REAGENTS_METABOLISM
	toxpwr = 0.25
	taste_description = "skewing"

/datum/reagent/toxin/skewium/on_mob_life(mob/living/M)
	if(M.hud_used)
		if(current_cycle >= 5 && current_cycle % 3 == 0)
			var/list/screens = list(M.hud_used.plane_masters["[GAME_PLANE]"], M.hud_used.plane_masters["[LIGHTING_PLANE]"])
			var/matrix/skew = matrix()
			var/intensity = 8
			skew.set_skew(rand(-intensity,intensity), rand(-intensity,intensity))
			var/matrix/newmatrix = skew

			if(prob(33)) // 1/3rd of the time, let's make it stack with the previous matrix! Mwhahahaha!
				var/obj/screen/plane_master/PM = M.hud_used.plane_masters["[GAME_PLANE]"]
				newmatrix = skew * PM.transform

			for(var/whole_screen in screens)
				animate(whole_screen, transform = newmatrix, time = 5, easing = QUAD_EASING, loop = -1)
				animate(transform = -newmatrix, time = 5, easing = QUAD_EASING)
	return ..()

/datum/reagent/toxin/skewium/on_mob_delete(mob/living/M)
	if(M && M.hud_used)
		var/list/screens = list(M.hud_used.plane_masters["[GAME_PLANE]"], M.hud_used.plane_masters["[LIGHTING_PLANE]"])
		for(var/whole_screen in screens)
			animate(whole_screen, transform = matrix(), time = 5, easing = QUAD_EASING)
	..()


/datum/reagent/toxin/anacea
	name = "Anacea"
	id = "anacea"
	description = "A toxin that quickly purges medicines and metabolizes very slowly."
	reagent_state = LIQUID
	color = "#3C5133"
	metabolization_rate = 0.08 * REAGENTS_METABOLISM
	toxpwr = 0.15

/datum/reagent/toxin/anacea/on_mob_life(mob/living/M)
	var/remove_amt = 5
	if(holder.has_reagent("calomel") || holder.has_reagent("pen_acid"))
		remove_amt = 0.5
	for(var/datum/reagent/medicine/R in M.reagents.reagent_list)
		M.reagents.remove_reagent(R.id,remove_amt)
	return ..()

//ACID


/datum/reagent/toxin/acid
	name = "Sulphuric acid"
	id = "sacid"
	description = "A strong mineral acid with the molecular formula H2SO4."
	color = "#00FF32"
	toxpwr = 1
	var/acidpwr = 10 //the amount of protection removed from the armour
	taste_description = "acid"

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
	C.acid_act(acidpwr, reac_volume)

/datum/reagent/toxin/acid/reaction_obj(obj/O, reac_volume)
	if(istype(O.loc, /mob)) //handled in human acid_act()
		return
	reac_volume = round(reac_volume,0.1)
	O.acid_act(acidpwr, reac_volume)

/datum/reagent/toxin/acid/reaction_turf(turf/T, reac_volume)
	if (!istype(T))
		return
	reac_volume = round(reac_volume,0.1)
	T.acid_act(acidpwr, reac_volume)

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
	taste_description = "dizziness"

/datum/reagent/toxin/peaceborg/confuse/on_mob_life(mob/living/M)
	if(M.confused < 6)
		M.confused = Clamp(M.confused + 3, 0, 5)
	if(M.dizziness < 6)
		M.dizziness = Clamp(M.dizziness + 3, 0, 5)
	if(prob(20))
		to_chat(M, "You feel confused and disorientated.")
	..()

/datum/reagent/toxin/peaceborg/tire
	name = "Tiring Solution"
	id = "tiresolution"
	description = "An extremely weak stamina-toxin that tires out the target. Completely harmless."
	toxpwr = 0
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "tiredness"

/datum/reagent/toxin/peaceborg/tire/on_mob_life(mob/living/M)
	var/healthcomp = (100 - M.health)	//DOES NOT ACCOUNT FOR ADMINBUS THINGS THAT MAKE YOU HAVE MORE THAN 200/210 HEALTH, OR SOMETHING OTHER THAN A HUMAN PROCESSING THIS.
	if(M.staminaloss < (45 - healthcomp))	//At 50 health you would have 200 - 150 health meaning 50 compensation. 60 - 50 = 10, so would only do 10-19 stamina.)
		M.adjustStaminaLoss(10)
	if(prob(30))
		to_chat(M, "You should sit down and take a rest...")
	..()

/datum/reagent/toxin/delayed
	name = "Toxin Microcapsules"
	id = "delayed_toxin"
	description = "Causes heavy toxin damage after a brief time of inactivity."
	reagent_state = LIQUID
	metabolization_rate = 0 //stays in the system until active.
	var/actual_metaboliztion_rate = REAGENTS_METABOLISM
	toxpwr = 0
	var/actual_toxpwr = 5
	var/delay = 30

/datum/reagent/toxin/delayed/on_mob_life(mob/living/M)
	if(current_cycle > delay)
		holder.remove_reagent(id, actual_metaboliztion_rate * M.metabolism_efficiency)
		M.adjustToxLoss(actual_toxpwr*REM, 0)
		if(prob(10))
			M.Weaken(1, 0)
		. = 1
	..()

/datum/reagent/toxin/mimesbane
	name = "Mime's Bane"
	id = "mimesbane"
	description = "A nonlethal neurotoxin that interferes with the victim's ability to gesture."
	color = "#F0F8FF" // rgb: 240, 248, 255
	toxpwr = 0
	taste_description = "stillness"
