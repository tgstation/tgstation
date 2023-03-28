/// List of z pillars (datums placed in the bottom left of XbyX squares that control transparency in that space)
/// The pillars are stored in triple depth lists indexed by (world_size % pillar_size) + 1
/// They are created at transparent turf request, and deleted when no turfs remain
GLOBAL_LIST_EMPTY(pillars_by_z)
#define Z_PILLAR_RADIUS 20
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
		our_lad = new(x_key, y_key, z)
		our_x[y_key] = our_lad
	return our_lad

/// Exists to be placed on the turf of walls and such to hold the vis_contents of the tile below
/// Otherwise the lower turf might get shifted around, which is dumb. do this instead.
/obj/effect/abstract/z_holder
	var/datum/z_pillar/pillar
	var/turf/show_for
	appearance_flags = PIXEL_SCALE
	plane = HUD_PLANE
	anchored = TRUE
	move_resist = INFINITY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/obj/effect/abstract/z_holder/Destroy()
	if(pillar)
		pillar.drawing_object -= show_for
		pillar = null
	show_for = null
	return ..()

/obj/effect/abstract/z_holder/proc/display(turf/display, datum/z_pillar/behalf_of)
	if(pillar)
		CRASH("We attempted to use a z holder to display when it was already in use, what'd you do")

	pillar = behalf_of
	show_for = display
	vis_contents += display
	behalf_of.drawing_object[display] = src

/// Grouping datum that manages transparency for a block of space
/// Setup to ease debugging, and to make add/remove operations cheaper
/datum/z_pillar
	var/x_pos
	var/y_pos
	var/z_pos
	/// Assoc list in the form displayed turf -> list of sources
	var/list/turf_sources = list()
	/// Assoc list of turfs using z holders in the form displayed turf -> z holder
	var/list/drawing_object = list()

/datum/z_pillar/New(x_pos, y_pos, z_pos)
	. = ..()
	src.x_pos = x_pos
	src.y_pos = y_pos
	src.z_pos = z_pos

/datum/z_pillar/Destroy()
	GLOB.pillars_by_z[z_pos][x_pos][y_pos] = null
	// Just to be totally clear, this is code that exists to
	// A: make sure cleanup is actually possible for this datum, just in case someone goes insane
	// B: allow for easier debugging and making sure everything behaves as expected when fully removed
	// It is not meant to be relied on, please don't actually it's not very fast
	for(var/turf/displaying in turf_sources)
		for(var/turf/displaying_for in turf_sources[displaying])
			hide_turf(displaying, displaying_for)
	return ..()

/// Displays a turf from the z level below us on our level
/datum/z_pillar/proc/display_turf(turf/to_display, turf/source)
	var/list/sources = turf_sources[to_display]

	if(sources) // If we aren't the first to request this turf, return
		sources |= source
		var/obj/effect/abstract/z_holder/holding = drawing_object[to_display]
		if(!holding)
			return

		var/turf/visual_target = to_display.above()
		/// Basically, if we used to be under a non transparent turf, but are no longer in that position
		/// Then we add to the transparent turf we're now under, and nuke the old object
		if(!istransparentturf(visual_target))
			return

		holding.vis_contents -= to_display
		qdel(holding)
		drawing_object -= to_display
		visual_target.vis_contents += to_display
		return

	// Otherwise, we need to create a new set of sources. let's do that yeah?
	sources = list()
	turf_sources[to_display] = sources
	sources |= source

	var/turf/visual_target = to_display.above()
	if(istransparentturf(visual_target) || isopenspaceturf(visual_target))
		visual_target.vis_contents += to_display
	else
		var/obj/effect/abstract/z_holder/hold_this = new(visual_target)
		hold_this.display(to_display, src)

/// Hides an existing turf from our vis_contents, or the vis_contents of the source if applicable
/datum/z_pillar/proc/hide_turf(turf/to_hide, turf/source)
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
		qdel(holding)
	else
		var/turf/visual_target = to_hide.above()
		visual_target.vis_contents -= to_hide

	if(!length(turf_sources) && !QDELETED(src))
		qdel(src)

/// Called when a transparent turf is cleared. We wait a tick, then check to see what
/// Kind of turf replaced our former holder, and resetup our visuals as desired
/// We do not need to do this for non transparent holders, because they will have their abstract object cleared
/// When a transparent holder comes back.
/datum/z_pillar/proc/parent_cleared(turf/visual, turf/current_holder)
	addtimer(CALLBACK(src, PROC_REF(refresh_orphan), visual, current_holder))

/// Runs the actual refresh of some formerly orphaned via vis_loc deletiong turf
/// We'll only reup if we either have no souece, or if the source is a transparent turf
/datum/z_pillar/proc/refresh_orphan(turf/orphan, turf/parent)
	var/list/sources = turf_sources[orphan]
	if(!length(sources))
		return

	var/obj/effect/abstract/z_holder/holding = drawing_object[orphan]
	if(holding)
		return

	if(istransparentturf(parent) || isopenspaceturf(parent))
		parent.vis_contents += orphan
	else
		var/obj/effect/abstract/z_holder/hold_this = new(parent)
		hold_this.display(orphan, src)

