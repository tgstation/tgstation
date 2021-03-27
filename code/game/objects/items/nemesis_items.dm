
/obj/item/nemesis_mine
	name = "energy mine"
	desc = "A high-tech trap, designed to electrocute any intruders that step on it."
	icon = 'icons/obj/nemesis.dmi'
	icon_state = "nemesis_trap_inactive"
	w_class = WEIGHT_CLASS_SMALL

	var/active = FALSE
	var/overloaded = FALSE
	var/obj/item/clothing/glasses/hud/security/sunglasses/nemesis/glasses

/obj/item/nemesis_mine/Crossed(mob/living/AM)
	. = ..()

	if(!istype(AM) || !isturf(loc) || !active)
		return

	if(AM.movement_type & FLYING)
		return

	trigger(AM)

/* //Uncomment if you want to remove overloading

/obj/item/nemesis_mine/attack_self(mob/user)
	to_chat(user, "<span class='notice'>You begin setting [src] up...</span>")
	if(!do_after(user, 3 SECONDS, src))
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(istype(H.get_item_by_slot(ITEM_SLOT_EYES), /obj/item/clothing/glasses/hud/security/sunglasses/nemesis))
			glasses = H.get_item_by_slot(ITEM_SLOT_EYES)

	active = TRUE
	icon_state = "trap_small"
	user.dropItemToGround(src, TRUE)
	update_icon()
	anchored = TRUE
	playsound(get_turf(src), 'sound/magic/blind.ogg', 50, TRUE) */

/obj/item/nemesis_mine/attack_self(mob/user)
	if(!ishuman(user))
		return ..()

	var/mob/living/carbon/human/H = user
	var/obj/item/clothing/gloves/rapid/nemesis/gloves = H.get_item_by_slot(ITEM_SLOT_GLOVES)
	if(!gloves || !istype(gloves))
		return ..()

	if(overloaded)
		gloves.gain_charge(NEMESIS_CHARGE_PER_MINE) //Refund
	else
		if(gloves.charge < NEMESIS_CHARGE_PER_MINE)
			to_chat(user, "<span class='warning'>Your A.R.E.S. suit does not posess enough charge to overload [src]! ([gloves.charge]/[NEMESIS_CHARGE_PER_MINE])</span>")
			return ..()

		gloves.lose_charge(NEMESIS_CHARGE_PER_MINE)

	overloaded = !overloaded
	to_chat(user, "<span class='notice'>You [overloaded ? "overload [src]'s detection system" : "return [src]'s circutry back to the normal state"].</span>")
	icon_state = "[overloaded ? "nemesis_trap" : "nemesis_trap_inactive"]"

/obj/item/nemesis_mine/attack_hand(mob/living/user, list/modifiers)
	if(!active)
		return ..()

	to_chat(user, "<span class='warning'>You attempt to disarm [src]...</span>")
	if(!do_after(user, 7 SECONDS, src))
		return
	active = FALSE
	icon_state = initial(icon_state)
	update_icon()
	anchored = FALSE
	to_chat(user, "<span class='notice'>You successfully disarm [src].</span>")

/obj/item/nemesis_mine/proc/trigger(mob/living/L)
	var/turf/T = get_turf(src)
	new /obj/effect/temp_visual/nemesis_circle(T)
	L.apply_damage(75, STAMINA)
	to_chat(L, "<span class='userdanger'>You trigger [src] and it explodes in shower of sparks!</span>")
	playsound(T, 'sound/magic/disable_tech.ogg', 50, TRUE)

	if(glasses && ishuman(glasses.loc))
		var/mob/living/carbon/human/H = glasses.loc
		if(H.get_item_by_slot(ITEM_SLOT_EYES) != glasses)
			return
		glasses.say("Attention: Tactical energy mine in [get_area(T)] has detonated.")

	qdel(src)

/obj/item/nemesis_mine/proc/trigger_overload()
	var/turf/T = get_turf(src)
	new /obj/effect/temp_visual/nemesis_circle/huge(T)
	playsound(T, 'sound/magic/disable_tech.ogg', 50, TRUE)
	for(var/mob/living/victim in range(1, T))
		to_chat(victim, "<span class='userdanger'>You are hit by an energy blast!</span>")
		victim.apply_damage(55, STAMINA)
	qdel(src)

/obj/item/nemesis_mine/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, quickstart = TRUE)
	. = ..()
	icon_state = "trap_small"

