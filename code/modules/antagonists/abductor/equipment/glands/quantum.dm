/obj/item/organ/internal/heart/gland/quantum
	abductor_hint = "quantic de-observation matrix. Periodically links with a random person in view, then the abductee later swaps positions with that person."
	cooldown_low = 150
	cooldown_high = 150
	uses = -1
	icon_state = "emp"
	mind_control_uses = 2
	mind_control_duration = 1200
	var/mob/living/carbon/entangled_mob

/obj/item/organ/internal/heart/gland/quantum/activate()
	if(entangled_mob)
		return
	for(var/mob/M in oview(owner, 7))
		if(!iscarbon(M))
			continue
		entangled_mob = M
		addtimer(CALLBACK(src, PROC_REF(quantum_swap)), rand(1 MINUTES, 4 MINUTES))
		return

/obj/item/organ/internal/heart/gland/quantum/proc/quantum_swap()
	if(QDELETED(entangled_mob))
		entangled_mob = null
		return
	var/turf/T = get_turf(owner)
	do_teleport(owner, get_turf(entangled_mob), null, channel = TELEPORT_CHANNEL_QUANTUM)
	do_teleport(entangled_mob, T, null, channel = TELEPORT_CHANNEL_QUANTUM)
	to_chat(owner, span_warning("You suddenly find yourself somewhere else!"))
	to_chat(entangled_mob, span_warning("You suddenly find yourself somewhere else!"))
	if(!active_mind_control) //Do not reset entangled mob while mind control is active
		entangled_mob = null

/obj/item/organ/internal/heart/gland/quantum/mind_control(command, mob/living/user)
	if(..())
		if(entangled_mob && ishuman(entangled_mob) && (entangled_mob.stat < DEAD))
			to_chat(entangled_mob, span_userdanger("You suddenly feel an irresistible compulsion to follow an order..."))
			to_chat(entangled_mob, span_mind_control("[command]"))
			var/atom/movable/screen/alert/mind_control/mind_alert = entangled_mob.throw_alert(ALERT_MIND_CONTROL, /atom/movable/screen/alert/mind_control)
			mind_alert.command = command
			message_admins("[key_name(owner)] mirrored an abductor mind control message to [key_name(entangled_mob)]: [command]")
			user.log_message("mirrored an abductor mind control message to [key_name(entangled_mob)]: [command]", LOG_GAME)
			update_gland_hud()

/obj/item/organ/internal/heart/gland/quantum/clear_mind_control()
	if(active_mind_control)
		to_chat(entangled_mob, span_userdanger("You feel the compulsion fade, and you completely forget about your previous orders."))
		entangled_mob.clear_alert(ALERT_MIND_CONTROL)
	..()
