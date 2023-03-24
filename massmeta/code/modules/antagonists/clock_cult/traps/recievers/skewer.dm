/obj/item/clockwork/trap_placer/skewer
	name = "латунный шампур"
	desc = "Латунный шампур с шипами, прикрепленный к механизму выдвижения, приводимому в действие паром."
	icon_state = "brass_skewer_extended"
	result_path = /obj/structure/destructible/clockwork/trap/skewer

/obj/structure/destructible/clockwork/trap/skewer
	name = "латунный шампур"
	desc = "Латунный шампур с шипами, прикрепленный к механизму выдвижения, приводимому в действие паром."
	icon_state = "brass_skewer"
	component_datum = /datum/component/clockwork_trap/skewer
	unwrench_path = /obj/item/clockwork/trap_placer/skewer
	buckle_lying = FALSE
	max_integrity = 40
	atom_integrity = 40
	var/cooldown = 0
	var/extended = FALSE
	var/mutable_appearance/stab_overlay

/obj/structure/destructible/clockwork/trap/skewer/proc/stab()
	if(extended)
		retract()
	if(cooldown > world.time)
		return
	cooldown = world.time + 100
	extended = TRUE
	icon_state = "brass_skewer_extended"
	var/target_stabbed = FALSE
	density = TRUE
	for(var/mob/living/M in get_turf(src))
		if(M.incorporeal_move || (M.movement_type & FLYING))
			continue
		if(buckle_mob(M, TRUE))
			target_stabbed = TRUE
			to_chat(M, span_userdanger("Меня протыкает [src]!"))
			M.emote("agony")
			M.apply_damage(5, BRUTE, BODY_ZONE_CHEST)
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				H.bleed(30)
	if(target_stabbed)
		if(!stab_overlay)
			stab_overlay = mutable_appearance('massmeta/icons/obj/clockwork_objects.dmi', "brass_skewer_pokeybit", layer=ABOVE_MOB_LAYER)
		add_overlay(stab_overlay)

/obj/structure/destructible/clockwork/trap/skewer/unbuckle_mob(mob/living/buckled_mob, force, can_fall = TRUE)
	if(force)
		return ..()
	if(!buckled_mob.break_do_after_checks())
		return
	to_chat(buckled_mob, span_warning("Пытаюсь слезть с [src]."))
	if(do_after(buckled_mob, 50, target=src))
		. = ..()
	else
		to_chat(buckled_mob, span_userdanger("Не вышло слезть с [src]."))

/obj/structure/destructible/clockwork/trap/skewer/post_unbuckle_mob(mob/living/M)
	if(!has_buckled_mobs())
		cut_overlay(stab_overlay)

/obj/structure/destructible/clockwork/trap/skewer/proc/retract()
	extended = FALSE
	icon_state = "brass_skewer"
	density = FALSE
	cut_overlay(stab_overlay)
	for(var/mob/living/M in buckled_mobs)
		unbuckle_mob(M, TRUE)

/datum/component/clockwork_trap/skewer
	takes_input = TRUE

/datum/component/clockwork_trap/skewer/trigger()
	if(!..())
		return
	var/obj/structure/destructible/clockwork/trap/skewer/S = parent
	if(!istype(S))
		return
	S.stab()