/obj/item/nemesis_mine/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..()) //If not caught, deploy
		if(overloaded)
			trigger_overload()
			return
		active = TRUE
		icon_state = "trap_small"
		update_icon()
		anchored = TRUE
		playsound(get_turf(src), 'sound/magic/blind.ogg', 50, TRUE)
		if(ishuman(throwingdatum.thrower))
			var/mob/living/carbon/human/H = throwingdatum.thrower
			if(istype(H.get_item_by_slot(ITEM_SLOT_EYES), /obj/item/clothing/glasses/hud/security/sunglasses/nemesis))
				glasses = H.get_item_by_slot(ITEM_SLOT_EYES)

/obj/effect/temp_visual/nemesis_circle
	name = "energy blast"
	icon = 'icons/obj/nemesis.dmi'
	icon_state = "trap_explosion"
	duration = 8

/obj/effect/temp_visual/nemesis_circle/huge
	name = "big energy blast"
	icon = 'icons/effects/96x96.dmi'
	icon_state = "nemesis_circle"
	duration = 5
	pixel_x = -32
	pixel_x = -32

/obj/item/shield/energy/nemesis
	name = "tactical energy shield"
	desc = "A tactical wrist-mounted energy shield from Nemesis Solutions."
	icon = 'icons/obj/nemesis.dmi'
	icon_state = "nemesis0"
	base_icon_state = "nemesis"
	throw_range = 0
	force = 3
	throwforce = 0
	throw_speed = 0

/obj/item/shield/energy/nemesis/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CLOTHING_TRAIT)

