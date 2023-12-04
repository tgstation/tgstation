GLOBAL_LIST_INIT(infected_contact_mobs, list())
GLOBAL_LIST_INIT(virusDB, list())

/datum/disease
	//the disease's antigens, that the body's immune_system will read to produce corresponding antibodies. Without antigens, a disease cannot be cured.
	var/list/antigen = list()
	///can we spread
	var/spread = TRUE
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

	var/stageprob = 25

	//when spreading to another mob, that new carrier has the disease's stage reduced by stage_variance
	var/stage_variance = -1

	var/uniqueID = 0// 0000 to 9999, set when the pathogen gets initially created
	var/subID = 0// 000 to 9999, set if the pathogen underwent effect or antigen mutation
	var/childID = 0// 01 to 99, incremented as the pathogen gets analyzed after a mutation


/proc/filter_disease_by_spread(list/diseases, required = NONE)
	if(!length(diseases))
		return list()

	var/list/viable = list()
	for(var/datum/disease/advanced/disease as anything in diseases)
		if(!(disease.spread_flags & required))
			continue
		viable += disease
	return viable

/datum/disease/advanced/proc/AddToGoggleView(mob/living/infectedMob)
	if (spread_flags & DISEASE_SPREAD_CONTACT_SKIN)
		GLOB.infected_contact_mobs |= infectedMob
		if (!infectedMob.pathogen)
			infectedMob.pathogen = image('monkestation/code/modules/virology/icons/effects.dmi',infectedMob,"pathogen_contact")
			infectedMob.pathogen.plane = HUD_PLANE
			infectedMob.pathogen.appearance_flags = RESET_COLOR|RESET_ALPHA
		for (var/mob/living/L in GLOB.science_goggles_wearers)
			if (L.client)
				L.client.images |= infectedMob.pathogen

/datum/disease/advanced/proc/incubate(atom/incubator, mutatechance=1)
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
		else if (incubator.reagents.has_reagent(/datum/reagent/toxin/mutagen, 0.5) && incubator.reagents.has_reagent(/datum/reagent/medicine/antipathogenic/spaceacillin,0.5))
			if(!incubator.reagents.remove_reagent(/datum/reagent/toxin/mutagen, 0.5) && !incubator.reagents.remove_reagent(/datum/reagent/medicine/antipathogenic/spaceacillin,0.5))
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
			if(!incubator.reagents.remove_reagent(/datum/reagent/medicine/antipathogenic/spaceacillin,0.05) && prob(mutatechance))
				log += "<br />[ROUND_TIME()] Weakening (/datum/reagent/medicine/antipathogenic/spaceacillin in [incubator])"
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

/datum/disease/advanced/proc/makerandom(var/list/str = list(), var/list/rob = list(), var/list/anti = list(), var/list/bad = list(), var/atom/source = null)
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

/datum/disease/advanced/proc/new_effect(badness = 2, stage = 0)
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

/datum/disease/advanced/proc/new_random_effect(var/max_badness = 5, var/min_badness = 0, var/stage = 0, var/old_effect)
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

/datum/disease/advanced/proc/randomize_spread()
	spread = DISEASE_SPREAD_BLOOD	//without blood spread, the disease cannot be extracted or cured, we don't want that for regular diseases
	if (prob(5))			//5% chance of spreading through both contact and the air.
		spread |= DISEASE_SPREAD_CONTACT_SKIN
		spread |= DISEASE_SPREAD_AIRBORNE
	else if (prob(40))		//38% chance of spreading through the air only.
		spread |= DISEASE_SPREAD_AIRBORNE
	else if (prob(60))		//34,2% chance of spreading through contact only.
		spread |= DISEASE_SPREAD_CONTACT_SKIN
							//22,8% chance of staying in blood

/datum/disease/advanced/proc/minormutate(index)
	var/datum/symptom/e = get_effect(index)
	e.minormutate()
	infectionchance = min(50,infectionchance + rand(0,10))
	log += "<br />[ROUND_TIME()] Infection chance now [infectionchance]%"

