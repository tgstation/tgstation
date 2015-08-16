/obj/item/device/rcd/matter/engineering
	schematics = list(
	/datum/rcd_schematic/decon,
	/datum/rcd_schematic/con_floors,
	/datum/rcd_schematic/con_walls,
	/datum/rcd_schematic/con_airlock
	)

	var/disabled		= 0

/obj/item/device/rcd/matter/engineering/afterattack(var/atom/A, var/mob/user)
	if(disabled)
		return

	return ..()

/obj/item/device/rcd/matter/engineering/suicide_act(var/mob/user)
	visible_message("<span class='danger'>[user] is using the deconstruct function on \the [src] on \himself! It looks like \he's  trying to commit suicide!</span>")
	return (user.death(1))

/obj/item/device/rcd/borg/engineering
	schematics = list(
	/datum/rcd_schematic/decon,
	/datum/rcd_schematic/con_floors,
	/datum/rcd_schematic/con_walls,
	/datum/rcd_schematic/con_airlock/no_access
	)

/obj/item/weapon/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter in a cartridge form, used in various fabricators."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	opacity = 0
	density = 0
	anchored = 0.0
	origin_tech = "materials=2"
	w_class = 2.0
	starting_materials = list(MAT_IRON = 30000, MAT_GLASS = 15000)
	w_type = RECYK_ELECTRONIC

/obj/item/weapon/rcd_ammo/attackby(var/obj/O, mob/user)
	if(is_type_in_list(O, list(/obj/item/device/rcd/matter/engineering,  /obj/item/device/rcd/matter/rsf)) || (istype(O, /obj/item/device/material_synth) && !istype(O, /obj/item/device/material_synth/robot)))
		return O.attackby(src, user)
