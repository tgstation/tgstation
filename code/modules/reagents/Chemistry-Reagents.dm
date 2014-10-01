#define SOLID 1
#define LIQUID 2
#define GAS 3

#define REM REAGENTS_EFFECT_MULTIPLIER

//The reaction procs must ALWAYS set src = null, this detaches the proc from the object (the reagent)
//so that it can continue working when the reagent is deleted while the proc is still active.


datum/reagent
	var/name = "Reagent"
	var/id = "reagent"
	var/description = ""
	var/datum/reagents/holder = null
	var/reagent_state = SOLID
	var/list/data
	var/volume = 0
	var/nutriment_factor = 0
	//var/list/viruses = list()
	var/color = "#000000" // rgb: 0, 0, 0 (does not support alpha channels - yet!)

datum/reagent/proc/reaction_mob(var/mob/M, var/method=TOUCH, var/volume) //By default we have a chance to transfer some
	if(!istype(M, /mob/living))	return 0
	var/datum/reagent/self = src
	src = null										  //of the reagent to the mob on TOUCHING it.

	if(!istype(self.holder.my_atom, /obj/effect/effect/chem_smoke))
				// If the chemicals are in a smoke cloud, do not try to let the chemicals "penetrate" into the mob's system (balance station 13) -- Doohl

		if(method == TOUCH)

			var/chance = 1
			var/block  = 0

			for(var/obj/item/clothing/C in M.get_equipped_items())
				if(C.permeability_coefficient < chance) chance = C.permeability_coefficient
				if(istype(C, /obj/item/clothing/suit/bio_suit))
					// bio suits are just about completely fool-proof - Doohl
					// kind of a hacky way of making bio suits more resistant to chemicals but w/e
					if(prob(75))
						block = 1

				if(istype(C, /obj/item/clothing/head/bio_hood))
					if(prob(75))
						block = 1

			chance = chance * 100

			if(prob(chance) && !block)
				if(M.reagents)
					M.reagents.add_reagent(self.id,self.volume/2)
	return 1

datum/reagent/proc/reaction_obj(var/obj/O, var/volume) //By default we transfer a small part of the reagent to the object
	src = null						//if it can hold reagents. nope!
	//if(O.reagents)
	//	O.reagents.add_reagent(id,volume/3)
	return

datum/reagent/proc/reaction_turf(var/turf/T, var/volume)
	src = null
	return

datum/reagent/proc/on_mob_life(var/mob/living/M as mob)
	if(!istype(M, /mob/living))
		return //Noticed runtime errors from pacid trying to damage ghosts, this should fix. --NEO
	holder.remove_reagent(src.id, REAGENTS_METABOLISM) //By default it slowly disappears.
	return

datum/reagent/proc/on_move(var/mob/M)
	return

// Called after add_reagents creates a new reagent.
datum/reagent/proc/on_new(var/data)
	return

// Called when two reagents of the same are mixing.
datum/reagent/proc/on_merge(var/data)
	return

datum/reagent/proc/on_update(var/atom/A)
	return

datum/reagent/blood
			data = list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=null,"resistances"=null,"trace_chem"=null)
			name = "Blood"
			id = "blood"
			reagent_state = LIQUID
			color = "#C80000" // rgb: 200, 0, 0

datum/reagent/blood/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	var/datum/reagent/blood/self = src
	src = null
	if(self.data && self.data["viruses"])
		for(var/datum/disease/D in self.data["viruses"])
			//var/datum/disease/virus = new D.type(0, D, 1)
			// We don't spread.
			if(D.spread_type == SPECIAL || D.spread_type == NON_CONTAGIOUS) continue

			if(method == TOUCH)
				M.contract_disease(D)
			else //injected
				M.contract_disease(D, 1, 0)

datum/reagent/blood/on_new(var/list/data)
	if(istype(data))
		SetViruses(src, data)

datum/reagent/blood/on_merge(var/list/data)
	if(src.data && data)

		if(src.data["viruses"] || data["viruses"])

			var/list/mix1 = src.data["viruses"]
			var/list/mix2 = data["viruses"]

			// Stop issues with the list changing during mixing.
			var/list/to_mix = list()

			for(var/datum/disease/advance/AD in mix1)
				to_mix += AD
			for(var/datum/disease/advance/AD in mix2)
				to_mix += AD

			var/datum/disease/advance/AD = Advance_Mix(to_mix)
			if(AD)
				var/list/preserve = list(AD)
				for(var/D in src.data["viruses"])
					if(!istype(D, /datum/disease/advance))
						preserve += D
				src.data["viruses"] = preserve
	return 1


datum/reagent/blood/reaction_turf(var/turf/simulated/T, var/volume)//splash the blood all over the place
	if(!istype(T)) return
	var/datum/reagent/blood/self = src
	src = null
	if(!(volume >= 3)) return
	//var/datum/disease/D = self.data["virus"]
	if(!self.data["donor"] || istype(self.data["donor"], /mob/living/carbon/human))
		var/obj/effect/decal/cleanable/blood/blood_prop = locate() in T //find some blood here
		if(!blood_prop) //first blood!
			blood_prop = new(T)
			blood_prop.blood_DNA[self.data["blood_DNA"]] = self.data["blood_type"]

		for(var/datum/disease/D in self.data["viruses"])
			var/datum/disease/newVirus = D.Copy(1)
			blood_prop.viruses += newVirus
			newVirus.holder = blood_prop


	else if(istype(self.data["donor"], /mob/living/carbon/monkey))
		var/obj/effect/decal/cleanable/blood/blood_prop = locate() in T
		if(!blood_prop)
			blood_prop = new(T)
			blood_prop.blood_DNA["Non-Human DNA"] = "A+"
		for(var/datum/disease/D in self.data["viruses"])
			var/datum/disease/newVirus = D.Copy(1)
			blood_prop.viruses += newVirus
			newVirus.holder = blood_prop

	else if(istype(self.data["donor"], /mob/living/carbon/alien))
		var/obj/effect/decal/cleanable/xenoblood/blood_prop = locate() in T
		if(!blood_prop)
			blood_prop = new(T)
			blood_prop.blood_DNA["UNKNOWN DNA STRUCTURE"] = "X*"
		for(var/datum/disease/D in self.data["viruses"])
			var/datum/disease/newVirus = D.Copy(1)
			blood_prop.viruses += newVirus
			newVirus.holder = blood_prop
	return

/* Must check the transfering of reagents and their data first. They all can point to one disease datum.

			Del()
				if(src.data["virus"])
					var/datum/disease/D = src.data["virus"]
					D.cure(0)
				..()
*/
datum/reagent/vaccine
	//data must contain virus type
	name = "Vaccine"
	id = "vaccine"
	reagent_state = LIQUID
	color = "#C81040" // rgb: 200, 16, 64

datum/reagent/vaccine/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	var/datum/reagent/vaccine/self = src
	src = null
	if(islist(self.data) && method == INGEST)
		for(var/datum/disease/D in M.viruses)
			if(D.GetDiseaseID() in self.data)
				D.cure()
		M.resistances |= self.data
	return

datum/reagent/vaccine/on_merge(var/list/data)
	if(istype(data))
		src.data |= data.Copy()


datum/reagent/water
	name = "Water"
	id = "water"
	description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
	reagent_state = LIQUID
	color = "#AAAAAA77" // rgb: 170, 170, 170, 77 (alpha)

datum/reagent/water/reaction_turf(var/turf/simulated/T, var/volume)
	if (!istype(T)) return
	src = null
	if(volume >= 10)
		T.MakeSlippery()

	for(var/mob/living/carbon/slime/M in T)
		M.apply_water()

	var/hotspot = (locate(/obj/effect/hotspot) in T)
	if(hotspot && !istype(T, /turf/space))
		var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
		lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)
	return
datum/reagent/water/reaction_obj(var/obj/O, var/volume)
	src = null
	var/turf/T = get_turf(O)
	var/hotspot = (locate(/obj/effect/hotspot) in T)
	if(hotspot && !istype(T, /turf/space))
		var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
		lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)
	if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/monkeycube))
		var/obj/item/weapon/reagent_containers/food/snacks/monkeycube/cube = O
		if(!cube.wrapped)
			cube.Expand()
	return

datum/reagent/water/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//Splashing people with water can help put them out!
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH)
		M.adjust_fire_stacks(-(volume / 10))
		if(M.fire_stacks <= 0)
			M.ExtinguishMob()
		return

datum/reagent/water/holywater
	name = "Holy Water"
	id = "holywater"
	description = "Water blessed by some deity."
	color = "#E0E8EF" // rgb: 224, 232, 239

datum/reagent/water/holywater/on_mob_life(var/mob/living/M as mob)
	if(!data) data = 1
	data++
	M.jitteriness = max(M.jitteriness-5,0)
	if(data >= 30)		// 12 units, 54 seconds @ metabolism 0.4 units & tick rate 1.8 sec
		if (!M.stuttering) M.stuttering = 1
		M.stuttering += 4
		M.Dizzy(5)
		if(iscultist(M) && prob(5))
			M.say(pick("Av'te Nar'sie","Pa'lid Mors","INO INO ORA ANA","SAT ANA!","Daim'niodeis Arc'iai Le'eones","Egkau'haom'nai en Chaous","Ho Diak'nos tou Ap'iron","R'ge Na'sie","Diabo us Vo'iscum","Si gn'um Co'nu"))
	if(data >= 75 && prob(33))	// 30 units, 135 seconds
		if (!M.confused) M.confused = 1
		M.confused += 3
		if(iscultist(M))
			ticker.mode.remove_cultist(M.mind)
			holder.remove_reagent(src.id, src.volume)	// maybe this is a little too perfect and a max() cap on the statuses would be better??
			M.jitteriness = 0
			M.stuttering = 0
			M.confused = 0
	holder.remove_reagent(src.id, 0.4)	//fixed consumption to prevent balancing going out of whack
	return

datum/reagent/water/holywater/reaction_turf(var/turf/simulated/T, var/volume)
	..()
	if(!istype(T)) return
	if(volume>=10)
		for(var/obj/effect/rune/R in T)
			qdel(R)
	T.Bless()

datum/reagent/fuel/unholywater		//if you somehow managed to extract this from someone, dont splash it on yourself and have a smoke
	name = "Unholy Water"
	id = "unholywater"
	description = "Something that shouldn't exist on this plane of existance."

datum/reagent/fuel/unholywater/on_mob_life(var/mob/living/M as mob)
	M.adjustBrainLoss(3)
	if(iscultist(M))
		M.status_flags |= GOTTAGOFAST
		M.drowsyness = max(M.drowsyness-5, 0)
		M.AdjustParalysis(-2)
		M.AdjustStunned(-2)
		M.AdjustWeakened(-2)
	else
		M.adjustToxLoss(2)
		M.adjustFireLoss(2)
		M.adjustOxyLoss(2)
		M.adjustBruteLoss(2)
	holder.remove_reagent(src.id, 1)

datum/reagent/hellwater			//if someone has this in their system they've really pissed off an eldrich god
	name = "Hell Water"
	id = "hell_water"
	description = "YOUR FLESH! IT BURNS!"

datum/reagent/hellwater/on_mob_life(var/mob/living/M as mob)
	M.fire_stacks = min(5,M.fire_stacks + 3)
	M.IgniteMob()			//Only problem with igniting people is currently the commonly availible fire suits make you immune to being on fire
	M.adjustToxLoss(1)
	M.adjustFireLoss(1)		//Hence the other damages... ain't I a bastard?
	M.adjustBrainLoss(5)
	holder.remove_reagent(src.id, 1)

datum/reagent/lube
	name = "Space Lube"
	id = "lube"
	description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
	reagent_state = LIQUID
	color = "#009CA8" // rgb: 0, 156, 168

datum/reagent/lube/reaction_turf(var/turf/simulated/T, var/volume)
	if (!istype(T)) return
	src = null
	if(volume >= 1)
		T.MakeSlippery(2)

datum/reagent/slimetoxin
	name = "Mutation Toxin"
	id = "mutationtoxin"
	description = "A corruptive toxin produced by slimes."
	reagent_state = LIQUID
	color = "#13BC5E" // rgb: 19, 188, 94

datum/reagent/aslimetoxin
	name = "Advanced Mutation Toxin"
	id = "amutationtoxin"
	description = "An advanced corruptive toxin produced by slimes."
	reagent_state = LIQUID
	color = "#13BC5E" // rgb: 19, 188, 94

datum/reagent/aslimetoxin/reaction_mob(var/mob/M, var/volume)
	src = null
	M.contract_disease(new /datum/disease/transformation/slime(0),1)

datum/reagent/inaprovaline
	name = "Inaprovaline"
	id = "inaprovaline"
	description = "Inaprovaline is a synaptic stimulant and cardiostimulant. Commonly used to stabilize patients."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/inaprovaline/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.losebreath >= 10)
		M.losebreath = max(10, M.losebreath-5)
	holder.remove_reagent(src.id, 0.5 * REAGENTS_METABOLISM)
	return

datum/reagent/space_drugs
	name = "Space drugs"
	id = "space_drugs"
	description = "An illegal chemical compound used as drug."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132

