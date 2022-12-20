// Status effect given to you if you're choking on something
/datum/status_effect/choke
	id = "choke"
	tick_interval = 0.2 SECONDS
	alert_type = null
	remove_on_fullheal = TRUE
	/// Weakref to the thing we're choking on
	var/datum/weakref/choking_on_ref
	/// If the thing we're choking on is on fire
	var/flaming

	/// The particle holder we're using to run our ash effects
	var/obj/effect/abstract/particle_holder/ash
	/// Our choking audio loop
	var/datum/looping_sound/choke_loop
	/// The delta client.pixel_y we've got
	var/delta_y = 0
	/// The delta client.pixel_x we've got
	var/delta_x = 0

/datum/status_effect/choke/on_creation(mob/living/new_owner, atom/movable/choke_on, flaming = FALSE, vomit_delay = -1)
	choking_on_ref = WEAKREF(choke_on)
	src.flaming = flaming
	src.duration = vomit_delay
	return ..()

/datum/status_effect/choke/on_apply()
	if(!iscarbon(owner)) // Ghosts do not have stomachs, and non carbons can't vomit
		return FALSE
	var/atom/movable/choking_on = choking_on_ref?.resolve()
	if(!choking_on)
		return FALSE
	// If we've got an item, remove it from storage
	if(isitem(choking_on))
		var/obj/item/chokin_item = choking_on
		if(chokin_item.item_flags & IN_INVENTORY)
			var/mob/inventory_in = chokin_item.loc
			inventory_in.transferItemToLoc(chokin_item, owner, force = TRUE, silent = TRUE)
		else if(!(chokin_item.item_flags & IN_STORAGE) || !chokin_item.remove_item_from_storage(owner))
			choking_on.forceMove(owner) // backup
	else
		choking_on.forceMove(owner)
	RegisterSignal(owner, SIGNAL_ADDTRAIT(TRAIT_NOBREATH), PROC_REF(no_breathing))
	RegisterSignal(owner, COMSIG_MOB_LOGOUT, PROC_REF(on_logout))
	RegisterSignal(owner, COMSIG_LIVING_DEATH, PROC_REF(on_death))
	// Of note, this means plasma lovers lose some methods of vomiting up
	RegisterSignal(owner, COMSIG_CARBON_VOMITED, PROC_REF(on_vomit))
	RegisterSignal(owner, COMSIG_CARBON_ATTEMPT_EAT, PROC_REF(attempt_eat))
	RegisterSignal(owner, COMSIG_CARBON_PRE_HELP, PROC_REF(helped))
	RegisterSignal(owner, COMSIG_CARBON_PRE_MISC_HELP, PROC_REF(shook))

	RegisterSignal(choking_on, COMSIG_PARENT_QDELETING, PROC_REF(remove_choke))
	RegisterSignal(choking_on, COMSIG_MOVABLE_MOVED, PROC_REF(hazard_moved))
	ADD_TRAIT(owner, TRAIT_MUTE, CHOKING_TRAIT)

	owner.add_mood_event(id, /datum/mood_event/choke)
	//stop on death
	choke_loop = new /datum/looping_sound/choking(owner)
	check_audio_state()

	owner.visible_message(span_bolddanger("[owner] tries to speak, but can't! They're choking!"), \
		span_userdanger("You try to breath, but there's a block! You're choking!"), \
		)

	//barticles
	if(flaming)
		ash = new(owner, /particles/smoke/ash)
		var/clear_in = rand(15 SECONDS, 25 SECONDS)
		if(duration != -1)
			clear_in = min(duration, clear_in)
		addtimer(CALLBACK(src, PROC_REF(clear_flame)), clear_in)
	return TRUE

/datum/status_effect/choke/proc/should_do_effects()
	return owner.stat != DEAD && !HAS_TRAIT(owner, TRAIT_NOBREATH)

/datum/status_effect/choke/proc/check_audio_state()
	if(!should_do_effects())
		choke_loop.stop()
		return
	choke_loop.start()

/datum/status_effect/choke/on_remove()
	owner.clear_mood_event(id)
	REMOVE_TRAIT(owner, TRAIT_MUTE, CHOKING_TRAIT)
	clean_client()
	clear_flame()
	if(choke_loop)
		QDEL_NULL(choke_loop)
	vomit_up()
	return ..()

/datum/status_effect/choke/proc/clean_client()
	// juuust in case, reset our x and y's
	var/client/client_owner = owner.canon_client
	if(client_owner)
		// Ok listen I want to use non relative animates here but BYOND WILL NOT LET ME
		// REEEEEEEEE
		animate(client_owner, pixel_x = client_owner.pixel_x - delta_x, pixel_y = client_owner.pixel_y - delta_y, 0.05 SECONDS, ANIMATION_PARALLEL)
	delta_x = 0
	delta_y = 0

