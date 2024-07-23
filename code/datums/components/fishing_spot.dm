// A thing you can fish in
/datum/component/fishing_spot
	/// Defines the probabilities and fish availibilty
	var/datum/fish_source/fish_source

/datum/component/fishing_spot/Initialize(configuration)
	if(ispath(configuration,/datum/fish_source))
		//Create new one of the given type
		fish_source = new configuration
	else if(istype(configuration,/datum/fish_source))
		//Use passed in instance
		fish_source = configuration
	else
		return COMPONENT_INCOMPATIBLE
	fish_source.on_fishing_spot_init()
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(handle_attackby))
	RegisterSignal(parent, COMSIG_FISHING_ROD_CAST, PROC_REF(handle_cast))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examined_more))
	RegisterSignal(parent, COMSIG_ATOM_EX_ACT, PROC_REF(explosive_fishing))
	ADD_TRAIT(parent, TRAIT_FISHING_SPOT, REF(src))

/datum/component/fishing_spot/Destroy()
	fish_source = null
	return ..()

/datum/component/fishing_spot/proc/handle_cast(datum/source, obj/item/fishing_rod/rod, mob/user)
	SIGNAL_HANDLER
	if(try_start_fishing(rod,user))
		return FISHING_ROD_CAST_HANDLED
	return NONE

/datum/component/fishing_spot/proc/handle_attackby(datum/source, obj/item/item, mob/user, params)
	SIGNAL_HANDLER
	if(try_start_fishing(item,user))
		return COMPONENT_NO_AFTERATTACK
	return NONE

///If the fish source has fishes that are shown in the
/datum/component/fishing_spot/proc/on_examined(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if(!HAS_MIND_TRAIT(user, TRAIT_EXAMINE_FISHING_SPOT))
		return

	var/has_known_fishes = FALSE
	for(var/reward in fish_source.fish_table)
		if(!ispath(reward, /obj/item/fish))
			continue
		var/obj/item/fish/prototype = reward
		if(initial(prototype.show_in_catalog))
			has_known_fishes = TRUE
			break
	if(!has_known_fishes)
		return

	examine_text += span_tinynoticeital("This is a fishing spot. You can look again to list its fishes...")

/datum/component/fishing_spot/proc/on_examined_more(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if(!HAS_MIND_TRAIT(user, TRAIT_EXAMINE_FISHING_SPOT))
		return

	var/list/known_fishes = list()
	for(var/reward in fish_source.fish_table)
		if(!ispath(reward, /obj/item/fish))
			continue
		var/obj/item/fish/prototype = reward
		if(initial(prototype.show_in_catalog))
			known_fishes += initial(prototype.name)

	if(!length(known_fishes))
		return

	examine_text += span_info("You can catch the following fish here: [english_list(known_fishes)].")

/datum/component/fishing_spot/proc/try_start_fishing(obj/item/possibly_rod, mob/user)
	SIGNAL_HANDLER
	var/obj/item/fishing_rod/rod = possibly_rod
	if(!istype(rod))
		return
	if(HAS_TRAIT(user,TRAIT_GONE_FISHING) || rod.fishing_line)
		user.balloon_alert(user, "already fishing")
		return COMPONENT_NO_AFTERATTACK
	var/denial_reason = fish_source.reason_we_cant_fish(rod, user, parent)
	if(denial_reason)
		to_chat(user, span_warning(denial_reason))
		return COMPONENT_NO_AFTERATTACK
	// In case the fishing source has anything else to do before beginning to fish.
	fish_source.on_start_fishing(rod, user, parent)
	start_fishing_challenge(rod, user)
	return COMPONENT_NO_AFTERATTACK

/datum/component/fishing_spot/proc/start_fishing_challenge(obj/item/fishing_rod/rod, mob/user)
	/// Roll what we caught based on modified table
	var/result = fish_source.roll_reward(rod, user)
	var/datum/fishing_challenge/challenge = new(src, result, rod, user)
	fish_source.pre_challenge_started(rod, user, challenge)
	challenge.start(user)

/datum/component/fishing_spot/proc/explosive_fishing(atom/location, severity)
	SIGNAL_HANDLER
	fish_source.spawn_reward_from_explosion(location, severity)
