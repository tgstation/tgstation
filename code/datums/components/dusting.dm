/datum/component/dusting
	/// Consume all objects that bump into the atom. Only applies to dense atoms.
	var/consume_on_bumped = TRUE
	/// Consume when attacking with the sword
	var/consume_on_attack = TRUE
	/// Consume when attacked by a mob with attack_hand
	var/consume_on_attack_hand = TRUE
	/// Consume when attacked by a mob using an item
	var/consume_on_attackby = TRUE
	/// Consume when trying to get picked up by a mob
	var/consume_on_pickup = FALSE
	/// Consume when we are thrown onto something
	var/consume_on_throw = TRUE
	/// If we consume the contents of atoms we consume as well. This ignores turfs regardless if consume_turfs is TRUE
	var/consume_all_contents = FALSE
	/// If we consume turfs
	var/consume_turfs = FALSE
	/// Special case to passively consume turfs. Can be paired with callbacks to change when to consume the turf
	var/passively_consumes_turf = FALSE

	/// The sound to play when consuming something
	var/consumption_sound = 'sound/effects/supermatter.ogg'

	/// If we pulse radiation after consuming something
	var/consume_does_radiation = TRUE
	/// Default radiation range after consuming something
	var/radiation_range = 3
	/// Default radiation threshold after consuming something
	var/radiation_threshold = 0.1
	/// Default radiation chance after consuming something
	var/radiation_chance = 50
	
	/// If a target has this flag, don't consume it
	var/ignore_flags = SUPERMATTER_IGNORES_1
	/// If a mob has this flag, don't consume it, along with ignore_flags
	var/ignore_status_flags = GODMODE
	/// Ignore subtypes of this type to consume. Becomes typecache list
	var/list/ignore_subtypesof = list(/obj/effect, /turf/open/space)

	//Text stuff

	/// Text to show to what gets consumed by us
	var/consumed_text = span_userdanger("An unearthly ringing fills your ears, pain fills you to the core until everything turns white...")
	/// Range to send consumption texts
	var/watch_consume_text_range = 10
	/// Text to show to non-blind people when something had been consumed.
	var/watch_consume_text_visual = span_danger("You can feel hot waves of radiation wash over you.")
	/// Audible text to show to people when something had been consumed.
	var/watch_consume_text_audible = span_danger("Your ear is filled with an unearthly ringing as your skin bubbles and reddens with new radiation burns.")
	/// Audible text to show to people when they can't see what's being consumed, but are still in range to recieve consumption messages.
	var/watch_consume_text_unseen = span_hear("An unearthly ringing fills your ears.")

	//Large mass of text below to help understand/document code :)

	/* Called when we had just consumed an atom and displayed a message
	 * `(datum/component/dusting/comp_source, atom/consumed)`
	 * 
	 * Arguments:
	 * * comp_source - The dusting component
	 * * consumed - The atom that just got consumed
	 */
	var/datum/callback/callback_after_consume

	/* Called just before pulsing radiation and sharing messages to nearby mobs.
	 * `(datum/component/dusting/comp_source, list/flavortext)`
	 * 
	 * Arguments:
	 * * comp_source - The dusting component
	 * * flavortext - A list that holds all the variables to handle visual messages and how radiation is handled. See [proc/get_special_text] for more info
	 */
	var/datum/callback/callback_get_flavortext

	/* If defined, this is called every SSobj process. Return value should be a normal process call return
	 * `(datum/component/dusting/comp_source)`
	 * 
	 * If the callback returns PROCESS_KILL, it will end the SSobj process.
	 *
	 * Arguments:
	 * * comp_source - The dusting component
	 */
	var/datum/callback/callback_process

	/* If defined, the callback will be Invoke()'d when the parent has started the attack chain (pre-attacking)
	 * `(datum/component/dusting/comp_source, atom/attacking_atom, mob/living/user, params)`
	 * 
	 * This callback should not sleep or wait in any way
	 * 
	 * Return from callback should be used to modify the attack chain. Use COMPONENT_CANCEL_ATTACK_CHAIN to stop the item from attacking
	 * A non-null return from the callback will stop consuming the item
	 * 
	 * Arguments:
	 * * comp_source - The dusting component
	 * * attacking_atom - The atom getting attacked 
	 * * user - The mob who is attacking with attacking_atom
	 * * params - Null if non-mob was attacked. If a client called this, contains things like if it's a right-click or holding shift, ctrl, or alt.
	 */
	var/datum/callback/callback_attack

	/* If defined, the callback will be Invoke()'d when the parent has been attacked with an empty hand. Can also be some simple animals.
	 * `(datum/component/dusting/comp_source, mob/user, list/modifiers)`
	 * 
	 * This callback should not sleep or wait in any way
	 * 
	 * A non-null return from the callback will stop consuming whoever tries to pick up the parent
	 * 
	 * Arguments:
	 * * comp_source - The dusting component
	 * * user - The mob who's attacking with an empty hand
	 * * modifiers - If a client called this, contains things like if it's a right-click or holding shift, ctrl, or alt.
	 */
	var/datum/callback/callback_attack_hand

	/* If defined, the callback will be Invoke()'d when the parent has recieved the attackby signal.
	 * `(datum/component/dusting/comp_source, obj/item/attacking_item, mob/user, params)`
	 * 
	 * This callback should not sleep or wait in any way
	 * 
	 * Return from callback should be used to modify the attack chain. Use COMPONENT_CANCEL_ATTACK_CHAIN to stop the item from attacking
	 * A non-null return from the callback will stop consuming the item
	 *
	 * Arguments:
	 * * comp_source - The dusting component
	 * * attacking_item - The item that's trying to hit the component's parent
	 * * user - The mob that's trying to attack with an item
	 * * params - If a client called this, contains things like if it's a right-click or holding shift, ctrl, or alt
	 */
	var/datum/callback/callback_attackby

	/* If defined, the callback will be Invoke()'d when the parent is picked up. This is after the parent is used with attack_hand.
	 * `(datum/component/dusting/comp_source, mob/user)`
	 * 
	 * This callback should not sleep or wait in any way
	 * 
	 * A non-null return from the callback will stop consuming whoever is trying to pick up the parent
	 * 
	 * Arguments:
	 * * comp_source - The dusting component
	 * * user - The mob that's trying to pick up the parent
	 */
	var/datum/callback/callback_on_pickup

	/* If defined, the callback will be Invoke()'d when an atom Bumps into the parent.
	 * `(datum/component/dusting/comp_source, atom/bumped_atom)`
	 * 
	 * This callback should not sleep or wait in any way
	 * 
	 * A non-null return from the callback will stop consuming whatever is moving into the parent
	 * 
	 * Arguments:
	 * * comp_source - The dusting component
	 * * bumped_atom - The atom bumping into the parent
	 */
	var/datum/callback/callback_on_bumped

	/* If defined, the callback will be Invoke()'d after the parent has been thrown onto something.
	 * `(datum/component/dusting/comp_source, atom/hit_atom, datum/thrownthing/throwingdatum)`
	 * 
	 * This callback should not sleep or wait in any way
	 * 
	 * Return from callback should be used to modify the attack chain.
	 * A non-null return from the callback will stop consuming the atom that gets hit.
	 * 
	 * Arguments:
	 * * comp_source - The dusting component
	 * * hit_atom - The atom that gets hit by the parent after being thrown. This is also whatever what was clicked on if it never met a dense object while being thrown
	 * * throwingdatum - The datum that handles throwing
	 */
	var/datum/callback/callback_throw_impact

	/* If defined, the callback will be Invoke()'d after the parent is getting consumed by a blob structure.
	 * `(datum/component/dusting/comp_source, obj/structure/blob/attacking_blob)`
	 * 
	 * This callback should not sleep or wait in any way
	 * 
	 * Return from callback should be used to modify if the blob structure gets to attack. Use COMPONENT_CANCEL_BLOB_ACT
	 * A non-null return from the callback will stop consuming the blob structure.
	 * 
	 * Arguments:
	 * * comp_source - The dusting component
	 * * attacking_blob - The blob structure trying to attack the parent
	 */
	var/datum/callback/callback_hitby_blob

