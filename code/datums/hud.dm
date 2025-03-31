/* HUD DATUMS */

GLOBAL_LIST_EMPTY(all_huds)

///gets filled by each /datum/atom_hud/New().
///associative list of the form: list(hud category = list(all global atom huds that use that category))
GLOBAL_LIST_EMPTY(huds_by_category)

//GLOBAL HUD LIST
GLOBAL_LIST_INIT(huds, list(
	DATA_HUD_SECURITY_BASIC = new /datum/atom_hud/data/human/security/basic(),
	DATA_HUD_SECURITY_ADVANCED = new /datum/atom_hud/data/human/security/advanced(),
	DATA_HUD_MEDICAL_BASIC = new /datum/atom_hud/data/human/medical/basic(),
	DATA_HUD_MEDICAL_ADVANCED = new /datum/atom_hud/data/human/medical/advanced(),
	DATA_HUD_DIAGNOSTIC = new /datum/atom_hud/data/diagnostic(),
	DATA_HUD_BOT_PATH = new /datum/atom_hud/data/bot_path(),
	DATA_HUD_ABDUCTOR = new /datum/atom_hud/abductor(),
	DATA_HUD_AI_DETECT = new /datum/atom_hud/ai_detector(),
	DATA_HUD_FAN = new /datum/atom_hud/data/human/fan_hud(),
	DATA_HUD_MALF_APC = new /datum/atom_hud/data/malf_apc(),
))

GLOBAL_LIST_INIT(trait_to_hud, list(
	TRAIT_SECURITY_HUD = DATA_HUD_SECURITY_ADVANCED,
	TRAIT_MEDICAL_HUD = DATA_HUD_MEDICAL_ADVANCED,
	TRAIT_DIAGNOSTIC_HUD = DATA_HUD_DIAGNOSTIC,
	TRAIT_BOT_PATH_HUD = DATA_HUD_BOT_PATH,
))

/datum/atom_hud
	///associative list of the form: list(z level = list(hud atom)).
	///tracks what hud atoms for this hud exists in what z level so we can only give users
	///the hud images that they can actually see.
	var/list/atom/hud_atoms = list()

	///associative list of the form: list(z level = list(hud user client mobs)).
	///tracks mobs that can "see" us
	// by z level so when they change z's we can adjust what images they see from this hud.
	var/list/hud_users = list()

	///used for signal tracking purposes, associative list of the form: list(hud atom = TRUE) that isn't separated by z level
	var/list/atom/hud_atoms_all_z_levels = list()

	///used for signal tracking purposes, associative list of the form: list(hud user = number of times this hud was added to this user).
	///that isn't separated by z level
	var/list/mob/hud_users_all_z_levels = list()

	///these will be the indexes for the atom's hud_list
	var/list/hud_icons = list()

	///mobs associated with the next time this hud can be added to them
	var/list/next_time_allowed = list()
	///mobs that have triggered the cooldown and are queued to see the hud, but do not yet
	var/list/queued_to_see = list()
	/// huduser = list(atoms with their hud hidden) - aka everyone hates targeted invisibility
	var/list/hud_exceptions = list()
	///whether or not this atom_hud type updates the global huds_by_category list.
	///some subtypes can't work like this since they're supposed to "belong" to
	///one target atom each. it will still go in the other global hud lists.
	var/uses_global_hud_category = TRUE

/datum/atom_hud/New()
	GLOB.all_huds += src
	for(var/z_level in 1 to world.maxz)
		hud_atoms += list(list())
		hud_users += list(list())

	RegisterSignal(SSdcs, COMSIG_GLOB_NEW_Z, PROC_REF(add_z_level_huds))

	if(uses_global_hud_category)
		for(var/hud_icon in hud_icons)
			GLOB.huds_by_category[hud_icon] += list(src)

/datum/atom_hud/Destroy()
	for(var/mob/mob as anything in hud_users_all_z_levels)
		hide_from(mob)

	for(var/atom/atom as anything in hud_atoms_all_z_levels)
		remove_atom_from_hud(atom)

	if(uses_global_hud_category)
		for(var/hud_icon in hud_icons)
			LAZYREMOVEASSOC(GLOB.huds_by_category, hud_icon, src)

	GLOB.all_huds -= src
	return ..()

