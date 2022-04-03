//These are tools that can hold only specific items. For example, the mediborg gets one that can only hold beakers and bottles.
/obj/item/borg/apparatus
	name = "unknown storage apparatus"
	desc = "This device seems nonfunctional."
	icon = 'icons/mob/robot_items.dmi'
	icon_state = "hugmodule"
	var/obj/item/stored
	var/list/storable = list()

/obj/item/borg/apparatus/Initialize(mapload)
	. = ..()
	RegisterSignal(loc.loc, COMSIG_BORG_SAFE_DECONSTRUCT, .proc/safedecon)

/obj/item/borg/apparatus/Destroy()
	QDEL_NULL(stored)
	. = ..()

///If we're safely deconstructed, we put the item neatly onto the ground, rather than deleting it.
/obj/item/borg/apparatus/proc/safedecon()
	SIGNAL_HANDLER

	if(stored)
		stored.forceMove(get_turf(src))
		stored = null

/obj/item/borg/apparatus/Exited(atom/movable/gone, direction)
	if(gone == stored) //sanity check
		UnregisterSignal(stored, COMSIG_ATOM_UPDATED_ICON)
		stored = null
	update_appearance()
	return ..()

/**
* Attack_self will pass for the stored item.
*/
/obj/item/borg/apparatus/attack_self(mob/living/silicon/robot/user)
	if(!stored || !issilicon(user))
		return ..()
	stored.attack_self(user)

//Alt click drops the stored item.
/obj/item/borg/apparatus/AltClick(mob/living/silicon/robot/user)
	if(!stored || !issilicon(user))
		return ..()
	stored.forceMove(user.drop_location())

/obj/item/borg/apparatus/pre_attack(atom/atom, mob/living/user, params)
	if(!stored)
		if (!is_type_in_list(atom, storable))
			return ..()
		var/obj/item/item = atom
		item.forceMove(src)
		stored = item
		RegisterSignal(stored, COMSIG_ATOM_UPDATED_ICON, .proc/on_stored_updated_icon)
		update_appearance()
	else
		stored.melee_attack_chain(user, atom, params)
/**
 * Updates the appearance of the apparatus when the stored object's icon gets updated.
 *
 * Returns NONE as we have not done anything to the stored object itself,
 * which is where this signal that this handler intercepts is sent from.
 */
/obj/item/borg/apparatus/proc/on_stored_updated_icon(datum/source, updates)
	SIGNAL_HANDLER

	update_appearance()
	return NONE

/obj/item/borg/apparatus/attackby(obj/item/item, mob/user, params)
	if(stored)
		item.melee_attack_chain(user, stored, params)
		return
	return ..()

//beaker holder
/obj/item/borg/apparatus/beaker
	name = "beaker storage apparatus"
	desc = "A special apparatus for carrying beakers without spilling the contents."
	icon_state = "borg_beaker_apparatus"
	storable = list(/obj/item/reagent_containers/glass/beaker,
					/obj/item/reagent_containers/glass/bottle)

/obj/item/borg/apparatus/beaker/Initialize(mapload)
	. = ..()
	add_glass()
	RegisterSignal(stored, COMSIG_ATOM_UPDATED_ICON, .proc/on_stored_updated_icon)
	update_appearance()

/obj/item/borg/apparatus/beaker/Destroy()
	if(stored)
		var/obj/item/reagent_containers/container = stored
		container.SplashReagents(get_turf(src))
	QDEL_NULL(stored)
	. = ..()

/obj/item/borg/apparatus/beaker/proc/add_glass()
	stored = new /obj/item/reagent_containers/glass/beaker/large(src)

/obj/item/borg/apparatus/beaker/examine()
	. = ..()
	if(stored)
		var/obj/item/reagent_containers/container = stored
		. += "The apparatus currently has [container] secured, which contains:"
		if(length(container.reagents.reagent_list))
			for(var/datum/reagent/reagent in container.reagents.reagent_list)
				. += "[reagent.volume] units of [reagent.name]"
		else
			. += "Nothing."

		. += span_notice(" <i>Right-clicking</i> will splash the beaker on the ground.")
	. += span_notice(" <i>Alt-click</i> will drop the currently stored beaker. ")

