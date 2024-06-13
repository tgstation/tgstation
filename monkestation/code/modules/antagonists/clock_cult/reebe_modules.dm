GLOBAL_LIST_EMPTY(abscond_markers)

/// spawn the reebe z level and map template, lazy templates dont work because we need to give this ztraits
/proc/spawn_reebe(forced = FALSE)
	var/static/reebe_loaded
	if(forced)
		message_admins("Admin forcing reebe spawn, if it has already spawned this will break things unless you know what your doing.")
	else if(reebe_loaded)
		return FALSE

	reebe_loaded = TRUE
	var/datum/space_level/reebe_z = SSmapping.add_new_zlevel("Reebe", ZTRAITS_REEBE)
	if(!reebe_z)
		reebe_loaded = FALSE
		CRASH("Failed to create the Reebe Z level.")

	SSmapping.initialize_reserved_level(reebe_z.z_value)
	if(!SSmapping.reservation_ready["[reebe_z.z_value]"]) //if this is not true then the block reservation will sleep forever
		reebe_loaded = FALSE
		CRASH("Reebe Z level not in SSmapping.reservation_ready.")

	var/datum/turf_reservation/reservation = SSmapping.request_turf_block_reservation(101, 101, z_reservation = reebe_z.z_value)
	if(!reservation)
		reebe_loaded = FALSE
		CRASH("Failed to reserve a block for Reebe.")

	var/datum/map_template/reebe_template = new(path = "_maps/~monkestation/templates/reebe.dmm", cache = TRUE)
	if(!reebe_template.cached_map) //might not be needed, im just copying lazy template code and I cant figure out what cached maps are for in this case
		reebe_loaded = FALSE
		CRASH("Failed to cache template for loading Reebe.")

	if(!reebe_template.load(reservation.bottom_left_turfs[1]))
		reebe_loaded = FALSE
		CRASH("Failed to load the Reebe template.")
	return TRUE

/obj/effect/mob_spawn/corpse/human/blood_cultist
	name = "Blood Cultist"
	outfit = /datum/outfit/blood_cultist

/datum/outfit/blood_cultist
	name = "Blood Cultist"

	uniform = /obj/item/clothing/under/color/black
	suit = /obj/item/clothing/suit/hooded/cultrobes/alt
	shoes = /obj/item/clothing/shoes/cult/alt

/datum/outfit/blood_cultist/post_equip(mob/living/carbon/human/equipped, visualsOnly)
	equipped.eye_color_left = BLOODCULT_EYE
	equipped.eye_color_right = BLOODCULT_EYE
	equipped.update_body()

	var/obj/item/clothing/suit/hooded/hooded = locate() in equipped
	hooded.ToggleHood()

/obj/effect/mob_spawn/corpse/human/clock_cultist
	name = "Clock Cultist"
	outfit = /datum/outfit/clock

/obj/effect/landmark/late_cog_portals
	name = "reebe crew portal spawn"

//for the portal from the outpost to reebe
/obj/effect/landmark/abscond_marker
	name = "abscond marker"
	icon = 'monkestation/icons/effects/landmarks_static.dmi'
	icon_state = "clockwork_orange"

/obj/effect/landmark/abscond_marker/Initialize(mapload)
	. = ..()
	GLOB.abscond_markers += src

/obj/effect/landmark/abscond_marker/Destroy()
	. = ..()
	GLOB.abscond_markers -= src

/obj/effect/servant_blocker
	name = "servant Blocker"
	icon = 'monkestation/icons/obj/clock_cult/clockwork_effects.dmi'
	icon_state = "servant_blocker"
	anchored = TRUE

/obj/effect/servant_blocker/CanPass(atom/movable/mover, border_dir)
	for(var/mob/held_mob in mover.get_all_contents())
		if(IS_CLOCK(held_mob))
			return FALSE
	return ..()

/obj/effect/spawner/structure/window/clockwork
	name = "brass window spawner"
	icon_state = "bronzewindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/clockwork/fulltile)