datum/reagent/space_drugs/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.druggy = max(M.druggy, 15)
	if(isturf(M.loc) && !istype(M.loc, /turf/space))
		if(M.canmove)
			if(prob(10)) step(M, pick(cardinal))
	if(prob(7)) M.emote(pick("twitch","drool","moan","giggle"))
	holder.remove_reagent(src.id, 0.5 * REAGENTS_METABOLISM)
	return

datum/reagent/serotrotium
	name = "Serotrotium"
	id = "serotrotium"
	description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
	reagent_state = LIQUID
	color = "#202040" // rgb: 20, 20, 40

datum/reagent/serotrotium/on_mob_life(var/mob/living/M as mob)
	if(ishuman(M))
		if(prob(7)) M.emote(pick("twitch","drool","moan","gasp"))
		holder.remove_reagent(src.id, 0.25 * REAGENTS_METABOLISM)
	return

/*		silicate
			name = "Silicate"
			id = "silicate"
			description = "A compound that can be used to reinforce glass."
			reagent_state = LIQUID
			color = "#C7FFFF" // rgb: 199, 255, 255

			reaction_obj(var/obj/O, var/volume)
				src = null
				if(istype(O,/obj/structure/window))
					if(O:silicate <= 200)

						O:silicate += volume
						O:health += volume * 3

						if(!O:silicateIcon)
							var/icon/I = icon(O.icon,O.icon_state,O.dir)

							var/r = (volume / 100) + 1
							var/g = (volume / 70) + 1
							var/b = (volume / 50) + 1
							I.SetIntensity(r,g,b)
							O.icon = I
							O:silicateIcon = I
						else
							var/icon/I = O:silicateIcon

							var/r = (volume / 100) + 1
							var/g = (volume / 70) + 1
							var/b = (volume / 50) + 1
							I.SetIntensity(r,g,b)
							O.icon = I
							O:silicateIcon = I

				return*/

datum/reagent/oxygen
	name = "Oxygen"
	id = "oxygen"
	description = "A colorless, odorless gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128

datum/reagent/copper
	name = "Copper"
	id = "copper"
	description = "A highly ductile metal."
	color = "#6E3B08" // rgb: 110, 59, 8

datum/reagent/nitrogen
	name = "Nitrogen"
	id = "nitrogen"
	description = "A colorless, odorless, tasteless gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128

datum/reagent/hydrogen
	name = "Hydrogen"
	id = "hydrogen"
	description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128

datum/reagent/potassium
	name = "Potassium"
	id = "potassium"
	description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
	reagent_state = SOLID
	color = "#A0A0A0" // rgb: 160, 160, 160

datum/reagent/mercury
	name = "Mercury"
	id = "mercury"
	description = "A chemical element."
	reagent_state = LIQUID
	color = "#484848" // rgb: 72, 72, 72

datum/reagent/mercury/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.canmove && istype(M.loc, /turf/space))
		step(M, pick(cardinal))
	if(prob(5)) M.emote(pick("twitch","drool","moan"))
	M.adjustBrainLoss(2)
	..()
	return

datum/reagent/sulfur
	name = "Sulfur"
	id = "sulfur"
	description = "A chemical element."
	reagent_state = SOLID
	color = "#BF8C00" // rgb: 191, 140, 0

datum/reagent/carbon
	name = "Carbon"
	id = "carbon"
	description = "A chemical element."
	reagent_state = SOLID
	color = "#1C1300" // rgb: 30, 20, 0

datum/reagent/carbon/reaction_turf(var/turf/T, var/volume)
	src = null
	if(!istype(T, /turf/space))
		new /obj/effect/decal/cleanable/dirt(T)

datum/reagent/chlorine
	name = "Chlorine"
	id = "chlorine"
	description = "A chemical element."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128

datum/reagent/chlorine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.take_organ_damage(1*REM, 0)
	..()
	return

datum/reagent/fluorine
	name = "Fluorine"
	id = "fluorine"
	description = "A highly-reactive chemical element."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128

datum/reagent/fluorine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(1*REM)
	..()
	return

datum/reagent/sodium
	name = "Sodium"
	id = "sodium"
	description = "A chemical element."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128

datum/reagent/phosphorus
	name = "Phosphorus"
	id = "phosphorus"
	description = "A chemical element."
	reagent_state = SOLID
	color = "#832828" // rgb: 131, 40, 40

datum/reagent/lithium
	name = "Lithium"
	id = "lithium"
	description = "A chemical element."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128

datum/reagent/lithium/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.canmove && istype(M.loc, /turf/space))
		step(M, pick(cardinal))
	if(prob(5)) M.emote(pick("twitch","drool","moan"))
	..()
	return

datum/reagent/sugar
	name = "Sugar"
	id = "sugar"
	description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255, 255, 255

datum/reagent/sugar/on_mob_life(var/mob/living/M as mob)
	M.nutrition += 1*REM
	..()
	return

datum/reagent/glycerol
	name = "Glycerol"
	id = "glycerol"
	description = "Glycerol is a simple polyol compound. Glycerol is sweet-tasting and of low toxicity."
	reagent_state = LIQUID
	color = "#808080" // rgb: 128, 128, 128

datum/reagent/nitroglycerin
	name = "Nitroglycerin"
	id = "nitroglycerin"
	description = "Nitroglycerin is a heavy, colorless, oily, explosive liquid obtained by nitrating glycerol."
	reagent_state = LIQUID
	color = "#808080" // rgb: 128, 128, 128

datum/reagent/radium
	name = "Radium"
	id = "radium"
	description = "Radium is an alkaline earth metal. It is extremely radioactive."
	reagent_state = SOLID
	color = "#C7C7C7" // rgb: 199,199,199

datum/reagent/radium/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.apply_effect(2*REM,IRRADIATE,0)
	..()
	return

datum/reagent/radium/reaction_turf(var/turf/T, var/volume)
	src = null
	if(volume >= 3)
		if(!istype(T, /turf/space))
			new /obj/effect/decal/cleanable/greenglow(T)
			return


datum/reagent/ryetalyn
	name = "Ryetalyn"
	id = "ryetalyn"
	description = "Ryetalyn can cure all genetic abnomalities."
	reagent_state = SOLID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/ryetalyn/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom

	var/needs_update = M.mutations.len > 0

	M.mutations = list()
	M.disabilities = 0
	M.sdisabilities = 0

	// Might need to update appearance for hulk etc.
	if(needs_update && ishuman(M))
		var/mob/living/carbon/human/H = M
		H.update_mutations()

	..()
	return

datum/reagent/thermite
	name = "Thermite"
	id = "thermite"
	description = "Thermite produces an aluminothermic reaction known as a thermite reaction. Can be used to melt walls."
	reagent_state = SOLID
	color = "#673910" // rgb: 103, 57, 16

datum/reagent/thermite/reaction_turf(var/turf/T, var/volume)
	src = null
	if(volume >= 1 && istype(T, /turf/simulated/wall))
		var/turf/simulated/wall/Wall = T
		if(istype(Wall, /turf/simulated/wall/r_wall))
			Wall.thermite = Wall.thermite+(volume*2.5)
		else
			Wall.thermite = Wall.thermite+(volume*10)
		Wall.overlays = list()
		Wall.overlays += image('icons/effects/effects.dmi',"thermite")
	return

datum/reagent/thermite/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustFireLoss(1)
	..()
	return

datum/reagent/virus_food
	name = "Virus Food"
	id = "virusfood"
	description = "A mixture of water and milk. Virus cells can use this mixture to reproduce."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#899613" // rgb: 137, 150, 19

datum/reagent/virus_food/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.nutrition += nutriment_factor*REM
	..()
	return

datum/reagent/sterilizine
	name = "Sterilizine"
	id = "sterilizine"
	description = "Sterilizes wounds in preparation for surgery."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
/*datum/reagent/sterilizine/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	src = null
	if (method==TOUCH)
		if(istype(M, /mob/living/carbon/human))
			if(M.health >= -100 && M.health <= 0)
				M.crit_op_stage = 0.0
	if (method==INGEST)
		usr << "Well, that was stupid."
		M.adjustToxLoss(3)
	return

datum/reagent/sterilizine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
		M.radiation += 3
		..()
		return
	*/
datum/reagent/iron
	name = "Iron"
	id = "iron"
	description = "Pure iron is a metal."
	reagent_state = SOLID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/gold
	name = "Gold"
	id = "gold"
	description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
	reagent_state = SOLID
	color = "#F7C430" // rgb: 247, 196, 48

datum/reagent/silver
	name = "Silver"
	id = "silver"
	description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
	reagent_state = SOLID
	color = "#D0D0D0" // rgb: 208, 208, 208

datum/reagent/uranium
	name ="Uranium"
	id = "uranium"
	description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
	reagent_state = SOLID
	color = "#B8B8C0" // rgb: 184, 184, 192

datum/reagent/uranium/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.apply_effect(1,IRRADIATE,0)
	..()
	return


datum/reagent/uranium/reaction_turf(var/turf/T, var/volume)
	src = null
	if(volume >= 3)
		if(!istype(T, /turf/space))
			new /obj/effect/decal/cleanable/greenglow(T)

datum/reagent/aluminium
	name = "Aluminium"
	id = "aluminium"
	description = "A silvery white and ductile member of the boron group of chemical elements."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168

datum/reagent/silicon
	name = "Silicon"
	id = "silicon"
	description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168

datum/reagent/fuel
	name = "Welding fuel"
	id = "fuel"
	description = "Required for welders. Flamable."
	reagent_state = LIQUID
	color = "#660000" // rgb: 102, 0, 0

datum/reagent/fuel/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//Splashing people with welding fuel to make them easy to ignite!
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH)
		M.adjust_fire_stacks(volume / 10)
		return

//Commenting this out as it's horribly broken. It's a neat effect though, so it might be worth making a new reagent (that is less common) with similar effects.	-Pete
/*
datum/reagent/fuel/reaction_obj(var/obj/O, var/volume)
	src = null
	var/turf/the_turf = get_turf(O)
	if(!the_turf)
		return //No sense trying to start a fire if you don't have a turf to set on fire. --NEO
	var/datum/gas_mixture/napalm = new
	var/datum/gas/volatile_fuel/fuel = new
	fuel.moles = 15
	napalm.trace_gases += fuel
	the_turf.assume_air(napalm)

datum/reagent/fuel/reaction_turf(var/turf/T, var/volume)
	src = null
	var/datum/gas_mixture/napalm = new
	var/datum/gas/volatile_fuel/fuel = new
	fuel.moles = 15
	napalm.trace_gases += fuel
	T.assume_air(napalm)
	return*/

datum/reagent/fuel/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustToxLoss(1)
	..()
	return

datum/reagent/space_cleaner
	name = "Space cleaner"
	id = "cleaner"
	description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
	reagent_state = LIQUID
	color = "#A5F0EE" // rgb: 165, 240, 238

datum/reagent/space_cleaner/reaction_obj(var/obj/O, var/volume)
	if(istype(O,/obj/effect/decal/cleanable))
		qdel(O)
	else
		if(O)
			O.clean_blood()

datum/reagent/space_cleaner/reaction_turf(var/turf/T, var/volume)
	if(volume >= 1)
		T.clean_blood()
		for(var/obj/effect/decal/cleanable/C in T)
			qdel(C)

		for(var/mob/living/carbon/slime/M in T)
			M.adjustToxLoss(rand(5,10))

datum/reagent/space_cleaner/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.r_hand)
			C.r_hand.clean_blood()
		if(C.l_hand)
			C.l_hand.clean_blood()
		if(C.wear_mask)
			if(C.wear_mask.clean_blood())
				C.update_inv_wear_mask(0)
		if(ishuman(M))
			var/mob/living/carbon/human/H = C
			if(H.head)
				if(H.head.clean_blood())
					H.update_inv_head(0)
			if(H.wear_suit)
				if(H.wear_suit.clean_blood())
					H.update_inv_wear_suit(0)
			else if(H.w_uniform)
				if(H.w_uniform.clean_blood())
					H.update_inv_w_uniform(0)
			if(H.shoes)
				if(H.shoes.clean_blood())
					H.update_inv_shoes(0)
		M.clean_blood()

datum/reagent/leporazine
	name = "Leporazine"
	id = "leporazine"
	description = "Leporazine can be use to stabilize an individuals body temperature."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/leporazine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
	else if(M.bodytemperature < 311)
		M.bodytemperature = min(310, M.bodytemperature + (40 * TEMPERATURE_DAMAGE_COEFFICIENT))
	..()
	return

datum/reagent/cryptobiolin
	name = "Cryptobiolin"
	id = "cryptobiolin"
	description = "Cryptobiolin causes confusion and dizzyness."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/cryptobiolin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.Dizzy(1)
	if(!M.confused) M.confused = 1
	M.confused = max(M.confused, 20)
	holder.remove_reagent(src.id, 0.5 * REAGENTS_METABOLISM)
	..()
	return

datum/reagent/kelotane
	name = "Kelotane"
	id = "kelotane"
	description = "Kelotane is a drug used to treat burns."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/kelotane/on_mob_life(var/mob/living/M as mob)
	if(M.stat == 2.0)
		return
	if(!M) M = holder.my_atom
	M.heal_organ_damage(0,2*REM)
	..()
	return

