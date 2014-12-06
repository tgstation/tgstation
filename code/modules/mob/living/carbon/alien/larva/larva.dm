/mob/living/carbon/alien/larva
	name = "\improper alien larva" //The alien larva, not 'Alien Larva'
	real_name = "alien larva"
	icon_state = "larva0"
	pass_flags = PASSTABLE

	maxHealth = 25
	health = 25
	storedPlasma = 50
	max_plasma = 50

	var/amount_grown = 0
	var/max_grown = 200
	var/time_of_birth

//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/larva/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "\improper alien larva")
		name = "\improper alien larva ([rand(1, 1000)])"
	real_name = name
	regenerate_icons()
	..()

//This is fine, works the same as a human
/mob/living/carbon/alien/larva/Bump(atom/movable/AM as mob|obj, yes)

	spawn(0)
		if((!(yes) || now_pushing))
			return
		now_pushing = 1
		if(ismob(AM))
			var/mob/tmob = AM
			if(istype(tmob, /mob/living/carbon/human) && (M_FAT in tmob.mutations))
				if(prob(70))
					src << "<span class='danger'>You fail to push [tmob]'s fat ass out of the way.</span>"
					now_pushing = 0
					return
				if(!(tmob.status_flags & CANPUSH))
					now_pushing = 0
					return
			tmob.LAssailant = src

		now_pushing = 0
		..()
		if (!(istype(AM, /atom/movable)))
			return
		if (!(now_pushing))
			now_pushing = 1
			if (!(AM.anchored))
				var/t = get_dir(src, AM)
				step(AM, t)
			now_pushing = null
		return
	return

//This needs to be fixed
/mob/living/carbon/alien/larva/Stat()
	..()
	stat(null, "Progress: [amount_grown]/[max_grown]")

/mob/living/carbon/alien/larva/adjustToxLoss(amount)
	if(stat != DEAD)
		amount_grown = min(amount_grown + 1, max_grown)
	..(amount)


/mob/living/carbon/alien/larva/ex_act(severity)
	if(flags & INVULNERABLE)
		return

	if(!blinded)
		flick("flash", flash)

	var/b_loss = null
	var/f_loss = null
	switch (severity)
		if(1.0)
			b_loss += 500
			gib()
			return
		if(2.0)
			b_loss += 60
			f_loss += 60
			ear_damage += 30
			ear_deaf += 120
		if(3.0)
			b_loss += 30
			if(prob(50))
				Paralyse(1)
			ear_damage += 15
			ear_deaf += 60

	adjustBruteLoss(b_loss)
	adjustFireLoss(f_loss)
	updatehealth()

/mob/living/carbon/alien/larva/blob_act()
	if(flags & INVULNERABLE)
		return
	if(stat == 2)
		return
	var/shielded = 0

	var/damage = null
	if(stat != 2)
		damage = rand(10,30)

	if(shielded)
		damage /= 4

		//paralysis += 1

	src << "<span class='warning'>The blob attacks you !</span>"

	adjustFireLoss(damage)
	updatehealth()
	return

//can't equip anything
/mob/living/carbon/alien/larva/attack_ui(slot_id)
	return

/mob/living/carbon/alien/larva/meteorhit(O as obj)
	if(flags & INVULNERABLE)
		return
	visible_message("<span class='warning'>\The [src] has been hit by [O]")
	if(health > 0)
		adjustBruteLoss((istype(O, /obj/effect/meteor/small) ? 10 : 25)) //You fucking what
		adjustFireLoss(30)
		updatehealth()
	return

