/obj/structure/particle_accelerator/fuel_chamber
	name = "EM Acceleration Chamber"
	desc_holder = "This is where the Alpha particles are accelerated to <b><i>radical speeds</i></b>."
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	icon_state = "fuel_chamber"
	reference = "fuel_chamber"

/obj/structure/particle_accelerator/fuel_chamber/update_icon()
	..()
	return