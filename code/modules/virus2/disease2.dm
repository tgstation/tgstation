/datum/disease2/disease
	var/infectionchance = 70
	var/speed = 1
	var/spreadtype = "Contact" // Can also be "Airborne"
	var/stage = 1
	var/stageprob = 10
	var/dead = 0
	var/clicks = 0
	var/uniqueID = 0
	var/list/datum/disease2/effectholder/effects = list()
	var/antigen = 0 // 16 bits describing the antigens, when one bit is set, a cure with that bit can dock here
	var/max_stage = 4

	var/log = ""
	var/logged_virusfood=0

/datum/disease2/disease/New(var/notes="No notes.")
	uniqueID = rand(0,10000)
	log += "<br />[timestamp()] CREATED - [notes]<br>"
	..()

/datum/disease2/disease/proc/makerandom(var/greater=0)
	for(var/i=1 ; i <= max_stage ; i++ )
		var/datum/disease2/effectholder/holder = new /datum/disease2/effectholder(src)
		holder.stage = i
		if(greater)
			holder.getrandomeffect(2)
		else
			holder.getrandomeffect()
		effects += holder
	uniqueID = rand(0,10000)
	infectionchance = rand(60,90)
	antigen |= text2num(pick(ANTIGENS))
	antigen |= text2num(pick(ANTIGENS))
	spreadtype = prob(70) ? "Airborne" : "Contact"

/proc/virus2_make_custom(client/C)
	if(!C.holder || !istype(C))
		return 0
	if(!(C.holder.rights & R_DEBUG))
		return 0
	var/mob/living/carbon/infectedMob = input(C, "Select person to infect", "Infect Person") in (player_list) // get the selected mob
	if(!istype(infectedMob))
		return // return if isn't proper mob type
	var/datum/disease2/disease/D = new /datum/disease2/disease("custom_disease") //set base name
	for(var/i = 1; i <= D.max_stage; i++)  // run through this loop until everything is set
		var/datum/disease2/effect/sympton = input(C, "Choose a sympton to add ([5-i] remaining)", "Choose a Sympton") in ((typesof(/datum/disease2/effect) - /datum/disease2/effect)) // choose a sympton from the list of them
		var/datum/disease2/effectholder/holder = new /datum/disease2/effectholder(infectedMob) // create the infectedMob as a holder for it.
		holder.stage = i // set the stage of this holder equal to i.
		var/datum/disease2/effect/f = new sympton // initalize the new sympton
		holder.effect = f // assign the new sympton to the holder
		holder.chance = input(C, "Choose chance", "Chance") as num // set the chance of the sympton that can occur
		D.log += "[f.name] [holder.chance]%<br>"
		D.effects += holder // add the holder to the disease

	D.uniqueID = rand(0, 10000)
	D.infectionchance = input(C, "Choose an infection rate percent", "Infection Rate") as num

	//pick random antigens for the disease to have
	D.antigen |= text2num(pick(ANTIGENS))
	D.antigen |= text2num(pick(ANTIGENS))

	D.spreadtype = input(C, "Select spread type", "Spread Type") in list("Airborne", "Contact") // select how the disease is spread
	infectedMob.virus2["[D.uniqueID]"] = D // assign the disease datum to the infectedMob/ selected user.
	log_admin("[infectedMob] was infected with a virus with uniqueID : [D.uniqueID] by [C.ckey]")
	message_admins("[infectedMob] was infected with a virus with uniqueID : [D.uniqueID] by [C.ckey]")
	return 1

/datum/disease2/disease/proc/activate(var/mob/living/carbon/mob)
	if(dead)
		cure(mob)
		return


	if(mob.stat == 2)
		return
	if(stage <= 1 && clicks == 0) 	// with a certain chance, the mob may become immune to the disease before it starts properly
		if(prob(5))
			mob.antibodies |= antigen // 20% immunity is a good chance IMO, because it allows finding an immune person easily

	if(mob.radiation > 50)
		if(prob(1))
			majormutate()
			log += "<br />[timestamp()] MAJORMUTATE (rads)!"


	//Space antibiotics stop disease completely (temporary)
	if(mob.reagents.has_reagent("spaceacillin"))
		return

	//Virus food speeds up disease progress
	if(mob.reagents.has_reagent("virusfood"))
		mob.reagents.remove_reagent("virusfood",0.1)
		if(!logged_virusfood)
			log += "<br />[timestamp()] Virus Fed ([mob.reagents.get_reagent_amount("virusfood")]U)"
			logged_virusfood=1
		clicks += 10
	else
		logged_virusfood=0

	//Moving to the next stage
	if(clicks > stage*100 && prob(10))
		if(stage == max_stage)
			src.cure(mob)
			mob.antibodies |= src.antigen
			log += "<br />[timestamp()] STAGEMAX ([stage])"
		else
			stage++
			log += "<br />[timestamp()] NEXT STAGE ([stage])"
			clicks = 0

	//Do nasty effects
	for(var/datum/disease2/effectholder/e in effects)
		e.runeffect(mob,stage)

	//Short airborne spread
	if(src.spreadtype == "Airborne")
		for(var/mob/living/carbon/M in oview(1,mob))
			if(airborne_can_reach(get_turf(mob), get_turf(M)))
				infect_virus2(M,src, notes="(Airborne from [key_name(mob)])")

	//fever
	mob.bodytemperature = max(mob.bodytemperature, min(310+5*stage ,mob.bodytemperature+5*stage))
	clicks+=speed