//The behemoth.
//Sorted by what would seem most useful to add first for admins adding this component to something
/datum/component/dusting/Initialize(
	consume_does_radiation = TRUE,
	radiation_range = 3,
	radiation_threshold = 0.1,
	radiation_chance = 50,
	consume_on_attack = TRUE,
	consume_on_throw = TRUE,
	consume_on_pickup = FALSE,
	consume_on_attack_hand = TRUE,
	consume_on_bumped = TRUE,
	consume_on_attackby = TRUE,
	consume_all_contents = FALSE,
	consume_turfs = FALSE,
	passively_consumes_turf = FALSE,
	consumption_sound = 'sound/effects/supermatter.ogg',
	consumed_text = span_userdanger("An unearthly ringing fills your ears, pain fills you to the core until everything turns white..."),
	watch_consume_text_range = 10,
	watch_consume_text_visual = span_danger("You can feel hot waves of radiation wash over you."),
	watch_consume_text_audible = span_danger("Your ear is filled with an unearthly ringing as your skin bubbles and reddens with new radiation burns."),
	watch_consume_text_unseen = span_hear("An unearthly ringing fills your ears."),
	ignore_subtypesof = list(/obj/effect, /turf/open/space),
	register_signals = TRUE,
	ignore_flags = SUPERMATTER_IGNORES_1,
	ignore_status_flags = GODMODE,
	datum/callback/callback_after_consume,
	datum/callback/callback_get_flavortext,
	datum/callback/callback_process,
	datum/callback/callback_attack,
	datum/callback/callback_attack_hand,
	datum/callback/callback_attackby,
	datum/callback/callback_on_pickup,
	datum/callback/callback_on_bumped,
	datum/callback/callback_throw_impact,
	datum/callback/callback_hitby_blob,
)

	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.consume_on_bumped = consume_on_bumped
	src.consume_on_attack = consume_on_attack
	src.consume_on_attack_hand = consume_on_attack_hand
	src.consume_on_attackby = consume_on_attackby
	src.consume_on_pickup = consume_on_pickup
	src.consume_on_throw = consume_on_throw
	src.consume_all_contents = consume_all_contents
	src.consume_turfs = consume_turfs
	src.passively_consumes_turf = passively_consumes_turf

	src.consumption_sound = consumption_sound

	src.consume_does_radiation = consume_does_radiation
	src.radiation_range = radiation_range
	src.radiation_threshold = radiation_threshold
	src.radiation_chance = radiation_chance

	src.ignore_flags = ignore_flags
	src.ignore_status_flags = ignore_status_flags
	src.ignore_subtypesof = ignore_subtypesof
	
	src.consumed_text = consumed_text
	src.watch_consume_text_range = watch_consume_text_range
	src.watch_consume_text_visual = watch_consume_text_visual
	src.watch_consume_text_audible = watch_consume_text_audible
	src.watch_consume_text_unseen = watch_consume_text_unseen

	src.callback_after_consume = callback_after_consume
	src.callback_get_flavortext = callback_get_flavortext
	src.callback_process = callback_process
	src.callback_attack = callback_attack
	src.callback_attack_hand = callback_attack_hand
	src.callback_attackby = callback_attackby
	src.callback_on_pickup = callback_on_pickup
	src.callback_on_bumped = callback_on_bumped
	src.callback_throw_impact = callback_throw_impact
	src.callback_hitby_blob = callback_hitby_blob

	if(register_signals) //For specifically the case of the supermatter, it has too much interaction
		RegisterSignal(parent, list(COMSIG_ITEM_PRE_ATTACK, COMSIG_ITEM_ATTACK_OBJ), .proc/attack_atom)
		RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/on_attackby)
		RegisterSignal(parent, COMSIG_ITEM_PICKUP, .proc/on_pickup)
		RegisterSignal(parent, COMSIG_MOVABLE_IMPACT, .proc/on_throw_impact)
		RegisterSignal(parent, COMSIG_ATOM_BUMPED, .proc/on_bumped)
		RegisterSignal(parent, list(\
			COMSIG_ATOM_ATTACK_HAND,
			COMSIG_ATOM_HULK_ATTACK,
			COMSIG_ATOM_ATTACK_ANIMAL,
			COMSIG_ATOM_ATTACK_BASIC_MOB,
			COMSIG_ATOM_ATTACK_PAW
		), .proc/on_attack_hand)
		RegisterSignal(parent, COMSIG_ATOM_BLOB_ACT, .proc/on_hitby_blob)
		
	if(callback_process)
		START_PROCESSING(SSobj, src)

