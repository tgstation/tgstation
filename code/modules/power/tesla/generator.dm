/obj/machinery/the_singularitygen/tesla
	name = "energy ball generator"
	desc = "Makes the wardenclyffe look like a child's plaything when shot with a particle accelerator."
	icon = 'icons/obj/tesla_engine/tesla_generator.dmi'
	icon_state = "TheSingGen"
	creation_type = /obj/singularity/energy_ball

/obj/machinery/the_singularitygen/tesla/tesla_act(power, explosive = FALSE)
	if(explosive)
		energy += power
