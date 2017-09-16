//Used by the Geis scripture to hold its target in place
/obj/structure/destructible/clockwork/geis_binding
	name = "glowing ring"
	desc = "A flickering, glowing purple ring around a target."
	clockwork_desc = "A binding ring around a target, preventing them from taking action."
	max_integrity = 20
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
	var/last_mob_health = 0
	var/apply_time = 0

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
	var/tick_damage = 1
	if(locate(/obj/effect/clockwork/sigil/submission) in loc)
		tick_damage *= 0.5
	if(LAZYLEN(buckled_mobs))
		for(var/V in buckled_mobs)
			var/mob/living/L = V
			if(is_servant_of_ratvar(L)) //servants are freed automatically
				take_damage(obj_integrity)
				return
			if(last_mob_health > L.health)
				tick_damage += last_mob_health - L.health
			last_mob_health = L.health
			if(L.layer != mob_layer)
				mob_layer = L.layer
				layer = mob_layer - 0.01
				cut_overlays()
				add_overlay(mutable_appearance('icons/effects/clockwork_effects.dmi', "geisbinding_top", mob_layer + 0.01))
			break
	take_damage(tick_damage, sound_effect = FALSE)
	playsound(src, 'sound/effects/empulse.ogg', tick_damage * 40, TRUE, -4)

/obj/structure/destructible/clockwork/geis_binding/attack_hand(mob/living/user)
	return

/obj/structure/destructible/clockwork/geis_binding/attackby(obj/item/I, mob/user, params)
	if(is_servant_of_ratvar(user) && istype(I, /obj/item/clockwork/slab))
		user.visible_message("<span class='warning'>[user] starts to dispel [src]...</span>", "<span class='danger'>You start to dispel [src]...</span>")
		if(do_after(user, 30, target = src))
			user.visible_message("<span class='warning'>[user] dispels [src]!</span>", "<span class='danger'>You dispel [src]!</span>")
			take_damage(obj_integrity)
		return 1
	return ..()

/obj/structure/destructible/clockwork/geis_binding/emp_act(severity)
	new /obj/effect/temp_visual/emp(loc)
	qdel(src)

/obj/structure/destructible/clockwork/geis_binding/post_buckle_mob(mob/living/M)
	..()
	if(M.buckled == src)
		desc = "A flickering, glowing purple ring around [M]."
		clockwork_desc = "A binding ring around [M], preventing [M.p_them()] from taking action."
		icon_state = "geisbinding"
		mob_layer = M.layer
		layer = mob_layer - 0.01
		add_overlay(mutable_appearance('icons/effects/clockwork_effects.dmi', "geisbinding_top", mob_layer + 0.01))
		last_mob_health = M.health
		apply_time = world.time
		for(var/obj/item/I in M.held_items)
			M.dropItemToGround(I)
		for(var/i in M.get_empty_held_indexes())
			var/obj/item/geis_binding/B = new(M)
			M.put_in_hands(B, i)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(!C.handcuffed)
				C.handcuffed = new /obj/item/restraints/handcuffs/energy/clock(C)
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
		M.AdjustStun(-130 + (apply_time - world.time), 1, 1) //remove exactly as much stun as was applied
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			C.silent = max(C.silent - 7, 0)
		for(var/obj/item/geis_binding/GB in M.held_items)
			M.dropItemToGround(GB, TRUE)
		if(iscarbon(M))
			var/mob/living/carbon/C = M
			if(istype(C.handcuffed, /obj/item/restraints/handcuffs/energy/clock))
				QDEL_NULL(C.handcuffed)
				C.update_handcuffed()

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

/obj/item/restraints/handcuffs/energy/clock
	name = "glowing rings"
	desc = "Flickering rings preventing you from holding items."
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "geisbinding_full"
	flags_1 = NODROP_1|ABSTRACT_1|DROPDEL_1
