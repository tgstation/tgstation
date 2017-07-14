//Used by the Geis scripture to hold its target in place
/obj/structure/destructible/clockwork/geis_binding
	name = "glowing ring"
	desc = "A flickering, glowing purple ring around a target."
	clockwork_desc = "A binding ring around a target, preventing them from taking action while they're being converted."
	max_integrity = 25
	light_range = 2
	light_power = 0.5
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
	var/mob/living/resisting = FALSE
	var/mob_layer = MOB_LAYER
	var/obj/item/clockwork/slab/slab

/obj/structure/destructible/clockwork/geis_binding/Initialize()
	. = ..()
	START_PROCESSING(SSprocessing, src)

/obj/structure/destructible/clockwork/geis_binding/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	slab.busy = null
	slab.icon_state = initial(slab.icon_state)
	return ..()

/obj/structure/destructible/clockwork/geis_binding/proc/assign_slab(obj/item/clockwork/slab/the_slab) //feed me energy
	set waitfor = FALSE
	if(!the_slab)
		return
	slab = the_slab
	sleep(1) //This is necessary for everything to happen properly with the ranged ability code
	slab.busy = "Maintaining Geis bindings"
	slab.icon_state = "judicial"

/obj/structure/destructible/clockwork/geis_binding/attackby(obj/item/I, mob/living/user, params)
	if(slab == I)
		user.visible_message("<span class='warning'>[user] dispels [src]!</span>", "<span class='danger'>You dispel the bindings!</span>")
		take_damage(obj_integrity)
		return
	. = ..()

/obj/structure/destructible/clockwork/geis_binding/process()
	if(!pulledby || !is_servant_of_ratvar(pulledby))
		take_damage(1) //Quickly decays when not pulled by a servant
	if(!resisting)
		return
	if(resisting.stat)
		to_chat(resisting, "<span class='warning'>Your struggling ceases as you fall unconscious!</span>")
		resisting = null
		return
	if(LAZYLEN(buckled_mobs))
		for(var/V in buckled_mobs)
			var/mob/living/L = V
			if(is_servant_of_ratvar(L))
				take_damage(obj_integrity) //be free!
				return
	take_damage(1, sound_effect = FALSE)
	playsound(src, 'sound/effects/empulse.ogg', 20, TRUE) //Much quieter than normal attacks but still obvious

/obj/structure/destructible/clockwork/geis_binding/examine(mob/user)
	icon_state = "geisbinding_full"
	..()
	icon_state = "geisbinding"
	if(resisting)
		to_chat(user, "<span class='warning'>[resisting] is struggling to break free from the bindings!</span>")

/obj/structure/destructible/clockwork/geis_binding/attack_hand(mob/living/user)
	return

/obj/structure/destructible/clockwork/geis_binding/emp_act(severity)
	new /obj/effect/temp_visual/emp(loc)
	qdel(src)

/obj/structure/destructible/clockwork/geis_binding/post_buckle_mob(mob/living/M)
	..()
	if(M.buckled == src && !is_servant_of_ratvar(M))
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
		M.visible_message("<span class='warning'>A [name] appears around [M]!</span>", \
		"<span class='warning'>A [name] appears around you!</span> <span class='boldwarning'>Resist!</span>")
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

/obj/structure/destructible/clockwork/geis_binding/relaymove(mob/user, direction)
	if(isliving(user) && !resisting) //let's NOT spam
		var/mob/living/L = user
		L.resist()

/obj/structure/destructible/clockwork/geis_binding/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src, 'sound/effects/empulse.ogg', 50, 1)

/obj/structure/destructible/clockwork/geis_binding/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	if(.)
		update_icon()

/obj/structure/destructible/clockwork/geis_binding/update_icon()
	alpha = min(initial(alpha) + ((obj_integrity - max_integrity) * 5), 255)

/obj/structure/destructible/clockwork/geis_binding/proc/repair_and_interrupt()
	obj_integrity = max_integrity
	update_icon()
	for(var/m in buckled_mobs)
		var/mob/living/L = m
		if(L)
			L.Stun(20, 1, 1)
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				C.silent += 4
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
	if(resisting)
		to_chat(user, "<span class='warning'>You're already trying to break free!</span>")
		return
	if(is_servant_of_ratvar(user))
		take_damage(obj_integrity) //freedom!
		return
	resisting = user
	user.visible_message("<span class='warning'>[user] starts struggling against [src]...</span>", "<span class='userdanger'>You start breaking out of [src]...</span>")
	START_PROCESSING(SSprocessing, src)

/obj/item/geis_binding
	name = "glowing ring"
	desc = "A flickering ring preventing you from holding items."
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "geisbinding_full"
	flags = NODROP|ABSTRACT|DROPDEL

/obj/item/geis_binding/pre_attackby(atom/target, mob/living/user, params)
	user.resist()
	return FALSE
