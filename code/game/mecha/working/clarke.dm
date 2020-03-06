/obj/mecha/working/clarke
	desc = "Combining man and machine for a better, stronger engineer. Can even resist lava!"
	name = "\improper Clarke"
	icon_state = "clarke"
	max_temperature = 65000
	max_integrity = 200
	step_in = 1.25
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	lights_power = 7
	deflect_chance = 10
	step_energy_drain = 15 //slightly higher energy drain since you movin those wheels FAST
	armor = list("melee" = 20, "bullet" = 10, "laser" = 20, "energy" = 10, "bomb" = 60, "bio" = 0, "rad" = 70, "fire" = 100, "acid" = 100) //low armor to compensate for fire protection and speed
	max_equip = 7
	wreckage = /obj/structure/mecha_wreckage/clarke
	enter_delay = 40
	canstrafe = FALSE
	var/obj/structure/ore_box/box

/obj/mecha/working/clarke/Initialize()
	. = ..()
	box = new /obj/structure/ore_box(src)
	var/obj/item/mecha_parts/mecha_equipment/ME = new /obj/item/mecha_parts/mecha_equipment/orebox_manager(src)
	ME.attach(src)

/obj/mecha/working/clarke/Destroy()
	box.dump_box_contents()
	return ..()

/obj/mecha/working/clarke/moved_inside(mob/living/carbon/human/H)
	. = ..()
	if(.)
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
		hud.add_hud_to(H)

/obj/mecha/working/clarke/go_out()
	if(isliving(occupant))
		var/mob/living/L = occupant
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
		hud.remove_hud_from(L)
	..()

/obj/mecha/working/clarke/mmi_moved_inside(obj/item/mmi/M, mob/user)
	. = ..()
	if(.)
		var/datum/atom_hud/hud = GLOB.huds[DATA_HUD_DIAGNOSTIC_ADVANCED]
		var/mob/living/brain/B = M.brainmob
		hud.add_hud_to(B)

////Ore Box Controls////

/obj/item/mecha_parts/mecha_equipment/orebox_manager //Special equipment for Clarke
	name = "ore storage module"
	desc = "An automated ore box management device."
	icon_state = "mecha_clamp" //None of this should matter, this shouldn't ever exist outside a mech anyway.
	selectable = FALSE
	detachable = FALSE
	salvageable = FALSE
	var/obj/mecha/working/clarke/hostmech //New var to avoid istype checking every time the topic button is pressed. This will only work inside Clarke mechs

/obj/item/mecha_parts/mecha_equipment/orebox_manager/attach(obj/mecha/M)
	if(istype(M, /obj/mecha/working/clarke))
		hostmech = M
	. = ..()

/obj/item/mecha_parts/mecha_equipment/orebox_manager/detach()
	hostmech = null //just in case
	. = ..()

/obj/item/mecha_parts/mecha_equipment/orebox_manager/Topic(href,href_list)
	..()
	if(!hostmech || !hostmech.box)
		return
	hostmech.box.dump_box_contents()

/obj/item/mecha_parts/mecha_equipment/orebox_manager/get_equip_info()
	return "[..()] [hostmech?.box?"<a href='?src=[REF(src)];mode=0'>Unload Cargo</a>":"Error"]"
