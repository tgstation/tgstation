// lots of ctrl c ctrl v from fov component no fucks given
/datum/component/shadowcasting
	/// Whether we are applying the masks now or not
	var/applied_shadow = FALSE
	/// Atom that shows shadowcasting overlays
	var/atom/movable/shadowcasting_holder/visual_shadow

/datum/component/shadowcasting/Initialize()
	. = ..()
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	var/mob/mob_parent = parent
	var/client/parent_client = mob_parent.client
	if(!parent_client) //Love client volatility!!
		qdel(src) //no QDEL hint for components, and we dont want this to print a warning regarding bad component application
		return

	for(var/atom/movable/screen/plane_master/plane_master as anything in mob_parent.hud_used.get_true_plane_masters(SHADOWCASTING_PLANE))
		plane_master.unhide_plane(mob_parent)

	visual_shadow = new
	update_shadow()

/datum/component/shadowcasting/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOVABLE_MOVED, PROC_REF(update_shadow))
	RegisterSignal(parent, COMSIG_MOB_RESET_PERSPECTIVE, PROC_REF(update_shadow))
	RegisterSignal(parent, COMSIG_MOB_SIGHT_CHANGE, PROC_REF(update_shadow))
	RegisterSignal(parent, COMSIG_MOB_LOGOUT, PROC_REF(mob_logout))

/datum/component/shadowcasting/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_MOVABLE_MOVED,
		COMSIG_MOB_RESET_PERSPECTIVE,
		COMSIG_MOB_SIGHT_CHANGE,
		COMSIG_MOB_LOGOUT,
	))

/datum/component/shadowcasting/Destroy(force, silent)
	var/mob/living/mob_parent = parent
	for(var/atom/movable/screen/plane_master/plane_master as anything in mob_parent.hud_used.get_true_plane_masters(SHADOWCASTING_PLANE))
		plane_master.hide_plane(mob_parent)

	if(applied_shadow)
		remove_shadow()
	if(visual_shadow)
		QDEL_NULL(visual_shadow)
	return ..()

/datum/component/shadowcasting/proc/update_shadow()
	SIGNAL_HANDLER
	var/mob/living/parent_mob = parent
	var/client/parent_client = parent_mob.client
	if(!parent_client) //Love client volatility!!
		return

	var/user_turf = get_turf(parent_mob)
	var/atom/top_most_atom = get_atom_on_turf(parent_mob)
	var/user_extends_eye = parent_client.eye != top_most_atom
	var/user_sees_turfs = parent_mob.sight & SEE_TURFS
	var/user_blind = parent_mob.sight & BLIND

	var/should_apply_mask = user_turf && !user_extends_eye && !user_sees_turfs && !user_blind
	if(should_apply_mask)
		add_shadow(user_turf)
	else
		remove_shadow()

/datum/component/shadowcasting/proc/add_shadow(turf/mob_turf)
	var/mob/parent_mob = parent
	var/client/parent_client = parent_mob.client
	if(!parent_client) //Love client volatility!!
		return
	applied_shadow = TRUE
	if(!mob_turf.shadowcasting_image)
		mob_turf.update_shadowcasting_image()
	visual_shadow.reflector.overlays = null
	visual_shadow.reflector.overlays += mob_turf.shadowcasting_image
	visual_shadow.loc = get_turf(parent_mob)
	parent_client.images |= visual_shadow.reflector

/datum/component/shadowcasting/proc/remove_shadow()
	var/mob/parent_mob = parent
	var/client/parent_client = parent_mob.client
	if(!parent_client) //Love client volatility!!
		return
	applied_shadow = FALSE
	visual_shadow.moveToNullspace()
	parent_client.images -= visual_shadow.reflector

/// When a mob logs out, delete the component
/datum/component/shadowcasting/proc/mob_logout(mob/source)
	SIGNAL_HANDLER
	qdel(src)
