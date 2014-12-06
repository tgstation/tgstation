/mob/living/carbon/alien/humanoid
	name = "\the alien"
	icon_state = "alien_s"

	var/obj/item/clothing/suit/wear_suit = null		//TODO: necessary? Are they even used? ~Carn
	var/obj/item/clothing/head/head = null			//
	var/obj/item/weapon/r_store = null
	var/obj/item/weapon/l_store = null
	var/caste = ""
	update_icon = 1

//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/humanoid/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "\improper alien")
		name = text("\improper alien ([rand(1, 1000)])")
	real_name = name
	..()

//This is fine, works the same as a human
/mob/living/carbon/alien/humanoid/Bump(atom/movable/AM as mob|obj, yes)
	spawn(0)
		if ((!(yes) || now_pushing)) //IF YES !
			return
		now_pushing = 0
		..()
		if(!istype(AM, /atom/movable))
			return

		if(ismob(AM))
			var/mob/tmob = AM
			tmob.LAssailant = src

		if(!now_pushing)
			now_pushing = 1
			if(!AM.anchored)
				var/t = get_dir(src, AM)
				if(istype(AM, /obj/structure/window/full))
					for(var/obj/structure/window/win in get_step(AM,t))
						now_pushing = 0
						return
				step(AM, t)
			now_pushing = null
		return
	return

/mob/living/carbon/alien/humanoid/movement_delay()
	var/tally = 0
	if(istype(src, /mob/living/carbon/alien/humanoid/queen))
		tally += 5
	if(istype(src, /mob/living/carbon/alien/humanoid/drone))
		tally += 2
	if(istype(src, /mob/living/carbon/alien/humanoid/sentinel))
		tally += 1
	if(istype(src, /mob/living/carbon/alien/humanoid/hunter))
		tally = -1 // hunters go supersuperfast
	return (tally + move_delay_add + config.alien_delay)

///mob/living/carbon/alien/humanoid/bullet_act(var/obj/item/projectile/Proj) taken care of in living

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
		flick("flash", flash)

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
	if(stat == 2)
		return
	var/shielded = 0
	var/damage = null
	if(stat != 2)
		damage = rand(30,40)

	if(shielded)
		damage /= 4

	src << "<span class='warning'>The blob attacks you !</span>"

	adjustFireLoss(damage)

	return


/mob/living/carbon/alien/humanoid/meteorhit(O as obj)
	if(flags & INVULNERABLE)
		return
	visible_message("<span class='warning'>\The [src] has been hit by [O]</span>")
	if(health > 0)
		adjustFireLoss((istype(O, /obj/effect/meteor/small) ? 10 : 25))
		adjustFireLoss(30)
		updatehealth()
	return


/mob/living/carbon/alien/humanoid/attack_paw(mob/living/carbon/monkey/M as mob)
	if(!ismonkey(M))
		return//Fix for aliens receiving double messages when attacking other aliens.

	if(!ticker)
		M << "<span class='warning'>You cannot attack people before the game has started.</span>"
		return

	/*
	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return
	*/
	..()

	switch(M.a_intent)

		if("help")
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
		M << "You cannot attack people before the game has started."
		return

	if(M.Victim) return // can't attack while eating!

	if(health > -100)
		visible_message("<span class='danger'>\The [M] glomps [src]!</span>")

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

/mob/living/carbon/alien/humanoid/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>[M.attacktext] [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been [M.attacktext] by [M.name] ([M.ckey])</font>")
		if(M.attack_sound)
			playsound(loc, M.attack_sound, 50, 1, 1)
		visible_message("<span class='warning'><B>[M]</B> [M.attacktext] \the [src] !</span>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		adjustBruteLoss(damage)
		updatehealth()

/mob/living/carbon/alien/humanoid/attack_hand(mob/living/carbon/human/M as mob)
	if(!ticker)
		M << "<span class='warning'>You cannot attack people before the game has started.</span>"
		return

	/*
	if(istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return
	*/

	..()

	if(M.gloves && istype(M.gloves,/obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.cell)
			if(M.a_intent == "hurt")//Stungloves. Any contact will stun the alien.
				if(G.cell.charge >= 2500)
					G.cell.charge -= 2500

					Weaken(5)
					if(stuttering < 5)
						stuttering = 5
					Stun(5)
					visible_message("<span class='danger'>\The [src] has been touched with the stun gloves by [M] !</span>")
					return
				else
					M << "<span class='warning'>Not enough charge !</span>"
					return

	switch(M.a_intent)

		if("help")
			if(health > 0)
				help_shake_act(M)
			else
				if(M.health >= -75.0)
					if(((M.head && M.head.flags & 4) || ((M.wear_mask && !( M.wear_mask.flags & 32 )) || ((head && head.flags & 4) || (wear_mask && !( wear_mask.flags & 32))))))
						M << "<span class='notice'>Remove that mask!</span>"
						return
					var/obj/effect/equip_e/human/O = new /obj/effect/equip_e/human()
					O.source = M
					O.target = src
					O.s_loc = M.loc
					O.t_loc = loc
					O.place = "CPR"
					requests += O
					spawn(0)
						O.process()
						return

		if("grab")
			if(M == src)
				return
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(M, src)

			M.put_in_active_hand(G)

			grabbed_by += G
			G.synch()

			LAssailant = M

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			visible_message("<span class='warning'>[M] has grabbed \the [src] passively !</span>")

		if("hurt")
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

		if("disarm")
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
		M << "<span class='warning'>You cannot attack people before the game has started.</span>"
		return

	/*
	if(istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "No attacking people at spawn, you jackass."
		return
	*/
	..()

	switch(M.a_intent)

		if("help")
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
				M << "\green <B>[name] is too injured for that.</B>"
	return


/mob/living/carbon/alien/humanoid/restrained()
	if (handcuffed)
		return 1
	return 0


/mob/living/carbon/alien/humanoid/var/co2overloadtime = null
/mob/living/carbon/alien/humanoid/var/temperature_resistance = T0C+75

/mob/living/carbon/alien/humanoid/show_inv(mob/user as mob)

	user.set_machine(src)
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR>
	<BR><B>Left Hand:</B> <A href='?src=\ref[src];item=l_hand'>[(l_hand ? text("[]", l_hand) : "Nothing")]</A>
	<BR><B>Right Hand:</B> <A href='?src=\ref[src];item=r_hand'>[(r_hand ? text("[]", r_hand) : "Nothing")]</A>
	<BR><B>Head:</B> <A href='?src=\ref[src];item=head'>[(head ? text("[]", head) : "Nothing")]</A>
	<BR><B>(Exo)Suit:</B> <A href='?src=\ref[src];item=suit'>[(wear_suit ? text("[]", wear_suit) : "Nothing")]</A>
	<BR><A href='?src=\ref[src];item=pockets'>Empty Pouches</A>
	<BR><A href='?src=\ref[user];mach_close=mob\ref[src]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob\ref[src];size=340x480"))
	onclose(user, "mob\ref[src]")
	return