/mob/living/carbon/alien/larva/attack_animal(mob/living/simple_animal/M as mob)
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>[M.attacktext] [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been [M.attacktext] by [M.name] ([M.ckey])</font>")
		visible_message("<span class='warning'><B>[M]</B> [M.attacktext] \the [src]!</span>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		adjustBruteLoss(damage)
		M.attack_log += text("\[[time_stamp()]\] <font color='red'>attacked [src.name] ([src.ckey])</font>")
		src.attack_log += text("\[[time_stamp()]\] <font color='orange'>was attacked by [M.name] ([M.ckey])</font>")
		updatehealth()

/mob/living/carbon/alien/larva/attack_paw(mob/living/carbon/monkey/M as mob)
	if(!(istype(M, /mob/living/carbon/monkey)))
		return //Fix for aliens receiving double messages when attacking other aliens.

	if(!ticker)
		M << "<span class='warning'>You cannot attack people before the game has started.</span>"
		return

/*
	//MUH SPAWN PROTECTION
	if(istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "<span class='warning'>No attacking people at spawn, you jackass.</span>"
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
				visible_message("<span class='danger'>\The [M] has bit \the [src] !</span>")
				adjustBruteLoss(rand(1, 3))
				updatehealth()
	return


/mob/living/carbon/alien/larva/attack_slime(mob/living/carbon/slime/M as mob)
	if(!ticker)
		M << "<span class='warning'>You cannot attack people before the game has started.</span>"
		return

	if(M.Victim) return // can't attack while eating!

	if(health > -100)

		for(var/mob/O in viewers(src, null))
			visible_message("<span class='danger'>\The [M] glomps \the [src]!</span>")

		var/damage = rand(1, 3)

		if(istype(src, /mob/living/carbon/slime/adult))
			damage = rand(20, 40)
		else
			damage = rand(5, 35)

		adjustBruteLoss(damage)

		updatehealth()
	return

/mob/living/carbon/alien/larva/attack_hand(mob/living/carbon/human/M as mob)
	if(!ticker)
		M << "<span class='warning'>You cannot attack people before the game has started.</span>"
		return

	/*
	if(istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "<span class='warning'>No attacking people at spawn, you jackass.</span>"
		return
	*/
	..()

	if(M.gloves && istype(M.gloves,/obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.cell)
			if(M.a_intent == "hurt")//Stungloves. Any contact will stun the alien.
				if(G.cell.charge >= 2500)
					G.cell.use(2500)

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
					if ((M.head && M.head.flags & 4) || (M.wear_mask && !( M.wear_mask.flags & 32 )) )
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
			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab( M, src )

			M.put_in_active_hand(G)
			grabbed_by += G
			G.synch()

			LAssailant = M

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			visible_message("<span class='warning'>[M] has grabbed \the [src] passively !</span>")

		else
			var/damage = rand(1, 9)
			if(prob(90))
				if(M_HULK in M.mutations)
					damage += 5
					spawn(0)
						Paralyse(1)
						step_away(src,M,15)
						sleep(3)
						step_away(src,M,15)
				playsound(loc, "punch", 25, 1, -1)
				visible_message("<span class='danger'>[M] has punched \the [src] !</span>")
				if(damage > 4.9)
					Weaken(rand(10,15))
					visible_message("<span class='danger'>[M] has weakened \the [src] !</span>")
				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				visible_message("<span class='danger'>[M] has attempted to punch \the [src] !</span>")
	return

/mob/living/carbon/alien/larva/attack_alien(mob/living/carbon/alien/humanoid/M as mob)
	if(!ticker)
		M << "<span class='warning'>You cannot attack people before the game has started.</span>"
		return

	/*
	if(istype(loc, /turf) && istype(loc.loc, /area/start))
		M << "<span class='warning'>No attacking people at spawn, you jackass.</span>"
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
			visible_message("<span class='notice'>[M.name] nuzzles [src] trying to wake it up !</span>")

		else
			if(health > 0)
				playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
				var/damage = rand(1, 3)
				for(var/mob/O in viewers(src, null))
					if((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[M.name] has bit []!</B>", src), 1)
				adjustBruteLoss(damage)
				updatehealth()
			else
				M << "\green <B>[name] is too injured for that.</B>"
	return

/mob/living/carbon/alien/larva/restrained()
	return 0

/mob/living/carbon/alien/larva/var/co2overloadtime = null
/mob/living/carbon/alien/larva/var/temperature_resistance = T0C+75

// new damage icon system
// now constructs damage icon for each organ from mask * damage field


/mob/living/carbon/alien/larva/show_inv(mob/user as mob)

	user.set_machine(src)
	var/dat = {"
	<B><HR><FONT size=3>[name]</FONT></B>
	<BR><HR><BR>
	<BR><A href='?src=\ref[user];mach_close=mob[name]'>Close</A>
	<BR>"}
	user << browse(dat, text("window=mob[name];size=340x480"))
	onclose(user, "mob[name]")
	return
