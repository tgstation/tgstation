
/**
 * ## todo list!
 *
 * Move all mutation add effects to "enable mutation" and the same for "disable mutation"
 * Trait for the other to be occupied, basically
 */



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
	///the copy of you created by the mutation.
	var/mob/living/carbon/human/the_other
	///as client stores movement delay, we unfortunately have to keep record of delay here instead.
	var/other_movement_delay
	///if you can earn the special achievement, enabled when the shuttle docks so you can't cheese the achievement.
	var/achievement_unlock_viable = FALSE

/datum/mutation/human/you_are_two/on_acquiring(mob/living/carbon/human/owner)
	. = ..()
	if(.)
		return
	the_other = new(owner.loc)
	owner.client.prefs.copy_to(the_other, antagonist = (LAZYLEN(owner.mind.antag_datums) > 0), is_latejoiner = FALSE)

	//reverses the name, if someone is trying to be a wise guy by starting with a name that gets reversed into a banned word "Floor"
	//it will turn into the reverse of "Wise Guy"
	var/other_name = reject_bad_name(reverse_text(lowertext(the_other.name))) || reverse_text("wisE guY")

	the_other.fully_replace_character_name(the_other.name, other_name)
	hook_signals()
	///this is unrelated to the other and so isn't in hook_signals
	RegisterSignal(SSdcs, COMSIG_GLOB_EMERGENCY_SHUTTLE_DOCKED, .proc/on_emergency_shuttle_dock)

/// called from emergency shuttle docking
/datum/mutation/human/you_are_two/proc/on_emergency_shuttle_dock()
	SIGNAL_HANDLER
	achievement_unlock_viable = TRUE

/datum/mutation/human/you_are_two/on_losing(mob/living/carbon/human/owner)
	. = ..()
	unhook_signals()
	var/cry_for_help = pick("AAAAAAAAAAAAA!!", "THE PAIN!!", "HELP!!", "I DON'T FEEL SO GOOD!!", "NO, WAIT!!", "PLEASE!!", "OH GOD!!")
	owner.say(cry_for_help)
	cry_for_help = copytext(cry_for_help, 1, length(cry_for_help)-2)
	cry_for_help += "-"
	the_other.say(cry_for_help)
	the_other.gib(TRUE, TRUE, TRUE)//nothing left
	if(owner.health > 0)
		owner.adjustBruteLoss(owner.health - 1) //set to barely out of crit
	else
		owner.adjustBruteLoss(30) //just set deeper into crit

/datum/mutation/human/you_are_two/proc/hook_signals()
	//signals for the other
	RegisterSignal(the_other, COMSIG_CARBON_GAIN_MUTATION, .proc/mutation_added)
	//signals for both
	RegisterSignal(owner, COMSIG_MOB_STATCHANGE, .proc/the_one_stat_change)
	RegisterSignal(the_other, COMSIG_MOB_STATCHANGE, .proc/the_other_stat_change)
	//signals for the one
	RegisterSignal(owner, COMSIG_MOB_FACED_ATOM, .proc/on_face_atom)
	RegisterSignal(owner, COMSIG_MOB_CLIENT_PRE_MOVE, .proc/on_pre_move)
	RegisterSignal(owner, COMSIG_MOB_SAY, .proc/on_say)
	RegisterSignal(owner, COMSIG_MOB_CLICKON, .proc/on_clickon)
	RegisterSignal(owner, COMSIG_COMBAT_MODE_TOGGLED, .proc/on_combat_mode_toggled)
	RegisterSignal(owner, COMSIG_LIVING_SELECTED_ZONE, .proc/on_zone_selected)
	RegisterSignal(owner, COMSIG_MOB_EMOTE, .proc/on_emote)
	//not a signal but should happen here anyway so sure
	ADD_TRAIT(TRAIT_RESERVED_BODY, GENETIC_MUTATION)

/datum/mutation/human/you_are_two/proc/unhook_signals()
	UnregisterSignal(the_other, list(COMSIG_CARBON_GAIN_MUTATION, COMSIG_MOB_STATCHANGE))
	UnregisterSignal(owner, list(
		COMSIG_MOB_STATCHANGE,
		COMSIG_MOB_FACED_ATOM,
		COMSIG_MOB_CLIENT_PRE_MOVE,
		COMSIG_MOB_SAY,
		COMSIG_MOB_CLICKON,
		COMSIG_COMBAT_MODE_TOGGLED,
		COMSIG_MOB_EMOTE
	))

/// Signal to increase burden_level (see update_burden proc) if a mutation is added
/datum/mutation/human/burdened/proc/mutation_added(datum/source, datum/mutation/human/mutation_type, class)
	SIGNAL_HANDLER

	. = COMPONENT_ABORT_MUTATION
	owner.dna.add_mutation(mutation_type)

///called when stat update for the one
/datum/mutation/human/you_are_two/proc/the_one_stat_change(datum/source, new_stat)
	SIGNAL_HANDLER
	var/last_stat = owner.stat
	if(new_stat == DEAD)
		if(the_other.stat != DEAD)
			the_other.death()
	else if(last_stat == DEAD)
		revive_one_of_them(the_other)

