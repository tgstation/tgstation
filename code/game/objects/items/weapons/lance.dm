/obj/item/weapon/melee/lance
	name = "tournament lance"
	desc = "A very long and heavy spear, used for jousting. "

	inhand_states = list("left_hand" = 'icons/mob/in-hand/left/96x96.dmi', "right_hand" = 'icons/mob/in-hand/right/96x96.dmi')
	item_state = "lance"

	icon = 'icons/obj/weapons.dmi'
	icon_state = "lance"

	force = 3
	w_class = 8

	attack_verb = list("bludgeoned", "whacked")

	var/list/default_attack_verbs = list("bludgeoned", "whacked")
	var/list/couch_attack_verbs = list("impaled", "stabbed")

	slowdown = 3.0 //Very heavy
	flags = SLOWDOWN_WHEN_CARRIED

	var/obj/effect/lance_trigger/trigger
	var/last_used = 0
	var/use_cooldown = 5 SECONDS

/obj/item/weapon/melee/lance/attack_self(mob/user)
	if(trigger)
		raise_lance(user)
	else
		if(world.time > last_used + use_cooldown)
			lower_lance(user)
		else
			to_chat(user, "<span class='warning'>You are not ready to couch \the [src] yet!</span>")

/obj/item/weapon/melee/lance/proc/lower_lance(mob/user)
	if(!trigger)
		trigger = new(null, usr, src)
		if(user) user.visible_message("<span class='danger'>[user] couches \the [src]!</span>", "<span class='notice'>You couch \the [src] and prepare to charge.</span>")
		item_state = "lance_lowered"
		force = initial(force)
		attack_verb = couch_attack_verbs

	if(isliving(loc))
		var/mob/living/owner = loc

		if(src == owner.l_hand)
			owner.update_inv_l_hand()
		else
			owner.update_inv_r_hand()

/obj/item/weapon/melee/lance/proc/raise_lance(mob/user)
	if(trigger)
		qdel(trigger)

	trigger = null

	if(user) user.visible_message("<span class='danger'>[user] raises \the [src].</span>", "<span class='notice'>You raise \the [src].</span>")
	item_state = "lance"
	force = initial(force)
	attack_verb = default_attack_verbs
	last_used = world.time

	if(isliving(loc))
		var/mob/living/owner = loc

		if(src == owner.l_hand)
			owner.update_inv_l_hand()
		else
			owner.update_inv_r_hand()

/obj/item/weapon/melee/lance/attack(mob/living/M, mob/living/user)
	if(istype(M) && trigger) //Lance is couched
		return trigger.Crossed(M)

	return ..()

/obj/effect/lance_trigger //This stays in front of the user (when the lance is lowered)
	name = "lance tip"
	desc = "Colliding with this is a bad idea"

	icon = 'icons/obj/weapons.dmi'
	icon_state = "toddler"

	invisibility = 101

	var/mob/living/owner
	var/obj/item/weapon/melee/lance/L

	var/amount_of_turfs_charged = -999 //Incremented by 1 on every forceMove().

/obj/effect/lance_trigger/New(loc, owner, lance)
	..()

	processing_objects.Add(src)
	src.owner = owner
	src.owner.lock_atom(src, y_offset = 1, rotate_offsets = 1) //1 turf in front of the player
	L = lance

	spawn()
		amount_of_turfs_charged = 0

/obj/effect/lance_trigger/Destroy()
	processing_objects.Remove(src)
	owner = null

	L.trigger = null
	L = null

	..()

/obj/effect/lance_trigger/process()
	if(!L)
		return qdel(src)

	if(!owner || !isturf(owner.loc))
		return L.raise_lance()

	if(amount_of_turfs_charged > 0 && (world.time - last_moved) >= 3)
		to_chat(owner, "<span class='notice'>You momentarily lose control of \the [L].</span>")
		L.raise_lance()
		return

/obj/effect/lance_trigger/forceMove(turf/new_loc)
	var/old_last_move = last_move //Old direction

	if(amount_of_turfs_charged > 0 && (world.time - last_moved) >= 3) //More than 2/10 of a second since last moved
		to_chat(owner, "<span class='notice'>You momentarily lose control of \the [L].</span>")
		L.raise_lance()
		return

	.=..()

	if(amount_of_turfs_charged > 0 && last_move != old_last_move) //Changed direction of the charge
		to_chat(owner, "<span class='notice'>You momentarily lose control of \the [L].</span>")
		L.raise_lance()
		return

	if(!L) return
	amount_of_turfs_charged++
	L.force += 3

	if(amount_of_turfs_charged > 0)
		if(istype(new_loc))
			for(var/mob/living/victim in new_loc)
				if(victim.lying) continue

				return Crossed(victim)

/obj/effect/lance_trigger/Crossed(atom/movable/O)
	if(!L || !owner) return qdel(src)
	if(L.loc != owner) return qdel(src)
	if(!isturf(owner.loc))
		L.raise_lance()
		return

	if(O != owner && isliving(O))
		var/mob/living/victim = O
		if(!victim.lying)
			var/base_damage = 3

			base_damage = min(base_damage * amount_of_turfs_charged, 72) //Max damage potential is reached at 34 turfs

			if(ishuman(victim))
				var/mob/living/carbon/human/H = victim
				var/datum/organ/external/affecting = H.get_organ(ran_zone(owner.zone_sel.selecting))

				if(H.check_shields(base_damage, "the couched lance"))
					H.visible_message("<span class='danger'>[H] blocks \the [owner]'s [src.L.name] hit.</span>", "<span class='notice'>You block \the [owner]'s couched [src.L.name].</span>")
					return

				victim.apply_damage(base_damage, BRUTE, affecting)
			else
				victim.apply_damage(base_damage, BRUTE)

			to_chat(owner, "<span class='danger'><i>DELIVERED COUCHED LANCE DAMAGE!</i></span>")
			victim.visible_message("<span class='danger'>[victim] has been impaled by [owner]'s [src.L.name]!</span>", "<span class='userdanger'>You were impaled by [owner]'s [src.L.name]!</span>")


			if(amount_of_turfs_charged >= 5)
				victim.Weaken(min(amount_of_turfs_charged-5, 5))//Stun begins at 5 charged turfs. Maximum effect at 10 charged turfs

			if(amount_of_turfs_charged >= 10)
				victim.throw_at(get_edge_target_turf(get_turf(victim), last_move), amount_of_turfs_charged * 0.25, 0.1)

			amount_of_turfs_charged -= 30
			if(amount_of_turfs_charged <= 0)
				L.raise_lance()

	return ..()
