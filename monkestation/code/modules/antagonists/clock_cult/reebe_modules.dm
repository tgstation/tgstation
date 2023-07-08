GLOBAL_LIST_EMPTY(abscond_markers)
/datum/lazy_template/reebe
	key = LAZY_TEMPLATE_KEY_OUTPOST_OF_COGS
	map_dir = "monkestation/_maps/lazy_templates"
	map_name = "reebe"

/// development helper proc for admins to run. to be removed
/proc/spawn_reebe()
	SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_OUTPOST_OF_COGS)

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
	if(ismob(mover))
		var/mob/passing_mob = mover
		if(IS_CLOCK(passing_mob))
			return FALSE
	for(var/mob/held_mob in mover.contents)
		if(IS_CLOCK(held_mob))
			return FALSE
	return ..()

/obj/effect/spawner/structure/window/clockwork
	name = "brass window spawner"
	icon_state = "bronzewindow_spawner"
	spawn_list = list(/obj/structure/grille, /obj/structure/window/reinforced/clockwork/fulltile)
