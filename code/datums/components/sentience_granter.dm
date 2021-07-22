/**
 * ## sentience granter component!
 *
 * component that reproduces the behavior of making an item
 * a single use that makes something sentient
 */
/datum/component/sentience_granter
	///if the sentience candidation is in process
	var/being_used = FALSE
	///the type of mob that can be sentienced with this granter
	var/sentience_type
	///on success, the proc to call
	var/datum/callback/success_callback

/datum/component/sentience_granter/Initialize(sentience_type = SENTIENCE_ORGANIC, success_callback)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.sentience_type = sentience_type
	src.success_callback = success_callback

/datum/component/sentience_granter/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, .proc/on_examine)
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, .proc/on_attack)

/datum/component/sentience_granter/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(COMSIG_PARENT_EXAMINE, COMSIG_ITEM_ATTACK))

/datum/component/sentience_granter/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_notice("You could sentience a lower intelligence creature if you use this on it.")

///signal called by using the item on someone
/datum/component/sentience_granter/proc/on_attack(datum/source, mob/living/target, mob/living/user)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, .proc/attempt_sentience, target, user)

/**
 * ## attempt_sentience()
 *
 * Proc from the attack signal that makes the component try to sentience the mob and consume the item.
 *
 * arguments:
 * * target - target being sentienced
 * * user - person who whapped target with the sentience granter
 */
/datum/component/sentience_granter/proc/attempt_sentience(mob/living/target, mob/living/user)
	//generic checks
	if(being_used || !ismob(target))
		return
	if(!isanimal(target) || target.ckey) //only works on animals that aren't player controlled
		user.balloon_alert(user, "[target] is too intelligent!")
		return
	if(target.stat)
		user.balloon_alert(user, "[target] is dead!")
		return
	var/mob/living/simple_animal/sentience_target = target
	if(sentience_target.sentience_type != sentience_type)
		user.balloon_alert(user, "this won't work on [sentience_target]!")
		return

	user.balloon_alert(user, "offering sentience...")
	being_used = TRUE

	var/list/candidates = pollCandidatesForMob("Do you want to play as [sentience_target.name]?", ROLE_SENTIENCE, ROLE_SENTIENCE, 50, sentience_target, POLL_IGNORE_SENTIENCE_GRANTER) // see poll_ignore.dm
	if(!LAZYLEN(candidates))
		to_chat(user, span_notice("[sentience_target] looks interested for a moment, but then looks back down. Maybe you should try again later."))
		being_used = FALSE
		return
	greet_sentient_mob()
	var/mob/dead/observer/candidate = pick(candidates)
	sentience_target.key = candidate.key
	sentience_target.mind.enslave_mind_to_creator(user)
	SEND_SIGNAL(sentience_target, COMSIG_SIMPLEMOB_SENTIENCEPOTION, user)
	sentience_target.sentience_act()
	greet_sentient_mob(sentience_target, user)
	to_chat(user, span_notice("[sentience_target] accepts [src] and suddenly becomes attentive and aware. It worked!"))
	sentience_target.copy_languages(user)
	if(success_callback)
		success_callback.InvokeAsync(user, sentience_target)
	qdel(src)

/**
 * ## greet_sentient_mob()
 *
 * Just all the messages a sentient mob gets.
 *
 * arguments:
 * * sentience_target - target being given the greeting info
 * * master - person who gave sentience_target sentience
 */
/datum/component/sentience_granter/proc/greet_sentient_mob(mob/living/simple_animal/sentience_target, mob/master)
	to_chat(sentience_target, span_warning("All at once it makes sense: you know what you are and who you are! Self awareness is yours!"))
	to_chat(sentience_target, span_userdanger("You are grateful to be self aware and owe [master.real_name] a great debt. Serve [master.real_name], and assist [master.p_them()] in completing [master.p_their()] goals at any cost."))
	if(sentience_target.flags_1 & HOLOGRAM_1) //Check to see if it's a holodeck creature
		to_chat(sentience_target, span_userdanger("You also become depressingly aware that you are not a real creature, but instead a holoform. Your existence is limited to the parameters of the holodeck."))
