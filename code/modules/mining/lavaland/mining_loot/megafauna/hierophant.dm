// Hierophant club

/obj/item/hierophant_club
	name = "hierophant club"
	desc = "The strange technology of this large club allows various nigh-magical teleportation feats. It used to beat you, but now you can set the beat."
	icon_state = "hierophant_club_ready_beacon"
	inhand_icon_state = "hierophant_club_ready_beacon"
	icon_angle = -135
	icon = 'icons/obj/mining_zones/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_NORMAL
	force = 15
	attack_verb_continuous = list("clubs", "beats", "pummels")
	attack_verb_simple = list("club", "beat", "pummel")
	hitsound = 'sound/items/weapons/sonic_jackhammer.ogg'
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	actions_types = list(/datum/action/item_action/vortex_recall)
	action_slots = ALL
	/// Linked teleport beacon for the group teleport functionality.
	var/obj/effect/hierophant/beacon
	/// TRUE if currently doing a teleport to the beacon, FALSE otherwise.
	var/teleporting = FALSE
	/// Action enabling the blink-dash functionality.
	var/datum/action/innate/dash/hierophant/blink
	/// Whether the blink ability is activated. IF TRUE, left clicking a location will blink to it. If FALSE, this is disabled.
	var/blink_activated = TRUE

/obj/item/hierophant_club/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	blink = new(src)

/obj/item/hierophant_club/Destroy(force)
	QDEL_NULL(blink)
	return ..()

/obj/item/hierophant_club/examine(mob/user)
	. = ..()
	if (beacon)
		. += span_hierophant_warning("The beacon is currently detached.")
	else
		. += span_hierophant_warning("There is a beacon attached at the back end of the handle.")

/obj/item/hierophant_club/equipped(mob/user)
	. = ..()
	blink.Grant(user, src)
	user.update_icons()

/obj/item/hierophant_club/dropped(mob/user)
	. = ..()
	blink.Remove(user)
	user.update_icons()

/obj/item/hierophant_club/suicide_act(mob/living/user)
	say("Xverwpsgexmrk...", forced = "hierophant club suicide")
	user.visible_message(span_suicide("[user] holds [src] into the air! It looks like [user.p_theyre()] trying to commit suicide!"))
	new/obj/effect/temp_visual/hierophant/telegraph(get_turf(user))
	playsound(user,'sound/machines/airlock/airlockopen.ogg', 75, TRUE)
	user.visible_message(span_hierophant_warning("[user] fades out, leaving [user.p_their()] belongings behind!"))
	for (var/obj/item/user_item as anything in user.get_all_gear(FALSE, FALSE))
		user.dropItemToGround(user_item)
	for (var/turf/blast_turf as anything in RANGE_TURFS(1, user))
		new /obj/effect/temp_visual/hierophant/blast/visual(blast_turf, user, TRUE)
	user.dropItemToGround(src) //Drop us last, so it goes on top of their stuff
	qdel(user)

/obj/item/hierophant_club/attack_self(mob/user)
	. = ..()
	blink_activated = !blink_activated
	balloon_alert(user, "blinking [blink_activated ? "enabled" : "disabled"]")

/obj/item/hierophant_club/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	// If our target is the beacon and the hierostaff is next to the beacon, we're trying to pick it up.
	if (interacting_with == beacon)
		return NONE

	if (!blink_activated)
		return NONE

	if (blink.teleport(user, interacting_with))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/item/hierophant_club/ranged_interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if (blink_activated)
		blink.teleport(user, interacting_with)
		return ITEM_INTERACT_SUCCESS
	return NONE

/obj/item/hierophant_club/update_icon_state()
	icon_state = inhand_icon_state = "hierophant_club[blink?.current_charges > 0 ? "_ready" : ""][!QDELETED(beacon) ? "" : "_beacon"]"
	return ..()

