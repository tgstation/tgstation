
//todo
/datum/artifact_effect/celldrain
	effecttype = "celldrain"
	effect_type = 3

/datum/artifact_effect/celldrain/DoEffectTouch(var/mob/user)
	if(user)
		if(istype(user, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = user
			for (var/obj/item/weapon/cell/D in R.contents)
				D.charge = max(D.charge - rand() * 100, 0)
				R << "\blue SYSTEM ALERT: Energy drain detected!"
			return 1

		return 1

/datum/artifact_effect/celldrain/DoEffectAura()
	if(holder)
		for (var/obj/machinery/power/apc/C in range(200, holder))
			for (var/obj/item/weapon/cell/B in C.contents)
				B.charge = max(B.charge - 50,0)
		for (var/obj/machinery/power/smes/S in range (src.effectrange,src))
			S.charge = max(S.charge - 100,0)
		for (var/mob/living/silicon/robot/M in mob_list)
			for (var/obj/item/weapon/cell/D in M.contents)
				D.charge = max(D.charge - 50,0)
				M << "\red SYSTEM ALERT: Energy drain detected!"
	return 1

/datum/artifact_effect/celldrain/DoEffectPulse()
	if(holder)
		for (var/obj/machinery/power/apc/C in range(200, holder))
			for (var/obj/item/weapon/cell/B in C.contents)
				B.charge = max(B.charge - rand() * 150,0)
		for (var/obj/machinery/power/smes/S in range (src.effectrange,src))
			S.charge = max(S.charge - 250,0)
		for (var/mob/living/silicon/robot/M in mob_list)
			for (var/obj/item/weapon/cell/D in M.contents)
				D.charge = max(D.charge - rand() * 150,0)
				M << "\red SYSTEM ALERT: Energy drain detected!"
	return 1
