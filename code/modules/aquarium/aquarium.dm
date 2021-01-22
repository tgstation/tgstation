#define AQUARIUM_FLUID_FRESHWATER "Freshwater"
#define AQUARIUM_FLUID_SALTWATER "Saltwater"
#define AQUARIUM_FLUID_SULPHWATEVER "Sulphuric Water"
#define AQUARIUM_FLUID_AIR "Air"

#define AQUARIUM_LAYER_STEP 0.01
/// Aquarium content layer offsets
#define AQUARIUM_MIN_OFFSET 0.01
#define AQUARIUM_MAX_OFFSET 1

#define FISH_ALIVE "alive"
#define FISH_DEAD "dead"

#define MIN_AQUARIUM_TEMP T0C
#define MAX_AQUARIUM_TEMP T0C + 100

#define AQUARIUM_COMPANY "Aquatech Ltd."

/obj/structure/aquarium
	name = "aquarium"
	density = TRUE
	anchored = TRUE

	icon = 'icons/obj/aquarium.dmi'
	icon_state = "aquarium_base"

	integrity_failure = 0.3

	var/fluid_type = AQUARIUM_FLUID_FRESHWATER
	var/fluid_temp = MIN_AQUARIUM_TEMP
	var/min_fluid_temp = MIN_AQUARIUM_TEMP
	var/max_fluid_temp = MAX_AQUARIUM_TEMP
	var/lamp = FALSE

	var/glass_icon_state = "aquarium_glass"
	var/broken_glass_icon_state = "aquarium_glass_broken"

	//This is the area where fish can swim
	var/aquarium_zone_min_px = 2
	var/aquarium_zone_max_px = 31
	var/aquarium_zone_min_py = 10
	var/aquarium_zone_max_py = 24

	var/list/fluid_types = list(AQUARIUM_FLUID_SALTWATER,AQUARIUM_FLUID_FRESHWATER,AQUARIUM_FLUID_SULPHWATEVER,AQUARIUM_FLUID_AIR)

	var/panel_open = TRUE

	///Current layers in use by aquarium contents
	var/list/used_layers = list()

/obj/structure/aquarium/Initialize()
	. = ..()
	update_icon()


/obj/structure/aquarium/proc/request_layer(layer_type)
	/**
	 * base aq layer
	 * min_offset = this value is returned on bottom layer mode
	 * min_offset + 0.1 fish1
	 * min_offset + 0.2 fish2
	 * ... these layers are returned for auto layer mode and tracked by used_layers
	 * min_offset + max_offset = this value is returned for top layer mode
	 * min_offset + max_offset + 1 = this is used for glass overlay
	 */
	//optional todo: hook up sending surface changed on aquarium changing layers
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

/obj/structure/aquarium/proc/free_layer(value)
	used_layers -= value

/obj/structure/aquarium/proc/get_surface_properties()
	. = list()
	.[AQUARIUM_PROPERTIES_PX_MIN] = aquarium_zone_min_px
	.[AQUARIUM_PROPERTIES_PX_MAX] = aquarium_zone_max_px
	.[AQUARIUM_PROPERTIES_PY_MIN] = aquarium_zone_min_py
	.[AQUARIUM_PROPERTIES_PY_MAX] = aquarium_zone_max_py

/obj/structure/aquarium/update_overlays()
	. = ..()
	if(panel_open)
		. += "panel"

	//Glass overlay goes on top of everything else.
	var/mutable_appearance/glass_overlay = mutable_appearance(icon,broken ? broken_glass_icon_state : glass_icon_state,layer=AQUARIUM_MAX_OFFSET-1)
	. += glass_overlay

/obj/structure/aquarium/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to [panel_open ? "close" : "open"] the control panel.</span>"

/obj/structure/aquarium/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return ..()
	panel_open = !panel_open
	update_icon()

/obj/structure/aquarium/wrench_act(mob/living/user, obj/item/I)
	if(default_unfasten_wrench(user,I))
		return TRUE

/obj/structure/aquarium/attackby(obj/item/I, mob/living/user, params)
	if(!broken)
		// This signal exists so we common items instead of adding component on init can just register creation of one in response.
		// This way we can avoid the cost of 9999 aquarium components on rocks that will never see water in their life.
		SEND_SIGNAL(I,COMSIG_AQUARIUM_BEFORE_INSERT_CHECK,src)
		if(SEND_SIGNAL(I,COMSIG_AQUARIUM_INSERT_READY,src) & AQUARIUM_CONTENT_READY_TO_INSERT)
			if(user.transferItemToLoc(I,src))
				SEND_SIGNAL(I,COMSIG_AQUARIUM_INSERTED,src)
				update_icon()
				return TRUE
		else if(istype(I,/obj/item/fish_feed))
			feed_fish(user,I)
			return TRUE
		else
			return ..()
	else
		var/obj/item/stack/sheet/glass/G = I
		if(istype(G))
			if(G.get_amount() < 2)
				to_chat(user, "<span class='warning'>You need two glass sheets to fix the case!</span>")
				return
			to_chat(user, "<span class='notice'>You start fixing [src]...</span>")
			if(do_after(user, 20, target = src))
				G.use(2)
				broken = FALSE
				obj_integrity = max_integrity
				update_icon()
			return TRUE
	return ..()

/obj/structure/aquarium/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	SEND_SIGNAL(src,COMSIG_AQUARIUM_STIRRED)


/obj/structure/aquarium/Exited(atom/movable/AM, atom/newLoc)
	. = ..()
	SEND_SIGNAL(AM,COMSIG_AQUARIUM_REMOVED,src)

