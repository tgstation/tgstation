///An element that puts in stasis any fish that enters the atom.
/datum/element/fish_safe_storage
	element_flags = ELEMENT_DETACH_ON_HOST_DESTROY
	var/list/tracked_fish = list()

/datum/element/fish_safe_storage/New()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/datum/element/fish_safe_storage/Attach(atom/target)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE

	RegisterSignal(target, COMSIG_ATOM_ENTERED, PROC_REF(on_enter))
	RegisterSignal(target, COMSIG_ATOM_EXITED, PROC_REF(on_exit))
	RegisterSignal(target, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON, PROC_REF(on_init_on))
	ADD_TRAIT(target, TRAIT_STOP_FISH_FLOPPING, REF(src))
	for(var/obj/item/fish/fish in target)
		tracked_fish |= fish
		ADD_TRAIT(fish, TRAIT_FISH_STASIS, REF(src))

/datum/element/fish_safe_storage/Detach(atom/source)
	for(var/obj/item/fish/fish in source)
		tracked_fish -= fish
		REMOVE_TRAIT(fish, TRAIT_FISH_STASIS, REF(src))
	UnregisterSignal(source, list(COMSIG_ATOM_ENTERED, COMSIG_ATOM_EXITED, COMSIG_ATOM_AFTER_SUCCESSFUL_INITIALIZED_ON))
	REMOVE_TRAIT(source, TRAIT_STOP_FISH_FLOPPING, REF(src))
	return ..()

/datum/element/fish_safe_storage/proc/on_enter(datum/source, obj/item/fish/arrived)
	SIGNAL_HANDLER
	if(isfish(arrived))
		tracked_fish |= arrived
		ADD_TRAIT(arrived, TRAIT_FISH_STASIS, REF(src))

/datum/element/fish_safe_storage/proc/on_init_on(datum/source, obj/item/fish/created)
	SIGNAL_HANDLER
	if(isfish(created) && !QDELETED(created))
		tracked_fish |= created
		ADD_TRAIT(created, TRAIT_FISH_STASIS, REF(src))

/datum/element/fish_safe_storage/proc/on_exit(datum/source, obj/item/fish/gone)
	SIGNAL_HANDLER
	if(isfish(gone))
		tracked_fish -= gone
		REMOVE_TRAIT(gone, TRAIT_FISH_STASIS, REF(src))

/datum/element/fish_safe_storage/process(seconds_per_tick)
	for(var/obj/item/fish/fish as anything in tracked_fish)
		///Keep delaying hunger and breeding while in stasis, and also heal them.
		fish.last_feeding += seconds_per_tick SECONDS
		fish.breeding_wait += seconds_per_tick SECONDS
		if(fish.health < initial(fish.health) * 0.65)
			fish.adjust_health(fish.health + 0.75 * seconds_per_tick)
