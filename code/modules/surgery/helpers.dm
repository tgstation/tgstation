proc/get_location_modifier(mob/M)
	var/turf/T = get_turf(M)
	if(locate(/obj/machinery/optable, T))
		return 1
	else if(locate(/obj/structure/table, T))
		return 0.8
	else if(locate(/obj/structure/stool/bed, T))
		return 0.7
	else
		return 0.5

/proc/attempt_initiate_surgery(obj/item/I, mob/living/M, mob/user)
	if(istype(M))
		if(M.lying || isslime(M))	//if they're prone or a slime
			var/list/all_surgeries = surgeries_list.Copy()
			var/list/available_surgeries = list()
			for(var/i in all_surgeries)
				var/datum/surgery/S = all_surgeries[i]

				if(locate(S.type) in M.surgeries)
					continue
				if(S.target_must_be_dead && M.stat != DEAD)
					continue
				for(var/path in S.species)
					if(istype(M, path))
						available_surgeries[S.name] = S
						break

			var/P = input("Begin which procedure?", "Surgery", null, null) as null|anything in available_surgeries
			if(P)
				var/datum/surgery/S = available_surgeries[P]
				var/datum/surgery/procedure = new S.type
				if(procedure)
					M.surgeries += procedure
					user.visible_message("<span class='notice'>[user] drapes [I] over [M]'s [procedure.location] to prepare for \an [procedure.name].</span>")

					user.attack_log += "\[[time_stamp()]\]<font color='red'>Initiated a [procedure.name] on [M.name] ([M.ckey])</font>"
					M.attack_log += "\[[time_stamp()]\]<font color='red'>[user.name] ([user.ckey]) initiated a [procedure.name]</font>"
					log_attack("<font color='red'>[user.name] ([user.ckey]) initiated a [procedure.name] on [M.name] ([M.ckey])</font>")
					return 1
	return 0