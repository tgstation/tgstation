<<<<<<< HEAD
/mob/living/carbon/alien/humanoid
	name = "alien"
	icon_state = "alien_s"
	pass_flags = PASSTABLE
	butcher_results = list(/obj/item/weapon/reagent_containers/food/snacks/meat/slab/xeno = 5, /obj/item/stack/sheet/animalhide/xeno = 1)
	limb_destroyer = 1
	var/obj/item/r_store = null
	var/obj/item/l_store = null
	var/caste = ""
	var/alt_icon = 'icons/mob/alienleap.dmi' //used to switch between the two alien icon files.
	var/leap_on_click = 0
	var/pounce_cooldown = 0
	var/pounce_cooldown_time = 30
	var/custom_pixel_x_offset = 0 //for admin fuckery.
	var/custom_pixel_y_offset = 0
	var/sneaking = 0 //For sneaky-sneaky mode and appropriate slowdown

//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/humanoid/New()
	AddAbility(new/obj/effect/proc_holder/alien/regurgitate(null))
	..()


/mob/living/carbon/alien/humanoid/movement_delay()
	. = ..()
	. += move_delay_add + config.alien_delay + sneaking	//move_delay_add is used to slow aliens with stuns

/mob/living/carbon/alien/humanoid/emp_act(severity)
	if(r_store) r_store.emp_act(severity)
	if(l_store) l_store.emp_act(severity)
	..()

/mob/living/carbon/alien/humanoid/attack_hulk(mob/living/carbon/human/user)
	if(user.a_intent == "harm")
		..(user, 1)
		adjustBruteLoss(15)
		var/hitverb = "punched"
		if(mob_size < MOB_SIZE_LARGE)
			Paralyse(1)
			step_away(src,user,15)
			sleep(1)
			step_away(src,user,15)
			hitverb = "slammed"
		playsound(loc, "punch", 25, 1, -1)
		visible_message("<span class='danger'>[user] has [hitverb] [src]!</span>", \
		"<span class='userdanger'>[user] has [hitverb] [src]!</span>")
		return 1

/mob/living/carbon/alien/humanoid/attack_hand(mob/living/carbon/human/M)
	if(..())
		switch(M.a_intent)
			if ("harm")
				var/damage = rand(1, 9)
				if (prob(90))
					playsound(loc, "punch", 25, 1, -1)
					visible_message("<span class='danger'>[M] has punched [src]!</span>", \
							"<span class='userdanger'>[M] has punched [src]!</span>")
					if ((stat != DEAD) && (damage > 9 || prob(5)))//Regular humans have a very small chance of weakening an alien.
						Paralyse(2)
						visible_message("<span class='danger'>[M] has weakened [src]!</span>", \
								"<span class='userdanger'>[M] has weakened [src]!</span>")
					adjustBruteLoss(damage)
					add_logs(M, src, "attacked")
					updatehealth()
				else
					playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
					visible_message("<span class='danger'>[M] has attempted to punch [src]!</span>")

			if ("disarm")
				if (!lying)
					if (prob(5))
						Paralyse(2)
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						add_logs(M, src, "pushed")
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

/mob/living/carbon/alien/humanoid/restrained(ignore_grab)
	. = handcuffed


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

/mob/living/carbon/alien/humanoid/cuff_resist(obj/item/I)
	playsound(src, 'sound/voice/hiss5.ogg', 40, 1, 1)  //Alien roars when starting to break free
	..(I, cuff_break = INSTANT_CUFFBREAK)

/mob/living/carbon/alien/humanoid/resist_grab(moving_resist)
	if(pulledby.grab_state)
		visible_message("<span class='danger'>[src] has broken free of [pulledby]'s grip!</span>")
	pulledby.stop_pulling()
	. = 0

/mob/living/carbon/alien/humanoid/get_standard_pixel_y_offset(lying = 0)
	if(leaping)
		return -32
	else if(custom_pixel_y_offset)
		return custom_pixel_y_offset
	else
		return initial(pixel_y)

/mob/living/carbon/alien/humanoid/get_standard_pixel_x_offset(lying = 0)
	if(leaping)
		return -32
	else if(custom_pixel_x_offset)
		return custom_pixel_x_offset
	else
		return initial(pixel_x)

