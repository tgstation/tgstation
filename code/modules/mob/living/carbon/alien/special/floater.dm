/mob/living/carbon/alien/humanoid/special/floater
	name = "Floater"
	desc = "These aliens are capable or flight through space and shit"
	xcom_state = "floater"

	New()
		..()
		var/obj/item/weapon/tank/jetpack/jetpack = new(src)
		jetpack.on = !(jetpack.on)
		back = jetpack
		return