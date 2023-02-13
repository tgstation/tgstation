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
	/// The shadow mask applied to a client's screen
	var/atom/movable/screen/fov_shadow/visual_shadow

/datum/component/fov_handler/Initialize(fov_type = FOV_180_DEGREES)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/living/mob_parent = parent
	var/client/parent_client = mob_parent.client
	if(!parent_client) //Love client volatility!!
		qdel(src) //no QDEL hint for components, and we dont want this to print a warning regarding bad component application
		return

	for(var/atom/movable/screen/plane_master/plane_master as anything in mob_parent.hud_used.get_true_plane_masters(FIELD_OF_VISION_BLOCKER_PLANE))
		plane_master.unhide_plane(mob_parent)

	blocker_mask = new
	visual_shadow = new
	visual_shadow.alpha = parent_client?.prefs.read_preference(/datum/preference/numeric/fov_darkness)
	set_fov_angle(fov_type)
	on_dir_change(mob_parent, mob_parent.dir, mob_parent.dir)
	update_fov_size()
	update_mask()

/datum/component/fov_handler/Destroy()
	var/mob/living/mob_parent = parent
	for(var/atom/movable/screen/plane_master/plane_master as anything in mob_parent.hud_used.get_true_plane_masters(FIELD_OF_VISION_BLOCKER_PLANE))
		plane_master.hide_plane(mob_parent)

	if(applied_mask)
		remove_mask()
	if(blocker_mask) // In a case of early deletion due to volatile client
		QDEL_NULL(blocker_mask)
	if(visual_shadow) // In a case of early deletion due to volatile client
		QDEL_NULL(visual_shadow)
	return ..()

/datum/component/fov_handler/proc/set_fov_angle(new_angle)
	fov_angle = new_angle
	blocker_mask.icon_state = "[fov_angle]"
	visual_shadow.icon_state = "[fov_angle]_v"

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
	visual_shadow.transform = blocker_mask.transform = new_matrix.Scale(x_scale, y_scale)
	visual_shadow.transform = blocker_mask.transform = new_matrix.Translate(x_shift * 16, y_shift * 16)

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
	if(!parent_client) //Love client volatility!!
		return
	applied_mask = FALSE
	parent_client.screen -= blocker_mask
	parent_client.screen -= visual_shadow
	parent_mob.hud_used.always_visible_inventory -= blocker_mask
	parent_mob.hud_used.always_visible_inventory -= visual_shadow

/datum/component/fov_handler/proc/add_mask()
	var/mob/parent_mob = parent
	var/client/parent_client = parent_mob.client
	if(!parent_client) //Love client volatility!!
		return
	applied_mask = TRUE
	parent_client.screen += blocker_mask
	parent_client.screen += visual_shadow
	parent_mob.hud_used.always_visible_inventory += blocker_mask
	parent_mob.hud_used.always_visible_inventory += visual_shadow

/// When a direction of the user changes, so do the masks
/datum/component/fov_handler/proc/on_dir_change(mob/source, old_dir, new_dir)
	SIGNAL_HANDLER
	blocker_mask.dir = new_dir
	visual_shadow.dir = new_dir

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
