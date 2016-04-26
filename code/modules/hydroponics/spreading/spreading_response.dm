/*/obj/effect/plantsegment/HasProximity(var/mob/living/M)

	if(!istype(M) || !Adjacent(M))
		return

	if(!is_mature() || limited_growth)
		return

	if(!(locked_atoms && locked_atoms.len) && !M.locked_to && !M.anchored && (M.size <= SIZE_SMALL || prob(round(seed.potency/6))) )
		//wait a tick for the Entered() proc that called HasProximity() to finish (and thus the moving animation),
		//so we don't appear to teleport from two tiles away when moving into a turf adjacent to vines.
		spawn(1)
			if(M && !M.locked_to)
				entangle_mob(M)*/

/obj/effect/plantsegment/proc/special_cooldown()
	return world.time >= last_special + max(3 SECONDS, 100-seed.potency)

/obj/effect/plantsegment/Crossed(var/mob/living/M)
	if(!istype(M) || !is_mature() || !special_cooldown())
		return
	if(prob(round(seed.potency/6)))
		entangle_mob(M)
	if(istype(M, /mob/living/carbon/human))
		do_thorns(M, 25) //this is the chance !! PER NON-PROTECTED LIMB !!
		do_sting(M, 30)

/obj/effect/plantsegment/attack_hand(var/mob/user)
	if(user.a_intent == I_HELP && !is_locking(/datum/locking_category/plantsegment) && harvest)
		if(seed.check_harvest(user))
			harvest(user)
		return

	manual_unbuckle(user)

/obj/effect/plantsegment/attack_paw(mob/user as mob)
	manual_unbuckle(user)

/obj/effect/plantsegment/proc/harvest(var/mob/user)
	seed.harvest(user, yield_mod = 0.5)
	harvest = 0
	age = mature_time // Since we don't die of old age, there's no need to keep an accurate age count.
	update_icon()
	plant_controller.add_plant(src)

/obj/effect/plantsegment/proc/do_thorns(var/mob/living/carbon/human/victim, var/chance)
	if(!seed || !seed.thorny)
		return
	if(!istype(victim)) return
	var/cuts = 0
	for(var/datum/organ/external/Ex in victim.organs) //hahaha shit this is probably going to MINCE people
		if(Ex && Ex.is_existing() && Ex.is_organic())
			if(victim.getarmor(Ex, "melee") < 5 && prob(chance/(cuts+1)))
				var/damage = 7 // I don't think this should be based on potency
				victim.apply_damage(damage, BRUTE, Ex)
				if(Ex.parent)
					Ex.parent.add_autopsy_data("[plant_damage_noun]", damage)
				if(victim.stat != DEAD)
					to_chat(victim, "<span class='danger'>Your [Ex.display_name] is pierced by the thorns on \the [src]!</span>")
				cuts++
				if(cuts >= 3) break
	last_special = world.time

/obj/effect/plantsegment/proc/do_sting(var/mob/living/carbon/human/victim, var/chance)
	if(!seed || !seed.stinging || victim.stat == DEAD)
		return
	if(!istype(victim)) return
	if(victim.get_exposed_body_parts() && prob(chance))
		if(seed.chems && seed.chems.len)
			for(var/rid in seed.chems)
				victim.reagents.add_reagent(rid, Clamp(1, 5, seed.potency/10))
			to_chat(victim, "<span class='danger'>You are stung by \the [src]!</span>")
	last_special = world.time

/obj/effect/plantsegment/proc/do_carnivorous_bite(var/mob/living/carbon/human/victim, var/chance)
	// http://i.imgur.com/Xt6rM4P.png
	if(!seed || !seed.carnivorous || !prob(chance))
		return
	if(victim.stat != DEAD)
		to_chat(victim, "<span class='danger'>\The [src] horribly twist and mangle your body!</span>")
	var/damage = round(triangular_seq(rand(seed.potency*0.2, seed.potency*0.6), 15))
	if(!istype(victim))
		victim.adjustBruteLoss(damage)
		return
	else
		var/datum/organ/external/affecting = victim.get_organ(pick("l_foot","r_foot","l_leg","r_leg","l_hand","r_hand","l_arm", "r_arm","head","chest","groin"))
		if(affecting && affecting.is_existing() && affecting.is_organic())
			victim.apply_damage(damage, BRUTE, affecting)
			if(affecting.parent)
				affecting.parent.add_autopsy_data("[plant_damage_noun]", damage)
		else
			victim.adjustBruteLoss(damage)

	victim.UpdateDamageIcon()
	victim.updatehealth()
	last_special = world.time

