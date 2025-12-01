/datum/element/wears_collar
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///our icon's pathfile
	var/collar_icon
	///our collar's icon state
	var/collar_icon_state
	///iconstate of our collar while resting
	var/collar_resting_icon_state

/datum/element/wears_collar/Attach(datum/target, collar_icon = 'icons/mob/simple/pets.dmi', collar_resting_icon_state = FALSE, collar_icon_state)
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.collar_icon = collar_icon
	src.collar_icon_state = collar_icon_state
	src.collar_resting_icon_state = collar_resting_icon_state

	RegisterSignal(target, COMSIG_ATOM_ATTACKBY, PROC_REF(attach_collar))
	RegisterSignal(target, COMSIG_ATOM_UPDATE_OVERLAYS, PROC_REF(on_overlays_updated))
	RegisterSignal(target, COMSIG_ATOM_EXITED, PROC_REF(on_content_exit))
	RegisterSignal(target, COMSIG_ATOM_ENTERED, PROC_REF(on_content_enter))
	RegisterSignal(target, COMSIG_LIVING_RESTING, PROC_REF(on_rest))
	RegisterSignal(target, COMSIG_MOB_STATCHANGE, PROC_REF(on_stat_change))

/datum/element/wears_collar/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(
		COMSIG_ATOM_ATTACKBY,
		COMSIG_ATOM_UPDATE_OVERLAYS,
		COMSIG_ATOM_EXITED,
		COMSIG_ATOM_ENTERED,
		COMSIG_LIVING_RESTING,
		COMSIG_MOB_STATCHANGE,
	))

/datum/element/wears_collar/proc/on_stat_change(mob/living/source)
	SIGNAL_HANDLER

	if(collar_icon_state)
		source.update_icon(UPDATE_OVERLAYS)

/datum/element/wears_collar/proc/on_content_exit(mob/living/source, atom/moved)
	SIGNAL_HANDLER

	if(!istype(moved, /obj/item/clothing/neck/petcollar))
		return
	source.fully_replace_character_name(null, source::name)
	if(collar_icon_state)
		source.update_appearance()

/datum/element/wears_collar/proc/on_content_enter(mob/living/source, obj/item/clothing/neck/petcollar/new_collar)
	SIGNAL_HANDLER

	if(!istype(new_collar) || !new_collar.tagname)
		return

	source.fully_replace_character_name(null, "\proper [new_collar.tagname]")
	if(collar_icon_state)
		source.update_appearance()

/datum/element/wears_collar/proc/attach_collar(atom/source, atom/movable/attacking_item, atom/user, params)
	SIGNAL_HANDLER

	if(!istype(attacking_item, /obj/item/clothing/neck/petcollar))
		return NONE
	if(locate(/obj/item/clothing/neck/petcollar) in source)
		user.balloon_alert(source, "already wearing a collar!")
		return NONE
	attacking_item.forceMove(source)
	return COMPONENT_NO_AFTERATTACK

/datum/element/wears_collar/proc/on_overlays_updated(mob/living/source, list/overlays)
	SIGNAL_HANDLER

	if(!locate(/obj/item/clothing/neck/petcollar) in source)
		return

	var/icon_tag = ""

	if(source.stat == DEAD || HAS_TRAIT(source, TRAIT_FAKEDEATH))
		icon_tag = "_dead"
	else if(collar_resting_icon_state && source.resting)
		icon_tag =  "_rest"

	overlays += mutable_appearance(collar_icon, "[collar_icon_state][icon_tag]collar")
	overlays += mutable_appearance(collar_icon, "[collar_icon_state][icon_tag]tag")


/datum/element/wears_collar/proc/on_rest(atom/movable/source)
	SIGNAL_HANDLER

	source.update_icon(UPDATE_OVERLAYS)
