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
	fish_source.on_fishing_spot_init(src)
	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(handle_attackby))
	RegisterSignal(parent, COMSIG_FISHING_ROD_CAST, PROC_REF(handle_cast))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examined))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE_MORE, PROC_REF(on_examined_more))
	RegisterSignal(parent, COMSIG_NPC_FISHING, PROC_REF(return_fishing_spot))
	RegisterSignal(parent, COMSIG_ATOM_EX_ACT, PROC_REF(explosive_fishing))
	RegisterSignal(parent, COMSIG_FISH_RELEASED_INTO, PROC_REF(fish_released))
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL), PROC_REF(link_to_fish_porter))
	ADD_TRAIT(parent, TRAIT_FISHING_SPOT, REF(src))

/datum/component/fishing_spot/Destroy()
	REMOVE_TRAIT(parent, TRAIT_FISHING_SPOT, REF(src))
	fish_source.on_fishing_spot_del(src)
	fish_source = null
	REMOVE_TRAIT(parent, TRAIT_FISHING_SPOT, REF(src))
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

	if(!fish_source.has_known_fishes())
		return

	examine_text += span_tinynoticeital("This is a fishing spot. You can look again to list its fishes...")

/datum/component/fishing_spot/proc/on_examined_more(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER
	if(!HAS_MIND_TRAIT(user, TRAIT_EXAMINE_FISHING_SPOT))
		return

	fish_source.get_catchable_fish_names(user, parent, examine_text)

/datum/component/fishing_spot/proc/try_start_fishing(obj/item/possibly_rod, mob/user)
	SIGNAL_HANDLER
	var/obj/item/fishing_rod/rod = possibly_rod
	if(!istype(rod))
		return
	if(GLOB.fishing_challenges_by_user[user] || rod.fishing_line)
		user.balloon_alert(user, "already fishing")
		return COMPONENT_NO_AFTERATTACK
	var/denial_reason = fish_source.reason_we_cant_fish(rod, user, parent)
	if(denial_reason)
		to_chat(user, span_warning(denial_reason))
		return COMPONENT_NO_AFTERATTACK
	// In case the fishing source has anything else to do before beginning to fish.
	fish_source.on_start_fishing(rod, user, parent)
	var/datum/fishing_challenge/challenge = new(src, rod, user)
	fish_source.pre_challenge_started(rod, user, challenge)
	challenge.start(user)
	return COMPONENT_NO_AFTERATTACK

/datum/component/fishing_spot/proc/return_fishing_spot(datum/source, list/fish_spot_container)
	fish_spot_container[NPC_FISHING_SPOT] = fish_source

/datum/component/fishing_spot/proc/explosive_fishing(atom/location, severity)
	SIGNAL_HANDLER
	fish_source.spawn_reward_from_explosion(location, severity)

/datum/component/fishing_spot/proc/link_to_fish_porter(atom/source, mob/user, obj/item/multitool/tool)
	SIGNAL_HANDLER
	if(istype(tool.buffer, /obj/machinery/fishing_portal_generator))
		var/obj/machinery/fishing_portal_generator/portal = tool.buffer
		return portal.link_fishing_spot(fish_source, source, user)

/datum/component/fishing_spot/proc/fish_released(datum/source, obj/item/fish/fish, mob/living/releaser)
	SIGNAL_HANDLER
	fish_source.readd_fish(fish, releaser)
