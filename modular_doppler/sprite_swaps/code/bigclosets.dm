/obj/structure/closet/emcloset
	icon = '/modular_doppler/sprite_swaps/icons/elockers.dmi'

/obj/structure/closet/emcloset/proc/animate_door(closing = FALSE)
	is_animating_door = FALSE

/obj/structure/closet/firecloset
	desc = "A large closet to store fire suppression equipment and materials.
	icon = '/modular_doppler/sprite_swaps/icons/elockers.dmi'
	max_integrity = 300
	contents_thermal_insulation = 1

/obj/structure/closet/firecloset/proc/animate_door(closing = FALSE)
	is_animating_door = FALSE

/obj/machinery/light_switch/update_overlays()
	. = ..()
	if(machine_stat & NOPOWER)
		return ..()
	. += emissive_appearance(icon, "[base_icon_state]-emissive[area.lightswitch ? "-on" : "-off"]", src, alpha = src.alpha)
