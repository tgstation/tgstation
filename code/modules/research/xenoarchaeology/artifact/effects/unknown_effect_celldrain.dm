
//todo
/datum/artifact_effect/celldrain
	effecttype = "celldrain"
	effect_type = 3

/datum/artifact_effect/celldrain/DoEffectTouch(var/mob/user)
	if(isrobot(user))
		var/mob/living/silicon/robot/R = user
		if(R.cell)
			R.cell.charge = max(D.charge - rand() * 100, 0)
			R << "<span class='danger'>SYSTEM ALERT: Large energy drain detected!</span>"
		return 1

/datum/artifact_effect/celldrain/DoEffectAura()
	if(holder)
		for(var/obj/machinery/power/apc/C in range(effectrange, holder))
			if(C.cell)
				C.cell.charge = max(B.charge - 50, 0)
		for(var/obj/machinery/power/battery/S in range(effectrange, holder))
			S.charge = max(B.charge - 50, 0)
		for(var/mob/living/silicon/robot/M in mob_list)
			if(M.cell)
				M.cell.charge = max(B.charge - 50, 0)
				if(world.time >= next_message)
					M << "<span class='warning'>SYSTEM ALERT: Energy drain detected!</span>"
		if(world.time >= next_message)
			next_message = world.time + 100
		return 1

/datum/artifact_effect/celldrain/DoEffectPulse()
	if(holder)
		for(var/obj/machinery/power/apc/C in range(effectrange, holder))
			if(C.cell)
				C.cell.charge = max(D.charge - rand() * 100, 0)
		for(var/obj/machinery/power/battery/S in range(effectrange, holder))
			S.charge = max(D.charge - rand() * 100, 0)
		for(var/mob/living/silicon/robot/M in mob_list)
			if(M.cell)
				M.cell.charge = max(D.charge - rand() * 100, 0)
				if(world.time >= next_message)
					M << "<span class='danger'>SYSTEM ALERT: Large energy drain detected!</span>"
		return 1
