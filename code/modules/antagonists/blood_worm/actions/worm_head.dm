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
	var/mob/living/basic/blood_worm/worm = target
	var/mob/living/carbon/human/host = worm.host

	var/current_host_head = host.get_bodypart(BODY_ZONE_HEAD)

	host.visible_message(
		message = span_danger("[host]'s head is suddenly consumed by pulsing red flesh!"),
		self_message = span_notice("You extend your worm head from your host."),
		ignored_mobs = owner
	)


	if(istype(current_host_head, /obj/item/bodypart/head/blood_worm))
		retract_head(host, worm) // how to place here retract_head proc?
	else
		extend_head(host, worm) // same but for another
	return ..()

// okay, here will be the actually grow, not the action, but actuall process, which can be called by different ways
/datum/action/cooldown/mob_cooldown/blood_worm/worm_head/proc/extend_head(mob/living/carbon/human/host, mob/living/basic/blood_worm/worm)
	worm.grant_bloodworm_head(host)

	var/obj/item/bodypart/head/blood_worm/new_worm_head_to_attach = new()
	var/current_host_head = target:get_bodypart(BODY_ZONE_HEAD)
	current_host_head:blood_worm_head_growth_animation()
	new_worm_head_to_attach.replace_limb(target, TRUE)
	target.update_body()

// same, but for retract worm head process
/datum/action/cooldown/mob_cooldown/blood_worm/worm_head/proc/retract_head(mob/living/carbon/human/host, mob/living/basic/blood_worm/worm)
	worm.remove_bloodworm_head(host)
