/* HUD DATUMS */

GLOBAL_LIST_EMPTY(all_huds)

///gets filled by each /datum/atom_hud/New().
///associative list of the form: list(hud category = list(all global atom huds that use that category))
GLOBAL_LIST_EMPTY(huds_by_category)

//GLOBAL HUD LIST
GLOBAL_LIST_INIT(huds, list(
	DATA_HUD_SECURITY_BASIC = new/datum/atom_hud/data/human/security/basic(),
	DATA_HUD_SECURITY_ADVANCED = new/datum/atom_hud/data/human/security/advanced(),
	DATA_HUD_MEDICAL_BASIC = new/datum/atom_hud/data/human/medical/basic(),
	DATA_HUD_MEDICAL_ADVANCED = new/datum/atom_hud/data/human/medical/advanced(),
	DATA_HUD_DIAGNOSTIC_BASIC = new/datum/atom_hud/data/diagnostic/basic(),
	DATA_HUD_DIAGNOSTIC_ADVANCED = new/datum/atom_hud/data/diagnostic/advanced(),
	DATA_HUD_ABDUCTOR = new/datum/atom_hud/abductor(),
	DATA_HUD_SENTIENT_DISEASE = new/datum/atom_hud/sentient_disease(),
	DATA_HUD_AI_DETECT = new/datum/atom_hud/ai_detector(),
	DATA_HUD_FAN = new/datum/atom_hud/data/human/fan_hud(),
))

/datum/atom_hud
	///associative list of the form: list(z level = list(hud atom)). tracks what hud atoms for this hud exists in what z level so we can only give users
	///the hud images that they can actually see.
	var/list/atom/hud_atoms = list()

	///associative list of the form: list(z level = list(hud user client mob = number of times this hud has been added to that mob)).
	///tracks users of this hud by z level so when they change z's we can adjust what images they see from this hud.
	var/list/hud_users = list()
	//TODOKYLER: make the mob users by z level list only contain client mobs!

	///used for signal tracking purposes, associative list of the form: list(hud atom = TRUE) that isnt separated by z level
	var/list/atom/hud_atoms_all_z_levels = list()

	///used for signal tracking purposes, associative list of the form: list(hud user = TRUE) that isnt separated by z level
	var/list/mob/hud_users_all_z_levels = list()

	///these will be the indexes for the atom's hud_list
	var/list/hud_icons = list()

	///mobs associated with the next time this hud can be added to them
	var/list/next_time_allowed = list()
	///mobs that have triggered the cooldown and are queued to see the hud, but do not yet
	var/list/queued_to_see = list()
	/// huduser = list(atoms with their hud hidden) - aka everyone hates targeted invisiblity
	var/hud_exceptions = list()

/datum/atom_hud/New()
	GLOB.all_huds += src
	for(var/z_level in 1 to world.maxz)
		hud_atoms += list(list())
		hud_users += list(list())

	RegisterSignal(SSdcs, COMSIG_GLOB_NEW_Z, .proc/add_z_level_huds)

	for(var/hud_icon in hud_icons)
		GLOB.huds_by_category[hud_icon] += list(src)

/datum/atom_hud/Destroy()
	for(var/mob/mob as anything in hud_users_all_z_levels)
		remove_hud_from_mob(mob)

	for(var/atom/atom as anything in hud_atoms_all_z_levels)
		remove_atom_from_hud(atom)

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
	if(z_level <= 0)
		return FALSE
	if(z_level > length(hud_users))
		stack_trace("get_hud_atoms_for_z_level() was given a z level index out of bounds of hud_atoms!")
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

