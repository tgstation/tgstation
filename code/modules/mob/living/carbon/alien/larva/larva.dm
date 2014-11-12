/mob/living/carbon/alien/larva
	name = "alien larva"
	real_name = "alien larva"
	icon_state = "larva0"
	pass_flags = PASSTABLE | PASSMOB
	mob_size = 0

	maxHealth = 25
	health = 25
	storedPlasma = 50
	max_plasma = 50

	var/amount_grown = 0
	var/max_grown = 200
	var/time_of_birth

//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/larva/New()
	create_reagents(100)
	if(name == "alien larva")
		name = "alien larva ([rand(1, 1000)])"
	real_name = name
	regenerate_icons()
	..()

//This is fine, works the same as a human
/mob/living/carbon/alien/larva/Bump(atom/movable/AM as mob|obj, yes)
	if ((!( yes ) || now_pushing))
		return
	now_pushing = 1
	if(ismob(AM))
		var/mob/tmob = AM
		tmob.LAssailant = src

	now_pushing = 0
	..()
	if (!istype(AM, /atom/movable))
		return
	if (!( now_pushing ))
		now_pushing = 1
		if (!( AM.anchored ))
			var/t = get_dir(src, AM)
			step(AM, t)
		now_pushing = null


//This needs to be fixed
/mob/living/carbon/alien/larva/Stat()
	..()
	stat(null, "Progress: [amount_grown]/[max_grown]")

/mob/living/carbon/alien/larva/adjustToxLoss(amount)
	if(stat != DEAD)
		amount_grown = min(amount_grown + 1, max_grown)
	..(amount)


/mob/living/carbon/alien/larva/ex_act(severity)
	..()

	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if (1.0)
			gib()
			return

		if (2.0)

			b_loss += 60

			f_loss += 60

			ear_damage += 30
			ear_deaf += 120

		if(3.0)
			b_loss += 30
			if (prob(50))
				Paralyse(1)
			ear_damage += 15
			ear_deaf += 60

	adjustBruteLoss(b_loss)
	adjustFireLoss(f_loss)

	updatehealth()



/mob/living/carbon/alien/larva/blob_act()
	if (stat == 2)
		return
	var/shielded = 0

	var/damage = null
	if (stat != 2)
		damage = rand(10,30)

	if(shielded)
		damage /= 4

		//paralysis += 1

	show_message("<span class='userdanger'>The blob attacks you!</span>")

	adjustFireLoss(damage)

	updatehealth()
	return


//can't equip anything
/mob/living/carbon/alien/larva/attack_ui(slot_id)
	return

/mob/living/carbon/alien/larva/attack_slime(mob/living/carbon/slime/M as mob)

	..()
	var/damage = rand(5, 35)
	if(M.is_adult)
		damage = rand(20, 40)
	adjustBruteLoss(damage)
	add_logs(M, src, "attacked", admin=0)
	updatehealth()
	return

/mob/living/carbon/alien/larva/attack_hand(mob/living/carbon/human/M as mob)
	if(..())
		var/damage = rand(1, 9)
		if (prob(90))
			if (HULK in M.mutations)
				damage += 5
				spawn(0)
					Paralyse(1)
					step_away(src,M,15)
					sleep(3)
					step_away(src,M,15)
			playsound(loc, "punch", 25, 1, -1)
			add_logs(M, src, "attacked", admin=0)
			visible_message("<span class='danger'>[M] has kicked [src]!</span>", \
					"<span class='userdanger'>[M] has kicked [src]!</span>")
			if ((stat != DEAD) && (damage > 4.9))
				Paralyse(rand(5,10))

			adjustBruteLoss(damage)
			updatehealth()
		else
			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			visible_message("<span class='danger'>[M] has attempted to kick [src]!</span>", \
					"<span class='userdanger'>[M] has attempted to kick [src]!</span>")

	return

/mob/living/carbon/alien/larva/restrained()
	return 0

/mob/living/carbon/alien/larva/var/co2overloadtime = null
/mob/living/carbon/alien/larva/var/temperature_resistance = T0C+75

// new damage icon system
// now constructs damage icon for each organ from mask * damage field


/mob/living/carbon/alien/larva/show_inv(mob/user)
	return

/mob/living/carbon/alien/larva/toggle_throw_mode()
	return

/mob/living/carbon/alien/larva/start_pulling()
	return

/* Commented out because it's duplicated in life.dm
/mob/living/carbon/alien/larva/proc/grow() // Larvae can grow into full fledged Xenos if they survive long enough
	if(icon_state == "larva_l" && !canmove) // This is a shit death check. It is made of shit and death. Fix later.
		return
	else
		var/mob/living/carbon/alien/humanoid/A = new(loc)
		A.key = key
		qdel(src) */

/mob/living/carbon/alien/larva/stripPanelUnequip(obj/item/what, mob/who)
	src << "<span class='warning'>You don't have the dexterity to do this!</span>"
	return

/mob/living/carbon/alien/larva/stripPanelEquip(obj/item/what, mob/who)
	src << "<span class='warning'>You don't have the dexterity to do this!</span>"
	return
