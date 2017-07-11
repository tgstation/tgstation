/datum/reagent/blood
	data = list("donor"=null,"viruses"=null,"blood_DNA"=null,"blood_type"=null,"resistances"=null,"trace_chem"=null,"mind"=null,"ckey"=null,"gender"=null,"real_name"=null,"cloneable"=null,"factions"=null)
	name = "Blood"
	id = "blood"
	color = "#C80000" // rgb: 200, 0, 0
	metabolization_rate = 5 //fast rate so it disappears fast.
	taste_description = "iron"
	taste_mult = 1.3
	glass_icon_state = "glass_red"
	glass_name = "glass of tomato juice"
	glass_desc = "Are you sure this is tomato juice?"
	shot_glass_icon_state = "shotglassred"

/datum/reagent/blood/reaction_mob(mob/M, method=TOUCH, reac_volume)
	if(data && data["viruses"])
		for(var/datum/disease/D in data["viruses"])

			if((D.spread_flags & SPECIAL) || (D.spread_flags & NON_CONTAGIOUS))
				continue

			if(method == TOUCH || method == VAPOR)
				M.ContractDisease(D)
			else //ingest, patch or inject
				M.ForceContractDisease(D)

	if(method == INJECT && iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.get_blood_id() == "blood")
			if(!data || !(data["blood_type"] in get_safe_blood(C.dna.blood_type)))
				C.reagents.add_reagent("toxin", reac_volume * 0.5)
			else
				C.blood_volume = min(C.blood_volume + round(reac_volume, 0.1), BLOOD_VOLUME_MAXIMUM)


/datum/reagent/blood/on_new(list/data)
	if(istype(data))
		SetViruses(src, data)

/datum/reagent/blood/on_merge(list/mix_data)
	if(data && mix_data)
		data["cloneable"] = 0 //On mix, consider the genetic sampling unviable for pod cloning, or else we won't know who's even getting cloned, etc
		if(data["viruses"] || mix_data["viruses"])

			var/list/mix1 = data["viruses"]
			var/list/mix2 = mix_data["viruses"]

			// Stop issues with the list changing during mixing.
			var/list/to_mix = list()

			for(var/datum/disease/advance/AD in mix1)
				to_mix += AD
			for(var/datum/disease/advance/AD in mix2)
				to_mix += AD

			var/datum/disease/advance/AD = Advance_Mix(to_mix)
			if(AD)
				var/list/preserve = list(AD)
				for(var/D in data["viruses"])
					if(!istype(D, /datum/disease/advance))
						preserve += D
				data["viruses"] = preserve
	return 1

/datum/reagent/blood/reaction_turf(turf/T, reac_volume)//splash the blood all over the place
	if(!istype(T))
		return
	if(reac_volume < 3)
		return

	var/obj/effect/decal/cleanable/blood/B = locate() in T //find some blood here
	if(!B)
		B = new(T)
	if(data["blood_DNA"])
		B.blood_DNA[data["blood_DNA"]] = data["blood_type"]

	for(var/datum/disease/D in data["viruses"])
		var/datum/disease/newVirus = D.Copy(1)
		B.viruses += newVirus
		newVirus.holder = B


/datum/reagent/liquidgibs
	name = "Liquid gibs"
	id = "liquidgibs"
	color = "#FF9966"
	description = "You don't even want to think about what's in here."
	taste_description = "gross iron"
	shot_glass_icon_state = "shotglassred"

/datum/reagent/vaccine
	//data must contain virus type
	name = "Vaccine"
	id = "vaccine"
	color = "#C81040" // rgb: 200, 16, 64
	taste_description = "slime"

/datum/reagent/vaccine/reaction_mob(mob/M, method=TOUCH, reac_volume)
	if(islist(data) && (method == INGEST || method == INJECT))
		for(var/datum/disease/D in M.viruses)
			if(D.GetDiseaseID() in data)
				D.cure()
		M.resistances |= data

/datum/reagent/vaccine/on_merge(list/data)
	if(istype(data))
		src.data |= data.Copy()

/datum/reagent/water
	name = "Water"
	id = "water"
	description = "A ubiquitous chemical substance that is composed of hydrogen and oxygen."
	color = "#AAAAAA77" // rgb: 170, 170, 170, 77 (alpha)
	taste_description = "water"
	var/cooling_temperature = 2
	glass_icon_state = "glass_clear"
	glass_name = "glass of Water"
	glass_desc = "The father of all refreshments."
	shot_glass_icon_state = "shotglassclear"

/*
 *	Water reaction to turf
 */

/datum/reagent/water/reaction_turf(turf/open/T, reac_volume)
	if (!istype(T))
		return
	var/CT = cooling_temperature

	if(reac_volume >= 5)
		T.MakeSlippery(min_wet_time = 10, wet_time_to_add = min(reac_volume*1.5, 60))

	for(var/mob/living/simple_animal/slime/M in T)
		M.apply_water()

	var/obj/effect/hotspot/hotspot = (locate(/obj/effect/hotspot) in T)
	if(hotspot && !isspaceturf(T))
		if(T.air)
			var/datum/gas_mixture/G = T.air
			G.temperature = max(min(G.temperature-(CT*1000),G.temperature/CT),0)
			G.react()
			qdel(hotspot)
	var/obj/effect/acid/A = (locate(/obj/effect/acid) in T)
	if(A)
		A.acid_level = max(A.acid_level - reac_volume*50, 0)

/*
 *	Water reaction to an object
 */

/datum/reagent/water/reaction_obj(obj/O, reac_volume)
	O.extinguish()
	O.acid_level = 0
	// Monkey cube
	if(istype(O,/obj/item/weapon/reagent_containers/food/snacks/monkeycube))
		var/obj/item/weapon/reagent_containers/food/snacks/monkeycube/cube = O
		cube.Expand()

	// Dehydrated carp
	else if(istype(O,/obj/item/toy/carpplushie/dehy_carp))
		var/obj/item/toy/carpplushie/dehy_carp/dehy = O
		dehy.Swell() // Makes a carp

	else if(istype(O, /obj/item/stack/sheet/hairlesshide))
		var/obj/item/stack/sheet/hairlesshide/HH = O
		var/obj/item/stack/sheet/wetleather/WL = new(get_turf(HH))
		WL.amount = HH.amount
		qdel(HH)

/*
 *	Water reaction to a mob
 */

/datum/reagent/water/reaction_mob(mob/living/M, method=TOUCH, reac_volume)//Splashing people with water can help put them out!
	if(!istype(M))
		return
	if(method == TOUCH)
		M.adjust_fire_stacks(-(reac_volume / 10))
		M.ExtinguishMob()
	..()

/datum/reagent/water/holywater
	name = "Holy Water"
	id = "holywater"
	description = "Water blessed by some deity."
	color = "#E0E8EF" // rgb: 224, 232, 239
	glass_icon_state  = "glass_clear"
	glass_name = "glass of Holy Water"
	glass_desc = "A glass of holy water."

/datum/reagent/water/holywater/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(is_servant_of_ratvar(M))
		to_chat(M, "<span class='userdanger'>A darkness begins to spread its unholy tendrils through your mind, purging the Justiciar's influence!</span>")
	..()