/datum/element/turf_z_transparency
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY

///This proc sets up the signals to handle updating viscontents when turfs above/below update. Handle plane and layer here too so that they don't cover other obs/turfs in Dream Maker
/datum/element/turf_z_transparency/Attach(datum/target, mapload)
	. = ..()
	if(!isturf(target))
		return ELEMENT_INCOMPATIBLE

	var/turf/our_turf = target

	RegisterSignal(target, COMSIG_TURF_MULTIZ_DEL, PROC_REF(on_multiz_turf_del))
	RegisterSignal(target, COMSIG_TURF_MULTIZ_NEW, PROC_REF(on_multiz_turf_new))

	ADD_TRAIT(our_turf, TURF_Z_TRANSPARENT_TRAIT, ELEMENT_TRAIT(type))

	if(!mapload)
		update_multi_z(our_turf)

/datum/element/turf_z_transparency/Detach(datum/source)
	. = ..()
	var/turf/our_turf = source
	clear_multiz(our_turf)

	UnregisterSignal(our_turf, list(COMSIG_TURF_MULTIZ_NEW, COMSIG_TURF_MULTIZ_DEL))
	REMOVE_TRAIT(our_turf, TURF_Z_TRANSPARENT_TRAIT, ELEMENT_TRAIT(type))

///Updates the viscontents or underlays below this tile.
/datum/element/turf_z_transparency/proc/update_multi_z(turf/our_turf)
	var/turf/below_turf = our_turf.below()
	if(below_turf) // If we actually have something below us, display it.
		for(var/turf/partner in range(1, below_turf))
			// We use our z here to ensure the pillar is actually on our level
			var/datum/z_pillar/z_boss = request_z_pillar(partner.x, partner.y, our_turf.z)
			z_boss.display_turf(partner, our_turf)
	else
		our_turf.underlays += get_baseturf_underlay(our_turf)

	// This shit is stupid
	// z transparency is for making something SHOW WHAT'S BENEATH it, or if nothing is, show
	// the appropriate underlay
	// IT IS NOT FOR MAKING YOUR CLOSED TURF SEETHROUGH
	// these are different concerns, and should not be HANDLED TOGETHER
	// similarly, if you rip this out, rework diagonal closed turfs to work with this system
	// it will make them look significantly nicer, and should let you tie into their logic more easily
	// Just please don't break behavior yeah? thanks, I love you <3
	if(isclosedturf(our_turf)) //Show girders below closed turfs
		var/mutable_appearance/girder_underlay = mutable_appearance('icons/obj/structures.dmi', "girder", layer = TURF_LAYER-0.01)
		girder_underlay.appearance_flags = RESET_ALPHA | RESET_COLOR
		our_turf.underlays += girder_underlay
		var/mutable_appearance/plating_underlay = mutable_appearance('icons/turf/floors.dmi', "plating", layer = TURF_LAYER-0.02)
		plating_underlay.appearance_flags = RESET_ALPHA | RESET_COLOR
		our_turf.underlays += plating_underlay
	return TRUE

/datum/element/turf_z_transparency/proc/clear_multiz(turf/our_turf)
	var/turf/below_turf = our_turf.below()
	if(below_turf) // If we actually have something below us, we need to clear ourselves from it
		for(var/turf/partner in range(1, below_turf))
			// We use our z here to ensure the pillar is actually on our level
			var/datum/z_pillar/z_boss = request_z_pillar(partner.x, partner.y, our_turf.z)
			z_boss.hide_turf(partner, our_turf)
			if(partner == below_turf)
				z_boss.parent_cleared(below_turf, our_turf)
	else
		our_turf.underlays -= get_baseturf_underlay(our_turf)

	if(isclosedturf(our_turf)) //Show girders below closed turfs
		var/mutable_appearance/girder_underlay = mutable_appearance('icons/obj/structures.dmi', "girder", layer = TURF_LAYER-0.01)
		girder_underlay.appearance_flags = RESET_ALPHA | RESET_COLOR
		our_turf.underlays -= girder_underlay
		var/mutable_appearance/plating_underlay = mutable_appearance('icons/turf/floors.dmi', "plating", layer = TURF_LAYER-0.02)
		plating_underlay.appearance_flags = RESET_ALPHA | RESET_COLOR
		our_turf.underlays -= plating_underlay

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
/datum/element/turf_z_transparency/proc/get_baseturf_underlay(turf/our_turf)
	var/turf/path = SSmapping.level_trait(our_turf.z, ZTRAIT_BASETURF) || /turf/open/space
	if(!ispath(path))
		path = text2path(path)
		if(!ispath(path))
			warning("Z-level [our_turf.z] has invalid baseturf '[SSmapping.level_trait(our_turf.z, ZTRAIT_BASETURF)]'")
			path = /turf/open/space
	var/mutable_appearance/underlay_appearance = mutable_appearance(initial(path.icon), initial(path.icon_state), layer = TURF_LAYER-0.02, offset_spokesman = our_turf, plane = PLANE_SPACE)
	underlay_appearance.appearance_flags = RESET_ALPHA | RESET_COLOR
	return underlay_appearance