/obj/item/borg/apparatus/beaker/update_overlays()
	. = ..()
	var/mutable_appearance/arm = mutable_appearance(icon = icon, icon_state = "borg_beaker_apparatus_arm")
	if(stored)
		COMPILE_OVERLAYS(stored)
		stored.pixel_x = 0
		stored.pixel_y = 0
		var/mutable_appearance/stored_copy = new /mutable_appearance(stored)
		if(istype(stored, /obj/item/reagent_containers/glass/beaker))
			arm.pixel_y = arm.pixel_y - 3
		stored_copy.layer = FLOAT_LAYER
		stored_copy.plane = FLOAT_PLANE
		. += stored_copy
	else
		arm.pixel_y = arm.pixel_y - 5
	. += arm

/// Secondary attack spills the content of the beaker.
/obj/item/borg/apparatus/beaker/pre_attack_secondary(atom/target, mob/living/silicon/robot/user)
	var/obj/item/reagent_containers/stored_beaker = stored
	stored_beaker.SplashReagents(drop_location(user))
	loc.visible_message(span_notice("[user] spills the contents of [stored_beaker] all over the ground."))
	return ..()

/obj/item/borg/apparatus/beaker/extra
	name = "secondary beaker storage apparatus"
	desc = "A supplementary beaker storage apparatus."

/obj/item/borg/apparatus/beaker/service
	name = "beverage storage apparatus"
	desc = "A special apparatus for carrying drinks without spilling the contents. Will resynthesize any drinks you pour out!"
	icon_state = "borg_beaker_apparatus"
	storable = list(/obj/item/reagent_containers/food/drinks,
					/obj/item/reagent_containers/food/condiment)

/obj/item/borg/apparatus/beaker/service/add_glass()
	stored = new /obj/item/reagent_containers/food/drinks/drinkingglass(src)
	handle_refilling(stored, loc.loc, force = TRUE)

/obj/item/borg/apparatus/beaker/service/proc/handle_refilling(obj/item/reagent_containers/glass, mob/living/silicon/robot/bro, force = FALSE)
	if (isnull(bro))
		bro = loc
	if (!iscyborg(bro))
		return

	if (!stored || force)
		glass.AddComponent(/datum/component/reagent_refiller, cell = bro?.cell)

/obj/item/borg/apparatus/beaker/service/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	if (!istype(arrived, /obj/item/reagent_containers/food/drinks))
		return
	handle_refilling(arrived)
	return ..()

//Organ storage bag
/obj/item/borg/apparatus/organ_storage //allows medical cyborgs to manipulate organs without hands
	name = "organ storage bag"
	desc = "A container for holding body parts."
	icon = 'icons/obj/storage.dmi'
	icon_state = "evidenceobj"
	item_flags = SURGICAL_TOOL
	storable = list(/obj/item/organ,
					/obj/item/bodypart)

/obj/item/borg/apparatus/organ_storage/examine()
	. = ..()
	. += "The organ bag currently contains:"
	if(stored)
		var/obj/item/organ = stored
		. += organ.name
	else
		. += "Nothing."
	. += span_notice(" <i>Alt-click</i> will drop the currently stored organ. ")

/obj/item/borg/apparatus/organ_storage/update_overlays()
	. = ..()
	icon_state = null // hides the original icon (otherwise it's drawn underneath)
	var/mutable_appearance/bag
	if(stored)
		COMPILE_OVERLAYS(stored)
		var/mutable_appearance/stored_organ = new /mutable_appearance(stored)
		stored_organ.layer = FLOAT_LAYER
		stored_organ.plane = FLOAT_PLANE
		stored_organ.pixel_x = 0
		stored_organ.pixel_y = 0
		. += stored_organ
		bag = mutable_appearance(icon, icon_state = "evidence") // full bag
	else
		bag = mutable_appearance(icon, icon_state = "evidenceobj") // empty bag
	. += bag

/obj/item/borg/apparatus/organ_storage/AltClick(mob/living/silicon/robot/user)
	. = ..()
	if(stored)
		var/obj/item/organ = stored
		user.visible_message(span_notice("[user] dumps [organ] from [src]."), span_notice("You dump [organ] from [src]."))
		cut_overlays()
		organ.forceMove(get_turf(src))
	else
		to_chat(user, span_notice("[src] is empty."))
