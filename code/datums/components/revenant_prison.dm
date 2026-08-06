// Radius of an area where we're looking for an object to re-imprison the revenant in
#define SEARCH_RADIUS 3

/datum/component/revenant_prison
	// Whether a revenant should be created upon release
	var/create_on_release = FALSE
	// The revenant which is currently imprisoned
	var/mob/living/basic/revenant/revenant
	// ckey of the player who controlled it when it was imprisoned
	var/old_ckey
	// Whether we should allow the revenant to switch homes if this one is qdeleted
	var/propagate = FALSE

/datum/component/revenant_prison/Initialize(mob/living/basic/revenant/revenant, create_on_release = FALSE, propagate = FALSE)
	if(create_on_release)
		return ..()
	if(!istype(revenant) || !isobj(parent))
		return COMPONENT_INCOMPATIBLE
	. = ..()

	src.propagate = propagate
	src.revenant = revenant
	revenant.dormant = TRUE
	old_ckey = revenant.client?.ckey
	revenant.forceMove(parent)

/datum/component/revenant_prison/Destroy()
	if(revenant?.client)
		revenant.ghostize(can_reenter_corpse = FALSE)
	QDEL_NULL(revenant)
	return ..()

/datum/component/revenant_prison/proc/on_parent_break(obj/source, damage_flags)
	SIGNAL_HANDLER
	source.visible_message(span_revenwarning("The revenant cackles as it escapes from [source]!"))
	playsound(source.loc, 'sound/effects/chemistry/ahaha.ogg', 100, TRUE)
	release_revenant(source, cause = "[parent] breaking")

/datum/component/revenant_prison/proc/release_revenant(obj/source, cause)
	SIGNAL_HANDLER
	if(create_on_release)
		revenant = new(get_turf(parent))
	if(!revenant)
		qdel(src)
		return FALSE
	message_admins("[revenant] [ADMIN_FLW(revenant)] has been released from [source] [ADMIN_JMP(source)]. Cause: [cause]")
	if(!revenant.reform(old_ckey))
		message_admins("Couldn't reform revenant upon release.")
	revenant = null
	qdel(src)
	return TRUE

/datum/component/revenant_prison/proc/shift_reflection(datum/source, obj/effect/abstract/reflection)
	SIGNAL_HANDLER
	apply_wibbly_filters(reflection)

/datum/component/revenant_prison/proc/on_parent_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(istype(parent, /obj/structure/mirror))
		examine_list += span_revenwarning("The reflection is shifting and distorted.")

/datum/component/revenant_prison/proc/on_parent_qdeleting(obj/source, force)
	SIGNAL_HANDLER
	if(force || !propagate)
		return
	for(var/obj/new_home in view(source.drop_location(), SEARCH_RADIUS))
		if(SEND_SIGNAL(new_home, COMSIG_REVENANT_PRISON_DESTROYED, revenant))
			source.visible_message(span_revenwarning("A dismal moan echoes as bits of [source] fall onto [new_home]!"))
			log_game("A revenant was trapped inside [new_home]")
			message_admins("A revenant was trapped inside [new_home] [ADMIN_JMP(new_home)]")
		return

/datum/component/revenant_prison/RegisterWithParent()
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_parent_qdeleting))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_parent_examine))
	RegisterSignal(parent, COMSIG_ATOM_BREAK, PROC_REF(on_parent_break))
	RegisterSignal(parent, COMSIG_REVENANT_RELEASE, PROC_REF(release_revenant))
	RegisterSignal(parent, COMSIG_REFLECTED_IMAGE_UPDATED, PROC_REF(shift_reflection))

/datum/component/revenant_prison/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_QDELETING)
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)
	UnregisterSignal(parent, COMSIG_ATOM_BREAK)
	UnregisterSignal(parent, COMSIG_REVENANT_RELEASE)
	UnregisterSignal(parent, COMSIG_REFLECTED_IMAGE_UPDATED)

/datum/component/revenant_prison/PostTransfer(datum/new_parent)
	revenant.forceMove(new_parent)

#undef SEARCH_RADIUS
