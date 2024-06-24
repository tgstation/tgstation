/* Emags
 * Contains:
 * EMAGS AND DOORMAGS
 */


/*
 * EMAG AND SUBTYPES
 */
/obj/item/card/emag
	desc = "It's a card with a magnetic strip attached to some circuitry."
	name = "cryptographic sequencer"
	icon_state = "emag"
	item_flags = NO_MAT_REDEMPTION | NOBLUDGEON
	slot_flags = ITEM_SLOT_ID
	worn_icon_state = "emag"
	var/prox_check = TRUE //If the emag requires you to be in range
	var/type_blacklist //List of types that require a specialized emag

/obj/item/card/emag/attack_self(mob/user) //for traitors with balls of plastitanium
	if(Adjacent(user))
		user.visible_message(span_notice("[user] shows you: [icon2html(src, viewers(user))] [name]."), span_notice("You show [src]."))
	add_fingerprint(user)

/obj/item/card/emag/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(isnull(user) || !istype(emag_card))
		return FALSE
	var/emag_count = 0
	for(var/obj/item/card/emag/emag in get_all_contents() + emag_card.get_all_contents()) // This is including itself
		emag_count++
	if(emag_count > 6) // 1 uplink's worth is the limit
		to_chat(user, span_warning("Nope, lesson learned. No more."))
		return FALSE
	if(emag_card.loc != loc) // Both have to be in your hand (or TK shenanigans)
		return FALSE
	if(!user.transferItemToLoc(emag_card, src, silent = FALSE))
		return FALSE

	user.visible_message(
		span_notice("[user] holds [emag_card] to [src], getting the two cards stuck together!"),
		span_notice("As you hold [emag_card] to [src], [emag_card.p_their()] magnets attract to one another, \
			and [emag_card.p_they()] become stuck together!"),
		visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
	)
	playsound(src, 'sound/effects/bang.ogg', 33, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)
	addtimer(CALLBACK(src, PROC_REF(contemplation_period), user), 2 SECONDS, TIMER_DELETE_ME)
	emag_card.vis_flags |= VIS_INHERIT_ID|VIS_INHERIT_PLANE
	vis_contents += emag_card
	name = initial(name)
	desc = initial(desc)
	var/list/all_emags = get_all_contents_type(/obj/item/card/emag) - src
	for(var/i in 1 to length(all_emags))
		var/obj/item/card/emag/other_emag = all_emags[i]
		other_emag.pixel_x = pixel_x + (4 * i)
		other_emag.pixel_y = pixel_y + (4 * i)
		other_emag.layer = layer - (0.01 * i)
		name += "-[initial(other_emag.name)]"
		desc += " There seems to be another card stuck to it...pretty soundly."
	return TRUE

/obj/item/card/emag/proc/contemplation_period(mob/user)
	if(QDELETED(user))
		return
	if(QDELETED(src))
		to_chat(user, span_notice("Oh, well."))
	else
		to_chat(user, span_warning("Well, shit. Those are never coming apart now."))

/obj/item/card/emag/Exited(atom/movable/gone, direction)
	. = ..()
	if(istype(gone, /obj/item/card/emag))
		// This is here so if(when) admins fish it out of contents it doesn't become glitchy
		gone.layer = initial(gone.layer)
		gone.vis_flags = initial(gone.vis_flags)
		vis_contents -= gone
		name = initial(name)
		desc = initial(desc)
		gone.name = initial(name)
		gone.desc = initial(desc)

/obj/item/card/emag/bluespace
	name = "bluespace cryptographic sequencer"
	desc = "It's a blue card with a magnetic strip attached to some circuitry. It appears to have some sort of transmitter attached to it."
	color = rgb(40, 130, 255)
	prox_check = FALSE

/obj/item/card/emag/halloween
	name = "hack-o'-lantern"
	desc = "It's a pumpkin with a cryptographic sequencer sticking out."
	icon_state = "hack_o_lantern"

/obj/item/card/emagfake
	name = /obj/item/card/emag::name
	desc = /obj/item/card/emag::desc + " Closer inspection shows that this card is a poorly made replica, with a \"Donk Co.\" logo stamped on the back."
	icon = /obj/item/card/emag::icon
	icon_state = /obj/item/card/emag::icon_state
	worn_icon_state = /obj/item/card/emag::worn_icon_state
	slot_flags = ITEM_SLOT_ID
	/// Whether we are exploding
	var/exploding = FALSE

/obj/item/card/emagfake/attack_self(mob/user) //for assistants with balls of plasteel
	if(Adjacent(user))
		user.visible_message(span_notice("[user] shows you: [icon2html(src, viewers(user))] [name]."), span_notice("You show [src]."))
	add_fingerprint(user)

/obj/item/card/emagfake/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(exploding)
		playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE, frequency = 2)
	else if(obj_flags & EMAGGED)
		log_bomber(user, "triggered", src, "(rigged/emagged)")
		visible_message(span_boldwarning("[src] begins to heat up!"))
		playsound(src, 'sound/items/bikehorn.ogg', 100, TRUE, frequency = 0.25)
		addtimer(CALLBACK(src, PROC_REF(blow_up)), 1 SECONDS, TIMER_DELETE_ME)
		exploding = TRUE
	else
		playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)
	return ITEM_INTERACT_SKIP_TO_ATTACK // So it does the attack animation.

