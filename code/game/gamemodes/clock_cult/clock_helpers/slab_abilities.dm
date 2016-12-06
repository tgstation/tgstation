//The base for slab-bound/based ranged abilities
/obj/effect/proc_holder/slab
	var/obj/item/clockwork/slab/slab
	var/successful = FALSE
	var/finished = FALSE
	var/in_progress = FALSE

/obj/effect/proc_holder/slab/remove_ranged_ability(msg)
	..()
	finished = TRUE
	QDEL_IN(src, 2)

/obj/effect/proc_holder/slab/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..() || in_progress)
		return TRUE
	if(ranged_ability_user.incapacitated() || !slab || !(slab in ranged_ability_user.held_items) || target == slab)
		remove_ranged_ability()
		return TRUE

//For the Geis scripture; binds a target to convert.
/obj/effect/proc_holder/slab/geis
	ranged_mousepointer = 'icons/effects/geis_target.dmi'

/obj/effect/proc_holder/slab/geis/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return TRUE

	var/turf/T = ranged_ability_user.loc
	if(!isturf(T))
		return TRUE

	var/target_is_binding = istype(target, /obj/structure/destructible/clockwork/geis_binding)

	if((target_is_binding || isliving(target)) && ranged_ability_user.Adjacent(target))
		if(target_is_binding)
			var/obj/structure/destructible/clockwork/geis_binding/GB = target
			GB.repair_and_interrupt()
			successful = TRUE
		else
			var/mob/living/L = target
			if(is_servant_of_ratvar(L))
				if(L != ranged_ability_user)
					ranged_ability_user << "<span class='sevtug'>\"[L.p_they(TRUE)] already serve[L.p_s()] Ratvar. [text2ratvar("Perhaps [ranged_ability_user.p_theyre()] into bondage?")]\"</span>"
				return TRUE
			if(L.stat == DEAD)
				ranged_ability_user << "<span class='sevtug'>\"[L.p_theyre(TRUE)] dead, idiot.\"</span>"
				return TRUE

			if(istype(L.buckled, /obj/structure/destructible/clockwork/geis_binding)) //if they're already bound, just stun them
				var/obj/structure/destructible/clockwork/geis_binding/GB = L.buckled
				GB.repair_and_interrupt()
				successful = TRUE
			else
				in_progress = TRUE
				clockwork_say(ranged_ability_user, text2ratvar("Be bound, heathen!"))
				remove_mousepointer(ranged_ability_user.client)
				if(slab.speed_multiplier >= 0.5) //excuse my debug...
					ranged_ability_user.notransform = TRUE
					addtimer(src, "reset_user_notransform", 5, TIMER_NORMAL, ranged_ability_user) //stop us moving for a little bit so we don't break the scripture following this
				slab.busy = null
				var/datum/clockwork_scripture/geis/conversion = new
				conversion.slab = slab
				conversion.invoker = ranged_ability_user
				conversion.target = target
				successful = conversion.run_scripture()

		remove_ranged_ability()

	return TRUE

/obj/effect/proc_holder/slab/geis/proc/reset_user_notransform(mob/living/user)
	if(user)
		user.notransform = FALSE

/obj/structure/destructible/clockwork/geis_binding
	name = "glowing ring"
	desc = "A flickering, glowing purple ring around a target."
	clockwork_desc = "A binding ring around a target, preventing them from taking action while they're being converted."
	max_integrity = 25
	obj_integrity = 25
	density = 0
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "geisbinding_full"
	break_message = null
	break_sound = 'sound/magic/Repulse.ogg'
	debris = list()
	can_buckle = TRUE
	buckle_lying = 0
	buckle_prevents_pull = TRUE
	var/resisting = FALSE
	var/mob_layer = MOB_LAYER

/obj/structure/destructible/clockwork/geis_binding/examine(mob/user)
	icon_state = "geisbinding_full"
	..()
	icon_state = "geisbinding"

/obj/structure/destructible/clockwork/geis_binding/attack_hand(mob/living/user)
	return