/mob/living/carbon/alien/humanoid/check_ear_prot()
	return 1

/mob/living/carbon/alien/humanoid/get_permeability_protection()
	return 0.8

/mob/living/carbon/alien/humanoid/alien_evolve(mob/living/carbon/alien/humanoid/new_xeno)
	drop_l_hand()
	drop_r_hand()
	for(var/atom/movable/A in stomach_contents)
		stomach_contents.Remove(A)
		new_xeno.stomach_contents.Add(A)
		A.loc = new_xeno
	..()

//For alien evolution/promotion/queen finder procs. Checks for an active alien of that type
proc/get_alien_type(var/alienpath)
	for(var/mob/living/carbon/alien/humanoid/A in living_mob_list)
		if(!istype(A, alienpath))
			continue
		if(!A.key || A.stat == DEAD) //Only living aliens with a ckey are valid.
			continue
		return A
	return FALSE


/mob/living/carbon/alien/humanoid/check_breath(datum/gas_mixture/breath)
	if(breath && breath.total_moles() > 0 && !sneaking)
		playsound(get_turf(src), pick('sound/voice/lowHiss2.ogg', 'sound/voice/lowHiss3.ogg', 'sound/voice/lowHiss4.ogg'), 50, 0, -5)
	..()

/mob/living/carbon/alien/humanoid/grabbedby(mob/living/carbon/user, supress_message = 0)
	if(user == src && pulling && grab_state >= GRAB_AGGRESSIVE && !pulling.anchored && iscarbon(pulling))
		devour_mob(pulling, devour_time = 60)
	else
		..()
=======
/mob/living/carbon/alien/humanoid
	name = "alien"
	icon_state = "alien_s"

	var/obj/item/clothing/suit/wear_suit = null		//TODO: necessary? Are they even used? ~Carn
	var/obj/item/clothing/head/head = null			//
	var/obj/item/weapon/r_store = null
	var/obj/item/weapon/l_store = null
	var/caste = ""
	update_icon = 1

	species_type = /mob/living/carbon/alien/humanoid

//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/humanoid/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien")
		name = text("alien ([rand(1, 1000)])")
	real_name = name
	..()

/mob/living/carbon/alien/humanoid/emp_act(severity)
	if(flags & INVULNERABLE)
		return

	if(wear_suit) wear_suit.emp_act(severity)
	if(head) head.emp_act(severity)
	if(r_store) r_store.emp_act(severity)
	if(l_store) l_store.emp_act(severity)
	..()

/mob/living/carbon/alien/humanoid/ex_act(severity)
	if(flags & INVULNERABLE)
		return

	if(!blinded)
		flash_eyes(visual = 1)

	var/shielded = 0

	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if(1.0)
			b_loss += 500
			gib()
			return

		if(2.0)
			if(!shielded)
				b_loss += 60
			f_loss += 60
			ear_damage += 30
			ear_deaf += 120

		if(3.0)
			b_loss += 30
			if(prob(50) && !shielded)
				Paralyse(1)
			ear_damage += 15
			ear_deaf += 60

	adjustBruteLoss(b_loss)
	adjustFireLoss(f_loss)

	updatehealth()

/mob/living/carbon/alien/humanoid/blob_act()
	if(flags & INVULNERABLE)
		return
	if(stat == DEAD)
		return
	..()
	playsound(loc, 'sound/effects/blobattack.ogg',50,1)
	var/shielded = 0
	var/damage = null
	if(stat != 2)
		damage = rand(30,40)

	if(shielded)
		damage /= 4

	to_chat(src, "<span class='warning'>The blob attacks you!</span>")


	adjustFireLoss(damage)

	return

/mob/living/carbon/alien/humanoid/attack_paw(mob/living/carbon/monkey/M as mob)
	if(!ismonkey(M))
		return//Fix for aliens receiving double messages when attacking other aliens.

	if(!ticker)
		to_chat(M, "<span class='warning'>You cannot attack people before the game has started.</span>")
		return

	/*
	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return
	*/
	..()

	switch(M.a_intent)

		if(I_HELP)
			help_shake_act(M)
		else
			if(istype(wear_mask, /obj/item/clothing/mask/muzzle))
				return
			if(health > 0)
				playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
				visible_message("<span class='danger'>\The [M] has bit \the [src]!</span>")
				adjustBruteLoss(rand(1, 3))
				updatehealth()
	return


