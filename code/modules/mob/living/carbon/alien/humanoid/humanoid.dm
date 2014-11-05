/mob/living/carbon/alien/humanoid
	name = "alien"
	icon_state = "alien_s"
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/caste = ""
	var/leap_on_click = 0
	update_icon = 1

//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/humanoid/New()
	create_reagents(1000)
	if(name == "alien")
		name = text("alien ([rand(1, 1000)])")
	real_name = name
	..()

//This is fine, works the same as a human
/mob/living/carbon/alien/humanoid/Bump(atom/movable/AM as mob|obj, yes)
	if ((!( yes ) || now_pushing))
		return
	now_pushing = 0
	..()
	if (!istype(AM, /atom/movable))
		return

	if (ismob(AM))
		var/mob/tmob = AM
		tmob.LAssailant = src

	if (!now_pushing)
		now_pushing = 1
		if (!AM.anchored)
			var/t = get_dir(src, AM)
			if (istype(AM, /obj/structure/window))
				if(AM:ini_dir == NORTHWEST || AM:ini_dir == NORTHEAST || AM:ini_dir == SOUTHWEST || AM:ini_dir == SOUTHEAST)
					for(var/obj/structure/window/win in get_step(AM,t))
						now_pushing = 0
						return
			step(AM, t)
		now_pushing = null

/mob/living/carbon/alien/humanoid/movement_delay()
	. = ..()
	. += move_delay_add + config.alien_delay	//move_delay_add is used to slow aliens with stuns

///mob/living/carbon/alien/humanoid/bullet_act(var/obj/item/projectile/Proj) taken care of in living

/mob/living/carbon/alien/humanoid/emp_act(severity)
	if(r_store) r_store.emp_act(severity)
	if(l_store) l_store.emp_act(severity)
	..()

/mob/living/carbon/alien/humanoid/ex_act(severity)
	..()

	var/shielded = 0

	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if (1.0)
			gib()
			return

		if (2.0)
			if (!shielded)
				b_loss += 60

			f_loss += 60

			ear_damage += 30
			ear_deaf += 120

		if(3.0)
			b_loss += 30
			if (prob(50) && !shielded)
				Paralyse(1)
			ear_damage += 15
			ear_deaf += 60

	adjustBruteLoss(b_loss)
	adjustFireLoss(f_loss)

	updatehealth()

/mob/living/carbon/alien/humanoid/blob_act()
	if (stat == 2)
		return
	var/shielded = 0
	var/damage = null
	if (stat != 2)
		damage = rand(30,40)

	if(shielded)
		damage /= 4

	show_message("<span class='userdanger'>The blob attacks!</span>")
	adjustFireLoss(damage)
	return


/mob/living/carbon/alien/humanoid/attack_slime(mob/living/carbon/slime/M as mob)
	..()
	var/damage = rand(5, 35)
	if(M.is_adult)
		damage = rand(10, 40)
	adjustBruteLoss(damage)
	add_logs(M, src, "attacked", admin=0)
	updatehealth()
	return

/mob/living/carbon/alien/humanoid/attack_hand(mob/living/carbon/human/M as mob)
	if(..())
		switch(M.a_intent)
			if ("harm")
				var/damage = rand(1, 9)
				if (prob(90))
					if (HULK in M.mutations)//HULK SMASH
						damage += 14
						spawn(0)
							Paralyse(1)
							step_away(src,M,15)
							sleep(3)
							step_away(src,M,15)
					playsound(loc, "punch", 25, 1, -1)
					visible_message("<span class='danger'>[M] has punched [src]!</span>", \
							"<span class='userdanger'>[M] has punched [src]!</span>")
					if ((stat != DEAD) && (damage > 9 || prob(5)))//Regular humans have a very small chance of weakening an alien.
						Paralyse(2)
						visible_message("<span class='danger'>[M] has weakened [src]!</span>", \
								"<span class='userdanger'>[M] has weakened [src]!</span>")
					adjustBruteLoss(damage)
					add_logs(M, src, "attacked", admin=0)
					updatehealth()
				else
					playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
					visible_message("<span class='danger'>[M] has attempted to punch [src]!</span>")

			if ("disarm")
				if (!lying)
					if (prob(5))
						Paralyse(2)
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						add_logs(M, src, "pushed", admin=0)
						visible_message("<span class='danger'>[M] has pushed down [src]!</span>", \
							"<span class='userdanger'>[M] has pushed down [src]!</span>")
					else
						if (prob(50))
							drop_item()
							playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
							visible_message("<span class='danger'>[M] has disarmed [src]!</span>", \
							"<span class='userdanger'>[M] has disarmed [src]!</span>")
						else
							playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
							visible_message("<span class='danger'>[M] has attempted to disarm [src]!</span>")



/mob/living/carbon/alien/humanoid/restrained()
	if (handcuffed)
		return 1
	return 0


/mob/living/carbon/alien/humanoid/var/co2overloadtime = null
/mob/living/carbon/alien/humanoid/var/temperature_resistance = T0C+75


/mob/living/carbon/alien/humanoid/show_inv(mob/user)
	user.set_machine(src)
	var/dat = {"
	<HR>
	<B><FONT size=3>[name]</FONT></B>
	<HR>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=[slot_l_hand]'>		[l_hand		? l_hand	: "Nothing"]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=[slot_r_hand]'>		[r_hand		? r_hand	: "Nothing"]</A>
	<BR><A href='?src=\ref[src];pouches=1'>Empty Pouches</A>"}

	if(handcuffed)
		dat += "<BR><A href='?src=\ref[src];item=[slot_handcuffed]'>Handcuffed</A>"
	if(legcuffed)
		dat += "<BR><A href='?src=\ref[src];item=[slot_legcuffed]'>Legcuffed</A>"

	dat += {"
	<BR>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	"}
	user << browse(dat, "window=mob\ref[src];size=325x500")
	onclose(user, "mob\ref[src]")


/mob/living/carbon/alien/humanoid/Topic(href, href_list)
	..()
	//strip panel
	if(usr.canUseTopic(src, BE_CLOSE, NO_DEXTERY))
		if(href_list["pouches"])
			visible_message("<span class='danger'>[usr] tries to empty [src]'s pouches.</span>", \
							"<span class='userdanger'>[usr] tries to empty [src]'s pouches.</span>")
			if(do_mob(usr, src, POCKET_STRIP_DELAY * 0.5))
				unEquip(r_store)
				unEquip(l_store)