/datum/disease2/disease/proc/cure(var/mob/living/carbon/mob)
	for(var/datum/disease2/effectholder/e in effects)
		e.effect.deactivate(mob)
	mob.virus2.Remove("[uniqueID]")

/datum/disease2/disease/proc/minormutate()
	//uniqueID = rand(0,10000)
	var/datum/disease2/effectholder/holder = pick(effects)
	holder.minormutate()
	infectionchance = min(50,infectionchance + rand(0,10))
	log += "<br />[timestamp()] Infection chance now [infectionchance]%"

/datum/disease2/disease/proc/majormutate()
	uniqueID = rand(0,10000)
	var/datum/disease2/effectholder/holder = pick(effects)
	holder.majormutate()
	if (prob(5))
		antigen = text2num(pick(ANTIGENS))
		antigen |= text2num(pick(ANTIGENS))

/datum/disease2/disease/proc/getcopy()
	var/datum/disease2/disease/disease = new /datum/disease2/disease("")
	disease.log=log
	disease.infectionchance = infectionchance
	disease.spreadtype = spreadtype
	disease.stageprob = stageprob
	disease.antigen   = antigen
	disease.uniqueID = uniqueID
	disease.speed = speed
	disease.stage = stage
	disease.clicks = clicks
	for(var/datum/disease2/effectholder/holder in effects)
		var/datum/disease2/effectholder/newholder = new /datum/disease2/effectholder(disease)
		newholder.effect = new holder.effect.type
		newholder.chance = holder.chance
		newholder.cure = holder.cure
		newholder.multiplier = holder.multiplier
		newholder.happensonce = holder.happensonce
		newholder.stage = holder.stage
		disease.effects += newholder
	return disease

/datum/disease2/disease/proc/issame(var/datum/disease2/disease/disease)
	var/list/types = list()
	var/list/types2 = list()
	for(var/datum/disease2/effectholder/d in effects)
		types += d.effect.type
	var/equal = 1

	for(var/datum/disease2/effectholder/d in disease.effects)
		types2 += d.effect.type

	for(var/type in types)
		if(!(type in types2))
			equal = 0

	if (antigen != disease.antigen)
		equal = 0
	return equal

/proc/virus_copylist(var/list/datum/disease2/disease/viruses)
	var/list/res = list()
	for (var/ID in viruses)
		var/datum/disease2/disease/V = viruses[ID]
		if(istype(V))
			res["[V.uniqueID]"] = V.getcopy()
		else
			testing("Got a NULL disease2 in virus_copylist ([V] is [V.type])!")
	return res


var/global/list/virusDB = list()

/datum/disease2/disease/proc/name()
	.= "stamm #[add_zero("[uniqueID]", 4)]"
	if ("[uniqueID]" in virusDB)
		var/datum/data/record/V = virusDB["[uniqueID]"]
		.= V.fields["name"]

/datum/disease2/disease/proc/get_info()
	var/r = "GNAv2 based virus lifeform - [name()], #[add_zero("[uniqueID]", 4)]"
	r += "<BR>Infection rate : [infectionchance * 10]"
	r += "<BR>Spread form : [spreadtype]"
	r += "<BR>Progress Speed : [stageprob * 10]"
	for(var/datum/disease2/effectholder/E in effects)
		r += "<BR>Effect:[E.effect.name]. Strength : [E.multiplier * 8]. Verosity : [E.chance * 15]. Type : [5-E.stage]."

	r += "<BR>Antigen pattern: [antigens2string(antigen)]"
	return r

/datum/disease2/disease/proc/addToDB()
	if ("[uniqueID]" in virusDB)
		return 0
	var/datum/data/record/v = new()
	v.fields["id"] = uniqueID
	v.fields["name"] = name()
	v.fields["description"] = get_info()
	v.fields["antigen"] = antigens2string(antigen)
	v.fields["spread type"] = spreadtype
	virusDB["[uniqueID]"] = v
	return 1

proc/virus2_lesser_infection()
	var/list/candidates = list()	//list of candidate keys

	for(var/mob/living/carbon/human/G in player_list)
		if(G.client && G.stat != DEAD)
			candidates += G
	if(!candidates.len)	return

	candidates = shuffle(candidates)

	infect_mob_random_lesser(candidates[1])

proc/virus2_greater_infection()
	var/list/candidates = list()	//list of candidate keys

	for(var/mob/living/carbon/human/G in player_list)
		if(G.client && G.stat != DEAD)
			candidates += G
	if(!candidates.len)	return

	candidates = shuffle(candidates)

	infect_mob_random_greater(candidates[1])