/obj/structure/aquarium/proc/feed_fish(mob/user, obj/item/fish/feed)
	to_chat(user,"<span class='notice'>You feed the fish.</span>")
	SEND_SIGNAL(src,COMSIG_AQUARIUM_FEEDING,feed.reagents) //todo pass in reagents for specific diets

/obj/structure/aquarium/interact(mob/user)
	if(!broken && user.pulling && user.a_intent == INTENT_GRAB && isliving(user.pulling))
		var/mob/living/L = user.pulling
		SEND_SIGNAL(L,COMSIG_AQUARIUM_BEFORE_INSERT_CHECK,src)
		if(SEND_SIGNAL(L,COMSIG_AQUARIUM_INSERT_READY,src) & AQUARIUM_CONTENT_READY_TO_INSERT)
			try_to_put_mob_in(user)
	else if(panel_open)
		. = ..() //call base ui_interact
	else
		admire(user)

/// Tries to put mob pulled by the user in the aquarium after a delay
/obj/structure/aquarium/proc/try_to_put_mob_in(mob/user)
	if(user.pulling && user.a_intent == INTENT_GRAB && isliving(user.pulling))
		var/mob/living/L = user.pulling
		if(L.buckled || L.has_buckled_mobs())
			to_chat(user, "<span class='warning'>[L] is attached to something!</span>")
			return
		user.visible_message("<span class='danger'>[user] starts to put [L] into [src]!</span>")
		if(do_after(user, 10 SECONDS, target = src))
			if(L && user.pulling == L && !L.buckled && !L.has_buckled_mobs() && (SEND_SIGNAL(L,COMSIG_AQUARIUM_INSERT_READY,src) & AQUARIUM_CONTENT_READY_TO_INSERT))
				user.visible_message("<span class='danger'>[user] stuffs [L] into [src]!</span>")
				L.forceMove(src)
				SEND_SIGNAL(L,COMSIG_AQUARIUM_INSERTED,src)
				update_icon()

///Apply mood bonus depending on aquarium status
/obj/structure/aquarium/proc/admire(mob/user)
	to_chat(user,"<span class='notice'>You take a moment to watch [src].</span>")
	if(do_after(user,5 SECONDS,target = src))
		//Check if there are live fish - good mood
		//All fish dead - bad mood.
		//No fish - nothing.
		var/dead_count = 0
		var/alive_count = 0
		for(var/atom/movable/AM in contents)
			var/datum/component/aquarium_content/AC = AM.GetComponent(/datum/component/aquarium_content)
			if(AC)
				if(istype(AC.properties,/datum/aquarium_behaviour/fish))
					var/datum/aquarium_behaviour/fish/F = AC.properties
					if(F.status == FISH_DEAD)
						dead_count += 1
					else
						alive_count += 1
		if(alive_count > 0)
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "aquarium", /datum/mood_event/aquarium_positive)
		else if(dead_count > 0)
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "aquarium", /datum/mood_event/aquarium_negative)
		// Could maybe scale power of this mood with number/types of fish

/obj/structure/aquarium/ui_data(mob/user)
	. = ..()
	.["fluid_type"] = fluid_type
	.["temperature"] = fluid_temp
	var/list/content_data = list()
	for(var/atom/movable/AM in contents)
		content_data += list(list("name"=AM.name,"ref"=ref(AM)))
	.["contents"] = content_data

/obj/structure/aquarium/ui_static_data(mob/user)
	. = ..()
	//I guess these should depend on the fluid so lava critters can get high or stuff below water freezing point but let's keep it simple for now.
	.["minTemperature"] = min_fluid_temp
	.["maxTemperature"] = max_fluid_temp
	.["fluidTypes"] = fluid_types

/obj/structure/aquarium/ui_act(action, params)
	. = ..()
	var/mob/user = usr
	switch(action)
		if("temperature")
			var/temperature = params["temperature"]
			if(text2num(temperature) != null)
				fluid_temp = clamp(temperature,min_fluid_temp,max_fluid_temp)
				. = TRUE
		if("fluid")
			if(params["fluid"] in fluid_types)
				fluid_type = params["fluid"]
				SEND_SIGNAL(src,COMSIG_AQUARIUM_FLUID_CHANGED,fluid_type)
				. = TRUE
		if("remove")
			var/atom/movable/AM = locate(params["ref"]) in contents
			if(AM)
				if(isitem(AM))
					user.put_in_hands(AM)
				else
					AM.forceMove(get_turf(src))
				to_chat(user,"<span class='notice'>You take out [AM] from [src]</span>")

/obj/structure/aquarium/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Aquarium", name)
		ui.open()

/obj/structure/aquarium/obj_break(damage_flag)
	. = ..()
	if(!broken)
		aquarium_smash()

/obj/structure/aquarium/proc/aquarium_smash()
	broken = TRUE
	var/possible_destinations_for_fish = list()
	var/droploc = drop_location()
	if(isturf(droploc))
		possible_destinations_for_fish = get_adjacent_open_turfs(droploc)
	else
		possible_destinations_for_fish = list(droploc)
	playsound(src, 'sound/effects/glassbr3.ogg', 100, TRUE)
	for(var/atom/movable/AM in contents)
		AM.forceMove(pick(possible_destinations_for_fish))
	if(fluid_type != AQUARIUM_FLUID_AIR)
		var/datum/reagents/R = new()
		R.add_reagent(/datum/reagent/water,30)
		chem_splash(droploc, 3, list(R))
	update_icon()
