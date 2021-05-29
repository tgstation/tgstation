#define AQUARIUM_LAYER_STEP 0.01
/// Aquarium content layer offsets
#define AQUARIUM_MIN_OFFSET 0.01
#define AQUARIUM_MAX_OFFSET 1

#define CACHED_OVERLAY_PANEL_APPEARANCE 1
#define CACHED_OVERLAY_GLASS_APPEARANCE 2
#define CACHED_OVERLAY_BROKENGLASS_APPEARANCE 3

/**
 * ## aquarium component!
 *
 * This shit is an aquarium
 */
/datum/component/aquarium
	///fluid in the aquarium
	var/fluid_type = AQUARIUM_FLUID_FRESHWATER
	///how hot it is
	var/fluid_temp = DEFAULT_AQUARIUM_TEMP
	///how cold it can be
	var/min_fluid_temp = MIN_AQUARIUM_TEMP
	///how hot it can be
	var/max_fluid_temp = MAX_AQUARIUM_TEMP
	///if fish reproduce in this 'quarium.
	var/allow_breeding = FALSE
	///when the thing this aquarium is attached to is broken, basically. means different things for different types
	var/broken = FALSE
	///if the panel is open for the aquarium
	var/panel_open = FALSE

	///This is the area where fish can swim
	var/aquarium_zone_min_px
	var/aquarium_zone_max_px
	var/aquarium_zone_min_py
	var/aquarium_zone_max_py

	///replacement for parent's contents list as turfs store objects on themselves, not in themselves.
	var/list/aquarium_contents = list()

	var/list/fluid_types = list(AQUARIUM_FLUID_SALTWATER, AQUARIUM_FLUID_FRESHWATER, AQUARIUM_FLUID_SULPHWATEVER, AQUARIUM_FLUID_AIR)
	///Current layers in use by aquarium contents
	var/list/used_layers = list()
	///number of living fish in the tank
	var/alive_fish = 0
	///number of dead fish in the tank
	var/dead_fish = 0

	var/static/list/created_overlays = list()

/datum/component/aquarium/Initialize(aquarium_zone_min_px, aquarium_zone_max_px, aquarium_zone_min_py, aquarium_zone_max_py)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE
	var/atom/aquarium_atom = parent
	src.aquarium_zone_min_px = aquarium_zone_min_px
	src.aquarium_zone_max_px = aquarium_zone_max_px
	src.aquarium_zone_min_py = aquarium_zone_min_py
	src.aquarium_zone_max_py = aquarium_zone_max_py
	aquarium_atom.update_appearance()

/datum/component/aquarium/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/on_attackby)
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, .proc/on_update_overlays)
	RegisterSignal(parent, COMSIG_CLICK_ALT, .proc/on_alt_click)
	RegisterSignal(parent, COMSIG_ATOM_UI_INTERACT, .proc/on_interact)
	if(isobj(parent))
		RegisterSignal(parent, COMSIG_OBJ_BREAK, .proc/on_break)
	if(isturf(parent))
		RegisterSignal(parent, list(COMSIG_TURF_BROKEN, COMSIG_TURF_BURNED), .proc/on_break)

/datum/component/aquarium/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_EXAMINE,
		COMSIG_PARENT_ATTACKBY,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_CLICK_ALT,
		COMSIG_ATOM_UI_INTERACT,
		COMSIG_OBJ_BREAK,
		COMSIG_TURF_BROKEN,
		COMSIG_TURF_BURNED
	))

/**
 * base aq layer
 * min_offset = this value is returned on bottom layer mode
 * min_offset + 0.1 fish1
 * min_offset + 0.2 fish2
 * ... these layers are returned for auto layer mode and tracked by used_layers
 * min_offset + max_offset = this value is returned for top layer mode
 * min_offset + max_offset + 1 = this is used for glass overlay
*/
/datum/component/aquarium/proc/request_layer(layer_type)
	var/atom/aquarium_atom = parent
	switch(layer_type)
		if(AQUARIUM_LAYER_MODE_BOTTOM)
			return aquarium_atom.layer + AQUARIUM_MIN_OFFSET
		if(AQUARIUM_LAYER_MODE_TOP)
			return aquarium_atom.layer + AQUARIUM_MAX_OFFSET
		if(AQUARIUM_LAYER_MODE_AUTO)
			var/chosen_layer = aquarium_atom.layer + AQUARIUM_MIN_OFFSET + AQUARIUM_LAYER_STEP
			while((chosen_layer in used_layers) && (chosen_layer <= aquarium_atom.layer + AQUARIUM_MAX_OFFSET))
				chosen_layer += AQUARIUM_LAYER_STEP
			used_layers += chosen_layer
			return chosen_layer

/datum/component/aquarium/proc/free_layer(value)
	used_layers -= value

