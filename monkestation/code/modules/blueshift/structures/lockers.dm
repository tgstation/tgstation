/obj/structure/closet/shuttle/closet_update_overlays(list/new_overlays)
	. = new_overlays
	if(enable_door_overlay && !is_animating_door)
		if(opened && has_opened_overlay)
			var/mutable_appearance/door_overlay = mutable_appearance(icon, "[icon_door || icon_state]_open", alpha = src.alpha)	//This was the only change, adding icon_door; TG wouldnt want it.
			. += door_overlay
			door_overlay.overlays += emissive_blocker(door_overlay.icon, door_overlay.icon_state, src, alpha = door_overlay.alpha) // If we don't do this the door doesn't block emissives and it looks weird.
		else if(has_closed_overlay)
			. += "[icon_door || icon_state]_door"
//TG won't ever really need this because their lockers with non-matching fronts dont have non-matching backs; so I simply re-define the proc for our shuttleclosets

/obj/structure/closet/shuttle
	anchored = TRUE
	density = TRUE
	can_be_unanchored = FALSE
	icon = 'monkestation/code/modules/blueshift/icons/obj/closet.dmi'
	icon_state = "wallcloset"
	icon_door = "wallcloset_mesh"
	door_anim_time = 0 //Somebody needs to remove the hard-sprited shuttles, or at least their lockers. These are a sin.

/obj/structure/closet/shuttle/white
	icon_state = "wallcloset_white"
	icon_door = "wallcloset_white"

/obj/structure/closet/shuttle/emergency
	name = "emergency closet"
	desc = "It's a storage unit for emergency breath masks and O2 tanks."
	icon_door = "wallcloset_o2"

/obj/structure/closet/shuttle/emergency/PopulateContents()
	for (var/i in 1 to 2)
		new /obj/item/tank/internals/emergency_oxygen/engi(src)
	new /obj/item/storage/toolbox/emergency(src)

/obj/structure/closet/shuttle/emergency/white
	icon_state = "wallcloset_white"

/obj/structure/closet/shuttle/medical
	name = "first-aid closet"
	desc = "It's a storage unit for emergency medical supplies."
	icon_door = "wallcloset_med"

/obj/structure/closet/shuttle/medical/PopulateContents()
	new /obj/item/storage/medkit/emergency(src)
	new /obj/item/healthanalyzer(src)
	new /obj/item/reagent_containers/hypospray(src)

/obj/structure/closet/shuttle/medical/white
	icon_state = "wallcloset_white"

/obj/structure/closet/shuttle/mining
	desc = "It's a storage unit for emergency breath masks, O2 tanks, and a pressure suit."
	icon_state = "wallcloset_white"
	icon_door = "wallcloset_mining"

/obj/structure/closet/shuttle/mining/PopulateContents()
	for (var/i in 1 to 2)
		new /obj/item/tank/internals/emergency_oxygen/engi(src)
		new /obj/item/clothing/mask/breath(src)
	new /obj/item/storage/toolbox/emergency(src)
	new /obj/item/clothing/head/helmet/space(src)
	new /obj/item/clothing/suit/space(src)

/obj/structure/closet/shuttle/engivent
	wall_mounted = TRUE
	name = "engine ventilation"
	desc = "An exhaust vent for the shuttle's engines. It looks just big enough to fit a person..."
	icon_state = "vent"
	icon_door = "vent"

//Generic Wall Closets - mount onto a wall, will end up storing anything that's on the tile it was placed from and 'occupies'.
//Mob Size is small so that it doesn't end up storing players standing on those tiles.
/obj/structure/closet/generic/wall
	door_anim_squish = 0.3
	door_anim_angle = 115
	door_hinge_x = -8.5
	wall_mounted = TRUE
	max_mob_size = MOB_SIZE_SMALL
	density = TRUE
	anchored = TRUE
	anchorable = FALSE //Prevents it being unwrenched and dragged around. Gotta unweld it!
	icon = 'monkestation/code/modules/blueshift/icons/obj/closet_wall.dmi'
	icon_state = "locker_wall"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/closet/generic/wall, 32)

