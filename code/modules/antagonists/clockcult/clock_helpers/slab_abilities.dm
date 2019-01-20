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

//For the Hateful Manacles scripture; applies replicant handcuffs to the target.
/obj/effect/proc_holder/slab/hateful_manacles

/obj/effect/proc_holder/slab/hateful_manacles/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return TRUE

	var/turf/T = ranged_ability_user.loc
	if(!isturf(T))
		return TRUE

	if(iscarbon(target) && target.Adjacent(ranged_ability_user))
		var/mob/living/carbon/L = target
		if(is_servant_of_ratvar(L))
			to_chat(ranged_ability_user, "<span class='neovgre'>\"[L.p_theyre(TRUE)] a servant.\"</span>")
			return TRUE
		else if(L.stat)
			to_chat(ranged_ability_user, "<span class='neovgre'>\"There is use in shackling the dead, but for examples.\"</span>")
			return TRUE
		else if (istype(L.handcuffed,/obj/item/restraints/handcuffs/clockwork))
			to_chat(ranged_ability_user, "<span class='neovgre'>\"[L.p_theyre(TRUE)] already helpless, no?\"</span>")
			return TRUE

		playsound(loc, 'sound/weapons/handcuffs.ogg', 30, TRUE)
		ranged_ability_user.visible_message("<span class='danger'>[ranged_ability_user] begins forming manacles around [L]'s wrists!</span>", \
		"<span class='neovgre_small'>You begin shaping replicant alloy into manacles around [L]'s wrists...</span>")
		to_chat(L, "<span class='userdanger'>[ranged_ability_user] begins forming manacles around your wrists!</span>")
		if(do_mob(ranged_ability_user, L, 30))
			if(!(istype(L.handcuffed,/obj/item/restraints/handcuffs/clockwork)))
				L.handcuffed = new/obj/item/restraints/handcuffs/clockwork(L)
				L.update_handcuffed()
				to_chat(ranged_ability_user, "<span class='neovgre_small'>You shackle [L].</span>")
				log_combat(ranged_ability_user, L, "handcuffed")
		else
			to_chat(ranged_ability_user, "<span class='warning'>You fail to shackle [L].</span>")

		successful = TRUE

		remove_ranged_ability()

	return TRUE

/obj/item/restraints/handcuffs/clockwork
	name = "replicant manacles"
	desc = "Heavy manacles made out of freezing-cold metal. It looks like brass, but feels much more solid."
	icon_state = "brass_manacles"
	item_flags = DROPDEL

/obj/item/restraints/handcuffs/clockwork/dropped(mob/user)
	user.visible_message("<span class='danger'>[user]'s [name] come apart at the seams!</span>", \
	"<span class='userdanger'>Your [name] break apart as they're removed!</span>")
	. = ..()

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
			to_chat(ranged_ability_user, "<span class='inathneq'>\"[L.p_theyre(TRUE)] dead. [text2ratvar("Oh, child. To have your life cut short...")]\"</span>")
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
			log_combat(ranged_ability_user, L, "healed with Sentinel's Compromise")
			L.visible_message("<span class='warning'>A blue light washes over [L], [has_holy_water ? "causing [L.p_them()] to briefly glow as it mends" : " mending"] [L.p_their()] bruises and burns!</span>", \
			"<span class='heavy_brass'>You feel Inath-neq's power healing your wounds[has_holy_water ? " and purging the darkness within you" : ""], but a deep nausea overcomes you!</span>")
		else
			clockwork_say(ranged_ability_user, text2ratvar("Purge foul darkness!"))
			log_combat(ranged_ability_user, L, "purged of holy water with Sentinel's Compromise")
			L.visible_message("<span class='warning'>A blue light washes over [L], causing [L.p_them()] to briefly glow!</span>", \
			"<span class='heavy_brass'>You feel Inath-neq's power purging the darkness within you!</span>")
		playsound(targetturf, 'sound/magic/staff_healing.ogg', 50, 1)

		if(has_holy_water)
			L.reagents.remove_reagent("holywater", 1000)

		remove_ranged_ability()

	return TRUE

//For the Kindle scripture; stuns and mutes a target non-servant.
/obj/effect/proc_holder/slab/kindle
	ranged_mousepointer = 'icons/effects/volt_target.dmi'

/obj/effect/proc_holder/slab/kindle/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return TRUE

	var/turf/T = ranged_ability_user.loc
	if(!isturf(T))
		return TRUE

	if(target in view(7, get_turf(ranged_ability_user)))

		successful = TRUE

		var/turf/U = get_turf(target)
		to_chat(ranged_ability_user, "<span class='brass'>You release the light of Ratvar!</span>")
		clockwork_say(ranged_ability_user, text2ratvar("Purge all untruths and honor Engine!"))
		log_combat(ranged_ability_user, U, "fired at with Kindle")
		playsound(ranged_ability_user, 'sound/magic/blink.ogg', 50, TRUE, frequency = 0.5)
		var/obj/item/projectile/kindle/A = new(T)
		A.preparePixelProjectile(target, caller, params)
		A.fire()

		remove_ranged_ability()

	return TRUE

/obj/item/projectile/kindle
	name = "kindled flame"
	icon_state = "pulse0"
	nodamage = TRUE
	damage = 0 //We're just here for the stunning!
	damage_type = BURN
	flag = "bomb"
	range = 3
	log_override = TRUE

/obj/item/projectile/kindle/Destroy()
	visible_message("<span class='warning'>[src] flickers out!</span>")
	. = ..()

/obj/item/projectile/kindle/on_hit(atom/target, blocked = FALSE)
	if(isliving(target))
		var/mob/living/L = target
		if(is_servant_of_ratvar(L) || L.stat || L.has_status_effect(STATUS_EFFECT_KINDLE))
			return
		var/atom/O = L.anti_magic_check()
		playsound(L, 'sound/magic/fireball.ogg', 50, TRUE, frequency = 1.25)
		if(O)
			if(isitem(O))
				L.visible_message("<span class='warning'>[L]'s eyes flare with dim light!</span>", \
				"<span class='userdanger'>Your [O] glows white-hot against you as it absorbs [src]'s power!</span>")
			else if(ismob(O))
				L.visible_message("<span class='warning'>[L]'s eyes flare with dim light!</span>")
			playsound(L, 'sound/weapons/sear.ogg', 50, TRUE)
		else
			L.visible_message("<span class='warning'>[L]'s eyes blaze with brilliant light!</span>", \
			"<span class='userdanger'>Your vision suddenly screams with white-hot light!</span>")
			L.Paralyze(15)
			L.apply_status_effect(STATUS_EFFECT_KINDLE)
			L.flash_act(1, 1)
			if(iscultist(L))
				L.adjustFireLoss(15)
	..()


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
			to_chat(ranged_ability_user, "<span class='inathneq'>\"[L.p_theyre(TRUE)] dead. [text2ratvar("Oh, child. To have your life cut short...")]\"</span>")
			return TRUE
		if(islist(L.stun_absorption) && L.stun_absorption["vanguard"] && L.stun_absorption["vanguard"]["end_time"] > world.time)
			to_chat(ranged_ability_user, "<span class='inathneq'>\"[L.p_theyre(TRUE)] already shielded by a Vanguard.\"</span>")
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
		log_combat(ranged_ability_user, targetturf, "created a judicial marker")
		remove_ranged_ability()

	return TRUE
