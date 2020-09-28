/// These datums get added to [/mob/living/simple_animal/var/passive_whims] instead of [/mob/living/simple_animal/var/live_whims], and need to be manually activated
/datum/whim/passive
	scan_every = 0

/// For peaceful mobs, this makes them try to run away when attacked
/datum/whim/passive/flee_danger
	name = "Flee danger"
	ticks_to_frustrate = 2
	abandon_rescan_length = 30 SECONDS
	/// A cooldown for a few visible_message related parts of this behavior
	COOLDOWN_DECLARE(cooldown_emote)
	/// How long the above cooldown lasts
	var/flee_emote_length = 10 SECONDS

/datum/whim/passive/flee_danger/activate(atom/new_target)
	. = ..()
	var/list/possible_panickers = list()
	for(var/mob/living/simple_animal/iter_simple in view(6, owner))
		if(iter_simple.stat || iter_simple.mind || iter_simple == src)
			continue
		if(!istype(iter_simple, owner.animal_species))
			continue
		possible_panickers += iter_simple

	if(length(possible_panickers) > 3)
		for(var/mob/living/simple_animal/panicked in possible_panickers)
			if(locate(/datum/whim/passive/panic) in panicked.passive_whims)
				continue
			var/datum/whim/passive/panic/losing_control = new(panicked)
			losing_control.activate(owner)
		testing("A panic breaks out! Num: [length(possible_panickers)]")

/datum/whim/passive/flee_danger/New(mob/living/simple_animal/attaching_owner)
	. = ..()
	RegisterSignal(owner, COMSIG_PARENT_ATTACKBY, .proc/receive_damage)
	RegisterSignal(owner, COMSIG_ATOM_ATTACK_HAND, .proc/receive_damage_hand)

/datum/whim/passive/flee_danger/Destroy(force, ...)
	if(owner)
		UnregisterSignal(owner, list(COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_ATTACK_HAND))
	return ..()

/// Just hands off control to [/datum/whim/passive/flee_danger/proc/check_spook]
/datum/whim/passive/flee_danger/proc/receive_damage(datum/source, obj/item/weapon, mob/living/user, params)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, .proc/check_spook, weapon, user, params)

/// Filters out non-bad-touches then hands off control to [/datum/whim/passive/flee_danger/proc/check_spook]
/datum/whim/passive/flee_danger/proc/receive_damage_hand(datum/source, mob/living/carbon/user)
	SIGNAL_HANDLER
	if(!istype(user) || user.a_intent == INTENT_HELP || user.a_intent == INTENT_GRAB)
		return FALSE
	INVOKE_ASYNC(src, .proc/check_spook, null, user)

/// I
/datum/whim/passive/flee_danger/proc/check_spook(obj/item/weapon, mob/living/user, params)
	if(!istype(user) || owner.stat || user == owner || owner.mind)
		return FALSE

	if(owner.pulledby)
		if(COOLDOWN_FINISHED(src, cooldown_emote))
			owner.visible_message("<span class='danger'>[owner] is unable to break from [owner.pulledby]'s grasp!</span>", vision_distance=COMBAT_MESSAGE_RANGE)
			COOLDOWN_START(src, cooldown_emote, flee_emote_length)
		return FALSE

	if(owner.current_whim == src)
		continued_assault(user)
		return

	if(COOLDOWN_FINISHED(src, cooldown_abandon_rescan))
		if(prob(80) && (owner.health / owner.maxHealth) < 0.3)
			if(COOLDOWN_FINISHED(src, cooldown_emote))
				owner.visible_message("<span class='danger'>[owner] seems to accept [owner.p_their()] fate, refusing to run.</span>", vision_distance=COMBAT_MESSAGE_RANGE)
				COOLDOWN_START(src, cooldown_emote, flee_emote_length)
			COOLDOWN_START(src, cooldown_abandon_rescan, abandon_rescan_length)
			return FALSE
	else
		return FALSE

	if(prob(100 - (owner.health / owner.maxHealth) * 100))
		return FALSE

	var/speed = 5
	speed += (1 - (owner.health / owner.maxHealth)) * 20
	walk_away(owner, user, 5, speed)
	owner.visible_message("<span class='danger'>[owner] jolts away from [user]!</span>")
	activate(user)

/datum/whim/passive/flee_danger/proc/continued_assault(mob/living/user)
	var/speed = 5
	speed += (1 - (owner.health / owner.maxHealth)) * 30
	walk_away(owner, user, 4, speed)



/**
  * When a member of the same animal_species starts fleeing danger and there's enough other species mates nearby, they can start a panic! aaaahhh!!
  *
  * Note that this Whim isn't added in any mob's class definition, it's a product of a species-mate activating flee_danger and assigning the panic Whim to us and activating it.
  *	After finishing its run, it sticks around until its cooldown wears off, then deletes itself. This is an example of how you can use Whims to affect other mobs arbitrarily by
  *	assigning Whims to other mobs, meaning you could shoestring together a sort of "coordination" simply by forcing similar Whims on a cluster of similar mobs, giving the
  *	player the illusion of more mechanical depth than actually exists if we're clever with our Whim scripting.
  */
/datum/whim/passive/panic
	name = "Panic!"
	ticks_to_frustrate = 4
	abandon_rescan_length = 30 SECONDS

/datum/whim/passive/panic/abandon()
	if(!QDELING(src))
		addtimer(CALLBACK(src, .proc/panic_cooldown), abandon_rescan_length) // no more panicking for this long
	return ..()

/datum/whim/passive/panic/activate(atom/new_target)
	if(!COOLDOWN_FINISHED(src, cooldown_abandon_rescan))
		qdel(src)
		return
	. = ..()
	owner.visible_message("<span class='notice'>[owner] panics!</span>")
	owner.do_alert_animation()
	playsound(owner.loc, 'sound/machines/chime.ogg', 50, TRUE, -1)

	var/speed = 5
	speed += (1 - (owner.health / owner.maxHealth)) * 20
	walk_rand(owner, speed)

/datum/whim/passive/panic/tick()
	. = ..()
	if(state == WHIM_INACTIVE)
		return

	if(prob(50))
		walk(owner, 0)
		owner.spin(2 SECONDS, 1)
	else
		var/speed = 5
		speed += (1 - (owner.health / owner.maxHealth)) * 20
		walk_rand(owner, speed)

/datum/whim/passive/panic/proc/panic_cooldown()
	if(!QDELING(src))
		qdel(src)
