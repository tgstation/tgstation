/obj/effect/judicial_mark
	name = "Judicial Mark"
	desc = "You feel standing on this would end poorly."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "judicial_marker"
	pixel_x = -32
	pixel_y = -32
	layer = BELOW_MOB_LAYER

/obj/effect/judicial_mark/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSfastprocess, src)
	INVOKE_ASYNC(src, PROC_REF(do_mark))

/obj/effect/judicial_mark/Destroy(force)
	STOP_PROCESSING(SSfastprocess, src)
	return ..()

/obj/effect/judicial_mark/process(seconds_per_tick)
	for(var/mob/living/marked_mob in range(1, src))
		if(IS_CLOCK(marked_mob))
			continue
		marked_mob.apply_status_effect(STATUS_EFFECT_INTERDICTION)

/obj/effect/judicial_mark/proc/do_mark() //need to do antimagic stuff
	playsound(src, 'sound/magic/clockwork/ratvar_attack.ogg', 50, use_reverb = TRUE)
	sleep(1.6 SECONDS)
	flick("judicial_explosion", src)
	sleep(1.3 SECONDS)
	playsound(src, 'sound/effects/explosion_distant.ogg', 100, use_reverb = TRUE)
	for(var/mob/living/marked_mob in range(1, src))
		if(IS_CLOCK(marked_mob))
			continue
		if(IS_CULTIST(marked_mob)) //lights blood cultists on fire as well as paralyzes for longer
			marked_mob.adjust_fire_stacks(2)
			marked_mob.ignite_mob()
			marked_mob.Paralyze(2 SECONDS, TRUE)
		else
			marked_mob.Paralyze(0.5 SECONDS)
		marked_mob.Knockdown(3 SECONDS)
		marked_mob.apply_damage(30, BURN)
		marked_mob.visible_message(span_warning("[marked_mob] is hit by a judicial explosion!"),
								   span_warning("You feel the ground beneath you heat up!"))
	sleep(0.3 SECONDS)
	qdel(src)