/datum/component/dusting/Destroy()
	UnregisterSignal(parent, list(\
		COMSIG_ITEM_PRE_ATTACK,
		COMSIG_ITEM_ATTACK_OBJ,
		COMSIG_PARENT_ATTACKBY,
		COMSIG_ITEM_PICKUP,
		COMSIG_MOVABLE_IMPACT,
		COMSIG_ATOM_BUMPED,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_HULK_ATTACK,
		COMSIG_ATOM_ATTACK_ANIMAL,
		COMSIG_ATOM_ATTACK_BASIC_MOB,
		COMSIG_ATOM_ATTACK_PAW,
	))
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/component/dusting/process(delta_time)
	if(!callback_process)
		STOP_PROCESSING(SSobj, src)
		return

	. = callback_process.Invoke(src) //Kills process if this returns PROCESS_KILL
	if(passively_consumes_turf && consume_turfs)
		consume_atom(get_turf(parent))

/* The cream of the crop
 * Handles consuming any physical manifestation (atom). It should be 100% safe to put anything in consumed_atom argument. SHOULD-
 * 
 * Arguments:
 * * consumed_atom - The atom to consume. Mobs call dust(). Objects call qdel(). Turfs call ScrapeAway().
 * * currently_consuming_contents - Used for preventing chat spamming for admins when this component deletes all contents. Don't set this to true unless you already know what you're doing
 */