/datum/disease/advanced/proc/minorstrength(index)
	var/datum/symptom/e = get_effect(index)
	e.multiplier_tweak(0.1)

/datum/disease/advanced/proc/minorweak(index)
	var/datum/symptom/e = get_effect(index)
	e.multiplier_tweak(-0.1)

/datum/disease/advanced/proc/get_effect(index)
	if(!index)
		return pick(symptoms)
	return symptoms[clamp(index,0,symptoms.len)]

//Major Mutations
/datum/disease/advanced/proc/effectmutate(var/inBody=FALSE)
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

/datum/disease/advanced/proc/antigenmutate()
	subID = rand(0,9999)
	var/old_dat = get_antigen_string()
	roll_antigen()
	log += "<br />[ROUND_TIME()] Mutated antigen [old_dat] into [get_antigen_string()]."

/datum/disease/advanced/proc/get_antigen_string()
	var/dat = ""
	for (var/A in antigen)
		dat += "[A]"
	return dat

/datum/disease/advanced/proc/roll_antigen(list/factors = list())
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


/datum/disease/advanced/proc/activate(mob/living/mob, starved = FALSE, seconds_per_tick)
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
	//Virus food speeds up disease progress
	if(mob.reagents.has_reagent(/datum/reagent/consumable/virus_food))
		mob.reagents.remove_reagent(/datum/reagent/consumable/virus_food, 0.1)
		if(!logged_virusfood)
			log += "<br />[ROUND_TIME()] Virus Fed ([mob.reagents.get_reagent_amount(/datum/reagent/consumable/virus_food)]U)"
			logged_virusfood=1
		ticks += 10
	else
		logged_virusfood=0
	if(prob(strength * 0.1))
		incubate(mob, 1)
	//Moving to the next stage
	if(ticks > stage*100 && prob(stageprob))
		incubate(mob, 1)
		if(stage < max_stages)
			log += "<br />[ROUND_TIME()] NEXT STAGE ([stage])"
			stage++
		ticks = 0

	//Pathogen killing each others
	for (var/datum/disease/advanced/enemy_pathogen as anything in mob.diseases)
		if(enemy_pathogen == src)
			continue

		if ((enemy_pathogen.form in can_kill) && strength > enemy_pathogen.strength)
			log += "<br />[ROUND_TIME()] destroyed enemy [enemy_pathogen.form] #[enemy_pathogen.uniqueID]-[enemy_pathogen.subID] ([strength] > [enemy_pathogen.strength])"
			enemy_pathogen.cure(mob)

	// This makes it so that <mob> only ever gets affected by the equivalent of one virus so antags don't just stack a bunch
	if(starved)
		return

	var/list/immune_data = GetImmuneData(mob)

	for(var/datum/symptom/e in symptoms)
		if (e.can_run_effect(immune_data[1]), seconds_per_tick = seconds_per_tick)
			e.run_effect(mob, seconds_per_tick)

	//fever is a reaction of the body's immune system to the infection. The higher the antibody concentration (and the disease still not cured), the higher the fever
	if (mob.bodytemperature < BODYTEMP_HEAT_DAMAGE_LIMIT)//but we won't go all the way to burning up just because of a fever, probably
		var/fever = round((robustness / 100) * (immune_data[2] / 10) * (stage / max_stages))
		switch (mob.mob_size)
			if (MOB_SIZE_TINY)
				mob.bodytemperature += fever*0.2
			if (MOB_SIZE_SMALL)
				mob.bodytemperature += fever*0.5
			if (MOB_SIZE_HUMAN)
				mob.bodytemperature += fever
			if (MOB_SIZE_LARGE)
				mob.bodytemperature += fever*1.5
			if (MOB_SIZE_HUGE)
				mob.bodytemperature += fever*2

		if (fever > 0  && prob(3))
			switch (fever_warning)
				if (0)
					to_chat(mob, "<span class='warning'>You feel a fever coming on, your body warms up and your head hurts a bit.</span>")
					fever_warning++
				if (1)
					if (mob.bodytemperature > 320)
						to_chat(mob, "<span class='warning'>Your palms are sweaty.</span>")
						fever_warning++
				if (2)
					if (mob.bodytemperature > 335)
						to_chat(mob, "<span class='warning'>Your knees are weak.</span>")
						fever_warning++
				if (3)
					if (mob.bodytemperature > 350)
						to_chat(mob, "<span class='warning'>Your arms are heavy.</span>")
						fever_warning++


	ticks += speed

