/mob/living/carbon/alien/larva
	name = "alien larva" //The alien larva, not 'Alien Larva'
	real_name = "alien larva"
	icon_state = "larva0"
	pass_flags = PASSTABLE

	maxHealth = 25
	health = 25
	storedPlasma = 50
	max_plasma = 50
	size = SIZE_TINY

	var/amount_grown = 0
	var/max_grown = 200
	var/time_of_birth

//This is fine right now, if we're adding organ specific damage this needs to be updated
/mob/living/carbon/alien/larva/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien larva")
		name = "alien larva ([rand(1, 1000)])"
	real_name = name
	regenerate_icons()
	add_language(LANGUAGE_XENO)
	default_language = all_languages[LANGUAGE_XENO]
	..()

//This needs to be fixed
/mob/living/carbon/alien/larva/Stat()
	..()
	if(statpanel("Status"))
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

	to_chat(src, "<span class='warning'>The blob attacks you !</span>")

	adjustFireLoss(damage)
	updatehealth()
	return

//can't equip anything
/mob/living/carbon/alien/larva/attack_ui(slot_id)
	return

//using the default attack_animal() in carbon.dm

/mob/living/carbon/alien/larva/attack_paw(mob/living/carbon/monkey/M as mob)
	if(!(istype(M, /mob/living/carbon/monkey)))
		return //Fix for aliens receiving double messages when attacking other aliens.

	if(!ticker)
		to_chat(M, "<span class='warning'>You cannot attack people before the game has started.</span>")
		return

/*
	//MUH SPAWN PROTECTION
	if(istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "<span class='warning'>No attacking people at spawn, you jackass.</span>")
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
				visible_message("<span class='danger'>\The [M] has bit \the [src] !</span>")
				adjustBruteLoss(rand(1, 3))
				updatehealth()
	return


/mob/living/carbon/alien/larva/attack_slime(mob/living/carbon/slime/M as mob)
	if(!ticker)
		to_chat(M, "<span class='warning'>You cannot attack people before the game has started.</span>")
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
		to_chat(M, "<span class='warning'>You cannot attack people before the game has started.</span>")
		return

	/*
	if(istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "<span class='warning'>No attacking people at spawn, you jackass.</span>")
		return
	*/
	..()

	if(M.gloves && istype(M.gloves,/obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.cell)
			if(M.a_intent == I_HURT)//Stungloves. Any contact will stun the alien.
				if(G.cell.charge >= 2500)
					G.cell.use(2500)

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
			if(health > 0)
				help_shake_act(M)
			else
				if(M.health >= -75.0)
					if ((M.head && M.head.flags & 4) || (M.wear_mask && !( M.wear_mask.flags & 32 )) )
						to_chat(M, "<span class='notice'>Remove that mask!</span>")
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

		if(I_GRAB)
			if(M == src)
				return
			var/obj/item/weapon/grab/G = getFromPool(/obj/item/weapon/grab,M,src)

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
		to_chat(M, "<span class='warning'>You cannot attack people before the game has started.</span>")
		return

	/*
	if(istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "<span class='warning'>No attacking people at spawn, you jackass.</span>")
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
			visible_message("<span class='notice'>[M.name] nuzzles [src] trying to wake it up !</span>")

		else
			if(health > 0)
				playsound(loc, 'sound/weapons/bite.ogg', 50, 1, -1)
				var/damage = rand(1, 3)
				for(var/mob/O in viewers(src, null))
					if((O.client && !( O.blinded )))
						O.show_message(text("<span class='danger'>[M.name] has bit []!</span>", src), 1)
				adjustBruteLoss(damage)
				updatehealth()
			else
				to_chat(M, "<span class='alien'>[name] is too injured for that.</span>")
	return

/mob/living/carbon/alien/larva/restrained()
	if(timestopped) return 1 //under effects of time magick

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

/* Why?
/mob/living/carbon/alien/larva/say_understands(var/mob/other,var/datum/language/speaking = null)
	if(speaking && speaking.name == LANGUAGE_SOL_COMMON)
		return 1
	return ..()
*/
