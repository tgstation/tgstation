 //Fermichem!!
//Fun chems for all the family

/datum/reagent/fermi
	name = "Fermi" //This should never exist, but it does so that it can exist in the case of errors..
	id = "fermi"
	taste_description	= "affection and love!"
	can_synth = FALSE

//This should process fermichems to find out how pure they are and what effect to do.
/datum/reagent/fermi/on_mob_add(mob/living/carbon/M, amount)
	. = ..()
	if(!M)
		return
	if(purity < 0)
		CRASH("Purity below 0 for chem: [id], Please let Fermis Know!")
	if (purity == 1 || DoNotSplit == TRUE)
		log_game("FERMICHEM: [M] ckey: [M.key] has ingested [volume]u of [id]")
		return
	else if (InverseChemVal > purity)//Turns all of a added reagent into the inverse chem
		M.reagents.remove_reagent(id, amount, FALSE)
		M.reagents.add_reagent(InverseChem, amount, FALSE, other_purity = 1)
		log_game("FERMICHEM: [M] ckey: [M.key] has ingested [volume]u of [InverseChem]")
		return
	else
		var/impureVol = amount * (1 - purity) //turns impure ratio into impure chem
		M.reagents.remove_reagent(id, (impureVol), FALSE)
		M.reagents.add_reagent(ImpureChem, impureVol, FALSE, other_purity = 1)
		log_game("FERMICHEM: [M] ckey: [M.key] has ingested [volume - impureVol]u of [id]")
		log_game("FERMICHEM: [M] ckey: [M.key] has ingested [volume]u of [ImpureChem]")
	return

//When merging two fermichems, see above
/datum/reagent/fermi/on_merge(data, amount, mob/living/carbon/M, purity)//basically on_mob_add but for merging
	. = ..()
	if(!ishuman(M))
		return
	if (purity < 0)
		CRASH("Purity below 0 for chem: [id], Please let Fermis Know!")
	if (purity == 1 || DoNotSplit == TRUE)
		log_game("FERMICHEM: [M] ckey: [M.key] has merged [volume]u of [id] in themselves")
		return
	else if (InverseChemVal > purity)
		M.reagents.remove_reagent(id, amount, FALSE)
		M.reagents.add_reagent(InverseChem, amount, FALSE, other_purity = 1)
		for(var/datum/reagent/fermi/R in M.reagents.reagent_list)
			if(R.name == "")
				R.name = name//Negative effects are hidden
		log_game("FERMICHEM: [M] ckey: [M.key] has merged [volume]u of [InverseChem]")
		return
	else
		var/impureVol = amount * (1 - purity)
		M.reagents.remove_reagent(id, impureVol, FALSE)
		M.reagents.add_reagent(ImpureChem, impureVol, FALSE, other_purity = 1)
		for(var/datum/reagent/fermi/R in M.reagents.reagent_list)
			if(R.name == "")
				R.name = name//Negative effects are hidden
		log_game("FERMICHEM: [M] ckey: [M.key] has merged [volume - impureVol]u of [id]")
		log_game("FERMICHEM: [M] ckey: [M.key] has merged [volume]u of [ImpureChem]")
	return


////////////////////////////////////////////////////////////////////////////////////////////////////
//										HATIMUIM
///////////////////////////////////////////////////////////////////////////////////////////////////
//Adds a heat upon your head, and tips their hat
//Also has a speech alteration effect when the hat is there
//Increase armour; 1 armour per 10u
//but if you OD it becomes negative.


/datum/reagent/fermi/hatmium //for hatterhat
	name = "Hat growth serium"
	id = "hatmium"
	description = "A strange substance that draws in a hat from the hat dimention."
	color = "#7c311a" // rgb: , 0, 255
	taste_description = "like jerky, whiskey and an off aftertaste of a crypt."
	metabolization_rate = 0.2
	overdose_threshold = 25
	DoNotSplit = TRUE
	pH = 4
	can_synth = TRUE


/datum/reagent/fermi/hatmium/on_mob_add(mob/living/carbon/human/M)
	. = ..()
	if(M.head)
		var/obj/item/W = M.head
		if(istype(W, /obj/item/clothing/head/hattip))
			qdel(W)
		else
			M.dropItemToGround(W, TRUE)
	var/hat = new /obj/item/clothing/head/hattip()
	M.equip_to_slot(hat, SLOT_HEAD, 1, 1)