/mob/living/carbon/alien/humanoid/attack_slime(mob/living/carbon/slime/M as mob)
	if(!ticker)
		to_chat(M, "<span class='warning'>You cannot attack people before the game has started.</span>")
		return

	if(M.Victim) return // can't attack while eating!

	if(health > -100)
		visible_message("<span class='danger'>\The [M] glomps [src]!</span>")
		add_logs(M, src, "glomped on", 0)

		var/damage = rand(1, 3)

		if(istype(M, /mob/living/carbon/slime/adult))
			damage = rand(10, 40)
		else
			damage = rand(5, 35)

		adjustBruteLoss(damage)

		if(M.powerlevel > 0)
			var/stunprob = 10
			var/power = M.powerlevel + rand(0,3)

			switch(M.powerlevel)
				if(1 to 2) stunprob = 20
				if(3 to 4) stunprob = 30
				if(5 to 6) stunprob = 40
				if(7 to 8) stunprob = 60
				if(9) 	   stunprob = 70
				if(10) 	   stunprob = 95

			if(prob(stunprob))
				M.powerlevel -= 3
				if(M.powerlevel < 0)
					M.powerlevel = 0
				visible_message("<span class='danger'>\The [M] has shocked [src]!</span>")

				Weaken(power)
				if(stuttering < power)
					stuttering = power
				Stun(power)

				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()

				if(prob(stunprob) && M.powerlevel >= 8)
					adjustFireLoss(M.powerlevel * rand(6,10))

		updatehealth()
	return

//using the default attack_animal() in carbon.dm

/mob/living/carbon/alien/humanoid/attack_hand(mob/living/carbon/human/M as mob)
	if(!ticker)
		to_chat(M, "<span class='warning'>You cannot attack people before the game has started.</span>")
		return

	/*
	if(istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return
	*/

	..()

	if(M.gloves && istype(M.gloves,/obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.cell)
			if(M.a_intent == I_HURT)//Stungloves. Any contact will stun the alien.
				if(G.cell.charge >= 2500)
					G.cell.charge -= 2500

					Weaken(5)
					if(stuttering < 5)
						stuttering = 5
					Stun(5)
					visible_message("<span class='danger'>\The [src] has been touched with the stun gloves by [M] !</span>")
					return
				else
					to_chat(M, "<span class='warning'>Not enough charge !</span>")
					return

	switch(M.a_intent)

		if(I_HELP)
			if(health >= config.health_threshold_crit)
				help_shake_act(M)
				return 1
			else
				if(M.check_body_part_coverage(MOUTH))
					to_chat(M, "<span class='notice'><B>Remove your [M.get_body_part_coverage(MOUTH)]!</B></span>")
					return 0

				if (!cpr_time)
					return 0

				M.visible_message("<span class='danger'>\The [M] is trying perform CPR on \the [src]!</span>")

				cpr_time = 0
				if(do_after(M, src, 3 SECONDS))
					adjustOxyLoss(-min(getOxyLoss(), 7))
					M.visible_message("<span class='danger'>\The [M] performs CPR on \the [src]!</span>")
					to_chat(src, "<span class='notice'>You feel a breath of fresh air enter your lungs. It feels good.</span>")
					to_chat(M, "<span class='warning'>Repeat at least every 7 seconds.</span>")
				cpr_time = 1

		if(I_GRAB)
			if(M == src)
				return
			var/obj/item/weapon/grab/G = getFromPool(/obj/item/weapon/grab,M, src)

			M.put_in_active_hand(G)

			grabbed_by += G
			G.synch()

			LAssailant = M

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			visible_message("<span class='warning'>[M] has grabbed \the [src] passively!</span>")

		if(I_HURT)
			var/damage = rand(1, 9)
			if(prob(90))
				if(M_HULK in M.mutations) //M_HULK SMASH
					damage += 14
					spawn(0)
						Weaken(damage) //Why can a hulk knock an alien out but not knock out a human? Damage is robust enough.
						step_away(src, M, 15)
						sleep(3)
						step_away(src, M, 15)
				playsound(loc, "punch", 25, 1, -1)
				visible_message("<span class='danger'>[M] has punched \the [src] !</span>")
				if(damage > 9 ||prob(5))//Regular humans have a very small chance of weakening an alien.
					Weaken(1, 5)
					visible_message("<span class='danger'>[M] has weakened \the [src] !</span>")
				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] has attempted to punch \the [src] !</span>")

		if(I_DISARM)
			if(!lying)
				if(prob(5)) //Very small chance to push an alien down.
					Weaken(2)
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					visible_message("<span class='danger'>[M] has pushed down \the [src] !</span>")
				else
					if(prob(50))
						drop_item()
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						visible_message("<span class='danger'>[M] has disarmed \the [src] !</span>")
					else
						playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
						visible_message("<span class='danger'>[M] has attempted to disarm \the [src] !</span>")
	return