/datum/atom_hud/proc/add_z_level_huds()
	SIGNAL_HANDLER
	hud_atoms += list(list())
	hud_users += list(list())

///returns a list of all hud atoms in the given z level and linked lower z levels (because hud users in higher z levels can see below)
/datum/atom_hud/proc/get_hud_atoms_for_z_level(z_level)
	if(z_level <= 0)
		return FALSE
	if(z_level > length(hud_atoms))
		stack_trace("get_hud_atoms_for_z_level() was given a z level index out of bounds of hud_atoms!")
		return FALSE

	. = list()
	. += hud_atoms[z_level]

	var/max_number_of_linked_z_levels_i_care_to_support_here = 10

	while(max_number_of_linked_z_levels_i_care_to_support_here)
		var/lower_z_level_exists = SSmapping.level_trait(z_level, ZTRAIT_DOWN)

		if(lower_z_level_exists)
			z_level--
			. += hud_atoms[z_level]
			max_number_of_linked_z_levels_i_care_to_support_here--
			continue

		else
			break

///returns a list of all hud users in the given z level and linked upper z levels (because hud users in higher z levels can see below)
/datum/atom_hud/proc/get_hud_users_for_z_level(z_level)
	if(z_level > length(hud_users) || z_level <= 0)
		stack_trace("get_hud_atoms_for_z_level() was given a z level index [z_level] out of bounds 1->[length(hud_users)] of hud_atoms!")
		return FALSE

	. = list()
	. += hud_users[z_level]

	var/max_number_of_linked_z_levels_i_care_to_support_here = 10

	while(max_number_of_linked_z_levels_i_care_to_support_here)
		var/upper_level_exists = SSmapping.level_trait(z_level, ZTRAIT_UP)

		if(upper_level_exists)
			z_level++
			. += hud_users[z_level]
			max_number_of_linked_z_levels_i_care_to_support_here--
			continue

		else
			break

///show this hud to the passed in user
/datum/atom_hud/proc/show_to(mob/new_viewer)
	if(!new_viewer)
		return

	if(!hud_users_all_z_levels[new_viewer])
		hud_users_all_z_levels[new_viewer] = 1

		RegisterSignal(new_viewer, COMSIG_QDELETING, PROC_REF(unregister_atom), override = TRUE) //both hud users and hud atoms use these signals
		RegisterSignal(new_viewer, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_atom_or_user_z_level_changed), override = TRUE)

		var/turf/their_turf = get_turf(new_viewer)
		if(!their_turf)
			return
		hud_users[their_turf.z][new_viewer] = TRUE

		if(next_time_allowed[new_viewer] > world.time)
			if(!queued_to_see[new_viewer])
				addtimer(CALLBACK(src, PROC_REF(show_hud_images_after_cooldown), new_viewer), next_time_allowed[new_viewer] - world.time)
				queued_to_see[new_viewer] = TRUE

		else
			next_time_allowed[new_viewer] = world.time + ADD_HUD_TO_COOLDOWN
			for(var/atom/hud_atom_to_add as anything in get_hud_atoms_for_z_level(their_turf.z))
				add_atom_to_single_mob_hud(new_viewer, hud_atom_to_add)
	else
		hud_users_all_z_levels[new_viewer] += 1 //increment the number of times this hud has been added to this hud user

///Hides the images in this hud from former_viewer
///If absolute is set to true, this will forcefully remove the hud, even if sources in theory remain
/datum/atom_hud/proc/hide_from(mob/former_viewer, absolute = FALSE)
	if(!former_viewer || !hud_users_all_z_levels[former_viewer])
		return

	hud_users_all_z_levels[former_viewer] -= 1//decrement number of sources for this hud on this user (bad way to track i know)

	if (absolute || hud_users_all_z_levels[former_viewer] <= 0)//if forced or there aren't any sources left, remove the user

		if(!hud_atoms_all_z_levels[former_viewer])//make sure we aren't unregistering changes on a mob that's also a hud atom for this hud
			UnregisterSignal(former_viewer, COMSIG_MOVABLE_Z_CHANGED)
			UnregisterSignal(former_viewer, COMSIG_QDELETING)

		hud_users_all_z_levels -= former_viewer

		if(next_time_allowed[former_viewer])
			next_time_allowed -= former_viewer

		var/turf/their_turf = get_turf(former_viewer)
		if(their_turf)
			hud_users[their_turf.z] -= former_viewer

		if(queued_to_see[former_viewer])
			queued_to_see -= former_viewer
		else if (their_turf)
			for(var/atom/hud_atom as anything in get_hud_atoms_for_z_level(their_turf.z))
				remove_atom_from_single_hud(former_viewer, hud_atom)

