/obj/proc_holder/spell/targeted/area_teleport
	name = "Area teleport"
	desc = "This spell teleports you to a type of area of your selection."

	var/randomise_selection = 0 //if it lets the usr choose the teleport loc or picks it from the list
	var/invocation_area = 1 //if the invocation appends the selected area

/obj/proc_holder/spell/targeted/area_teleport/perform(list/targets, recharge = 1)
	var/thearea = before_cast(targets)
	if(!thearea || !cast_check(1))
		revert_cast()
		return
	invocation(thearea)
	spawn(0)
		if(charge_type == "recharge" && recharge)
			start_recharge()
	cast(targets,thearea)
	after_cast(targets)

/obj/proc_holder/spell/targeted/area_teleport/before_cast(list/targets)
	var/A = null

	if(!randomise_selection)
		A = input("Area to teleport to", "Teleport", A) in teleportlocs
	else
		A = pick(teleportlocs)

	var/area/thearea = teleportlocs[A]

	return thearea

/obj/proc_holder/spell/targeted/area_teleport/cast(list/targets,area/thearea)
	for(var/mob/target in targets)
		var/list/L = list()
		for(var/turf/T in get_area_turfs(thearea.type))
			if(!T.density)
				var/clear = 1
				for(var/obj/O in T)
					if(O.density)
						clear = 0
						break
				if(clear)
					L+=T

		target.loc = pick(L)

	return

/obj/proc_holder/spell/targeted/area_teleport/invocation(area/chosenarea = null)
	if(!invocation_area || !chosenarea)
		..()
	else
		switch(invocation_type)
			if("shout")
				usr.say("[invocation] [uppertext(chosenarea.name)]")
				if(usr.gender=="male")
					playsound(usr.loc, pick('vs_chant_conj_hm.wav','vs_chant_conj_lm.wav','vs_chant_ench_hm.wav','vs_chant_ench_lm.wav','vs_chant_evoc_hm.wav','vs_chant_evoc_lm.wav','vs_chant_illu_hm.wav','vs_chant_illu_lm.wav','vs_chant_necr_hm.wav','vs_chant_necr_lm.wav'), 100, 1)
				else
					playsound(usr.loc, pick('vs_chant_conj_hf.wav','vs_chant_conj_lf.wav','vs_chant_ench_hf.wav','vs_chant_ench_lf.wav','vs_chant_evoc_hf.wav','vs_chant_evoc_lf.wav','vs_chant_illu_hf.wav','vs_chant_illu_lf.wav','vs_chant_necr_hf.wav','vs_chant_necr_lf.wav'), 100, 1)
			if("whisper")
				usr.whisper("[invocation] [uppertext(chosenarea.name)]")

	return