/datum/status_effect/choke/proc/clear_flame()
	flaming = FALSE
	if(ash)
		QDEL_NULL(ash)

/datum/status_effect/choke/proc/vomit_up()
	var/atom/movable/choking_on = choking_on_ref?.resolve()
	if(choking_on && iscarbon(owner))
		var/mob/living/carbon/carbon_owner = owner
		// This will yeet the thing we're choking on out of us
		carbon_owner.vomit(lost_nutrition = 20, force = TRUE, distance = 2)

/datum/status_effect/choke/proc/on_vomit(mob/source, distance, force)
	SIGNAL_HANDLER
	var/atom/movable/choking_on = choking_on_ref?.resolve()
	if(choking_on)
		choking_on_ref = null
		choking_on.forceMove(get_turf(source)) // Gotta be on a tile to throw yourself bestie
		var/atom/target = get_edge_target_turf(source, source.dir)
		choking_on.throw_at(target, distance, 1, source)

/datum/status_effect/choke/get_examine_text()
	return span_boldwarning("[owner.p_they(TRUE)] [owner.p_are()] choking!")

/datum/status_effect/choke/proc/remove_choke(datum/source)
	SIGNAL_HANDLER
	if(!QDELETED(src))
		qdel(src)

/datum/status_effect/choke/proc/hazard_moved(atom/movable/source)
	SIGNAL_HANDLER
	if(QDELETED(src))
		return
	if(source.loc != owner)
		qdel(src)

/datum/status_effect/choke/proc/no_breathing(mob/living/source)
	SIGNAL_HANDLER
	RegisterSignal(source, SIGNAL_REMOVETRAIT(TRAIT_NOBREATH), PROC_REF(on_breathable))
	check_audio_state()

/datum/status_effect/choke/proc/on_breathable(mob/living/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, SIGNAL_REMOVETRAIT(TRAIT_NOBREATH))
	check_audio_state()

/datum/status_effect/choke/proc/on_logout(datum/source)
	SIGNAL_HANDLER
	clean_client()

/datum/status_effect/choke/proc/on_death(mob/living/source)
	SIGNAL_HANDLER
	RegisterSignal(source, COMSIG_LIVING_REVIVE, PROC_REF(on_revive))
	check_audio_state()

/datum/status_effect/choke/proc/on_revive(mob/living/source)
	SIGNAL_HANDLER
	UnregisterSignal(source, COMSIG_LIVING_REVIVE)
	check_audio_state()

/datum/status_effect/choke/proc/attempt_eat(mob/source, atom/eating)
	SIGNAL_HANDLER
	source.balloon_alert(source, "can't get it down!")
	return COMSIG_CARBON_BLOCK_EAT

/datum/status_effect/choke/proc/helped(mob/source, mob/helping)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(heimlich), source, helping)
	return COMPONENT_BLOCK_HELP_ACT

/datum/status_effect/choke/proc/shook(mob/source, mob/helping)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(heimlich), source, helping)
	return COMPONENT_BLOCK_MISC_HELP

/datum/status_effect/choke/proc/heimlich(mob/victim, mob/aggressor)
	if(victim == aggressor)
		return
	if(DOING_INTERACTION_WITH_TARGET(aggressor, victim))
		victim.balloon_alert(aggressor, "already helping!")
		return
	if(DOING_INTERACTION(aggressor, "heimlich"))
		victim.balloon_alert(aggressor, "already helping someone!")
		return

	if(!thrusting_continues(victim, aggressor, before_work = TRUE))
		return
	aggressor.start_pulling(victim)
	// I want the thing to look vaugely like the heimlich. Sue me
	victim.setDir(aggressor.dir)

	var/hand_name = "hand"
	if(!iscarbon(aggressor))
		hand_name = "paw" // Fuck you

	var/mob/living/livin_victim = victim
	if(iscarbon(aggressor) && livin_victim.body_position == STANDING_UP)
		owner.visible_message(span_warning("[aggressor] wraps [aggressor.p_their()] arms around [victim]'s stomach, and begins thrusting [aggressor.p_their()] fists towards themselves!"), \
			span_boldwarning("[aggressor] wraps [aggressor.p_their()] arms around you, and begins thrusting their hands into your chest. [capitalize(GLOB.deity)] that hurts!"), \
			)
	else
		owner.visible_message(span_warning("[aggressor] places [aggressor.p_their()] [hand_name]s on [victim]'s back, and begins forcefully striking it!"), \
			span_boldwarning("You feel [aggressor]\s [hand_name]s on your back, and then repeated striking!"))

	if(!do_after_mob(aggressor, victim, 7 SECONDS, extra_checks = CALLBACK(src, PROC_REF(thrusting_continues), victim, aggressor), interaction_key = "heimlich"))
		aggressor.stop_pulling()
		return
	aggressor.stop_pulling()

	var/atom/movable/choking_on = choking_on_ref?.resolve()
	owner.visible_message(span_green("[victim] vomits up \the[choking_on]. [victim.p_theyre()] gonna make it!"), \
			span_green("You vomit up that accursed blockage. YOU CAN BREATHE! The broken chest is a hell of a price to pay."))
	if(iscarbon(victim))
		var/mob/living/carbon/carbon_victim = victim
		var/obj/item/bodypart/chest = carbon_victim.get_bodypart(BODY_ZONE_CHEST)
		if(chest)
			chest.force_wound_upwards(/datum/wound/blunt/severe)
	playsound(owner, 'sound/creatures/crack_vomit.ogg', 120, extrarange = 5, falloff_exponent = 4)
	vomit_up()