/datum/reagent/water/holywater/on_mob_life(mob/living/M)
	if(!data) data = 1
	data++
	M.jitteriness = min(M.jitteriness+4,10)
	if(data >= 30)		// 12 units, 54 seconds @ metabolism 0.4 units & tick rate 1.8 sec
		if(!M.stuttering)
			M.stuttering = 1
		M.stuttering = min(M.stuttering+4, 10)
		M.Dizzy(5)
		if(iscultist(M) && prob(5))
			M.say(pick("Av'te Nar'sie","Pa'lid Mors","INO INO ORA ANA","SAT ANA!","Daim'niodeis Arc'iai Le'eones","R'ge Na'sie","Diabo us Vo'iscum","Eld' Mon Nobis"))
		else if(is_servant_of_ratvar(M) && prob(8))
			switch(pick("speech", "message", "emote"))
				if("speech")
					clockwork_say(M, "...[text2ratvar(pick("Engine... your light grows dark...", "Where are you, master?", "He lies rusting in Error...", "Purge all untruths and... and... something..."))]")
				if("message")
					to_chat(M, "<span class='boldwarning'>[pick("Ratvar's illumination of your mind has begun to flicker", "He lies rusting in Reebe, derelict and forgotten. And there he shall stay", \
					"You can't save him. Nothing can save him now", "It seems that Nar-Sie will triumph after all")].</span>")
				if("emote")
					M.visible_message("<span class='warning'>[M] [pick("whimpers quietly", "shivers as though cold", "glances around in paranoia")].</span>")
	if(data >= 75)	// 30 units, 135 seconds
		if(iscultist(M) || is_servant_of_ratvar(M))
			if(iscultist(M))
				SSticker.mode.remove_cultist(M.mind, 1, 1)
			else if(is_servant_of_ratvar(M))
				remove_servant_of_ratvar(M)
			M.jitteriness = 0
			M.stuttering = 0
			holder.remove_reagent(id, volume)	// maybe this is a little too perfect and a max() cap on the statuses would be better??
			return
	holder.remove_reagent(id, 0.4)	//fixed consumption to prevent balancing going out of whack

/datum/reagent/water/holywater/reaction_turf(turf/T, reac_volume)
	..()
	if(!istype(T)) return
	if(reac_volume>=10)
		for(var/obj/effect/rune/R in T)
			qdel(R)
	T.Bless()

/datum/reagent/fuel/unholywater		//if you somehow managed to extract this from someone, dont splash it on yourself and have a smoke
	name = "Unholy Water"
	id = "unholywater"
	description = "Something that shouldn't exist on this plane of existence."
	taste_description = "suffering"

/datum/reagent/fuel/unholywater/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		M.reagents.add_reagent("unholywater", (reac_volume/4))
		return
	return ..()

/datum/reagent/fuel/unholywater/on_mob_life(mob/living/M)
	if(iscultist(M))
		M.drowsyness = max(M.drowsyness-5, 0)
		M.AdjustUnconscious(-20, 0)
		M.AdjustStun(-40, 0)
		M.AdjustKnockdown(-40, 0)
		M.adjustToxLoss(-2, 0)
		M.adjustOxyLoss(-2, 0)
		M.adjustBruteLoss(-2, 0)
		M.adjustFireLoss(-2, 0)
	else
		M.adjustBrainLoss(3)
		M.adjustToxLoss(1, 0)
		M.adjustFireLoss(2, 0)
		M.adjustOxyLoss(2, 0)
		M.adjustBruteLoss(2, 0)
	holder.remove_reagent(src.id, 1)
	. = 1

/datum/reagent/hellwater			//if someone has this in their system they've really pissed off an eldrich god
	name = "Hell Water"
	id = "hell_water"
	description = "YOUR FLESH! IT BURNS!"
	taste_description = "burning"

/datum/reagent/hellwater/on_mob_life(mob/living/M)
	M.fire_stacks = min(5,M.fire_stacks + 3)
	M.IgniteMob()			//Only problem with igniting people is currently the commonly availible fire suits make you immune to being on fire
	M.adjustToxLoss(1, 0)
	M.adjustFireLoss(1, 0)		//Hence the other damages... ain't I a bastard?
	M.adjustBrainLoss(5)
	holder.remove_reagent(src.id, 1)

/datum/reagent/medicine/omnizine/godblood
	name = "Godblood"
	id = "godblood"
	description = "Slowly heals all damage types. Has a rather high overdose threshold. Glows with mysterious power."
	overdose_threshold = 150

/datum/reagent/lube
	name = "Space Lube"
	id = "lube"
	description = "Lubricant is a substance introduced between two moving surfaces to reduce the friction and wear between them. giggity."
	color = "#009CA8" // rgb: 0, 156, 168
	taste_description = "cherry" // by popular demand

/datum/reagent/lube/reaction_turf(turf/open/T, reac_volume)
	if (!istype(T))
		return
	if(reac_volume >= 1)
		T.MakeSlippery(TURF_WET_LUBE, 15, min(reac_volume * 2, 120))

/datum/reagent/spraytan
	name = "Spray Tan"
	id = "spraytan"
	description = "A substance applied to the skin to darken the skin."
	color = "#FFC080" // rgb: 255, 196, 128  Bright orange
	metabolization_rate = 10 * REAGENTS_METABOLISM // very fast, so it can be applied rapidly.  But this changes on an overdose
	overdose_threshold = 11 //Slightly more than one un-nozzled spraybottle.
	taste_description = "sour oranges"

/datum/reagent/spraytan/reaction_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	if(ishuman(M))
		if(method == PATCH || method == VAPOR)
			var/mob/living/carbon/human/N = M
			if(N.dna.species.id == "human")
				switch(N.skin_tone)
					if("african1")
						N.skin_tone = "african2"
					if("indian")
						N.skin_tone = "african1"
					if("arab")
						N.skin_tone = "indian"
					if("asian2")
						N.skin_tone = "arab"
					if("asian1")
						N.skin_tone = "asian2"
					if("mediterranean")
						N.skin_tone = "african1"
					if("latino")
						N.skin_tone = "mediterranean"
					if("caucasian3")
						N.skin_tone = "mediterranean"
					if("caucasian2")
						N.skin_tone = pick("caucasian3", "latino")
					if("caucasian1")
						N.skin_tone = "caucasian2"
					if ("albino")
						N.skin_tone = "caucasian1"

			if(MUTCOLORS in N.dna.species.species_traits) //take current alien color and darken it slightly
				var/newcolor = ""
				var/len = length(N.dna.features["mcolor"])
				for(var/i=1, i<=len, i+=1)
					var/ascii = text2ascii(N.dna.features["mcolor"],i)
					switch(ascii)
						if(48)
							newcolor += "0"
						if(49 to 57)
							newcolor += ascii2text(ascii-1)	//numbers 1 to 9
						if(97)
							newcolor += "9"
						if(98 to 102)
							newcolor += ascii2text(ascii-1)	//letters b to f lowercase
						if(65)
							newcolor +="9"
						if(66 to 70)
							newcolor += ascii2text(ascii+31)	//letters B to F - translates to lowercase
						else
							break
				if(ReadHSV(newcolor)[3] >= ReadHSV("#7F7F7F")[3])
					N.dna.features["mcolor"] = newcolor
			N.regenerate_icons()



		if(method == INGEST)
			if(show_message)
				to_chat(M, "<span class='notice'>That tasted horrible.</span>")
			M.AdjustStun(40)
			M.AdjustKnockdown(40)
	..()