/proc/virus_copylist(list/list)
	if(!length(list))
		return list()
	var/list/L = list()
	for(var/datum/disease/advanced/D as anything in list)
		L += D.Copy()
	return L

/datum/disease/advanced/cure(var/mob/living/carbon/mob,var/condition=0)
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
	var/list/V = filter_disease_by_spread(mob.diseases, required = DISEASE_SPREAD_CONTACT_SKIN)
	if (V && V.len <= 0)
		GLOB.infected_contact_mobs -= mob
		if (mob.pathogen)
			for (var/mob/living/L in GLOB.science_goggles_wearers)
				if (L.client)
					L.client.images -= mob.pathogen


/datum/disease/advanced/proc/GetImmuneData(mob/living/mob)
	var/lowest_stage = stage
	var/highest_concentration = 0

	if (mob.immune_system)
		var/immune_system = mob.immune_system.GetImmunity()
		var/immune_str = immune_system[1]
		var/list/antibodies = immune_system[2]
		var/subdivision = (strength - ((robustness * strength) / 100)) / max_stages
		//for each antigen, we measure the corresponding antibody concentration in the carrier's immune system
		//the less robust the pathogen, the more likely that further stages' effects won't activate at a given concentration
		for (var/A in antigen)
			var/concentration = immune_str * antibodies[A]
			highest_concentration = max(highest_concentration,concentration)
			var/i = lowest_stage
			while (i > 0)
				if (concentration > (strength - i * subdivision))
					lowest_stage = i-1
				i--

	return list(lowest_stage,highest_concentration)

/datum/disease/advanced/proc/name(var/override=FALSE)
	.= "[form] #["[uniqueID]"][childID ? "-["[childID]"]" : ""]"
	
	if (!override && ("[uniqueID]-[subID]" in GLOB.virusDB))
		var/datum/data/record/V = GLOB.virusDB["[uniqueID]-[subID]"]
		.= V.fields["name"]
	
/datum/disease/advanced/proc/real_name()
	.= "[form] #["[uniqueID]"]-["[subID]"]"
	if ("[uniqueID]-[subID]" in GLOB.virusDB)
		var/datum/data/record/v = GLOB.virusDB["[uniqueID]-[subID]"]
		var/nickname = v.fields["nickname"] ? " \"[v.fields["nickname"]]\"" : ""
		. += nickname

/datum/disease/advanced/proc/get_subdivisions_string()
	var/subdivision = (strength - ((robustness * strength) / 100)) / max_stages
	var/dat = "("
	for (var/i = 1 to max_stages)
		dat += "[round(strength - i * subdivision)]"
		if (i < max_stages)
			dat += ", "
	dat += ")"
	return dat

/datum/disease/advanced/proc/get_info()
	var/r = "GNAv3 [name()]"
	r += "<BR>Strength / Robustness : <b>[strength]% / [robustness]%</b> - [get_subdivisions_string()]"
	r += "<BR>Infectability : <b>[infectionchance]%</b>"
	r += "<BR>Spread forms : <b>[get_spread_string()]</b>"
	r += "<BR>Progress Speed : <b>[stageprob]%</b>"
	r += "<dl>"
	for(var/datum/symptom/e in symptoms)
		r += "<dt> &#x25CF; <b>Stage [e.stage] - [e.name]</b> (Danger: [e.badness]). Strength: <b>[e.multiplier]</b>. Occurrence: <b>[e.chance]%</b>.</dt>"
		r += "<dd>[e.desc]</dd>"
	r += "</dl>"
	r += "<BR>Antigen pattern: [get_antigen_string()]"
	r += "<BR><i>last analyzed at: [worldtime2text()]</i>"
	return r

