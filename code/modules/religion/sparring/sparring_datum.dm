/datum/sparring_match
	///the chaplain. it isn't actually a chaplain all the time, but in the cases where the chaplain is needed this will always be them.
	var/mob/living/carbon/human/chaplain
	///the other fighter
	var/mob/living/carbon/human/opponent
	///what weapons will be allowed during the sparring match
	var/weapons_condition
	///area instance the participants must stay in
	var/area/arena_condition
	///what stakes the fight will have
	var/stakes_condition
	///cheats from the chaplain
	var/chaplain_violations_allowed = 2
	///cheats from the non-chaplain
	var/opponent_violations_allowed = 2
	///outside interventions that ruin the match
	var/flubs = 2

/datum/sparring_match/New(weapons_condition, arena_condition, stakes_condition, mob/living/carbon/human/chaplain, mob/living/carbon/human/opponent)
	. = ..()
	src.weapons_condition = weapons_condition
	src.arena_condition = arena_condition
	src.stakes_condition = stakes_condition
	src.chaplain = chaplain
	src.opponent = opponent
	ADD_TRAIT(chaplain, TRAIT_SPARRING, TRAIT_GENERIC)
	ADD_TRAIT(opponent, TRAIT_SPARRING, TRAIT_GENERIC)
	hook_signals(chaplain)
	hook_signals(opponent)
	chaplain.add_filter("sparring_outline", 9, list("type" = "outline", "color" = "#e02200"))
	opponent.add_filter("sparring_outline", 9, list("type" = "outline", "color" = "#004ee0"))

/datum/sparring_match/proc/hook_signals(mob/living/carbon/human/sparring)
	//weapon conditions
	if(weapons_condition < CONDITION_ANY_WEAPON)
		RegisterSignal(sparring, COMSIG_MOB_FIRED_GUN, PROC_REF(gun_violation))
		RegisterSignal(sparring, COMSIG_MOB_GRENADE_ARMED, PROC_REF(grenade_violation))
	if(weapons_condition <= CONDITION_CEREMONIAL_ONLY)
		RegisterSignal(sparring, COMSIG_ATOM_ATTACKBY, PROC_REF(melee_violation))
	//arena conditions
	RegisterSignal(sparring, COMSIG_MOVABLE_MOVED, PROC_REF(arena_violation))
	//severe violations (insta violation win for other party) conditions
	RegisterSignal(sparring, COMSIG_MOVABLE_POST_TELEPORT, PROC_REF(teleport_violation))
	//win conditions
	RegisterSignal(sparring, COMSIG_MOB_STATCHANGE, PROC_REF(check_for_victory))
	//flub conditions
	RegisterSignal(sparring, COMSIG_ATOM_ATTACKBY, PROC_REF(outsider_interference), override = TRUE)
	RegisterSignal(sparring, COMSIG_ATOM_HULK_ATTACK, PROC_REF(hulk_interference), override = TRUE)
	RegisterSignal(sparring, COMSIG_ATOM_ATTACK_HAND, PROC_REF(hand_interference), override = TRUE)
	RegisterSignal(sparring, COMSIG_ATOM_ATTACK_PAW, PROC_REF(paw_interference), override = TRUE)
	RegisterSignal(sparring, COMSIG_ATOM_HITBY, PROC_REF(thrown_interference), override = TRUE)
	RegisterSignal(sparring, COMSIG_ATOM_BULLET_ACT, PROC_REF(projectile_interference), override = TRUE)
	//severe flubs (insta match ender, no winners) conditions
	RegisterSignal(sparring, COMSIG_LIVING_DEATH, PROC_REF(death_flub))
	RegisterSignal(sparring, COMSIG_QDELETING, PROC_REF(deletion_flub))