/obj/structure/closet/emcloset/wall
	door_anim_squish = 0.3
	door_anim_angle = 115
	door_hinge_x = -8.5
	wall_mounted = TRUE
	max_mob_size = MOB_SIZE_SMALL
	density = TRUE
	anchored = TRUE
	anchorable = FALSE
	icon = 'monkestation/code/modules/blueshift/icons/obj/closet_wall.dmi'
	icon_state = "emergency_wall"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/closet/emcloset/wall, 32)

/obj/structure/closet/firecloset/wall
	door_anim_squish = 0.3
	door_anim_angle = 115
	door_hinge_x = -8.5
	wall_mounted = TRUE
	max_mob_size = MOB_SIZE_SMALL
	density = TRUE
	anchored = TRUE
	anchorable = FALSE
	icon = 'monkestation/code/modules/blueshift/icons/obj/closet_wall.dmi'
	icon_state = "fire_wall"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/closet/firecloset/wall, 32)

//These two are pre-locked versions of closet/generic/wall, for mapping only
/obj/structure/closet/secure_closet/wall
	door_anim_squish = 0.3
	door_anim_angle = 115
	door_hinge_x = -8.5
	wall_mounted = TRUE
	max_mob_size = MOB_SIZE_SMALL
	density = TRUE
	anchored = TRUE
	anchorable = FALSE
	icon = 'monkestation/code/modules/blueshift/icons/obj/closet_wall.dmi'
	icon_state = "locker_wall"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/closet/secure_closet/wall, 32)

/obj/structure/closet/secure_closet/personal/wall
	door_anim_squish = 0.3
	door_anim_angle = 115
	door_hinge_x = -8.5
	wall_mounted = TRUE
	max_mob_size = MOB_SIZE_SMALL
	density = TRUE
	anchored = TRUE
	anchorable = FALSE
	icon = 'monkestation/code/modules/blueshift/icons/obj/closet_wall.dmi'
	icon_state = "locker_wall"

MAPPING_DIRECTIONAL_HELPERS(/obj/structure/closet/secure_closet/personal/wall, 32)

//These procs create empty subtypes, for when it's placed by a user rather than mapped in...
//Secure/personal don't get these since they're made with airlock electronics
/obj/structure/closet/generic/wall/empty/PopulateContents()
	return

/obj/structure/closet/emcloset/wall/empty/PopulateContents()
	return

/obj/structure/closet/firecloset/wall/empty/PopulateContents()
	return

//Wallmounts, for rebuilding the wall lockers above
/obj/item/wallframe/closet
	name = "wall mounted closet"
	desc = "It's a wall mounted storage unit for... well, whatever you put in this one. Apply to wall to use."
	icon = 'monkestation/code/modules/blueshift/icons/obj/closet_wall.dmi'
	icon_state = "locker_mount"
	result_path = /obj/structure/closet/generic/wall/empty
	pixel_shift = 32

/obj/item/wallframe/emcloset
	name = "wall mounted emergency closet"
	desc = "It's a wall mounted storage unit for emergency breath masks and O2 tanks. Apply to wall to use."
	icon = 'monkestation/code/modules/blueshift/icons/obj/closet_wall.dmi'
	icon_state = "emergency_mount"
	result_path = /obj/structure/closet/emcloset/wall/empty
	pixel_shift = 32

/obj/item/wallframe/firecloset
	name = "wall mounted fire-safety closet"
	desc = "It's a wall mounted storage unit for fire-fighting supplies. Apply to wall to use."
	icon = 'monkestation/code/modules/blueshift/icons/obj/closet_wall.dmi'
	icon_state = "fire_mount"
	result_path = /obj/structure/closet/firecloset/wall/empty
	pixel_shift = 32