/datum/reagent/fermi/hatmium/on_mob_life(mob/living/carbon/human/M)
	if(!istype(M.head, /obj/item/clothing/head/hattip))
		return ..()
	var/hatArmor = 0
	if(!overdosed)
		hatArmor = (purity/10)
	else
		hatArmor = - (purity/10)
	if(hatArmor > 90)
		return ..()
	var/obj/item/W = M.head
	W.armor = W.armor.modifyAllRatings(hatArmor)
	..()

////////////////////////////////////////////////////////////////////////////////////////////////////
//										FURRANIUM
///////////////////////////////////////////////////////////////////////////////////////////////////
//OwO whats this?
//Makes you nya and awoo
//At a certain amount of time in your system it gives you a fluffy tongue, if pure enough, it's permanent.

/datum/reagent/fermi/furranium
	name = "Furranium"
	id = "furranium"
	description = "OwO whats this?"
	color = "#f9b9bc" // rgb: , 0, 255
	taste_description = "dewicious degenyewacy"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	InverseChemVal 		= 0
	var/obj/item/organ/tongue/nT
	DoNotSplit = TRUE
	pH = 5
	var/obj/item/organ/tongue/T
	can_synth = TRUE

/datum/reagent/fermi/furranium/reaction_mob(mob/living/carbon/human/M, method=INJECT, reac_volume)
	if(method == INJECT)
		var/turf/T = get_turf(M)
		M.adjustOxyLoss(15)
		M.Knockdown(50)
		M.Stun(50)
		M.emote("cough")
		var/obj/item/toy/plush/P = pick(subtypesof(/obj/item/toy/plush))
		new P(T)
		to_chat(M, "<span class='warning'>You feel a lump form in your throat, as you suddenly cough up what seems to be a hairball?</b></span>")
		var/list/seen = viewers(8, T)
		for(var/mob/S in seen)
			to_chat(S, "<span class='warning'>[M] suddenly coughs up a [P.name]!</b></span>")
		var/T2 = get_random_station_turf()
		P.throw_at(T2, 8, 1)
	..()

/datum/reagent/fermi/furranium/on_mob_life(mob/living/carbon/M)

	switch(current_cycle)
		if(1 to 9)
			if(prob(20))
				to_chat(M, "<span class='notice'>Your tongue feels... fluffy</span>")
		if(10 to 15)
			if(prob(10))
				to_chat(M, "You find yourself unable to supress the desire to meow!")
				M.emote("nya")
			if(prob(10))
				to_chat(M, "You find yourself unable to supress the desire to howl!")
				M.emote("awoo")
			if(prob(20))
				var/list/seen = viewers(5, get_turf(M))//Sound and sight checkers
				for(var/victim in seen)
					if((istype(victim, /mob/living/simple_animal/pet/)) || (victim == M) || (!isliving(victim)))
						seen = seen - victim
				if(LAZYLEN(seen))
					to_chat(M, "You notice [pick(seen)]'s bulge [pick("OwO!", "uwu!")]")
		if(16)
			T = M.getorganslot(ORGAN_SLOT_TONGUE)
			var/obj/item/organ/tongue/nT = new /obj/item/organ/tongue/fluffy
			T.Remove(M)
			nT.Insert(M)
			T.moveToNullspace()//To valhalla
			to_chat(M, "<span class='big warning'>Your tongue feels... weally fwuffy!!</span>")
		if(17 to INFINITY)
			if(prob(5))
				to_chat(M, "You find yourself unable to supress the desire to meow!")
				M.emote("nya")
			if(prob(5))
				to_chat(M, "You find yourself unable to supress the desire to howl!")
				M.emote("awoo")
			if(prob(5))
				var/list/seen = viewers(5, get_turf(M))//Sound and sight checkers
				for(var/victim in seen)
					if((istype(victim, /mob/living/simple_animal/pet/)) || (victim == M) || (!isliving(victim)))
						seen = seen - victim
				if(LAZYLEN(seen))
					to_chat(M, "You notice [pick(seen)]'s bulge [pick("OwO!", "uwu!")]")
	..()