/datum/sparring_match/proc/unhook_signals(mob/living/carbon/human/sparring)
	if(!sparring)
		return
	UnregisterSignal(sparring, list(
		COMSIG_MOB_FIRED_GUN,
		COMSIG_MOB_GRENADE_ARMED,
		COMSIG_MOVABLE_MOVED,
		COMSIG_MOVABLE_POST_TELEPORT,
		COMSIG_MOB_STATCHANGE,
		COMSIG_ATOM_ATTACKBY,
		COMSIG_ATOM_HULK_ATTACK,
		COMSIG_ATOM_ATTACK_HAND,
		COMSIG_ATOM_ATTACK_PAW,
		COMSIG_ATOM_HITBY,
		COMSIG_ATOM_BULLET_ACT,
		COMSIG_LIVING_DEATH,
		COMSIG_QDELETING,
	))

///someone is changing health state, end the fight in crit
/datum/sparring_match/proc/check_for_victory(datum/participant, new_stat)
	SIGNAL_HANDLER

	//death needs to be a flub, conscious means they haven't won
	if(new_stat == CONSCIOUS || new_stat == DEAD)
		return
	if(participant == chaplain)
		end_match(opponent, chaplain)
	else
		end_match(chaplain, opponent)

// SIGNALS THAT ARE FOR BEING ATTACKED FIRST (GUILTY)
/datum/sparring_match/proc/outsider_interference(datum/source, obj/item/I, mob/attacker)
	SIGNAL_HANDLER
	if(attacker == chaplain || attacker == opponent)
		return
	INVOKE_ASYNC(src, PROC_REF(flub), attacker)

/datum/sparring_match/proc/hulk_interference(datum/source, mob/attacker)
	SIGNAL_HANDLER
	if((attacker == chaplain || attacker == opponent))
		// fist fighting a hulk is so dumb. i can't fathom why you would do this.
		return
	INVOKE_ASYNC(src, PROC_REF(flub), attacker)

/datum/sparring_match/proc/hand_interference(datum/source, mob/living/attacker)
	SIGNAL_HANDLER
	if(attacker == chaplain || attacker == opponent)
		//you can pretty much always use fists as a participant
		return

	INVOKE_ASYNC(src, PROC_REF(flub), attacker)

/datum/sparring_match/proc/paw_interference(datum/source, mob/living/attacker)
	SIGNAL_HANDLER

	if(attacker == chaplain || attacker == opponent)
		//you can pretty much always use paws as a participant
		return

	INVOKE_ASYNC(src, PROC_REF(flub), attacker)

/datum/sparring_match/proc/thrown_interference(datum/source, atom/movable/thrown_movable, skipcatch = FALSE, hitpush = TRUE, blocked = FALSE, datum/thrownthing/throwingdatum)
	SIGNAL_HANDLER

	if(!isitem(thrown_movable))
		return
	var/mob/living/honorbound = source
	var/obj/item/thrown_item = thrown_movable
	var/mob/thrown_by = throwingdatum.get_thrower()
	if(thrown_item.throwforce < honorbound.health && ishuman(thrown_by))
		INVOKE_ASYNC(src, PROC_REF(flub), thrown_by)

/datum/sparring_match/proc/projectile_interference(datum/participant, obj/projectile/proj)
	SIGNAL_HANDLER
	if(proj.firer == chaplain || proj.firer == opponent)
		//oh, well that's allowed. or maybe it isn't. doesn't matter because firing the gun will trigger a violation, so no additional violation needed
		return
	var/mob/living/interfering
	if(isliving(proj.firer))
		interfering = proj.firer
	INVOKE_ASYNC(src, PROC_REF(flub), interfering)

///someone randomly fucking died
/datum/sparring_match/proc/death_flub(datum/deceased)
	SIGNAL_HANDLER

	flubbed_match()

///someone randomly fucking deleted
/datum/sparring_match/proc/deletion_flub(datum/qdeleting)
	SIGNAL_HANDLER

	flubbed_match()