/datum/status_effect/choke/proc/mirror_dir(atom/source, old_dir, new_dir)
	SIGNAL_HANDLER
	owner.dir = new_dir

/datum/status_effect/choke/proc/thrusting_continues(mob/living/victim, mob/aggressor, before_work = FALSE)
	if(iscarbon(aggressor))
		var/free_hands = 0
		// Listen bud, you need at least 2 free hands for this
		for(var/hand_i in 1 to length(aggressor.held_items))
			if(!aggressor.has_hand_for_held_index(hand_i) || aggressor.held_items[hand_i])
				continue
			free_hands += 1
		if(free_hands < 2)
			victim.balloon_alert(aggressor, "need 2 free hands!")
			return FALSE

	if(iscarbon(victim))
		var/mob/living/carbon/carbon_victim = victim
		if(!carbon_victim.appears_alive())
			victim.balloon_alert(aggressor, "too late...")
			return FALSE

	if(!choking_on_ref)
		return FALSE

	if(!before_work)
		// This check isn't valid at first because it looks dumb if other things fail
		if(victim.pulledby != aggressor)
			victim.balloon_alert(aggressor, "must be able to move them!")
			return FALSE

		// Similarly, but also this is a burden of knowhow that's cringe
		if(aggressor.dir != get_dir(aggressor, victim))
			victim.balloon_alert(aggressor, "must be facing them!")
			return FALSE

		// See above
		if(victim.dir != aggressor.dir)
			victim.balloon_alert(aggressor, "must be facing the same way!")
			return FALSE

	// If we ain't starting, deal a tad bit of brute, as a treat
	// Note, we attempt to process 10 times a second, so over 7 seconds this'll deal 14 brute
	if(!before_work)
		victim.adjustBruteLoss(0.2)
	return TRUE

/datum/status_effect/choke/tick(delta_time)
	if(!should_do_effects())
		return

	deal_damage(delta_time)

	var/client/client_owner = owner.client
	if(client_owner)
		do_vfx(client_owner)

/datum/status_effect/choke/proc/deal_damage(delta_time)
	owner.losebreath += 1 * delta_time // 1 breath loss a second. This will deal additional breath damage, and prevent breathing
	if(flaming)
		var/obj/item/bodypart/head = owner.get_bodypart(BODY_ZONE_HEAD)
		if(head)
			head.receive_damage(0, 2 * delta_time)
		owner.adjustStaminaLoss(2 * delta_time)

/datum/status_effect/choke/proc/do_vfx(client/vfx_on)
	var/old_x = delta_x
	delta_x = WRAP(delta_x + rand(1, 6), -13, 13)
	var/old_y = delta_y
	delta_y = WRAP(delta_y + rand(1, 6), -13, 13)
	// We run on fast process, which procs us once every 0.2 seconds. We want to move every 0.05, so we do 4 animates
	// In other news, ANIMATION_RELATIVE does not work on client.pixel_x/y. Thanks byond
	animate(vfx_on, pixel_x = vfx_on.pixel_x + (delta_x - old_x), pixel_y = vfx_on.pixel_y + (delta_y - old_y), time = 0.05 SECONDS, flags = ANIMATION_PARALLEL)
	for(var/i in 1 to 3)
		old_x = delta_x
		delta_x = WRAP(delta_x + rand(1, 6), -13, 13)
		old_y = delta_y
		delta_y = WRAP(delta_y + rand(1, 6), -13, 13)
		animate(pixel_x = vfx_on.pixel_x + (delta_x - old_x), pixel_y = vfx_on.pixel_y + (delta_y - old_y), time = 0.05 SECONDS)