/datum/reagent/fermi/furranium/on_mob_delete(mob/living/carbon/M)
	if(purity < 1)//Only permanent if you're a good chemist.
		nT = M.getorganslot(ORGAN_SLOT_TONGUE)
		nT.Remove(M)
		qdel(nT)
		T.Insert(M)
		to_chat(M, "<span class='notice'>You feel your tongue.... unfluffify...?</span>")
		M.say("Pleh!")
	else
		log_game("FERMICHEM: [M] ckey: [M.key]'s tongue has been made permanent")


///////////////////////////////////////////////////////////////////////////////////////////////
//Nanite removal
//Writen by Trilby!! Embellsished a little by me.

/datum/reagent/fermi/nanite_b_gone
	name = "Naninte bane"
	id = "nanite_b_gone"
	description = "A stablised EMP that is highly volatile, shocking small nano machines that will kill them off at a rapid rate in a patient's system."
	color = "#708f8f"
	overdose_threshold = 15
	ImpureChem 			= "nanite_b_goneTox" //If you make an inpure chem, it stalls growth
	InverseChemVal 		= 0.25
	InverseChem 		= "nanite_b_goneTox" //At really impure vols, it just becomes 100% inverse
	taste_description = "what can only be described as licking a battery."
	pH = 9
	can_synth = FALSE

/datum/reagent/fermi/nanite_b_gone/on_mob_life(mob/living/carbon/C)
	//var/component/nanites/N = M.GetComponent(/datum/component/nanites)
	GET_COMPONENT_FROM(N, /datum/component/nanites, C)
	if(isnull(N))
		return ..()
	N.nanite_volume = -purity//0.5 seems to be the default to me, so it'll neuter them.
	..()

/datum/reagent/fermi/nanite_b_gone/overdose_process(mob/living/carbon/C)
	//var/component/nanites/N = M.GetComponent(/datum/component/nanites)
	GET_COMPONENT_FROM(N, /datum/component/nanites, C)
	if(prob(5))
		to_chat(C, "<span class='warning'>The residual voltage from the nanites causes you to seize up!</b></span>")
		C.electrocute_act(10, (get_turf(C)), 1, FALSE, FALSE, FALSE, TRUE)
	if(prob(10))
		//empulse((get_turf(C)), 3, 2)//So the nanites randomize
		var/atom/T = C
		T.emp_act(EMP_HEAVY)
		to_chat(C, "<span class='warning'>The nanites short circuit within your system!</b></span>")
	if(isnull(N))
		return ..()
	N.nanite_volume = -2
	..()

/datum/reagent/fermi/nanite_b_gone/reaction_obj(obj/O, reac_volume)
	O.emp_act(EMP_HEAVY)

/datum/reagent/fermi/nanite_b_goneTox
	name = "Naninte bain"
	id = "nanite_b_goneTox"
	description = "Poorly made, and shocks you!"
	metabolization_rate = 1

//Increases shock events.
/datum/reagent/fermi/nanite_b_goneTox/on_mob_life(mob/living/carbon/C)//Damages the taker if their purity is low. Extended use of impure chemicals will make the original die. (thus can't be spammed unless you've very good)
	if(prob(15))
		to_chat(C, "<span class='warning'>The residual voltage in your system causes you to seize up!</b></span>")
		C.electrocute_act(10, (get_turf(C)), 1, FALSE, FALSE, FALSE, TRUE)
	if(prob(50))
		var/atom/T = C
		T.emp_act(EMP_HEAVY)
		to_chat(C, "<span class='warning'>You feel your hair stand on end as you glow brightly for a moment!</b></span>")
	..()


///////////////////////////////////////////////////////////////////////////////////////////////
//				MISC FERMICHEM CHEMS FOR SPECIFIC INTERACTIONS ONLY
///////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/fermi/fermiAcid
	name = "Acid vapour"
	id = "fermiAcid"
	description = "Someone didn't do like an otter, and add acid to water."
	taste_description = "acid burns, ow"
	color = "#FFFFFF"
	pH = 0
	can_synth = FALSE