///apply this atom_hud to new_mob_user
/datum/atom_hud/proc/add_hud_to_mob(mob/new_mob_user)
	if(!new_mob_user)
		return

	var/turf/their_turf = get_turf(new_mob_user)
	if(!their_turf)
		return

	if(!hud_users[their_turf.z][new_mob_user])
		hud_users[their_turf.z][new_mob_user] = 1
		hud_users_all_z_levels[new_mob_user] = TRUE

		RegisterSignal(new_mob_user, COMSIG_PARENT_QDELETING, .proc/unregister_mob)
		RegisterSignal(new_mob_user, COMSIG_MOVABLE_Z_CHANGED, .proc/on_atom_or_user_z_level_changed, override = TRUE)

		if(next_time_allowed[new_mob_user] > world.time)
			if(!queued_to_see[new_mob_user])
				addtimer(CALLBACK(src, .proc/show_hud_images_after_cooldown, new_mob_user), next_time_allowed[new_mob_user] - world.time)
				queued_to_see[new_mob_user] = TRUE

		else
			next_time_allowed[new_mob_user] = world.time + ADD_HUD_TO_COOLDOWN
			for(var/atom/hud_atom_to_add as anything in get_hud_atoms_for_z_level(their_turf.z))
				add_atom_to_single_mob_hud(new_mob_user, hud_atom_to_add)
	else
		hud_users[their_turf.z][new_mob_user]++

///removes everyone of this hud's atom images from former_hud_user
/datum/atom_hud/proc/remove_hud_from_mob(mob/former_hud_user, absolute = FALSE)
	if(!former_hud_user || !hud_users_all_z_levels[former_hud_user])
		return

	var/turf/their_turf = get_turf(former_hud_user)
	if(!their_turf)
		return

	if (absolute || !--hud_users[their_turf.z][former_hud_user])
		UnregisterSignal(former_hud_user, COMSIG_PARENT_QDELETING)
		if(!hud_atoms_all_z_levels[former_hud_user])//make sure we arent removing a mob that also has its own hud atoms
			UnregisterSignal(former_hud_user, COMSIG_MOVABLE_Z_CHANGED)

		hud_users[their_turf.z] -= former_hud_user
		hud_users_all_z_levels -= former_hud_user

		if(next_time_allowed[former_hud_user])
			next_time_allowed -= former_hud_user

		if(queued_to_see[former_hud_user])
			queued_to_see -= former_hud_user

		else
			for(var/atom/hud_atom as anything in get_hud_atoms_for_z_level(their_turf.z))
				remove_atom_from_single_hud(former_hud_user, hud_atom)

/// add new_hud_atom to this hud
/datum/atom_hud/proc/add_atom_to_hud(atom/new_hud_atom)
	if(!new_hud_atom)
		return FALSE
	var/turf/atom_turf = get_turf(new_hud_atom)
	if(!atom_turf)
		return

	RegisterSignal(new_hud_atom, COMSIG_MOVABLE_Z_CHANGED, .proc/on_atom_or_user_z_level_changed, override = TRUE)

	hud_atoms[atom_turf.z] |= new_hud_atom
	hud_atoms_all_z_levels[new_hud_atom] = TRUE

	for(var/mob/mob_to_show as anything in get_hud_users_for_z_level(atom_turf.z))
		if(!queued_to_see[mob_to_show])
			add_atom_to_single_mob_hud(mob_to_show, new_hud_atom)
	return TRUE

/mob/proc/add_images()
	var/list/thing = list()
	for(var/i in 1 to 1000)
		thing += new/image(loc = src)

	var/len1 = length(client.images)
	client.images |= thing
	var/len2 = length(client.images)
	var/a = 2

/// remove this atom from this hud completely
/datum/atom_hud/proc/remove_atom_from_hud(atom/hud_atom_to_remove)
	if(!hud_atom_to_remove)
		return FALSE

	//make sure we arent unregistering a hud atom thats also a hud user mob
	if(!hud_users_all_z_levels[hud_atom_to_remove])
		UnregisterSignal(hud_atom_to_remove, COMSIG_MOVABLE_Z_CHANGED)

	for(var/mob/mob_to_remove as anything in hud_users_all_z_levels)
		remove_atom_from_single_hud(mob_to_remove, hud_atom_to_remove)

	var/turf/atom_turf = get_turf(hud_atom_to_remove)
	if(!atom_turf)
		return

	hud_atoms[atom_turf.z] -= hud_atom_to_remove
	hud_atoms_all_z_levels -= hud_atom_to_remove

	return TRUE

