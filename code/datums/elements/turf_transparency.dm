/// List of z pillars (objects placed in the bottom left of XbyX squares that have transparent relevant turfs in their vis_contents)
/// We do this because any other method of expanding out turfs ends up offsetting the plane master, and it's impossible to unoffset it
/// The pillars are stored in triple depth lists indexed by (world_size % pillar_size) + 1
/// They are created at transparent turf request, and deleted when no turfs remain
GLOBAL_LIST_EMPTY(pillars_by_z)
#define Z_PILLAR_RADIUS 6
// Takes a position, transforms it into a z pillar key
#define Z_PILLAR_TRANSFORM(pos) (ROUND_UP(pos / Z_PILLAR_RADIUS))
// Takes a z pillar key, hands back the actual posiiton it represents
// A key of 1 becomes 1, a key of 2 becomes Z_PILLAR_RADIUS + 1, etc.
#define Z_KEY_TO_POSITION(key) (((key - 1) * Z_PILLAR_RADIUS) + 1)

/// Returns a z pillar to insert turfs into
/proc/request_z_pillar(x, y, z)
	var/list/pillars_by_z = GLOB.pillars_by_z
	if(length(pillars_by_z) < z)
		pillars_by_z.len = z
	var/list/our_z = pillars_by_z[z]
	if(!our_z)
		our_z = list()
		pillars_by_z[z] = our_z

	//Now that we've got the z layer sorted, we're gonna check the X line
	var/x_key = Z_PILLAR_TRANSFORM(x)
	if(length(our_z) < x_key)
		our_z.len = x_key
	var/list/our_x = our_z[x_key]
	if(!our_x)
		our_x = list()
		our_z[x_key] = our_x

	//And now the y layer
	var/y_key = Z_PILLAR_TRANSFORM(y)
	if(length(our_x) < y_key)
		our_x.len = y_key
	var/datum/z_pillar/our_lad = our_x[y_key]
	if(!our_lad)
		our_lad = new()
		our_x[y_key] = our_lad
	return our_lad

/// Exists to be placed on the turf of walls and such to hold the vis_contents of the tile below
/// Otherwise the lower turf might get shifted around, which is dumb. do this instead.
/obj/effect/abstract/z_holder
	appearance_flags = PIXEL_SCALE
	plane = HUD_PLANE
	anchored = TRUE
	move_resist = INFINITY
	invisibility = 101
	
/datum/z_pillar
	/// Assoc list in the form displayed turf -> list of sources
	var/list/turf_sources = list()
	/// Assoc list of turfs using z holders in the form displayed turf -> z holder
	var/list/drawing_object = list()

/// Displays a turf from the z level below us on our level
/// Note: we type source as movable despite accepting turfs here. This is done because
/// otherwise we will get an error about vis_contents on atom, since... it's not supported by areas?
/datum/z_pillar/proc/display_turf(turf/to_display, atom/movable/source, mapload)
	var/list/sources = turf_sources[to_display]
	if(!sources)
		sources = list()
		turf_sources[to_display] = sources
	sources |= source

	if(length(sources) != 1) // If we aren't the first to request this turf, return
		var/obj/effect/abstract/z_holder/holding = drawing_object[to_display]
		if(!holding)
			return

		var/turf/visual_target = to_display.above()
		/// Basically, if we used to be under a non transparent turf, but are no longer in that position
		/// Then we add to the transparent turf we're now under, and nuke the old object
		if(!HAS_TRAIT(visual_target, TURF_Z_TRANSPARENT_TRAIT))
			return

		holding.vis_contents -= to_display
		qdel(holding)
		drawing_object -= to_display
		visual_target.vis_contents += to_display
		return

	var/turf/visual_target = to_display.above()
	// The isopenspaceturf() here isn't nessesarry for behavior, but serves as an optimization for large openspace areas
	if(HAS_TRAIT(visual_target, TURF_Z_TRANSPARENT_TRAIT) || isopenspaceturf(visual_target))
		visual_target.vis_contents += to_display
	else
		var/obj/effect/abstract/z_holder/hold_this = new(visual_target)
		hold_this.vis_contents += to_display
		drawing_object[to_display] = hold_this

