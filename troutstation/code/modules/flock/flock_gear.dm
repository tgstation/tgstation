/// Just a bunch of misc items mostly for agents to create with their resources

// CHAMELEON HAT
/obj/item/clothing/head/hats/flock_chameleon
	name = "polymorphic beanie"
	desc = "It looks more like a sad melon covered in wires, but this is apparently the pinnacle of alien hat technology."
	icon_state = "flock"
	icon = 'troutstation/icons/obj/clothing/head/hats.dmi'
	worn_icon = 'troutstation/icons/mob/clothing/head/hats.dmi'

/obj/item/clothing/head/hats/flock_chameleon/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_FLOCKISH_ITEM, ROUNDSTART_TRAIT)

/obj/item/clothing/head/hats/flock_chameleon/examine(mob/user)
	. = ..()
	. += span_notice("Use it on a hat to take that hat's appearance. Use it by itself to reset.")

/obj/item/clothing/head/hats/flock_chameleon/interact_with_atom(atom/target, mob/living/user, list/modifiers)
	if(istype(target, /obj/item/clothing/head))
		var/obj/item/clothing/head/hat = target
		playsound(get_turf(src), 'sound/effects/bamf.ogg', 50, TRUE)
		visible_message(span_notice("[src] liquifies and resolidifies itself into a perfect visual replica of [target]."))
		desc = hat.desc
		icon = hat.icon
		icon_state = hat.icon_state
		inhand_icon_state = hat.inhand_icon_state
		worn_icon = hat.worn_icon
		lefthand_file = hat.lefthand_file
		righthand_file = hat.righthand_file

/obj/item/clothing/head/hats/flock_chameleon/attack_self(mob/user, modifiers)
	if(icon != initial(icon))
		playsound(get_turf(src), 'sound/effects/bamf.ogg', 50, TRUE)
		visible_message(span_notice("[src] liquifies and resolidifies itself into its original shape."))
		desc = initial(desc)
		icon = initial(icon)
		icon_state = initial(icon_state)
		inhand_icon_state = initial(inhand_icon_state)
		worn_icon = initial(worn_icon)
		lefthand_file = initial(lefthand_file)
		righthand_file = initial(righthand_file)

// DOOR/LOCKER/CRATE JACK
// basically functions as a very, very targeted emag, like a door emag
/obj/item/flock_jack
	name = "nonstandard accessor"
	desc = "It's a good thing this works on contact, because you have no idea what you're even looking at."
	icon_state = "accessor"
	icon = 'troutstation/icons/obj/flock_gadgets.dmi'
	var/list/type_whitelist

/obj/item/flock_jack/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_FLOCKISH_ITEM, ROUNDSTART_TRAIT)
	type_whitelist = list(
		typesof(/obj/machinery/door/airlock),
		typesof(/obj/machinery/door/window/),
		typesof(/obj/machinery/door/firedoor),
		typesof(/obj/structure/closet),
	)

/obj/item/flock_jack/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(SHOULD_SKIP_INTERACTION(interacting_with, src, user))
		return NONE
	if(!can_affect(interacting_with, user))
		return ITEM_INTERACT_BLOCKING
	return interface(interacting_with, user) ? ITEM_INTERACT_SUCCESS : ITEM_INTERACT_BLOCKING

/obj/item/flock_jack/proc/interface(atom/target, mob/living/user)
	log_combat(user, target, "attempted to emag via flockjack")
	user.visible_message(span_warning("[user] sticks [src] to [target] and the device begins to melt and meld into it!"),
		span_notice("You stick [src] to [target] and hold it in place as it forms interfacing components, chittering away."),
		span_notice("You hear strange beeping."))
	playsound(get_turf(src), 'troutstation/sound/effects/flock/flock_hack.ogg', 50, TRUE)
	if(!do_after(user, 10 SECONDS, target = target))
		return FALSE
	if(!user.temporarilyRemoveItemFromInventory(src))
		return FALSE
	if(target.emag_act(user, src))
		SSblackbox.record_feedback("tally", "atom_emagged", 1, target.type)
		to_chat(user, span_warning("[src] dissolves completely into the material."))
		qdel(src)
		return TRUE
	else
		to_chat(user, span_warning("Strangely, it doesn't look like it worked. [src] reforms within your grasp."))
		return FALSE

/obj/item/flock_jack/proc/can_affect(atom/target, mob/user)
	for (var/list/subtypelist in type_whitelist)
		if (target.type in subtypelist)
			return TRUE
	to_chat(user, span_warning("[src] has not been given sufficient instructions to deal with this technology."))
	return FALSE

// PLUSHIE because why not
/obj/item/toy/plush/flock_agent
	name = "flock agent plushie"
	desc = "A plushie depicting a flock agent. Whatever that is. It looks adorable, but I wouldn't keep it near your headset."
	icon = 'troutstation/icons/obj/toys/plushes.dmi'
	icon_state = "plushie_flock_agent"
	inhand_icon_state = null
	attack_verb_continuous = list("pecks", "caws at")
	attack_verb_continuous = list("peck", "caw at")
	squeak_override = list(
		'troutstation/sound/effects/flock/flock_scream1.ogg' = 1,
		'troutstation/sound/effects/flock/flock_scream2.ogg' = 1,
	)

/obj/item/toy/plush/flock_agent/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_FLOCKISH_ITEM, ROUNDSTART_TRAIT)