///someone used a gun
/datum/sparring_match/proc/gun_violation(mob/offender, obj/item/gun/gun_fired, target, params, zone_override, list/bonus_spread_values)
	SIGNAL_HANDLER
	violation(offender, "using guns")

///someone used a grenade
/datum/sparring_match/proc/grenade_violation(datum/offender)
	SIGNAL_HANDLER
	violation(offender, "using grenades")

///someone used melee weapons
/datum/sparring_match/proc/melee_violation(datum/offender, obj/item/thing, mob/user, params)
	SIGNAL_HANDLER

	if(weapons_condition != CONDITION_CEREMONIAL_ONLY)
		violation(offender, "using melee weapons")
	if(istype(thing, /obj/item/ceremonial_blade))
		return
	violation(offender, "using non ceremonial weapons")

/datum/sparring_match/proc/teleport_violation(datum/offender)
	SIGNAL_HANDLER
	if(offender == chaplain)
		end_match(opponent, chaplain, violation_victory = TRUE)
	else
		end_match(chaplain, opponent, violation_victory = TRUE)

///someone tried to leave
/datum/sparring_match/proc/arena_violation(atom/movable/mover, atom/oldloc, direction)
	SIGNAL_HANDLER

	var/area/inhabited_area = get_area(mover)
	if(inhabited_area == arena_condition)
		return //still in the ring!! :)

	violation(mover, "leaving the arena")
	var/atom/throw_target = get_edge_target_turf(mover, REVERSE_DIR(direction))
	mover.throw_at(throw_target, 6, 4)

/datum/sparring_match/proc/violation(mob/living/carbon/human/offender, reason)
	SIGNAL_HANDLER

	to_chat(offender, span_userdanger("Violation! No [reason]!"))
	if(offender == chaplain)
		chaplain_violations_allowed--
		if(!chaplain_violations_allowed)
			end_match(opponent, chaplain, violation_victory = TRUE)
	else
		opponent_violations_allowed--
		if(!opponent_violations_allowed)
			end_match(chaplain, opponent, violation_victory = TRUE)

/datum/sparring_match/proc/flub(mob/living/interfering)
	if(interfering)
		var/list/possible_punishments = list(PUNISHMENT_OMEN, PUNISHMENT_LIGHTNING)
		if(ishuman(interfering))
			possible_punishments += PUNISHMENT_BRAND
		switch(pick(possible_punishments))
			if(PUNISHMENT_OMEN)
				to_chat(interfering, span_warning("You get a bad feeling... for interfering with [chaplain]'s sparring match..."))
				interfering.AddComponent(/datum/component/omen)
			if(PUNISHMENT_LIGHTNING)
				to_chat(interfering, span_warning("[GLOB.deity] has punished you for interfering with [chaplain]'s sparring match!"))
				lightningbolt(interfering)
			if(PUNISHMENT_BRAND)
				var/mob/living/carbon/human/branded = interfering
				to_chat(interfering, span_warning("[GLOB.deity] brands your flesh for interfering with [chaplain]'s sparring match!!"))
				var/obj/item/bodypart/branded_limb = pick(branded.bodyparts)
				branded_limb.force_wound_upwards(/datum/wound/burn/flesh/severe/brand, wound_source = "divine intervention")
				branded.painful_scream() // DOPPLER EDIT: check for painkilling before screaming

	flubs--
	if(!flubs) //too many interferences
		flubbed_match()

///this match was interfered on, nobody wins or loses anything, just end
/datum/sparring_match/proc/flubbed_match()
	cleanup_sparring_match()

	if(chaplain) //flubing means we don't know who is still standing
		to_chat(chaplain, span_bolddanger("The match was flub'd! No winners, no losers. You may restart the match with another contract."))
	if(opponent)
		to_chat(opponent, span_bolddanger("The match was flub'd! No winners, no losers."))
	qdel(src)

