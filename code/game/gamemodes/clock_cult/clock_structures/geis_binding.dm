//Used by the Geis scripture to hold its target in place
/obj/structure/destructible/clockwork/geis_binding
	name = "glowing ring"
	desc = "A flickering, glowing purple ring around a target."
	clockwork_desc = "A binding ring around a target, preventing them from taking action while they're being converted."
	max_integrity = 25
	light_range = 2
	light_power = 0.8
	light_color = "#AF0AAF"
	anchored = FALSE
	density = FALSE
	immune_to_servant_attacks = TRUE
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "geisbinding_full"
	break_message = null
	break_sound = 'sound/magic/repulse.ogg'
	debris = list()
	can_buckle = TRUE
	buckle_lying = 0
	var/mob_layer = MOB_LAYER

/obj/structure/destructible/clockwork/geis_binding/Initialize(mapload, obj/item/clockwork/slab/the_slab)
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/structure/destructible/clockwork/geis_binding/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/structure/destructible/clockwork/geis_binding/examine(mob/user)
	icon_state = "geisbinding_full"
	..()
	icon_state = "geisbinding"

/obj/structure/destructible/clockwork/geis_binding/process()
	if(LAZYLEN(buckled_mobs))
		for(var/V in buckled_mobs)
			var/mob/living/L = V
			if(is_servant_of_ratvar(L)) //servants are freed automatically
				take_damage(obj_integrity)
				return
	var/tick_damage = 1
	if(!is_servant_of_ratvar(pulledby))
		tick_damage++
	take_damage(tick_damage, sound_effect = FALSE)
	playsound(src, 'sound/effects/empulse.ogg', tick_damage * 20, TRUE)

/obj/structure/destructible/clockwork/geis_binding/attack_hand(mob/living/user)
	return

/obj/structure/destructible/clockwork/geis_binding/emp_act(severity)
	new /obj/effect/temp_visual/emp(loc)
	qdel(src)

/obj/structure/destructible/clockwork/geis_binding/post_buckle_mob(mob/living/M)
	..()
	if(M.buckled == src)
		desc = "A flickering, glowing purple ring around [M]."
		clockwork_desc = "A binding ring around [M], preventing [M.p_them()] from taking action while [M.p_theyre()] being converted."
		icon_state = "geisbinding"
		mob_layer = M.layer
		layer = M.layer - 0.01
		add_overlay(mutable_appearance('icons/effects/clockwork_effects.dmi', "geisbinding_top", M.layer + 0.01))
		for(var/obj/item/I in M.held_items)
			M.dropItemToGround(I)
		for(var/i in M.get_empty_held_indexes())
			var/obj/item/geis_binding/B = new(M)
			M.put_in_hands(B, i)
		M.regenerate_icons()
		M.visible_message("<span class='warning'>A [name] appears around [M]!</span>", "<span class='warning'>A [name] appears around you!</span>")
		repair_and_interrupt()
	else
		var/obj/effect/temp_visual/ratvar/geis_binding/G = new /obj/effect/temp_visual/ratvar/geis_binding(M.loc)
		var/obj/effect/temp_visual/ratvar/geis_binding/T = new /obj/effect/temp_visual/ratvar/geis_binding/top(M.loc)
		G.layer = mob_layer - 0.01
		T.layer = mob_layer + 0.01
		G.alpha = alpha
		T.alpha = alpha
		animate(G, transform = matrix()*2, alpha = 0, time = 8, easing = EASE_OUT)
		animate(T, transform = matrix()*2, alpha = 0, time = 8, easing = EASE_OUT)
		M.visible_message("<span class='warning'>[src] snaps into glowing pieces and dissipates!</span>")
		for(var/obj/item/geis_binding/GB in M.held_items)
			M.dropItemToGround(GB, TRUE)

/obj/structure/destructible/clockwork/geis_binding/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src, 'sound/effects/empulse.ogg', 50, 1)

/obj/structure/destructible/clockwork/geis_binding/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(.)
		update_icon()

/obj/structure/destructible/clockwork/geis_binding/update_icon()
	alpha = min(255 * ((obj_integrity/max_integrity) + 0.2) , 255)

/obj/structure/destructible/clockwork/geis_binding/proc/repair_and_interrupt()
	obj_integrity = max_integrity
	update_icon()
	for(var/m in buckled_mobs)
		var/mob/living/L = m
		if(L)
			L.Stun(130, 1, 1) //basically here to act as a mute for borgs
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				C.silent += 7
	visible_message("<span class='sevtug'>[src] flares brightly!</span>")
	var/obj/effect/temp_visual/ratvar/geis_binding/G1 = new /obj/effect/temp_visual/ratvar/geis_binding(loc)
	var/obj/effect/temp_visual/ratvar/geis_binding/G2 = new /obj/effect/temp_visual/ratvar/geis_binding(loc)
	var/obj/effect/temp_visual/ratvar/geis_binding/T1 = new /obj/effect/temp_visual/ratvar/geis_binding/top(loc)
	var/obj/effect/temp_visual/ratvar/geis_binding/T2 = new /obj/effect/temp_visual/ratvar/geis_binding/top(loc)
	G1.layer = mob_layer - 0.01
	G2.layer = mob_layer - 0.01
	T1.layer = mob_layer + 0.01
	T2.layer = mob_layer + 0.01
	animate(G1, pixel_y = pixel_y + 9, alpha = 0, time = 8, easing = EASE_IN)
	animate(G2, pixel_y = pixel_y - 9, alpha = 0, time = 8, easing = EASE_IN)
	animate(T1, pixel_y = pixel_y + 9, alpha = 0, time = 8, easing = EASE_IN)
	animate(T2, pixel_y = pixel_y - 9, alpha = 0, time = 8, easing = EASE_IN)

/obj/structure/destructible/clockwork/geis_binding/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(buckled_mob != user)
		return ..()

/obj/item/geis_binding
	name = "glowing ring"
	desc = "A flickering ring preventing you from holding items."
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "geisbinding_full"
	flags_1 = NODROP_1|ABSTRACT_1|DROPDEL_1

/obj/item/geis_binding/pre_attackby(atom/target, mob/living/user, params)
	return FALSE