datum/reagent/dermaline
	name = "Dermaline"
	id = "dermaline"
	description = "Dermaline is the next step in burn medication. Works twice as good as kelotane and enables the body to restore even the direst heat-damaged tissue."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/dermaline/on_mob_life(var/mob/living/M as mob)
	if(M.stat == 2.0) //THE GUY IS **DEAD**! BEREFT OF ALL LIFE HE RESTS IN PEACE etc etc. He does NOT metabolise shit anymore, god DAMN
		return
	if(!M) M = holder.my_atom
	M.heal_organ_damage(0,3*REM)
	..()
	return

datum/reagent/dexalin
	name = "Dexalin"
	id = "dexalin"
	description = "Dexalin is used in the treatment of oxygen deprivation."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/dexalin/on_mob_life(var/mob/living/M as mob)
	if(M.stat == 2.0)
		return  //See above, down and around. --Agouri
	if(!M) M = holder.my_atom
	M.adjustOxyLoss(-2*REM)
	if(holder.has_reagent("lexorin"))
		holder.remove_reagent("lexorin", 2*REM)
	..()
	return

datum/reagent/dexalinp
	name = "Dexalin Plus"
	id = "dexalinp"
	description = "Dexalin Plus is used in the treatment of oxygen deprivation. Its highly effective."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/dexalinp/on_mob_life(var/mob/living/M as mob)
	if(M.stat == 2.0)
		return
	if(!M) M = holder.my_atom
	M.adjustOxyLoss(-M.getOxyLoss())
	if(holder.has_reagent("lexorin"))
		holder.remove_reagent("lexorin", 2*REM)
	..()
	return

datum/reagent/tricordrazine
	name = "Tricordrazine"
	id = "tricordrazine"
	description = "Tricordrazine is a highly potent stimulant, originally derived from cordrazine. Can be used to treat a wide range of injuries."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/tricordrazine/on_mob_life(var/mob/living/M as mob)
	if(M.stat == 2.0)
		return
	if(!M) M = holder.my_atom
	if(M.getOxyLoss() && prob(80)) M.adjustOxyLoss(-1*REM)
	if(M.getBruteLoss() && prob(80)) M.heal_organ_damage(1*REM,0)
	if(M.getFireLoss() && prob(80)) M.heal_organ_damage(0,1*REM)
	if(M.getToxLoss() && prob(80)) M.adjustToxLoss(-1*REM)
	..()
	return

datum/reagent/anti_toxin
	name = "Anti-Toxin (Dylovene)"
	id = "anti_toxin"
	description = "Dylovene is a broad-spectrum antitoxin."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/anti_toxin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.reagents.remove_all_type(/datum/reagent/toxin, 1*REM, 0, 1)
	M.drowsyness = max(M.drowsyness-2*REM, 0)
	M.hallucination = max(0, M.hallucination - 5*REM)
	M.adjustToxLoss(-2*REM)
	..()
	return

datum/reagent/adminordrazine //An OP chemical for admins
	name = "Adminordrazine"
	id = "adminordrazine"
	description = "It's magic. We don't have to explain it."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/adminordrazine/on_mob_life(var/mob/living/carbon/M as mob)
	if(!M) M = holder.my_atom ///This can even heal dead people.
	M.reagents.remove_all_type(/datum/reagent/toxin, 5*REM, 0, 1)
	M.setCloneLoss(0)
	M.setOxyLoss(0)
	M.radiation = 0
	M.heal_organ_damage(5,5)
	M.adjustToxLoss(-5)
	M.hallucination = 0
	M.setBrainLoss(0)
	M.disabilities = 0
	M.sdisabilities = 0
	M.eye_blurry = 0
	M.eye_blind = 0
	M.SetWeakened(0)
	M.SetStunned(0)
	M.SetParalysis(0)
	M.silent = 0
	M.dizziness = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.confused = 0
	M.sleeping = 0
	M.jitteriness = 0
	for(var/datum/disease/D in M.viruses)
		D.spread = "Remissive"
		D.stage--
		if(D.stage < 1)
			D.cure()
	..()
	return

datum/reagent/synaptizine
	name = "Synaptizine"
	id = "synaptizine"
	description = "Synaptizine is used to treat various diseases."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/synaptizine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.drowsyness = max(M.drowsyness-5, 0)
	M.AdjustParalysis(-1)
	M.AdjustStunned(-1)
	M.AdjustWeakened(-1)
	if(holder.has_reagent("mindbreaker"))
		holder.remove_reagent("mindbreaker", 5)
	M.hallucination = max(0, M.hallucination - 10)
	if(prob(60))	M.adjustToxLoss(1)
	..()
	return

datum/reagent/impedrezene
	name = "Impedrezene"
	id = "impedrezene"
	description = "Impedrezene is a narcotic that impedes one's ability by slowing down the higher brain cell functions."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/impedrezene/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.jitteriness = max(M.jitteriness-5,0)
	if(prob(80)) M.adjustBrainLoss(1*REM)
	if(prob(50)) M.drowsyness = max(M.drowsyness, 3)
	if(prob(10)) M.emote("drool")
	..()
	return

datum/reagent/hyronalin
	name = "Hyronalin"
	id = "hyronalin"
	description = "Hyronalin is a medicinal drug used to counter the effect of radiation poisoning."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/hyronalin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.radiation = max(M.radiation-3*REM,0)
	..()
	return

datum/reagent/arithrazine
	name = "Arithrazine"
	id = "arithrazine"
	description = "Arithrazine is an unstable medication used for the most extreme cases of radiation poisoning."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/arithrazine/on_mob_life(var/mob/living/M as mob)
	if(M.stat == 2.0)
		return  //See above, down and around. --Agouri
	if(!M) M = holder.my_atom
	M.radiation = max(M.radiation-7*REM,0)
	M.adjustToxLoss(-1*REM)
	if(prob(15))
		M.take_organ_damage(1, 0)
	..()
	return

datum/reagent/alkysine
	name = "Alkysine"
	id = "alkysine"
	description = "Alkysine is a drug used to lessen the damage to neurological tissue after a catastrophic injury. Can heal brain tissue."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/alkysine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustBrainLoss(-3*REM)
	..()
	return

datum/reagent/imidazoline
	name = "Imidazoline"
	id = "imidazoline"
	description = "Heals eye damage"
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/imidazoline/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.eye_blurry = max(M.eye_blurry-5 , 0)
	M.eye_blind = max(M.eye_blind-5 , 0)
	M.disabilities &= ~NEARSIGHTED
	M.eye_stat = max(M.eye_stat-5, 0)
//	M.sdisabilities &= ~1		Replaced by eye surgery
	..()
	return

datum/reagent/bicaridine
	name = "Bicaridine"
	id = "bicaridine"
	description = "Bicaridine is an analgesic medication and can be used to treat blunt trauma."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/bicaridine/on_mob_life(var/mob/living/M as mob)
	if(M.stat == 2.0)
		return
	if(!M) M = holder.my_atom
	M.heal_organ_damage(2*REM,0)
	..()
	return

datum/reagent/hyperzine
	name = "Hyperzine"
	id = "hyperzine"
	description = "Hyperzine is a highly effective, long lasting, muscle stimulant."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/hyperzine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(5)) M.emote(pick("twitch","blink_r","shiver"))
	M.status_flags |= GOTTAGOFAST
	holder.remove_reagent(src.id, 0.5 * REAGENTS_METABOLISM)
	//..()		//this was causing hyperzine to be consumed twice...
	return

datum/reagent/cryoxadone
	name = "Cryoxadone"
	id = "cryoxadone"
	description = "A chemical mixture with almost magical healing powers. Its main limitation is that the targets body temperature must be under 170K for it to metabolise correctly."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/cryoxadone/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.bodytemperature < 170)
		M.adjustCloneLoss(-1)
		M.adjustOxyLoss(-3)
		M.heal_organ_damage(3,3)
		M.adjustToxLoss(-3)
	..()
	return

datum/reagent/clonexadone
	name = "Clonexadone"
	id = "clonexadone"
	description = "A liquid compound similar to that used in the cloning process. Can be used to 'finish' clones that get ejected early when used in conjunction with a cryo tube."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/clonexadone/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.bodytemperature < 170)
		M.adjustCloneLoss(-3)
		M.adjustOxyLoss(-3)
		M.heal_organ_damage(3,3)
		M.adjustToxLoss(-3)
		M.status_flags &= ~DISFIGURED
	..()
	return

datum/reagent/rezadone
	name = "Rezadone"
	id = "rezadone"
	description = "A powder derived from fish toxin, this substance can effectively treat cellular damage in humanoids, though excessive consumption has side effects."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0

datum/reagent/rezadone/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(!data) data = 1
	data++
	switch(data)
		if(1 to 15)
			M.adjustCloneLoss(-1)
			M.heal_organ_damage(1,1)
		if(15 to 35)
			M.adjustCloneLoss(-2)
			M.heal_organ_damage(2,1)
			M.status_flags &= ~DISFIGURED
		if(35 to INFINITY)
			M.adjustToxLoss(1)
			M.Dizzy(5)
			M.Jitter(5)

	..()
	return

datum/reagent/spaceacillin
	name = "Spaceacillin"
	id = "spaceacillin"
	description = "An all-purpose antiviral agent."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220

datum/reagent/spaceacillin/on_mob_life(var/mob/living/M as mob)//no more mr. panacea
	holder.remove_reagent(src.id, 0.2)
	..()
	return

datum/reagent/nanites
	name = "Nanomachines"
	id = "nanites"
	description = "Microscopic construction robots."
	reagent_state = LIQUID
	color = "#535E66" // rgb: 83, 94, 102

datum/reagent/nanites/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	src = null
	if( (prob(10) && method==TOUCH) || method==INGEST)
		M.contract_disease(new /datum/disease/transformation/robot(0),1)

datum/reagent/xenomicrobes
	name = "Xenomicrobes"
	id = "xenomicrobes"
	description = "Microbes with an entirely alien cellular structure."
	reagent_state = LIQUID
	color = "#535E66" // rgb: 83, 94, 102

datum/reagent/xenomicrobes/reaction_mob(var/mob/M, var/method=TOUCH, var/volume)
	src = null
	if( (prob(10) && method==TOUCH) || method==INGEST)
		M.contract_disease(new /datum/disease/transformation/xeno(0),1)

datum/reagent/fluorosurfactant//foam precursor
	name = "Fluorosurfactant"
	id = "fluorosurfactant"
	description = "A perfluoronated sulfonic acid that forms a foam when mixed with water."
	reagent_state = LIQUID
	color = "#9E6B38" // rgb: 158, 107, 56

datum/reagent/foaming_agent// Metal foaming agent. This is lithium hydride. Add other recipes (e.g. LiH + H2O -> LiOH + H2) eventually.
	name = "Foaming agent"
	id = "foaming_agent"
	description = "A agent that yields metallic foam when mixed with light metal and a strong acid."
	reagent_state = SOLID
	color = "#664B63" // rgb: 102, 75, 99

datum/reagent/ammonia
	name = "Ammonia"
	id = "ammonia"
	description = "A caustic substance commonly used in fertilizer or household cleaners."
	reagent_state = GAS
	color = "#404030" // rgb: 64, 64, 48

datum/reagent/diethylamine
	name = "Diethylamine"
	id = "diethylamine"
	description = "A secondary amine, mildly corrosive."
	reagent_state = LIQUID
	color = "#604030" // rgb: 96, 64, 48

datum/reagent/ethylredoxrazine	// FUCK YOU, ALCOHOL
	name = "Ethylredoxrazine"
	id = "ethylredoxrazine"
	description = "A powerful oxidizer that reacts with ethanol."
	reagent_state = SOLID
	color = "#605048" // rgb: 96, 80, 72

datum/reagent/ethylredoxrazine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.dizziness = 0
	M.drowsyness = 0
	M.stuttering = 0
	M.confused = 0
	M.reagents.remove_all_type(/datum/reagent/ethanol, 1*REM, 0, 1)
	..()
	return

//////////////////////////Poison stuff///////////////////////

datum/reagent/toxin
	name = "Toxin"
	id = "toxin"
	description = "A toxic chemical."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	var/toxpwr = 1.5

datum/reagent/toxin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(toxpwr)
		M.adjustToxLoss(toxpwr*REM)
	..()
	return

datum/reagent/toxin/amatoxin
	name = "Amatoxin"
	id = "amatoxin"
	description = "A powerful poison derived from certain species of mushroom."
	reagent_state = LIQUID
	color = "#792300" // rgb: 121, 35, 0
	toxpwr = 1

datum/reagent/toxin/mutagen
	name = "Unstable mutagen"
	id = "mutagen"
	description = "Might cause unpredictable mutations. Keep away from children."
	reagent_state = LIQUID
	color = "#13BC5E" // rgb: 19, 188, 94
	toxpwr = 0

datum/reagent/toxin/mutagen/reaction_mob(var/mob/living/carbon/M, var/method=TOUCH, var/volume)
	if(!..())	return
	if(!istype(M) || !M.dna)	return  //No robots, AIs, aliens, Ians or other mobs should be affected by this.
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

