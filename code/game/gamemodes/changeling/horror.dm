/datum/species/horror // /vg/
	name = "Horror"
	icobase = 'icons/mob/human_races/r_horror.dmi'
	deform = 'icons/mob/human_races/r_horror.dmi'  // TODO: Need deform.
	language = "Clatter"
	attack_verb = "punch"

	flags = NO_BREATHE /*| NON_GENDERED*/ | NO_PAIN

	// Yep.
	default_mutations=list(M_HULK)

	cold_level_1 = 0 //Default 260 - Lower is better
	cold_level_2 = 10 //Default 200
	cold_level_3 = 20 //Default 120

	heat_level_1 = 420 //Default 360 - Higher is better
	heat_level_2 = 480 //Default 400
	heat_level_3 = 1100 //Default 1000


	warning_low_pressure = 50
	hazard_low_pressure = 0

	max_hurt_damage = 20

	// Same as disposal
	punch_throw_speed = 1
	punch_throw_range = 10

	throw_mult = 1.5 // +0.5 for hulk
	fireloss_mult = 2 // double the damage, half the fun

	abilities = list(
		/client/proc/changeling_force_airlock
	)

	override_icon = 'icons/mob/horror.dmi'

/client/proc/changeling_force_airlock()
	set category = "Changeling"
	set name = "Force Airlock"
	set desc = "We will attempt to force open an airlock in front of us."

	var/mob/living/carbon/human/H=eye
	if(!istype(H))
		return

	if(H.stat!=0 || !H.mind.changeling || H.species.name != "Horror")
		return

	var/turf/T = get_step(H,H.dir)
	if(!T)
		return
	for(var/obj/machinery/door/D in T)
		if(D.density)
			D.visible_message("\red \The [D]'s motors whine as several great tendrils begin trying to force it open!")
			if(do_after(H,50) && prob(50))
				D.open(1)
				D.visible_message("\red [H.name] forces \the [D] open!")

				// Open firedoors, too.
				for(var/obj/machinery/door/firedoor/FD in D.loc)
					if(FD && FD.density)
						FD.open(1)
			else
				usr << "\red You fail to open \the [D]."
			return