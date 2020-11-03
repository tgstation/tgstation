/datum/component/riding/mulebot/handle_specials()
	. = ..()
	var/atom/movable/parent_movable = parent
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 12), TEXT_SOUTH = list(0, 12), TEXT_EAST = list(0, 12), TEXT_WEST = list(0, 12)))
	set_vehicle_dir_layer(SOUTH, parent_movable.layer) //vehicles default to ABOVE_MOB_LAYER while moving, let's make sure that doesn't happen while a mob is riding us.
	set_vehicle_dir_layer(NORTH, parent_movable.layer)
	set_vehicle_dir_layer(EAST, parent_movable.layer)
	set_vehicle_dir_layer(WEST, parent_movable.layer)


/datum/component/riding/cow/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 8), TEXT_SOUTH = list(0, 8), TEXT_EAST = list(-2, 8), TEXT_WEST = list(2, 8)))
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)


/datum/component/riding/bear/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(1, 8), TEXT_SOUTH = list(1, 8), TEXT_EAST = list(-3, 6), TEXT_WEST = list(3, 6)))
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(WEST, ABOVE_MOB_LAYER)


/datum/component/riding/carp
	override_allow_spacemove = TRUE

/datum/component/riding/carp/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 13), TEXT_SOUTH = list(0, 15), TEXT_EAST = list(-2, 12), TEXT_WEST = list(2, 12)))
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)


/datum/component/riding/megacarp/handle_specials()
	. = ..()
	var/atom/movable/parent_movable = parent
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(1, 8), TEXT_SOUTH = list(1, 8), TEXT_EAST = list(-3, 6), TEXT_WEST = list(3, 6)))
	set_vehicle_dir_offsets(SOUTH, parent_movable.pixel_x, 0)
	set_vehicle_dir_offsets(NORTH, parent_movable.pixel_x, 0)
	set_vehicle_dir_offsets(EAST, parent_movable.pixel_x, 0)
	set_vehicle_dir_offsets(WEST, parent_movable.pixel_x, 0)
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)

/datum/component/riding/vatbeast
	override_allow_spacemove = TRUE
	can_use_abilities = TRUE

/datum/component/riding/vatbeast/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 15), TEXT_SOUTH = list(0, 15), TEXT_EAST = list(-10, 15), TEXT_WEST = list(10, 15)))
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)

/datum/component/riding/goliath
	keytype = /obj/item/key/lasso

/datum/component/riding/goliath/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 8), TEXT_SOUTH = list(0, 8), TEXT_EAST = list(-2, 8), TEXT_WEST = list(2, 8)))
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)



/datum/component/riding/atv
	keytype = /obj/item/key
	rider_check_flags = REQUIRES_LEGS | REQUIRES_ARMS | UNBUCKLE_DISABLED_RIDER
	vehicle_move_delay = 1.5

/datum/component/riding/atv/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)

/datum/component/riding/bicycle
	rider_check_flags = REQUIRES_LEGS | REQUIRES_ARMS | UNBUCKLE_DISABLED_RIDER
	vehicle_move_delay = 0

/datum/component/riding/bicycle/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))



/datum/component/riding/lavaboat
	rider_check_flags = NONE // not sure
	keytype = /obj/item/oar
	var/allowed_turf = /turf/open/lava

/datum/component/riding/lavaboat/handle_specials()
	. = ..()
	allowed_turf_typecache = typecacheof(allowed_turf)

/datum/component/riding/lavaboat/dragonboat
	vehicle_move_delay = 1

/datum/component/riding/lavaboat/dragonboat/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(1, 2), TEXT_SOUTH = list(1, 2), TEXT_EAST = list(1, 2), TEXT_WEST = list( 1, 2)))

/datum/component/riding/lavaboat/dragonboat
	vehicle_move_delay = 1
	keytype = null


/datum/component/riding/janicart
	keytype = /obj/item/key/janitor

/datum/component/riding/janicart/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 7), TEXT_EAST = list(-12, 7), TEXT_WEST = list( 12, 7)))

/datum/component/riding/scooter
	rider_check_flags = REQUIRES_LEGS | REQUIRES_ARMS | UNBUCKLE_DISABLED_RIDER