/datum/disease/advanced/proc/get_spread_string()
	var/dat = ""
	var/check = 0
	if (spread_flags & DISEASE_SPREAD_BLOOD)
		dat += "Blood"
		check += DISEASE_SPREAD_BLOOD
		if (spread_flags > check)
			dat += ", "
	if (spread_flags & DISEASE_SPREAD_CONTACT_SKIN)
		dat += "Skin Contact"
		check += DISEASE_SPREAD_CONTACT_SKIN
		if (spread_flags > check)
			dat += ", "
	if (spread_flags & DISEASE_SPREAD_AIRBORNE)
		dat += "Airborne"
		check += DISEASE_SPREAD_AIRBORNE
		if (spread_flags > check)
			dat += ", "
	if (spread_flags & DISEASE_SPREAD_CONTACT_FLUIDS)
		dat += "Fluid Contact"
		check += DISEASE_SPREAD_CONTACT_FLUIDS
		if(spread > check)
			dat += ", "
	if (spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS)
		dat += "Non Contagious"
		check += DISEASE_SPREAD_NON_CONTAGIOUS
		if(spread_flags > check)
			dat += ", "
	if (spread_flags & DISEASE_SPREAD_SPECIAL)
		dat += "UNKNOWN SPREAD"
		check += DISEASE_SPREAD_SPECIAL
		if(spread_flags > check)
			dat += ", "
	/*
	if (spread_flags & SPREAD_COLONY)
		dat += "Colonizing"
		check += SPREAD_COLONY
		if (spread_flags > check)
			dat += ", "
	if (spread_flags & SPREAD_MEMETIC)
		dat += "Memetic"
		check += SPREAD_MEMETIC
		if (spread_flags > check)
			dat += ", "
	*/
	return dat

/datum/disease/advanced/proc/addToDB()
	if ("[uniqueID]-[subID]" in GLOB.virusDB)
		return 0
	childID = 0
	for (var/virus_file in GLOB.virusDB)
		var/datum/data/record/v = GLOB.virusDB[virus_file]
		if (v.fields["id"] == uniqueID)
			childID++
	var/datum/data/record/v = new()
	v.fields["id"] = uniqueID
	v.fields["sub"] = subID
	v.fields["child"] = childID
	v.fields["form"] = form
	v.fields["name"] = name()
	v.fields["nickname"] = ""
	v.fields["description"] = get_info()
	v.fields["description_hidden"] = get_info(TRUE)
	v.fields["custom_desc"] = "No comments yet."
	v.fields["antigen"] = get_antigen_string()
	v.fields["spread type"] = get_spread_string()
	v.fields["danger"] = "Undetermined"
	GLOB.virusDB["[uniqueID]-[subID]"] = v
	return 1

/datum/disease/advanced/virus
	form = "Virus"
	max_stages = 4
	infectionchance = 70
	infectionchance_base = 70
	stageprob = 10
	stage_variance = -1
	can_kill = list("Bacteria")

/datum/disease/advanced/bacteria//faster spread and progression, but only 3 stages max, and reset to stage 1 on every spread
	form = "Bacteria"
	max_stages = 3
	infectionchance = 90
	infectionchance_base = 90
	stageprob = 30
	stage_variance = -4
	can_kill = list("Parasite")

/datum/disease/advanced/parasite//slower spread. stage preserved on spread
	form = "Parasite"
	infectionchance = 50
	infectionchance_base = 50
	stageprob = 10
	stage_variance = 0
	can_kill = list("Virus")

/datum/disease/advanced/prion//very fast progression, but very slow spread and resets to stage 1.
	form = "Prion"
	infectionchance = 10
	infectionchance_base = 10
	stageprob = 80
	stage_variance = -10
	can_kill = list()