/obj/effect/plantsegment/proc/do_chem_inject(var/mob/living/carbon/human/victim, var/chance)
	if(seed.chems && seed.chems.len && istype(victim) && victim.stat != DEAD)
		to_chat(victim, "<span class='danger'>You feel something seeping into your skin!</span>")
		for(var/rid in seed.chems)
			var/injecting = min(5,max(1,seed.potency/5))
			victim.reagents.add_reagent(rid,injecting)
		last_special = world.time
	if(seed.hematophage)
		var/drawing = min(25, victim.vessel.get_reagent_amount("blood"))
		if(drawing)
			victim.vessel.remove_reagent("blood", drawing)
			last_special = world.time

/obj/effect/plantsegment/proc/manual_unbuckle(mob/user as mob)
	var/list/atom/movable/locked = get_locked(/datum/locking_category/plantsegment)
	if(locked && locked.len)
		var/mob/M = locked[1]
		if(!user || !istype(user))
			user = M //Since the event sytem can't hot-potato arguments, for now, assume if noone's trying to free you, then you're trying to free yourself.
		if(prob(Clamp(140 - seed.potency, 20, 100)))
			if(M != user)
				M.visible_message(\
					"<span class='notice'>[user.name] frees [M.name] from \the [src].</span>",\
					"<span class='notice'>[user.name] frees you from [src].</span>",\
					"<span class='warning'>You hear shredding and ripping.</span>")
			else
				M.visible_message(\
					"<span class='notice'>[M.name] struggles free of [src].</span>",\
					"<span class='notice'>You untangle [src] from around yourself.</span>",\
					"<span class='warning'>You hear shredding and ripping.</span>")
			unlock_atom(M)
		else
			var/text = pick("rip","tear","pull")
			user.visible_message(\
				"<span class='notice'>[user.name] [text]s at \the [src].</span>",\
				"<span class='notice'>You [text] at \the [src].</span>",\
				"<span class='warning'>You hear shredding and ripping.</span>")
		user.delayNextAttack(5)

/obj/effect/plantsegment/lock_atom(var/mob/living/M)
	. = ..()
	if(!.)
		return

	if(!istype(M))
		return

	on_resist_key = M.on_resist.Add(src, "manual_unbuckle")

	last_special = world.time

/obj/effect/plantsegment/unlock_atom(var/mob/living/M)
	. = ..()
	if(!.)
		return

	if(!istype(M))
		return

	M.on_resist.Remove(on_resist_key)
	on_resist_key = null

/obj/effect/plantsegment/proc/entangle_mob(var/mob/living/victim)
	if(!victim || victim.locked_to || !seed || seed.spread != 2 || is_locking(/datum/locking_category/plantsegment)) //How much of this is actually necessary, I wonder
		return

	lock_atom(victim, /datum/locking_category/plantsegment)
	if(victim.stat != DEAD)
		to_chat(victim, "<span class='danger'>The vines [pick("wind", "tangle", "tighten")] around you!</span>")

/obj/effect/plantsegment/proc/grab_mob(var/mob/living/victim)
	if(!victim || victim.locked_to || !seed || seed.spread != 2 || is_locking(/datum/locking_category/plantsegment))
		return

	var/can_grab = 1
	if(istype(victim, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = victim
		if(istype(H.shoes, /obj/item/clothing/shoes/magboots) && (H.shoes.flags & NOSLIP))
			can_grab = 0
	if(can_grab)
		src.visible_message("<span class='danger'>Tendrils lash out from \the [src] and drag \the [victim] in!</span>")
		victim.forceMove(src.loc)
		lock_atom(victim, /datum/locking_category/plantsegment)

/datum/locking_category/plantsegment