datum/reagent/toxin/mutagen/on_mob_life(var/mob/living/carbon/M)
	if(!istype(M))	return
	if(!M) M = holder.my_atom
	M.apply_effect(5,IRRADIATE,0)
	..()
	return

datum/reagent/toxin/plasma
	name = "Plasma"
	id = "plasma"
	description = "Plasma in its liquid form."
	reagent_state = LIQUID
	color = "#DB2D08" // rgb: 219, 45, 8
	toxpwr = 3

datum/reagent/toxin/plasma/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(holder.has_reagent("inaprovaline"))
		holder.remove_reagent("inaprovaline", 2*REM)
	..()
	return

datum/reagent/toxin/plasma/reaction_obj(var/obj/O, var/volume)
	src = null
	/*if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/egg/slime))
		var/obj/item/weapon/reagent_containers/food/snacks/egg/slime/egg = O
		if (egg.grown)
			egg.Hatch()*/
	if((!O) || (!volume))	return 0
	O.atmos_spawn_air(SPAWN_TOXINS|SPAWN_20C, volume)

datum/reagent/toxin/plasma/reaction_turf(var/turf/simulated/T, var/volume)
	src = null
	if(istype(T))
		T.atmos_spawn_air(SPAWN_TOXINS|SPAWN_20C, volume)
	return

datum/reagent/toxin/plasma/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//Splashing people with plasma is stronger than fuel!
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH)
		M.adjust_fire_stacks(volume / 5)
		return

datum/reagent/toxin/lexorin
	name = "Lexorin"
	id = "lexorin"
	description = "Lexorin temporarily stops respiration. Causes tissue damage."
	reagent_state = LIQUID
	color = "#C8A5DC" // rgb: 200, 165, 220
	toxpwr = 0

datum/reagent/toxin/lexorin/on_mob_life(var/mob/living/M as mob)
	if(M.stat == 2.0)
		return
	if(!M) M = holder.my_atom
	if(prob(33))
		M.take_organ_damage(1*REM, 0)
	M.adjustOxyLoss(3)
	if(prob(20)) M.emote("gasp")
	..()
	return

datum/reagent/toxin/slimejelly
	name = "Slime Jelly"
	id = "slimejelly"
	description = "A gooey semi-liquid produced from one of the deadliest lifeforms in existence. SO REAL."
	reagent_state = LIQUID
	color = "#801E28" // rgb: 128, 30, 40
	toxpwr = 0

datum/reagent/toxin/slimejelly/on_mob_life(var/mob/living/M as mob)
	if(prob(10))
		M << "<span class='danger'>Your insides are burning!</span>"
		M.adjustToxLoss(rand(20,60)*REM)
	else if(prob(40))
		M.heal_organ_damage(5*REM,0)
	..()
	return

datum/reagent/toxin/cyanide
	name = "Cyanide"
	id = "cyanide"
	description = "A highly toxic chemical."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	toxpwr = 3

datum/reagent/toxin/cyanide/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.adjustOxyLoss(3*REM)
	M.sleeping += 1
	..()
	return

datum/reagent/toxin/minttoxin
	name = "Mint Toxin"
	id = "minttoxin"
	description = "Useful for dealing with undesirable customers."
	reagent_state = LIQUID
	color = "#CF3600" // rgb: 207, 54, 0
	toxpwr = 0

datum/reagent/toxin/minttoxin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if (FAT in M.mutations)
		M.gib()
	..()
	return

datum/reagent/toxin/carpotoxin
	name = "Carpotoxin"
	id = "carpotoxin"
	description = "A deadly neurotoxin produced by the dreaded spess carp."
	reagent_state = LIQUID
	color = "#003333" // rgb: 0, 51, 51
	toxpwr = 2

datum/reagent/toxin/zombiepowder
	name = "Zombie Powder"
	id = "zombiepowder"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	reagent_state = SOLID
	color = "#669900" // rgb: 102, 153, 0
	toxpwr = 0.5

datum/reagent/toxin/zombiepowder/on_mob_life(var/mob/living/carbon/M as mob)
	if(!M) M = holder.my_atom
	M.status_flags |= FAKEDEATH
	M.adjustOxyLoss(0.5*REM)
	M.Weaken(5)
	M.silent = max(M.silent, 5)
	M.tod = worldtime2text()
	..()
	return

datum/reagent/toxin/zombiepowder/Del()
	if(holder && ismob(holder.my_atom))
		var/mob/M = holder.my_atom
		M.status_flags &= ~FAKEDEATH
	..()

datum/reagent/toxin/mindbreaker
	name = "Mindbreaker Toxin"
	id = "mindbreaker"
	description = "A powerful hallucinogen. Not a thing to be messed with."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 139, 166, 233
	toxpwr = 0

datum/reagent/toxin/mindbreaker/on_mob_life(var/mob/living/M)
	if(!M) M = holder.my_atom
	M.hallucination += 10
	..()
	return

datum/reagent/toxin/plantbgone
	name = "Plant-B-Gone"
	id = "plantbgone"
	description = "A harmful toxic mixture to kill plantlife. Do not ingest!"
	reagent_state = LIQUID
	color = "#49002E" // rgb: 73, 0, 46
	toxpwr = 1

datum/reagent/toxin/plantbgone/reaction_obj(var/obj/O, var/volume)
	if(istype(O,/obj/structure/alien/weeds/))
		var/obj/structure/alien/weeds/alien_weeds = O
		alien_weeds.health -= rand(15,35) // Kills alien weeds pretty fast
		alien_weeds.healthcheck()
	else if(istype(O,/obj/effect/glowshroom)) //even a small amount is enough to kill it
		qdel(O)
	else if(istype(O,/obj/effect/spacevine))
		var/obj/effect/spacevine/SV = O
		SV.on_chem_effect(src)

datum/reagent/toxin/plantbgone/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	src = null
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(!C.wear_mask) // If not wearing a mask
			C.adjustToxLoss(2) // 4 toxic damage per application, doubled for some reason

datum/reagent/toxin/plantbgone/weedkiller
	name = "Weed Killer"
	id = "weedkiller"
	description = "A harmful toxic mixture to kill weeds. Do not ingest!"
	reagent_state = LIQUID
	color = "#4B004B" // rgb: 75, 0, 75


datum/reagent/toxin/pestkiller
	name = "Pest Killer"
	id = "pestkiller"
	description = "A harmful toxic mixture to kill pests. Do not ingest!"
	color = "#4B004B" // rgb: 75, 0, 75
	toxpwr = 1

datum/reagent/toxin/pestkiller/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	src = null
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(!C.wear_mask) // If not wearing a mask
			C.adjustToxLoss(2) // 4 toxic damage per application, doubled for some reason

datum/reagent/toxin/stoxin
	name = "Sleep Toxin"
	id = "stoxin"
	description = "An effective hypnotic used to treat insomnia."
	reagent_state = LIQUID
	color = "#E895CC" // rgb: 232, 149, 204
	toxpwr = 0

datum/reagent/toxin/stoxin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(!data) data = 1
	switch(data)
		if(1 to 12)
			if(prob(5))	M.emote("yawn")
		if(12 to 15)
			M.eye_blurry = max(M.eye_blurry, 10)
		if(15 to 25)
			M.drowsyness  = max(M.drowsyness, 20)
		if(25 to INFINITY)
			M.Paralyse(20)
			M.drowsyness  = max(M.drowsyness, 30)
	data++
	..()
	return


datum/reagent/toxin/spore
	name = "Spore Toxin"
	id = "spore"
	description = "A toxic spore cloud which blocks vision when ingested."
	reagent_state = LIQUID
	color = "#9ACD32"
	toxpwr = 0.5

datum/reagent/toxin/spore/on_mob_life(var/mob/living/M as mob)
	..()
	M.damageoverlaytemp = 60
	M.eye_blurry = max(M.eye_blurry, 3)
	return

datum/reagent/toxin/chloralhydrate
	name = "Chloral Hydrate"
	id = "chloralhydrate"
	description = "A powerful sedative."
	reagent_state = SOLID
	color = "#000067" // rgb: 0, 0, 103
	toxpwr = 0

datum/reagent/toxin/chloralhydrate/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(!data) data = 1
	data++
	switch(data)
		if(1 to 10)
			M.confused += 2
			M.drowsyness += 2
		if(10 to 50)
			M.sleeping += 1
		if(51 to INFINITY)
			M.sleeping += 1
			M.adjustToxLoss((data - 50)*REM)
	holder.remove_reagent(src.id, 0.5 * REAGENTS_METABOLISM)
	..()
	return

datum/reagent/toxin/beer2	//disguised as normal beer for use by emagged brobots
	name = "Beer"
	id = "beer2"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

datum/reagent/toxin/beer2/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(!data) data = 1
	switch(data)
		if(1 to 50)
			M.sleeping += 1
		if(51 to INFINITY)
			M.sleeping += 1
			M.adjustToxLoss((data - 50)*REM)
	data++
	holder.remove_reagent(src.id, 0.5 * REAGENTS_METABOLISM)
	..()
	return

datum/reagent/toxin/acid
	name = "Sulphuric acid"
	id = "sacid"
	description = "A strong mineral acid with the molecular formula H2SO4."
	reagent_state = LIQUID
	color = "#DB5008" // rgb: 219, 80, 8
	toxpwr = 1
	var/meltprob = 10

datum/reagent/toxin/acid/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//magic numbers everywhere
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M

			if(H.head)
				if(prob(meltprob) && !H.head.unacidable)
					H << "<span class='danger'>Your headgear melts away but protects you from the acid!</span>"
					qdel(H.head)
					H.update_inv_head(0)
					H.update_hair(0)
				else
					H << "<span class='warning'>Your headgear protects you from the acid.</span>"
				return

			if(H.wear_mask)
				if(prob(meltprob) && !H.wear_mask.unacidable)
					H << "<span class='danger'>Your mask melts away but protects you from the acid!</span>"
					qdel(H.wear_mask)
					H.update_inv_wear_mask(0)
					H.update_hair(0)
				else
					H << "<span class='warning'>Your mask protects you from the acid.</span>"
				return

			if(H.glasses) //Doesn't protect you from the acid but can melt anyways!
				if(prob(meltprob) && !H.glasses.unacidable)
					H << "<span class='danger'>Your glasses melts away!</span>"
					qdel(H.glasses)
					H.update_inv_glasses(0)

		else if(ismonkey(M))
			var/mob/living/carbon/monkey/MK = M
			if(MK.wear_mask)
				if(!MK.wear_mask.unacidable)
					MK << "<span class='danger'>Your mask melts away but protects you from the acid!</span>"
					qdel(MK.wear_mask)
					MK.update_inv_wear_mask(0)
				else
					MK << "<span class='warning'>Your mask protects you from the acid.</span>"
				return

		if(!M.unacidable)
			if(istype(M, /mob/living/carbon/human) && volume >= 3)
				var/mob/living/carbon/human/H = M
				var/obj/item/organ/limb/affecting = H.get_organ("head")
				if(affecting)
					if(affecting.take_damage(4*toxpwr, 2*toxpwr))
						H.update_damage_overlays(0)
					if(prob(meltprob)) //Applies disfigurement
						H.emote("scream")
						H.facial_hair_style = "Shaved"
						H.hair_style = "Bald"
						H.update_hair(0)
						H.status_flags |= DISFIGURED
			else
				M.take_organ_damage(min(6*toxpwr, volume * toxpwr)) // uses min() and volume to make sure they aren't being sprayed in trace amounts (1 unit != insta rape) -- Doohl
	else
		if(!M.unacidable)
			M.take_organ_damage(min(6*toxpwr, volume * toxpwr))

datum/reagent/toxin/acid/reaction_obj(var/obj/O, var/volume)
	if((istype(O,/obj/item) || istype(O,/obj/effect/glowshroom)) && prob(meltprob * 3))
		if(!O.unacidable)
			var/obj/effect/decal/cleanable/molten_item/I = new/obj/effect/decal/cleanable/molten_item(get_turf(O))
			I.desc = "Looks like this was \an [O] some time ago."
			for(var/mob/M in viewers(5, O))
				M << "<span class='danger'> \the [O] melts.</span>"
			qdel(O)

datum/reagent/toxin/acid/polyacid
	name = "Polytrinic acid"
	id = "pacid"
	description = "Polytrinic acid is a an extremely corrosive chemical substance."
	reagent_state = LIQUID
	color = "#8E18A9" // rgb: 142, 24, 169
	toxpwr = 2
	meltprob = 30

datum/reagent/toxin/coffeepowder
	name = "Coffee Grounds"
	id = "coffeepowder"
	description = "Finely ground coffee beans, used to make coffee."
	reagent_state = SOLID
	color = "#5B2E0D" // rgb: 91, 46, 13
	toxpwr = 0.5

datum/reagent/toxin/teapowder
	name = "Ground Tea Leaves"
	id = "teapowder"
	description = "Finely shredded tea leaves, used for making tea."
	reagent_state = SOLID
	color = "#7F8400" // rgb: 127, 132, 0
	toxpwr = 0.5

datum/reagent/toxin/mutetoxin //the new zombie powder.
	name = "Mute Toxin"
	id = "mutetoxin"
	description = "A toxin that temporarily paralyzes the vocal cords."
	reagent_state = LIQUID
	color = "#F0F8FF" // rgb: 240, 248, 255
	toxpwr = 0