/datum/reagent/fermi/fermiAcid/reaction_mob(mob/living/carbon/C, method)
	var/target = C.get_bodypart(BODY_ZONE_CHEST)
	var/acidstr
	if(!C.reagents.pH || C.reagents.pH >5)
		acidstr = 3
	else
		acidstr = ((5-C.reagents.pH)*2) //runtime - null.pH ?
	C.adjustFireLoss(acidstr/2, 0)
	if((method==VAPOR) && (!C.wear_mask))
		if(prob(20))
			to_chat(C, "<span class='warning'>You can feel your lungs burning!</b></span>")
		var/obj/item/organ/lungs/L = C.getorganslot(ORGAN_SLOT_LUNGS)
		L.adjustLungLoss(acidstr*2, C)
		C.apply_damage(acidstr/5, BURN, target)
	C.acid_act(acidstr, volume)
	..()

/datum/reagent/fermi/fermiAcid/reaction_obj(obj/O, reac_volume)
	if(ismob(O.loc)) //handled in human acid_act()
		return
	if((holder.pH > 5) || (volume < 0.1)) //Shouldn't happen, but just in case
		return
	reac_volume = round(volume,0.1)
	var/acidstr = (5-holder.pH)*2 //(max is 10)
	O.acid_act(acidstr, volume)
	..()

/datum/reagent/fermi/fermiAcid/reaction_turf(turf/T, reac_volume)
	if (!istype(T))
		return
	reac_volume = round(volume,0.1)
	var/acidstr = (5-holder.pH)
	T.acid_act(acidstr, volume)
	..()

/datum/reagent/fermi/fermiTest
	name = "Fermis Test Reagent"
	id = "fermiTest"
	description = "You should be really careful with this...! Also, how did you get this?"
	addProc = TRUE
	can_synth = FALSE

/datum/reagent/fermi/fermiTest/on_new(datum/reagents/holder)
	..()
	if(LAZYLEN(holder.reagent_list) == 1)
		return
	else
		holder.remove_reagent("fermiTest", volume)//Avoiding recurrsion
	var/location = get_turf(holder.my_atom)
	if(purity < 0.34 || purity == 1)
		var/datum/effect_system/foam_spread/s = new()
		s.set_up(volume*2, location, holder)
		s.start()
	if((purity < 0.67 && purity >= 0.34)|| purity == 1)
		var/datum/effect_system/smoke_spread/chem/s = new()
		s.set_up(holder, volume*2, location)
		s.start()
	if(purity >= 0.67)
		for (var/datum/reagent/reagent in holder.reagent_list)
			if (istype(reagent, /datum/reagent/fermi))
				var/datum/chemical_reaction/fermi/Ferm  = GLOB.chemical_reagents_list[reagent.id]
				Ferm.FermiExplode(src, holder.my_atom, holder, holder.total_volume, holder.chem_temp, holder.pH)
			else
				var/datum/chemical_reaction/Ferm  = GLOB.chemical_reagents_list[reagent.id]
				Ferm.on_reaction(holder, reagent.volume)
	for(var/mob/M in viewers(8, location))
		to_chat(M, "<span class='danger'>The solution reacts dramatically, with a meow!</span>")
		playsound(get_turf(M), 'modular_citadel/sound/voice/merowr.ogg', 50, 1)
	holder.clear_reagents()

/datum/reagent/fermi/fermiTox
	name = "FermiTox"
	id = "fermiTox"
	description = "You should be really careful with this...! Also, how did you get this? You shouldn't have this!"
	data = "merge"
	color = "FFFFFF"
	can_synth = FALSE

//I'm concerned this is too weak, but I also don't want deathmixes.
/datum/reagent/fermi/fermiTox/on_mob_life(mob/living/carbon/C, method)
	if(C.dna && istype(C.dna.species, /datum/species/jelly))
		C.adjustToxLoss(-2)
	else
		C.adjustToxLoss(2)
	..()

/datum/reagent/fermi/acidic_buffer
	name = "Acidic buffer"
	id = "acidic_buffer"
	description = "This reagent will consume itself and move the pH of a beaker towards acidity when added to another."
	color = "#fbc314"
	pH = 0
	can_synth = TRUE

//Consumes self on addition and shifts pH
/datum/reagent/fermi/acidic_buffer/on_new(datapH)
	data = datapH
	if(LAZYLEN(holder.reagent_list) == 1)
		return
	holder.pH = ((holder.pH * holder.total_volume)+(pH * (volume)))/(holder.total_volume + (volume))
	var/list/seen = viewers(5, get_turf(holder))
	for(var/mob/M in seen)
		to_chat(M, "<span class='warning'>The beaker fizzes as the pH changes!</b></span>")
	playsound(get_turf(holder.my_atom), 'sound/FermiChem/bufferadd.ogg', 50, 1)
	holder.remove_reagent(id, volume, ignore_pH = TRUE)
	..()

