///Lavaproof, fireproof, fast mech with low armor and higher energy consumption, cannot strafe and has an internal ore box.
/obj/vehicle/sealed/mecha/working/clarke
	desc = "Combining man and machine for a better, stronger engineer. Can even resist lava!"
	name = "\improper Clarke"
	icon_state = "clarke"
	max_temperature = 65000
	max_integrity = 200
	movedelay = 1.25
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	lights_power = 7
	deflect_chance = 10
	step_energy_drain = 15 //slightly higher energy drain since you movin those wheels FAST
	armor = list(MELEE = 20, BULLET = 10, LASER = 20, ENERGY = 10, BOMB = 60, BIO = 0, RAD = 70, FIRE = 100, ACID = 100) //low armor to compensate for fire protection and speed
	max_equip = 7
	wreckage = /obj/structure/mecha_wreckage/clarke
	enter_delay = 40
	mecha_flags = ADDING_ACCESS_POSSIBLE | IS_ENCLOSED | HAS_LIGHTS

/obj/vehicle/sealed/mecha/working/clarke/Initialize()
	. = ..()
	var/obj/item/mecha_parts/mecha_equipment/orebox_manager/ME = new(src)
	ME.attach(src)

/obj/vehicle/sealed/mecha/working/clarke/Destroy()
	box.dump_box_contents()
	return ..()

/obj/vehicle/sealed/mecha/working/clarke/moved_inside(mob/living/carbon/human/H)
	. = ..()
	if(. && !HAS_TRAIT(H, TRAIT_DIAGNOSTIC_HUD))
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
		hud.add_hud_to(H)

/obj/vehicle/sealed/mecha/working/clarke/remove_occupant(mob/M)
	if(isliving(M) && HAS_TRAIT_FROM(M, TRAIT_DIAGNOSTIC_HUD, src))
		var/mob/living/L = M
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
		hud.remove_hud_from(L)
	return ..()

/obj/vehicle/sealed/mecha/working/clarke/mmi_moved_inside(obj/item/mmi/M, mob/user)
	. = ..()
	if(.)
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
		var/mob/living/brain/B = M.brainmob
		hud.add_hud_to(B)

//Ore Box Controls

///Special equipment for the Clarke mech, handles moving ore without giving the mech a hydraulic clamp and cargo compartment.
/obj/item/mecha_parts/mecha_equipment/orebox_manager
	name = "ore storage module"
	desc = "An automated ore box management device."
	icon = 'icons/obj/mining.dmi'
	icon_state = "bin"
	selectable = FALSE
	detachable = FALSE
	salvageable = FALSE
	/// Var to avoid istype checking every time the topic button is pressed. This will only work inside Clarke mechs.
	var/obj/vehicle/sealed/mecha/working/clarke/hostmech

/obj/item/mecha_parts/mecha_equipment/orebox_manager/attach(obj/vehicle/sealed/mecha/M)
	. = ..()
	if(istype(M, /obj/vehicle/sealed/mecha/working/clarke))
		hostmech = M

/obj/item/mecha_parts/mecha_equipment/orebox_manager/detach()
	hostmech = null //just in case
	return ..()

/obj/item/mecha_parts/mecha_equipment/orebox_manager/Topic(href,href_list)
	. = ..()
	if(!hostmech || !hostmech.box)
		return
	hostmech.box.dump_box_contents()

/obj/item/mecha_parts/mecha_equipment/orebox_manager/get_equip_info()
	return "[..()] [hostmech?.box ? "<a href='?src=[REF(src)];mode=0'>Unload Cargo</a>" : "Error"]"
