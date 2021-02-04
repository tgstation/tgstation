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
	RegisterSignal(owner, COMSIG_MOB_CLICKON, .proc/check_swing)

/datum/mutation/human/hulk/proc/on_attack_hand(mob/living/carbon/human/source, atom/target, proximity)
	SIGNAL_HANDLER

	if(!proximity)
		return
	if(!source.combat_mode)
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
	UnregisterSignal(owner, COMSIG_MOB_CLICKON)

/datum/mutation/human/hulk/proc/handle_speech(original_message, wrapped_message)
	SIGNAL_HANDLER

	var/message = wrapped_message[1]
	if(message)
		message = "[replacetext(message, ".", "!")]!!"
	wrapped_message[1] = message
	return COMPONENT_UPPERCASE_SPEECH

/// How many steps it takes to throw the mob
#define HULK_TAILTHROW_STEPS 28

/// Run a barrage of checks to see if any given click is actually able to swing
/datum/mutation/human/hulk/proc/check_swing(mob/living/carbon/human/user, atom/clicked_atom, params)
	SIGNAL_HANDLER

	/// Basically, we only proceed if we're in throw mode with a tailed carbon in our grasp with at least a neck grab and we're not restrained in some way
	var/list/modifiers = params2list(params)
	if(modifiers["alt"] || modifiers["shift"] || modifiers["ctrl"] || modifiers["middle"])
		return
	if(!user.in_throw_mode || user.get_active_held_item() || user.zone_selected != BODY_ZONE_PRECISE_GROIN)
		return
	if(user.grab_state < GRAB_NECK || !iscarbon(user.pulling) || user.buckled || user.incapacitated())
		return

	var/mob/living/carbon/possible_throwable = user.pulling
	if(!possible_throwable.getorganslot(ORGAN_SLOT_TAIL))
		return

	if(ishuman(possible_throwable))
		var/mob/living/carbon/human/human_throwable = possible_throwable
		if(human_throwable.wear_suit && (human_throwable.wear_suit.flags_inv & HIDEJUMPSUIT))
			to_chat(user, "<span class='warning'>You can't reach [human_throwable]'s tail through [human_throwable.p_their()] [human_throwable.wear_suit.name]!</span>")
			return

	user.face_atom(clicked_atom)
	INVOKE_ASYNC(src, .proc/setup_swing, user, possible_throwable)
	return(COMSIG_MOB_CANCEL_CLICKON)

/// Do a short 2 second do_after before starting the actual swing
/datum/mutation/human/hulk/proc/setup_swing(mob/living/carbon/human/the_hulk, mob/living/carbon/yeeted_person)
	var/original_dir = the_hulk.dir // so no matter if the hulk tries to mess up their direction, they always face where they started when they throw

	yeeted_person.forceMove(the_hulk.loc)
	yeeted_person.setDir(get_dir(yeeted_person, the_hulk))

	log_combat(the_hulk, yeeted_person, "has started swinging by tail")
	yeeted_person.Stun(2 SECONDS)
	yeeted_person.visible_message("<span class='danger'>[the_hulk] starts grasping [yeeted_person] by the tail...</span>", \
					"<span class='userdanger'>[the_hulk] begins grasping your tail!</span>", "<span class='hear'>You hear aggressive shuffling!</span>", null, the_hulk)
	to_chat(the_hulk, "<span class='danger'>You start grasping [yeeted_person] by the tail...</span>")

	if(!do_after(the_hulk, 2 SECONDS, yeeted_person))
		yeeted_person.visible_message("<span class='danger'>[yeeted_person] breaks free of [the_hulk]'s grasp!</span>", \
					"<span class='userdanger'>You break free from [the_hulk]'s grasp!</span>", "<span class='hear'>You hear aggressive shuffling!</span>", null, the_hulk)
		to_chat(the_hulk, "<span class='danger'>You lose your grasp on [yeeted_person]'s tail!</span>")
		return

	// we're officially a-go!
	yeeted_person.Paralyze(8 SECONDS)
	yeeted_person.visible_message("<span class='danger'>[the_hulk] starts spinning [yeeted_person] around by [yeeted_person.p_their()] tail!</span>", \
					"<span class='userdanger'>[the_hulk] starts spinning you around by your tail!</span>", "<span class='hear'>You hear wooshing sounds!</span>", null, the_hulk)
	to_chat(the_hulk, "<span class='danger'>You start spinning [yeeted_person] around by [yeeted_person.p_their()] tail!</span>")
	the_hulk.emote("scream")
	yeeted_person.emote("scream")
	swing_loop(the_hulk, yeeted_person, 0, original_dir)

/**
 * Does the animations for the hulk swing loop
 *
 * This code is based in part on the wrestling swing code ported from goon, see [code/datums/martial/wrestling.dm]
 * credit to: cogwerks, pistoleer, spyguy, angriestibm, marquesas, and stuntwaffle.
 * For each step of the swinging, with the delay getting shorter along the way. Checks to see we still have them in our grasp at each step.
 */
