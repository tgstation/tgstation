/*
 * A component to stun and cuff targets
 */
/datum/component/stun_n_cuff
	/// mobs we cannot stun nor cuff
	var/list/blacklist_mobs
	///sound to play when stunning
	var/stun_sound
	///time to stun the target for
	var/stun_timer
	///time it takes for us to handcuff the target
	var/handcuff_timer
	///callback after we have stunned someone
	var/datum/callback/post_stun_callback
	///callback after we have arrested someone
	var/datum/callback/post_arrest_callback
	///time until we can stun again
	var/stun_cooldown_timer
	///type of cuffs we use
	var/handcuff_type
	///cooldown until we can stun again
	COOLDOWN_DECLARE(stun_cooldown)

/datum/component/stun_n_cuff/Initialize(list/blacklist_mobs = list(),
	stun_sound = 'sound/items/weapons/egloves.ogg',
	stun_timer = 8 SECONDS,
	handcuff_timer = 4 SECONDS,
	stun_cooldown_timer = 10 SECONDS,
	handcuff_type = /obj/item/restraints/handcuffs/cable/zipties/used,
	post_stun_callback,
	post_arrest_callback,
	)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.blacklist_mobs = blacklist_mobs
	src.stun_sound = stun_sound
	src.stun_timer = stun_timer
	src.handcuff_timer = handcuff_timer
	src.handcuff_type = handcuff_type
	src.stun_cooldown_timer = stun_cooldown_timer
	src.post_stun_callback = post_stun_callback
	src.post_arrest_callback = post_arrest_callback


/datum/component/stun_n_cuff/RegisterWithParent()
	RegisterSignal(parent, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_unarmed_attack))

/datum/component/stun_n_cuff/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_HOSTILE_PRE_ATTACKINGTARGET)
	REMOVE_TRAIT(parent, TRAIT_MOB_BREEDER, REF(src))
	post_stun_callback = null
	post_arrest_callback = null

/datum/component/stun_n_cuff/proc/on_unarmed_attack(mob/living/source, atom/target)
	SIGNAL_HANDLER

	if(target == source || !iscarbon(target))
		return NONE

	if(is_type_in_typecache(target, blacklist_mobs))
		return NONE

	var/mob/living/carbon/living_target = target
	if(living_target.IsParalyzed())
		INVOKE_ASYNC(src, PROC_REF(cuff_target), target)
	else
		stun_target(target)

	return COMPONENT_HOSTILE_NO_ATTACK

/datum/component/stun_n_cuff/proc/cuff_target(mob/living/carbon/human_target)
	if(human_target.handcuffed)
		var/mob/living/living_parent = parent
		living_parent.balloon_alert(human_target, "already cuffed!")
		return

	playsound(parent, 'sound/items/weapons/cablecuff.ogg', 30, TRUE)
	human_target.visible_message(span_danger("[parent] is trying to put zipties on [human_target]!"),\
		span_danger("[parent] is trying to put zipties on you!"))

	if(!do_after(parent, handcuff_timer, human_target))
		return
	human_target.set_handcuffed(new handcuff_type(human_target))
	post_arrest_callback?.Invoke(human_target)

/datum/component/stun_n_cuff/proc/stun_target(mob/living/carbon/human_target)
	if(!COOLDOWN_FINISHED(src, stun_cooldown))
		return
	playsound(parent, stun_sound, 50, TRUE)
	human_target.Paralyze(stun_timer)
	human_target.set_stutter(40 SECONDS)
	log_combat(parent, human_target, "honked")

	human_target.visible_message(
		span_danger("[parent] stuns [human_target]!"), \
		span_userdanger("[parent] stuns you!"), \
	)
	COOLDOWN_START(src, stun_cooldown, stun_cooldown_timer)
	post_stun_callback?.Invoke(human_target)
