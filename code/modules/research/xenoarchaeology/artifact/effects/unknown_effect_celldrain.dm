
//todo
/datum/artifact_effect/celldrain
	effecttype = "celldrain"
	effect_type = 3

/datum/artifact_effect/celldrain/DoEffectTouch(var/mob/user)
	if(user)
		if(istype(user, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = user
			for (var/obj/item/weapon/stock_parts/cell/D in R.contents)
				D.charge = max(D.charge - rand() * 100, 0)
				R << "<span class='notice'>SYSTEM ALERT: Energy drain detected!</span>"
			return 1

		return 1

/datum/artifact_effect/celldrain/DoEffectAura()
	if(holder)
		for (var/obj/machinery/power/apc/C in range(200, holder))
			C.cell.charge = max(C.cell.charge - 50,0)
		for (var/mob/living/silicon/robot/M in mob_list)
			for (var/obj/item/weapon/stock_parts/cell/D in M.contents)
				D.charge = max(D.charge - 50,0)
				M << "<span class='warning'>SYSTEM ALERT: Energy drain detected!</span>"
	return 1

/datum/artifact_effect/celldrain/DoEffectPulse()
	if(holder)
		for (var/obj/machinery/power/apc/C in range(200, holder))
			C.cell.charge = max(C.cell.charge - rand() * 150,0)
		for (var/mob/living/silicon/robot/M in mob_list)
			for (var/obj/item/weapon/stock_parts/cell/D in M.contents)
				D.charge = max(D.charge - rand() * 150,0)
				M << "<span class='warning'>SYSTEM ALERT: Energy drain detected!</span>"
	return 1
