//Hulk turns your skin green, makes you strong, and allows you to shrug off stun effect.
/datum/mutation/human/hulk
	name = "Hulk"
	desc = "A poorly understood genome that causes the holder's muscles to expand, inhibit speech and gives the person a bad skin condition."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	text_gain_indication = "<span class='notice'>Your muscles hurt!</span>"
	species_allowed = list("human") //no skeleton/lizard hulk
	health_req = 25
	instability = 40
	var/scream_delay = 50
	var/last_scream = 0


/datum/mutation/human/hulk/on_acquiring(mob/living/carbon/human/owner)
	if(..())
		return
	ADD_TRAIT(owner, TRAIT_STUNIMMUNE, GENETIC_MUTATION)
	ADD_TRAIT(owner, TRAIT_PUSHIMMUNE, GENETIC_MUTATION)
	ADD_TRAIT(owner, TRAIT_CHUNKYFINGERS, GENETIC_MUTATION)
	ADD_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, GENETIC_MUTATION)
	ADD_TRAIT(owner, TRAIT_HULK, GENETIC_MUTATION)
	owner.update_body_parts()
	SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "hulk", /datum/mood_event/hulk)
	RegisterSignal(owner, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, .proc/on_attack_hand)
	RegisterSignal(owner, COMSIG_MOB_SAY, .proc/handle_speech)
	RegisterSignal(owner, COMSIG_MOB_EMOTE, .proc/handle_emote)

/datum/mutation/human/hulk/proc/on_attack_hand(mob/living/carbon/human/source, atom/target, proximity)
	SIGNAL_HANDLER

	if(!proximity)
		return
	if(source.a_intent != INTENT_HARM)
		return
	if(target.attack_hulk(owner))
		if(world.time > (last_scream + scream_delay))
			last_scream = world.time
			INVOKE_ASYNC(src, .proc/scream_attack, source)
		log_combat(source, target, "punched", "hulk powers")
		source.do_attack_animation(target, ATTACK_EFFECT_SMASH)
		source.changeNext_move(CLICK_CD_MELEE)

		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/mutation/human/hulk/proc/scream_attack(mob/living/carbon/human/source)
	source.say(pick(";RAAAAAAAARGH!", ";HNNNNNNNNNGGGGGGH!", ";GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", ";AAAAAAARRRGH!" ), forced="hulk")

/**
  *Checks damage of a hulk's arm and applies bone wounds as necessary.
  *
  *Called by specific atoms being attacked, such as walls. If an atom
  *does not call this proc, than punching that atom will not cause
  *arm breaking (even if the atom deals recoil damage to hulks).
  *Arguments:
  *arg1 is the arm to evaluate damage of and possibly break.
  */
/datum/mutation/human/hulk/proc/break_an_arm(obj/item/bodypart/arm)
	switch(arm.brute_dam)
		if(45 to 50)
			arm.force_wound_upwards(/datum/wound/blunt/critical)
		if(41 to 45)
			arm.force_wound_upwards(/datum/wound/blunt/severe)
		if(35 to 41)
			arm.force_wound_upwards(/datum/wound/blunt/moderate)

/datum/mutation/human/hulk/on_life()
	if(owner.health < 0)
		on_losing(owner)
		to_chat(owner, "<span class='danger'>You suddenly feel very weak.</span>")

/datum/mutation/human/hulk/on_losing(mob/living/carbon/human/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, TRAIT_STUNIMMUNE, GENETIC_MUTATION)
	REMOVE_TRAIT(owner, TRAIT_PUSHIMMUNE, GENETIC_MUTATION)
	REMOVE_TRAIT(owner, TRAIT_CHUNKYFINGERS, GENETIC_MUTATION)
	REMOVE_TRAIT(owner, TRAIT_IGNOREDAMAGESLOWDOWN, GENETIC_MUTATION)
	REMOVE_TRAIT(owner, TRAIT_HULK, GENETIC_MUTATION)
	owner.update_body_parts()
	SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "hulk")
	UnregisterSignal(owner, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)
	UnregisterSignal(owner, COMSIG_MOB_SAY)
	UnregisterSignal(owner, COMSIG_MOB_EMOTE)

/datum/mutation/human/hulk/proc/handle_speech(original_message, wrapped_message)
	SIGNAL_HANDLER

	var/message = wrapped_message[1]
	if(message)
		message = "[replacetext(message, ".", "!")]!!"
	wrapped_message[1] = message
	return COMPONENT_UPPERCASE_SPEECH

/// How many steps it takes to throw the mob. Should be divisible by 4 so we throw in the direction we started
#define HULK_TAILTHROW_STEPS 28

/// If we have a tail'd mob in a neckgrab and we spin, kick off the spinfest
/datum/mutation/human/hulk/proc/handle_emote(mob/living/carbon/user, datum/emote/emote)
	if(user.incapacitated() || emote.key != "spin" || !user.pulling || !user.grab_state >= GRAB_NECK)
		return

	if(!iscarbon(user.pulling))
		return

	var/mob/living/carbon/possible_throwable = user.pulling
	if(!possible_throwable.getorganslot(ORGAN_SLOT_TAIL) && !ismonkey(possible_throwable))
		return

	INVOKE_ASYNC(src, .proc/setup_swing, user, possible_throwable)

