/// Component which handles Field of View masking for clients. FoV attributes are at /mob/living
/datum/component/fov_handler
	/// Currently applied x size of the fov masks
	var/current_fov_x = BASE_FOV_MASK_X_DIMENSION
	/// Currently applied y size of the fov masks
	var/current_fov_y = BASE_FOV_MASK_Y_DIMENSION
	/// Whether we are applying the masks now
	var/applied_mask = FALSE
	/// The angle of the mask we are applying
	var/fov_angle = FOV_180_DEGREES
	/// The blocker mask applied to a client's screen
	var/atom/movable/screen/fov_blocker/blocker_mask

/datum/component/fov_handler/Initialize(fov_type = FOV_180_DEGREES)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/mob_parent = parent
	var/client/parent_client = mob_parent.client
	if(!parent_client) //Love client volatility!!
		qdel(src) //no QDEL hint for components, and we dont want this to print a warning regarding bad component application
		return

	ADD_TRAIT(mob_parent, TRAIT_FOV_APPLIED, REF(src))

	blocker_mask = new
	set_fov_angle(fov_type)
	on_dir_change(mob_parent, mob_parent.dir, mob_parent.dir)
	update_fov_size()
	update_mask()

/datum/component/fov_handler/Destroy()
	var/mob/living/mob_parent = parent

	REMOVE_TRAIT(mob_parent, TRAIT_FOV_APPLIED, REF(src))
	if(applied_mask)
		remove_mask()
	if(blocker_mask) // In a case of early deletion due to volatile client
		QDEL_NULL(blocker_mask)
	return ..()

/datum/component/fov_handler/proc/set_fov_angle(new_angle)
	fov_angle = new_angle
	blocker_mask.icon_state = "[fov_angle > 0 ? fov_angle : (360 + fov_angle)]"

/// Updates the size of the FOV masks by comparing them to client view size.
/datum/component/fov_handler/proc/update_fov_size()
	SIGNAL_HANDLER
	var/mob/parent_mob = parent
	var/client/parent_client = parent_mob.client
	if(!parent_client) //Love client volatility!!
		return
	var/list/view_size = getviewsize(parent_client.view)
	if(view_size[1] == current_fov_x && view_size[2] == current_fov_y)
		return
	current_fov_x = BASE_FOV_MASK_X_DIMENSION
	current_fov_y = BASE_FOV_MASK_Y_DIMENSION
	var/matrix/new_matrix = new
	var/x_shift = view_size[1] - current_fov_x
	var/y_shift = view_size[2] - current_fov_y
	var/x_scale = view_size[1] / current_fov_x
	var/y_scale = view_size[2] / current_fov_y
	current_fov_x = view_size[1]
	current_fov_y = view_size[2]
	if (fov_angle < 0)
		x_scale *= -1
		y_scale *= -1
	blocker_mask.transform = new_matrix.Scale(x_scale, y_scale)
	blocker_mask.transform = new_matrix.Translate(x_shift * 16, y_shift * 16)

/// Updates the mask application to client by checking `stat` and `eye`
/datum/component/fov_handler/proc/update_mask()
	SIGNAL_HANDLER
	var/mob/parent_mob = parent
	var/client/parent_client = parent_mob.client
	if(!parent_client) //Love client volatility!!
		return
	var/user_living = parent_mob != DEAD
	var/atom/top_most_atom = get_atom_on_turf(parent_mob)
	var/user_extends_eye = parent_client.eye != top_most_atom
	var/should_apply_mask = user_living && !user_extends_eye

	if(should_apply_mask == applied_mask)
		return

	if(should_apply_mask)
		add_mask()
	else
		remove_mask()

/datum/component/fov_handler/proc/remove_mask()
	var/mob/parent_mob = parent
	var/client/parent_client = parent_mob.client
	// Prevents stupid ass hard deletes
	parent_mob.hud_used.always_visible_inventory -= blocker_mask
	if(!parent_client) //Love client volatility!!
		return
	applied_mask = FALSE
	parent_client.screen -= blocker_mask

/datum/component/fov_handler/proc/add_mask()
	var/mob/parent_mob = parent
	var/client/parent_client = parent_mob.client
	if(!parent_client) //Love client volatility!!
		return
	applied_mask = TRUE
	parent_client.screen += blocker_mask
	parent_mob.hud_used.always_visible_inventory += blocker_mask

/// When a direction of the user changes, so do the masks
/datum/component/fov_handler/proc/on_dir_change(mob/source, old_dir, new_dir)
	SIGNAL_HANDLER
	blocker_mask.dir = new_dir

/// When a mob logs out, delete the component
/datum/component/fov_handler/proc/mob_logout(mob/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/component/fov_handler/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_ATOM_DIR_CHANGE, PROC_REF(on_dir_change))
	RegisterSignal(parent, COMSIG_LIVING_DEATH, PROC_REF(update_mask))
	RegisterSignal(parent, COMSIG_LIVING_REVIVE, PROC_REF(update_mask))
	RegisterSignal(parent, COMSIG_MOB_CLIENT_CHANGE_VIEW, PROC_REF(update_fov_size))
	RegisterSignal(parent, COMSIG_MOB_RESET_PERSPECTIVE, PROC_REF(update_mask))
	RegisterSignal(parent, COMSIG_MOB_LOGOUT, PROC_REF(mob_logout))

/datum/component/fov_handler/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_MOB_RESET_PERSPECTIVE, COMSIG_ATOM_DIR_CHANGE, COMSIG_LIVING_DEATH, COMSIG_LIVING_REVIVE, COMSIG_MOB_LOGOUT))
