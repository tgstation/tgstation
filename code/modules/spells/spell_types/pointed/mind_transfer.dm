/obj/effect/proc_holder/spell/pointed/mind_transfer
	name = "Mind Transfer"
	desc = "This spell allows the user to switch bodies with a target next to him."
	school = "transmutation"
	charge_max = 600
	clothes_req = FALSE
	invocation = "GIN'YU CAPAN"
	invocation_type = INVOCATION_WHISPER
	range = 1
	cooldown_min = 200 //100 deciseconds reduction per rank
	ranged_mousepointer = 'icons/effects/mouse_pointers/mindswap_target.dmi'
	action_icon_state = "mindswap"
	active_msg = "You prepare to swap minds with a target..."
	/// For how long is the caster stunned for after the spell
	var/unconscious_amount_caster = 40 SECONDS
	/// For how long is the victim stunned for after the spell
	var/unconscious_amount_victim = 40 SECONDS

/obj/effect/proc_holder/spell/pointed/mind_transfer/cast(list/targets, mob/living/user, silent = FALSE)
	if(!targets.len)
		if(!silent)
			to_chat(user, "<span class='warning'>No mind found!</span>")
		return FALSE
	if(targets.len > 1)
		if(!silent)
			to_chat(user, "<span class='warning'>Too many minds! You're not a hive damnit!</span>")
		return FALSE
	if(!can_target(targets[1], user, silent))
		return FALSE

	var/mob/living/victim = targets[1] //The target of the spell whos body will be transferred to.
	var/datum/mind/VM = victim.mind
	if(victim.anti_magic_check(TRUE, FALSE) || VM.has_antag_datum(/datum/antagonist/wizard) || VM.has_antag_datum(/datum/antagonist/cult) || VM.has_antag_datum(/datum/antagonist/changeling) || VM.has_antag_datum(/datum/antagonist/rev) || victim.key[1] == "@")
		if(!silent)
			to_chat(user, "<span class='warning'>[victim.p_their(TRUE)] mind is resisting your spell!</span>")
		return FALSE
	if(istype(victim, /mob/living/simple_animal/hostile/guardian))
		var/mob/living/simple_animal/hostile/guardian/stand = victim
		if(stand.summoner)
			victim = stand.summoner

	//You should not be able to enter one of the most powerful side-antags as a fucking wizard.
	if(istype(victim,/mob/living/simple_animal/hostile/imp/slaughter))
		to_chat(user, "<span class='warning'>The devilish contract doesn't include the 'mind swappable' package, please try again another lifetime.</span>")
		return

	//MIND TRANSFER BEGIN
	var/mob/dead/observer/ghost = victim.ghostize()
	user.mind.transfer_to(victim)

	ghost.mind.transfer_to(user)
	if(ghost.key)
		user.key = ghost.key //have to transfer the key since the mind was not active
	qdel(ghost)
	//MIND TRANSFER END

	//Here we knock both mobs out for a time.
	user.Unconscious(unconscious_amount_caster)
	victim.Unconscious(unconscious_amount_victim)
	SEND_SOUND(user, sound('sound/magic/mandswap.ogg'))
	SEND_SOUND(victim, sound('sound/magic/mandswap.ogg')) // only the caster and victim hear the sounds, that way no one knows for sure if the swap happened
	return TRUE

/obj/effect/proc_holder/spell/pointed/mind_transfer/can_target(atom/target, mob/user, silent)
	. = ..()
	if(!.)
		return FALSE
	if(!isliving(target))
		if(!silent)
			to_chat(user, "<span class='warning'>You can only swap minds with living beings!</span>")
		return FALSE
	if(user == target)
		if(!silent)
			to_chat(user, "<span class='warning'>You can't swap minds with yourself!</span>")
		return FALSE

	var/mob/living/victim = target
	var/t_He = victim.p_they(TRUE)

	if(ismegafauna(victim))
		if(!silent)
			to_chat(user, "<span class='warning'>This creature is too powerful to control!</span>")
		return FALSE
	if(victim.stat == DEAD)
		if(!silent)
			to_chat(user, "<span class='warning'>You don't particularly want to be dead!</span>")
		return FALSE
	if(!victim.key || !victim.mind)
		if(!silent)
			to_chat(user, "<span class='warning'>[t_He] appear[victim.p_s()] to be catatonic! Not even magic can affect [victim.p_their()] vacant mind.</span>")
		return FALSE
	if(user.suiciding)
		if(!silent)
			to_chat(user, "<span class='warning'>You're killing yourself! You can't concentrate enough to do this!</span>")
		return FALSE
	if(istype(victim, /mob/living/simple_animal/hostile/guardian))
		var/mob/living/simple_animal/hostile/guardian/stand = victim
		if(stand.summoner)
			if(stand.summoner == user)
				if(!silent)
					to_chat(user, "<span class='warning'>Swapping minds with your own guardian would just put you back into your own head!</span>")
				return FALSE
	return TRUE