/obj/structure/destructible/clockwork/geis_binding/post_buckle_mob(mob/living/M)
	if(M.buckled == src)
		desc = "A flickering, glowing purple ring around [M]."
		clockwork_desc = "A binding ring around [M], preventing [M.p_them()] from taking action while [M.p_theyre()] being converted."
		icon_state = "geisbinding"
		mob_layer = M.layer
		layer = M.layer - 0.01
		var/image/GB = new('icons/effects/clockwork_effects.dmi', src, "geisbinding_top", M.layer + 0.01)
		add_overlay(GB)
		for(var/obj/item/I in M.held_items)
			M.unEquip(I)
		for(var/i in M.get_empty_held_indexes())
			var/obj/item/geis_binding/B = new(M)
			M.put_in_hands(B, i)
		M.regenerate_icons()
		M.visible_message("<span class='warning'>A [name] appears around [M]!</span>", \
		"<span class='warning'>A [name] appears around you!</span>\n<span class='userdanger'>Resist!</span>")
	else
		var/obj/effect/overlay/temp/ratvar/geis_binding/G = PoolOrNew(/obj/effect/overlay/temp/ratvar/geis_binding, M.loc)
		var/obj/effect/overlay/temp/ratvar/geis_binding/T = PoolOrNew(/obj/effect/overlay/temp/ratvar/geis_binding/top, M.loc)
		G.layer = mob_layer - 0.01
		T.layer = mob_layer + 0.01
		G.alpha = alpha
		T.alpha = alpha
		animate(G, transform = matrix()*2, alpha = 0, time = 8, easing = EASE_OUT)
		animate(T, transform = matrix()*2, alpha = 0, time = 8, easing = EASE_OUT)
		M.visible_message("<span class='warning'>[src] snaps into glowing pieces and dissipates!</span>")
		for(var/obj/item/geis_binding/GB in M.held_items)
			M.unEquip(GB, TRUE)
		qdel(src)

/obj/structure/destructible/clockwork/geis_binding/relaymove(mob/user, direction)
	if(isliving(user))
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
	visible_message("<span class='sevtug'>[src] flares brightly!</span>")
	var/obj/effect/overlay/temp/ratvar/geis_binding/G1 = PoolOrNew(/obj/effect/overlay/temp/ratvar/geis_binding, loc)
	var/obj/effect/overlay/temp/ratvar/geis_binding/G2 = PoolOrNew(/obj/effect/overlay/temp/ratvar/geis_binding, loc)
	var/obj/effect/overlay/temp/ratvar/geis_binding/T1 = PoolOrNew(/obj/effect/overlay/temp/ratvar/geis_binding/top, loc)
	var/obj/effect/overlay/temp/ratvar/geis_binding/T2 = PoolOrNew(/obj/effect/overlay/temp/ratvar/geis_binding/top, loc)
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
		if(!resisting)
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
	force = 0
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "geisbinding_full"
	flags = NODROP|ABSTRACT|DROPDEL|NOBLUDGEON

/obj/item/geis_binding/afterattack(atom/target, mob/living/user, proximity_flag, params)
	user.resist()

//For the Sentinel's Compromise scripture; heals a target servant.
/obj/effect/proc_holder/slab/compromise
	ranged_mousepointer = 'icons/effects/compromise_target.dmi'

/obj/effect/proc_holder/slab/compromise/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return TRUE

	var/turf/T = ranged_ability_user.loc
	if(!isturf(T))
		return TRUE

	if(isliving(target) && (target in view(7, get_turf(ranged_ability_user))))
		var/mob/living/L = target
		if(!is_servant_of_ratvar(L))
			ranged_ability_user << "<span class='inathneq'>\"[L] does not yet serve Ratvar.\"</span>"
			return TRUE
		if(L.stat == DEAD)
			ranged_ability_user << "<span class='inathneq'>\"[L.p_they(TRUE)] [L.p_are()] dead. [text2ratvar("Oh, child. To have your life cut short...")]\"</span>"
			return TRUE

		var/brutedamage = L.getBruteLoss()
		var/burndamage = L.getFireLoss()
		var/totaldamage = brutedamage + burndamage
		if(!totaldamage && (!L.reagents || !L.reagents.has_reagent("holywater")))
			ranged_ability_user << "<span class='inathneq'>\"[L] is unhurt and untainted.\"</span>"
			return TRUE
		var/targetturf = get_turf(L)
		if(totaldamage)
			L.adjustBruteLoss(-brutedamage)
			L.adjustFireLoss(-burndamage)
			L.adjustToxLoss(totaldamage * 0.5)
			var/healseverity = max(round(totaldamage*0.05, 1), 1) //shows the general severity of the damage you just healed, 1 glow per 20
			for(var/i in 1 to healseverity)
				PoolOrNew(/obj/effect/overlay/temp/heal, list(targetturf, "#1E8CE1"))
			clockwork_say(ranged_ability_user, text2ratvar("Mend wounded flesh!"))
		else
			clockwork_say(ranged_ability_user, text2ratvar("Purge foul darkness!"))
		ranged_ability_user << "<span class='brass'>You bathe [L == ranged_ability_user ? "yourself":"[L]"] in Inath-neq's power!</span>"
		L.visible_message("<span class='warning'>A blue light washes over [L], mending [L.p_their()] bruises and burns!</span>", \
		"<span class='heavy_brass'>You feel Inath-neq's power healing your wounds, but a deep nausea overcomes you!</span>")
		playsound(targetturf, 'sound/magic/Staff_Healing.ogg', 50, 1)

		if(L.reagents && L.reagents.has_reagent("holywater"))
			L.reagents.remove_reagent("holywater", 1000)
			L << "<span class='heavy_brass'>Ratvar's light flares, banishing the darkness. Your devotion remains intact!</span>"

		remove_ranged_ability()

	return TRUE