/datum/reagent/spraytan/overdose_process(mob/living/M)
	metabolization_rate = 1 * REAGENTS_METABOLISM

	if(ishuman(M))
		var/mob/living/carbon/human/N = M
		N.hair_style = "Spiky"
		N.facial_hair_style = "Shaved"
		N.facial_hair_color = "000"
		N.hair_color = "000"
		if(!(HAIR in N.dna.species.species_traits)) //No hair? No problem!
			N.dna.species.species_traits += HAIR
		if(N.dna.species.use_skintones)
			N.skin_tone = "orange"
		else if(MUTCOLORS in N.dna.species.species_traits) //Aliens with custom colors simply get turned orange
			N.dna.features["mcolor"] = "f80"
		N.regenerate_icons()
		if(prob(7))
			if(N.w_uniform)
				M.visible_message(pick("<b>[M]</b>'s collar pops up without warning.</span>", "<b>[M]</b> flexes [M.p_their()] arms."))
			else
				M.visible_message("<b>[M]</b> flexes [M.p_their()] arms.")
	if(prob(10))
		M.say(pick("Shit was SO cash.", "You are everything bad in the world.", "What sports do you play, other than 'jack off to naked drawn Japanese people?'", "Don’t be a stranger. Just hit me with your best shot.", "My name is John and I hate every single one of you."))
	..()
	return

/datum/reagent/stableslimetoxin
	name = "Stable Mutation Toxin"
	id = "stablemutationtoxin"
	description = "A humanizing toxin produced by slimes."
	color = "#5EFF3B" //RGB: 94, 255, 59
	metabolization_rate = INFINITY //So it instantly removes all of itself
	taste_description = "slime"
	var/datum/species/race = /datum/species/human
	var/mutationtext = "<span class='danger'>The pain subsides. You feel... human.</span>"

/datum/reagent/stableslimetoxin/on_mob_life(mob/living/carbon/human/H)
	..()
	if(!istype(H))
		return
	to_chat(H, "<span class='warning'><b>You crumple in agony as your flesh wildly morphs into new forms!</b></span>")
	H.visible_message("<b>[H]</b> falls to the ground and screams as [H.p_their()] skin bubbles and froths!") //'froths' sounds painful when used with SKIN.
	H.Knockdown(60, 0)
	addtimer(CALLBACK(src, .proc/mutate, H), 30)
	return

/datum/reagent/stableslimetoxin/proc/mutate(mob/living/carbon/human/H)
	if(QDELETED(H))
		return
	var/current_species = H.dna.species.type
	var/datum/species/mutation = race
	if(mutation && mutation != current_species)
		to_chat(H, mutationtext)
		H.set_species(mutation)
	else
		to_chat(H, "<span class='danger'>The pain vanishes suddenly. You feel no different.</span>")

/datum/reagent/stableslimetoxin/classic //The one from plasma on green slimes
	name = "Mutation Toxin"
	id = "mutationtoxin"
	description = "A corruptive toxin produced by slimes."
	color = "#13BC5E" // rgb: 19, 188, 94
	race = /datum/species/jelly/slime
	mutationtext = "<span class='danger'>The pain subsides. Your whole body feels like slime.</span>"

/datum/reagent/stableslimetoxin/lizard
	name = "Lizard Mutation Toxin"
	id = "lizardmutationtoxin"
	description = "A lizarding toxin produced by slimes."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/lizard
	mutationtext = "<span class='danger'>The pain subsides. You feel... scaly.</span>"

/datum/reagent/stableslimetoxin/fly
	name = "Fly Mutation Toxin"
	id = "flymutationtoxin"
	description = "An insectifying toxin produced by slimes."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/fly
	mutationtext = "<span class='danger'>The pain subsides. You feel... buzzy.</span>"

/datum/reagent/stableslimetoxin/pod
	name = "Podperson Mutation Toxin"
	id = "podmutationtoxin"
	description = "A vegetalizing toxin produced by slimes."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/pod
	mutationtext = "<span class='danger'>The pain subsides. You feel... plantlike.</span>"

/datum/reagent/stableslimetoxin/jelly
	name = "Imperfect Mutation Toxin"
	id = "jellymutationtoxin"
	description = "An jellyfying toxin produced by slimes."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/jelly
	mutationtext = "<span class='danger'>The pain subsides. You feel... wobbly.</span>"

/datum/reagent/stableslimetoxin/golem
	name = "Golem Mutation Toxin"
	id = "golemmutationtoxin"
	description = "A crystal toxin produced by slimes."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/golem/random
	mutationtext = "<span class='danger'>The pain subsides. You feel... rocky.</span>"

/datum/reagent/stableslimetoxin/abductor
	name = "Abductor Mutation Toxin"
	id = "abductormutationtoxin"
	description = "An alien toxin produced by slimes."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/abductor
	mutationtext = "<span class='danger'>The pain subsides. You feel... alien.</span>"

/datum/reagent/stableslimetoxin/android
	name = "Android Mutation Toxin"
	id = "androidmutationtoxin"
	description = "A robotic toxin produced by slimes."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/android
	mutationtext = "<span class='danger'>The pain subsides. You feel... artificial.</span>"


//BLACKLISTED RACES
/datum/reagent/stableslimetoxin/skeleton
	name = "Skeleton Mutation Toxin"
	id = "skeletonmutationtoxin"
	description = "A scary toxin produced by slimes."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/skeleton
	mutationtext = "<span class='danger'>The pain subsides. You feel... spooky.</span>"

/datum/reagent/stableslimetoxin/zombie
	name = "Zombie Mutation Toxin"
	id = "zombiemutationtoxin"
	description = "An undead toxin produced by slimes."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/zombie //Not the infectious kind. The days of xenobio zombie outbreaks are long past.
	mutationtext = "<span class='danger'>The pain subsides. You feel... undead.</span>"

/datum/reagent/stableslimetoxin/ash
	name = "Ash Mutation Toxin"
	id = "ashmutationtoxin"
	description = "An ashen toxin produced by slimes."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/lizard/ashwalker
	mutationtext = "<span class='danger'>The pain subsides. You feel... savage.</span>"


//DANGEROUS RACES
/datum/reagent/stableslimetoxin/shadow
	name = "Shadow Mutation Toxin"
	id = "shadowmutationtoxin"
	description = "A dark toxin produced by slimes."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/shadow
	mutationtext = "<span class='danger'>The pain subsides. You feel... darker.</span>"

/datum/reagent/stableslimetoxin/plasma
	name = "Plasma Mutation Toxin"
	id = "plasmamutationtoxin"
	description = "A plasma-based toxin produced by slimes."
	color = "#5EFF3B" //RGB: 94, 255, 59
	race = /datum/species/plasmaman
	mutationtext = "<span class='danger'>The pain subsides. You feel... flammable.</span>"

/datum/reagent/stableslimetoxin/unstable //PSYCH
	name = "Unstable Mutation Toxin"
	id = "unstablemutationtoxin"
	description = "An unstable and unpredictable corruptive toxin produced by slimes."
	color = "#5EFF3B" //RGB: 94, 255, 59
	mutationtext = "<span class='danger'>The pain subsides. You feel... different.</span>"

/datum/reagent/stableslimetoxin/unstable/on_mob_life(mob/living/carbon/human/H)
	var/list/possible_morphs = list()
	for(var/type in subtypesof(/datum/species))
		var/datum/species/S = type
		if(initial(S.blacklisted))
			continue
		possible_morphs += S
	race = pick(possible_morphs)
	..()

/datum/reagent/mulligan
	name = "Mulligan Toxin"
	id = "mulligan"
	description = "This toxin will rapidly change the DNA of human beings. Commonly used by Syndicate spies and assassins in need of an emergency ID change."
	color = "#5EFF3B" //RGB: 94, 255, 59
	metabolization_rate = INFINITY
	taste_description = "slime"

