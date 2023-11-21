GLOBAL_LIST_INIT(infected_contact_mobs, list())

/datum/disease
	//the disease's antigens, that the body's immune_system will read to produce corresponding antibodies. Without antigens, a disease cannot be cured.
	var/list/antigen = list()
	///can we spread
	var/spread = FALSE
	//alters a pathogen's propensity to mutate. Set to FALSE to forbid a pathogen from ever mutating.
	var/mutation_modifier = TRUE
	//the antibody concentration at which the disease will fully exit the body
	var/strength = 100
	//the percentage of the strength at which effects will start getting disabled by antibodies.
	var/robustness = 100
	//chance to cure the disease at every proc when the body is getting cooked alive.
	var/max_bodytemperature = 1000
	//very low temperatures will stop the disease from activating/progressing
	var/min_bodytemperature = 120

	//logging
	var/log = ""
	var/origin = "Unknown"
	var/logged_virusfood = FALSE
	var/fever_warning = FALSE

	//cosmetic
	var/color
	var/pattern = 1
	var/pattern_color

	///pathogenic warfare - If you have a second disease of a form name in the list they will start fighting.
	var/list/can_kill = list("Bacteria")

	//When an opportunity for the disease to spread to a mob arrives, runs this percentage through prob()
	//Ignored if infected materials are ingested (injected with infected blood, eating infected meat)
	var/infectionchance = 70
	var/infectionchance_base = 70

	//ticks increases by [speed] every time the disease activates. Drinking Virus Food also accelerates the process by 10.
	var/ticks = 0
	var/speed = 1

	//when spreading to another mob, that new carrier has the disease's stage reduced by stage_variance
	var/stage_variance = -1

	var/uniqueID = 0// 0000 to 9999, set when the pathogen gets initially created
	var/subID = 0// 000 to 9999, set if the pathogen underwent effect or antigen mutation
	var/childID = 0// 01 to 99, incremented as the pathogen gets analyzed after a mutation


/proc/filter_disease_by_spread(list/diseases, required = NONE)
	if(!length(diseases))
		return list()

	var/list/viable = list()
	for(var/datum/disease/disease as anything in diseases)
		if(!(disease.spread_flags & required))
			continue
		viable += disease
	return viable

/datum/disease/proc/AddToGoggleView(mob/living/infectedMob)
	if (spread & SPREAD_CONTACT)
		GLOB.infected_contact_mobs |= infectedMob
		if (!infectedMob.pathogen)
			infectedMob.pathogen = image('monkestation/code/modules/virology/icons/effects.dmi',infectedMob,"pathogen_contact")
			infectedMob.pathogen.plane = HUD_PLANE
			infectedMob.pathogen.appearance_flags = RESET_COLOR|RESET_ALPHA
		for (var/mob/living/L in GLOB.science_goggles_wearers)
			if (L.client)
				L.client.images |= infectedMob.pathogen