//For the cyborg Linked Vanguard scripture, grants you and a nearby ally Vanguard
/obj/effect/proc_holder/slab/vanguard
	ranged_mousepointer = 'icons/effects/vanguard_target.dmi'

/obj/effect/proc_holder/slab/vanguard/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return TRUE

	var/turf/T = ranged_ability_user.loc
	if(!isturf(T))
		return TRUE

	if(isliving(target) && (target in view(7, get_turf(ranged_ability_user))))
		var/mob/living/L = target
		if(!is_servant_of_ratvar(L))
			ranged_ability_user << "<span class='inathneq'>\"[L] does not yet serve Ratvar.\"</span>"
			return TRUE
		if(L.stat == DEAD)
			ranged_ability_user << "<span class='inathneq'>\"[L.p_they(TRUE)] [L.p_are()] dead. [text2ratvar("Oh, child. To have your life cut short...")]\"</span>"
			return TRUE
		if(islist(L.stun_absorption) && L.stun_absorption["vanguard"] && L.stun_absorption["vanguard"]["end_time"] > world.time)
			ranged_ability_user << "<span class='inathneq'>\"[L.p_they(TRUE)] [L.p_are()] already shielded by a Vanguard.\"</span>"
			return TRUE

		if(L == ranged_ability_user)
			for(var/mob/living/LT in spiral_range(7, T))
				if(LT.stat == DEAD || !is_servant_of_ratvar(LT) || LT == ranged_ability_user || !(LT in view(7, get_turf(ranged_ability_user))) || \
				(islist(LT.stun_absorption) && LT.stun_absorption["vanguard"] && LT.stun_absorption["vanguard"]["end_time"] > world.time))
					continue
				LT.apply_status_effect(STATUS_EFFECT_VANGUARD)
		else
			L.apply_status_effect(STATUS_EFFECT_VANGUARD)
		ranged_ability_user.apply_status_effect(STATUS_EFFECT_VANGUARD)

		clockwork_say(ranged_ability_user, text2ratvar("Shield us from darkness!"))

		remove_ranged_ability()

	return TRUE

//For the cyborg Judicial Marker scripture, places a judicial marker
/obj/effect/proc_holder/slab/judicial
	ranged_mousepointer = 'icons/effects/visor_reticule.dmi'

/obj/effect/proc_holder/slab/judicial/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return TRUE

	var/turf/T = ranged_ability_user.loc
	if(!isturf(T))
		return TRUE

	if(target in view(7, get_turf(ranged_ability_user)))
		clockwork_say(ranged_ability_user, text2ratvar("Kneel, heathens!"))
		ranged_ability_user.visible_message("<span class='warning'>[ranged_ability_user]'s eyes fire a stream of energy at [target], creating a strange mark!</span>", \
		"<span class='heavy_brass'>You direct the judicial force to [target].</span>")
		var/turf/targetturf = get_turf(target)
		new/obj/effect/clockwork/judicial_marker(targetturf, ranged_ability_user)
		add_logs(ranged_ability_user, targetturf, "created a judicial marker")
		remove_ranged_ability()

	return TRUE