/datum/component/dusting/proc/consume_atom(atom/consumed_atom, currently_consuming_contents)
	if(isnull(consumed_atom))
		CRASH("Tried to consume NULL reference.")
	if(consumed_atom.flags_1 & ignore_flags)
		return
	if(is_type_in_typecache(consumed_atom, ignore_subtypesof))
		return
	if((!consume_turfs && isturf(consumed_atom)) || currently_consuming_contents) //Don't consume turfs multiple times, that's bad juju
		return
	if(ismob(consumed_atom) && !isliving(consumed_atom)) //Don't kill ghosts/eyes somehow
		return
	var/atom/atom_parent = parent

	//First, consume the contents
	if(consume_all_contents && !currently_consuming_contents)
		var/list/contents_to_consume = consumed_atom.get_all_contents()
		contents_to_consume.Remove(src, parent) //Remove ourselves and our parent if somehow in that list
		consume_multiple_atoms(contents_to_consume)

	//This proc gets special text cases
	var/list/misc_text = get_special_text(callback_get_flavortext, atom_parent, consumed_atom)
	if(!LAZYLEN(misc_text))
		stack_trace("get_special_text() returned [islist(misc_text) ? "an empty list" : "an unhandled type"].")
		return
	
	//Next, consume the actual atom
	if(ismob(consumed_atom))
		var/mob/living/consumed_living = consumed_atom
		if(consumed_living.status_flags & ignore_status_flags) //We don't wanna consume mobs with these status flags
			return

		//Logging. Don't skip admeme chat because this is a mob we're talking about
		message_admins("[misc_text[COMP_DUST_ADMINS_PREFIX]][misc_text[COMP_DUST_ADMINS_MOB]] [ADMIN_JMP(atom_parent)]")
		atom_parent.investigate_log(misc_text[COMP_DUST_INVESTIGATE_MOB], INVESTIGATE_SUPERMATTER)

		//Consume thy flesh
		consumed_living.visible_message(misc_text[COMP_DUST_MOB_VISUAL], misc_text[COMP_DUST_MOB_SELF], misc_text[COMP_DUST_MOB_BLIND])
		consumed_living.dust(force = TRUE)

	if(isobj(consumed_atom))
		var/obj/consumed_object = consumed_atom
		if(!currently_consuming_contents) //Skip sending this to an admin's chat
			message_admins("[misc_text[COMP_DUST_ADMINS_PREFIX]][misc_text[COMP_DUST_ADMINS]] [ADMIN_JMP(atom_parent)].")
		atom_parent.investigate_log(misc_text[COMP_DUST_INVESTIGATE], INVESTIGATE_SUPERMATTER)

		//Vaporized
		consumed_object.visible_message(misc_text[COMP_DUST_OBJ_VISUAL], null, misc_text[COMP_DUST_OBJ_BLIND])
		qdel(consumed_object)

	if(isturf(consumed_atom))
		var/turf/old_turf = consumed_atom
		var/turf/old_turf_type = consumed_atom.type
		var/turf/new_turf = old_turf.ScrapeAway(flags = CHANGETURF_INHERIT_AIR)
		if(new_turf.type == old_turf_type) //Nothing happened
			return
		
		//Complete destruction
		new_turf.visible_message(span_danger("[misc_text[COMP_DUST_TURF_VISUAL_PREFIX]] and reveals [new_turf] underneath."), null, misc_text[COMP_DUST_TURF_BLIND])

	//Om nom nom
	playsound(get_turf(parent), consumption_sound, 80, vary = TRUE)

	//Next, do radiation and give fluff text to nearby mobs
	. = TRUE

	if(consume_does_radiation)
		do_radiation(
			range = misc_text[COMP_DUST_RADIATION_RANGE],
			threshold = misc_text[COMP_DUST_RADIATION_THRESHOLD],
			chance = misc_text[COMP_DUST_RADIATION_CHANCE],
			visual_range = misc_text[COMP_DUST_RADIATION_RANGE_TEXT],
			visual_message = misc_text[COMP_DUST_RADIATION_VISUAL],
			audible_message = misc_text[COMP_DUST_RADIATION_AUDIBLE],
			unseen_message = misc_text[COMP_DUST_RADIATION_UNSEEN],
			consumed_atom_name = misc_text[COMP_DUST_CONSUMED],
		)
	
	callback_after_consume?.InvokeAsync(src, consumed_atom)