/datum/disease/proc/incubate(atom/incubator, mutatechance=1)
	mutatechance *= mutation_modifier

	var/mob/living/body = null
	var/obj/item/weapon/virusdish/dish = null
	var/obj/machinery/disease2/incubator/machine = null

	if (isliving(incubator))
		body = incubator
	else if (istype(incubator,/obj/item/weapon/virusdish))
		dish = incubator
		if (istype(dish.loc,/obj/machinery/disease2/incubator))
			machine = dish.loc

	if (mutatechance > 0 && (body || dish) && incubator.reagents)
		if (incubator.reagents.has_reagent(/datum/reagent/toxin/mutagen,  0.5) && incubator.reagents.has_reagent(/datum/reagent/consumable/nutriment/protein,0.5))
			if(!incubator.reagents.remove_reagent(/datum/reagent/toxin/mutagen, 0.5) && !incubator.reagents.remove_reagent(/datum/reagent/consumable/nutriment/protein,0.5))
				log += "<br />[ROUND_TIME()] Robustness Strengthening (Mutagen and Protein in [incubator])"
				var/change = rand(1,5)
				robustness = min(100,robustness + change)
				for(var/datum/symptom/e in symptoms)
					e.multiplier_tweak(0.1)
					minormutate()
				if (dish)
					if (machine)
						machine.update_minor(dish,0,change,0.1)
		else if (incubator.reagents.has_reagent(/datum/reagent/toxin/mutagen, 0.5) && incubator.reagents.has_reagent(/datum/reagent/medicine/spaceacillin,0.5))
			if(!incubator.reagents.remove_reagent(/datum/reagent/toxin/mutagen, 0.5) && !incubator.reagents.remove_reagent(/datum/reagent/medicine/spaceacillin,0.5))
				log += "<br />[ROUND_TIME()] Robustness Weakening (Mutagen and spaceacillin in [incubator])"
				var/change = rand(1,5)
				robustness = max(0,robustness - change)
				for(var/datum/symptom/e in symptoms)
					e.multiplier_tweak(-0.1)
					minormutate()
				if (dish)
					if (machine)
						machine.update_minor(dish,0,-change,-0.1)
		else
			if(!incubator.reagents.remove_reagent(/datum/reagent/toxin/mutagen, 0.05) && prob(mutatechance))
				log += "<br />[ROUND_TIME()] Effect Mutation (Mutagen in [incubator])"
				effectmutate(body != null)
				if (dish)
					if(dish.info && dish.analysed)
						dish.info = "OUTDATED : [dish.info]"
						dish.analysed = 0
					dish.update_icon()
					if (machine)
						machine.update_major(dish)
			if(!incubator.reagents.remove_reagent(/datum/reagent/consumable/nutriment/protein,0.05) && prob(mutatechance))
				log += "<br />[ROUND_TIME()] Strengthening (/datum/reagent/consumable/nutriment/protein in [incubator])"
				var/change = rand(1,5)
				strength = min(100,strength + change)
				if (dish)
					if (machine)
						machine.update_minor(dish,change)
			if(!incubator.reagents.remove_reagent(/datum/reagent/medicine/spaceacillin,0.05) && prob(mutatechance))
				log += "<br />[ROUND_TIME()] Weakening (/datum/reagent/medicine/spaceacillin in [incubator])"
				var/change = rand(1,5)
				strength = max(0,strength - change)
				if (dish)
					if (machine)
						machine.update_minor(dish,-change)
		if(!incubator.reagents.remove_reagent(/datum/reagent/uranium/radium,0.02) && prob(mutatechance/8))
			log += "<br />[ROUND_TIME()] Antigen Mutation (Radium in [incubator])"
			antigenmutate()
			if (dish)
				if(dish.info && dish.analysed)
					dish.info = "OUTDATED : [dish.info]"
					dish.analysed = 0
				if (machine)
					machine.update_major(dish)

