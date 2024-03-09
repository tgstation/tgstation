/datum/action/cooldown/mob_cooldown/bot/honk_stun
	name = "Honk Stun"
	desc = "Spread cheer and joy all around!"
	button_icon = 'icons/obj/art/horn.dmi'
	button_icon_state = "bike_horn"
	cooldown_time = 10 SECONDS
	///is our owner a honkbot?
	var/datum/callback/honkbot_callback

/datum/action/cooldown/mob_cooldown/bot/honk_stun/Grant(mob/grant_to)
	. = ..()
	if(isnull(owner))
		return
	if(!istype(owner, /mob/living/basic/bot/honkbot))
		return
	honkbot_callback = CALLBACK(owner, TYPE_PROC_REF(/mob/living/basic/bot/honkbot, set_attacking_state))

/datum/action/cooldown/mob_cooldown/bot/honk_stun/Activate(mob/living/current_target)
	if(!istype(current_target))
		return

	playsound(owner, 'sound/items/AirHorn.ogg', 100, TRUE, -1)
	honkbot_callback?.Invoke()
	if(!ishuman(current_target))
		current_target.Paralyze(8 SECONDS)
		current_target.set_stutter(40 SECONDS)
		if(owner.client)
			StartCooldown()
		return TRUE

	current_target.set_stutter(40 SECONDS)
	if(!HAS_TRAIT(current_target, TRAIT_DEAF))
		var/obj/item/organ/internal/ears/target_ears = current_target.get_organ_slot(ORGAN_SLOT_EARS)
		target_ears?.adjustEarDamage(0, 5)
	current_target.set_jitter_if_lower(100 SECONDS)
	current_target.Paralyze(6 SECONDS)

	log_combat(owner, current_target, "honked")

	current_target.visible_message(
		span_danger("[owner] honks [current_target]!"), \
		span_userdanger("[owner] honks you!"), \
	)
	if(owner.client)
		StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/bot/honk_stun/Destroy()
	. = ..()
	honkbot_callback = null


/datum/action/cooldown/mob_cooldown/bot/handcuff_target
	name = "Fake handcuffs"
	desc = "Prank your victim!"
	button_icon = 'icons/obj/restraints.dmi'
	button_icon_state = "cuff"
	cooldown_time = 10 SECONDS
	///cuffing delay
	var/cuff_duration = 6 SECONDS
	///type of cuffs we will be using
	var/cuff_type = /obj/item/restraints/handcuffs/cable/zipties/fake
	///is our owner a honkbot?
	var/datum/callback/honkbot_callback

/datum/action/cooldown/mob_cooldown/bot/handcuff_target/Grant(mob/grant_to)
	. = ..()
	if(isnull(owner))
		return
	if(!istype(owner, /mob/living/basic/bot/honkbot))
		return
	honkbot_callback = CALLBACK(owner, TYPE_PROC_REF(/mob/living/basic/bot/honkbot, post_cuffing))

/datum/action/cooldown/mob_cooldown/bot/handcuff_target/Activate(atom/current_target)
	if(!ishuman(current_target))
		return FALSE

	var/mob/living/carbon/human/human_target = current_target
	if(human_target.handcuffed)
		owner.balloon_alert(human_target, "already cuffed!")
		return FALSE

	playsound(owner, 'sound/weapons/cablecuff.ogg', 30, TRUE)
	human_target.visible_message(span_danger("[owner] is trying to put zipties on [current_target]!"),\
		span_danger("[owner] is trying to put zipties on you!"))
	INVOKE_ASYNC(src, PROC_REF(start_cuffing), human_target)
	StartCooldown()
	return TRUE

/datum/action/cooldown/mob_cooldown/bot/handcuff_target/proc/start_cuffing(mob/living/carbon/human_target)
	if(!do_after(owner, cuff_duration, human_target))
		return
	human_target.set_handcuffed(new cuff_type(human_target))
	human_target.update_handcuffed()