/datum/reagent/mulligan/on_mob_life(mob/living/carbon/human/H)
	to_chat(H, "<span class='warning'><b>You grit your teeth in pain as your body rapidly mutates!</b></span>")
	H.visible_message("<b>[H]</b> suddenly transforms!")
	randomize_human(H)
	..()

/datum/reagent/aslimetoxin
	name = "Advanced Mutation Toxin"
	id = "amutationtoxin"
	description = "An advanced corruptive toxin produced by slimes."
	color = "#13BC5E" // rgb: 19, 188, 94
	taste_description = "slime"

/datum/reagent/aslimetoxin/reaction_mob(mob/M, method=TOUCH, reac_volume)
	if(method != TOUCH)
		M.ForceContractDisease(new /datum/disease/transformation/slime(0))

/datum/reagent/gluttonytoxin
	name = "Gluttony's Blessing"
	id = "gluttonytoxin"
	description = "An advanced corruptive toxin produced by something terrible."
	color = "#5EFF3B" //RGB: 94, 255, 59
	can_synth = 0
	taste_description = "decay"

/datum/reagent/gluttonytoxin/reaction_mob(mob/M, method=TOUCH, reac_volume)
	M.ForceContractDisease(new /datum/disease/transformation/morph(0))

/datum/reagent/serotrotium
	name = "Serotrotium"
	id = "serotrotium"
	description = "A chemical compound that promotes concentrated production of the serotonin neurotransmitter in humans."
	color = "#202040" // rgb: 20, 20, 40
	metabolization_rate = 0.25 * REAGENTS_METABOLISM
	taste_description = "bitterness"

/datum/reagent/serotrotium/on_mob_life(mob/living/M)
	if(ishuman(M))
		if(prob(7))
			M.emote(pick("twitch","drool","moan","gasp"))
	..()

/datum/reagent/oxygen
	name = "Oxygen"
	id = "oxygen"
	description = "A colorless, odorless gas. Grows on trees but is still pretty valuable."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_mult = 0 // oderless and tasteless

/datum/reagent/oxygen/reaction_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))
		return 0
	O.atmos_spawn_air("o2=[reac_volume/2];TEMP=[T20C]")

/datum/reagent/oxygen/reaction_turf(turf/open/T, reac_volume)
	if(istype(T))
		T.atmos_spawn_air("o2=[reac_volume/2];TEMP=[T20C]")
	return

/datum/reagent/copper
	name = "Copper"
	id = "copper"
	description = "A highly ductile metal. Things made out of copper aren't very durable, but it makes a decent material for electrical wiring."
	reagent_state = SOLID
	color = "#6E3B08" // rgb: 110, 59, 8
	taste_description = "metal"

/datum/reagent/nitrogen
	name = "Nitrogen"
	id = "nitrogen"
	description = "A colorless, odorless, tasteless gas. A simple asphyxiant that can silently displace vital oxygen."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_mult = 0

/datum/reagent/nitrogen/reaction_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))
		return 0
	O.atmos_spawn_air("n2=[reac_volume/2];TEMP=[T20C]")

/datum/reagent/nitrogen/reaction_turf(turf/open/T, reac_volume)
	if(istype(T))
		T.atmos_spawn_air("n2=[reac_volume/2];TEMP=[T20C]")
	return

/datum/reagent/hydrogen
	name = "Hydrogen"
	id = "hydrogen"
	description = "A colorless, odorless, nonmetallic, tasteless, highly combustible diatomic gas."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_mult = 0

/datum/reagent/potassium
	name = "Potassium"
	id = "potassium"
	description = "A soft, low-melting solid that can easily be cut with a knife. Reacts violently with water."
	reagent_state = SOLID
	color = "#A0A0A0" // rgb: 160, 160, 160
	taste_description = "sweetness"

/datum/reagent/mercury
	name = "Mercury"
	id = "mercury"
	description = "A curious metal that's a liquid at room temperature. Neurodegenerative and very bad for the mind."
	color = "#484848" // rgb: 72, 72, 72A
	taste_mult = 0 // apparently tasteless.

/datum/reagent/mercury/on_mob_life(mob/living/M)
	if(M.canmove && !isspaceturf(M.loc))
		step(M, pick(GLOB.cardinals))
	if(prob(5))
		M.emote(pick("twitch","drool","moan"))
	M.adjustBrainLoss(2)
	..()

/datum/reagent/sulfur
	name = "Sulfur"
	id = "sulfur"
	description = "A sickly yellow solid mostly known for its nasty smell. It's actually much more helpful than it looks in biochemisty."
	reagent_state = SOLID
	color = "#BF8C00" // rgb: 191, 140, 0
	taste_description = "rotten eggs"

/datum/reagent/carbon
	name = "Carbon"
	id = "carbon"
	description = "A crumbly black solid that, while unexciting on an physical level, forms the base of all known life. Kind of a big deal."
	reagent_state = SOLID
	color = "#1C1300" // rgb: 30, 20, 0
	taste_description = "sour chalk"

/datum/reagent/carbon/reaction_turf(turf/T, reac_volume)
	if(!isspaceturf(T))
		var/obj/effect/decal/cleanable/dirt/D = locate() in T.contents
		if(!D)
			new /obj/effect/decal/cleanable/dirt(T)

/datum/reagent/chlorine
	name = "Chlorine"
	id = "chlorine"
	description = "A pale yellow gas that's well known as an oxidizer. While it forms many harmless molecules in its elemental form it is far from harmless."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_description = "chlorine"

/datum/reagent/chlorine/on_mob_life(mob/living/M)
	M.take_bodypart_damage(1*REM, 0, 0)
	. = 1
	..()

/datum/reagent/fluorine
	name = "Fluorine"
	id = "fluorine"
	description = "A comically-reactive chemical element. The universe does not want this stuff to exist in this form in the slightest."
	reagent_state = GAS
	color = "#808080" // rgb: 128, 128, 128
	taste_description = "acid"

/datum/reagent/fluorine/on_mob_life(mob/living/M)
	M.adjustToxLoss(1*REM, 0)
	. = 1
	..()

/datum/reagent/sodium
	name = "Sodium"
	id = "sodium"
	description = "A soft silver metal that can easily be cut with a knife. It's not salt just yet, so refrain from putting in on your chips."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
	taste_description = "salty metal"

/datum/reagent/phosphorus
	name = "Phosphorus"
	id = "phosphorus"
	description = "A ruddy red powder that burns readily. Though it comes in many colors, the general theme is always the same."
	reagent_state = SOLID
	color = "#832828" // rgb: 131, 40, 40
	taste_description = "vinegar"

/datum/reagent/lithium
	name = "Lithium"
	id = "lithium"
	description = "A silver metal, its claim to fame is its remarkably low density. Using it is a bit too effective in calming oneself down."
	reagent_state = SOLID
	color = "#808080" // rgb: 128, 128, 128
	taste_description = "metal"

/datum/reagent/lithium/on_mob_life(mob/living/M)
	if(M.canmove && !isspaceturf(M.loc))
		step(M, pick(GLOB.cardinals))
	if(prob(5))
		M.emote(pick("twitch","drool","moan"))
	..()

/datum/reagent/glycerol
	name = "Glycerol"
	id = "glycerol"
	description = "Glycerol is a simple polyol compound. Glycerol is sweet-tasting and of low toxicity."
	color = "#808080" // rgb: 128, 128, 128
	taste_description = "sweetness"

