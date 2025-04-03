#define pet_carrier_full(carrier) carrier.occupants.len >= carrier.max_occupants || carrier.occupant_weight >= carrier.max_occupant_weight

//Used to transport little animals without having to drag them across the station.
//Comes with a handy lock to prevent them from running off.
/obj/item/pet_carrier
	name = "pet carrier"
	desc = "A big white-and-blue pet carrier. Good for carrying <s>meat to the chef</s> cute animals around."
	icon = 'icons/obj/pet_carrier.dmi'
	base_icon_state = "pet_carrier"
	icon_state = "pet_carrier_open"
	inhand_icon_state = "pet_carrier"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	greyscale_config = /datum/greyscale_config/pet_carrier
	greyscale_config_inhand_left = /datum/greyscale_config/pet_carrier_inhands_left
	greyscale_config_inhand_right = /datum/greyscale_config/pet_carrier_inhands_right
	greyscale_colors = COLOR_BLUE
	force = 5
	attack_verb_continuous = list("bashes", "carries")
	attack_verb_simple = list("bash", "carry")
	w_class = WEIGHT_CLASS_BULKY
	throw_speed = 2
	throw_range = 3
	custom_materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT * 7.5, /datum/material/glass = SMALL_MATERIAL_AMOUNT)
	interaction_flags_mouse_drop = NEED_DEXTERITY
	/// Is the pet carrier open? Allows you to collect/remove pets.
	var/open = TRUE
	/// Does this carrier allow locking? Disabled for the small pet carrier.
	var/allows_locking = TRUE
	/// Is this carrier locked? Locks don't require access, just an alt click.
	var/locked = FALSE
	/// List of all mob occupants from inside of the pet carrier.
	var/list/occupants = list()
	/// Combined weight of all mob occupants based on the MOB_SIZE_ defines.
	var/occupant_weight = 0
	/// Maximum number of mobs that can fit in a pet carrier, so you can't have infinite mice or something in one carrier
	var/max_occupants = 3
	/// Maximum weight of a mob that can be carried. This is calculated from the mob sizes of occupants
	var/max_occupant_weight = MOB_SIZE_SMALL

	/// Sound played when the mob carrier is opened.
	var/open_sound = 'sound/items/handling/cardboard_box/cardboard_box_rustle.ogg'
	/// Sound played when the mob carrier is closed.
	var/close_sound = 'sound/items/handling/cardboard_box/cardboardbox_drop.ogg'

/obj/item/pet_carrier/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/pet_carrier/Destroy()
	if(occupants.len)
		for(var/V in occupants)
			remove_occupant(V)
	return ..()

/obj/item/pet_carrier/Exited(atom/movable/gone, direction)
	. = ..()
	if(isliving(gone) && (gone in occupants))
		var/mob/living/living_gone = gone
		occupants -= gone
		occupant_weight -= living_gone.mob_size

/obj/item/pet_carrier/examine(mob/user)
	. = ..()
	if(occupants.len)
		for(var/V in occupants)
			var/mob/living/L = V
			. += span_notice("It has [L] inside.")
	else
		. += span_notice("It has nothing inside.")

	// At some point these need to be converted to contextual screentips
	. += span_notice("Activate it in your hand to [open ? "close" : "open"] its door. Click-drag onto floor to release its occupants.")
	if(!open && allows_locking)
		. += span_notice("Alt-click to [locked ? "unlock" : "lock"] its door.")

/obj/item/pet_carrier/attack_self(mob/living/user)
	if(open)
		to_chat(user, span_notice("You close [src]'s door."))
		playsound(user, close_sound, 50, TRUE)
		open = FALSE
	else
		if(locked)
			to_chat(user, span_warning("[src] is locked!"))
			return
		to_chat(user, span_notice("You open [src]'s door."))
		playsound(user, open_sound, 50, TRUE)
		open = TRUE
	update_appearance()

/obj/item/pet_carrier/click_alt(mob/living/user)
	if(open || !allows_locking)
		return CLICK_ACTION_BLOCKING
	locked = !locked
	to_chat(user, span_notice("You flip the lock switch [locked ? "down" : "up"]."))
	if(locked)
		playsound(user, 'sound/machines/airlock/boltsdown.ogg', 30, TRUE)
	else
		playsound(user, 'sound/machines/airlock/boltsup.ogg', 30, TRUE)
	update_appearance()
	return CLICK_ACTION_SUCCESS

/obj/item/pet_carrier/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(user.combat_mode || !isliving(interacting_with))
		return NONE
	if(!open)
		to_chat(user, span_warning("You need to open [src]'s door!"))
		return ITEM_INTERACT_BLOCKING
	var/mob/living/target = interacting_with
	if(target.mob_size > max_occupant_weight)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(isfelinid(H))
				to_chat(user, span_warning("You'd need a lot of catnip and treats, plus maybe a laser pointer, for that to work."))
			else
				to_chat(user, span_warning("Humans, generally, do not fit into pet carriers."))
		else
			to_chat(user, span_warning("You get the feeling [target] isn't meant for a [name]."))
		return ITEM_INTERACT_BLOCKING
	if(user == target)
		to_chat(user, span_warning("Why would you ever do that?"))
		return ITEM_INTERACT_BLOCKING
	load_occupant(user, target)
	return ITEM_INTERACT_SUCCESS

