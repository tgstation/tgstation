#define AQUARIUM_LAYER_STEP 0.01
/// Aquarium content layer offsets
#define AQUARIUM_MIN_OFFSET 0.01
#define AQUARIUM_MAX_OFFSET 1

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
	///This is the area where fish can swim

	var/aquarium_zone_min_px
	var/aquarium_zone_max_px
	var/aquarium_zone_min_py
	var/aquarium_zone_max_py

	var/list/fluid_types = list(AQUARIUM_FLUID_SALTWATER, AQUARIUM_FLUID_FRESHWATER, AQUARIUM_FLUID_SULPHWATEVER, AQUARIUM_FLUID_AIR)
	///if the panel is open for the aquarium
	var/panel_open = TRUE
	///Current layers in use by aquarium contents
	var/list/used_layers = list()
	///number of living fish in the tank
	var/alive_fish = 0
	///number of dead fish in the tank
	var/dead_fish = 0

/datum/component/aquarium/Initialize(aquarium_zone_min_px, aquarium_zone_max_px, aquarium_zone_min_py, aquarium_zone_max_py)
	. = ..()
	src.aquarium_zone_min_px = aquarium_zone_min_px
	src.aquarium_zone_max_px = aquarium_zone_max_px
	src.aquarium_zone_min_py = aquarium_zone_min_py
	src.aquarium_zone_max_py = aquarium_zone_max_py
	parent.update_appearance()

/datum/component/aquarium/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/on_attackby)
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_OVERLAYS, .proc/on_update_overlays)
	RegisterSignal(parent, COMSIG_CLICK_ALT, .proc/on_alt_click)
	RegisterSignal(parent, COMSIG_ATOM_UI_INTERACT, .proc/on_interact)
	if(isobj(parent))
		RegisterSignal(parent, COMSIG_OBJ_BREAK, .proc/on_break)

/datum/component/aquarium/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_EXAMINE,
		COMSIG_PARENT_ATTACKBY,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_CLICK_ALT,
		COMSIG_ATOM_UI_INTERACT,
		COMSIG_OBJ_BREAK
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
	switch(layer_type)
		if(AQUARIUM_LAYER_MODE_BOTTOM)
			return layer + AQUARIUM_MIN_OFFSET
		if(AQUARIUM_LAYER_MODE_TOP)
			return layer + AQUARIUM_MAX_OFFSET
		if(AQUARIUM_LAYER_MODE_AUTO)
			var/chosen_layer = layer + AQUARIUM_MIN_OFFSET + AQUARIUM_LAYER_STEP
			while((chosen_layer in used_layers) && (chosen_layer <= layer + AQUARIUM_MAX_OFFSET))
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

///signal called by overlays updating
/datum/component/aquarium/proc/on_update_overlays(datum/source, list/overlays)
	SIGNAL_HANDLER
	var/atom/aquarium_atom = parent

	var/static/panel_overlay
	var/static/glass_healthy_overlay
	var/static/glass_broken_overlay
	if(isnull(panel_overlay))
		panel_overlay = iconstate2appearance(aquarium_atom.icon, "panel")
	if(panel_open)
		overlays += panel_overlay

	//Glass overlay goes on top of everything else.
	if(broken) ? broken_glass_icon_state : glass_icon_state,layer=AQUARIUM_MAX_OFFSET-1)
	overlays += glass_overlay