/obj/item/card/emagfake/proc/blow_up()
	visible_message(span_boldwarning("[src] explodes!"))
	explosion(src, light_impact_range = 1, explosion_cause = src)
	qdel(src)

/obj/item/card/emagfake/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	playsound(src, SFX_SPARKS, 50, TRUE, SILENCED_SOUND_EXTRARANGE)
	desc = /obj/item/card/emag::desc
	obj_flags |= EMAGGED
	if(user)
		balloon_alert(user, "rigged to blow")
		log_bomber(user, "rigged to blow", src, "(emagging)")
	return TRUE

/obj/item/card/emag/Initialize(mapload)
	. = ..()
	type_blacklist = list(typesof(/obj/machinery/door/airlock) + typesof(/obj/machinery/door/window/) +  typesof(/obj/machinery/door/firedoor) - typesof(/obj/machinery/door/airlock/tram)) //list of all typepaths that require a specialized emag to hack.

/obj/item/card/emag/storage_insert_on_interaction(datum/storage, atom/storage_holder, mob/living/user)
	return !user.combat_mode

/obj/item/card/emag/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!can_emag(interacting_with, user))
		return ITEM_INTERACT_BLOCKING
	log_combat(user, interacting_with, "attempted to emag")
	interacting_with.emag_act(user, src)
	return ITEM_INTERACT_SUCCESS

/obj/item/card/emag/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	return prox_check ? NONE : interact_with_atom(interacting_with, user)

/obj/item/card/emag/proc/can_emag(atom/target, mob/user)
	for (var/subtypelist in type_blacklist)
		if (target.type in subtypelist)
			to_chat(user, span_warning("The [target] cannot be affected by the [src]! A more specialized hacking device is required."))
			return FALSE
	return TRUE

/*
 * DOORMAG
 */
/obj/item/card/emag/doorjack
	desc = "Commonly known as a \"doorjack\", this device is a specialized cryptographic sequencer specifically designed to override station airlock access codes. Uses self-refilling charges to hack airlocks."
	name = "airlock authentication override card"
	icon_state = "doorjack"
	worn_icon_state = "doorjack"
	var/type_whitelist //List of types
	var/charges = 3
	var/max_charges = 3
	var/list/charge_timers = list()
	var/charge_time = 1800 //three minutes

/obj/item/card/emag/doorjack/Initialize(mapload)
	. = ..()
	type_whitelist = list(typesof(/obj/machinery/door/airlock), typesof(/obj/machinery/door/window/), typesof(/obj/machinery/door/firedoor)) //list of all acceptable typepaths that this device can affect

/obj/item/card/emag/doorjack/proc/use_charge(mob/user)
	charges --
	to_chat(user, span_notice("You use [src]. It now has [charges] charge[charges == 1 ? "" : "s"] remaining."))
	charge_timers.Add(addtimer(CALLBACK(src, PROC_REF(recharge)), charge_time, TIMER_STOPPABLE))

/obj/item/card/emag/doorjack/proc/recharge(mob/user)
	charges = min(charges+1, max_charges)
	playsound(src,'sound/machines/twobeep.ogg',10,TRUE, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 0)
	charge_timers.Remove(charge_timers[1])

/obj/item/card/emag/doorjack/examine(mob/user)
	. = ..()
	. += span_notice("It has [charges] charges remaining.")
	if (length(charge_timers))
		. += "[span_notice("<b>A small display on the back reads:")]</b>"
	for (var/i in 1 to length(charge_timers))
		var/timeleft = timeleft(charge_timers[i])
		var/loadingbar = num2loadingbar(timeleft/charge_time)
		. += span_notice("<b>CHARGE #[i]: [loadingbar] ([DisplayTimeText(timeleft)])</b>")

/obj/item/card/emag/doorjack/can_emag(atom/target, mob/user)
	if (charges <= 0)
		to_chat(user, span_warning("[src] is recharging!"))
		return FALSE
	for (var/list/subtypelist in type_whitelist)
		if (target.type in subtypelist)
			return TRUE
	to_chat(user, span_warning("[src] is unable to interface with this. It only seems to fit into airlock electronics."))
	return FALSE

/*
 * Battlecruiser Access
 */
/obj/item/card/emag/battlecruiser
	name = "battlecruiser coordinates upload card"
	desc = "An ominous card that contains the location of the station, and when applied to a communications console, \
	the ability to long-distance contact the Syndicate fleet."
	icon_state = "battlecruisercaller"
	worn_icon_state = "emag"
	///whether we have called the battlecruiser
	var/used = FALSE
	/// The battlecruiser team that the battlecruiser will get added to
	var/datum/team/battlecruiser/team

/obj/item/card/emag/battlecruiser/proc/use_charge(mob/user)
	used = TRUE
	to_chat(user, span_boldwarning("You use [src], and it interfaces with the communication console. No going back..."))

/obj/item/card/emag/battlecruiser/examine(mob/user)
	. = ..()
	. += span_notice("It can only be used on the communications console.")

/obj/item/card/emag/battlecruiser/can_emag(atom/target, mob/user)
	if(used)
		to_chat(user, span_warning("[src] is used up."))
		return FALSE
	if(!istype(target, /obj/machinery/computer/communications))
		to_chat(user, span_warning("[src] is unable to interface with this. It only seems to interface with the communication console."))
		return FALSE
	return TRUE
