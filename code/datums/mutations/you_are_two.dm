

/**
 * ## you are two!
 *
 * Mutation that makes you control two bodies at once. The other the_other will mimick your actions.
 * You have an ability to swap between which body you are directly controlling at any time.
 * If one body dies, the other will too. Careful!
 * If you attack a target, the other will attack it as well IF it is in range.
 */
/datum/mutation/human/you_are_two
	name = "\"You Are Two\""
	desc = "A mutational opposite of a split personality. Instead of many minds in habiting one body, it is one mind inhabiting multiple bodies."
	difficulty = 10 //teensie bit rarer
	quality = NEGATIVE //Like HARS, you can do some interesting and good things with it, but for the most part this is a bad thing.
	text_gain_indication = "<span class='danger'>Your mind flickers between states. You feel two.</span>"
	text_lose_indication = "<span class='danger'>You feel an immense pain as if you are ripped away from half of... something else? You are one again!</span>"
	power = /obj/effect/proc_holder/spell/self/you_are_the_other
	var/mob/living/carbon/human/the_other

/datum/mutation/human/you_are_two/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	the_other = new(owner.loc)
	owner.client.prefs.copy_to(the_other, antagonist = (LAZYLEN(player.mind.antag_datums) > 0), is_latejoiner = FALSE)
	hook_signals(the_other)

/datum/mutation/human/you_are_two/on_losing(mob/living/carbon/human/owner)
	. = ..()
	unhook_signals(the_other)
	the_other.say(pick("AAAAAAAAAAAAA-", "THE PAI-", "HEL-", "I DON'T FEEL SO GOO-", "NO, WAI-", "PLEAS-", "OH GO-"))
	the_other.gib(TRUE, TRUE, TRUE)//nothing left
	if(owner.health > 0)
		owner.adjustBruteLoss(health - 1) //set to barely out of crit
	else
		owner.adjustBruteLoss(30) //just set deeper into crit


/datum/mutation/human/you_are_two/proc/hook_signals(mob/living/carbon/human/the_one)
	RegisterSignal(the_one, COMSIG_MOVABLE_PRE_MOVE, .proc/on_pre_move)

///called when the one moves
/datum/mutation/human/you_are_two/proc/on_pre_move(datum/the_one, atom/newloc)
	SIGNAL_HANDLER
	var/attempted_movement_direction = get_dir(the_one, newloc)
	var/turf/attempted_movement_destination = get_step(the_other, attempted_movement_direction)
	the_other.Move(attempted_movement_destination)

/datum/mutation/human/you_are_two/proc/unhook_signals(mob/living/carbon/human/the_other)
	UnregisterSignal(the_one, list(COMSIG_MOVABLE_PRE_MOVE))

/obj/effect/proc_holder/spell/self/you_are_the_other
	name = "\"You are the other\""
	desc = "Moves your main focus to your other self, for more fine tuned interactions."
	charge_max = 50
	cooldown_min = 50
	clothes_req = FALSE
	action_icon_state = "declaration"

/obj/effect/proc_holder/spell/pointed/declare_evil/cast(list/targets, mob/living/carbon/human/user, silent = FALSE)
	if(!ishuman(user))
		return FALSE
	var/datum/mutation/human/you_are_two/mutation = user.dna.check_mutation(YOU_ARE_TWO)

	balloon_alert(user, "body swapped")

	//UNHOOK SIGNALS
	mutation.unhook_signals(the_other)
	//TRANSFER
	user.mind.transfer_to(mutation.the_other)
	the_other = user //switch the new the_other target to your old one
	//HOOK SIGNALS INTO NEW COPY
	mutation.hook_signals(the_other)
