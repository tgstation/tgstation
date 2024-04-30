/obj/item/organ/internal/heart/gland/plasma
	abductor_hint = "effluvium sanguine-synonym emitter. The abductee randomly emits clouds of plasma."
	cooldown_low = 2 MINUTES
	cooldown_high = 3 MINUTES
	icon_state = "slime"
	uses = -1
	mind_control_uses = 1
	mind_control_duration = 80 SECONDS

/obj/item/organ/internal/heart/gland/plasma/activate()
	to_chat(owner, span_warning("You feel bloated."))
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), owner, span_userdanger("A massive stomachache overcomes you.")), 15 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(vomit_plasma)), 20 SECONDS)

/obj/item/organ/internal/heart/gland/plasma/proc/vomit_plasma()
	if(!owner)
		return
	owner.visible_message(span_danger("[owner] vomits a cloud of plasma!"))
	var/turf/open/T = get_turf(owner)
	if(istype(T))
		T.atmos_spawn_air("plasma=50;TEMP=[T20C]")
	owner.vomit()