/datum/reagent/radium
	name = "Radium"
	id = "radium"
	description = "Radium is an alkaline earth metal. It is extremely radioactive."
	reagent_state = SOLID
	color = "#C7C7C7" // rgb: 199,199,199
	taste_description = "the colour blue and regret"

/datum/reagent/radium/on_mob_life(mob/living/M)
	M.apply_effect(2*REM/M.metabolism_efficiency,IRRADIATE,0)
	..()

/datum/reagent/radium/reaction_turf(turf/T, reac_volume)
	if(reac_volume >= 3)
		if(!isspaceturf(T))
			var/obj/effect/decal/cleanable/greenglow/GG = locate() in T.contents
			if(!GG)
				GG = new/obj/effect/decal/cleanable/greenglow(T)
			GG.reagents.add_reagent("radium", reac_volume)

/datum/reagent/space_cleaner/sterilizine
	name = "Sterilizine"
	id = "sterilizine"
	description = "Sterilizes wounds in preparation for surgery."
	color = "#C8A5DC" // rgb: 200, 165, 220
	taste_description = "bitterness"

/datum/reagent/space_cleaner/sterilizine/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(iscarbon(M) && (method in list(TOUCH, VAPOR, PATCH)))
		var/mob/living/carbon/C = M
		for(var/s in C.surgeries)
			var/datum/surgery/S = s
			S.success_multiplier = max(0.20, S.success_multiplier)
			// +20% success propability on each step, useful while operating in less-than-perfect conditions
	..()

/datum/reagent/iron
	name = "Iron"
	id = "iron"
	description = "Pure iron is a metal."
	reagent_state = SOLID
	taste_description = "iron"

	color = "#C8A5DC" // rgb: 200, 165, 220

/datum/reagent/iron/on_mob_life(mob/living/M)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		if(C.blood_volume < BLOOD_VOLUME_NORMAL)
			C.blood_volume += 0.5
	..()

/datum/reagent/iron/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(!isliving(M))
		return
	if(M.has_bane(BANE_IRON)) //If the target is weak to cold iron, then poison them.
		if(holder && holder.chem_temp < 100) // COLD iron.
			M.reagents.add_reagent("toxin", reac_volume)
	..()

/datum/reagent/gold
	name = "Gold"
	id = "gold"
	description = "Gold is a dense, soft, shiny metal and the most malleable and ductile metal known."
	reagent_state = SOLID
	color = "#F7C430" // rgb: 247, 196, 48
	taste_description = "expensive metal"

/datum/reagent/silver
	name = "Silver"
	id = "silver"
	description = "A soft, white, lustrous transition metal, it has the highest electrical conductivity of any element and the highest thermal conductivity of any metal."
	reagent_state = SOLID
	color = "#D0D0D0" // rgb: 208, 208, 208
	taste_description = "expensive yet reasonable metal"

/datum/reagent/silver/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(!isliving(M))
		return
	if(M.has_bane(BANE_SILVER))
		M.reagents.add_reagent("toxin", reac_volume)
	..()

/datum/reagent/uranium
	name ="Uranium"
	id = "uranium"
	description = "A silvery-white metallic chemical element in the actinide series, weakly radioactive."
	reagent_state = SOLID
	color = "#B8B8C0" // rgb: 184, 184, 192
	taste_description = "the inside of a reactor"

/datum/reagent/uranium/on_mob_life(mob/living/M)
	M.apply_effect(1/M.metabolism_efficiency,IRRADIATE,0)
	..()

/datum/reagent/uranium/reaction_turf(turf/T, reac_volume)
	if(reac_volume >= 3)
		if(!isspaceturf(T))
			var/obj/effect/decal/cleanable/greenglow/GG = locate() in T.contents
			if(!GG)
				GG = new/obj/effect/decal/cleanable/greenglow(T)
			GG.reagents.add_reagent("uranium", reac_volume)

/datum/reagent/bluespace
	name = "Bluespace Dust"
	id = "bluespace"
	description = "A dust composed of microscopic bluespace crystals, with minor space-warping properties."
	reagent_state = SOLID
	color = "#0000CC"
	taste_description = "fizzling blue"

/datum/reagent/bluespace/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		do_teleport(M, get_turf(M), (reac_volume / 5), asoundin = 'sound/effects/phasein.ogg') //4 tiles per crystal
	..()

/datum/reagent/bluespace/on_mob_life(mob/living/M)
	if(current_cycle > 10 && prob(15))
		to_chat(M, "<span class='warning'>You feel unstable...</span>")
		M.Jitter(2)
		current_cycle = 1
		addtimer(CALLBACK(GLOBAL_PROC, .proc/do_teleport, M, get_turf(M), 5, null, null, null, 'sound/effects/phasein.ogg'), 30)
	..()

/datum/reagent/aluminium
	name = "Aluminium"
	id = "aluminium"
	description = "A silvery white and ductile member of the boron group of chemical elements."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168
	taste_description = "metal"

/datum/reagent/silicon
	name = "Silicon"
	id = "silicon"
	description = "A tetravalent metalloid, silicon is less reactive than its chemical analog carbon."
	reagent_state = SOLID
	color = "#A8A8A8" // rgb: 168, 168, 168
	taste_mult = 0

/datum/reagent/fuel
	name = "Welding fuel"
	id = "welding_fuel"
	description = "Required for welders. Flamable."
	color = "#660000" // rgb: 102, 0, 0
	taste_description = "gross metal"
	glass_icon_state = "dr_gibb_glass"
	glass_name = "glass of welder fuel"
	glass_desc = "Unless you're an industrial tool, this is probably not safe for consumption."

/datum/reagent/fuel/reaction_mob(mob/living/M, method=TOUCH, reac_volume)//Splashing people with welding fuel to make them easy to ignite!
	if(!isliving(M))
		return
	if(method == TOUCH || method == VAPOR)
		M.adjust_fire_stacks(reac_volume / 10)
		return
	..()

/datum/reagent/fuel/on_mob_life(mob/living/M)
	M.adjustToxLoss(1, 0)
	. = 1
	..()

/datum/reagent/space_cleaner
	name = "Space cleaner"
	id = "cleaner"
	description = "A compound used to clean things. Now with 50% more sodium hypochlorite!"
	color = "#A5F0EE" // rgb: 165, 240, 238
	taste_description = "sourness"

/datum/reagent/space_cleaner/reaction_obj(obj/O, reac_volume)
	if(istype(O,/obj/effect/decal/cleanable))
		qdel(O)
	else
		if(O)
			O.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
			O.clean_blood()

/datum/reagent/space_cleaner/reaction_turf(turf/T, reac_volume)
	if(reac_volume >= 1)
		T.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		T.clean_blood()
		for(var/obj/effect/decal/cleanable/C in T)
			qdel(C)

		for(var/mob/living/simple_animal/slime/M in T)
			M.adjustToxLoss(rand(5,10))