/// add new_hud_atom to this hud
/datum/atom_hud/proc/add_atom_to_hud(atom/new_hud_atom)
	if(!new_hud_atom)
		return FALSE

	// No matter where or who you are, you matter to me :)
	RegisterSignal(new_hud_atom, COMSIG_MOVABLE_Z_CHANGED, PROC_REF(on_atom_or_user_z_level_changed), override = TRUE)
	RegisterSignal(new_hud_atom, COMSIG_QDELETING, PROC_REF(unregister_atom), override = TRUE) //both hud atoms and hud users use these signals
	hud_atoms_all_z_levels[new_hud_atom] = TRUE

	var/turf/atom_turf = get_turf(new_hud_atom)
	if(!atom_turf)
		return TRUE

	hud_atoms[atom_turf.z] |= new_hud_atom

	for(var/mob/mob_to_show as anything in get_hud_users_for_z_level(atom_turf.z))
		if(!queued_to_see[mob_to_show])
			add_atom_to_single_mob_hud(mob_to_show, new_hud_atom)
	return TRUE

/// remove this atom from this hud completely
/datum/atom_hud/proc/remove_atom_from_hud(atom/hud_atom_to_remove)
	if(!hud_atom_to_remove || !hud_atoms_all_z_levels[hud_atom_to_remove])
		return FALSE

	//make sure we aren't unregistering a hud atom that's also a hud user mob
	if(!hud_users_all_z_levels[hud_atom_to_remove])
		UnregisterSignal(hud_atom_to_remove, COMSIG_MOVABLE_Z_CHANGED)
		UnregisterSignal(hud_atom_to_remove, COMSIG_QDELETING)

	for(var/mob/mob_to_remove as anything in hud_users_all_z_levels)
		remove_atom_from_single_hud(mob_to_remove, hud_atom_to_remove)

	hud_atoms_all_z_levels -= hud_atom_to_remove

	var/turf/atom_turf = get_turf(hud_atom_to_remove)
	if(!atom_turf)
		return TRUE

	hud_atoms[atom_turf.z] -= hud_atom_to_remove

	return TRUE

///adds a newly active hud category's image on a hud atom to every mob that could see it
/datum/atom_hud/proc/add_single_hud_category_on_atom(atom/hud_atom, hud_category_to_add)
	if(!hud_atom?.active_hud_list?[hud_category_to_add] || QDELING(hud_atom) || !(hud_category_to_add in hud_icons))
		return FALSE

	if(!hud_atoms_all_z_levels[hud_atom])
		add_atom_to_hud(hud_atom)
		return TRUE

	var/turf/atom_turf = get_turf(hud_atom)
	if(!atom_turf)
		return FALSE

	for(var/mob/hud_user as anything in get_hud_users_for_z_level(atom_turf.z))
		if(!hud_user.client)
			continue
		if(!hud_exceptions[hud_user] || !(hud_atom in hud_exceptions[hud_user]))
			hud_user.client.images |= hud_atom.active_hud_list[hud_category_to_add]

	return TRUE

///removes the image or images in hud_atom.hud_list[hud_category_to_remove] from every mob that can see it but leaves every other image
///from that atom there.
/datum/atom_hud/proc/remove_single_hud_category_on_atom(atom/hud_atom, hud_category_to_remove)
	if(QDELETED(hud_atom) || !(hud_category_to_remove in hud_icons) || !hud_atoms_all_z_levels[hud_atom])
		return FALSE

	if(!hud_atom.active_hud_list)
		remove_atom_from_hud(hud_atom)
		return TRUE

	var/turf/atom_turf = get_turf(hud_atom)
	if(!atom_turf)
		return FALSE

	for(var/mob/hud_user as anything in get_hud_users_for_z_level(atom_turf.z))
		if(!hud_user.client)
			continue
		hud_user.client.images -= hud_atom.active_hud_list[hud_category_to_remove]//by this point it shouldn't be in active_hud_list

	return TRUE

