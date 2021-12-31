/obj/item/organ/heart/gland/plasma
	true_name = "effluvium sanguine-synonym emitter. Makes the abductee emit a disrupting psychic wave every so often. This will either stun, cause hallucinations or deal random brain damage to people nearby"
	cooldown_low = 1200
	cooldown_high = 1800
	icon_state = "slime"
	uses = -1
	mind_control_uses = 1
	mind_control_duration = 800

/obj/item/organ/heart/gland/plasma/activate()
	to_chat(owner, span_warning("You feel bloated."))
	addtimer(CALLBACK(GLOBAL_PROC, .proc/to_chat, owner, span_userdanger("A massive stomachache overcomes you.")), 150)
	addtimer(CALLBACK(src, .proc/vomit_plasma), 200)

/obj/item/organ/heart/gland/plasma/proc/vomit_plasma()
	if(!owner)
		return
	owner.visible_message(span_danger("[owner] vomits a cloud of plasma!"))
	var/turf/open/T = get_turf(owner)
	if(istype(T))
		T.atmos_spawn_air("plasma=50;TEMP=[T20C]")
	owner.vomit()
