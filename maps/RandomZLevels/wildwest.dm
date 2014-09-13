/* Code for the Wild West map by Brotemis
 * Contains:
 *		Wish Granter
 *		Meat Grinder
 */

/*
 * Wish Granter
 */
/obj/machinery/wish_granter_dark
	name = "Wish Granter"
	desc = "You're not so sure about this, anymore..."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"

	anchored = 1
	density = 1
	use_power = 0

	var/chargesa = 1
	var/insistinga = 0

/obj/machinery/wish_granter_dark/attack_hand(var/mob/living/carbon/human/user as mob)
	usr.set_machine(src)

	if(chargesa <= 0)
		user << "The Wish Granter lies silent."
		return

	else if(!istype(user, /mob/living/carbon/human))
		user << "You feel a dark stirring inside of the Wish Granter, something you want nothing of. Your instincts are better than any man's."
		return

	else if(is_special_character(user))
		user << "Even to a heart as dark as yours, you know nothing good will come of this.  Something instinctual makes you pull away."

	else if (!insistinga)
		user << "Your first touch makes the Wish Granter stir, listening to you.  Are you really sure you want to do this?"
		insistinga++

	else
		chargesa--
		insistinga = 0
		var/wish = input("You want...","Wish") as null|anything in list("Power","Wealth","Immortality","To Kill","Peace")
		switch(wish)
			if("Power")
				user << "<B>Your wish is granted, but at a terrible cost...</B>"
				user << "The Wish Granter punishes you for your selfishness, claiming your soul and warping your body to match the darkness in your heart."
				if (!(M_LASER in user.mutations))
					user.mutations.Add(M_LASER)
					user << "\blue You feel pressure building behind your eyes."
				if (!(M_RESIST_COLD in user.mutations))
					user.mutations.Add(M_RESIST_COLD)
					user << "\blue Your body feels warm."
				if (!(M_RESIST_HEAT in user.mutations))
					user.mutations.Add(M_RESIST_HEAT)
					user << "\blue Your skin feels icy to the touch."
				if (!(M_XRAY in user.mutations))
					user.mutations.Add(M_XRAY)
					user.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
					user.see_in_dark = 8
					user.see_invisible = SEE_INVISIBLE_LEVEL_TWO
					user << "\blue The walls suddenly disappear."
				user.dna.mutantrace = "shadow"
				user.update_mutantrace()
			if("Wealth")
				user << "<B>Your wish is granted, but at a terrible cost...</B>"
				user << "The Wish Granter punishes you for your selfishness, claiming your soul and warping your body to match the darkness in your heart."
				new /obj/structure/closet/syndicate/resources/everything(loc)
				user.dna.mutantrace = "shadow"
				user.update_mutantrace()
			if("Immortality")
				user << "<B>Your wish is granted, but at a terrible cost...</B>"
				user << "The Wish Granter punishes you for your selfishness, claiming your soul and warping your body to match the darkness in your heart."
				user.verbs += /mob/living/carbon/proc/immortality
				user.dna.mutantrace = "shadow"
				user.update_mutantrace()
			if("To Kill")
				user << "<B>Your wish is granted, but at a terrible cost...</B>"
				user << "The Wish Granter punishes you for your wickedness, claiming your soul and warping your body to match the darkness in your heart."
				ticker.mode.traitors += user.mind
				user.mind.special_role = "traitor"
				var/datum/objective/hijack/hijack = new
				hijack.owner = user.mind
				user.mind.objectives += hijack
				user << "<B>Your inhibitions are swept away, the bonds of loyalty broken, you are free to murder as you please!</B>"
				var/obj_count = 1
				for(var/datum/objective/OBJ in user.mind.objectives)
					user << "<B>Objective #[obj_count]</B>: [OBJ.explanation_text]"
					obj_count++
				user.dna.mutantrace = "shadow"
				user.update_mutantrace()
			if("Peace")
				user << "<B>Whatever alien sentience that the Wish Granter possesses is satisfied with your wish. There is a distant wailing as the last of the Faithless begin to die, then silence.</B>"
				user << "You feel as if you just narrowly avoided a terrible fate..."
				for(var/mob/living/simple_animal/hostile/faithless/F in world)
					F.health = -10
					F.stat = 2
					F.icon_state = "faithless_dead"


///////////////Meatgrinder//////////////


/obj/effect/meatgrinder
	name = "Meat Grinder"
	desc = "What is that thing?"
	density = 1
	anchored = 1
	layer = 3
	icon = 'icons/mob/critter.dmi'
	icon_state = "blob"
	var/triggerproc = "explode" //name of the proc thats called when the mine is triggered
	var/triggered = 0

/obj/effect/meatgrinder/New()
	icon_state = "blob"

/obj/effect/meatgrinder/Crossed(AM as mob|obj)
	Bumped(AM)

/obj/effect/meatgrinder/Bumped(mob/M as mob|obj)

	if(triggered) return

	if(istype(M, /mob/living/carbon/human) || istype(M, /mob/living/carbon/monkey))
		for(var/mob/O in viewers(world.view, src.loc))
			O << "<font color='red'>[M] triggered the \icon[src] [src]</font>"
		triggered = 1
		call(src,triggerproc)(M)

/obj/effect/meatgrinder/proc/triggerrad1(mob)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	for(var/mob/O in viewers(world.view, src.loc))
		s.set_up(3, 1, src)
		s.start()
		explosion(mob, 1, 0, 0, 0)
		spawn(0)
			del(src)

/obj/effect/meatgrinder
	name = "Meat Grinder"
	icon_state = "blob"
	triggerproc = "triggerrad1"


/////For the Wishgranter///////////

/mob/living/carbon/proc/immortality()
	set category = "Immortality"
	set name = "Resurrection"

	var/mob/living/carbon/C = usr
	if(!C.stat)
		C << "<span class='notice'>You're not dead yet!</span>"
		return
	C << "<span class='notice'>Death is not your end!</span>"

	spawn(rand(800,1200))
		if(C.stat == DEAD)
			dead_mob_list -= C
			living_mob_list += C
		C.stat = CONSCIOUS
		C.tod = null
		C.setToxLoss(0)
		C.setOxyLoss(0)
		C.setCloneLoss(0)
		C.SetParalysis(0)
		C.SetStunned(0)
		C.SetWeakened(0)
		C.radiation = 0
		C.heal_overall_damage(C.getBruteLoss(), C.getFireLoss())
		C.reagents.clear_reagents()
		C << "<span class='notice'>You have regenerated.</span>"
		C.visible_message("<span class='warning'>[usr] appears to wake from the dead, having healed all wounds.</span>")
		C.update_canmove()
	return 1