/datum/component/riding/scooter/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0), TEXT_SOUTH = list(-2), TEXT_EAST = list(0), TEXT_WEST = list( 2)))

/datum/component/riding/scooter/skateboard
	vehicle_move_delay = 1.5
	rider_check_flags = REQUIRES_LEGS | UNBUCKLE_DISABLED_RIDER

/datum/component/riding/scooter/skateboard/handle_specials()
	. = ..()
	set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)

/datum/component/riding/scooter/skateboard/wheelys
	vehicle_move_delay = 0

/datum/component/riding/scooter/skateboard/wheelys/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0), TEXT_SOUTH = list(0), TEXT_EAST = list(0), TEXT_WEST = list(0)))

/datum/component/riding/scooter/skateboard/wheelys/rollerskates
	vehicle_move_delay = 1.5

/datum/component/riding/scooter/skateboard/wheelys/skishoes
	vehicle_move_delay = 1

/datum/component/riding/scooter/skateboard/wheelys/skishoes/handle_specials()
	. = ..()
	allowed_turf_typecache = typecacheof(/turf/open/floor/plating/asteroid/snow/icemoon)

/datum/component/riding/secway
	keytype = /obj/item/key/security
	vehicle_move_delay = 1.75
	rider_check_flags = REQUIRES_LEGS | REQUIRES_ARMS | UNBUCKLE_DISABLED_RIDER

/datum/component/riding/secway/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 4), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(0, 4), TEXT_WEST = list( 0, 4)))


/datum/component/riding/speedbike
	vehicle_move_delay = 0
	override_allow_spacemove = TRUE
	rider_check_flags = REQUIRES_LEGS | REQUIRES_ARMS | UNBUCKLE_DISABLED_RIDER

/datum/component/riding/speedbike/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, -8), TEXT_SOUTH = list(0, 4), TEXT_EAST = list(-10, 5), TEXT_WEST = list( 10, 5)))
	set_vehicle_dir_offsets(NORTH, -16, -16)
	set_vehicle_dir_offsets(SOUTH, -16, -16)
	set_vehicle_dir_offsets(EAST, -18, 0)
	set_vehicle_dir_offsets(WEST, -18, 0)


/datum/component/riding/wheelchair
	vehicle_move_delay = 0
	rider_check_flags = REQUIRES_ARMS

/datum/component/riding/wheelchair/handle_specials()
	. = ..()
	set_vehicle_dir_layer(SOUTH, OBJ_LAYER)
	set_vehicle_dir_layer(NORTH, ABOVE_MOB_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)


/datum/component/riding/car
	//vehicle_move_delay = movedelay
	vehicle_move_delay = 1
	slowvalue = 0

/datum/component/riding/car/clowncar
	keytype = /obj/item/bikehorn

/datum/component/riding/car/speedwagon
	vehicle_move_delay = 0

/datum/component/riding/car/speedwagon/handle_specials()
	. = ..()
	set_riding_offsets(1, list(TEXT_NORTH = list(-10, -4), TEXT_SOUTH = list(16, 3), TEXT_EAST = list(-4, 30), TEXT_WEST = list(4, -3)))
	set_riding_offsets(2, list(TEXT_NORTH = list(19, -5, 4), TEXT_SOUTH = list(-13, 3, 4), TEXT_EAST = list(-4, -3, 4.1), TEXT_WEST = list(4, 28, 3.9)))
	set_riding_offsets(3, list(TEXT_NORTH = list(-10, -18, 4.2), TEXT_SOUTH = list(16, 25, 3.9), TEXT_EAST = list(-22, 30), TEXT_WEST = list(22, -3, 4.1)))
	set_riding_offsets(4, list(TEXT_NORTH = list(19, -18, 4.2), TEXT_SOUTH = list(-13, 25, 3.9), TEXT_EAST = list(-22, 3, 3.9), TEXT_WEST = list(22, 28)))
	set_vehicle_dir_offsets(NORTH, -48, -48)
	set_vehicle_dir_offsets(SOUTH, -48, -48)
	set_vehicle_dir_offsets(EAST, -48, -48)
	set_vehicle_dir_offsets(WEST, -48, -48)
	for(var/i in GLOB.cardinals)
		set_vehicle_dir_layer(i, BELOW_MOB_LAYER)