/datum/disease/proc/makerandom(var/list/str = list(), var/list/rob = list(), var/list/anti = list(), var/list/bad = list(), var/atom/source = null)
	//ID
	uniqueID = rand(0,9999)
	subID = rand(0,9999)

	//base stats
	strength = rand(str[1],str[2])
	robustness = rand(rob[1],rob[2])
	roll_antigen(anti)

	//effects
	for(var/i = 1; i <= max_stages; i++)
		var/selected_badness = pick(
			bad[EFFECT_DANGER_HELPFUL];EFFECT_DANGER_HELPFUL,
			bad[EFFECT_DANGER_FLAVOR];EFFECT_DANGER_FLAVOR,
			bad[EFFECT_DANGER_ANNOYING];EFFECT_DANGER_ANNOYING,
			bad[EFFECT_DANGER_HINDRANCE];EFFECT_DANGER_HINDRANCE,
			bad[EFFECT_DANGER_HARMFUL];EFFECT_DANGER_HARMFUL,
			bad[EFFECT_DANGER_DEADLY];EFFECT_DANGER_DEADLY,
			)
		var/datum/symptom/e = new_effect(text2num(selected_badness), i)
		symptoms += e
		log += "<br />[ROUND_TIME()] Added effect [e.name] ([e.chance]% Occurence)."

	//slightly randomized infection chance
	var/variance = initial(infectionchance)/10
	infectionchance = rand(initial(infectionchance)-variance,initial(infectionchance)+variance)
	infectionchance_base = infectionchance

	//cosmetic petri dish stuff - if set beforehand, will not be randomized
	if (!color)
		var/list/randomhexes = list("8","9","a","b","c","d","e")
		color = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"
		pattern = rand(1,6)
		pattern_color = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"

	//spreading vectors - if set beforehand, will not be randomized
	if (!spread)
		randomize_spread()

	//logging
	log += "<br />[ROUND_TIME()] Created and Randomized<br>"

	//admin panel
	if (origin == "Unknown")
		if (istype(source,/obj/item/weapon/virusdish))
			if (isturf(source.loc))
				var/turf/T = source.loc
				if (istype(T.loc,/area/centcom))
					origin = "Centcom"
				else if (istype(T.loc,/area/station/medical/virology))
					origin = "Virology"

/datum/disease/proc/new_effect(var/badness = 2, var/stage = 0)
	var/list/datum/symptom/list = list()
	var/list/to_choose = subtypesof(/datum/symptom)
	for(var/e in to_choose)
		var/datum/symptom/f = new e
		if(!f.restricted && f.stage == stage && text2num(f.badness) == badness)
			list += f
	if (list.len <= 0)
		return new_random_effect(badness+1,badness-1,stage)
	else
		var/datum/symptom/e = pick(list)
		e.chance = rand(1, e.max_chance)
		return e

/datum/disease/proc/new_random_effect(var/max_badness = 5, var/min_badness = 0, var/stage = 0, var/old_effect)
	var/list/datum/symptom/list = list()
	var/list/to_choose = subtypesof(/datum/symptom)
	if(old_effect) //So it doesn't just evolve right back into the previous virus type
		to_choose.Remove(old_effect)
	for(var/e in to_choose)
		var/datum/symptom/f = new e
		if(!f.restricted && f.stage == stage && text2num(f.badness) <= max_badness && text2num(f.badness) >= min_badness)
			list += f
	if (list.len <= 0)
		return new_random_effect(min(max_badness+1,5),max(0,min_badness-1),stage)
	else
		var/datum/symptom/e = pick(list)
		e.chance = rand(1, e.max_chance)
		return e

/datum/disease/proc/randomize_spread()
	spread = SPREAD_BLOOD	//without blood spread, the disease cannot be extracted or cured, we don't want that for regular diseases
	if (prob(5))			//5% chance of spreading through both contact and the air.
		spread |= SPREAD_CONTACT
		spread |= SPREAD_AIRBORNE
	else if (prob(40))		//38% chance of spreading through the air only.
		spread |= SPREAD_AIRBORNE
	else if (prob(60))		//34,2% chance of spreading through contact only.
		spread |= SPREAD_CONTACT
							//22,8% chance of staying in blood

/datum/disease/proc/minormutate(index)
	var/datum/symptom/e = get_effect(index)
	e.minormutate()
	infectionchance = min(50,infectionchance + rand(0,10))
	log += "<br />[ROUND_TIME()] Infection chance now [infectionchance]%"

/datum/disease/proc/get_effect(index)
	if(!index)
		return pick(symptoms)
	return symptoms[clamp(index,0,symptoms.len)]