/datum/reagent/space_cleaner/reaction_mob(mob/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		M.remove_atom_colour(WASHABLE_COLOUR_PRIORITY)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(H.lip_style)
					H.lip_style = null
					H.update_body()
			for(var/obj/item/I in C.held_items)
				I.clean_blood()
			if(C.wear_mask)
				if(C.wear_mask.clean_blood())
					C.update_inv_wear_mask()
			if(ishuman(M))
				var/mob/living/carbon/human/H = C
				if(H.head)
					if(H.head.clean_blood())
						H.update_inv_head()
				if(H.wear_suit)
					if(H.wear_suit.clean_blood())
						H.update_inv_wear_suit()
				else if(H.w_uniform)
					if(H.w_uniform.clean_blood())
						H.update_inv_w_uniform()
				if(H.shoes)
					if(H.shoes.clean_blood())
						H.update_inv_shoes()
				H.wash_cream()
			M.clean_blood()

/datum/reagent/space_cleaner/ez_clean
	name = "EZ Clean"
	id = "ez_clean"
	description = "A powerful, acidic cleaner sold by Waffle Co. Affects organic matter while leaving other objects unaffected."
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "acid"

/datum/reagent/space_cleaner/ez_clean/on_mob_life(mob/living/M)
	M.adjustBruteLoss(3.33)
	M.adjustFireLoss(3.33)
	M.adjustToxLoss(3.33)
	..()

/datum/reagent/space_cleaner/ez_clean/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	..()
	if((method == TOUCH || method == VAPOR) && !issilicon(M))
		M.adjustBruteLoss(1)
		M.adjustFireLoss(1)

/datum/reagent/cryptobiolin
	name = "Cryptobiolin"
	id = "cryptobiolin"
	description = "Cryptobiolin causes confusion and dizziness."
	color = "#C8A5DC" // rgb: 200, 165, 220
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	taste_description = "sourness"

/datum/reagent/cryptobiolin/on_mob_life(mob/living/M)
	M.Dizzy(1)
	if(!M.confused)
		M.confused = 1
	M.confused = max(M.confused, 20)
	..()

/datum/reagent/impedrezene
	name = "Impedrezene"
	id = "impedrezene"
	description = "Impedrezene is a narcotic that impedes one's ability by slowing down the higher brain cell functions."
	color = "#C8A5DC" // rgb: 200, 165, 220A
	taste_description = "numbness"

/datum/reagent/impedrezene/on_mob_life(mob/living/M)
	M.jitteriness = max(M.jitteriness-5,0)
	if(prob(80))
		M.adjustBrainLoss(1*REM)
	if(prob(50))
		M.drowsyness = max(M.drowsyness, 3)
	if(prob(10))
		M.emote("drool")
	..()

/datum/reagent/nanites
	name = "Nanomachines"
	id = "nanomachines"
	description = "Microscopic construction robots."
	color = "#535E66" // rgb: 83, 94, 102
	can_synth = 0
	taste_description = "sludge"

/datum/reagent/nanites/reaction_mob(mob/M, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		M.ForceContractDisease(new /datum/disease/transformation/robot(0))

/datum/reagent/xenomicrobes
	name = "Xenomicrobes"
	id = "xenomicrobes"
	description = "Microbes with an entirely alien cellular structure."
	color = "#535E66" // rgb: 83, 94, 102
	can_synth = 0
	taste_description = "sludge"

/datum/reagent/xenomicrobes/reaction_mob(mob/M, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		M.ContractDisease(new /datum/disease/transformation/xeno(0))

/datum/reagent/fungalspores
	name = "Tubercle bacillus Cosmosis microbes"
	id = "fungalspores"
	description = "Active fungal spores."
	color = "#92D17D" // rgb: 146, 209, 125
	taste_description = "slime"

/datum/reagent/fungalspores/reaction_mob(mob/M, method=TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(method==PATCH || method==INGEST || method==INJECT || (method == VAPOR && prob(min(reac_volume,100)*(1 - touch_protection))))
		M.ForceContractDisease(new /datum/disease/tuberculosis(0))

/datum/reagent/fluorosurfactant//foam precursor
	name = "Fluorosurfactant"
	id = "fluorosurfactant"
	description = "A perfluoronated sulfonic acid that forms a foam when mixed with water."
	color = "#9E6B38" // rgb: 158, 107, 56
	taste_description = "metal"

/datum/reagent/foaming_agent// Metal foaming agent. This is lithium hydride. Add other recipes (e.g. LiH + H2O -> LiOH + H2) eventually.
	name = "Foaming agent"
	id = "foaming_agent"
	description = "A agent that yields metallic foam when mixed with light metal and a strong acid."
	reagent_state = SOLID
	color = "#664B63" // rgb: 102, 75, 99
	taste_description = "metal"

/datum/reagent/ammonia
	name = "Ammonia"
	id = "ammonia"
	description = "A caustic substance commonly used in fertilizer or household cleaners."
	reagent_state = GAS
	color = "#404030" // rgb: 64, 64, 48
	taste_description = "mordant"

/datum/reagent/diethylamine
	name = "Diethylamine"
	id = "diethylamine"
	description = "A secondary amine, mildly corrosive."
	color = "#604030" // rgb: 96, 64, 48
	taste_description = "iron"

/datum/reagent/carbondioxide
	name = "Carbon Dioxide"
	id = "co2"
	reagent_state = GAS
	description = "A gas commonly produced by burning carbon fuels. You're constantly producing this in your lungs."
	color = "#B0B0B0" // rgb : 192, 192, 192
	taste_description = "something unknowable"

/datum/reagent/carbondioxide/reaction_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))
		return 0
	O.atmos_spawn_air("co2=[reac_volume/5];TEMP=[T20C]")

/datum/reagent/carbondioxide/reaction_turf(turf/open/T, reac_volume)
	if(istype(T))
		T.atmos_spawn_air("co2=[reac_volume/5];TEMP=[T20C]")
	return

/datum/reagent/nitrous_oxide
	name = "Nitrous Oxide"
	id = "nitrous_oxide"
	description = "A potent oxidizer used as fuel in rockets and as an anaesthetic during surgery."
	reagent_state = LIQUID
	metabolization_rate = 1.5 * REAGENTS_METABOLISM
	color = "#808080"
	taste_description = "sweetness"

/datum/reagent/nitrous_oxide/reaction_obj(obj/O, reac_volume)
	if((!O) || (!reac_volume))
		return 0
	O.atmos_spawn_air("n2o=[reac_volume/5];TEMP=[T20C]")

/datum/reagent/nitrous_oxide/reaction_turf(turf/open/T, reac_volume)
	if(istype(T))
		T.atmos_spawn_air("n2o=[reac_volume/5];TEMP=[T20C]")

/datum/reagent/nitrous_oxide/reaction_mob(mob/M, method=TOUCH, reac_volume)
	if(method == VAPOR)
		M.drowsyness += max(round(reac_volume, 1), 2)

/datum/reagent/nitrous_oxide/on_mob_life(mob/living/M)
	M.drowsyness += 2
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		H.blood_volume = max(H.blood_volume - 2.5, 0)
	if(prob(20))
		M.losebreath += 2
		M.confused = min(M.confused + 2, 5)
	..()

/////////////////////////Coloured Crayon Powder////////////////////////////
//For colouring in /proc/mix_color_from_reagents


/datum/reagent/colorful_reagent/crayonpowder
	name = "Crayon Powder"
	id = "crayon powder"
	var/colorname = "none"
	description = "A powder made by grinding down crayons, good for colouring chemical reagents."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 207, 54, 0
	taste_description = "the back of class"

/datum/reagent/colorful_reagent/crayonpowder/New()
	description = "\an [colorname] powder made by grinding down crayons, good for colouring chemical reagents."


/datum/reagent/colorful_reagent/crayonpowder/red
	name = "Red Crayon Powder"
	id = "redcrayonpowder"
	colorname = "red"
	color = "#DA0000" // red
	random_color_list = list("#DA0000")

/datum/reagent/colorful_reagent/crayonpowder/orange
	name = "Orange Crayon Powder"
	id = "orangecrayonpowder"
	colorname = "orange"
	color = "#FF9300" // orange
	random_color_list = list("#FF9300")

/datum/reagent/colorful_reagent/crayonpowder/yellow
	name = "Yellow Crayon Powder"
	id = "yellowcrayonpowder"
	colorname = "yellow"
	color = "#FFF200" // yellow
	random_color_list = list("#FFF200")

/datum/reagent/colorful_reagent/crayonpowder/green
	name = "Green Crayon Powder"
	id = "greencrayonpowder"
	colorname = "green"
	color = "#A8E61D" // green
	random_color_list = list("#A8E61D")

/datum/reagent/colorful_reagent/crayonpowder/blue
	name = "Blue Crayon Powder"
	id = "bluecrayonpowder"
	colorname = "blue"
	color = "#00B7EF" // blue
	random_color_list = list("#00B7EF")

/datum/reagent/colorful_reagent/crayonpowder/purple
	name = "Purple Crayon Powder"
	id = "purplecrayonpowder"
	colorname = "purple"
	color = "#DA00FF" // purple
	random_color_list = list("#DA00FF")

/datum/reagent/colorful_reagent/crayonpowder/invisible
	name = "Invisible Crayon Powder"
	id = "invisiblecrayonpowder"
	colorname = "invisible"
	color = "#FFFFFF00" // white + no alpha
	random_color_list = list(null)	//because using the powder color turns things invisible

/datum/reagent/colorful_reagent/crayonpowder/black
	name = "Black Crayon Powder"
	id = "blackcrayonpowder"
	colorname = "black"
	color = "#1C1C1C" // not quite black
	random_color_list = list("#404040")

/datum/reagent/colorful_reagent/crayonpowder/white
	name = "White Crayon Powder"
	id = "whitecrayonpowder"
	colorname = "white"
	color = "#FFFFFF" // white
	random_color_list = list("#FFFFFF") //doesn't actually change appearance at all




//////////////////////////////////Hydroponics stuff///////////////////////////////

/datum/reagent/plantnutriment
	name = "Generic nutriment"
	id = "plantnutriment"
	description = "Some kind of nutriment. You can't really tell what it is. You should probably report it, along with how you obtained it."
	color = "#000000" // RBG: 0, 0, 0
	var/tox_prob = 0
	taste_description = "plant food"

/datum/reagent/plantnutriment/on_mob_life(mob/living/M)
	if(prob(tox_prob))
		M.adjustToxLoss(1*REM, 0)
		. = 1
	..()

/datum/reagent/plantnutriment/eznutriment
	name = "E-Z-Nutrient"
	id = "eznutriment"
	description = "Cheap and extremely common type of plant nutriment."
	color = "#376400" // RBG: 50, 100, 0
	tox_prob = 10

/datum/reagent/plantnutriment/left4zednutriment
	name = "Left 4 Zed"
	id = "left4zednutriment"
	description = "Unstable nutriment that makes plants mutate more often than usual."
	color = "#1A1E4D" // RBG: 26, 30, 77
	tox_prob = 25

/datum/reagent/plantnutriment/robustharvestnutriment
	name = "Robust Harvest"
	id = "robustharvestnutriment"
	description = "Very potent nutriment that prevents plants from mutating."
	color = "#9D9D00" // RBG: 157, 157, 0
	tox_prob = 15







// GOON OTHERS



/datum/reagent/oil
	name = "Oil"
	id = "oil"
	description = "Burns in a small smoky fire, mostly used to get Ash."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "oil"

/datum/reagent/stable_plasma
	name = "Stable Plasma"
	id = "stable_plasma"
	description = "Non-flammable plasma locked into a liquid form that cannot ignite or become gaseous/solid."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "bitterness"
	taste_mult = 1.5

/datum/reagent/stable_plasma/on_mob_life(mob/living/M)
	if(iscarbon(M))
		var/mob/living/carbon/C = M
		C.adjustPlasma(10)
	..()
	return

/datum/reagent/iodine
	name = "Iodine"
	id = "iodine"
	description = "Commonly added to table salt as a nutrient. On its own it tastes far less pleasing."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "metal"

/datum/reagent/carpet
	name = "Carpet"
	id = "carpet"
	description = "For those that need a more creative way to roll out a red carpet."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "carpet" // Your tounge feels furry.

/datum/reagent/carpet/reaction_turf(turf/T, reac_volume)
	if(istype(T, /turf/open/floor/plating) || istype(T, /turf/open/floor/plasteel))
		var/turf/open/floor/F = T
		F.ChangeTurf(/turf/open/floor/carpet)
	..()
	return

/datum/reagent/bromine
	name = "Bromine"
	id = "bromine"
	description = "A brownish liquid that's highly reactive. Useful for stopping free radicals, but not intended for human consumption."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "chemicals"

/datum/reagent/phenol
	name = "Phenol"
	id = "phenol"
	description = "An aromatic ring of carbon with a hydroxyl group. A useful precursor to some medicines, but has no healing properties on its own."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "acid"

/datum/reagent/ash
	name = "Ash"
	id = "ash"
	description = "Supposedly phoenixes rise from these, but you've never seen it."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "ash"

/datum/reagent/acetone
	name = "Acetone"
	id = "acetone"
	description = "A slick, slightly carcinogenic liquid. Has a multitude of mundane uses in everyday life."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "acid"

/datum/reagent/colorful_reagent
	name = "Colorful Reagent"
	id = "colorful_reagent"
	description = "Thoroughly sample the rainbow."
	reagent_state = LIQUID
	color = "#C8A5DC"
	var/list/random_color_list = list("#00aedb","#a200ff","#f47835","#d41243","#d11141","#00b159","#00aedb","#f37735","#ffc425","#008744","#0057e7","#d62d20","#ffa700")
	taste_description = "rainbows"


/datum/reagent/colorful_reagent/on_mob_life(mob/living/M)
	if(M && isliving(M))
		M.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)
	..()

/datum/reagent/colorful_reagent/reaction_mob(mob/living/M, reac_volume)
	if(M && isliving(M))
		M.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)
	..()