///helper to remove all the effects after a match ends
/datum/sparring_match/proc/cleanup_sparring_match()
	REMOVE_TRAIT(chaplain, TRAIT_SPARRING, TRAIT_GENERIC)
	REMOVE_TRAIT(opponent, TRAIT_SPARRING, TRAIT_GENERIC)
	unhook_signals(chaplain)
	unhook_signals(opponent)
	chaplain.remove_filter("sparring_outline")
	opponent.remove_filter("sparring_outline")

/datum/sparring_match/proc/end_match(mob/living/carbon/human/winner, mob/living/carbon/human/loser, violation_victory = FALSE)
	cleanup_sparring_match()
	to_chat(chaplain, span_bolddanger("[violation_victory ? "[loser] DISQUALIFIED!" : ""]  [winner] HAS WON!"))
	to_chat(opponent, span_bolddanger("[violation_victory ? "[loser] DISQUALIFIED!" : ""]  [winner] HAS WON!"))
	win(winner, loser, violation_victory)
	lose(loser, winner)
	if(stakes_condition != STAKES_YOUR_SOUL)
		var/healing_message = "You may want to heal up the loser now."
		if(winner == chaplain)
			healing_message += " Your bible will heal the loser for awhile."
		to_chat(winner, span_notice(healing_message))
	qdel(src)

///most of the effects are handled on `lose()` instead.
/datum/sparring_match/proc/win(mob/living/carbon/human/winner, mob/living/carbon/human/loser, violation_victory)
	switch(stakes_condition)
		if(STAKES_HOLY_MATCH)
			if(winner == chaplain)
				if(violation_victory)
					to_chat(winner, span_warning("[GLOB.deity] is not entertained from a matched decided by violations. No favor awarded..."))
				else
					to_chat(winner, span_nicegreen("You've won favor with [GLOB.deity]!"))
				var/datum/religion_sect/spar/sect = GLOB.religious_sect
				sect.adjust_favor(1, winner)
				sect.past_opponents += WEAKREF(loser)
		if(STAKES_MONEY_MATCH)
			to_chat(winner, span_nicegreen("You've won all of [loser]'s money!"))
		if(STAKES_YOUR_SOUL)
			to_chat(winner, span_nicegreen("You've won [loser]'s SOUL!"))

/datum/sparring_match/proc/lose(mob/living/carbon/human/loser, mob/living/carbon/human/winner)
	if(!loser) //shit happened?
		return
	switch(stakes_condition)
		if(STAKES_HOLY_MATCH)
			if(loser == chaplain)
				var/datum/religion_sect/spar/sect = GLOB.religious_sect
				sect.matches_lost++
				if(sect.matches_lost < 3)
					to_chat(loser, span_userdanger("[GLOB.deity] is angry you lost in their name!"))
					return
				to_chat(loser, span_userdanger("[GLOB.deity] is enraged by your lackluster sparring record!"))
				lightningbolt(loser)
				loser.add_mood_event("sparring", /datum/mood_event/banished)
				loser.mind.holy_role = NONE
				to_chat(loser, span_userdanger("You have been excommunicated! You are no longer holy!"))
		if(STAKES_MONEY_MATCH)
			to_chat(loser, span_userdanger("You've lost all your money to [winner]!"))
			var/datum/bank_account/loser_account = loser.get_bank_account()
			var/datum/bank_account/winner_account = winner.get_bank_account()
			if(!loser_account || !winner_account)//the winner is pretty owned in this case but whatever shoulda read the fine print of the contract
				return
			winner_account.transfer_money(loser_account, loser_account.account_balance, "Bet: Sparring")
		if(STAKES_YOUR_SOUL)
			var/turf/shard_turf = get_turf(loser)
			if(!shard_turf)
				return
			to_chat(loser, span_userdanger("You've lost ownership over your soul to [winner]!"))
			var/obj/item/soulstone/anybody/chaplain/sparring/shard = new(shard_turf)
			INVOKE_ASYNC(shard, TYPE_PROC_REF(/obj/item/soulstone, capture_soul), loser, winner, forced = TRUE)
