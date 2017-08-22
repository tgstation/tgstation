//The base for slab-bound/based ranged abilities
/obj/effect/proc_holder/slab
	var/obj/item/clockwork/slab/slab
	var/successful = FALSE
	var/finished = FALSE
	var/in_progress = FALSE

/obj/effect/proc_holder/slab/Destroy()
	slab = null
	return ..()

/obj/effect/proc_holder/slab/remove_ranged_ability(msg)
	..()
	finished = TRUE
	QDEL_IN(src, 6)

/obj/effect/proc_holder/slab/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..() || in_progress)
		return TRUE
	if(ranged_ability_user.incapacitated() || !slab || !(slab in ranged_ability_user.held_items) || target == slab)
		remove_ranged_ability()
		return TRUE

//For the Geis scripture; binds a target to convert.
/obj/effect/proc_holder/slab/geis
	ranged_mousepointer = 'icons/effects/geis_target.dmi'
	var/obj/structure/destructible/clockwork/geis_binding/binding //we always have a reference to the binding
	var/obj/structure/destructible/clockwork/geis_binding/pulled_binding //we use this to see if we're pulling it or not

/obj/effect/proc_holder/slab/geis/remove_ranged_ability(msg)
	..()
	binding = null
	pulled_binding = null

/obj/effect/proc_holder/slab/geis/InterceptClickOn(mob/living/caller, params, atom/target)
	var/turf/T = ranged_ability_user.loc
	if(!isturf(T))
		return TRUE

	var/target_is_binding = istype(target, /obj/structure/destructible/clockwork/geis_binding)

	if((target_is_binding || isliving(target)) && ranged_ability_user.Adjacent(target))
		if(in_progress || ..())
			var/mob/living/L = target
			if(!pulled_binding)
				if(target == binding || (isliving(target) && L.buckled == binding))
					pulled_binding = binding
					ranged_ability_user.start_pulling(binding)
					remove_mousepointer(ranged_ability_user.client)
					ranged_mousepointer = 'icons/effects/geis_target_remove.dmi'
					add_mousepointer(ranged_ability_user.client)
			else if(target == pulled_binding || (isliving(target) && L.buckled == pulled_binding))
				ranged_ability_user.visible_message("<span class='warning'>[ranged_ability_user] dispels [pulled_binding]!</span>", "<span class='danger'>You dispel the binding!</span>")
				binding.take_damage(obj_integrity)
				remove_ranged_ability()
			return TRUE
		if(target_is_binding)
			var/obj/structure/destructible/clockwork/geis_binding/GB = target
			GB.repair_and_interrupt()
			for(var/m in GB.buckled_mobs)
				if(m)
					add_logs(ranged_ability_user, m, "rebound with Geis")
			successful = TRUE
		else
			var/mob/living/L = target
			if(L.null_rod_check())
				to_chat(ranged_ability_user, "<span class='sevtug'>\"A void weapon? Really, you expect me to be able to do anything?\"</span>")
				return TRUE
			if(is_servant_of_ratvar(L))
				if(L != ranged_ability_user)
					to_chat(ranged_ability_user, "<span class='sevtug'>\"[L.p_they(TRUE)] already serve[L.p_s()] Ratvar. [text2ratvar("Perhaps [ranged_ability_user.p_theyre()] into bondage?")]\"</span>")
				return TRUE
			if(L.stat == DEAD)
				to_chat(ranged_ability_user, "<span class='sevtug'>\"[L.p_theyre(TRUE)] dead, idiot.\"</span>")
				return TRUE

			if(istype(L.buckled, /obj/structure/destructible/clockwork/geis_binding)) //if they're already bound, just stun them
				var/obj/structure/destructible/clockwork/geis_binding/GB = L.buckled
				GB.repair_and_interrupt()
				add_logs(ranged_ability_user, L, "rebound with Geis")
				successful = TRUE
			else
				in_progress = TRUE
				clockwork_say(ranged_ability_user, text2ratvar("Be bound, heathen!"))
				remove_mousepointer(ranged_ability_user.client)
				ranged_mousepointer = 'icons/effects/geis_target_remove.dmi'
				add_mousepointer(ranged_ability_user.client)
				add_logs(ranged_ability_user, L, "bound with Geis")
				playsound(target, 'sound/magic/blink.ogg', 50, TRUE, frequency = 0.5)
				if(slab.speed_multiplier >= 0.5) //excuse my debug...
					ranged_ability_user.notransform = TRUE
					addtimer(CALLBACK(src, .proc/reset_user_notransform, ranged_ability_user), 5) //stop us moving for a little bit so we don't break the binding immediately
				if(L.buckled)
					L.buckled.unbuckle_mob(target, TRUE)
				binding = new(get_turf(target))
				binding.setDir(target.dir)
				binding.buckle_mob(target, TRUE)
				pulled_binding = binding
				ranged_ability_user.start_pulling(binding)
				slab.busy = "sustaining Geis"
				slab.flags_1 |= NODROP_1
				while(!QDELETED(binding) && !QDELETED(ranged_ability_user))
					if(ranged_ability_user.pulling == binding)
						pulled_binding = binding
						if(ranged_ability_user.client && ranged_ability_user.client.mouse_pointer_icon == 'icons/effects/geis_target.dmi')
							remove_mousepointer(ranged_ability_user.client)
							ranged_mousepointer = 'icons/effects/geis_target_remove.dmi'
							add_mousepointer(ranged_ability_user.client)
					else //if we're not pulling it, swap our mousepointer
						pulled_binding = null
						if(ranged_ability_user.client && ranged_ability_user.client.mouse_pointer_icon == 'icons/effects/geis_target_remove.dmi')
							remove_mousepointer(ranged_ability_user.client)
							ranged_mousepointer = 'icons/effects/geis_target.dmi'
							add_mousepointer(ranged_ability_user.client)
					sleep(1)
				if(!QDELETED(slab))
					slab.flags_1 &= ~NODROP_1
				in_progress = FALSE
				successful = TRUE

		remove_ranged_ability()
	else
		..()

	return TRUE

