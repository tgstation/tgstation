/datum/disease/proc/minormutate(index)
	var/datum/symptom/e = get_effect(index)
	e.minormutate()
	infectionchance = min(50,infectionchance + rand(0,10))
	log += "<br />[ROUND_TIME()] Infection chance now [infectionchance]%"

/datum/disease/proc/minorstrength(index)
	var/datum/symptom/e = get_effect(index)
	e.multiplier_tweak(0.1)

/datum/disease/proc/minorweak(index)
	var/datum/symptom/e = get_effect(index)
	e.multiplier_tweak(-0.1)

//Major Mutations
/datum/disease/proc/effectmutate(var/inBody=FALSE, datum/symptom/symptom)
	clean_global_log()
	subID = rand(0,9999)

	///this should be done better but I can't figure out how to return the index value of something from a list
	var/i = 0
	for(var/datum/symptom/s as anything in symptoms)
		i++
		if(s == symptom)
			break

	var/list/randomhexes = list("7","8","9","a","b","c","d","e")
	var/colormix = "#[pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)][pick(randomhexes)]"
	color = BlendRGB(color,colormix,0.25)
	var/datum/symptom/f
	if (inBody)//mutations that occur directly in a body don't cause helpful symptoms to become deadly instantly.
		f = new_random_effect(min(5,text2num(symptom.badness)+1), max(0,text2num(symptom.badness)-1), symptom.stage, symptom.type)
	else
		f = new_random_effect(min(5,text2num(symptom.badness)+2), max(0,text2num(symptom.badness)-3), symptom.stage, symptom.type)//badness is slightly more likely to go down than up.
	var/datum/symptom/old = symptoms[i]
	SEND_SIGNAL(old, COMSIG_SYMPTOM_DETACH)
	symptoms[i] = f
	log += "<br />[ROUND_TIME()] Mutated effect [symptom.name] [symptom.chance]% into [f.name] [f.chance]%."
	update_global_log()

/datum/disease/proc/antigenmutate()
	clean_global_log()
	subID = rand(0,9999)
	var/old_dat = get_antigen_string()
	roll_antigen()
	log += "<br />[ROUND_TIME()] Mutated antigen [old_dat] into [get_antigen_string()]."
	update_global_log()

/datum/disease/proc/incubate(atom/movable/incubator, mutatechance = 1, specified_stage)
	if(!mutatechance)
		return
	mutatechance *= mutation_modifier

	var/datum/reagents/reagents = incubator.reagents
	if(!reagents)
		return

	var/obj/machinery/disease2/incubator/machine
	if(istype(incubator.loc, /obj/machinery/disease2/incubator))
		machine = incubator.loc


	if(specified_stage)
		stage_incubation(specified_stage, mutatechance, reagents, machine, incubator)

	for(var/datum/reagent/reagent as anything in reagents.reagent_list)
		if(prob(mutatechance))
			reagent.disease_incubate(incubator, src, machine)
			reagents.remove_reagent(reagent.type, (reagent.volume * 0.1))

/datum/disease/proc/stage_incubation(specified_stage, mutatechance, datum/reagents/reagents, obj/machinery/disease2/incubator/machine, atom/movable/incubator)
	var/list/symptoms_at_stage = list()
	for(var/datum/symptom/e as anything in symptoms)
		if(e.stage != specified_stage)
			continue
		symptoms_at_stage |= e

	for(var/datum/reagent/reagent as anything in reagents.reagent_list)
		if(prob(mutatechance))
			reagent.stage_disease_incubate(incubator, src, symptoms_at_stage, machine)
			reagents.remove_reagent(reagent.type, (reagent.volume * 0.1))
