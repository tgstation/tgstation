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
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(handle_attackby))
	RegisterSignal(parent, COMSIG_FISHING_ROD_CAST, PROC_REF(handle_cast))

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

/datum/component/fishing_spot/proc/try_start_fishing(obj/item/possibly_rod, mob/user)
	SIGNAL_HANDLER
	var/obj/item/fishing_rod/rod = possibly_rod
	if(!istype(rod))
		return
	if(HAS_TRAIT(user,TRAIT_GONE_FISHING) || rod.currently_hooked_item)
		user.balloon_alert(user, "already fishing")
		return COMPONENT_NO_AFTERATTACK
	var/denial_reason = fish_source.reason_we_cant_fish(rod, user)
	if(denial_reason)
		to_chat(user, span_warning(denial_reason))
		return COMPONENT_NO_AFTERATTACK
	start_fishing_challenge(rod, user)
	return COMPONENT_NO_AFTERATTACK

/datum/component/fishing_spot/proc/start_fishing_challenge(obj/item/fishing_rod/rod, mob/user)
	/// Roll what we caught based on modified table
	var/result = fish_source.roll_reward(rod, user)
	var/datum/fishing_challenge/challenge = new(src, result, rod, user)
	fish_source.pre_challenge_started(rod, user, challenge)
	challenge.start(user)
