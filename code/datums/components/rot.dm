/datum/component/rot
	var/amount = 1

/datum/component/rot/Initialize(new_amount)
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	if(new_amount)
		amount = new_amount

	START_PROCESSING(SSprocessing, src)

/datum/component/rot/process()
	var/atom/A = parent

	var/turf/open/T = get_turf(A)
	if(!istype(T) || T.return_air().return_pressure() > (WARNING_HIGH_PRESSURE - 10))
		return

	var/datum/gas_mixture/stank = new
	ADD_GAS(/datum/gas/miasma, stank.gases)
	stank.gases[/datum/gas/miasma][MOLES] = amount
	stank.temperature = BODYTEMP_NORMAL // otherwise we have gas below 2.7K which will break our lag generator
	T.assume_air(stank)
	T.air_update_turf()

/datum/component/rot/corpse
	amount = MIASMA_CORPSE_MOLES

/datum/component/rot/corpse/Initialize()
	if(!iscarbon(parent))
		return COMPONENT_INCOMPATIBLE
	. = ..()

/datum/component/rot/corpse/process()
	var/mob/living/carbon/C = parent
	if(C.stat != DEAD)
		qdel(src)
		return


	if(C.reagents.has_reagent(/datum/reagent/teslium, 5))
		C.reagents.remove_reagent(/datum/reagent/teslium, 5)
		var/total_burn	= 0
		var/total_brute	= 0
		var/tplus = world.time - C.timeofdeath	//length of time spent dead
		var/tlimit = 9000
		var/obj/item/organ/heart = C.getorgan(/obj/item/organ/heart)
		var/HALFWAYCRITDEATH = ((HEALTH_THRESHOLD_CRIT + HEALTH_THRESHOLD_DEAD) * 0.5)


		C.visible_message("<span class='warning'>[C]'s body convulses a bit.</span>")
		C.electrocute_act(0, C)
		playsound(C, "sparks", 50, 1)
		playsound(C, 'sound/machines/defib_zap.ogg', 75, 1, -1)
		total_brute	= C.getBruteLoss()
		total_burn	= C.getFireLoss()
		if(isliving(C.pulledby))		//CLEAR!
			var/mob/living/M = C.pulledby
			if(M.electrocute_act(30, C))
				M.emote("scream")

		if (C.suiciding)
			return
		if (C.hellbound)
			return
		if (tplus > tlimit)
			return
		if (!heart)
			return
		if (heart.organ_flags & ORGAN_FAILING)
			return
		if (total_burn >= MAX_REVIVE_FIRE_DAMAGE || total_brute >= MAX_REVIVE_BRUTE_DAMAGE || HAS_TRAIT(C, TRAIT_HUSK))
			return
		if(C.get_ghost())
			return

		var/obj/item/organ/brain/BR = C.getorgan(/obj/item/organ/brain)
		if(BR)
			if(BR.organ_flags & ORGAN_FAILING)
				return
			if(BR.brain_death)
				return
			if(BR.suicided || BR.brainmob?.suiciding)
				return

		if (C.health > HALFWAYCRITDEATH)
			C.adjustOxyLoss(C.health - HALFWAYCRITDEATH, 0)
		else
			var/overall_damage = total_brute + total_burn + C.getToxLoss() + C.getOxyLoss()
			var/mobhealth = C.health
			C.adjustOxyLoss((mobhealth - HALFWAYCRITDEATH) * (C.getOxyLoss() / overall_damage), 0)
			C.adjustToxLoss((mobhealth - HALFWAYCRITDEATH) * (C.getToxLoss() / overall_damage), 0)
			C.adjustFireLoss((mobhealth - HALFWAYCRITDEATH) * (total_burn / overall_damage), 0)
			C.adjustBruteLoss((mobhealth - HALFWAYCRITDEATH) * (total_brute / overall_damage), 0)
		C.updatehealth() // Previous "adjust" procs don't update health, so we do it manually.
		C.set_heartattack(FALSE)
		C.revive()
		C.emote("gasp")
		C.Jitter(100)
		SEND_SIGNAL(C, COMSIG_LIVING_MINOR_SHOCK)

		return

	// Wait a bit before decaying
	if(world.time - C.timeofdeath < 2 MINUTES)
		return

	// Properly stored corpses shouldn't create miasma
	if(istype(C.loc, /obj/structure/closet/crate/coffin)|| istype(C.loc, /obj/structure/closet/body_bag) || istype(C.loc, /obj/structure/bodycontainer))
		return

	// No decay if formaldehyde in corpse or when the corpse is charred
	if(C.reagents.has_reagent(/datum/reagent/toxin/formaldehyde, 15) || HAS_TRAIT(C, TRAIT_HUSK))
		return

	// Also no decay if corpse chilled or not organic/undead
	if(C.bodytemperature <= T0C-10 || !(C.mob_biotypes & (MOB_ORGANIC|MOB_UNDEAD)))
		return

	..()

/datum/component/rot/gibs
	amount = MIASMA_GIBS_MOLES
