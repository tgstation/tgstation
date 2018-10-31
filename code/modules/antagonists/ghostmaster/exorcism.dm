#define REVEAL_WORD "word"

#define EXORCISM_REQ_AREA "spec_area"
#define EXORCISM_REQ_CANDLE "candle"
#define EXORCISM_REQ_HOLY_GROUND "holy_ground"

#define EXORCISM_STEP_REAGENT "reagent" //Splash the corpse with reagent
#define EXORCISM_STEP_ITEM "item" //Hit the corpse with item
#define EXORCISM_STEP_CLEAN "clean"
#define EXORCISM_STEP_FIRE "fire"
#define EXORCISM_STEP_PRAYER "prayer"

/datum/exorcism
	var/obj/holder //The thing exorcism steps are performed on
	var/reveal_method
	var/reveal_data
	var/list/requirements = list()
	var/list/steps = list() //step = details (path/reagentid)
	var/current_step = 1
	var/list/shown_hints
	var/revealed = FALSE
	var/completed = FALSE
	var/mob/bound_spook //Thing that will get exorcised when this is completed
	var/retaliate = TRUE //mistakes hurt

/datum/exorcism/New()
	. = ..()
	reset_hints()

/datum/exorcism/proc/generate(step_count = 5, req_count = 1)
	//Todo more reveal methods.
	reveal_method = REVEAL_WORD
	reveal_data = pick("swordfish","beetlejuice","appear spirit")

	var/list/possible_reqs = list(EXORCISM_REQ_AREA,EXORCISM_REQ_CANDLE,EXORCISM_REQ_HOLY_GROUND)
	for(var/i in 1 to req_count)
		var/reqp = pick_n_take(possible_reqs)

		switch(reqp)
			if(EXORCISM_REQ_AREA)
				requirements[reqp] = pick(GLOB.the_station_areas)
			else
				requirements[reqp] = 1
		if(!possible_reqs.len)
			break

	var/list/possible_steps = list(EXORCISM_STEP_REAGENT,EXORCISM_STEP_ITEM,EXORCISM_STEP_CLEAN,EXORCISM_STEP_FIRE,EXORCISM_STEP_PRAYER)
	for(var/i in 1 to step_count)
		var/stepp = pick(possible_steps)
		var/list/step_data = list()
		step_data["step"] = stepp
		switch(stepp)
			if(EXORCISM_STEP_REAGENT)
				step_data["data"] = pick("ale","water","tea")
			if(EXORCISM_STEP_ITEM)
				step_data["data"] = pick(/obj/item/storage/book/bible,/obj/item/storage/toolbox)
			if(EXORCISM_STEP_PRAYER)
				step_data["data"] = pick("rest in peace","happy pinning","goodbye")
		steps += list(step_data)

/datum/exorcism/proc/reset_hints()
	shown_hints = list()
	shown_hints["requirements"] = 0
	shown_hints["steps"] = 0
	shown_hints["location"] = FALSE
	shown_hints["reveal"] = FALSE

/datum/exorcism/proc/RegisterCorpse(obj/O)
	holder = O
	if(reveal_method == REVEAL_WORD && !(O.flags_1 & HEAR_1))
		O.flags_1 |= HEAR_1
	RegisterSignal(O,COMSIG_MOVABLE_HEAR,.proc/check_reveal_hear)
	RegisterSignal(O,COMSIG_PARENT_ATTACKBY,.proc/check_step_attackby)
	RegisterSignal(O,COMSIG_COMPONENT_CLEAN_ACT, .proc/check_step_clean)
	RegisterSignal(O,COMSIG_ATOM_REAGENT_BEFORE_REACTION, .proc/check_step_reaction)

/datum/exorcism/proc/UnregisterCorpse(obj/O)
	UnregisterSignal(holder,COMSIG_MOVABLE_HEAR)
	UnregisterSignal(holder,COMSIG_PARENT_ATTACKBY)
	UnregisterSignal(holder,COMSIG_COMPONENT_CLEAN_ACT)
	UnregisterSignal(holder,COMSIG_ATOM_REAGENT_BEFORE_REACTION)
	holder = null

/datum/exorcism/proc/check_reveal_hear(datum/source, message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, message_mode)
	if(radio_freq)
		return
	if(!revealed && reveal_method == REVEAL_WORD && !radio_freq && findtext(message,reveal_data))
		Reveal()
	else if(revealed && in_range(speaker,holder))
		var/list/current = steps[current_step]
		if(current == EXORCISM_STEP_PRAYER && findtext(message,current["data"]))
			if(check_requirements())
				next_step()
			else
				Fizzle()
		//Going to give fizzle a pass here so you can talk about other things around it


/datum/exorcism/proc/check_step_attackby(datum/source, obj/item/I, mob/living/user, params)
	if(!revealed)
		return
	if(!check_requirements())
		Fizzle()
		return
	var/list/current = steps[current_step]
	switch(current["step"])
		if(EXORCISM_STEP_ITEM)
			if(istype(I,current["data"]))
				next_step()
			else
				Fizzle()
		if(EXORCISM_STEP_FIRE)
			if(I.is_hot())
				next_step()
			else
				Fizzle()
		else
			Fizzle() //Don't hit it with random stuff.

