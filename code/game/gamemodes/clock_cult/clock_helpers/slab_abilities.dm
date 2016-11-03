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

//For the Guvax scripture; binds a target to convert.
/obj/effect/proc_holder/slab/guvax
	ranged_mousepointer = 'icons/effects/guvax_target.dmi'

/obj/effect/proc_holder/slab/guvax/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return TRUE

	var/turf/T = ranged_ability_user.loc
	if(!isturf(T))
		return TRUE

	if(isliving(target) && ranged_ability_user.Adjacent(target))
		var/mob/living/L = target
		if(is_servant_of_ratvar(L))
			if(L != ranged_ability_user)
				ranged_ability_user << "<span class='sevtug'>\"[L.p_they(TRUE)] already serve[L.p_s()] Ratvar. [text2ratvar("Perhaps [ranged_ability_user.p_theyre()] into bondage?")]\"</span>"
			return TRUE
		if(L.stat == DEAD)
			ranged_ability_user << "<span class='sevtug'>\"[L.p_theyre(TRUE)] dead, idiot.\"</span>"
			return TRUE

		if(istype(L.buckled, /obj/structure/destructible/clockwork/guvax_binding)) //if they're already bound, just stun them
			L.Stun(1)
			successful = TRUE
		else
			in_progress = TRUE
			clockwork_say(ranged_ability_user, text2ratvar("Be bound, heathen!"))
			remove_mousepointer(ranged_ability_user.client)
			ranged_ability_user.notransform = TRUE
			addtimer(src, "reset_user_notransform", 5, FALSE, ranged_ability_user) //stop us moving for a little bit so we don't break the scripture following this
			slab.busy = null
			var/datum/clockwork_scripture/guvax/conversion = new
			conversion.slab = slab
			conversion.invoker = ranged_ability_user
			conversion.target = target
			successful = conversion.run_scripture()

		remove_ranged_ability()

	return TRUE

/obj/effect/proc_holder/slab/guvax/proc/reset_user_notransform(mob/living/user)
	if(user)
		user.notransform = FALSE

/obj/structure/destructible/clockwork/guvax_binding
	name = "glowing ring"
	desc = "A flickering, glowing purple ring around a target."
	clockwork_desc = "A binding ring around a target, preventing them from taking action while they're being converted."
	max_integrity = 30
	obj_integrity = 30
	density = 0
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "guvaxbinding"
	break_message = "<span class='warning'>The glowing ring shatters!</span>"
	break_sound = 'sound/magic/Repulse.ogg'
	debris = list()
	can_buckle = TRUE
	buckle_lying = 0

/obj/structure/destructible/clockwork/guvax_binding/examine(mob/user)
	icon_state = "guvaxbinding_full"
	..()
	icon_state = "guvaxbinding"

/obj/structure/destructible/clockwork/guvax_binding/attack_hand(mob/living/user)
	return

/obj/structure/destructible/clockwork/guvax_binding/post_buckle_mob(mob/living/M)
	if(M.buckled == src)
		desc = "A flickering, glowing purple ring around [M]."
		clockwork_desc = "A binding ring around [M], preventing [M.p_them()] from taking action while [M.p_theyre()] being converted."
		layer = M.layer - 0.01
		var/image/GB = new('icons/effects/clockwork_effects.dmi', src, "guvaxbinding_top", M.layer + 0.01)
		add_overlay(GB)
		for(var/obj/item/I in M.held_items)
			M.unEquip(I)
		for(var/i in M.get_empty_held_indexes())
			var/obj/item/guvax_binding/B = new(M)
			M.put_in_hands(B, i)
		M.regenerate_icons()
		M.visible_message("<span class='warning'>A [name] appears around [M]!</span>", \
		"<span class='warning'>A [name] appears around you!</span>\n<span class='userdanger'>Resist!</span>")
	else
		M.visible_message("<span class='warning'>[src] snaps into glowing pieces and dissipates!</span>")
		for(var/obj/item/guvax_binding/G in M.held_items)
			M.unEquip(G, TRUE)
		qdel(src)

/obj/structure/destructible/clockwork/guvax_binding/user_unbuckle_mob(mob/living/buckled_mob, mob/user)
	if(buckled_mob == user)
		user.visible_message("<span class='warning'>[user] starts struggling against [src]...</span>", "<span class='userdanger'>You start breaking out of [src]...</span>")
		if(do_after(user, 40, target = src))
			user.visible_message("<span class='warning'>[user] breaks [src]!</span>", "<span class='userdanger'>You break [src]!</span>")
			unbuckle_mob(user, TRUE)
			return user
	else
		return ..()

/obj/item/guvax_binding
	name = "glowing ring"
	desc = "A flickering ring preventing you from holding items."
	force = 0
	icon = 'icons/effects/clockwork_effects.dmi'
	icon_state = "guvaxbinding_full"
	flags = NODROP|ABSTRACT|DROPDEL|NOBLUDGEON

/obj/item/guvax_binding/afterattack(atom/target, mob/living/user, proximity_flag, params)
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
