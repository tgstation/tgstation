/*Completely generic structures for use by mappers to create fake objects, i.e. display rooms*/
/obj/structure/showcase
	name = "showcase"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "showcase_1"
	desc = "A stand with the empty body of a cyborg bolted to it."
	density = 1
	anchored = 1

/obj/structure/showcase/fakeid
	name = "\improper Centcom identification console"
	desc = "You can use this to change ID's."
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"

/obj/structure/showcase/fakeid/Initialize()
	..()
	add_overlay("id")
	add_overlay("id_key")

/obj/structure/showcase/fakesec
	name = "\improper Centcom security records"
	desc = "Used to view and edit personnel's security records"
	icon = 'icons/obj/computer.dmi'
	icon_state = "computer"

/obj/structure/showcase/fakesec/Initialize()
	..()
	add_overlay("security")
	add_overlay("security_key")

/obj/structure/showcase/horrific_experiment
	name = "horrific experiment"
	desc = "Some sort of pod filled with blood and viscera. You swear you can see it moving..."
	icon = 'icons/obj/cloning.dmi'
	icon_state = "pod_g"

//Deconstructing
//Showcases can be any sprite, so it makes sense that they can't be constructed.
//However if a player wants to move an existing showcase or remove one, this is for that.

CONSTRUCTION_BLUEPRINT(/obj/structure/showcase, FALSE, FALSE)
	return newlist(
		/datum/construction_state/first{
			required_type_to_construct = /obj/item/stack/sheet/metal
			required_amount_to_construct = 4
			buildable = 0
		},
		/datum/construction_state{
			required_type_to_construct = /obj/item/weapon/screwdriver
			required_type_to_deconstruct = /obj/item/weapon/crowbar
			deconstruction_delay = 20
			deconstruction_message = "crowbar apart"
			construction_message = "rescrew"
			examine_message = "It has its screws loosened."
			//fastenable = TRUE	//OBJCONREF
		},
		/datum/construction_state/last{
			required_type_to_deconstruct = /obj/item/weapon/screwdriver
			deconstruction_message = "unscrew"
			examine_message = "The showcase is fully constructed."
			//fastenable = TRUE	//OBJCONREF
		}
	)