///called when stat update for the other
/datum/mutation/human/you_are_two/proc/the_other_stat_change(datum/source, new_stat)
	SIGNAL_HANDLER
	var/last_stat = the_other.stat
	if(new_stat == DEAD)
		if(owner.stat != DEAD)
			owner.death()
	else if(last_stat == DEAD)
		revive_one_of_them(owner)

/datum/mutation/human/you_are_two/proc/revive_one_of_them(mob/living/reviving)
	var/genetic_punishment = the_other.health < HEALTH_THRESHOLD_DEAD
	reviving.revive(full_heal = genetic_punishment)
	if(genetic_punishment)//we need the person in question revived at all costs so we'll apply some really annoying damage type to encourage fixing both bodies
		reviving.visible_message("<span class='notice'>[src]'s wounds close, leaving severe genetic imperfections in their place!</span>")
		reviving.adjustCloneLoss(70)

///called when the one faces an atom
/datum/mutation/human/you_are_two/proc/on_face_atom(datum/source, new_dir)
	SIGNAL_HANDLER
	the_other.dir = new_dir

#define MOVEMENT_DELAY_BUFFER 0.75
#define MOVEMENT_DELAY_BUFFER_DELTA 1.25

///called when the one moves
/datum/mutation/human/you_are_two/proc/on_pre_move(datum/source, atom/newloc)
	SIGNAL_HANDLER
	if(world.time < other_movement_delay)
		return FALSE
	var/attempted_movement_direction = get_dir(owner, newloc)
	var/turf/attempted_movement_destination = get_step(the_other, attempted_movement_direction)

	var/old_move_delay = other_movement_delay
	other_movement_delay = world.time + world.tick_lag //this is here because Move() can now be called mutiple times per tick
	var/add_delay = the_other.cached_multiplicative_slowdown
	the_other.set_glide_size(DELAY_TO_GLIDE_SIZE(add_delay * ( (NSCOMPONENT(attempted_movement_direction) && EWCOMPONENT(attempted_movement_direction)) ? 2 : 1 ) ))
	if(old_move_delay + (add_delay*MOVEMENT_DELAY_BUFFER_DELTA) + MOVEMENT_DELAY_BUFFER > world.time)
		other_movement_delay = old_move_delay
	else
		other_movement_delay = world.time


	the_other.Move(attempted_movement_destination)

#undef MOVEMENT_DELAY_BUFFER
#undef MOVEMENT_DELAY_BUFFER_DELTA

///called when the one talks
/datum/mutation/human/you_are_two/proc/on_say(mob/speaking, speech_args)
	SIGNAL_HANDLER
	//fucking run_emote sleeping
	INVOKE_ASYNC(
		the_other,
		/atom/movable.proc/say,
		speech_args[1],
		speech_args[2],
		speech_args[3],
		speech_args[4],
		speech_args[5],
		speech_args[6],
		speech_args[7]
	)

///called whenever the one clicks on an atom
/datum/mutation/human/you_are_two/proc/on_clickon(datum/source, atom/target, params)
	SIGNAL_HANDLER
	if(isliving(target) && get_dist(the_other, target) <= 1)
		if(target == the_other)
			target = owner
		INVOKE_ASYNC(the_other, /mob.proc/ClickOn, target, params)

///called whenever the one selects a new zone
/datum/mutation/human/you_are_two/proc/on_zone_selected(datum/source, new_zone)
	SIGNAL_HANDLER
	var/atom/movable/screen/zone_sel/selector = the_other.hud_used.zone_select
	selector.set_selected_zone(new_zone, the_other)

///called whenever the one toggles combat mode
/datum/mutation/human/you_are_two/proc/on_combat_mode_toggled(datum/source, new_mode)
	SIGNAL_HANDLER
	the_other.set_combat_mode(new_mode, silent = TRUE)

///called whenever the one emotes
/datum/mutation/human/you_are_two/proc/on_emote(datum/source, datum/emote/emote, act, type_override, params, intentional)
	SIGNAL_HANDLER
	INVOKE_ASYNC(
		emote,
		/datum/emote.proc/run_emote,
		the_other,
		params,
		type_override,
		intentional,
	)

/obj/effect/proc_holder/spell/self/you_are_the_other
	name = "\"You are the other\""
	desc = "Moves your main focus to your other self, for more fine tuned interactions."
	action_icon = 'icons/mob/actions/actions_genetic.dmi'
	action_icon_state = "you_are_the_other"
	charge_max = 50
	cooldown_min = 50
	clothes_req = FALSE
	stat_allowed = TRUE

/obj/effect/proc_holder/spell/self/you_are_the_other/cast(list/targets, mob/living/carbon/human/user, silent = FALSE)
	if(!ishuman(user))
		return FALSE
	var/datum/mutation/human/you_are_two/mutation = user.dna.check_mutation(YOU_ARE_TWO)
	//UNHOOK SIGNALS (this must come first as there are signals for losing mutations)
	mutation.unhook_signals()
	//TRANSFER MUTATIONS + TRAUMAS
	for(var/datum/mutation/human/mut in user.dna.mutations)
		mut.disable_mutation(user)
		mut.enable_mutation(mutation.the_other)
	//trauma transfer code here
	//TRANSFER CONTROL TO NEW BODY
	user.mind.transfer_to(mutation.the_other)
	mutation.the_other = user //switch the new the_other target to your old one
	//HOOK SIGNALS INTO NEW COPY
	mutation.hook_signals()

	balloon_alert(user, "body swapped")