/datum/mutation/human/hulk/proc/swing_loop(mob/living/carbon/human/the_hulk, mob/living/carbon/yeeted_person, step, original_dir)
	if(!yeeted_person || !the_hulk || the_hulk.incapacitated())
		return
	if(get_dist(the_hulk, yeeted_person) > 1 || !isturf(the_hulk.loc) || !isturf(yeeted_person.loc))
		to_chat(the_hulk, "<span class='warning'>You lose your grasp on [yeeted_person]!</span>")
		return

	var/delay = 5
	switch (step)
		if(24 to INFINITY)
			delay = 0.1
		if(20 to 23)
			delay = 0.5
		if(16 to 19)
			delay = 1
		if(13 to 15)
			delay = 2
		if(8 to 12)
			delay = 3
		if(4 to 7)
			delay = 3.5
		if(0 to 3)
			delay = 4

	the_hulk.setDir(turn(the_hulk.dir, 90))
	var/turf/current_spin_turf = yeeted_person.loc
	var/turf/intermediate_spin_turf = get_step(yeeted_person, the_hulk.dir) // the diagonal
	var/turf/next_spin_turf = get_step(the_hulk, the_hulk.dir)

	if((isturf(current_spin_turf) && current_spin_turf.Exit(yeeted_person)) && (isturf(next_spin_turf) && next_spin_turf.Enter(yeeted_person)))
		yeeted_person.forceMove(next_spin_turf)
		yeeted_person.face_atom(the_hulk)

	var/list/collateral_check = intermediate_spin_turf.contents + next_spin_turf.contents // check the cardinal and the diagonal tiles we swung past
	var/turf/collat_throw_target = get_edge_target_turf(yeeted_person, get_dir(current_spin_turf, next_spin_turf)) // what direction we're swinging

	for(var/mob/living/collateral_mob in collateral_check)
		if(!collateral_mob.density || collateral_mob == yeeted_person)
			continue

		yeeted_person.adjustBruteLoss(step*0.5)
		playsound(collateral_mob,'sound/weapons/punch1.ogg',50,TRUE)
		log_combat(the_hulk, collateral_mob, "has smacked with tail swing victim")
		log_combat(the_hulk, yeeted_person, "has smacked this person into someone while tail swinging") // i have no idea how to better word this

		if(collateral_mob == the_hulk) // if the hulk moves wrong and crosses himself
			the_hulk.visible_message("<span class='warning'>[the_hulk] smacks [the_hulk.p_them()]self with [yeeted_person]!</span>", "<span class='userdanger'>You end up smacking [yeeted_person] into yourself!</span>", ignored_mobs = yeeted_person)
			to_chat(yeeted_person, "<span class='userdanger'>[the_hulk] smacks you into [the_hulk.p_them()]self, turning you free!</span>")
			the_hulk.adjustBruteLoss(step)
			return

		yeeted_person.visible_message("<span class='warning'>[the_hulk] swings [yeeted_person] directly into [collateral_mob], sending [collateral_mob.p_them()] flying!</span>", \
			"<span class='userdanger'>You're smacked into [collateral_mob]!</span>", ignored_mobs = collateral_mob)
		to_chat(collateral_mob, "<span class='userdanger'>[the_hulk] swings [yeeted_person] directly into you, sending you flying!</span>")

		collateral_mob.adjustBruteLoss(step*0.5)
		collateral_mob.throw_at(collat_throw_target, round(step * 0.25) + 1, round(step * 0.25) + 1)
		step -= 5
		delay += 5

	step++
	if(step >= HULK_TAILTHROW_STEPS)
		finish_swing(the_hulk, yeeted_person, original_dir)
	else if(step < 0)
		the_hulk.visible_message("<span class='danger'>[the_hulk] loses [the_hulk.p_their()] momentum on [yeeted_person]!</span>", "<span class='warning'>You lose your momentum on swinging [yeeted_person]!</span>", ignored_mobs = yeeted_person)
		to_chat(yeeted_person, "<span class='userdanger'>[the_hulk] loses [the_hulk.p_their()] momentum and lets go of you!</span>")
	else
		addtimer(CALLBACK(src, .proc/swing_loop, the_hulk, yeeted_person, step, original_dir), delay)

/// Time to toss the victim at high speed
/datum/mutation/human/hulk/proc/finish_swing(mob/living/carbon/human/the_hulk, mob/living/carbon/yeeted_person, original_dir)
	if(!yeeted_person || !the_hulk || the_hulk.incapacitated())
		return
	if(get_dist(the_hulk, yeeted_person) > 1 || !isturf(the_hulk.loc) || !isturf(yeeted_person.loc))
		to_chat(the_hulk, "<span class='warning'>You lose your grasp on [yeeted_person]!</span>")
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
	yeeted_person.throw_at(T, 10, 6, the_hulk, TRUE, TRUE)
	log_combat(the_hulk, yeeted_person, "has thrown by tail")

#undef HULK_TAILTHROW_STEPS
