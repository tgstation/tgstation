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
	force = 5
	attack_verb_continuous = list("bashes", "carries")
	attack_verb_simple = list("bash", "carry")
	w_class = WEIGHT_CLASS_BULKY
	throw_speed = 2
	throw_range = 3
	custom_materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT * 7.5, /datum/material/glass = SMALL_MATERIAL_AMOUNT)
	var/open = TRUE
	var/locked = FALSE
	var/list/occupants = list()
	var/occupant_weight = 0
	var/max_occupants = 3 //Hard-cap so you can't have infinite mice or something in one carrier
	var/max_occupant_weight = MOB_SIZE_SMALL //This is calculated from the mob sizes of occupants

/obj/item/pet_carrier/Destroy()
	if(occupants.len)
		for(var/V in occupants)
			remove_occupant(V)
	return ..()

/obj/item/pet_carrier/Exited(atom/movable/gone, direction)
	if(isliving(gone) && (gone in occupants))
		var/mob/living/L = gone
		occupants -= gone
		occupant_weight -= L.mob_size

/obj/item/pet_carrier/handle_atom_del(atom/A)
	if(A in occupants && isliving(A))
		var/mob/living/L = A
		occupants -= L
		occupant_weight -= L.mob_size
	..()

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
	if(!open)
		. += span_notice("Alt-click to [locked ? "unlock" : "lock"] its door.")

/obj/item/pet_carrier/attack_self(mob/living/user)
	if(open)
		to_chat(user, span_notice("You close [src]'s door."))
		playsound(user, 'sound/effects/bin_close.ogg', 50, TRUE)
		open = FALSE
	else
		if(locked)
			to_chat(user, span_warning("[src] is locked!"))
			return
		to_chat(user, span_notice("You open [src]'s door."))
		playsound(user, 'sound/effects/bin_open.ogg', 50, TRUE)
		open = TRUE
	update_appearance()

/obj/item/pet_carrier/AltClick(mob/living/user)
	if(open || !user.can_perform_action(src))
		return
	locked = !locked
	to_chat(user, span_notice("You flip the lock switch [locked ? "down" : "up"]."))
	if(locked)
		playsound(user, 'sound/machines/boltsdown.ogg', 30, TRUE)
	else
		playsound(user, 'sound/machines/boltsup.ogg', 30, TRUE)
	update_appearance()

/obj/item/pet_carrier/attack(mob/living/target, mob/living/user)
	if(user.combat_mode)
		return ..()
	if(!open)
		to_chat(user, span_warning("You need to open [src]'s door!"))
		return
	if(target.mob_size > max_occupant_weight)
		if(ishuman(target))
			var/mob/living/carbon/human/H = target
			if(isfelinid(H))
				to_chat(user, span_warning("You'd need a lot of catnip and treats, plus maybe a laser pointer, for that to work."))
			else
				to_chat(user, span_warning("Humans, generally, do not fit into pet carriers."))
		else
			to_chat(user, span_warning("You get the feeling [target] isn't meant for a [name]."))
		return
	if(user == target)
		to_chat(user, span_warning("Why would you ever do that?"))
		return
	load_occupant(user, target)

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
		to_chat(user, span_boldannounce("Bingo! The lock pops open!"))
		locked = FALSE
		playsound(src, 'sound/machines/boltsup.ogg', 30, TRUE)
		update_appearance()
	else
		loc.visible_message(span_warning("[src] starts rattling as something pushes against the door!"), null, null, null, user)
		to_chat(user, span_notice("You start pushing out of [src]... (This will take about 20 seconds.)"))
		if(!do_after(user, 200, target = user) || open || !locked || !(user in occupants))
			return
		loc.visible_message(span_warning("[user] shoves out of [src]!"), null, null, null, user)
		to_chat(user, span_notice("You shove open [src]'s door against the lock's resistance and fall out!"))
		locked = FALSE
		open = TRUE
		update_appearance()
		remove_occupant(user)

/obj/item/pet_carrier/update_icon_state()
	if(open)
		icon_state = initial(icon_state)
		return ..()
	icon_state = "[base_icon_state]_[!occupants.len ? "closed" : "occupied"]"
	return ..()

/obj/item/pet_carrier/update_overlays()
	. = ..()
	if(!open)
		. += "[base_icon_state]_[locked ? "" : "un"]locked"

/obj/item/pet_carrier/MouseDrop(atom/over_atom)
	. = ..()
	if(isopenturf(over_atom) && usr.can_perform_action(src, NEED_DEXTERITY) && usr.Adjacent(over_atom) && open && occupants.len)
		usr.visible_message(span_notice("[usr] unloads [src]."), \
		span_notice("You unload [src] onto [over_atom]."))
		for(var/V in occupants)
			remove_occupant(V, over_atom)

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
	if(occupant in occupants || !istype(occupant))
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

#undef pet_carrier_full
