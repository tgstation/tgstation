/datum/movable_physics_editor
	var/client/owner
	var/atom/movable/target
	var/datum/component/movable_physics/movable_physics

/datum/movable_physics_editor/New(user, atom/target)
	src.owner = CLIENT_FROM_VAR(user)
	src.target = target
	RegisterSignal(src.target, COMSIG_QDELETING, PROC_REF(target_deleted))
	src.movable_physics = target.GetComponent(/datum/component/movable_physics)
	if(!src.movable_physics)
		src.movable_physics = target.AddComponent(/datum/component/movable_physics)
	src.movable_physics.physics_flags |= MPHYSICS_PAUSED

/datum/movable_physics_editor/Destroy(force)
	owner = null
	if(target)
		UnregisterSignal(target, COMSIG_QDELETING)
	target = null
	movable_physics = null
	return ..()

/datum/movable_physics_editor/ui_state(mob/user)
	return GLOB.admin_state

/datum/movable_physics_editor/ui_data(mob/user)
	var/list/data = list()

	data["target_name"] = target.name
	data["physics_flags"] = movable_physics.physics_flags
	data["angle"] = movable_physics.angle
	data["horizontal_velocity"] = movable_physics.horizontal_velocity
	data["vertical_velocity"] = movable_physics.vertical_velocity
	data["horizontal_friction"] = movable_physics.horizontal_friction
	data["vertical_friction"] = movable_physics.vertical_friction
	data["horizontal_conservation_of_momentum"] = movable_physics.horizontal_conservation_of_momentum
	data["vertical_conservation_of_momentum"] = movable_physics.vertical_conservation_of_momentum
	data["z_floor"] = movable_physics.z_floor
	data["visual_angle_velocity"] = movable_physics.visual_angle_velocity
	data["visual_angle_friction"] = movable_physics.visual_angle_friction
	data["spin_speed"] = movable_physics.spin_speed
	data["spin_loops"] = movable_physics.spin_loops
	data["spin_clockwise"] = movable_physics.spin_clockwise
	data["bounce_spin_speed"] = movable_physics.bounce_spin_speed
	data["bounce_spin_loops"] = movable_physics.bounce_spin_loops
	data["bounce_spin_clockwise"] = movable_physics.bounce_spin_clockwise
	data["bounce_sound"] = movable_physics.bounce_sound

	return data

/datum/movable_physics_editor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MovablePhysicsTester")
		ui.open()

/datum/movable_physics_editor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	switch(action)
		if("edit_variable")
			var/var_name = params["variable"]
			INVOKE_ASYNC(owner, TYPE_PROC_REF(/client, modify_variables), movable_physics, var_name, TRUE)
		if("pause")
			if(movable_physics.physics_flags & MPHYSICS_PAUSED)
				movable_physics.physics_flags &= ~MPHYSICS_PAUSED
				if(!(movable_physics.physics_flags & MPHYSICS_MOVING))
					movable_physics.start_movement()
			else
				//no we don't call stop_movement() this is called paused for a reason
				movable_physics.physics_flags |= MPHYSICS_PAUSED
			return TRUE
		if("physics_chungus_deluxe")
			//changes everything to the physics chungus deluxe preset i guess
			movable_physics.horizontal_velocity = rand(4.5 * 100, 5.5 * 100) * 0.01
			movable_physics.vertical_velocity = rand(4 * 100, 4.5 * 100) * 0.01
			movable_physics.horizontal_friction = rand(0.2 * 100, 0.24 * 100) * 0.01
			movable_physics.vertical_friction = 10 * 0.05
			movable_physics.z_floor = 0
			movable_physics.visual_angle_velocity = rand(1 * 100, 3 * 100) * 0.01
			movable_physics.visual_angle_friction = 0.1
			return TRUE

/datum/movable_physics_editor/ui_close(mob/user)
	. = ..()
	qdel(src)

/datum/movable_physics_editor/proc/target_deleted(atom/movable/source)
	SIGNAL_HANDLER

	qdel(src)

/client/proc/open_movable_physics_editor(atom/in_atom)
	var/datum/movable_physics_editor/editor = new /datum/movable_physics_editor(src, in_atom)
	editor.ui_interact(mob)