datum/reagent/toxin/mutetoxin/on_mob_life(mob/living/carbon/M)
	M.silent += REM + 1 //If this var is increased by one or less, it will have no effect since silent is decreased right after reagents are handled in Life(). Hence the + 1.
	..()

datum/reagent/toxin/staminatoxin
	name = "Tirizene"
	id = "tirizene"
	description = "A toxin that affects the stamina of a person when injected into the bloodstream."
	reagent_state = LIQUID
	color = "#6E2828"
	data = 13
	toxpwr = 0

datum/reagent/toxin/staminatoxin/on_mob_life(mob/living/carbon/M)
	M.adjustStaminaLoss(REM * data)
	data = max(data - 1, 3)
	..()

/////////////////////////Coloured Crayon Powder////////////////////////////
//For colouring in /proc/mix_color_from_reagents


datum/reagent/crayonpowder
	name = "Crayon Powder"
	id = "crayon powder"
	var/colorname = "none"
	description = "A powder made by grinding down crayons, good for colouring chemical reagents."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 207, 54, 0

datum/reagent/crayonpowder/New()
	description = "\an [colorname] powder made by grinding down crayons, good for colouring chemical reagents."


datum/reagent/crayonpowder/red
	name = "Red Crayon Powder"
	id = "redcrayonpowder"
	colorname = "red"

datum/reagent/crayonpowder/orange
	name = "Orange Crayon Powder"
	id = "orangecrayonpowder"
	colorname = "orange"
	color = "#FF9300" // orange

datum/reagent/crayonpowder/yellow
	name = "Yellow Crayon Powder"
	id = "yellowcrayonpowder"
	colorname = "yellow"
	color = "#FFF200" // yellow

datum/reagent/crayonpowder/green
	name = "Green Crayon Powder"
	id = "greencrayonpowder"
	colorname = "green"
	color = "#A8E61D" // green

datum/reagent/crayonpowder/blue
	name = "Blue Crayon Powder"
	id = "bluecrayonpowder"
	colorname = "blue"
	color = "#00B7EF" // blue

datum/reagent/crayonpowder/purple
	name = "Purple Crayon Powder"
	id = "purplecrayonpowder"
	colorname = "purple"
	color = "#DA00FF" // purple

datum/reagent/crayonpowder/invisible
	name = "Invisible Crayon Powder"
	id = "invisiblecrayonpowder"
	colorname = "invisible"
	color = "#FFFFFF00" // white + no alpha


/////////////////////////Food Reagents////////////////////////////
// Part of the food code. Nutriment is used instead of the old "heal_amt" code. Also is where all the food
// 	condiments, additives, and such go.
datum/reagent/nutriment
	name = "Nutriment"
	id = "nutriment"
	description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
	reagent_state = SOLID
	nutriment_factor = 15 * REAGENTS_METABOLISM
	color = "#664330" // rgb: 102, 67, 48

datum/reagent/nutriment/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(50)) M.heal_organ_damage(1,0)
	M.nutrition += nutriment_factor	// For hunger and fatness
/*
	// If overeaten - vomit and fall down
	// Makes you feel bad but removes reagents and some effect
	// from your body
	if (M.nutrition > 650)
		M.nutrition = rand (250, 400)
		M.weakened += rand(2, 10)
		M.jitteriness += rand(0, 5)
		M.dizziness = max (0, (M.dizziness - rand(0, 15)))
		M.druggy = max (0, (M.druggy - rand(0, 15)))
		M.adjustToxLoss(rand(-15, -5)))
		M.updatehealth()
*/
	..()
	return

datum/reagent/lipozine
	name = "Lipozine" // The anti-nutriment.
	id = "lipozine"
	description = "A chemical compound that causes a powerful fat-burning reaction."
	reagent_state = LIQUID
	nutriment_factor = 10 * REAGENTS_METABOLISM
	color = "#BBEDA4" // rgb: 187, 237, 164

datum/reagent/lipozine/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.nutrition -= nutriment_factor
	M.overeatduration = 0
	if(M.nutrition < 0)//Prevent from going into negatives.
		M.nutrition = 0
	..()
	return

datum/reagent/soysauce
	name = "Soysauce"
	id = "soysauce"
	description = "A salty sauce made from the soy plant."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#792300" // rgb: 121, 35, 0

datum/reagent/ketchup
	name = "Ketchup"
	id = "ketchup"
	description = "Ketchup, catsup, whatever. It's tomato paste."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#731008" // rgb: 115, 16, 8


datum/reagent/capsaicin
	name = "Capsaicin Oil"
	id = "capsaicin"
	description = "This is what makes chilis hot."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 179, 16, 8

datum/reagent/capsaicin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(!data) data = 1
	switch(data)
		if(1 to 15)
			M.bodytemperature += 5 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent("frostoil"))
				holder.remove_reagent("frostoil", 5)
			if(istype(M, /mob/living/carbon/slime))
				M.bodytemperature += rand(5,20)
		if(15 to 25)
			M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(istype(M, /mob/living/carbon/slime))
				M.bodytemperature += rand(10,20)
		if(25 to INFINITY)
			M.bodytemperature += 15 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(istype(M, /mob/living/carbon/slime))
				M.bodytemperature += rand(15,20)
	data++
	..()
	return

datum/reagent/condensedcapsaicin
	name = "Condensed Capsaicin"
	id = "condensedcapsaicin"
	description = "A chemical agent used for self-defense and in police work."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 179, 16, 8

datum/reagent/condensedcapsaicin/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH)
		if(istype(M, /mob/living/carbon/human))
			var/mob/living/carbon/human/victim = M
			var/mouth_covered = 0
			var/eyes_covered = 0
			var/obj/item/safe_thing = null
			if( victim.wear_mask )
				if ( victim.wear_mask.flags & MASKCOVERSEYES )
					eyes_covered = 1
					safe_thing = victim.wear_mask
				if ( victim.wear_mask.flags & MASKCOVERSMOUTH )
					mouth_covered = 1
					safe_thing = victim.wear_mask
			if( victim.head )
				if ( victim.head.flags & MASKCOVERSEYES )
					eyes_covered = 1
					safe_thing = victim.head
				if ( victim.head.flags & MASKCOVERSMOUTH )
					mouth_covered = 1
					safe_thing = victim.head
			if(victim.glasses)
				eyes_covered = 1
				if ( !safe_thing )
					safe_thing = victim.glasses
			if ( eyes_covered && mouth_covered )
				return
			else if ( mouth_covered )	// Reduced effects if partially protected
				if(prob(5))
					victim.emote("scream")
				victim.eye_blurry = max(M.eye_blurry, 3)
				victim.eye_blind = max(M.eye_blind, 1)
				victim.confused = max(M.confused, 3)
				victim.damageoverlaytemp = 60
				victim.Weaken(3)
				victim.drop_item()
				return
			else if ( eyes_covered ) // Eye cover is better than mouth cover
				victim.eye_blurry = max(M.eye_blurry, 3)
				victim.damageoverlaytemp = 30
				return
			else // Oh dear :D
				if(prob(5))
					victim.emote("scream")
				victim.eye_blurry = max(M.eye_blurry, 5)
				victim.eye_blind = max(M.eye_blind, 2)
				victim.confused = max(M.confused, 6)
				victim.damageoverlaytemp = 75
				victim.Weaken(5)
				victim.drop_item()

datum/reagent/condensedcapsaicin/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(prob(5))
		M.visible_message("<span class='warning'>[M] [pick("dry heaves!","coughs!","splutters!")]</span>")
	..()
	return

datum/reagent/frostoil
	name = "Frost Oil"
	id = "frostoil"
	description = "A special oil that noticably chills the body. Extraced from Icepeppers."
	reagent_state = LIQUID
	color = "#B31008" // rgb: 139, 166, 233

datum/reagent/frostoil/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(!data) data = 1
	switch(data)
		if(1 to 15)
			M.bodytemperature -= 5 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent("capsaicin"))
				holder.remove_reagent("capsaicin", 5)
			if(istype(M, /mob/living/carbon/slime))
				M.bodytemperature -= rand(5,20)
		if(15 to 25)
			M.bodytemperature -= 10 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(istype(M, /mob/living/carbon/slime))
				M.bodytemperature -= rand(10,20)
		if(25 to INFINITY)
			M.bodytemperature -= 15 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(prob(1)) M.emote("shiver")
			if(istype(M, /mob/living/carbon/slime))
				M.bodytemperature -= rand(15,20)
	data++
	..()
	return

datum/reagent/frostoil/reaction_turf(var/turf/simulated/T, var/volume)
	if(volume >= 5)
		for(var/mob/living/carbon/slime/M in T)
			M.adjustToxLoss(rand(15,30))
		//if(istype(T))
		//	T.atmos_spawn_air(SPAWN_COLD)

datum/reagent/sodiumchloride
	name = "Table Salt"
	id = "sodiumchloride"
	description = "A salt made of sodium chloride. Commonly used to season food."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255,255,255

datum/reagent/blackpepper
	name = "Black Pepper"
	id = "blackpepper"
	description = "A powder ground from peppercorns. *AAAACHOOO*"
	reagent_state = SOLID
	// no color (ie, black)

datum/reagent/coco
	name = "Coco Powder"
	id = "coco"
	description = "A fatty, bitter paste made from coco beans."
	reagent_state = SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

datum/reagent/coco/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	..()
	return

datum/reagent/hot_coco
	name = "Hot Chocolate"
	id = "hot_coco"
	description = "Made with love! And coco beans."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#403010" // rgb: 64, 48, 16

datum/reagent/hot_coco/on_mob_life(var/mob/living/M as mob)
	if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	M.nutrition += nutriment_factor
	..()
	return

datum/reagent/mushroomhallucinogen
	name = "Mushroom Hallucinogen"
	id = "mushroomhallucinogen"
	description = "A strong hallucinogenic drug derived from certain species of mushroom."
	color = "#E700E7" // rgb: 231, 0, 231

datum/reagent/mushroomhallucinogen/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.druggy = max(M.druggy, 30)
	if(!data) data = 1
	switch(data)
		if(1 to 5)
			if (!M.stuttering) M.stuttering = 1
			M.Dizzy(5)
			if(prob(10)) M.emote(pick("twitch","giggle"))
		if(5 to 10)
			if (!M.stuttering) M.stuttering = 1
			M.Jitter(10)
			M.Dizzy(10)
			M.druggy = max(M.druggy, 35)
			if(prob(20)) M.emote(pick("twitch","giggle"))
		if (10 to INFINITY)
			if (!M.stuttering) M.stuttering = 1
			M.Jitter(20)
			M.Dizzy(20)
			M.druggy = max(M.druggy, 40)
			if(prob(30)) M.emote(pick("twitch","giggle"))
	holder.remove_reagent(src.id, 0.2)
	data++
	..()
	return

datum/reagent/sprinkles
	name = "Sprinkles"
	id = "sprinkles"
	description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#FF00FF" // rgb: 255, 0, 255

datum/reagent/sprinkles/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	if(istype(M, /mob/living/carbon/human) && M.job in list("Security Officer", "Head of Security", "Detective", "Warden"))
		if(!M) M = holder.my_atom
		M.heal_organ_damage(1,1)
		M.nutrition += nutriment_factor
		..()
		return
	..()

/*	//removed because of meta bullshit. this is why we can't have nice things.
datum/reagent/syndicream
	name = "Cream filling"
	id = "syndicream"
	description = "Delicious cream filling of a mysterious origin. Tastes criminally good."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#AB7878" // rgb: 171, 120, 120

datum/reagent/syndicream/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	if(istype(M, /mob/living/carbon/human) && M.mind)
		if(M.mind.special_role)
			if(!M) M = holder.my_atom
			M.heal_organ_damage(1,1)
			M.nutrition += nutriment_factor
			..()
			return
	..()
*/
datum/reagent/cornoil
	name = "Corn Oil"
	id = "cornoil"
	description = "An oil derived from various types of corn."
	reagent_state = LIQUID
	nutriment_factor = 20 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

datum/reagent/cornoil/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	..()
	return

datum/reagent/cornoil/reaction_turf(var/turf/simulated/T, var/volume)
	if (!istype(T)) return
	src = null
	if(volume >= 3)
		T.MakeSlippery()
	var/hotspot = (locate(/obj/effect/hotspot) in T)
	if(hotspot)
		var/datum/gas_mixture/lowertemp = T.remove_air( T:air:total_moles() )
		lowertemp.temperature = max( min(lowertemp.temperature-2000,lowertemp.temperature / 2) ,0)
		lowertemp.react()
		T.assume_air(lowertemp)
		qdel(hotspot)

datum/reagent/enzyme
	name = "Universal Enzyme"
	id = "enzyme"
	description = "A universal enzyme used in the preperation of certain chemicals and foods."
	reagent_state = LIQUID
	color = "#365E30" // rgb: 54, 94, 48

datum/reagent/dry_ramen
	name = "Dry Ramen"
	id = "dry_ramen"
	description = "Space age food, since August 25, 1958. Contains dried noodles, vegetables, and chemicals that boil in contact with water."
	reagent_state = SOLID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