///when a hud atom or hud user changes z levels this makes sure it gets the images it needs and removes the images it doesn't need.
///because of how signals work we need the same proc to handle both use cases because being a hud atom and being a hud user aren't mutually exclusive
/datum/atom_hud/proc/on_atom_or_user_z_level_changed(atom/movable/moved_atom, turf/old_turf, turf/new_turf)
	SIGNAL_HANDLER
	if(old_turf)
		if(hud_users_all_z_levels[moved_atom])
			hud_users[old_turf.z] -= moved_atom

			remove_all_atoms_from_single_hud(moved_atom, get_hud_atoms_for_z_level(old_turf.z))

		if(hud_atoms_all_z_levels[moved_atom])
			hud_atoms[old_turf.z] -= moved_atom

			//this wont include moved_atom since its removed
			remove_atom_from_all_huds(get_hud_users_for_z_level(old_turf.z), moved_atom)

	if(new_turf)
		if(hud_users_all_z_levels[moved_atom])
			hud_users[new_turf.z][moved_atom] = TRUE //hud users is associative, hud atoms isn't

			add_all_atoms_to_single_mob_hud(moved_atom, get_hud_atoms_for_z_level(new_turf.z))

		if(hud_atoms_all_z_levels[moved_atom])
			hud_atoms[new_turf.z] |= moved_atom

			add_atom_to_all_mob_huds(get_hud_users_for_z_level(new_turf.z), moved_atom)

/// add just hud_atom's hud images (that are part of this atom_hud) to requesting_mob's client.images list
/datum/atom_hud/proc/add_atom_to_single_mob_hud(mob/requesting_mob, atom/hud_atom) //unsafe, no sanity apart from client
	if(!requesting_mob || !requesting_mob.client || !hud_atom)
		return

	for(var/hud_category in (hud_icons & hud_atom.active_hud_list))
		if(!hud_exceptions[requesting_mob] || !(hud_atom in hud_exceptions[requesting_mob]))
			requesting_mob.client.images |= hud_atom.active_hud_list[hud_category]

/// all passed in hud_atoms's hud images (that are part of this atom_hud) to requesting_mob's client.images list
/// optimization of [/datum/atom_hud/proc/add_atom_to_single_mob_hud] for hot cases, we assert that no nulls will be passed in via the list
/datum/atom_hud/proc/add_all_atoms_to_single_mob_hud(mob/requesting_mob, list/atom/hud_atoms) //unsafe, no sanity apart from client
	if(!requesting_mob || !requesting_mob.client)
		return

	// Hud entries this mob ignores
	var/list/mob_exceptions = hud_exceptions[requesting_mob]

	for(var/hud_category in hud_icons)
		for(var/atom/hud_atom as anything in hud_atoms)
			if(mob_exceptions && (hud_atom in hud_exceptions[requesting_mob]))
				continue
			var/image/output = hud_atom.active_hud_list?[hud_category]
			// byond throws a fit if you try to add null to the images list
			if(!output)
				continue
			requesting_mob.client.images |= output

/// add just hud_atom's hud images (that are part of this atom_hud) to all the requesting_mobs's client.images list
/// optimization of [/datum/atom_hud/proc/add_atom_to_single_mob_hud] for hot cases, we assert that no nulls will be passed in via the list
/datum/atom_hud/proc/add_atom_to_all_mob_huds(list/mob/requesting_mobs, atom/hud_atom) //unsafe, no sanity apart from client
	if(!hud_atom?.active_hud_list)
		return

	var/list/images_to_add = list()
	for(var/hud_category in (hud_icons & hud_atom.active_hud_list))
		images_to_add |= hud_atom.active_hud_list[hud_category]

	// Cache for sonic speed, lists are structs
	var/list/exceptions = hud_exceptions
	for(var/mob/requesting_mob as anything in requesting_mobs)
		if(!requesting_mob.client)
			continue
		if(!exceptions[requesting_mob] || !(hud_atom in exceptions[requesting_mob]))
			requesting_mob.client.images |= images_to_add