/datum/component/aquarium/proc/get_surface_properties()
	. = list()
	.[AQUARIUM_PROPERTIES_PX_MIN] = aquarium_zone_min_px
	.[AQUARIUM_PROPERTIES_PX_MAX] = aquarium_zone_max_px
	.[AQUARIUM_PROPERTIES_PY_MIN] = aquarium_zone_min_py
	.[AQUARIUM_PROPERTIES_PY_MAX] = aquarium_zone_max_py

///
/**
 * signal called by overlays updating
 *
 * created_overlays is an assoc list, icon file name = list("panel" icon state, "glass" icon state, "glass_broken" icon state)
 */
/datum/component/aquarium/proc/on_update_overlays(datum/source, list/overlays)
	SIGNAL_HANDLER
	var/atom/aquarium_atom = parent

	var/list/this_aquarium_overlays = created_overlays[aquarium_atom.icon]
	if(!this_aquarium_overlays)
		var/list/new_cache = list()
		new_cache[CACHED_OVERLAY_PANEL_APPEARANCE] = iconstate2appearance(aquarium_atom.icon, "panel")
		new_cache[CACHED_OVERLAY_GLASS_APPEARANCE] = layerediconstate2appearance(aquarium_atom.icon, "glass", layer = AQUARIUM_MAX_OFFSET-1)
		new_cache[CACHED_OVERLAY_BROKENGLASS_APPEARANCE] = layerediconstate2appearance(aquarium_atom.icon, "glass_broken", layer = AQUARIUM_MAX_OFFSET-1)
		created_overlays[aquarium_atom.icon] = new_cache
		this_aquarium_overlays = new_cache
	if(panel_open)
		overlays += this_aquarium_overlays[CACHED_OVERLAY_PANEL_APPEARANCE]

	//Glass overlay goes on top of everything else.
	if(!broken)
		overlays += this_aquarium_overlays[CACHED_OVERLAY_GLASS_APPEARANCE]
	else
		overlays += this_aquarium_overlays[CACHED_OVERLAY_BROKENGLASS_APPEARANCE]

///signal called by parent getting examined
/datum/component/aquarium/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	examine_text += "<span class='notice'>Alt-click to [panel_open ? "close" : "open"] the control panel.</span>"

/datum/component/aquarium/proc/on_alt_click(datum/source, mob/user)
	SIGNAL_HANDLER
	var/atom/aquarium_atom = parent
	if(!user.canUseTopic(parent, BE_CLOSE))
		return
	panel_open = !panel_open
	aquarium_atom.update_appearance()
	return COMPONENT_CANCEL_CLICK_ALT