/// Hides an existing turf from our vis_contents, or the vis_contents of the source if applicable
/// Note: we type source as movable despite accepting turfs here. This is done because
/// otherwise we will get an error about vis_contents on atom, since... it's not supported by areas?
/datum/z_pillar/proc/hide_turf(turf/to_hide, atom/movable/source)
	var/list/sources = turf_sources[to_hide]
	if(!sources)
		return
	sources -= source
	// More sources remain
	if(length(sources))
		return

	turf_sources -= to_hide
	var/obj/effect/abstract/z_holder/holding = drawing_object[to_hide]
	if(holding)
		var/obj/effect/abstract/z_holder/holding_this = locate(/obj/effect/abstract/z_holder)
		holding_this.vis_contents -= to_hide
		qdel(holding_this)
	else
		var/turf/visual_target = to_hide.above()
		visual_target.vis_contents -= to_hide

/datum/element/turf_z_transparency
	element_flags = ELEMENT_DETACH

///This proc sets up the signals to handle updating viscontents when turfs above/below update. Handle plane and layer here too so that they don't cover other obs/turfs in Dream Maker
/datum/element/turf_z_transparency/Attach(datum/target, mapload)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE

	var/turf/our_turf = target

	our_turf.layer = OPENSPACE_LAYER

	RegisterSignal(target, COMSIG_TURF_MULTIZ_DEL, .proc/on_multiz_turf_del)
	RegisterSignal(target, COMSIG_TURF_MULTIZ_NEW, .proc/on_multiz_turf_new)

	ADD_TRAIT(our_turf, TURF_Z_TRANSPARENT_TRAIT, ELEMENT_TRAIT(type))

	if(!mapload)
		update_multi_z(our_turf)

/datum/element/turf_z_transparency/Detach(datum/source)
	. = ..()
	var/turf/our_turf = source
	our_turf.vis_contents.len = 0
	UnregisterSignal(our_turf, list(COMSIG_TURF_MULTIZ_NEW, COMSIG_TURF_MULTIZ_DEL))
	REMOVE_TRAIT(our_turf, TURF_Z_TRANSPARENT_TRAIT, ELEMENT_TRAIT(type))

///Updates the viscontents or underlays below this tile.
/datum/element/turf_z_transparency/proc/update_multi_z(turf/our_turf)
	var/turf/below_turf = our_turf.below()
	// lemon todo: register for changeturf here, or on the z pillar datum
	if(below_turf) // If we actually have something below us, display it.
		for(var/turf/partner in range(1, below_turf))
			// We use our z here to ensure the pillar is actually on our level
			var/datum/z_pillar/z_boss = request_z_pillar(partner.x, partner.y, our_turf.z)
			z_boss.display_turf(partner, our_turf)
	else
		our_turf.vis_contents.len = 0 // Nuke the list
		add_baseturf_underlay(our_turf)

	if(isclosedturf(our_turf)) //Show girders below closed turfs
		var/mutable_appearance/girder_underlay = mutable_appearance('icons/obj/structures.dmi', "girder", layer = TURF_LAYER-0.01)
		girder_underlay.appearance_flags = RESET_ALPHA | RESET_COLOR
		our_turf.underlays += girder_underlay
		var/mutable_appearance/plating_underlay = mutable_appearance('icons/turf/floors.dmi', "plating", layer = TURF_LAYER-0.02)
		plating_underlay.appearance_flags = RESET_ALPHA | RESET_COLOR
		our_turf.underlays += plating_underlay
	return TRUE

/datum/element/turf_z_transparency/proc/on_multiz_turf_del(turf/our_turf, turf/below_turf, dir)
	SIGNAL_HANDLER

	if(dir != DOWN)
		return

	update_multi_z(our_turf)

/datum/element/turf_z_transparency/proc/on_multiz_turf_new(turf/our_turf, turf/below_turf, dir)
	SIGNAL_HANDLER

	if(dir != DOWN)
		return

	update_multi_z(our_turf)

///Called when there is no real turf below this turf
/datum/element/turf_z_transparency/proc/add_baseturf_underlay(turf/our_turf)
	var/turf/path = SSmapping.level_trait(our_turf.z, ZTRAIT_BASETURF) || /turf/open/space
	if(!ispath(path))
		path = text2path(path)
		if(!ispath(path))
			warning("Z-level [our_turf.z] has invalid baseturf '[SSmapping.level_trait(our_turf.z, ZTRAIT_BASETURF)]'")
			path = /turf/open/space
	var/mutable_appearance/underlay_appearance = mutable_appearance(initial(path.icon), initial(path.icon_state), layer = TURF_LAYER-0.02, offset_spokesman = our_turf, plane = PLANE_SPACE)
	underlay_appearance.appearance_flags = RESET_ALPHA | RESET_COLOR
	our_turf.underlays += underlay_appearance