/obj/item/hierophant_club/ui_action_click(mob/user, action)
	if (teleporting)
		balloon_alert(user, "already in use!")
		return

	if (!user.is_holding(src))
		to_chat(user, span_warning("You need to hold the club in your hands to [beacon ? "teleport with it" : "detach the beacon"]!"))
		return

	if (!beacon)
		deploy_beacon(user)
		return

	if (get_dist(user, beacon) <= 2)
		balloon_alert(user, "too close to the beacon!")
		return

	var/turf/beacon_turf = get_turf(beacon)
	if (!beacon_turf || beacon_turf.is_blocked_turf(TRUE))
		balloon_alert(user, "the beacon is blocked!")
		return

	if (!isturf(user.loc))
		balloon_alert(user, "not enough room to teleport!")
		return

	var/turf/user_turf = get_turf(user)
	teleporting = TRUE
	user.update_mob_action_buttons()
	user.visible_message(span_hierophant_warning("[user] starts to glow faintly..."), span_hierophant_warning("You begin channeling [src]'s power..."))
	beacon.icon_state = "hierophant_tele_on"
	var/obj/effect/temp_visual/hierophant/telegraph/edge/user_telegraph = new /obj/effect/temp_visual/hierophant/telegraph/edge(user_turf)
	var/obj/effect/temp_visual/hierophant/telegraph/edge/beacon_telegraph = new /obj/effect/temp_visual/hierophant/telegraph/edge(beacon_turf)
	if (!do_after(user, 4 SECONDS, user))
		if (user)
			balloon_alert(user, "interrupted!")
		stop_teleport(user)
		qdel(user_telegraph)
		qdel(beacon_telegraph)
		return

	if (!beacon)
		balloon_alert(user, "interrupted!")
		stop_teleport(user)
		return

	if (beacon_turf.is_blocked_turf(TRUE))
		balloon_alert(user, "the beacon is blocked!")
		stop_teleport(user)
		return

	new /obj/effect/temp_visual/hierophant/telegraph(user_turf, user)
	new /obj/effect/temp_visual/hierophant/telegraph(beacon_turf, user)
	playsound(user_turf, 'sound/machines/airlock/airlockopen.ogg', 200, TRUE)
	playsound(beacon_turf, 'sound/effects/magic/wand_teleport.ogg', 200, TRUE)

	new /obj/effect/temp_visual/hierophant/telegraph/teleport(user_turf, user)
	new /obj/effect/temp_visual/hierophant/telegraph/teleport(beacon_turf, user)

	for(var/turf/turf_near_user_turf as anything in RANGE_TURFS(1, user_turf))
		new /obj/effect/temp_visual/hierophant/blast/visual(turf_near_user_turf, user, TRUE)

	for(var/turf/turf_near_beacon as anything in RANGE_TURFS(1, beacon_turf))
		new /obj/effect/temp_visual/hierophant/blast/visual(turf_near_beacon, user, TRUE)

	for(var/mob/living/victim in range(1, user_turf))
		INVOKE_ASYNC(src, PROC_REF(teleport_mob), user_turf, beacon_turf, victim, user)

	addtimer(CALLBACK(src, PROC_REF(stop_teleport), user), 0.6 SECONDS)

/// Just to cut down on copypasta
/obj/item/hierophant_club/proc/stop_teleport(mob/user)
	teleporting = FALSE
	if (beacon)
		beacon.icon_state = "hierophant_tele_off"
	if (user)
		user.update_mob_action_buttons()

/// Teleports mobs after a short animation
/obj/item/hierophant_club/proc/teleport_mob(turf/user_turf, turf/beacon_turf, mob/victim, mob/user)
	var/turf/target_turf = get_step(beacon_turf, get_dir(user_turf, victim))
	if (!target_turf || target_turf.is_blocked_turf(TRUE))
		return
	animate(victim, alpha = 0, time = 0.2 SECONDS, easing = SINE_EASING|EASE_OUT)
	sleep(0.2 SECONDS)
	victim.visible_message(span_hierophant_warning("[victim] fades out!"))
	var/success = do_teleport(victim, target_turf, no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC)
	animate(victim, alpha = 255, time = 0.2 SECONDS, SINE_EASING|EASE_OUT)
	victim.visible_message(span_hierophant_warning("[victim] fades in!"))
	if (user != victim && success)
		log_combat(user, victim, "teleported", null, "from [AREACOORD(user_turf)]")

