/// Component that lets us space kidnap people as the voidwalker with our HAAAADS
/datum/component/space_kidnap
	/// How long does it take to kidnap them?
	var/kidnap_time = 6 SECONDS
	/// Are we kidnapping right now?
	var/kidnapping = FALSE

/datum/component/space_kidnap/Initialize(...)
	if(!ishuman(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(try_kidnap))

/datum/component/space_kidnap/proc/try_kidnap(mob/living/parent, atom/target)
	SIGNAL_HANDLER

	if(!isliving(target))
		return

	var/mob/living/victim = target

	if(victim.stat == DEAD)
		target.balloon_alert(parent, "is dead!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(!victim.incapacitated)
		return

	if(!isspaceturf(get_turf(target)))
		target.balloon_alert(parent, "not in space!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(!kidnapping)
		INVOKE_ASYNC(src, PROC_REF(kidnap), parent, target)
		return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/space_kidnap/proc/kidnap(mob/living/parent, mob/living/victim)
	victim.Paralyze(kidnap_time) //so they don't get up if we already got em
	var/obj/particles = new /obj/effect/abstract/particle_holder (victim, /particles/void_kidnap)
	kidnapping = TRUE

	if(do_after(parent, kidnap_time, victim, extra_checks = victim.incapacitated))
		take_them(victim)

	qdel(particles)
	kidnapping = FALSE

/datum/component/space_kidnap/proc/take_them(mob/living/victim)
	if(ishuman(victim))
		var/mob/living/carbon/human/hewmon = victim
		hewmon.gain_trauma(/datum/brain_trauma/voided)

	victim.flash_act(INFINITY, override_blindness_check = TRUE, visual = TRUE, type = /atom/movable/screen/fullscreen/flash/black)
	new /obj/effect/temp_visual/circle_wave/unsettle(get_turf(victim))

	if(!SSmapping.lazy_load_template(LAZY_TEMPLATE_KEY_VOIDWALKER_VOID) || !GLOB.voidwalker_void.len)
		victim.forceMove(get_random_station_turf())
		victim.heal_overall_damage(brute = 80, burn = 20)
		CRASH("[victim] was instantly dumped after being voidwalker kidnapped due to a missing landmark!")
	else
		victim.heal_and_revive(90)
		victim.adjustOxyLoss(-100, FALSE)

		var/obj/wisp = new /obj/effect/wisp_mobile (get_turf(pick(GLOB.voidwalker_void)))
		victim.forceMove(wisp)
		succesfully_kidnapped()

/datum/component/space_kidnap/proc/succesfully_kidnapped(mob/living/carbon/human/kidnappee)
	SEND_SIGNAL(parent, COMSIG_VOIDWALKER_SUCCESFUL_KIDNAP, kidnappee)
