/obj/item/organ/internal/cyberimp/chest
	name = "cybernetic torso implant"
	desc = "implants for the organs in your torso"
	icon_state = "chest_implant"
	implant_overlay = "chest_implant_overlay"
	zone = "chest"

/obj/item/organ/internal/cyberimp/chest/nutriment
	name = "Nutriment pump implant"
	desc = "This implant with synthesize and pump into your bloodstream a small amount of nutriment when you are starving."
	icon_state = "chest_implant"
	implant_color = "#00AA00"
	var/hunger_threshold = NUTRITION_LEVEL_STARVING
	var/synthesizing = 0
	var/poison_amount = 5
	slot = "stomach"
	origin_tech = "materials=5;programming=3;biotech=4"

/obj/item/organ/internal/cyberimp/chest/nutriment/on_life()
	if(synthesizing)
		return

	if(owner.nutrition <= hunger_threshold)
		synthesizing = 1
		owner << "<span class='notice'>You feel less hungry...</span>"
		owner.nutrition += 50
		spawn(50)
			synthesizing = 0

/obj/item/organ/internal/cyberimp/chest/nutriment/emp_act(severity)
	if(!owner)
		return
	owner.reagents.add_reagent("????",poison_amount / severity) //food poisoning
	owner << "<span class='warning'>You feel like your insides are burning.</span>"


/obj/item/organ/internal/cyberimp/chest/nutriment/plus
	name = "Nutriment pump implant PLUS"
	desc = "This implant will synthesize and pump into your bloodstream a small amount of nutriment when you are hungry."
	icon_state = "chest_implant"
	implant_color = "#006607"
	hunger_threshold = NUTRITION_LEVEL_HUNGRY
	poison_amount = 10
	origin_tech = "materials=5;programming=3;biotech=5"



/obj/item/organ/internal/cyberimp/chest/reviver
	name = "Reviver implant"
	desc = "This implant will attempt to revive you if you lose consciousness. For the faint of heart!"
	icon_state = "chest_implant"
	implant_color = "#AD0000"
	origin_tech = "materials=6;programming=3;biotech=6;syndicate=4"
	slot = "heartdrive"
	var/revive_cost = 0
	var/reviving = 0
	var/cooldown = 0

/obj/item/organ/internal/cyberimp/chest/reviver/on_life()
	if(reviving)
		if(owner.stat == UNCONSCIOUS)
			spawn(30)
				if(prob(90) && owner.getOxyLoss())
					owner.adjustOxyLoss(-3)
					revive_cost += 5
				if(prob(75) && owner.getBruteLoss())
					owner.adjustBruteLoss(-1)
					revive_cost += 20
				if(prob(75) && owner.getFireLoss())
					owner.adjustFireLoss(-1)
					revive_cost += 20
				if(prob(40) && owner.getToxLoss())
					owner.adjustToxLoss(-1)
					revive_cost += 50
		else
			cooldown = revive_cost + world.time
			reviving = 0
		return

	if(cooldown > world.time)
		return
	if(owner.stat != UNCONSCIOUS)
		return
	if(owner.suiciding)
		return

	revive_cost = 0
	reviving = 1

/obj/item/organ/internal/cyberimp/chest/reviver/emp_act(severity)
	if(!owner)
		return

	if(reviving)
		revive_cost += 200
	else
		cooldown += 200

	if(istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = owner
		if(H.stat != DEAD && prob(50 / severity))
			H.heart_attack = 1
			spawn(600 / severity)
				H.heart_attack = 0
				if(H.stat == CONSCIOUS)
					H << "<span class='notice'>You feel your heart beating again!</span>"




/obj/item/organ/internal/cyberimp/chest/thrusters
	name = "implantable thrusters set"
	desc = "An implantable set of thruster ports. They use the gas from environment or subject's internals for propulsion in zero-gravity areas. \
	Unlike regular jetpack, this device has no stablilzation system."
	slot = "thrusters"
	icon_state = "imp_jetpack"
	origin_tech = "materials=6;programming=4;magnets=3;biotech=4;engineering=4"
	implant_overlay = null
	implant_color = null
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	w_class = 3
	var/on = 0
	var/datum/effect_system/trail_follow/ion/ion_trail

/obj/item/organ/internal/cyberimp/chest/thrusters/Insert(mob/living/carbon/M, special = 0)
	..()
	if(!ion_trail)
		ion_trail = new
	ion_trail.set_up(M)

/obj/item/organ/internal/cyberimp/chest/thrusters/Remove(mob/living/carbon/M, special = 0)
	if(on)
		toggle(silent=1)
	..()

/obj/item/organ/internal/cyberimp/chest/thrusters/ui_action_click()
	toggle()

/obj/item/organ/internal/cyberimp/chest/thrusters/proc/toggle(silent=0)
	if(!on)
		if(crit_fail)
			if(!silent)
				owner << "<span class='warning'>Your thrusters set seems to be broken!</span>"
			return 0
		on = 1
		if(allow_thrust(0.01))
			ion_trail.start()
			if(!silent)
				owner << "<span class='notice'>You turn your thrusters set on.</span>"
	else
		ion_trail.stop()
		if(!silent)
			owner << "<span class='notice'>You turn your thrusters set off.</span>"
		on = 0
	update_icon()

/obj/item/organ/internal/cyberimp/chest/thrusters/update_icon()
	if(on)
		icon_state = "imp_jetpack-on"
	else
		icon_state = "imp_jetpack"
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/organ/internal/cyberimp/chest/thrusters/proc/allow_thrust(num)
	if(!on || !owner)
		return 0

	var/turf/T = get_turf(owner)
	if(!T) // No more runtimes from being stuck in nullspace.
		return 0

	// Priority 1: use air from environment.
	var/datum/gas_mixture/environment = T.return_air()
	if(environment && environment.return_pressure() > 30)
		return 1

	// Priority 2: use plasma from internal plasma storage.
	// (just in case someone would ever use this implant system to make cyber-alien ops with jetpacks and taser arms)
	if(owner.getPlasma() >= num*100)
		owner.adjustPlasma(-num*100)
		return 1

	// Priority 3: use internals tank.
	var/obj/item/weapon/tank/I = owner.internal
	if(I && I.air_contents && I.air_contents.total_moles() > num)
		var/datum/gas_mixture/removed = I.air_contents.remove(num)
		if(removed.total_moles() > 0.005)
			T.assume_air(removed)
			return 1
		else
			T.assume_air(removed)

	toggle(silent=1)
	return 0