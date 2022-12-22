/obj/item/toy/basketball
	name = "basketball"
	icon = 'icons/obj/weapons/items_and_weapons.dmi'
	icon_state = "basketball"
	inhand_icon_state = "basketball"
	desc = "Here's your chance, do your dance at the Space Jam."
	w_class = WEIGHT_CLASS_BULKY //Stops people from hiding it in their bags/pockets
	/// The person dribbling the basketball
	var/mob/living/wielder

// what about wielder.combat_mode  ???

/obj/item/toy/basketball/Initialize(mapload)
	. = ..()

	RegisterSignal(src, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(src, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))

// basketball/qdel don't forget to remove these signals
//	UnregisterSignal(source, list(COMSIG_PARENT_EXAMINE, COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED))

/obj/item/toy/basketball/proc/on_equip(obj/item/source, mob/living/user, slot)
	SIGNAL_HANDLER

	/*
	if(!(source.slot_flags & slot))
		return
	*/

	wielder = user
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(movement_stamina_drain))
	RegisterSignal(user, COMSIG_MOB_EMOTE, PROC_REF(emote_stamina_drain))
	// use this to check shoving?
	//RegisterSignal(parent, COMSIG_MOB_ATTACK_HAND, PROC_REF(check_shove))

/obj/item/toy/basketball/proc/on_drop(obj/item/source, mob/user)
	SIGNAL_HANDLER

	wielder = null
	UnregisterSignal(user, list(COMSIG_MOVABLE_MOVED, COMSIG_MOB_EMOTE))


/obj/item/toy/basketball/proc/movement_stamina_drain(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	wielder.apply_damage(1, STAMINA)
	playsound(src, 'sound/items/dodgeball.ogg', 50, TRUE)

/obj/item/toy/basketball/proc/emote_stamina_drain(mob/living/user, datum/emote/emote)
	SIGNAL_HANDLER

	if(!istype(emote, /datum/emote/spin))
		return

	wielder.apply_damage(10, STAMINA)

/obj/item/toy/basketball/attack(mob/living/carbon/target, mob/living/user, params)
	. = ..()
	if(!iscarbon(target))
		return

	user.balloon_alert_to_viewers("passes the ball")
	playsound(src, 'sound/items/dodgeball.ogg', 50, TRUE)
	target_mob.put_in_hands(src)

// if(HAS_TRAIT(src, TRAIT_WIELDED))
// M.apply_damage(10, STAMINA)
/*
/obj/item/toy/cards/deck/attack_hand_secondary(mob/living/user, list/modifiers)
	attack_hand(user, modifiers, flip_card = TRUE)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
*/

/obj/structure/hoop
	name = "basketball hoop"
	desc = "Boom, shakalaka!"
	icon = 'icons/obj/basketball.dmi'
	icon_state = "hoop"
	anchored = TRUE
	density = TRUE
	var/total_score = 0

/obj/structure/hoop/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/structure/hoop/proc/score(points)
	playsound(src, 'sound/machines/scanbuzz.ogg', 100, FALSE)
	total_score += points
	update_appearance()

/obj/structure/hoop/update_overlays()
	. = ..()

	var/dir_offset_x = 0
	var/dir_offset_y = 0

	switch(dir)
		if(NORTH)
			dir_offset_y = -32
		if(SOUTH)
			dir_offset_y = 32
		if(EAST)
			dir_offset_x = 32
		if(WEST)
			dir_offset_x = -32

	var/mutable_appearance/scoreboard = mutable_appearance('icons/obj/signs.dmi', "tram_hits")
	scoreboard.pixel_x = dir_offset_x
	scoreboard.pixel_y = dir_offset_y
	. += scoreboard

	var/tens = (total_score / 10) % 10
	var/mutable_appearance/tens_overlay = mutable_appearance('icons/obj/signs.dmi', "days_[tens]")
	tens_overlay.pixel_x = dir_offset_x - 5
	tens_overlay.pixel_y = dir_offset_y
	. += tens_overlay

	var/ones = total_score % 10
	var/mutable_appearance/ones_overlay = mutable_appearance('icons/obj/signs.dmi', "hits_[ones]")
	ones_overlay.pixel_x = dir_offset_x + 4
	ones_overlay.pixel_y = dir_offset_y
	. += ones_overlay

/obj/structure/hoop/attackby(obj/item/ball, mob/living/baller, params)
	if(get_dist(src, baller) < 2) // TK users aren't allowed to dunk (not sure if this code even works tbh)
		if(baller.transferItemToLoc(ball, drop_location()))
			visible_message(span_warning("[baller] dunks [ball] into \the [src]!"))
			score(2)

/obj/structure/hoop/attack_hand(mob/living/baller, list/modifiers)
	. = ..()
	if(.)
		return
	if(baller.pulling && isliving(baller.pulling))
		var/mob/living/loser = baller.pulling
		if(baller.grab_state < GRAB_AGGRESSIVE)
			to_chat(baller, span_warning("You need a better grip to do that!"))
			return
		loser.forceMove(loc)
		loser.Paralyze(100)
		visible_message(span_danger("[baller] dunks [loser] into \the [src]!"))
		score(2)
		baller.stop_pulling()
	else
		..()

/obj/structure/hoop/AltClick(mob/living/user)
	if(user.canUseTopic(src, be_close = TRUE, no_dexterity = TRUE, no_tk = TRUE, need_hands = !iscyborg(user)))
		user.balloon_alert_to_viewers("resetting score...")
		playsound(src, 'sound/machines/locktoggle.ogg', 50, TRUE)
		if(do_after(user, 5 SECONDS, target = src))
			total_score = 0
			update_appearance()
	return ..()

/*
/obj/item/restraints/legcuffs/bola/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, gentle = FALSE, quickstart = TRUE)
	if(!..())
		return
	playsound(src.loc,'sound/weapons/bolathrow.ogg', 75, TRUE)
*/

/obj/structure/hoop/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isitem(AM) && !istype(AM, /obj/projectile))
		//throwingdatum.dist_travelled

		if(prob(50))
			AM.forceMove(get_turf(src))
			visible_message(span_warning("Swish! [AM] lands in [src]."))
			score(2)
			return
		else
			visible_message(span_danger("[AM] bounces off of [src]'s rim!"))
			return ..()
	else
		return ..()