/*Code for aliens attacking aliens. Because aliens act on a hivemind, I don't see them as very aggressive with each other.
As such, they can either help or harm other aliens. Help works like the human help command while harm is a simple nibble.
In all, this is a lot like the monkey code. /N
*/

/mob/living/carbon/alien/humanoid/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if(!ticker)
		to_chat(M, "<span class='warning'>You cannot attack people before the game has started.</span>")
		return

	/*
	if(istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return
	*/
	..()

	switch(M.a_intent)

		if(I_HELP)
			sleeping = max(0,sleeping-5)
			resting = 0
			AdjustParalysis(-3)
			AdjustStunned(-3)
			AdjustWeakened(-3)
			visible_message("<span class='notice'>[M] nuzzles [src] trying to wake it up !</span>")
		else
			if(health > 0)
				playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
				var/damage = rand(1, 3)
				visible_message("<span class='danger'>\The [M] has bit [src]!</span>")
				adjustBruteLoss(damage)
				updatehealth()
			else
				to_chat(M, "<span class='alien'>[name] is too injured for that.</span>")
	return


/mob/living/carbon/alien/humanoid/restrained()
	if(timestopped) return 1 //under effects of time magick
	if (handcuffed)
		return 1
	return 0


/mob/living/carbon/alien/humanoid/var/co2overloadtime = null
/mob/living/carbon/alien/humanoid/var/temperature_resistance = T0C+75

/mob/living/carbon/alien/humanoid/show_inv(mob/user as mob)
	user.set_machine(src)
	var/pickpocket = user.isGoodPickpocket()
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR>"}

	for(var/i = 1 to held_items.len) //Hands
		var/obj/item/I = held_items[i]
		dat += "<B>[capitalize(get_index_limb_name(i))]</B> <A href='?src=\ref[src];hands=[i]'>[makeStrippingButton(I)]</A><BR>"

	dat += "<BR><B>Head:</B> <A href='?src=\ref[src];item=[slot_head]'>[makeStrippingButton(head)]</A>"
	dat += "<BR><B>Exosuit:</B> <A href='?src=\ref[src];item=[slot_wear_suit]'>[makeStrippingButton(wear_suit)]</A>"
	if(pickpocket)
		dat += "<BR><B>Left pouch:</B> <A href='?src=\ref[src];pockets=left'>[(l_store && !(src.l_store.abstract)) ? l_store : "<font color=grey>Left (Empty)</font>"]</A>"
		dat += " <A href='?src=\ref[src];pockets=right'>[(r_store && !(src.r_store.abstract)) ? r_store : "<font color=grey>Right (Empty)</font>"]</A>"
	else
		dat += "<BR><B>Right pouch:</B> <A href='?src=\ref[src];pockets=left'>[(l_store && !(src.l_store.abstract)) ? "Left (Full)" : "<font color=grey>Left (Empty)</font>"]</A>"
		dat += " <A href='?src=\ref[src];pockets=right'>[(r_store && !(src.r_store.abstract)) ? "Right (Full)" : "<font color=grey>Right (Empty)</font>"]</A>"
	dat += "<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A><BR>"

	user << browse(dat, text("window=mob\ref[src];size=340x480"))
	onclose(user, "mob\ref[src]")
	return

/mob/living/carbon/alien/humanoid/Topic(href, href_list)
	. = ..()
	if(href_list["pockets"]) //href_list "pockets" would be "left" or "right"
		if(usr.incapacitated() || !Adjacent(usr)|| isanimal(usr))
			return
		handle_strip_pocket(usr, href_list["pockets"])
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
