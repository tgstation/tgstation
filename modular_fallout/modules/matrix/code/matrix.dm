#define MATRIX_MAX_ITERATIONS 100

/turf/closed/indestructible/transition
	name = "transit matrix"
	desc = "It looks like walking into this will take you someplace else."
	icon = 'modular_fallout/modules/matrix/icons/matrix.dmi'
	icon_state = "matrixblue"
	/// Is the matrix currently being used?
	var/in_use = FALSE
	/// Target destination z level
	var/target_z
	/// Target destination x co-ordinate
	var/target_x
	/// Target destination y co-ordinate
	var/target_y


/turf/closed/indestructible/transition/is_transition_turf()
	if(target_z || target_x || target_y)
		return TRUE


/turf/closed/indestructible/transition/Bumped(atom/movable/teleported_atom)
	. = ..()

	if(!check_coord_validity() || teleported_atom.pulledby)
		return
	var/turf/destination_turf = locate(target_x, target_y, target_z)
	var/current_iterations = 0
	while(destination_turf.density || istype(destination_turf.loc, /area/shuttle)) // Extend towards the center of the map, trying to look for a better place to arrive
		if(current_iterations++ >= MATRIX_MAX_ITERATIONS)
			log_game("MATRIX Z-TRANSIT ERROR: Could not find a safe place to land [teleported_atom] within [MATRIX_MAX_ITERATIONS] iterations.")
			break

		if(target_x < 128)
			target_x++
		else
			target_x--

		if(target_y < 128)
			target_y++
		else
			target_y--

		destination_turf = locate(target_x, target_y, target_z)

	var/atom/movable/dragged_atom = teleported_atom.pulling
	teleported_atom.forceMove(destination_turf)
	if(dragged_atom)
		// target the turf behind them, for the dragged thing
		var/turf/target_turf = get_step(teleported_atom.loc,turn(teleported_atom.dir, 180))
		dragged_atom.forceMove(target_turf)
		teleported_atom.start_pulling(dragged_atom)

	//now we're on the new z_level, proceed the space drifting
	stoplag()//Let a diagonal move finish, if necessary


/turf/closed/indestructible/transition/attack_ghost(mob/dead/observer/user)
	if(!check_coord_validity())
		return ..()
	var/turf/target_turf = locate(target_x, target_y, target_z)
	user.forceMove(target_turf)


/turf/closed/indestructible/transition/proc/check_coord_validity()
	if(!target_z || !target_x || !target_y)
		return FALSE
	return TRUE


#undef MATRIX_MAX_ITERATIONS