///signal from when the aquarium is attacked with an item
/datum/component/aquarium/proc/on_attackby(datum/source, obj/item/attacked_with, mob/user)
	SIGNAL_HANDLER
	var/atom/aquarium_atom = parent
	if(broken && istype(attacked_with, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/glass = attacked_with
		if(glass.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need two glass sheets to fix [parent]!</span>")
			return
		to_chat(user, "<span class='notice'>You start fixing [parent]...</span>")
		INVOKE_ASYNC(src, .proc/attempt_fix, user, attacked_with)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(istype(attacked_with, /obj/item/fish_feed))
		to_chat(user,"<span class='notice'>You feed the fish.</span>")
		return

	// This signal exists so we common items instead of adding component on init can just register creation of one in response.
	// This way we can avoid the cost of 9999 aquarium components on rocks that will never see water in their life.
	SEND_SIGNAL(attacked_with, COMSIG_AQUARIUM_BEFORE_INSERT_CHECK,aquarium_atom)
	var/datum/component/aquarium_content/content_component = attacked_with.GetComponent(/datum/component/aquarium_content)
	if(content_component && content_component.is_ready_to_insert(aquarium_atom))
		if(user.transferItemToLoc(attacked_with, null))
			aquarium_contents += attacked_with
			content_component.current_aquarium = src
			content_component.on_inserted()
			aquarium_atom.update_appearance()
			return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/aquarium/proc/attempt_fix(mob/user, obj/item/stack/sheet/glass/glass)
	var/atom/aquarium_atom = parent
	if(!do_after(user, 2 SECONDS, target = aquarium_atom))
		user.balloon_alert(user, "interrupted!")
		return
	glass.use(2)
	broken = FALSE
	if(isobj(aquarium_atom))
		var/obj/aquarium_obj = aquarium_atom
		aquarium_obj.obj_integrity = aquarium_obj.max_integrity
	if(isfloorturf(aquarium_atom))
		var/turf/open/floor/aquarium_turf = aquarium_atom
		aquarium_turf.broken = FALSE
	aquarium_atom.update_appearance()

/datum/component/aquarium/proc/on_interact(datum/source, mob/user)
	if(!broken && user.pulling && isliving(user.pulling))
		var/mob/living/living_pulled = user.pulling
		SEND_SIGNAL(living_pulled, COMSIG_AQUARIUM_BEFORE_INSERT_CHECK,src)
		var/datum/component/aquarium_content/content_component = living_pulled.GetComponent(/datum/component/aquarium_content)
		if(content_component && content_component.is_ready_to_insert(src))
			try_to_put_mob_in(user)
	else if(panel_open)
		ui_interact(user) //interact with the component instead
	else
		admire(user)

/// Tries to put mob pulled by the user in the aquarium after a delay
/datum/component/aquarium/proc/try_to_put_mob_in(mob/user)
	var/atom/aquarium_atom = parent
	if(user.pulling && isliving(user.pulling))
		var/mob/living/living_pulled = user.pulling
		if(living_pulled.buckled || living_pulled.has_buckled_mobs())
			to_chat(user, "<span class='warning'>[living_pulled] is attached to something!</span>")
			return
		user.visible_message("<span class='danger'>[user] starts to put [living_pulled] into [src]!</span>")
		if(do_after(user, 10 SECONDS, target = src))
			if(QDELETED(living_pulled) || user.pulling != living_pulled || living_pulled.buckled  || living_pulled.has_buckled_mobs())
				return
			var/datum/component/aquarium_content/content_component = living_pulled.GetComponent(/datum/component/aquarium_content)
			if(content_component || content_component.is_ready_to_insert(src))
				return
			user.visible_message("<span class='danger'>[user] stuffs [living_pulled] into [src]!</span>")
			living_pulled.forceMove(src)
			aquarium_atom.update_appearance()

///Apply mood bonus depending on aquarium status
/datum/component/aquarium/proc/admire(mob/user)
	to_chat(user,"<span class='notice'>You take a moment to watch [parent].</span>")
	if(do_after(user, 5 SECONDS, target = parent))
		//Check if there are live fish - good mood
		//All fish dead - bad mood.
		//No fish - nothing.
		if(alive_fish > 0)
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "aquarium", /datum/mood_event/aquarium_positive)
		else if(dead_fish > 0)
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "aquarium", /datum/mood_event/aquarium_negative)
		// Could maybe scale power of this mood with number/types of fish

/datum/component/aquarium/ui_data(mob/user)
	. = ..()
	.["fluid_type"] = fluid_type
	.["temperature"] = fluid_temp
	.["allow_breeding"] = allow_breeding
	var/list/content_data = list()
	for(var/atom/movable/fish in aquarium_contents)
		content_data += list(list("name"=fish.name,"ref"=ref(fish)))
	.["contents"] = content_data

/datum/component/aquarium/ui_static_data(mob/user)
	. = ..()
	//I guess these should depend on the fluid so lava critters can get high or stuff below water freezing point but let's keep it simple for now.
	.["minTemperature"] = min_fluid_temp
	.["maxTemperature"] = max_fluid_temp
	.["fluidTypes"] = fluid_types

/datum/component/aquarium/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/mob/user = usr
	switch(action)
		if("temperature")
			var/temperature = params["temperature"]
			if(isnum(temperature))
				fluid_temp = clamp(temperature, min_fluid_temp, max_fluid_temp)
				. = TRUE
		if("fluid")
			if(params["fluid"] in fluid_types)
				fluid_type = params["fluid"]
				SEND_SIGNAL(src, COMSIG_AQUARIUM_FLUID_CHANGED, fluid_type)
				. = TRUE
		if("allow_breeding")
			allow_breeding = !allow_breeding
			. = TRUE
		if("remove")
			var/atom/movable/inside = locate(params["ref"]) in aquarium_contents
			if(inside)
				if(isitem(inside))
					user.put_in_hands(inside)
				else
					inside.forceMove(get_turf(src))
				to_chat(user,"<span class='notice'>You take out [inside] from [src].</span>")

/datum/component/aquarium/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	var/atom/aquarium_atom = parent
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Aquarium", aquarium_atom.name)
		ui.open()

///signal called from various ways an atom "breaks" from a gameplay standpoint
/datum/component/aquarium/proc/on_break(damage_flag)
	SIGNAL_HANDLER
	if(!broken)
		aquarium_smash()

/datum/component/aquarium/proc/aquarium_smash()
	broken = TRUE
	var/atom/aquarium_atom = parent
	var/possible_destinations_for_fish = list()
	var/droploc = aquarium_atom.drop_location()
	if(isturf(droploc))
		possible_destinations_for_fish = get_adjacent_open_turfs(droploc)
	else
		possible_destinations_for_fish = list(droploc)
	playsound(src, 'sound/effects/glassbr3.ogg', 100, TRUE)
	for(var/atom/movable/fish in aquarium_contents)
		fish.forceMove(pick(possible_destinations_for_fish))
	if(fluid_type != AQUARIUM_FLUID_AIR)
		var/datum/reagents/reagent_splash = new()
		reagent_splash.add_reagent(/datum/reagent/water, 30)
		chem_splash(droploc, 3, list(reagent_splash))
	aquarium_atom.update_appearance()

#undef AQUARIUM_LAYER_STEP
#undef AQUARIUM_MIN_OFFSET
#undef AQUARIUM_MAX_OFFSET