datum/reagent/dry_ramen/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	..()
	return

datum/reagent/hot_ramen
	name = "Hot Ramen"
	id = "hot_ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

datum/reagent/hot_ramen/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (10 * TEMPERATURE_DAMAGE_COEFFICIENT))
	..()
	return

datum/reagent/hell_ramen
	name = "Hell Ramen"
	id = "hell_ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

datum/reagent/hell_ramen/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	M.bodytemperature += 10 * TEMPERATURE_DAMAGE_COEFFICIENT
	..()
	return

datum/reagent/flour
	name = "flour"
	id = "flour"
	description = "This is what you rub all over yourself to pretend to be a ghost."
	reagent_state = SOLID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#FFFFFF" // rgb: 0, 0, 0

datum/reagent/flour/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	..()
	return

datum/reagent/flour/reaction_turf(var/turf/T, var/volume)
	src = null
	if(!istype(T, /turf/space))
		new /obj/effect/decal/cleanable/flour(T)

datum/reagent/cherryjelly
	name = "Cherry Jelly"
	id = "cherryjelly"
	description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
	reagent_state = LIQUID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#801E28" // rgb: 128, 30, 40

datum/reagent/cherryjelly/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	..()
	return

/////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////// DRINKS BELOW, Beer is up there though, along with cola. Cap'n Pete's Cuban Spiced Rum////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////

datum/reagent/orangejuice
	name = "Orange juice"
	id = "orangejuice"
	description = "Both delicious AND rich in Vitamin C, what more do you need?"
	reagent_state = LIQUID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#E78108" // rgb: 231, 129, 8

datum/reagent/orangejuice/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	if(!M) M = holder.my_atom
	if(M.getOxyLoss() && prob(30)) M.adjustOxyLoss(-1)
	M.nutrition++
	..()
	return

datum/reagent/tomatojuice
	name = "Tomato Juice"
	id = "tomatojuice"
	description = "Tomatoes made into juice. What a waste of big, juicy tomatoes, huh?"
	reagent_state = LIQUID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#731008" // rgb: 115, 16, 8

datum/reagent/tomatojuice/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	if(!M) M = holder.my_atom
	if(M.getFireLoss() && prob(20)) M.heal_organ_damage(0,1)
	M.nutrition++
	..()
	return

datum/reagent/limejuice
	name = "Lime Juice"
	id = "limejuice"
	description = "The sweet-sour juice of limes."
	reagent_state = LIQUID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#365E30" // rgb: 54, 94, 48

datum/reagent/limejuice/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	if(!M) M = holder.my_atom
	if(M.getToxLoss() && prob(20)) M.adjustToxLoss(-1*REM)
	M.nutrition++
	..()
	return

datum/reagent/carrotjuice
	name = "Carrot juice"
	id = "carrotjuice"
	description = "It is just like a carrot but without crunching."
	reagent_state = LIQUID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#973800" // rgb: 151, 56, 0

datum/reagent/carrotjuice/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.nutrition += nutriment_factor
	M.eye_blurry = max(M.eye_blurry-1 , 0)
	M.eye_blind = max(M.eye_blind-1 , 0)
	if(!data) data = 1
	switch(data)
		if(1 to 20)
			//nothing
		if(21 to INFINITY)
			if (prob(data-10))
				M.disabilities &= ~NEARSIGHTED
	data++
	..()
	return

datum/reagent/berryjuice
	name = "Berry Juice"
	id = "berryjuice"
	description = "A delicious blend of several different kinds of berries."
	reagent_state = LIQUID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#863333" // rgb: 134, 51, 51

datum/reagent/berryjuice/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.nutrition += nutriment_factor
	..()
	return

datum/reagent/poisonberryjuice
	name = "Poison Berry Juice"
	id = "poisonberryjuice"
	description = "A tasty juice blended from various kinds of very deadly and toxic berries."
	reagent_state = LIQUID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#863353" // rgb: 134, 51, 83

datum/reagent/poisonberryjuice/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.nutrition += nutriment_factor
	M.adjustToxLoss(1)
	..()
	return

datum/reagent/watermelonjuice
	name = "Watermelon Juice"
	id = "watermelonjuice"
	description = "Delicious juice made from watermelon."
	reagent_state = LIQUID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#863333" // rgb: 134, 51, 51

datum/reagent/watermelonjuice/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.nutrition += nutriment_factor
	..()
	return

datum/reagent/lemonjuice
	name = "Lemon Juice"
	id = "lemonjuice"
	description = "This juice is VERY sour."
	reagent_state = LIQUID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#863333" // rgb: 175, 175, 0

datum/reagent/lemonjuice/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.nutrition += nutriment_factor
	..()
	return

datum/reagent/banana
	name = "Banana Juice"
	id = "banana"
	description = "The raw essence of a banana. HONK"
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#863333" // rgb: 175, 175, 0

datum/reagent/banana/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	if(istype(M, /mob/living/carbon/human) && M.job in list("Clown"))
		if(!M) M = holder.my_atom
		M.heal_organ_damage(1,1)
		..()
		return
	if(istype(M, /mob/living/carbon/monkey))
		if(!M) M = holder.my_atom
		M.heal_organ_damage(1,1)
		..()
		return
	..()

datum/reagent/nothing
	name = "Nothing"
	id = "nothing"
	description = "Absolutely nothing."
	nutriment_factor = 1 * REAGENTS_METABOLISM

datum/reagent/nothing/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	if(istype(M, /mob/living/carbon/human) && M.job in list("Mime"))
		if(!M) M = holder.my_atom
		M.heal_organ_damage(1,1)
		..()
		return
	..()

datum/reagent/potato_juice
	name = "Potato Juice"
	id = "potato"
	description = "Juice of the potato. Bleh."
	reagent_state = LIQUID
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0

datum/reagent/potato_juice/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	..()
	return

datum/reagent/milk
	name = "Milk"
	id = "milk"
	description = "An opaque white liquid produced by the mammary glands of mammals."
	reagent_state = LIQUID
	color = "#DFDFDF" // rgb: 223, 223, 223

datum/reagent/milk/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
	if(holder.has_reagent("capsaicin"))
		holder.remove_reagent("capsaicin", 2)
	M.nutrition++
	..()
	return

datum/reagent/soymilk
	name = "Soy Milk"
	id = "soymilk"
	description = "An opaque white liquid made from soybeans."
	reagent_state = LIQUID
	color = "#DFDFC7" // rgb: 223, 223, 199

datum/reagent/soymilk/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
	M.nutrition++
	..()
	return

datum/reagent/cream
	name = "Cream"
	id = "cream"
	description = "The fatty, still liquid part of milk. Why don't you mix this with sum scotch, eh?"
	reagent_state = LIQUID
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#DFD7AF" // rgb: 223, 215, 175

datum/reagent/cream/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
	..()
	return

datum/reagent/coffee
	name = "Coffee"
	id = "coffee"
	description = "Coffee is a brewed drink prepared from roasted seeds, commonly called coffee beans, of the coffee plant."
	reagent_state = LIQUID
	color = "#482000" // rgb: 72, 32, 0

datum/reagent/coffee/on_mob_life(var/mob/living/M as mob)
	..()
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.sleeping = max(0,M.sleeping - 2)
	if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (25 * TEMPERATURE_DAMAGE_COEFFICIENT))
	M.Jitter(5)
	if(holder.has_reagent("frostoil"))
		holder.remove_reagent("frostoil", 5)
	..()
	return

datum/reagent/tea
	name = "Tea"
	id = "tea"
	description = "Tasty black tea, it has antioxidants, it's good for you!"
	reagent_state = LIQUID
	color = "#101000" // rgb: 16, 16, 0

datum/reagent/tea/on_mob_life(var/mob/living/M as mob)
	..()
	M.dizziness = max(0,M.dizziness-2)
	M.drowsyness = max(0,M.drowsyness-1)
	M.jitteriness = max(0,M.jitteriness-3)
	M.sleeping = max(0,M.sleeping-1)
	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1)
	if (M.bodytemperature < 310)  //310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (20 * TEMPERATURE_DAMAGE_COEFFICIENT))
	..()
	return

datum/reagent/icecoffee
	name = "Iced Coffee"
	id = "icecoffee"
	description = "Coffee and ice, refreshing and cool."
	reagent_state = LIQUID
	color = "#102838" // rgb: 16, 40, 56

datum/reagent/icecoffee/on_mob_life(var/mob/living/M as mob)
	..()
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.sleeping = max(0,M.sleeping-2)
	if (M.bodytemperature > 310)//310 is the normal bodytemp. 310.055
		M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	M.Jitter(5)
	..()
	return

datum/reagent/icetea
	name = "Iced Tea"
	id = "icetea"
	description = "No relation to a certain rap artist/ actor."
	reagent_state = LIQUID
	color = "#104038" // rgb: 16, 64, 56

datum/reagent/icetea/on_mob_life(var/mob/living/M as mob)
	..()
	M.dizziness = max(0,M.dizziness-2)
	M.drowsyness = max(0,M.drowsyness-1)
	M.sleeping = max(0,M.sleeping-2)
	if(M.getToxLoss() && prob(20))
		M.adjustToxLoss(-1)
	if (M.bodytemperature > 310)//310 is the normal bodytemp. 310.055
		M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	return

datum/reagent/space_cola
	name = "Cola"
	id = "cola"
	description = "A refreshing beverage."
	reagent_state = LIQUID
	color = "#100800" // rgb: 16, 8, 0

datum/reagent/space_cola/on_mob_life(var/mob/living/M as mob)
	M.drowsyness = max(0,M.drowsyness-5)
	if (M.bodytemperature > 310)//310 is the normal bodytemp. 310.055
		M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	M.nutrition += 1
	..()
	return

datum/reagent/nuka_cola
	name = "Nuka Cola"
	id = "nuka_cola"
	description = "Cola, cola never changes."
	reagent_state = LIQUID
	color = "#100800" // rgb: 16, 8, 0

datum/reagent/nuka_cola/on_mob_life(var/mob/living/M as mob)
	M.Jitter(20)
	M.druggy = max(M.druggy, 30)
	M.dizziness +=5
	M.drowsyness = 0
	M.sleeping = max(0,M.sleeping-2)
	M.status_flags |= GOTTAGOFAST
	if (M.bodytemperature > 310)//310 is the normal bodytemp. 310.055
		M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	M.nutrition += 1
	..()
	return

datum/reagent/spacemountainwind
	name = "Space Mountain Wind"
	id = "spacemountainwind"
	description = "Blows right through you like a space wind."
	reagent_state = LIQUID
	color = "#102000" // rgb: 16, 32, 0

