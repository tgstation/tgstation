/datum/artifact_effect/cellcharge
	effecttype = "cellcharge"
	effect_type = 3
	var/next_message

/datum/artifact_effect/cellcharge/DoEffectTouch(var/mob/user)
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(R.cell)
			R.cell.charge += rand() * 100
			to_chat(R, "<span class='notice'>SYSTEM ALERT: Large energy boost detected!</span>")
		if(world.time >= next_message)
			next_message = world.time + 50
		return 1

/datum/artifact_effect/cellcharge/DoEffectAura()
	if(holder)
		for(var/obj/machinery/power/apc/C in range(effectrange, holder))
			if(C.cell)
				C.cell.charge += 25
		for(var/obj/machinery/power/battery/S in range(effectrange, holder))
			S.charge += 25
		for(var/mob/living/silicon/robot/M in mob_list)
			if(M.cell)
				M.cell.charge += 25
				if(world.time >= next_message)
					to_chat(M, "<span class='notice'>SYSTEM ALERT: Energy boost detected!</span>")
		if(world.time >= next_message)
			next_message = world.time + 300
		return 1

/datum/artifact_effect/cellcharge/DoEffectPulse()
	if(holder)
		for(var/obj/machinery/power/apc/C in range(effectrange, holder))
			if(C.cell)
				C.cell.charge += rand() * 100
		for(var/obj/machinery/power/battery/S in range(effectrange, holder))
			S.charge += rand() * 100
		for(var/mob/living/silicon/robot/M in mob_list)
			if(M.cell)
				M.cell.charge += rand() * 100
				if(world.time >= next_message)
					to_chat(M, "<span class='notice'>SYSTEM ALERT: Large energy boost detected!</span>")
		if(world.time >= next_message)
			next_message = world.time + 300
		return 1