/datum/exorcism/proc/check_step_clean(datum/source, strength)
	if(!revealed)
		return
	if(!check_requirements())
		Fizzle()
		return
	var/list/current = steps[current_step]
	if(current["step"] == EXORCISM_STEP_CLEAN)
		next_step()
	else
		Fizzle()

/datum/exorcism/proc/check_step_reaction(datum/source, datum/reagent/R, volume_mod)
	if(!revealed)
		return
	if(!check_requirements())
		Fizzle()
		return
	var/list/current = steps[current_step]
	if(current["step"] == EXORCISM_STEP_REAGENT)
		if(R.id == current["data"])
			next_step()
		else
			Fizzle()

/datum/exorcism/proc/next_step()
	SEND_SIGNAL(holder,COMSIG_EXORCISM_STEP)
	current_step++
	if(current_step > steps.len)
		Success()

/datum/exorcism/proc/Reveal()
	SEND_SIGNAL(holder,COMSIG_EXORCISM_REVEAL)
	revealed = TRUE
	holder.visible_message("<span class='big haunt'>Was [holder] always here ?</span>")

/datum/exorcism/proc/Success()
	completed = TRUE
	SEND_SIGNAL(holder,COMSIG_EXORCISM_SUCCESS)
	SEND_SIGNAL(bound_spook,COMSIG_EXORCISM_SUCCESS)

/datum/exorcism/proc/Fizzle()
	holder.visible_message("<span class='userdanger'>The angry spirits retaliate!</span>")
	current_step = 1 //start from beginning
	if(retaliate)
		var/curse = pick("blight","emp","scream","ghosthorde")
		switch(curse)
			if("blight")
				for(var/mob/living/carbon/human/H in view(holder))
					H.ForceContractDisease(new /datum/disease/revblight(),FALSE,TRUE)
			if("emp")
				empulse(holder, 5, 10)
			if("scream")
				for(var/mob/living/L in view(holder))
					to_chat(L,"<span class='userdanger'>You hear an inhuman shriek.</span>")
					L.adjustEarDamage(0, 30)
					L.confused += 25
					L.Jitter(50)
					SEND_SOUND(L, sound('sound/effects/screech.ogg'))
			if("ghosthorde")
				for(var/i in 1 to 3)
					var/mob/living/simple_animal/hostile/retaliate/ghost/G = new(get_turf(holder))
					G.Retaliate()
		retaliate = FALSE
		addtimer(VARSET_CALLBACK(src,retaliate,TRUE),20) //To keep spam low
	return

/datum/exorcism/proc/check_requirements()
	for(var/R in requirements)
		switch(R)
			if(EXORCISM_REQ_AREA)
				var/area/A = get_area(holder)
				if(istype(A,requirements[R]))
					continue
				return FALSE
			if(EXORCISM_REQ_CANDLE)
				for(var/obj/item/candle/C in view(3,holder))
					if(C.lit)
						continue
				return FALSE
			if(EXORCISM_REQ_HOLY_GROUND)
				var/turf/T = get_turf(holder)
				if(istype(get_area(T),/area/chapel))
					continue
				if(locate(/obj/effect/blessing) in T)
					continue
				return FALSE
	return TRUE

/datum/exorcism/proc/give_hint()
	if(!shown_hints["location"])
		shown_hints["location"] = TRUE
		var/area/A = get_area(holder)
		return "I was bured in [A.name]"
	if(!shown_hints["reveal"])
		shown_hints["reveal"] = TRUE
		switch(reveal_method)
			if(REVEAL_WORD)
				return "To find my bones say [reveal_data] over my grave."
	var/req_hints = shown_hints["requirements"]
	if(req_hints < requirements.len)
		var/chosen = requirements[++req_hints]
		shown_hints["requirements"] = req_hints
		switch(chosen)
			if(EXORCISM_REQ_AREA)
				var/area/A = requirements[chosen]
				return "Bring my bones to [initial(A.name)] to let me rest in peace."
			if(EXORCISM_REQ_CANDLE)
				return "Light candles over my bones to let me rest in peace."
			if(EXORCISM_REQ_HOLY_GROUND)
				return "Let my bones rest in sanctified ground."
	var/step_hints = shown_hints["steps"]
	if(step_hints < steps.len)
		var/list/chosen = steps[++step_hints]
		shown_hints["steps"] = step_hints
		var/hint = "[thtotext(step_hints)], "
		switch(chosen["step"])
			if(EXORCISM_STEP_REAGENT)
				hint += "pour [chosen["data"]] over my bones."
			if(EXORCISM_STEP_ITEM)
				var/obj/item/I = chosen["data"]
				hint += "strike my bones with a [initial(I.name)]."
			if(EXORCISM_STEP_CLEAN)
				hint += "clean my bones."
			if(EXORCISM_STEP_FIRE)
				hint += "purify my bones with fire."
			if(EXORCISM_STEP_PRAYER)
				hint += "say [chosen["data"]] over my bones."
		return hint
	reset_hints()
	return .()
	
/datum/exorcism/Destroy(force, ...)
	UnregisterCorpse()
	. = ..()
	