/// Attempts to place a return beacon at user's feet
/obj/item/hierophant_club/proc/deploy_beacon(mob/user)
	if (!isopenturf(user.loc) && !isopenspaceturf(user.loc))
		to_chat(user, span_warning("You need to be on solid ground to detach the beacon!"))
		return

	user.visible_message(span_hierophant_warning("[user] starts fiddling with [src]'s pommel..."), span_notice("You start detaching the hierophant beacon..."))
	balloon_alert(user, "detaching the beacon...")
	if (!do_after(user, 5 SECONDS, user))
		balloon_alert(user, "interrupted!")
		return

	// Already dropped one
	if (beacon)
		return

	var/turf/user_turf = get_turf(user)
	new /obj/effect/temp_visual/hierophant/telegraph/teleport(user_turf, user)
	beacon = new /obj/effect/hierophant(user_turf)
	playsound(beacon, 'sound/effects/magic/blind.ogg', 200, TRUE, -4)
	RegisterSignal(beacon, COMSIG_QDELETING, PROC_REF(beacon_destroyed))

	user.update_mob_action_buttons()
	user.visible_message(span_hierophant_warning("[user] places a strange machine beneath [user.p_their()] feet!"), span_hierophant("You detach the hierophant beacon, allowing you to teleport yourself and any allies to it at any time!"))
	to_chat(user, span_hierophant("You can remove the beacon to place it again by striking it with the club."))
	update_appearance(UPDATE_ICON_STATE)

/obj/item/hierophant_club/proc/beacon_destroyed(datum/source)
	SIGNAL_HANDLER
	beacon = null
	if (ismob(loc))
		to_chat(loc, span_hierophant("With a loud snap, a new beacon appears at [src]'s pommel."))
	else
		visible_message(span_hierophant("With a loud snap, a new beacon appears at [src]'s pommel."))
	playsound(src, 'sound/effects/magic/blind.ogg', 50, TRUE, -4)
	update_appearance(UPDATE_ICON_STATE)

#define HIEROPHANT_BLINK_RANGE 5
#define HIEROPHANT_BLINK_COOLDOWN (15 SECONDS)

/datum/action/innate/dash/hierophant
	current_charges = 1
	max_charges = 1
	charge_rate = HIEROPHANT_BLINK_COOLDOWN
	recharge_sound = null
	phasein = /obj/effect/temp_visual/hierophant/blast/visual
	phaseout = /obj/effect/temp_visual/hierophant/blast/visual
	// It's a simple purple beam, works well enough for the purple hiero effects.
	beam_effect = "plasmabeam"

/datum/action/innate/dash/hierophant/teleport(mob/user, atom/target)
	var/dist = get_dist(user, target)
	if(dist > HIEROPHANT_BLINK_RANGE)
		user.balloon_alert(user, "destination out of range!")
		return FALSE

	var/turf/target_turf = get_turf(target)
	if(target_turf.is_blocked_turf_ignore_climbable())
		user.balloon_alert(user, "destination blocked!")
		return FALSE

	. = ..()

	var/obj/item/hierophant_club/club = target
	if(!istype(club))
		club.update_appearance(UPDATE_ICON_STATE)

/datum/action/innate/dash/hierophant/charge()
	. = ..()
	var/obj/item/hierophant_club/club = target
	if(istype(club))
		club.update_appearance(UPDATE_ICON_STATE)

#undef HIEROPHANT_BLINK_RANGE
#undef HIEROPHANT_BLINK_COOLDOWN