/datum/component/dusting/proc/consume_multiple_atoms(list/atoms)
	if(atoms.len)
		var/atom/atom_parent = parent
		message_admins("[atom_parent] ([src.type]) has consumed multiple objects [ADMIN_JMP(atom_parent)].")
	for(var/atom in atoms)
		consume_atom(atom, currently_consuming_contents=TRUE)

//Does a pulse of radiation, provides visual messages to nearby mobs, and logs irradiation
/datum/component/dusting/proc/do_radiation(range=5, threshold=1, chance=100, visual_range=10, visual_message, audible_message, unseen_message, consumed_atom_name)
	radiation_pulse(parent, max_range = range, threshold = threshold, chance = chance)
	var/atom/atom_parent = parent
	for(var/mob/living/near_mob in range(visual_range, parent))
		if(HAS_TRAIT(near_mob, TRAIT_RADIMMUNE) || issilicon(near_mob))
			continue
		if(ishuman(near_mob) && SSradiation.wearing_rad_protected_clothing(near_mob))
			continue
		if(near_mob in view(watch_consume_text_range, atom_parent))
			near_mob.show_message(visual_message, MSG_VISUAL, audible_message, MSG_AUDIBLE)
		else
			near_mob.show_message(unseen_message, MSG_AUDIBLE)
		atom_parent.investigate_log("has irradiated [key_name(near_mob)] after consuming \the [consumed_atom_name].", INVESTIGATE_SUPERMATTER)

//Consumes the atom, then spread radiation + text
/datum/component/dusting/proc/consume_and_radiate(atom/consumed_atom, range=5, threshold=1, chance=100, visual_range=10, visual_message, audible_message, unseen_message, consumed_atom_name)
	if(!consume_does_radiation) //Do nothing, just consume
		return consume_atom(consumed_atom)
	
	consume_does_radiation = FALSE //Temporarily set to false so do_radiation doesn't get automatically called with the wrong text we're trying to display
	. = consume_atom(consumed_atom) //NOURISHMENT
	do_radiation(range, threshold, chance, visual_range, visual_message, audible_message, unseen_message, consumed_atom.name)
	consume_does_radiation = TRUE
	

/*
	ALL HAIL THE MAGIC DCS!
	(Signal procs below and things that would invoke callbacks)
 */

