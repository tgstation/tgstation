//Used by the Geis scripture to hold its target in place
/obj/structure/destructible/clockwork/geis_binding
	name = "glowing ring"
	desc = "A flickering, glowing purple ring around a target."
	clockwork_desc = "A binding ring around a target, preventing them from taking action while they're being converted."
	max_integrity = 25
	obj_integrity = 25
	light_color = "#AF0AAF"
	density = FALSE
	immune_to_servant_attacks = TRUE
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "geisbinding_full"
	break_message = null
	break_sound = 'sound/magic/Repulse.ogg'
	debris = list()
	can_buckle = TRUE
	buckle_lying = 0
	buckle_prevents_pull = TRUE
	var/resisting = FALSE
	var/can_resist = FALSE
	var/mob_layer = MOB_LAYER

/obj/structure/destructible/clockwork/geis_binding/New()
	..()
	set_light(2, 0.5)

/obj/structure/destructible/clockwork/geis_binding/examine(mob/user)
	icon_state = "geisbinding_full"
	..()
	icon_state = "geisbinding"

/obj/structure/destructible/clockwork/geis_binding/attack_hand(mob/living/user)
	return

/obj/structure/destructible/clockwork/geis_binding/emp_act(severity)
	new /obj/effect/overlay/temp/emp(loc)
	qdel(src)

/obj/structure/destructible/clockwork/geis_binding/post_buckle_mob(mob/living/M)
	..()
	if(M.buckled == src)
		desc = "A flickering, glowing purple ring around [M]."
		clockwork_desc = "A binding ring around [M], preventing [M.p_them()] from taking action while [M.p_theyre()] being converted."
		icon_state = "geisbinding"
		mob_layer = M.layer
		layer = M.layer - 0.01
		var/image/GB = new('icons/effects/clockwork_effects.dmi', src, "geisbinding_top", M.layer + 0.01)
		add_overlay(GB)
		for(var/obj/item/I in M.held_items)
			M.dropItemToGround(I)
		for(var/i in M.get_empty_held_indexes())
			var/obj/item/geis_binding/B = new(M)
			M.put_in_hands(B, i)
		M.regenerate_icons()
		M.visible_message("<span class='warning'>A [name] appears around [M]!</span>", \
		"<span class='warning'>A [name] appears around you!</span>[can_resist ? "\n<span class='userdanger'>Resist!</span>":""]")
		if(!can_resist)
			repair_and_interrupt()
	else
		var/obj/effect/overlay/temp/ratvar/geis_binding/G = new /obj/effect/overlay/temp/ratvar/geis_binding(M.loc)
		var/obj/effect/overlay/temp/ratvar/geis_binding/T = new /obj/effect/overlay/temp/ratvar/geis_binding/top(M.loc)
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
	if(isliving(user) && can_resist)
		var/mob/living/L = user
		L.resist()

/obj/structure/destructible/clockwork/geis_binding/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	playsound(src, 'sound/effects/EMPulse.ogg', 50, 1)

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
			L.Stun(1, 1, 1)
			if(iscarbon(L))
				var/mob/living/carbon/C = L
				C.silent += 4
	visible_message("<span class='sevtug'>[src] flares brightly!</span>")
	var/obj/effect/overlay/temp/ratvar/geis_binding/G1 = new /obj/effect/overlay/temp/ratvar/geis_binding(loc)
	var/obj/effect/overlay/temp/ratvar/geis_binding/G2 = new /obj/effect/overlay/temp/ratvar/geis_binding(loc)
	var/obj/effect/overlay/temp/ratvar/geis_binding/T1 = new /obj/effect/overlay/temp/ratvar/geis_binding/top(loc)
	var/obj/effect/overlay/temp/ratvar/geis_binding/T2 = new /obj/effect/overlay/temp/ratvar/geis_binding/top(loc)
	G1.layer = mob_layer - 0.01
	G2.layer = mob_layer - 0.01
	T1.layer = mob_layer + 0.01
	T2.layer = mob_layer + 0.01
	animate(G1, pixel_y = pixel_y + 9, alpha = 0, time = 8, easing = EASE_IN)
	animate(G2, pixel_y = pixel_y - 9, alpha = 0, time = 8, easing = EASE_IN)
	animate(T1, pixel_y = pixel_y + 9, alpha = 0, time = 8, easing = EASE_IN)
	animate(T2, pixel_y = pixel_y - 9, alpha = 0, time = 8, easing = EASE_IN)

/obj/structure/destructible/clockwork/geis_binding/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(buckled_mob == user)
		if(!resisting && can_resist)
			resisting = TRUE
			user.visible_message("<span class='warning'>[user] starts struggling against [src]...</span>", "<span class='userdanger'>You start breaking out of [src]...</span>")
			while(do_after(user, 10, target = src) && resisting && obj_integrity)
				if(obj_integrity - 5 <= 0)
					user.visible_message("<span class='warning'>[user] breaks [src]!</span>", "<span class='userdanger'>You break [src]!</span>")
					take_damage(5)
					return user
				take_damage(5)
			resisting = FALSE
	else
		return ..()

/obj/item/geis_binding
	name = "glowing ring"
	desc = "A flickering ring preventing you from holding items."
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "geisbinding_full"
	flags = NODROP|ABSTRACT|DROPDEL

/obj/item/geis_binding/pre_attackby(atom/target, mob/living/user, params)
	user.resist()
	return FALSE