/// remove every hud image for this hud on atom_to_remove from client_mob's client.images list
/datum/atom_hud/proc/remove_atom_from_single_hud(mob/client_mob, atom/atom_to_remove)
	if(!client_mob || !client_mob.client || !atom_to_remove?.active_hud_list)
		return
	for(var/hud_image in hud_icons)
		client_mob.client.images -= atom_to_remove.active_hud_list[hud_image]

/// remove every hud image for this hud pulled from atoms_to_remove from client_mob's client.images list
/// optimization of [/datum/atom_hud/proc/remove_atom_from_single_hud] for hot cases, we assert that no nulls will be passed in via the list
/datum/atom_hud/proc/remove_all_atoms_from_single_hud(mob/client_mob, list/atom/atoms_to_remove)
	if(!client_mob || !client_mob.client)
		return
	for(var/hud_image in hud_icons)
		for(var/atom/atom_to_remove as anything in atoms_to_remove)
			client_mob.client.images -= atom_to_remove.active_hud_list?[hud_image]

/// remove every hud image for this hud on atom_to_remove from client_mobs's client.images list
/// optimization of [/datum/atom_hud/proc/remove_atom_from_single_hud] for hot cases, we assert that no nulls will be passed in via the list
/datum/atom_hud/proc/remove_atom_from_all_huds(list/mob/client_mobs, atom/atom_to_remove)
	if(!atom_to_remove?.active_hud_list)
		return

	var/list/images_to_remove = list()
	for(var/hud_image in hud_icons)
		images_to_remove |= atom_to_remove.active_hud_list[hud_image]

	for(var/mob/client_mob as anything in client_mobs)
		if(!client_mob.client)
			continue
		client_mob.client.images -= images_to_remove

/datum/atom_hud/proc/unregister_atom(datum/source, force)
	SIGNAL_HANDLER
	hide_from(source, TRUE)
	remove_atom_from_hud(source)

/datum/atom_hud/proc/hide_single_atomhud_from(mob/hud_user, atom/hidden_atom)

	if(hud_users_all_z_levels[hud_user])
		remove_atom_from_single_hud(hud_user, hidden_atom)

	if(!hud_exceptions[hud_user])
		hud_exceptions[hud_user] = list(hidden_atom)
	else
		hud_exceptions[hud_user] += hidden_atom

/datum/atom_hud/proc/unhide_single_atomhud_from(mob/hud_user, atom/hidden_atom)
	hud_exceptions[hud_user] -= hidden_atom

	var/turf/hud_atom_turf = get_turf(hidden_atom)

	if(!hud_atom_turf)
		return

	if(hud_users[hud_atom_turf.z][hud_user])
		add_atom_to_single_mob_hud(hud_user, hidden_atom)

/datum/atom_hud/proc/show_hud_images_after_cooldown(mob/queued_hud_user)
	if(!queued_to_see[queued_hud_user])
		return

	queued_to_see -= queued_hud_user
	next_time_allowed[queued_hud_user] = world.time + ADD_HUD_TO_COOLDOWN

	var/turf/user_turf = get_turf(queued_hud_user)
	if(!user_turf)
		return

	for(var/atom/hud_atom_to_show as anything in get_hud_atoms_for_z_level(user_turf.z))
		add_atom_to_single_mob_hud(queued_hud_user, hud_atom_to_show)

//MOB PROCS
/mob/proc/reload_huds()
	var/turf/our_turf = get_turf(src)
	if(!our_turf)
		return

	for(var/datum/atom_hud/hud in GLOB.all_huds)
		if(hud?.hud_users_all_z_levels[src])
			for(var/atom/hud_atom as anything in hud.get_hud_atoms_for_z_level(our_turf.z))
				hud.add_atom_to_single_mob_hud(src, hud_atom)

/mob/dead/new_player/reload_huds()
	return

/mob/proc/add_click_catcher()
	client.screen += client.void

/mob/dead/new_player/add_click_catcher()
	return