//Major Mutations
/datum/disease/proc/effectmutate(var/inBody=FALSE)
	subID = rand(0,9999)
	var/list/randomhexes = list("7","8","9","a","b","c","d","e")
	var/colormix = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"
	color = BlendRGB(color,colormix,0.25)
	var/i = rand(1, symptoms.len)
	var/datum/symptom/e = symptoms[i]
	var/datum/symptom/f
	if (inBody)//mutations that occur directly in a body don't cause helpful symptoms to become deadly instantly.
		f = new_random_effect(min(5,text2num(e.badness)+1), max(0,text2num(e.badness)-1), e.stage, e.type)
	else
		f = new_random_effect(min(5,text2num(e.badness)+2), max(0,text2num(e.badness)-3), e.stage, e.type)//badness is slightly more likely to go down than up.
	symptoms[i] = f
	log += "<br />[ROUND_TIME()] Mutated effect [e.name] [e.chance]% into [f.name] [f.chance]%."

/datum/disease/proc/antigenmutate()
	subID = rand(0,9999)
	var/old_dat = get_antigen_string()
	roll_antigen()
	log += "<br />[ROUND_TIME()] Mutated antigen [old_dat] into [get_antigen_string()]."

/datum/disease/proc/get_antigen_string()
	var/dat = ""
	for (var/A in antigen)
		dat += "[A]"
	return dat

/datum/disease/proc/roll_antigen(list/factors = list())
	if (factors.len <= 0)
		antigen = list(pick(GLOB.all_antigens))
		antigen |= pick(GLOB.all_antigens)
	else
		var/selected_first_antigen = pick(
			factors[ANTIGEN_BLOOD];ANTIGEN_BLOOD,
			factors[ANTIGEN_COMMON];ANTIGEN_COMMON,
			factors[ANTIGEN_RARE];ANTIGEN_RARE,
			factors[ANTIGEN_ALIEN];ANTIGEN_ALIEN,
			)

		antigen = list(pick(antigen_family(selected_first_antigen)))

		var/selected_second_antigen = pick(
			factors[ANTIGEN_BLOOD];ANTIGEN_BLOOD,
			factors[ANTIGEN_COMMON];ANTIGEN_COMMON,
			factors[ANTIGEN_RARE];ANTIGEN_RARE,
			factors[ANTIGEN_ALIEN];ANTIGEN_ALIEN,
			)

		antigen |= pick(antigen_family(selected_second_antigen))


/datum/disease/proc/activate(mob/living/mob,var/starved = FALSE)
	if(mob.stat == DEAD)
		return

	//Searing body temperatures cure diseases, on top of killing you.
	if(mob.bodytemperature > max_bodytemperature)
		cure(mob,1)
		return

	if(!mob.immune_system.CanInfect(src))
		cure(mob)
		return

	//Freezing body temperatures halt diseases completely
	if(mob.bodytemperature < min_bodytemperature)
		return

/proc/virus_copylist(list/list)
	if(!length(list))
		return list()
	var/list/L = list()
	for(var/datum/disease/D as anything in list)
		L += D.Copy()
	return L

/datum/disease/proc/cure(var/mob/living/carbon/mob,var/condition=0)
	/* TODO
	switch (condition)
		if (0)
			log_debug("[form] [uniqueID]-[subID] in [key_name(mob)] has been cured, and is being removed from their body.")
		if (1)
			log_debug("[form] [uniqueID]-[subID] in [key_name(mob)] has died from extreme temperature inside their host, and is being removed from their body.")
		if (2)
			log_debug("[form] [uniqueID]-[subID] in [key_name(mob)] has been wiped out by an immunity overload.")
	*/
	for(var/datum/symptom/e in symptoms)
		e.End(src)
	mob.diseases -= src
	//--Plague Stuff--
	/*
	var/datum/faction/plague_mice/plague = find_active_faction_by_type(/datum/faction/plague_mice)
	if (plague && ("[uniqueID]-[subID]" == plague.diseaseID))
		plague.update_hud_icons()
	*/
	//----------------
	var/list/V = filter_disease_by_spread(mob.diseases, required = SPREAD_CONTACT)
	if (V && V.len <= 0)
		GLOB.infected_contact_mobs -= mob
		if (mob.pathogen)
			for (var/mob/living/L in GLOB.science_goggles_wearers)
				if (L.client)
					L.client.images -= mob.pathogen