/datum/reagent/colorful_reagent/reaction_obj(obj/O, reac_volume)
	if(O)
		O.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)
	..()

/datum/reagent/colorful_reagent/reaction_turf(turf/T, reac_volume)
	if(T)
		T.add_atom_colour(pick(random_color_list), WASHABLE_COLOUR_PRIORITY)
	..()

/datum/reagent/hair_dye
	name = "Quantum Hair Dye"
	id = "hair_dye"
	description = "Has a high chance of making you look like a mad scientist."
	reagent_state = LIQUID
	color = "#C8A5DC"
	var/list/potential_colors = list("0ad","a0f","f73","d14","d14","0b5","0ad","f73","fc2","084","05e","d22","fa0") // fucking hair code
	taste_description = "sourness"

/datum/reagent/hair_dye/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		if(M && ishuman(M))
			var/mob/living/carbon/human/H = M
			H.hair_color = pick(potential_colors)
			H.facial_hair_color = pick(potential_colors)
			H.update_hair()

/datum/reagent/barbers_aid
	name = "Barber's Aid"
	id = "barbers_aid"
	description = "A solution to hair loss across the world."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "sourness"

/datum/reagent/barbers_aid/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		if(M && ishuman(M))
			var/mob/living/carbon/human/H = M
			var/datum/sprite_accessory/hair/picked_hair = pick(GLOB.hair_styles_list)
			var/datum/sprite_accessory/facial_hair/picked_beard = pick(GLOB.facial_hair_styles_list)
			H.hair_style = picked_hair
			H.facial_hair_style = picked_beard
			H.update_hair()

