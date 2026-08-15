/// Extends or retracts a worm head. More of a social sign than an actual ability.
/datum/action/cooldown/mob_cooldown/blood_worm/worm_head
	name = "Worm head"
	desc = "Extend or retract worm head on your host"
	button_icon_state = "worm_head"
	cooldown_time = 5 SECONDS
	click_to_activate = FALSE
	check_flags = NONE

/datum/action/cooldown/mob_cooldown/blood_worm/worm_head/Grant(mob/grant_to)
	. = ..()
	if (!owner)
		return
	RegisterSignal(owner, COMSIG_LIVING_HEALTH_UPDATE, PROC_REF(update_status_on_signal))

/datum/action/cooldown/mob_cooldown/blood_worm/worm_head/Remove(remove_from)
	UnregisterSignal(remove_from, COMSIG_LIVING_HEALTH_UPDATE)
	return ..()

/datum/action/cooldown/mob_cooldown/blood_worm/worm_head/IsAvailable(feedback)
	if (!ishuman(owner) && !istype(owner, /mob/living/basic/blood_worm))
		return FALSE

	return ..()

// Activation of ability of grow of the blood worm head
/datum/action/cooldown/mob_cooldown/blood_worm/worm_head/Activate(atom/target) // logic on click
	// this whole shit proce needs to be redone
	var/mob/living/basic/blood_worm/worm = src.target // maybe like that, again? cause there is no worm, there is only target, and src of it is a worm\another being, who called ability
	var/mob/living/carbon/human/host = worm?.host // todo: remove ?

	var/current_host_head = host.get_bodypart(BODY_ZONE_HEAD)

	host.visible_message(
		message = span_danger("[host]'s head is suddenly consumed by pulsing red flesh!"),
		self_message = span_notice("You extend your worm head from your host."),
		ignored_mobs = owner
	)

	// todo: is it workng
	if(istype(current_host_head, /obj/item/bodypart/head/blood_worm))
		retract_head(host, worm) // how to place here retract_head proc?
	else
		extend_head(host, worm) // same but for another
	return ..()

// okay, here will be the actually grow, not the action, but actuall process, which can be called by different ways
/datum/action/cooldown/mob_cooldown/blood_worm/worm_head/proc/extend_head(mob/living/carbon/human/host, mob/living/basic/blood_worm/worm)

	// var/obj/item/bodypart/head/blood_worm/new_worm_head_to_attach = new()
	var/obj/item/bodypart/head/current_host_head = host.get_bodypart(BODY_ZONE_HEAD)
	// todo: animation of grow, sprite is done, but code is not doing animation
	message_admins("attempt to start worm head grow animation")
	if (current_host_head)
		worm.storage_for_head += current_host_head
		message_admins("host head is real, starting worm head grow animation")
		current_host_head.blood_worm_head_growth_animation() // it was supposed to be animation

		// timer
		addtimer(CALLBACK(src, PROC_REF(swap_to_worm_head), host, worm), 2.20 SECONDS)

	message_admins("extend head activation")
	message_admins("worm: [worm]")
	message_admins("host: [host]")
	// store the head on the worm mob
	// worm.storage_for_head += current_host_head
	message_admins("worm.storage_for_head: [worm.storage_for_head]")

	// new_worm_head_to_attach.replace_limb(host, TRUE) // this also moves the content from old head, to new head, yeah?
	// host.update_body()

// proc for swaping to worm head, when timer(so animation can animate) will finish
/datum/action/cooldown/mob_cooldown/blood_worm/worm_head/proc/swap_to_worm_head(mob/living/carbon/human/host, mob/living/basic/blood_worm/worm)
	var/obj/item/bodypart/head/blood_worm/new_worm_head_to_attach = new()
	new_worm_head_to_attach.replace_limb(host, TRUE)
	host.update_body()

// same, but for retract worm head process
/datum/action/cooldown/mob_cooldown/blood_worm/worm_head/proc/retract_head(mob/living/carbon/human/host, mob/living/basic/blood_worm/worm)
	var/obj/item/bodypart/head/stored_head = worm.storage_for_head[1]

	message_admins("before worm.storage_for_head: [worm.storage_for_head]")
	stored_head.replace_limb(host, TRUE)
	worm.storage_for_head -= stored_head
	message_admins("after worm.storage_for_head: [worm.storage_for_head]")

	host.update_body()