///signal called by parent getting examined
/datum/component/aquarium/proc/on_examine(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	examine_text += "<span class='notice'>Alt-click to [panel_open ? "close" : "open"] the control panel.</span>"

/datum/component/aquarium/proc/on_alt_click(datum/source, mob/user)
	SIGNAL_HANDLER
	if(!user.canUseTopic(parent, BE_CLOSE))
		return ..()
	panel_open = !panel_open
	parent.update_appearance()

///signal from when the aquarium is attacked with an item
/datum/component/aquarium/proc/on_attackby(datum/source, obj/item/attacked_with, mob/user)
	SIGNAL_HANDLER

	var/atom/aquarium_atom = parent

	if(broken && istype(attacked_with, /obj/item/stack/sheet/glass))
		var/obj/item/stack/sheet/glass/glass = attacked_with
		if(glass.get_amount() < 2)
			to_chat(user, "<span class='warning'>You need two glass sheets to fix the case!</span>")
			return
		to_chat(user, "<span class='notice'>You start fixing [parent]...</span>")
		if(!do_after(user, 2 SECONDS, target = src))
			user.balloon_alert(user, "interrupted!")
			return
		glass.use(2)
		broken = FALSE
		obj_integrity = max_integrity
		aquarium_atom.update_appearance()
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(istype(attacked_with, /obj/item/fish_feed))
		to_chat(user,"<span class='notice'>You feed the fish.</span>")
		return

	// This signal exists so we common items instead of adding component on init can just register creation of one in response.
	// This way we can avoid the cost of 9999 aquarium components on rocks that will never see water in their life.
	SEND_SIGNAL(I,COMSIG_AQUARIUM_BEFORE_INSERT_CHECK,src)
	var/datum/component/aquarium_content/content_component = I.GetComponent(/datum/component/aquarium_content)
	if(content_component && content_component.is_ready_to_insert(src))
		if(user.transferItemToLoc(I,src))
			update_appearance()
			return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/aquarium/proc/on_interact(datum/source, mob/user)
	if(!broken && user.pulling && isliving(user.pulling))
		var/mob/living/living_pulled = user.pulling
		SEND_SIGNAL(living_pulled, COMSIG_AQUARIUM_BEFORE_INSERT_CHECK,src)
		var/datum/component/aquarium_content/content_component = living_pulled.GetComponent(/datum/component/aquarium_content)
		if(content_component && content_component.is_ready_to_insert(src))
			try_to_put_mob_in(user)
	else if(panel_open)
		interact(user) //interact with the component instead
	else
		admire(user)

/// Tries to put mob pulled by the user in the aquarium after a delay
/datum/component/aquarium/proc/try_to_put_mob_in(mob/user)
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
			update_appearance()

///Apply mood bonus depending on aquarium status
/datum/component/aquarium/proc/admire(mob/user)
	to_chat(user,"<span class='notice'>You take a moment to watch [src].</span>")
	if(do_after(user, 5 SECONDS, target = src))
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
	for(var/atom/movable/fish in contents)
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
			var/atom/movable/inside = locate(params["ref"]) in contents
			if(inside)
				if(isitem(inside))
					user.put_in_hands(inside)
				else
					inside.forceMove(get_turf(src))
				to_chat(user,"<span class='notice'>You take out [inside] from [src].</span>")

/datum/component/aquarium/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Aquarium", name)
		ui.open()

/datum/component/aquarium/on_break(damage_flag)
	. = ..()
	if(!broken)
		aquarium_smash()

/datum/component/aquarium/proc/aquarium_smash()
	broken = TRUE
	var/possible_destinations_for_fish = list()
	var/droploc = drop_location()
	if(isturf(droploc))
		possible_destinations_for_fish = get_adjacent_open_turfs(droploc)
	else
		possible_destinations_for_fish = list(droploc)
	playsound(src, 'sound/effects/glassbr3.ogg', 100, TRUE)
	for(var/atom/movable/fish in contents)
		fish.forceMove(pick(possible_destinations_for_fish))
	if(fluid_type != AQUARIUM_FLUID_AIR)
		var/datum/reagents/reagent_splash = new()
		reagent_splash.add_reagent(/datum/reagent/water, 30)
		chem_splash(droploc, 3, list(reagent_splash))
	update_appearance()

#undef AQUARIUM_LAYER_STEP
#undef AQUARIUM_MIN_OFFSET
#undef AQUARIUM_MAX_OFFSET
