#define ATOM_IS_RENDERING_ORIGINAL(atom) (atom.render_target && atom.render_target[1] == "*")

/*!
 * Okay so basically, you're looking at managed render_targets and render_sources
 * Theres a few big snags here to making this code like-not hellish:
 * * We need to support the following:
 *   * atoms
 *   * images (and their child, Mutable appearances) who have the same vars as atoms but arent children
 *   * filters, who are children of datum... but dont let us use any vars (see [/datum/render_relay/var/target])
 *   * filters, unlike atoms, also support multiple render_sources because they basically work completely differently
 *  //TODO THE ABOVE IS NOT SUPPORTED YET I AM USING HACKS WHERES ITS NEEDED RN (/atom/movable/lighting_mask)
 *
 * Hence, we need to add a managing datum to filters
 * and we have to make render source management a list while forbidding atoms from treating it as such
 * and we have to miscast images as atoms
 * AND we have to do this all at datum level due to images/atoms not inheriting
 *
 * Oh also anything interfacing with these needs to treat it as an image/atom to datum/image/atom thing
 * so instead of just 2 random strings handling everything like how it is by default, you need to make sure it's all tracked properly
 *
 * And some usecases also need to be able to walk up and down the render stack to apply some effects
 *
 * Byond also does not give a fuck if you make circular references and will just.. randomly pick an unrelated render_target on screen instead of something that makes sense
 * So lets stop people from doing that as well while we're at it
 *
 * Having fun yet?
 */

/datum
	///flat list of render_relays that we render to. Don't directly use this unless you're a helper or /datum/render_relay please, use a helper instead
	var/list/datum/render_relay/rendering_to
	///if this is set, this is the atom we are currently rendering in place of our own appearance
	///this is only longer than one when we're using a filter, since atoms only support one at once
	var/datum/render_relay/rendering_from

/**
 * Render relay datum holder
 *
 * Essentually, these are holder for managing render_target and render_source
 * This means you should not longer access/set those vars manually and use the helpers interfacing with this instead
 * Provides sourcing, manages "*" type draws, and allows lookup along the entire "stack" of these effecrs
 */
/datum/render_relay
	///bool if this relay should be drawing the original(provider) as well
	var/draw_original
	/**
	 * This is the target we are relaying to, it can be either an atom or a /datum/filter_data (hence no type)
	 * Atom and Ma is annoying but easy since we can just set the var
	 * Because lummox loves us so much var access on filters access it's args instead
	 * thus Filters will runtime if it's not the right type
	 * Which means the vars available to access are inconsistent at runtime. yay.
	 * even worse type doesnt actually check the type it checks the string arg
	 * instead we have to thus use /datum/filter_data
	 */
	var/datum/target
	///atom that we are rendering from that has a render_target set. CAN be an atom OR an image.
	var/atom/provider

/datum/render_relay/New(draw_original, datum/target, atom/provider)
	. = ..()
	src.draw_original = draw_original
	src.target = target
	src.provider = provider
	LAZYADD(provider.rendering_to, src)
	if(isatom(target) || isimage(target))
		var/atom/atom_cast = target
		atom_cast.rendering_from = src
		atom_cast.render_source = provider.render_target
	if(isfilterdata(target))
		var/datum/filter_data/filt_target = target
		filt_target.set_render_from(src)
	RegisterSignal(provider, COMSIG_QDELETING, PROC_REF(qdel_self))
	RegisterSignal(target, COMSIG_QDELETING, PROC_REF(qdel_self))

///called on del of either provider to clean us up
/datum/render_relay/proc/qdel_self()
	SIGNAL_HANDLER
	provider.stop_render_to(target)
	qdel(src)

/datum/render_relay/Destroy(force, ...)
	target = null
	provider = null
	return ..()

/**
 * Links two atoms using render_target and render_source to draw src instead of source
 * @param target		/datum/filter_data or /atom or /image to draw to
 * @param draw_original	Bool, whether we want to continue rendering the original atoms appearance
 */
/datum/proc/relay_render_to(datum/target, draw_original = TRUE)
	ASSERT(isatom(src) || isimage(src))
	ASSERT(isatom(target) || isfilterdata(target) || isimage(target), "Invalid target for rendering relay")
	if(target in get_below_renderers())
		CRASH("Circular rendering reference detected. Canceling applying render relay of [target.type]")
	if(!isfilterdata(target))
		var/atom/atom_cast = target
		if(atom_cast.render_source)
			CRASH("Tried to relay twice to the same atom. Consider using a holder in viscontents instead.")
	//filterdata sanity checks are handled by add filter already

	//we can be an image or an atom but they have the same vars so hence this cursed shit
	var/atom/atom_cast = src
	if(!atom_cast.render_target)
		var/new_target = ""
		if(!draw_original)
			new_target += "*"

		var/static/uuid = 0
		uuid++
		//soooooo lemon thinks that there may be some byond bugs with
		//non-"normal" chars at the end and slates
		//cant be assed to test so idk if its true
		//so lets just add a buffer on both sides just in case(tm)
		var/static/buffer = "wowza"
		new_target = new_target + buffer + "[uuid]" + buffer

		atom_cast.render_target = new_target
	else if(ATOM_IS_RENDERING_ORIGINAL(atom_cast) && !draw_original)
		atom_cast.render_target = "*" + atom_cast.render_target
		for(var/datum/render_relay/relay as anything in rendering_to)
			if(isatom(relay.target))
				var/atom/good_ending = relay.target
				good_ending.render_source = atom_cast.render_target
			else
				var/datum/filter_data/bad_ending = relay.target
				bad_ending.update_render_source()

	new /datum/render_relay(draw_original, target, src)

