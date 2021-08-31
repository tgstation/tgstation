#define CONTENTS_OF(input_atom) input_atom:nullspaced_contents ? input_atom:nullspaced_contents + input_atom:contents : input_atom:contents

#define CREATE_FAKELOC_ASSOCIATION(movable, atom_loc) movable:real_loc = atom_loc; LAZYADD(atom_loc:nullspaced_contents, movable);

#define GET_ASSOCIATED_LOC(movable) movable:real_loc ? movable:real_loc : movable:loc

///Add to an object if you want to be able to be hidden under tiles
/datum/element/undertile
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
	id_arg_index = 2

	///the invisiblity trait applied, like TRAIT_T_RAY_VISIBLE
	var/invisibility_trait
	///level of invisibility applied when under a tile. Could be INVISIBILITY_OBSERVER if you still want it to be visible to ghosts
	var/invisibility_level
	///an overlay for the tile if we wish to apply that
	var/tile_overlay
	///whether we use alpha or not. TRUE uses ALPHA_UNDERTILE because otherwise we have 200 different instances of this element for different alphas
	var/use_alpha
	///We will switch between anchored and unanchored. for stuff like satchels that shouldn't be pullable under tiles but are otherwise unanchored
	var/use_anchor
	///whether we nullspace our target when it is hidden
	var/nullspace_contents = FALSE