/obj/item/shield/energy/nemesis/attack_self(mob/living/carbon/human/user)
	if(clumsy_check && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		to_chat(user, "<span class='userdanger'>You beat yourself in the head with [src]!</span>")
		user.take_bodypart_damage(5)

	var/obj/item/clothing/gloves/rapid/nemesis/gloves = user.get_item_by_slot(ITEM_SLOT_GLOVES)
	if(!gloves || !istype(gloves))
		return FALSE

	if(!gloves.charge)
		to_chat(user, "<span class='warning'>[src] fails to activate without any charge avalible.</span>")
		return FALSE

	active = !active
	icon_state = "[base_icon_state][active]"

	if(active)
		force = on_force
		throwforce = on_throwforce
		throw_speed = on_throw_speed
		w_class = WEIGHT_CLASS_BULKY
		playsound(user, 'sound/weapons/saberon.ogg', 35, TRUE)
		to_chat(user, "<span class='notice'>[src] is now active.</span>")
	else
		force = initial(force)
		throwforce = initial(throwforce)
		throw_speed = initial(throw_speed)
		w_class = WEIGHT_CLASS_TINY
		playsound(user, 'sound/weapons/saberoff.ogg', 35, TRUE)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
	add_fingerprint(user)

/obj/item/shield/energy/nemesis/on_shield_block(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	var/obj/item/clothing/gloves/rapid/nemesis/gloves = owner.get_item_by_slot(ITEM_SLOT_GLOVES)
	if(!gloves || !istype(gloves) || gloves.charge <= round(damage / 10))
		active = !active
		icon_state = "[base_icon_state][active]"
		force = initial(force)
		w_class = WEIGHT_CLASS_TINY
		playsound(owner, 'sound/weapons/saberoff.ogg', 35, TRUE)
		to_chat(owner, "<span class='warning'>[src] turns off!</span>")

	if(istype(gloves))
		gloves.lose_charge(round(damage / 10))

/obj/item/shield/energy/nemesis/IsReflect()
	if(!ishuman(loc))
		return (active)

	var/mob/living/carbon/human/H = loc
	var/obj/item/clothing/gloves/rapid/nemesis/gloves = H.get_item_by_slot(ITEM_SLOT_GLOVES)
	if(!gloves || !istype(gloves))
		return (active)

	if(gloves.charge < 2)
		if(active)
			active = !active
			icon_state = "[base_icon_state][active]"
			force = initial(force)
			w_class = WEIGHT_CLASS_TINY
			playsound(H, 'sound/weapons/saberoff.ogg', 35, TRUE)
			to_chat(H, "<span class='warning'>[src] turns off!</span>")
		return FALSE

	gloves.lose_charge(2)

	return (active) && prob((gloves.charge + 2) / NEMESIS_MAX_CHARGE * 100)

/obj/item/shield/energy/nemesis/AltClick(mob/user)
	if(!ishuman(user))
		return

	var/mob/living/carbon/human/owner = user
	var/obj/item/clothing/gloves/rapid/nemesis/gloves = owner.get_item_by_slot(ITEM_SLOT_GLOVES)
	if(!gloves || !istype(gloves) || gloves.shield != src)
		return

	if(active)
		active = !active
		icon_state = "[base_icon_state][active]"
		force = initial(force)
		w_class = WEIGHT_CLASS_TINY
		playsound(owner, 'sound/weapons/saberoff.ogg', 35, TRUE)

	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, TRUE)
	user.dropItemToGround(src, TRUE)
	forceMove(gloves)

/obj/item/shield/energy/nemesis/afterattack(atom/target, mob/user, proximity, click_parameters)
	if(!istype(target, /obj/item/clothing/gloves/rapid/nemesis))
		return ..()

	var/obj/item/clothing/gloves/rapid/nemesis/gloves = target
	if(gloves.shield != src)
		return

	if(active)
		active = !active
		icon_state = "[base_icon_state][active]"
		force = initial(force)
		w_class = WEIGHT_CLASS_TINY
		playsound(user, 'sound/weapons/saberoff.ogg', 35, TRUE)

	playsound(src.loc, 'sound/mecha/mechmove03.ogg', 50, TRUE)
	user.dropItemToGround(src, TRUE)
	forceMove(gloves)

/obj/item/nemesis_trap
	name = "disk trap"
	desc = "A small disk with an energy clamp, designed to be placed on the walls."
	icon = 'icons/obj/nemesis.dmi'
	icon_state = "trap"
	w_class = WEIGHT_CLASS_SMALL

	var/active = FALSE
	var/obj/item/clothing/glasses/hud/security/sunglasses/nemesis/glasses
	var/list/beams = list()

/obj/item/nemesis_trap/afterattack(atom/target, mob/user, proximity, click_parameters)
	if(!istype(target, /turf/closed))
		return ..()

	to_chat(user, "<span class='notice'>You begin setting [src] up...</span>")
	if(!do_after(user, 3 SECONDS, src))
		return ..()

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(istype(H.get_item_by_slot(ITEM_SLOT_EYES), /obj/item/clothing/glasses/hud/security/sunglasses/nemesis))
			glasses = H.get_item_by_slot(ITEM_SLOT_EYES)

	active = TRUE
	icon_state = "trap_deployed"
	dir = get_dir(target, user)
	user.dropItemToGround(src, TRUE)
	update_icon()
	anchored = TRUE
	pixel_x = 0
	pixel_y = 0
	playsound(get_turf(src), 'sound/magic/blind.ogg', 50, TRUE)
	deploy_beams()

/obj/item/nemesis_trap/proc/deploy_beams()
	for(var/obj/item/nemesis_trap/trap in view(3, get_turf(src)))
		if(trap == src || !trap.active)
			continue

		icon_state = "trap_deployed_active"
		update_icon()

		trap.icon_state = "trap_deployed_active"
		trap.update_icon()

		var/datum/beam/beam = Beam(trap, "nemesis", maxdistance = 5, beam_type = /obj/effect/ebeam/nemesis)
		beams += beam
		trap.beams += beam

/obj/item/nemesis_trap/proc/trigger()
	for(var/datum/beam/beam in beams)
		qdel(beam)
	qdel(src)

/obj/effect/ebeam/nemesis
	name = "energy beam"
	desc = "An energy beam, connected to a disk trap."

	mouse_opacity = MOUSE_OPACITY_ICON

/obj/effect/ebeam/nemesis/Crossed(atom/movable/AM)
	. = ..()
	if(isliving(AM))
		var/mob/living/L = AM
		if(L.body_position == LYING_DOWN)
			return

		var/turf/T = get_turf(src)
		var/obj/item/nemesis_trap/trap_one = owner.origin
		var/obj/item/nemesis_trap/trap_two = owner.target

		new /obj/effect/temp_visual/nemesis_circle/huge(T)

		to_chat(L, "<span class='userdanger'>You cross [src] and it destabilises, releasing a large energy blast!</span>")
		playsound(T, 'sound/magic/disable_tech.ogg', 50, TRUE)

		for(var/mob/living/victim in range(1, T))
			if(victim != L)
				to_chat(victim, "<span class='userdanger'>You are hit by an energy blast!</span>")
			victim.apply_damage(35, STAMINA)

		if(trap_one.glasses && ishuman(trap_one.glasses.loc))
			var/mob/living/carbon/human/H = trap_one.glasses.loc
			if(H.get_item_by_slot(ITEM_SLOT_EYES) == trap_one.glasses)
				trap_one.glasses.say("Attention: Disk trap in [get_area(T)] has detonated.")

		trap_one.trigger()
		trap_two.trigger()
