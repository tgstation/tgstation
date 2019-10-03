 //Fermichem!!
//Fun chems for all the family

/datum/reagent/fermi
	name = "Fermi" //This should never exist, but it does so that it can exist in the case of errors..
	taste_description	= "affection and love!"
	can_synth = FALSE
	var/purity
	var/addProc
	var/ImpureChem = /datum/reagent/fermi
	var/InverseChemVal = 0.2 //purity sat which it flips
	var/InverseChem = /datum/reagent/fermi
	var/DoNotSplit = FALSE

//This should process fermichems to find out how pure they are and what effect to do.
/datum/reagent/fermi/on_mob_add(mob/living/carbon/M, amount)
	. = ..()
	if(!M)
		return
	if(purity < 0)
		CRASH("Purity below 0 for chem : [type], yell at coders")
	if (purity == 1 || DoNotSplit == TRUE)
		log_game("FERMICHEM: [M] ckey: [M.key] has ingested [volume]u of [type]")
		return
	else if (InverseChemVal > purity)//Turns all of a added reagent into the inverse chem
		M.reagents.remove_reagent(type, amount, FALSE)
		M.reagents.add_reagent(InverseChem, amount, FALSE, other_purity = 1)
		log_game("FERMICHEM: [M] ckey: [M.key] has ingested [volume]u of [InverseChem]")
		return
	else
		var/impureVol = amount * (1 - purity) //turns impure ratio into impure chem
		M.reagents.remove_reagent(type, (impureVol), FALSE)
		M.reagents.add_reagent(ImpureChem, impureVol, FALSE, other_purity = 1)
		log_game("FERMICHEM: [M] ckey: [M.key] has ingested [volume - impureVol]u of [type]")
		log_game("FERMICHEM: [M] ckey: [M.key] has ingested [volume]u of [ImpureChem]")
	return


///////////////////////////////////////////////////////////////////////////////////////////////
//				MISC FERMICHEM CHEMS FOR SPECIFIC INTERACTIONS ONLY
///////////////////////////////////////////////////////////////////////////////////////////////

/datum/reagent/fermi/fermiAcid
	name = "Acid vapour"
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
	C.adjustFireLoss(acidstr/2,0)
	if((method==VAPOR) && (!C.wear_mask))
		if(prob(20))
			to_chat(C, "<span class='warning'>You can feel an intense burning sensation in your lungs!</b></span>")
		C.adjustOrganLoss(ORGAN_SLOT_LUNGS, -2)
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
/* idk what this does so commented out lol - it was causing errors
what the fuck is holder anyways
/datum/reagent/fermi/fermiTest
	name = "Fermis Test Reagent"
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
				var/datum/chemical_reaction/fermi/Ferm  = GLOB.chemical_reagents_list[reagent.type]
				Ferm.FermiExplode(src, holder.my_atom, holder, holder.total_volume, holder.chem_temp, holder.pH)
			else
				var/datum/chemical_reaction/Ferm  = GLOB.chemical_reagents_list[reagent.type]
				Ferm.on_reaction(holder, reagent.volume)
	holder.clear_reagents()
*/
/datum/reagent/fermi/fermiTox
	name = "FermiTox"
	description = "You should be really careful with this...! Also, how did you get this? You shouldn't have this!"
	data = "merge"
	color = "FFFFFF"
	can_synth = FALSE

//I'm concerned this is too weak, but I also don't want deathmixes.
/datum/reagent/fermi/fermiTox/on_mob_life(mob/living/carbon/C, method)
		C.adjustToxLoss(2)
		..()

/datum/reagent/fermi/acidic_buffer
	name = "Acidic buffer"
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
	holder.remove_reagent(type, volume, ignore_pH = TRUE)
	..()

/datum/reagent/fermi/basic_buffer
	name = "Basic buffer"
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
	holder.remove_reagent(type, volume, ignore_pH = TRUE)
	..()
