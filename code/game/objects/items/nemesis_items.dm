
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

/obj/item/nemesis_mine/attack_self(mob/user)
	if(!ishuman(user))
		return ..()

	var/mob/living/carbon/human/owner = user
	var/obj/item/clothing/gloves/rapid/nemesis/gloves = owner.get_item_by_slot(ITEM_SLOT_GLOVES)
	if(!gloves || !istype(gloves))
		return ..()

	if(overloaded)
		gloves.gain_charge(round(NEMESIS_CHARGE_PER_MINE * 0.5)) //Small refund
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
	var/disarm_time = 15 SECONDS
	if(ishuman(user))
		var/mob/living/carbon/human/disarmer = user
		if(istype(disarmer.get_item_by_slot(ITEM_SLOT_GLOVES), /obj/item/clothing/gloves/rapid/nemesis))
			disarm_time = 1 SECONDS

	if(!do_after(user, disarm_time, src))
		return
	active = FALSE
	icon_state = initial(icon_state)
	update_icon()
	anchored = FALSE
	to_chat(user, "<span class='notice'>You successfully disarm [src].</span>")

/obj/item/nemesis_mine/attackby(obj/O, mob/user, params)
	if(!active)
		return ..()

	if(!istype(O, /obj/item/screwdriver))
		return ..()

	to_chat(user, "<span class='warning'>You attempt to disarm [src]...</span>")
	var/disarm_time = 3 SECONDS
	if(ishuman(user))
		var/mob/living/carbon/human/disarmer = user
		if(istype(disarmer.get_item_by_slot(ITEM_SLOT_GLOVES), /obj/item/clothing/gloves/rapid/nemesis))
			disarm_time = 1 SECONDS

	if(!do_after(user, disarm_time, src))
		return

	active = FALSE
	icon_state = initial(icon_state)
	update_icon()
	anchored = FALSE
	to_chat(user, "<span class='notice'>You successfully disarm [src].</span>")


/obj/item/nemesis_mine/proc/trigger(mob/living/victim)
	var/turf/cur_loc = get_turf(src)
	new /obj/effect/temp_visual/nemesis_circle(cur_loc)

	if(!victim)
		victim = locate() in cur_loc

	if(victim)
		victim.apply_damage(75, STAMINA)
		to_chat(victim, "<span class='userdanger'>You trigger [src] and it explodes in shower of sparks!</span>")

	playsound(cur_loc, 'sound/magic/disable_tech.ogg', 50, TRUE)

	if(glasses && ishuman(glasses.loc))
		var/mob/living/carbon/human/owner = glasses.loc
		if(owner.get_item_by_slot(ITEM_SLOT_EYES) != glasses)
			return
		glasses.say("Attention: Tactical energy mine in [get_area(cur_loc)] has detonated.")

	qdel(src)

/obj/item/nemesis_mine/proc/trigger_overload()
	var/turf/cur_loc = get_turf(src)
	new /obj/effect/temp_visual/nemesis_circle/huge(cur_loc)
	playsound(cur_loc, 'sound/magic/disable_tech.ogg', 50, TRUE)
	for(var/mob/living/victim in range(1, cur_loc))
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
		playsound(src, 'sound/magic/blind.ogg', 50, TRUE)
		if(ishuman(throwingdatum.thrower))
			var/mob/living/carbon/human/owner = throwingdatum.thrower
			if(istype(owner.get_item_by_slot(ITEM_SLOT_EYES), /obj/item/clothing/glasses/hud/security/sunglasses/nemesis))
				glasses = owner.get_item_by_slot(ITEM_SLOT_EYES)

/obj/item/nemesis_mine/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return

	if(prob(35))
		trigger()

	var/datum/effect_system/spark_spread/sparks = new(get_turf(src))
	sparks.set_up(4, 0, loc)
	sparks.start()
	qdel(src)

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
	force = 3

	item_flags = SLOWS_WHILE_IN_HAND
	slowdown = 0

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
		slowdown = 2 //Heavy slowdown
	else
		force = initial(force)
		throwforce = initial(throwforce)
		throw_speed = initial(throw_speed)
		w_class = WEIGHT_CLASS_TINY
		playsound(user, 'sound/weapons/saberoff.ogg', 35, TRUE)
		to_chat(user, "<span class='notice'>[src] can now be concealed.</span>")
		slowdown = 0
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
		slowdown = 0

	if(istype(gloves))
		if(damage < 10)
			gloves.lose_charge(1)
			return
		gloves.lose_charge(round(damage * 0.1))

/obj/item/shield/energy/nemesis/IsReflect()
	if(!ishuman(loc))
		return (active)

	var/mob/living/carbon/human/owner = loc
	var/obj/item/clothing/gloves/rapid/nemesis/gloves = owner.get_item_by_slot(ITEM_SLOT_GLOVES)
	if(!gloves || !istype(gloves))
		return (active)

	if(gloves.charge < 2)
		if(active)
			active = !active
			icon_state = "[base_icon_state][active]"
			force = initial(force)
			w_class = WEIGHT_CLASS_TINY
			playsound(owner, 'sound/weapons/saberoff.ogg', 35, TRUE)
			to_chat(owner, "<span class='warning'>[src] turns off!</span>")
			slowdown = 0
		return FALSE

	gloves.lose_charge(2)

	return (active) && prob((gloves.charge + 2) / NEMESIS_MAX_CHARGE * 80) //Maximum 80% chance for the balance reasons