/datum/element/undertile/Attach(atom/movable/target, invisibility_trait, invisibility_level = INVISIBILITY_MAXIMUM, tile_overlay, use_alpha = TRUE, use_anchor = FALSE, nullspace_contents = FALSE)
	. = ..()
	if(!ismovable(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_OBJ_HIDE, .proc/hide)

	src.tile_overlay = tile_overlay
	src.use_alpha = use_alpha
	src.use_anchor = use_anchor
	src.invisibility_trait = invisibility_trait
	src.invisibility_level = invisibility_level
	src.nullspace_contents = nullspace_contents

	if(!nullspace_contents)
		return

	RegisterSignal(target, COMSIG_MOVABLE_MOVED, .proc/on_target_moved)

	target.real_loc = target.loc
	LAZYADD(target.loc.nullspaced_contents, target)

///signal handler for COMSIG_MOVABLE_MOVED, if we get moved out of nullspace then undo any work we did to associate target with the loc its "supposed" to be in
/datum/element/undertile/proc/on_target_moved(atom/movable/target, atom/old_loc, movement_dir, forced, list/old_locs)
	SIGNAL_HANDLER
	if(!nullspace_contents || target.loc == null)//if we're moving to nullspace, dont do anything here
		return

	if(!old_loc && target.real_loc == target.loc)//moving from nullspace to realspace and real_loc is already the new loc
		hide(target, FALSE)
		return

	//if we are moving from realspace to realspace (old_loc is not null and loc is not null)
	LAZYREMOVE(old_loc.nullspaced_contents, target)
	target.real_loc = target.loc
	LAZYADD(target.loc.nullspaced_contents, target)
	hide(target, FALSE)
	return


///called when a tile has been covered or uncovered
/datum/element/undertile/proc/hide(atom/movable/source, covered)
	SIGNAL_HANDLER

	source.invisibility = covered ? invisibility_level : 0

	var/turf/source_turf = get_turf(source.real_loc || source)

	if(covered)
		if(nullspace_contents)
			for(var/mob/client_mob in source.client_mobs_in_contents)//dont want them getting stuck
				client_mob.abstract_move(source_turf)
			source.unbuckle_all_mobs(TRUE)
			source.abstract_move(null)

		if(invisibility_trait)
			ADD_TRAIT(source, invisibility_trait, TRAIT_GENERIC)
		if(tile_overlay)
			source_turf.add_overlay(tile_overlay)
		if(use_alpha)
			source.alpha = ALPHA_UNDERTILE
		if(use_anchor)
			source.set_anchored(TRUE)

	else
		if(nullspace_contents && source.loc == null)//move it from nullspace to its real loc
			UnregisterSignal(source, COMSIG_MOVABLE_MOVED)
			source.abstract_move(source.real_loc)
			RegisterSignal(source, COMSIG_MOVABLE_MOVED, .proc/on_target_moved)
		if(invisibility_trait)
			REMOVE_TRAIT(source, invisibility_trait, TRAIT_GENERIC)
		if(tile_overlay)
			source_turf.overlays -= tile_overlay
		if(use_alpha)
			source.alpha = 255
		if(use_anchor)
			source.set_anchored(FALSE)

/datum/element/undertile/Detach(atom/movable/target, visibility_trait, invisibility_level = INVISIBILITY_MAXIMUM)
	. = ..()
	hide(target, FALSE)
	UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	target.real_loc = null
	LAZYREMOVE(target.loc.nullspaced_contents, target)


/atom/movable/proc/count_all_vis_contents()
	. = 0
	for(var/atom/movable/vis_content_atom as anything in vis_contents)
		. += 1
		. += vis_content_atom.count_all_vis_contents()

/turf/proc/count_all_vis_contents()
	. = 0
	for(var/atom/movable/vis_content_atom as anything in vis_contents)
		. += 1
		. += vis_content_atom.count_all_vis_contents()

/mob/proc/tally_maptick_stats_in_range()
	var/movables_in_turf_range = 0
	var/movables_in_mob_contents = 0 //note that these cost far less when processed by SendMaps, most likely due to not checking appearance but verbs
	var/movables_in_screen = 0
	var/total_non_vis_contents_movables = 0
	var/obscured_movables = 0 //movables that arent in view() for any reason

	var/invisible_movables_in_range = 0 //movables we cannot see but are processed by SendMaps anyways

	var/vis_contents_on_movables = 0
	var/vis_contents_on_turfs = 0
	var/total_vis_contents = 0
	var/total_movables_plus_vis_contents = 0 //theyre equivalent to SendMaps

	var/total_turfs_in_range = 0

	var/images_in_client_images = 0

	var/seen_areas = 0

	var/list/client_view = splittext(client.view,"x") //list("one view dimension", "other view dimension")

	client_view[1] = num2text(text2num(client_view[1])+2)
	client_view[2] = num2text(text2num(client_view[2])+2)//byond adds a tile to each view dimension at a minimum, it adds more in some situations but lummox hasnt told me what

	var/used_sendmaps_scan_viewsize = jointext(client_view, "x")

	var/turf/our_turf = get_turf(src)

	for(var/atom/processed_atom in range(used_sendmaps_scan_viewsize, our_turf))
		if(isarea(processed_atom))
			seen_areas++
			continue //i dont thiiiiiink areas are processed?

		if(isturf(processed_atom))
			total_turfs_in_range++
			var/turf/processed_turf = processed_atom
			vis_contents_on_turfs += processed_turf.count_all_vis_contents()

		if(ismovable(processed_atom))
			movables_in_turf_range++
			var/atom/movable/processed_movable = processed_atom
			vis_contents_on_movables += processed_movable.count_all_vis_contents()
			if(processed_atom.invisibility > see_invisible)
				invisible_movables_in_range++

			if(!(processed_atom in view(src)))
				obscured_movables++

	for(var/atom/movable/processed_screen_movable in client.screen)
		movables_in_screen++
		vis_contents_on_movables += processed_screen_movable.count_all_vis_contents()

	for(var/image/client_image as anything in client.images)
		images_in_client_images++

	for(var/atom/movable/contents_movable in src)
		movables_in_mob_contents++//i dont believe that vis_contents does anything for these

	total_vis_contents = vis_contents_on_movables + vis_contents_on_turfs
	total_non_vis_contents_movables = movables_in_screen + movables_in_turf_range + movables_in_mob_contents
	total_movables_plus_vis_contents = total_non_vis_contents_movables + total_vis_contents

	message_admins("[src] with an adjusted view of [used_sendmaps_scan_viewsize] makes SendMaps process [total_movables_plus_vis_contents] movables every tick, [total_non_vis_contents_movables] \
	 arent vis_contents. of the non vis_contents movables, [movables_in_turf_range] are on turfs, [movables_in_screen] are in \
	 client.screen, and [movables_in_mob_contents] are in the client mob. \
	 [total_vis_contents] of the total movables count are vis_contents and [vis_contents_on_movables] of those are on movables and [vis_contents_on_turfs] are on turfs.")

	message_admins("there are [total_turfs_in_range] turfs in range, [images_in_client_images] images in client.images, \
	 and [obscured_movables] of the [movables_in_turf_range] total turf contents movables cannot be seen by the client. \
	 [invisible_movables_in_range] movables are invisible to the client regardless of line of sight. \
	 [seen_areas] areas are in range.")