///Stops this atom rendering to the specified /atom, /image or /datum/filter_data
/datum/proc/stop_render_to(datum/target)
	ASSERT(isatom(src) || isimage(src))
	for(var/datum/render_relay/relay as anything in rendering_to)
		if(relay.target != target)
			continue
		stop_render_relaying(relay)

/// Stops this /atom or /image from rendering to all it's current relays
/datum/proc/stop_render_all()
	ASSERT(isatom(src) || isimage(src))
	for(var/datum/render_relay/relay as anything in rendering_to)
		stop_render_relaying(relay)

///private proc that handles cancelling a specified relay, and cleaning up render_source nd render_target as needed
/datum/proc/stop_render_relaying(datum/render_relay/relay)
	PRIVATE_PROC(TRUE)
	//assertions handled by whatever calls this sicne it's private already

	var/atom/atom_cast = src
	LAZYREMOVE(rendering_to, relay)
	if(isatom(relay.target))
		var/atom/atom_target = relay.target
		atom_target.render_source = null
		atom_target.rendering_from = null
	else
		var/datum/filter_data/data = relay.target
		data.set_render_from(null)
		data.update_render_source()
	qdel(relay)
	if(!LAZYLEN(rendering_to))
		atom_cast.render_target = null
	else if(!ATOM_IS_RENDERING_ORIGINAL(atom_cast))
		for(var/datum/render_relay/relay_found as anything in rendering_to)
			if(!relay_found.draw_original)
				return
		// we now are only using non original copiers, so we need to start showing the original again
		atom_cast.render_target = copytext_char(atom_cast.render_target, 2)
		for(var/datum/render_relay/relay_found as anything in rendering_to)
			if(isatom(relay_found.target))
				var/atom/good_ending = relay_found.target
				good_ending.render_source = atom_cast.render_target
			else
				var/datum/filter_data/bad_ending = relay_found.target
				bad_ending.update_render_source()

/**
 * Returns the full render stack of this atom
 * returns a list of atoms AND /datum/filter_data. unordered
 * Supports isfilterdata unlike most other render procs
 */
/datum/proc/get_render_stack()
	RETURN_TYPE(/list)
	ASSERT(isatom(src) || isimage(src) || isfilterdata(src))
	. = list(src)
	//check below first
	var/atom/current_level = src
	while(current_level.rendering_from)
		current_level = current_level.rendering_from.provider
		. += current_level
	if(!LAZYLEN(rendering_to))
		return
	var/list/atom/to_check = LAZYCOPY(rendering_to)
	while(length(to_check))
		var/datum/render_relay/next_relay = to_check[1]
		to_check -= next_relay
		. += next_relay.target
		var/list/next_relays = LAZYCOPY(next_relay.provider.rendering_to)
		if(LAZYLEN(next_relays))
			to_check += next_relays

/**
 * Traverses all relays and finds the "ending" targets that don't relay anywhere else
 * returns a list of atoms and /datum/filter_data
 */
/datum/proc/get_terminating_renderers()
	RETURN_TYPE(/list)
	ASSERT(isatom(src) || isimage(src))

	if(!length(rendering_to))
		return list(src)
	. = list()
	for(var/datum/render_relay/relay as anything in rendering_to)
		var/list/datum/render_relay/next_renderto = LAZYCOPY(relay.provider.rendering_to)
		if(!next_renderto)
			. |= relay.target
			continue
		var/list/datum/render_relay/top_relays = list()
		while(length(next_renderto))
			var/datum/render_relay/next_relay = next_renderto[1]
			next_renderto -= next_relay
			if(!LAZYLEN(next_relay.provider.rendering_to))
				top_relays |= next_relay
			else
				var/list/next_relays = next_relay.provider.rendering_to
				if(LAZYLEN(next_relays))
					next_renderto += next_relays
		for(var/datum/render_relay/laterrelay as anything in top_relays)
			. |= laterrelay.target

///Returns the bottommost atom of the render stack. Supports isfilterdata unlike most other render procs
/datum/proc/get_root_renderer()
	RETURN_TYPE(/atom)
	ASSERT(isatom(src) || isimage(src) || isfilterdata(src))

	//providers can only ever be atoms (thank god)
	var/atom/current_level = src
	while(current_level.rendering_from)
		current_level = current_level.rendering_from.provider
	return current_level

///Returns the part of the render stack below us. Supports isfilterdata unlike most other render procs
/datum/proc/get_below_renderers()
	RETURN_TYPE(/list)
	ASSERT(isatom(src) || isimage(src) || isfilterdata(src))

	. = list()
	//providers can only ever be atoms (thank god)
	var/atom/current_level = src
	while(current_level.rendering_from)
		current_level = current_level.rendering_from.provider
		. += current_level

#undef ATOM_IS_RENDERING_ORIGINAL
