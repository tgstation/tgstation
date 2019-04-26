/obj/mecha/working/aquifer
	desc = "Autonomous Power Loader Unit MK-I. Designed primarily around heavy lifting, the Ripley can be outfitted with utility equipment to fill a number of roles."
	name = "\improper Aquifer"
	icon_state = "aquifer"
	silicon_icon_state = "aquifer_open"
	step_in = 1.5
	max_integrity = 150
	lights_power = 7
	deflect_chance = 0
	armor = list("melee" = 0, "bullet" = 0, "laser" = 30, "energy" = 20, "bomb" = 40, "bio" = 0, "rad" = 20, "fire" = 100, "acid" = 100)
	max_equip = 4
	wreckage = /obj/structure/mecha_wreckage/aquifer
	operation_req_access = list(ACCESS_HYDROPONICS)
	enclosed = FALSE
	enter_delay = 10
	exit_delay = 10

/obj/mecha/working/aquifer/Initialize()
	. = ..()
	create_reagents(1000)
	reagents.add_reagent("water", 1000)

/obj/mecha/working/aquifer/Topic()
	..()
	//if(href_list["siphon_nearby"])
		
	//return
