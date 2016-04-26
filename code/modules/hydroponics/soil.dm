/obj/machinery/portable_atmospherics/hydroponics/soil
	name = "soil"
	icon = 'icons/obj/hydroponics.dmi'
	icon_state = "soil"
	density = 0
	use_power = 0
	draw_warnings = 0

	machine_flags = 0 // THIS SHOULD NOT EVER BE UNWRENCHED AND IT SHOULD NOT EVER SPAWN MACHINE FRAMES, MY GOD

/obj/machinery/portable_atmospherics/hydroponics/soil/attackby(var/obj/item/W, var/mob/user)
	if(istype(W, /obj/item/weapon/pickaxe/shovel))
		if(!seed)
			to_chat(user, "You clear up [src]!")
			new /obj/item/weapon/ore/glass(loc)//we get some of the dirt back
			new /obj/item/weapon/ore/glass(loc)
			qdel(src)
			return 1
		else
			..()
	else
		return ..()

/obj/machinery/portable_atmospherics/hydroponics/soil/smashDestroy(destroy_chance)
	qdel(src)

/obj/machinery/portable_atmospherics/hydroponics/soil/New()
	..()
	verbs -= /obj/machinery/portable_atmospherics/hydroponics/verb/close_lid
	verbs -= /obj/machinery/portable_atmospherics/hydroponics/verb/set_label
	verbs -= /obj/machinery/portable_atmospherics/hydroponics/verb/light_toggle
	component_parts = list()