//Returns a list full of text with assigned values to customize what is shown when a mob gets consumed. Also returns radiation values
/datum/component/dusting/proc/get_special_text(datum/callback/callback, atom/atom_parent, atom/consumed_atom, rad_range, rad_threshold, rad_chance)
	. = list(
		COMP_DUST_MOB_VISUAL = span_danger("[consumed_atom] slams into [atom_parent], inducing a resonance... [consumed_atom.p_their()] body starts to glow and burst into flames before flashing into dust!"),
		COMP_DUST_MOB_SELF = consumed_text,
		COMP_DUST_MOB_BLIND = span_hear("You hear an unearthly noise as a wave of heat washes over you."),
		COMP_DUST_OBJ_VISUAL = span_danger("[consumed_atom] smacks into [atom_parent] and rapidly flashes to ash."),
		COMP_DUST_OBJ_BLIND = span_hear("You hear a loud crack as you are washed with a wave of heat."),
		COMP_DUST_TURF_VISUAL_PREFIX = "[atom_parent] consumes \the [consumed_atom.name]",
		COMP_DUST_TURF_BLIND = span_hear("You hear a loud crack as you are washed with a wave of heat."),
		COMP_DUST_TURF_OVERRIDE = null,
		COMP_DUST_INVESTIGATE = "has consumed [consumed_atom]",
		COMP_DUST_INVESTIGATE_MOB = "has consumed [key_name(consumed_atom)].",
		COMP_DUST_ADMINS_PREFIX = "[atom_parent] ([type]) ",
		COMP_DUST_ADMINS = "has consumed [consumed_atom]",
		COMP_DUST_ADMINS_MOB = "has consumed [key_name_admin(consumed_atom)]",
		COMP_DUST_RADIATION_RANGE = rad_range,
		COMP_DUST_RADIATION_THRESHOLD = rad_threshold,
		COMP_DUST_RADIATION_CHANCE = rad_chance,
		COMP_DUST_RADIATION_RANGE_TEXT = watch_consume_text_range,
		COMP_DUST_RADIATION_VISUAL = watch_consume_text_visual,
		COMP_DUST_RADIATION_AUDIBLE = watch_consume_text_audible,
		COMP_DUST_RADIATION_UNSEEN = watch_consume_text_unseen,
		COMP_DUST_CONSUMED = consumed_atom.name,
	)
	if(isobj(consumed_atom))
		var/obj/consumed_object = consumed_atom
		if(consumed_object.fingerprintslast)
			.[COMP_DUST_INVESTIGATE] += ", last touched by [consumed_object.fingerprintslast]"
	
	if(callback)
		. = callback.Invoke(src, consumed_atom, .)

/datum/component/dusting/proc/attack_atom(datum/source, atom/attacked_atom, mob/living/user, params)
	SIGNAL_HANDLER

	. = callback_attack?.Invoke(src, attacked_atom, user, params)
	if(.)
		return .

	if(consume_on_attack)
		if(consume_atom(attacked_atom))
			return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/dusting/proc/on_attack_hand(datum/source, mob/user, list/modifiers)
	SIGNAL_HANDLER

	. = callback_attack_hand?.Invoke(src, user, modifiers)
	if(.)
		return .

	if(consume_on_attack_hand)
		consume_atom(user)

/datum/component/dusting/proc/on_attackby(datum/source, obj/item/attacking_item, mob/user, params)
	SIGNAL_HANDLER

	. = callback_attackby?.Invoke(src, attacking_item, user, params)
	if(.)
		return .

	if(consume_on_attackby)
		if(consume_atom(attacking_item))
			return COMPONENT_NO_AFTERATTACK

/datum/component/dusting/proc/on_pickup(datum/source, mob/user)
	SIGNAL_HANDLER

	. = callback_on_pickup?.Invoke(src, user)
	if(.)
		return .

	if(consume_on_pickup)
		if(consume_atom(user))
			return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/dusting/proc/on_bumped(datum/source, atom/bumped_atom)
	SIGNAL_HANDLER

	. = callback_on_bumped?.Invoke(src, bumped_atom)
	if(.)
		return .

	if(consume_on_bumped)
		consume_atom(bumped_atom)

/datum/component/dusting/proc/on_throw_impact(datum/source, atom/hit_atom, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER

	. = callback_throw_impact?.Invoke(src, hit_atom, throwingdatum)
	if(.)
		return .

	if(consume_on_throw)
		consume_atom(hit_atom)

/datum/component/dusting/proc/on_hitby_blob(datum/source, obj/structure/blob/attacking_blob)
	SIGNAL_HANDLER

	. = callback_hitby_blob?.Invoke(src, attacking_blob)
	if(.)
		return .

	if(consume_on_attackby)
		consume_atom(attacking_blob)