/obj/effect/proc_holder/slab/geis/proc/reset_user_notransform(mob/living/user)
	if(user)
		user.notransform = FALSE

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
			to_chat(ranged_ability_user, "<span class='inathneq'>\"[L] does not yet serve Ratvar.\"</span>")
			return TRUE
		if(L.stat == DEAD)
			to_chat(ranged_ability_user, "<span class='inathneq'>\"[L.p_they(TRUE)] [L.p_are()] dead. [text2ratvar("Oh, child. To have your life cut short...")]\"</span>")
			return TRUE

		var/brutedamage = L.getBruteLoss()
		var/burndamage = L.getFireLoss()
		var/oxydamage = L.getOxyLoss()
		var/totaldamage = brutedamage + burndamage + oxydamage
		if(!totaldamage && (!L.reagents || !L.reagents.has_reagent("holywater")))
			to_chat(ranged_ability_user, "<span class='inathneq'>\"[L] is unhurt and untainted.\"</span>")
			return TRUE

		successful = TRUE

		to_chat(ranged_ability_user, "<span class='brass'>You bathe [L == ranged_ability_user ? "yourself":"[L]"] in Inath-neq's power!</span>")
		var/targetturf = get_turf(L)
		var/has_holy_water = (L.reagents && L.reagents.has_reagent("holywater"))
		var/healseverity = max(round(totaldamage*0.05, 1), 1) //shows the general severity of the damage you just healed, 1 glow per 20
		for(var/i in 1 to healseverity)
			new /obj/effect/temp_visual/heal(targetturf, "#1E8CE1")
		if(totaldamage)
			L.adjustBruteLoss(-brutedamage)
			L.adjustFireLoss(-burndamage)
			L.adjustOxyLoss(-oxydamage)
			L.adjustToxLoss(totaldamage * 0.5, TRUE, TRUE)
			clockwork_say(ranged_ability_user, text2ratvar("[has_holy_water ? "Heal tainted" : "Mend wounded"] flesh!"))
			add_logs(ranged_ability_user, L, "healed with Sentinel's Compromise")
			L.visible_message("<span class='warning'>A blue light washes over [L], [has_holy_water ? "causing [L.p_them()] to briefly glow as it mends" : " mending"] [L.p_their()] bruises and burns!</span>", \
			"<span class='heavy_brass'>You feel Inath-neq's power healing your wounds[has_holy_water ? " and purging the darkness within you" : ""], but a deep nausea overcomes you!</span>")
		else
			clockwork_say(ranged_ability_user, text2ratvar("Purge foul darkness!"))
			add_logs(ranged_ability_user, L, "purged of holy water with Sentinel's Compromise")
			L.visible_message("<span class='warning'>A blue light washes over [L], causing [L.p_them()] to briefly glow!</span>", \
			"<span class='heavy_brass'>You feel Inath-neq's power purging the darkness within you!</span>")
		playsound(targetturf, 'sound/magic/staff_healing.ogg', 50, 1)

		if(has_holy_water)
			L.reagents.remove_reagent("holywater", 1000)

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
			to_chat(ranged_ability_user, "<span class='inathneq'>\"[L] does not yet serve Ratvar.\"</span>")
			return TRUE
		if(L.stat == DEAD)
			to_chat(ranged_ability_user, "<span class='inathneq'>\"[L.p_they(TRUE)] [L.p_are()] dead. [text2ratvar("Oh, child. To have your life cut short...")]\"</span>")
			return TRUE
		if(islist(L.stun_absorption) && L.stun_absorption["vanguard"] && L.stun_absorption["vanguard"]["end_time"] > world.time)
			to_chat(ranged_ability_user, "<span class='inathneq'>\"[L.p_they(TRUE)] [L.p_are()] already shielded by a Vanguard.\"</span>")
			return TRUE

		successful = TRUE

		if(L == ranged_ability_user)
			for(var/mob/living/LT in spiral_range(7, T))
				if(LT.stat == DEAD || !is_servant_of_ratvar(LT) || LT == ranged_ability_user || !(LT in view(7, get_turf(ranged_ability_user))) || \
				(islist(LT.stun_absorption) && LT.stun_absorption["vanguard"] && LT.stun_absorption["vanguard"]["end_time"] > world.time))
					continue
				L = LT
				break

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
		successful = TRUE

		clockwork_say(ranged_ability_user, text2ratvar("Kneel, heathens!"))
		ranged_ability_user.visible_message("<span class='warning'>[ranged_ability_user]'s eyes fire a stream of energy at [target], creating a strange mark!</span>", \
		"<span class='heavy_brass'>You direct the judicial force to [target].</span>")
		var/turf/targetturf = get_turf(target)
		new/obj/effect/clockwork/judicial_marker(targetturf, ranged_ability_user)
		add_logs(ranged_ability_user, targetturf, "created a judicial marker")
		remove_ranged_ability()

	return TRUE
