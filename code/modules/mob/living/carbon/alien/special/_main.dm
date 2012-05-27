//XCOM alien code
//By Xerif (Donated by the Foundation project, ss13.org)

/mob/living/carbon/alien/humanoid/special
	has_fine_manipulation = 1
	var/xcom_state

	New()
		..()
		spawn (1)
			var/datum/reagents/R = new/datum/reagents(100)
			reagents = R
			R.my_atom = src

			mind = new()
			mind.key = key
			mind.special_role = "Special Xeno"

			name = "[name] ([rand(1, 1000)])"
			real_name = name

			src.stand_icon = new /icon('xcomalien.dmi', xcom_state)
			src.lying_icon = new /icon('xcomalien.dmi', xcom_state)
			src.icon = src.stand_icon

			remove_special_verbs()

			rebuild_appearance()

	death(gibbed)
		..()
		spawn(5)
			gib()

	Stat()
		statpanel("Status")
		if (src.client && src.client.holder)
			stat(null, "([x], [y], [z])")

		stat(null, "Intent: [src.a_intent]")
		stat(null, "Move Mode: [src.m_intent]")

		if (src.client.statpanel == "Status")
			if (src.internal)
				if (!src.internal.air_contents)
					del(src.internal)
				else
					stat("Internal Atmosphere Info", src.internal.name)
					stat("Tank Pressure", src.internal.air_contents.return_pressure())
					stat("Distribution Pressure", src.internal.distribute_pressure)
		return

	alien_talk()
		if(istype(src, /mob/living/carbon/alien/humanoid/special/etheral))
			..()
			return
		if(istype(src, /mob/living/carbon/alien/humanoid/special/sectoid))
			..()
			return
		return

/mob/living/carbon/alien/humanoid/special/proc/xcom_attack()
	return

/mob/living/carbon/alien/humanoid/special/proc/remove_special_verbs()
	verbs -= /mob/living/carbon/alien/humanoid/verb/plant
	verbs -= /mob/living/carbon/alien/humanoid/verb/ActivateHuggers
	verbs -= /mob/living/carbon/alien/humanoid/verb/whisp
	verbs -= /mob/living/carbon/alien/humanoid/verb/transfer_plasma
	verbs -= /mob/living/carbon/alien/humanoid/verb/corrode
	return