datum/reagent/spacemountainwind/on_mob_life(var/mob/living/M as mob)
	M.drowsyness = max(0,M.drowsyness-7)
	M.sleeping = max(0,M.sleeping-1)
	if (M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	M.Jitter(5)
	M.nutrition += 1
	..()
	return

datum/reagent/dr_gibb
	name = "Dr. Gibb"
	id = "dr_gibb"
	description = "A delicious blend of 42 different flavours"
	reagent_state = LIQUID
	color = "#102000" // rgb: 16, 32, 0

datum/reagent/dr_gibb/on_mob_life(var/mob/living/M as mob)
	M.drowsyness = max(0,M.drowsyness-6)
	if (M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
	M.nutrition += 1
	..()
	return

datum/reagent/space_up
	name = "Space-Up"
	id = "space_up"
	description = "Tastes like a hull breach in your mouth."
	reagent_state = LIQUID
	color = "#00FF00" // rgb: 0, 255, 0

datum/reagent/space_up/on_mob_life(var/mob/living/M as mob)
	if (M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (8 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
	M.nutrition += 1
	..()
	return

datum/reagent/lemon_lime
	name = "Lemon Lime"
	description = "A tangy substance made of 0.5% natural citrus!"
	id = "lemon_lime"
	reagent_state = LIQUID
	color = "#8CFF00" // rgb: 135, 255, 0

datum/reagent/lemon_lime/on_mob_life(var/mob/living/M as mob)
	if (M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (8 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
	M.nutrition += 1
	..()
	return

datum/reagent/sodawater
	name = "Soda Water"
	id = "sodawater"
	description = "A can of club soda. Why not make a scotch and soda?"
	reagent_state = LIQUID
	color = "#619494" // rgb: 97, 148, 148

datum/reagent/sodawater/on_mob_life(var/mob/living/M as mob)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	if (M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	..()
	return

datum/reagent/tonic
	name = "Tonic Water"
	id = "tonic"
	description = "It tastes strange but at least the quinine keeps the Space Malaria at bay."
	reagent_state = LIQUID
	color = "#0064C8" // rgb: 0, 100, 200

datum/reagent/tonic/on_mob_life(var/mob/living/M as mob)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.sleeping = max(0,M.sleeping-2)
	if (M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	..()
	return

datum/reagent/ice
	name = "Ice"
	id = "ice"
	description = "Frozen water, your dentist wouldn't like you chewing this."
	reagent_state = SOLID
	color = "#619494" // rgb: 97, 148, 148

datum/reagent/ice/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.bodytemperature -= 5 * TEMPERATURE_DAMAGE_COEFFICIENT
	..()
	return

datum/reagent/soy_latte
	name = "Soy Latte"
	id = "soy_latte"
	description = "A nice and tasty beverage while you are reading your hippie books."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

datum/reagent/soy_latte/on_mob_life(var/mob/living/M as mob)
	..()
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.sleeping = 0
	if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	M.Jitter(5)
	if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
	M.nutrition++
	..()
	return

datum/reagent/cafe_latte
	name = "Cafe Latte"
	id = "cafe_latte"
	description = "A nice, strong and tasty beverage while you are reading."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

datum/reagent/cafe_latte/on_mob_life(var/mob/living/M as mob)
	..()
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.sleeping = 0
	if (M.bodytemperature < 310)//310 is the normal bodytemp. 310.055
		M.bodytemperature = min(310, M.bodytemperature + (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	M.Jitter(5)
	if(M.getBruteLoss() && prob(20)) M.heal_organ_damage(1,0)
	M.nutrition++
	..()
	return

datum/reagent/doctor_delight
	name = "The Doctor's Delight"
	id = "doctorsdelight"
	description = "A gulp a day keeps the MediBot away. That's probably for the best."
	reagent_state = LIQUID
	color = "#FF8CFF" // rgb: 255, 140, 255

datum/reagent/doctor_delight/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	if(M.getOxyLoss() && prob(80)) M.adjustOxyLoss(-2)
	if(M.getBruteLoss() && prob(80)) M.heal_organ_damage(2,0)
	if(M.getFireLoss() && prob(80)) M.heal_organ_damage(0,2)
	if(M.getToxLoss() && prob(80)) M.adjustToxLoss(-2)
	if(M.dizziness !=0) M.dizziness = max(0,M.dizziness-15)
	if(M.confused !=0) M.confused = max(0,M.confused - 5)
	..()
	return

//////////////////////////////////Hydroponics stuff///////////////////////////////

datum/reagent/plantnutriment
	name = "Generic nutriment"
	id = "plantnutriment"
	description = "Some kind of nutriment. You can't really tell what it is. You should probably report it, along with how you obtained it."
	reagent_state = LIQUID
	color = "#000000" // RBG: 0, 0, 0
	var/tox_prob = 0

datum/reagent/plantnutriment/on_mob_life(var/mob/living/M as mob)
	if(prob(tox_prob)) M.adjustToxLoss(1*REM)
	..()
	return

datum/reagent/plantnutriment/eznutriment
	name = "E-Z-Nutrient"
	id = "eznutriment"
	description = "Cheap and extremely common type of plant nutriment."
	reagent_state = LIQUID
	color = "#376400" // RBG: 50, 100, 0
	tox_prob = 10

datum/reagent/plantnutriment/left4zednutriment
	name = "Left 4 Zed"
	id = "left4zednutriment"
	description = "Unstable nutriment that makes plants mutate more often than usual."
	reagent_state = LIQUID
	color = "#1A1E4D" // RBG: 26, 30, 77
	tox_prob = 25

datum/reagent/plantnutriment/robustharvestnutriment
	name = "Robust Harvest"
	id = "robustharvestnutriment"
	description = "Very potent nutriment that prevents plants from mutating."
	reagent_state = LIQUID
	color = "#9D9D00" // RBG: 157, 157, 0
	tox_prob = 15

//////////////////////////////////////////////The ten friggen million reagents that get you drunk//////////////////////////////////////////////

datum/reagent/atomicbomb
	name = "Atomic Bomb"
	id = "atomicbomb"
	description = "Nuclear proliferation never tasted so good."
	reagent_state = LIQUID
	color = "#666300" // rgb: 102, 99, 0

datum/reagent/atomicbomb/on_mob_life(var/mob/living/M as mob)
	M.druggy = max(M.druggy, 50)
	M.confused = max(M.confused+2,0)
	M.Dizzy(10)
	if (!M.stuttering) M.stuttering = 1
	M.stuttering += 3
	if(!data) data = 1
	data++
	switch(data)
		if(51 to 200)
			M.sleeping += 1
		if(201 to INFINITY)
			M.sleeping += 1
			M.adjustToxLoss(2)
	..()
	return

datum/reagent/gargle_blaster
	name = "Pan-Galactic Gargle Blaster"
	id = "gargleblaster"
	description = "Whoah, this stuff looks volatile!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

datum/reagent/gargle_blaster/on_mob_life(var/mob/living/M as mob)
	if(!data) data = 1
	data++
	M.dizziness +=6
	if(data >= 15 && data <45)
		if (!M.stuttering) M.stuttering = 1
		M.stuttering += 3
	else if(data >= 45 && prob(50) && data <55)
		M.confused = max(M.confused+3,0)
	else if(data >=55)
		M.druggy = max(M.druggy, 55)
	else if(data >=200)
		M.adjustToxLoss(2)
	..()
	return

datum/reagent/neurotoxin
	name = "Neurotoxin"
	id = "neurotoxin"
	description = "A strong neurotoxin that puts the subject into a death-like state."
	reagent_state = LIQUID
	color = "#2E2E61" // rgb: 46, 46, 97

datum/reagent/neurotoxin/on_mob_life(var/mob/living/carbon/M as mob)
	if(!M) M = holder.my_atom
	M.weakened = max(M.weakened, 3)
	if(!data) data = 1
	data++
	M.dizziness +=6
	if(data >= 15 && data <45)
		if (!M.stuttering) M.stuttering = 1
		M.stuttering += 3
	else if(data >= 45 && prob(50) && data <55)
		M.confused = max(M.confused+3,0)
	else if(data >=55)
		M.druggy = max(M.druggy, 55)
	else if(data >=200)
		M.adjustToxLoss(2)
	..()
	return

datum/reagent/hippies_delight
	name = "Hippie's Delight"
	id = "hippiesdelight"
	description = "You just don't get it maaaan."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0

datum/reagent/hippies_delight/on_mob_life(var/mob/living/M as mob)
	if(!M) M = holder.my_atom
	M.druggy = max(M.druggy, 50)
	if(!data) data = 1
	data++
	switch(data)
		if(1 to 5)
			if (!M.stuttering) M.stuttering = 1
			M.Dizzy(10)
			if(prob(10)) M.emote(pick("twitch","giggle"))
		if(5 to 10)
			if (!M.stuttering) M.stuttering = 1
			M.Jitter(20)
			M.Dizzy(20)
			M.druggy = max(M.druggy, 45)
			if(prob(20)) M.emote(pick("twitch","giggle"))
		if (10 to 200)
			if (!M.stuttering) M.stuttering = 1
			M.Jitter(40)
			M.Dizzy(40)
			M.druggy = max(M.druggy, 60)
			if(prob(30)) M.emote(pick("twitch","giggle"))
		if(200 to INFINITY)
			if (!M.stuttering) M.stuttering = 1
			M.Jitter(60)
			M.Dizzy(60)
			M.druggy = max(M.druggy, 75)
			if(prob(40)) M.emote(pick("twitch","giggle"))
			if(prob(30)) M.adjustToxLoss(2)
	holder.remove_reagent(src.id, 0.2)
	..()
	return

/*boozepwr chart
55 = non-toxic alchohol
45 = medium-toxic
35 = the hard stuff
25 = potent mixes
<15 = deadly toxic
*/

datum/reagent/ethanol
	name = "Ethanol"
	id = "ethanol"
	description = "A well-known alcohol with a variety of applications."
	reagent_state = LIQUID
	color = "#404030" // rgb: 64, 64, 48
	var/boozepwr = 10 //lower numbers mean the booze will have an effect faster.

datum/reagent/ethanol/on_mob_life(var/mob/living/M as mob)
	if(!data) data = 1
	data++
	M.jitteriness = max(M.jitteriness-5,0)
	if(data >= boozepwr)
		if (!M.stuttering) M.stuttering = 1
		M.stuttering += 4
		M.Dizzy(5)
	if(data >= boozepwr*2.5 && prob(33))
		if (!M.confused) M.confused = 1
		M.confused += 3
	if(data >= boozepwr*10 && prob(33))
		M.adjustToxLoss(2)
	..()
	return
datum/reagent/ethanol/reaction_obj(var/obj/O, var/volume)
	if(istype(O,/obj/item/weapon/paper))
		var/obj/item/weapon/paper/paperaffected = O
		paperaffected.clearpaper()
		usr << "The solution melts away the ink on the paper."
	if(istype(O,/obj/item/weapon/book))
		if(volume >= 5)
			var/obj/item/weapon/book/affectedbook = O
			affectedbook.dat = null
			usr << "The solution melts away the ink on the book."
		else
			usr << "It wasn't enough..."
	return

datum/reagent/ethanol/reaction_mob(var/mob/living/M, var/method=TOUCH, var/volume)//Splashing people with ethanol isn't quite as good as fuel.
	if(!istype(M, /mob/living))
		return
	if(method == TOUCH)
		M.adjust_fire_stacks(volume / 15)
		return

datum/reagent/ethanol/beer
	name = "Beer"
	id = "beer"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 55

datum/reagent/ethanol/beer/on_mob_life(var/mob/living/M as mob)
	M.nutrition += 1
	..()
	return

datum/reagent/ethanol/beer/greenbeer
	name = "Green Beer"
	id = "greenbeer"
	description = "An alcoholic beverage made from malted grains, hops, yeast, and water. Dyed a festive green."
	color = "#A8E61D"

datum/reagent/ethanol/kahlua
	name = "Kahlua"
	id = "kahlua"
	description = "A widely known, Mexican coffee-flavoured liqueur. In production since 1936!"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 45

datum/reagent/ethanol/kahlua/on_mob_life(var/mob/living/M as mob)
	M.dizziness = max(0,M.dizziness-5)
	M.drowsyness = max(0,M.drowsyness-3)
	M.sleeping = max(0,M.sleeping-2)
	M.Jitter(5)
	..()
	return

datum/reagent/ethanol/whiskey
	name = "Whiskey"
	id = "whiskey"
	description = "A superb and well-aged single-malt whiskey. Damn."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 35

datum/reagent/ethanol/thirteenloko
	name = "Thirteen Loko"
	id = "thirteenloko"
	description = "A potent mixture of caffeine and alcohol."
	color = "#102000" // rgb: 16, 32, 0
	boozepwr = 35

datum/reagent/ethanol/thirteenloko/on_mob_life(var/mob/living/M as mob)
	M.drowsyness = max(0,M.drowsyness-7)
	M.sleeping = max(0,M.sleeping-2)
	if (M.bodytemperature > 310)
		M.bodytemperature = max(310, M.bodytemperature - (5 * TEMPERATURE_DAMAGE_COEFFICIENT))
	M.Jitter(5)
	M.nutrition += 1
	..()
	return

datum/reagent/ethanol/vodka
	name = "Vodka"
	id = "vodka"
	description = "Number one drink AND fueling choice for Russians worldwide."
	color = "#0064C8" // rgb: 0, 100, 200
	boozepwr = 35

datum/reagent/ethanol/vodka/on_mob_life(var/mob/living/M as mob)
	M.radiation = max(M.radiation-2,0)
	..()
	return

datum/reagent/ethanol/bilk
	name = "Bilk"
	id = "bilk"
	description = "This appears to be beer mixed with milk. Disgusting."
	color = "#895C4C" // rgb: 137, 92, 76
	boozepwr = 55

datum/reagent/ethanol/bilk/on_mob_life(var/mob/living/M as mob)
	if(M.getBruteLoss() && prob(10)) M.heal_organ_damage(1,0)
	M.nutrition += 2
	..()
	return

datum/reagent/ethanol/threemileisland
	name = "Three Mile Island Iced Tea"
	id = "threemileisland"
	description = "Made for a woman, strong enough for a man."
	color = "#666340" // rgb: 102, 99, 64
	boozepwr = 15

datum/reagent/ethanol/threemileisland/on_mob_life(var/mob/living/M as mob)
	M.druggy = max(M.druggy, 50)
	..()
	return

datum/reagent/ethanol/gin
	name = "Gin"
	id = "gin"
	description = "It's gin. In space. I say, good sir."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 55

datum/reagent/ethanol/rum
	name = "Rum"
	id = "rum"
	description = "Yohoho and all that."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 45

datum/reagent/ethanol/tequilla
	name = "Tequila"
	id = "tequilla"
	description = "A strong and mildly flavoured, mexican produced spirit. Feeling thirsty hombre?"
	color = "#FFFF91" // rgb: 255, 255, 145
	boozepwr = 35

datum/reagent/ethanol/vermouth
	name = "Vermouth"
	id = "vermouth"
	description = "You suddenly feel a craving for a martini..."
	color = "#91FF91" // rgb: 145, 255, 145
	boozepwr = 45

datum/reagent/ethanol/wine
	name = "Wine"
	id = "wine"
	description = "An premium alchoholic beverage made from distilled grape juice."
	color = "#7E4043" // rgb: 126, 64, 67
	boozepwr = 45

datum/reagent/ethanol/cognac
	name = "Cognac"
	id = "cognac"
	description = "A sweet and strongly alchoholic drink, made after numerous distillations and years of maturing. Classy as fornication."
	color = "#AB3C05" // rgb: 171, 60, 5
	boozepwr = 45

datum/reagent/ethanol/hooch
	name = "Hooch"
	id = "hooch"
	description = "Either someone's failure at cocktail making or attempt in alchohol production. In any case, do you really want to drink that?"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 35

datum/reagent/ethanol/ale
	name = "Ale"
	id = "ale"
	description = "A dark alchoholic beverage made by malted barley and yeast."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 55

datum/reagent/ethanol/goldschlager
	name = "Goldschlager"
	id = "goldschlager"
	description = "100 proof cinnamon schnapps, made for alcoholic teen girls on spring break."
	color = "#FFFF91" // rgb: 255, 255, 145
	boozepwr = 25

datum/reagent/ethanol/patron
	name = "Patron"
	id = "patron"
	description = "Tequila with silver in it, a favorite of alcoholic women in the club scene."
	color = "#585840" // rgb: 88, 88, 64
	boozepwr = 45

datum/reagent/ethanol/gintonic
	name = "Gin and Tonic"
	id = "gintonic"
	description = "An all time classic, mild cocktail."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 55

datum/reagent/ethanol/cuba_libre
	name = "Cuba Libre"
	id = "cubalibre"
	description = "Rum, mixed with cola. Viva la revolution."
	color = "#3E1B00" // rgb: 62, 27, 0
	boozepwr = 45

datum/reagent/ethanol/whiskey_cola
	name = "Whiskey Cola"
	id = "whiskeycola"
	description = "Whiskey, mixed with cola. Surprisingly refreshing."
	color = "#3E1B00" // rgb: 62, 27, 0
	boozepwr = 35

datum/reagent/ethanol/martini
	name = "Classic Martini"
	id = "martini"
	description = "Vermouth with Gin. Not quite how 007 enjoyed it, but still delicious."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 35

datum/reagent/ethanol/vodkamartini
	name = "Vodka Martini"
	id = "vodkamartini"
	description = "Vodka with Gin. Not quite how 007 enjoyed it, but still delicious."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 25

datum/reagent/ethanol/white_russian
	name = "White Russian"
	id = "whiterussian"
	description = "That's just, like, your opinion, man..."
	color = "#A68340" // rgb: 166, 131, 64
	boozepwr = 35

datum/reagent/ethanol/screwdrivercocktail
	name = "Screwdriver"
	id = "screwdrivercocktail"
	description = "Vodka, mixed with plain ol' orange juice. The result is surprisingly delicious."
	color = "#A68310" // rgb: 166, 131, 16
	boozepwr = 35

datum/reagent/ethanol/booger
	name = "Booger"
	id = "booger"
	description = "Ewww..."
	color = "#8CFF8C" // rgb: 140, 255, 140
	boozepwr = 45

datum/reagent/ethanol/bloody_mary
	name = "Bloody Mary"
	id = "bloodymary"
	description = "A strange yet pleasurable mixture made of vodka, tomato and lime juice. Or at least you THINK the red stuff is tomato juice."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 35

datum/reagent/ethanol/brave_bull
	name = "Brave Bull"
	id = "bravebull"
	description = "It's just as effective as Dutch-Courage!."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 35

datum/reagent/ethanol/tequilla_sunrise
	name = "Tequila Sunrise"
	id = "tequillasunrise"
	description = "Tequila and orange juice. Much like a Screwdriver, only Mexican~"
	color = "#FFE48C" // rgb: 255, 228, 140
	boozepwr = 35

datum/reagent/ethanol/toxins_special
	name = "Toxins Special"
	id = "toxinsspecial"
	description = "This thing is ON FIRE! CALL THE DAMN SHUTTLE!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 15

datum/reagent/ethanol/toxins_special/on_mob_life(var/mob/living/M as mob)
	if (M.bodytemperature < 330)
		M.bodytemperature = min(330, M.bodytemperature + (15 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
	..()
	return

datum/reagent/ethanol/beepsky_smash
	name = "Beepsky Smash"
	id = "beepskysmash"
	description = "Deny drinking this and prepare for THE LAW."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 25

datum/reagent/ethanol/beepsky_smash/on_mob_life(var/mob/living/M as mob)
	M.Stun(2)
	..()
	return

datum/reagent/ethanol/irish_cream
	name = "Irish Cream"
	id = "irishcream"
	description = "Whiskey-imbued cream, what else would you expect from the Irish."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 35

datum/reagent/ethanol/manly_dorf
	name = "The Manly Dorf"
	id = "manlydorf"
	description = "Beer and Ale, brought together in a delicious mix. Intended for true men only."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 45 //was 10, but really its only beer and ale, both weak alchoholic beverages

datum/reagent/ethanol/longislandicedtea
	name = "Long Island Iced Tea"
	id = "longislandicedtea"
	description = "The liquor cabinet, brought together in a delicious mix. Intended for middle-aged alcoholic women only."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 25

datum/reagent/ethanol/moonshine
	name = "Moonshine"
	id = "moonshine"
	description = "You've really hit rock bottom now... your liver packed its bags and left last night."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 25

datum/reagent/ethanol/b52
	name = "B-52"
	id = "b52"
	description = "Coffee, Irish Cream, and cognac. You will get bombed."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 25

datum/reagent/ethanol/irishcoffee
	name = "Irish Coffee"
	id = "irishcoffee"
	description = "Coffee, and alcohol. More fun than a Mimosa to drink in the morning."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 35

datum/reagent/ethanol/margarita
	name = "Margarita"
	id = "margarita"
	description = "On the rocks with salt on the rim. Arriba~!"
	color = "#8CFF8C" // rgb: 140, 255, 140
	boozepwr = 35

datum/reagent/ethanol/black_russian
	name = "Black Russian"
	id = "blackrussian"
	description = "For the lactose-intolerant. Still as classy as a White Russian."
	color = "#360000" // rgb: 54, 0, 0
	boozepwr = 35

datum/reagent/ethanol/manhattan
	name = "Manhattan"
	id = "manhattan"
	description = "The Detective's undercover drink of choice. He never could stomach gin..."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 45

datum/reagent/ethanol/manhattan_proj
	name = "Manhattan Project"
	id = "manhattan_proj"
	description = "A scientist's drink of choice, for pondering ways to blow up the station."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 15

datum/reagent/ethanol/manhattan_proj/on_mob_life(var/mob/living/M as mob)
	M.druggy = max(M.druggy, 30)
	..()
	return

datum/reagent/ethanol/whiskeysoda
	name = "Whiskey Soda"
	id = "whiskeysoda"
	description = "For the more refined griffon."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 35

datum/reagent/ethanol/antifreeze
	name = "Anti-freeze"
	id = "antifreeze"
	description = "Ultimate refreshment."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 25

datum/reagent/ethanol/antifreeze/on_mob_life(var/mob/living/M as mob)
	if (M.bodytemperature < 330)
		M.bodytemperature = min(330, M.bodytemperature + (20 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
	..()
	return

datum/reagent/ethanol/barefoot
	name = "Barefoot"
	id = "barefoot"
	description = "Barefoot and pregnant"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 45

datum/reagent/ethanol/snowwhite
	name = "Snow White"
	id = "snowwhite"
	description = "A cold refreshment"
	color = "#FFFFFF" // rgb: 255, 255, 255
	boozepwr = 45

datum/reagent/ethanol/demonsblood
	name = "Demons Blood"
	id = "demonsblood"
	description = "AHHHH!!!!"
	color = "#820000" // rgb: 130, 0, 0
	boozepwr = 35

datum/reagent/ethanol/vodkatonic
	name = "Vodka and Tonic"
	id = "vodkatonic"
	description = "For when a gin and tonic isn't russian enough."
	color = "#0064C8" // rgb: 0, 100, 200
	boozepwr = 35

datum/reagent/ethanol/ginfizz
	name = "Gin Fizz"
	id = "ginfizz"
	description = "Refreshingly lemony, deliciously dry."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 45

datum/reagent/ethanol/bahama_mama
	name = "Bahama mama"
	id = "bahama_mama"
	description = "Tropical cocktail."
	color = "#FF7F3B" // rgb: 255, 127, 59
	boozepwr = 35

datum/reagent/ethanol/singulo
	name = "Singulo"
	id = "singulo"
	description = "A blue-space beverage!"
	color = "#2E6671" // rgb: 46, 102, 113
	boozepwr = 15

datum/reagent/ethanol/sbiten
	name = "Sbiten"
	id = "sbiten"
	description = "A spicy Vodka! Might be a little hot for the little guys!"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 35

datum/reagent/ethanol/sbiten/on_mob_life(var/mob/living/M as mob)
	if (M.bodytemperature < 360)
		M.bodytemperature = min(360, M.bodytemperature + (50 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
	..()
	return

datum/reagent/ethanol/devilskiss
	name = "Devils Kiss"
	id = "devilskiss"
	description = "Creepy time!"
	color = "#A68310" // rgb: 166, 131, 16
	boozepwr = 35

datum/reagent/ethanol/red_mead
	name = "Red Mead"
	id = "red_mead"
	description = "The true Viking drink! Even though it has a strange red color."
	color = "#C73C00" // rgb: 199, 60, 0
	boozepwr = 45

datum/reagent/ethanol/mead
	name = "Mead"
	id = "mead"
	description = "A Vikings drink, though a cheap one."
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 45

datum/reagent/ethanol/mead/on_mob_life(var/mob/living/M as mob)
				M.nutrition += 1
				..()
				return

datum/reagent/ethanol/iced_beer
	name = "Iced Beer"
	id = "iced_beer"
	description = "A beer which is so cold the air around it freezes."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 55

datum/reagent/ethanol/iced_beer/on_mob_life(var/mob/living/M as mob)
	if(M.bodytemperature > 270)
		M.bodytemperature = max(270, M.bodytemperature - (20 * TEMPERATURE_DAMAGE_COEFFICIENT)) //310 is the normal bodytemp. 310.055
	..()
	return

datum/reagent/ethanol/grog
	name = "Grog"
	id = "grog"
	description = "Watered down rum, Nanotrasen approves!"
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 90

datum/reagent/ethanol/aloe
	name = "Aloe"
	id = "aloe"
	description = "So very, very, very good."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 35

datum/reagent/ethanol/andalusia
	name = "Andalusia"
	id = "andalusia"
	description = "A nice, strange named drink."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 35

datum/reagent/ethanol/alliescocktail
	name = "Allies Cocktail"
	id = "alliescocktail"
	description = "A drink made from your allies, not as sweet as when made from your enemies."
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 35

datum/reagent/ethanol/acid_spit
	name = "Acid Spit"
	id = "acidspit"
	description = "A drink for the daring, can be deadly if incorrectly prepared!"
	reagent_state = LIQUID
	color = "#365000" // rgb: 54, 80, 0
	boozepwr = 45

datum/reagent/ethanol/amasec
	name = "Amasec"
	id = "amasec"
	description = "Official drink of the Nanotrasen Gun-Club!"
	reagent_state = LIQUID
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 35

datum/reagent/ethanol/changelingsting
	name = "Changeling Sting"
	id = "changelingsting"
	description = "You take a tiny sip and feel a burning sensation..."
	color = "#2E6671" // rgb: 46, 102, 113
	boozepwr = 15

datum/reagent/ethanol/irishcarbomb
	name = "Irish Car Bomb"
	id = "irishcarbomb"
	description = "Mmm, tastes like chocolate cake..."
	color = "#2E6671" // rgb: 46, 102, 113
	boozepwr = 25

datum/reagent/ethanol/syndicatebomb
	name = "Syndicate Bomb"
	id = "syndicatebomb"
	description = "Tastes like terrorism!"
	color = "#2E6671" // rgb: 46, 102, 113
	boozepwr = 15

datum/reagent/ethanol/erikasurprise
	name = "Erika Surprise"
	id = "erikasurprise"
	description = "The surprise is, it's green!"
	color = "#2E6671" // rgb: 46, 102, 113
	boozepwr = 35

datum/reagent/ethanol/driestmartini
	name = "Driest Martini"
	id = "driestmartini"
	description = "Only for the experienced. You think you see sand floating in the glass."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#2E6671" // rgb: 46, 102, 113
	boozepwr = 25

datum/reagent/ethanol/bananahonk
	name = "Banana Mama"
	id = "bananahonk"
	description = "A drink from Clown Heaven."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#FFFF91" // rgb: 255, 255, 140
	boozepwr = 25

datum/reagent/ethanol/bananahonk/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	if(istype(M, /mob/living/carbon/human) && M.job in list("Clown") || istype(M, /mob/living/carbon/monkey))
		if(!M) M = holder.my_atom
		M.heal_organ_damage(1,1)
		..()
		return

datum/reagent/ethanol/silencer
	name = "Silencer"
	id = "silencer"
	description = "A drink from Mime Heaven."
	nutriment_factor = 1 * REAGENTS_METABOLISM
	color = "#664300" // rgb: 102, 67, 0
	boozepwr = 15

datum/reagent/ethanol/silencer/on_mob_life(var/mob/living/M as mob)
	M.nutrition += nutriment_factor
	if(istype(M, /mob/living/carbon/human) && M.job in list("Mime"))
		if(!M) M = holder.my_atom
		M.heal_organ_damage(1,1)
		..()
		return

// Undefine the alias for REAGENTS_EFFECT_MULTIPLER
#undef REM