/datum/reagent/concentrated_barbers_aid
	name = "Concentrated Barber's Aid"
	id = "concentrated_barbers_aid"
	description = "A concentrated solution to hair loss across the world."
	reagent_state = LIQUID
	color = "#C8A5DC"
	taste_description = "sourness"

/datum/reagent/concentrated_barbers_aid/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		if(M && ishuman(M))
			var/mob/living/carbon/human/H = M
			H.hair_style = "Very Long Hair"
			H.facial_hair_style = "Very Long Beard"
			H.update_hair()

/datum/reagent/saltpetre
	name = "Saltpetre"
	id = "saltpetre"
	description = "Volatile. Controversial. Third Thing."
	reagent_state = LIQUID
	color = "#60A584" // rgb: 96, 165, 132
	taste_description = "cool salt"

/datum/reagent/lye
	name = "Lye"
	id = "lye"
	description = "Also known as sodium hydroxide. As a profession making this is somewhat underwhelming."
	reagent_state = LIQUID
	color = "#FFFFD6" // very very light yellow
	taste_description = "acid"

/datum/reagent/drying_agent
	name = "Drying agent"
	id = "drying_agent"
	description = "A desiccant. Can be used to dry things."
	reagent_state = LIQUID
	color = "#A70FFF"
	taste_description = "dryness"

/datum/reagent/drying_agent/reaction_turf(turf/open/T, reac_volume)
	if(istype(T) && T.wet)
		T.wet_time = max(0, T.wet_time-reac_volume*5) // removes 5 seconds of wetness for every unit.
		T.HandleWet()

/datum/reagent/drying_agent/reaction_obj(obj/O, reac_volume)
	if(O.type == /obj/item/clothing/shoes/galoshes)
		var/t_loc = get_turf(O)
		qdel(O)
		new /obj/item/clothing/shoes/galoshes/dry(t_loc)

// Virology virus food chems.

/datum/reagent/toxin/mutagen/mutagenvirusfood
	name = "mutagenic agar"
	id = "mutagenvirusfood"
	color = "#A3C00F" // rgb: 163,192,15
	taste_description = "sourness"

/datum/reagent/toxin/mutagen/mutagenvirusfood/sugar
	name = "sucrose agar"
	id = "sugarvirusfood"
	color = "#41B0C0" // rgb: 65,176,192
	taste_description = "sweetness"

/datum/reagent/medicine/synaptizine/synaptizinevirusfood
	name = "virus rations"
	id = "synaptizinevirusfood"
	color = "#D18AA5" // rgb: 209,138,165
	taste_description = "bitterness"

/datum/reagent/toxin/plasma/plasmavirusfood
	name = "virus plasma"
	id = "plasmavirusfood"
	color = "#A69DA9" // rgb: 166,157,169
	taste_description = "bitterness"
	taste_mult = 1.5

/datum/reagent/toxin/plasma/plasmavirusfood/weak
	name = "weakened virus plasma"
	id = "weakplasmavirusfood"
	color = "#CEC3C6" // rgb: 206,195,198
	taste_description = "bitterness"
	taste_mult = 1.5

/datum/reagent/uranium/uraniumvirusfood
	name = "decaying uranium gel"
	id = "uraniumvirusfood"
	color = "#67ADBA" // rgb: 103,173,186
	taste_description = "the inside of a reactor"

/datum/reagent/uranium/uraniumvirusfood/unstable
	name = "unstable uranium gel"
	id = "uraniumplasmavirusfood_unstable"
	color = "#2FF2CB" // rgb: 47,242,203
	taste_description = "the inside of a reactor"

/datum/reagent/uranium/uraniumvirusfood/stable
	name = "stable uranium gel"
	id = "uraniumplasmavirusfood_stable"
	color = "#04506C" // rgb: 4,80,108
	taste_description = "the inside of a reactor"

// Bee chemicals

/datum/reagent/royal_bee_jelly
	name = "royal bee jelly"
	id = "royal_bee_jelly"
	description = "Royal Bee Jelly, if injected into a Queen Space Bee said bee will split into two bees."
	color = "#00ff80"
	taste_description = "strange honey"

/datum/reagent/royal_bee_jelly/on_mob_life(mob/living/M)
	if(prob(2))
		M.say(pick("Bzzz...","BZZ BZZ","Bzzzzzzzzzzz..."))
	..()

//Misc reagents

/datum/reagent/romerol
	name = "Romerol"
	// the REAL zombie powder
	id = "romerol"
	description = "Romerol is a highly experimental bioterror agent \
		which causes dormant nodules to be etched into the grey matter of \
		the subject. These nodules only become active upon death of the \
		host, upon which, the secondary structures activate and take control \
		of the host body."
	color = "#123524" // RGB (18, 53, 36)
	metabolization_rate = INFINITY
	can_synth = 0
	taste_description = "brains"

/datum/reagent/romerol/on_mob_life(mob/living/carbon/human/H)
	// Silently add the zombie infection organ to be activated upon death
	if(!H.getorganslot("zombie_infection"))
		var/obj/item/organ/zombie_infection/ZI = new()
		ZI.Insert(H)
	..()

/datum/reagent/growthserum
	name = "Growth Serum"
	id = "growthserum"
	description = "A commercial chemical designed to help older men in the bedroom."//not really it just makes you a giant
	color = "#ff0000"//strong red. rgb 255, 0, 0
	var/current_size = 1
	taste_description = "bitterness" // apparently what viagra tastes like

/datum/reagent/growthserum/on_mob_life(mob/living/carbon/H)
	var/newsize = current_size
	switch(volume)
		if(0 to 19)
			newsize = 1.25
		if(20 to 49)
			newsize = 1.5
		if(50 to 99)
			newsize = 2
		if(100 to 199)
			newsize = 2.5
		if(200 to INFINITY)
			newsize = 3.5

	H.resize = newsize/current_size
	current_size = newsize
	H.update_transform()
	..()

/datum/reagent/growthserum/on_mob_delete(mob/living/M)
	M.resize = 1/current_size
	M.update_transform()
	..()

/datum/reagent/plastic_polymers
	name = "plastic polymers"
	id = "plastic_polymers"
	description = "the petroleum based components of plastic."
	color = "#f7eded"
	taste_description = "plastic"

/datum/reagent/glitter
	name = "generic glitter"
	id = "glitter"
	description = "if you can see this description, contact a coder."
	color = "#FFFFFF" //pure white
	taste_description = "plastic"
	reagent_state = SOLID
	var/glitter_type = /obj/effect/decal/cleanable/glitter

/datum/reagent/glitter/reaction_turf(turf/T, reac_volume)
	if(!istype(T))
		return
	new glitter_type(T)

/datum/reagent/glitter/pink
	name = "pink glitter"
	id = "pink_glitter"
	description = "pink sparkles that get everywhere"
	color = "#ff8080" //A light pink color
	glitter_type = /obj/effect/decal/cleanable/glitter/pink

/datum/reagent/glitter/white
	name = "white glitter"
	id = "white_glitter"
	description = "white sparkles that get everywhere"
	glitter_type = /obj/effect/decal/cleanable/glitter/white

/datum/reagent/glitter/blue
	name = "blue glitter"
	id = "blue_glitter"
	description = "blue sparkles that get everywhere"
	color = "#4040FF" //A blueish color
	glitter_type = /obj/effect/decal/cleanable/glitter/blue