/datum/reagent/fermi/basic_buffer
	name = "Basic buffer"
	id = "basic_buffer"
	description = "This reagent will consume itself and move the pH of a beaker towards alkalinity when added to another."
	color = "#3853a4"
	pH = 14
	can_synth = TRUE

/datum/reagent/fermi/basic_buffer/on_new(datapH)
	data = datapH
	if(LAZYLEN(holder.reagent_list) == 1)
		return
	holder.pH = ((holder.pH * holder.total_volume)+(pH * (volume)))/(holder.total_volume + (volume))
	var/list/seen = viewers(5, get_turf(holder))
	for(var/mob/M in seen)
		to_chat(M, "<span class='warning'>The beaker froths as the pH changes!</b></span>")
	playsound(get_turf(holder.my_atom), 'sound/FermiChem/bufferadd.ogg', 50, 1)
	holder.remove_reagent(id, volume, ignore_pH = TRUE)
	..()

//Turns you into a cute catto while it's in your system.
//If you manage to gamble perfectly, makes you have cat ears after you transform back. But really, you shouldn't end up with that with how random it is.
/datum/reagent/fermi/secretcatchem //Should I hide this from code divers? A secret cit chem?
	name = "secretcatchem" //an attempt at hiding it
	id = "secretcatchem"
	description = "An illegal and hidden chem that turns people into cats. It's said that it's so rare and unstable that having it means you've been blessed."
	taste_description = "hairballs and cream"
	color = "#ffc224"
	var/catshift = FALSE
	var/mob/living/simple_animal/pet/cat/custom_cat/catto = null
	can_synth = FALSE

/datum/reagent/fermi/secretcatchem/New()
	name = "Catbalti[pick("a","u","e","y")]m [pick("apex", "prime", "meow")]"//rename

/datum/reagent/fermi/secretcatchem/on_mob_add(mob/living/carbon/human/H)
	. = ..()
	if(purity >= 0.8)//ONLY if purity is high, and given the stuff is random. It's very unlikely to get this to 1. It already requires felind too, so no new functionality there.
		//exception(al) handler:
		H.dna.features["ears"]  = "Cat"
		H.dna.features["mam_ears"] = "Cat"
		H.verb_say = "mewls"
		catshift = TRUE
		playsound(get_turf(H), 'modular_citadel/sound/voice/merowr.ogg', 50, 1, -1)
	to_chat(H, "<span class='notice'>You suddenly turn into a cat!</span>")
	catto = new(get_turf(H.loc))
	H.mind.transfer_to(catto)
	catto.name = H.name
	catto.desc = "A cute catto! They remind you of [H] somehow."
	catto.color = "#[H.dna.features["mcolor"]]"
	catto.pseudo_death = TRUE
	H.forceMove(catto)
	log_game("FERMICHEM: [H] ckey: [H.key] has been made into a cute catto.")
	SSblackbox.record_feedback("tally", "fermi_chem", 1, "cats")
	//Just to deal with rascally ghosts
	//ADD_TRAIT(catto, TRAIT_NODEATH, "catto")//doesn't work
	//catto.health = 1000 //To simulate fake death, while preventing ghosts escaping.

/datum/reagent/fermi/secretcatchem/on_mob_life(mob/living/carbon/H)
	if(catto.health <= 0) //So the dead can't ghost
		if(prob(10))
			to_chat(H, "<span class='notice'>You feel your body start to slowly shift back from it's dead form.</span>")
	else if(prob(5))
		playsound(get_turf(catto), 'modular_citadel/sound/voice/merowr.ogg', 50, 1, -1)
		catto.say("lets out a meowrowr!*")
	..()

/datum/reagent/fermi/secretcatchem/on_mob_delete(mob/living/carbon/H)
	var/words = "Your body shifts back to normal."
	H.forceMove(catto.loc)
	catto.mind.transfer_to(H)
	if(catshift == TRUE)
		words += " ...But wait, are those cat ears?"
		H.say("*wag")//force update sprites.
	to_chat(H, "<span class='notice'>[words]</span>")
	qdel(catto)
	log_game("FERMICHEM: [H] ckey: [H.key] has returned to normal")