/// Do a short 2 second do_after before starting the actual swing
/datum/mutation/human/hulk/proc/setup_swing(mob/living/carbon/human/the_hulk, mob/living/carbon/yeeted_person)
	var/original_dir = the_hulk.dir // so no matter if the hulk tries to mess up their direction, they always face where they started when they throw

	yeeted_person.forceMove(the_hulk.loc)
	yeeted_person.setDir(get_dir(yeeted_person, the_hulk))

	yeeted_person.Stun(2 SECONDS)
	yeeted_person.visible_message("<span class='danger'>[the_hulk] starts grasping [yeeted_person] by the tail...</span>", \
					"<span class='userdanger'>[the_hulk] begins grasping your tail!</span>", "<span class='hear'>You hear aggressive shuffling!</span>", null, the_hulk)
	to_chat(the_hulk, "<span class='danger'>You start grasping [yeeted_person] by the tail...</span>")

	if(!do_after(the_hulk, 2 SECONDS, yeeted_person))
		yeeted_person.visible_message("<span class='danger'>[yeeted_person] breaks free of [the_hulk]'s grasp!</span>", \
					"<span class='userdanger'>You break free from [the_hulk]'s grasp!</span>", "<span class='hear'>You hear aggressive shuffling!</span>", null, the_hulk)
		to_chat(the_hulk, "<span class='danger'>You lose your grasp on [yeeted_person]'s tail!</span>")
		return

	yeeted_person.Stun(8 SECONDS)
	yeeted_person.visible_message("<span class='danger'>[the_hulk] starts spinning [yeeted_person] around by [yeeted_person.p_their()] tail!</span>", \
					"<span class='userdanger'>[the_hulk] starts spinning you around by your tail!</span>", "<span class='hear'>You hear wooshing sounds!</span>", null, the_hulk)
	to_chat(the_hulk, "<span class='danger'>You start spinning [yeeted_person] around by [yeeted_person.p_their()] tail!</span>")
	the_hulk.emote("scream")
	yeeted_person.emote("scream")
	swing_loop(the_hulk, yeeted_person, 0, original_dir)

/// For each step of the swinging, with the delay getting shorter along the way. Checks to see we still have them in our grasp at each step.
/datum/mutation/human/hulk/proc/swing_loop(mob/living/carbon/human/the_hulk, mob/living/carbon/yeeted_person, step, original_dir)
	if(!is_swing_viable(the_hulk, yeeted_person))
		return

	var/delay = 6
	switch (step)
		if (25 to INFINITY)
			delay = 0.1
		if (21 to 24)
			delay = 0.5
		if (17 to 20)
			delay = 1
		if (14 to 16)
			delay = 2
		if (9 to 13)
			delay = 3
		if (5 to 8)
			delay = 4
		if (0 to 4)
			delay = 5

	the_hulk.setDir(turn(the_hulk.dir, 90))
	var/turf/T = get_step(the_hulk, the_hulk.dir)
	var/turf/S = yeeted_person.loc
	if ((isturf(S) && S.Exit(yeeted_person)) && (isturf(T) && T.Enter(the_hulk)))
		yeeted_person.forceMove(T)
		yeeted_person.setDir(get_dir(yeeted_person, the_hulk))

	step++
	if(step >= HULK_TAILTHROW_STEPS)
		finish_swing(the_hulk, yeeted_person, original_dir)
	else
		addtimer(CALLBACK(src, .proc/swing_loop, the_hulk, yeeted_person, step, original_dir), delay)

/// Time to toss the victim at high speed
/datum/mutation/human/hulk/proc/finish_swing(mob/living/carbon/human/the_hulk, mob/living/carbon/yeeted_person, original_dir)
	if(!is_swing_viable(the_hulk, yeeted_person))
		return

	the_hulk.setDir(original_dir)
	yeeted_person.forceMove(the_hulk.loc) // Maybe this will help with the wallthrowing bug.
	yeeted_person.visible_message("<span class='danger'>[the_hulk] throws [yeeted_person]!</span>", \
					"<span class='userdanger'>You're thrown by [the_hulk]!</span>", "<span class='hear'>You hear aggressive shuffling and a loud thud!</span>", null, the_hulk)
	to_chat(the_hulk, "<span class='danger'>You throw [yeeted_person]!</span>")
	playsound(the_hulk.loc, "swing_hit", 50, TRUE)
	var/turf/T = get_edge_target_turf(the_hulk, the_hulk.dir)
	if(!isturf(T))
		return
	if(!yeeted_person.stat)
		yeeted_person.emote("scream")
	yeeted_person.throw_at(T, 10, 6, the_hulk, TRUE, TRUE, callback = CALLBACK(yeeted_person, /mob/living/carbon.proc/Paralyze, 20))
	log_combat(the_hulk, yeeted_person, "has thrown by tail")

/// Helper to reduce copypasta, this proc returns FALSE if either the hulk or thrown person are deleted or separated, TRUE otherwise
/datum/mutation/human/hulk/proc/is_swing_viable(mob/living/carbon/human/the_hulk, mob/living/carbon/yeeted_person)
	if(!yeeted_person || !the_hulk || the_hulk.incapacitated())
		return FALSE

	if (get_dist(the_hulk, yeeted_person) > 1)
		to_chat(the_hulk, "<span class='warning'>[yeeted_person] is too far away!</span>")
		return FALSE

	if (!isturf(the_hulk.loc) || !isturf(yeeted_person.loc))
		to_chat(the_hulk, "<span class='warning'>You can't throw [yeeted_person] from here!</span>")
		return FALSE
	return TRUE

#undef HULK_TAILTHROW_STEPS