///adds a newly active hud category's image on a hud atom to every mob that could see it
/datum/atom_hud/proc/add_single_hud_category_on_atom(atom/hud_atom, hud_category_to_add)
	if(!hud_atom?.active_hud_list?[hud_category_to_add] || QDELING(hud_atom) || !(hud_category_to_add in hud_icons))
		return FALSE

	var/turf/atom_turf = get_turf(hud_atom)
	if(!atom_turf)
		return FALSE

	if(!hud_atoms_all_z_levels[hud_atom])
		add_atom_to_hud(hud_atom)
		return TRUE

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
		hud_user.client.images -= hud_atom.active_hud_list[hud_category_to_remove]//by this point it shouldnt be in active_hud_list

	return TRUE

///when a hud atom or hud user changes z levels this makes sure it gets the images it needs and removes the images it doesnt need.
///because of how signals work we need the same proc to handle both use cases because being a hud atom and being a hud user arent mutually exclusive
/datum/atom_hud/proc/on_atom_or_user_z_level_changed(atom/movable/moved_atom, turf/old_turf, turf/new_turf)
	SIGNAL_HANDLER

	if(old_turf)
		if(hud_users_all_z_levels[moved_atom])
			hud_users[old_turf.z] -= moved_atom

			for(var/atom/formerly_seen_hud_atom as anything in get_hud_atoms_for_z_level(old_turf.z))
				remove_atom_from_single_hud(moved_atom, formerly_seen_hud_atom)

		if(hud_atoms_all_z_levels[moved_atom])
			hud_atoms[old_turf.z] -= moved_atom

			for(var/mob/formerly_seeing as anything in get_hud_users_for_z_level(old_turf.z))
				remove_atom_from_single_hud(formerly_seeing, moved_atom)

	if(new_turf)
		if(hud_users_all_z_levels[moved_atom])
			hud_users[new_turf.z] += moved_atom

			for(var/atom/newly_seen_hud_atom as anything in get_hud_atoms_for_z_level(new_turf.z))
				add_atom_to_single_mob_hud(moved_atom, newly_seen_hud_atom)

		if(hud_atoms_all_z_levels[moved_atom])
			hud_atoms[new_turf.z] += moved_atom

			for(var/mob/newly_seeing as anything in get_hud_users_for_z_level(new_turf.z))
				add_atom_to_single_mob_hud(newly_seeing, moved_atom)

/// add just hud_atom's hud images (that are part of this atom_hud) to requesting_mob's client.images list
/datum/atom_hud/proc/add_atom_to_single_mob_hud(mob/requesting_mob, atom/hud_atom) //unsafe, no sanity apart from client
	if(!requesting_mob || !requesting_mob.client || !hud_atom)
		return

	for(var/hud_category in (hud_icons & hud_atom.active_hud_list))
		if(!hud_exceptions[requesting_mob] || !(hud_atom in hud_exceptions[requesting_mob]))
			requesting_mob.client.images |= hud_atom.active_hud_list[hud_category]

/// remove every hud image for this hud on atom_to_remove from client_mob's client.images list
/datum/atom_hud/proc/remove_atom_from_single_hud(mob/client_mob, atom/atom_to_remove)
	if(!client_mob || !client_mob.client || !atom_to_remove?.active_hud_list)
		return
	var/len1 = length(client_mob.client.images)
	for(var/hud_image in hud_icons)
		client_mob.client.images -= atom_to_remove.active_hud_list[hud_image]
	var/len2 = length(client_mob.client.images)
	var/a = 1

/datum/atom_hud/proc/unregister_mob(datum/source, force)
	SIGNAL_HANDLER
	remove_hud_from_mob(source, TRUE)

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