/obj/item/shield/energy/nemesis/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return

	if(active)
		active = !active
		icon_state = "[base_icon_state][active]"
		force = initial(force)
		w_class = WEIGHT_CLASS_TINY
		playsound(src, 'sound/weapons/saberoff.ogg', 35, TRUE)
		slowdown = 0

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
		slowdown = 0

	playsound(src, 'sound/mecha/mechmove03.ogg', 50, TRUE)
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
		slowdown = 0

	playsound(src, 'sound/mecha/mechmove03.ogg', 50, TRUE)
	user.dropItemToGround(src, TRUE)
	forceMove(gloves)

/obj/item/nemesis_trap
	name = "disk trap"
	desc = "A small disk with an energy clamp, designed to be placed on the walls."
	icon = 'icons/obj/nemesis.dmi'
	icon_state = "trap"
	w_class = WEIGHT_CLASS_SMALL
	item_flags = NO_PIXEL_RANDOM_DROP | NOBLUDGEON

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
		var/mob/living/carbon/human/owner = user
		if(istype(owner.get_item_by_slot(ITEM_SLOT_EYES), /obj/item/clothing/glasses/hud/security/sunglasses/nemesis))
			glasses = owner.get_item_by_slot(ITEM_SLOT_EYES)

	active = TRUE
	icon_state = "trap_deployed"
	dir = get_dir(target, user)
	user.dropItemToGround(src, TRUE)
	update_icon()
	anchored = TRUE
	playsound(src, 'sound/magic/blind.ogg', 50, TRUE)
	deploy_beams()

/obj/item/nemesis_trap/attack_hand(mob/living/user, list/modifiers)
	if(!active)
		return ..()

	to_chat(user, "<span class='warning'>You attempt to disarm [src]...</span>")
	var/disarm_time = 15 SECONDS
	if(ishuman(user))
		var/mob/living/carbon/human/disarmer = user
		if(istype(disarmer.get_item_by_slot(ITEM_SLOT_GLOVES), /obj/item/clothing/gloves/rapid/nemesis))
			disarm_time = 1 SECONDS

	if(!do_after(user, disarm_time, src))
		return

	to_chat(user, "<span class='notice'>You successfully disarm [src].</span>")
	qdel(src)

/obj/item/nemesis_trap/attackby(obj/O, mob/user, params)
	if(!active)
		return ..()

	if(!istype(O, /obj/item/screwdriver))
		return ..()

	to_chat(user, "<span class='warning'>You attempt to disarm [src]...</span>")
	var/disarm_time = 3 SECONDS
	if(ishuman(user))
		var/mob/living/carbon/human/disarmer = user
		if(istype(disarmer.get_item_by_slot(ITEM_SLOT_GLOVES), /obj/item/clothing/gloves/rapid/nemesis))
			disarm_time = 1 SECONDS

	if(!do_after(user, disarm_time, src))
		return

	to_chat(user, "<span class='notice'>You successfully disarm [src].</span>")
	qdel(src)

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
	var/datum/effect_system/spark_spread/sparks = new(get_turf(src))
	sparks.set_up(4, 0, loc)
	sparks.start()
	qdel(src)

/obj/item/nemesis_trap/Destroy()
	for(var/datum/beam/beam in beams)
		QDEL_NULL(beam)
	. = ..()

/obj/effect/ebeam/nemesis
	name = "energy beam"
	desc = "An energy beam, connected to a disk trap."

	mouse_opacity = MOUSE_OPACITY_ICON

/obj/effect/ebeam/nemesis/Crossed(atom/movable/AM)
	. = ..()
	if(isliving(AM))
		var/mob/living/target = AM
		if(target.body_position == LYING_DOWN)
			return

		var/turf/cur_loc = get_turf(src)
		var/obj/item/nemesis_trap/trap_one = owner.origin
		var/obj/item/nemesis_trap/trap_two = owner.target

		new /obj/effect/temp_visual/nemesis_circle/huge(cur_loc)

		to_chat(target, "<span class='userdanger'>You cross [src] and it destabilises, releasing a large energy blast!</span>")
		playsound(cur_loc, 'sound/magic/disable_tech.ogg', 50, TRUE)

		for(var/mob/living/victim in range(1, cur_loc))
			if(victim != target)
				to_chat(victim, "<span class='userdanger'>You are hit by an energy blast!</span>")
			victim.apply_damage(35, STAMINA)

		if(trap_one.glasses && ishuman(trap_one.glasses.loc))
			var/mob/living/carbon/human/owner = trap_one.glasses.loc
			if(owner.get_item_by_slot(ITEM_SLOT_EYES) == trap_one.glasses)
				trap_one.glasses.say("Attention: Disk trap in [get_area(cur_loc)] has detonated.")

		trap_one.trigger()
		trap_two.trigger()

/obj/item/nemesis_trap/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	trigger()

/obj/item/storage/box/nemesis_equipment
	icon_state = "black_box"

/obj/item/storage/box/nemesis_equipment/PopulateContents()
	new /obj/item/nemesis_trap(src)
	new /obj/item/nemesis_trap(src)
	new /obj/item/nemesis_trap(src)
	new /obj/item/nemesis_trap(src)
	new /obj/item/nemesis_mine(src)
	new /obj/item/nemesis_mine(src)
	new /obj/item/nemesis_mine(src)
	new /obj/item/nemesis_mine(src)