/obj/item/pet_carrier/relaymove(mob/living/user, direction)
	if(open)
		loc.visible_message(span_notice("[user] climbs out of [src]!"), \
		span_warning("[user] jumps out of [src]!"))
		remove_occupant(user)
		return
	else if(!locked)
		loc.visible_message(span_notice("[user] pushes open the door to [src]!"), \
		span_warning("[user] pushes open the door of [src]!"))
		open = TRUE
		update_appearance()
		return
	else if(user.client)
		container_resist_act(user)

/obj/item/pet_carrier/container_resist_act(mob/living/user)
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	if(user.mob_size <= MOB_SIZE_SMALL)
		to_chat(user, span_notice("You poke a limb through [src]'s bars and start fumbling for the lock switch... (This will take some time.)"))
		to_chat(loc, span_warning("You see [user] reach through the bars and fumble for the lock switch!"))
		if(!do_after(user, rand(300, 400), target = user) || open || !locked || !(user in occupants))
			return
		loc.visible_message(span_warning("[user] flips the lock switch on [src] by reaching through!"), null, null, null, user)
		to_chat(user, span_bolddanger("Bingo! The lock pops open!"))
		locked = FALSE
		playsound(src, 'sound/machines/airlock/boltsup.ogg', 30, TRUE)
		update_appearance()
	else
		loc.visible_message(span_warning("[src] starts rattling as something pushes against the door!"), null, null, null, user)
		to_chat(user, span_notice("You start pushing out of [src]... (This will take about 20 seconds.)"))
		if(!do_after(user, 20 SECONDS, target = user) || open || !locked || !(user in occupants))
			return
		loc.visible_message(span_warning("[user] shoves out of [src]!"), null, null, null, user)
		to_chat(user, span_notice("You shove open [src]'s door against the lock's resistance and fall out!"))
		locked = FALSE
		open = TRUE
		update_appearance()
		remove_occupant(user)

/obj/item/pet_carrier/update_icon_state()
	if(open)
		icon_state = "[base_icon_state]_open"
		return ..()
	icon_state = "[base_icon_state]_[!occupants.len ? "closed" : "occupied"]_[locked ? "locked" : "unlocked"]"
	return ..()

/obj/item/pet_carrier/mouse_drop_dragged(atom/over_atom, mob/user, src_location, over_location, params)
	if(isopenturf(over_atom) && open && occupants.len)
		user.visible_message(span_notice("[user] unloads [src]."), \
		span_notice("You unload [src] onto [over_atom]."))
		for(var/V in occupants)
			remove_occupant(V, over_atom)

/obj/item/pet_carrier/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()

	if(!locked)
		context[SCREENTIP_CONTEXT_LMB] = open ? "Close door" : "Open door"
		return TRUE
	if(allows_locking)
		context[SCREENTIP_CONTEXT_ALT_LMB] = locked ? "Unlock door" : "Lock door"
		return  TRUE

/obj/item/pet_carrier/proc/load_occupant(mob/living/user, mob/living/target)
	if(pet_carrier_full(src))
		to_chat(user, span_warning("[src] is already carrying too much!"))
		return
	user.visible_message(span_notice("[user] starts loading [target] into [src]."), \
	span_notice("You start loading [target] into [src]..."), null, null, target)
	to_chat(target, span_userdanger("[user] starts loading you into [user.p_their()] [name]!"))
	if(!do_after(user, 3 SECONDS, target))
		return
	if(target in occupants)
		return
	if(pet_carrier_full(src)) //Run the checks again, just in case
		to_chat(user, span_warning("[src] is already carrying too much!"))
		return
	user.visible_message(span_notice("[user] loads [target] into [src]!"), \
	span_notice("You load [target] into [src]."), null, null, target)
	to_chat(target, span_userdanger("[user] loads you into [user.p_their()] [name]!"))
	add_occupant(target)

/obj/item/pet_carrier/proc/add_occupant(mob/living/occupant)
	if((occupant in occupants) || !istype(occupant))
		return
	occupant.forceMove(src)
	occupants += occupant
	occupant_weight += occupant.mob_size

/obj/item/pet_carrier/proc/remove_occupant(mob/living/occupant, turf/new_turf)
	if(!(occupant in occupants) || !istype(occupant))
		return
	occupant.forceMove(new_turf ? new_turf : drop_location())
	occupants -= occupant
	occupant_weight -= occupant.mob_size
	occupant.setDir(SOUTH)

/obj/item/pet_carrier/biopod
	name = "biopod"
	desc = "Alien device used for undescribable purpose. Or carrying pets."
	base_icon_state = "biopod"
	icon_state = "biopod_open"
	inhand_icon_state = "biopod"
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_colors = null

/obj/item/pet_carrier/small
	name = "small pet carrier"
	desc = "A small pet carrier for miniature sized animals."
	w_class = WEIGHT_CLASS_NORMAL
	base_icon_state = "small_carrier"
	icon_state = "small_carrier_open"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	greyscale_config = null
	greyscale_config_inhand_left = null
	greyscale_config_inhand_right = null
	greyscale_colors = null

	max_occupants = 1
	allows_locking = FALSE

/obj/item/pet_carrier/small/mouse
	name = "small mouse carrier"
	desc = "A small pet carrier for miniature sized animals. This looks prepared for a mouse."
	open = FALSE
	icon_state = "small_carrier_occupied_unlocked"

/obj/item/pet_carrier/small/mouse/Initialize(mapload)
	var/mob/living/basic/mouse/hero_mouse = new /mob/living/basic/mouse(src)
	add_occupant(hero_mouse) //mouse hero
	return ..()

#undef pet_carrier_full
