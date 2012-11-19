/* Code for the Wild West map by Brotemis
 * Contains:
 *		Wish Granter
 *		Meat Grinder
 */

/*
 * Wish Granter
 */
/obj/machinery/wwish_granter
	name = "Wish Granter"
	desc = "You're not so sure about this, anymore..."
	icon = 'icons/obj/device.dmi'
	icon_state = "syndbeacon"

	anchored = 1
	density = 1

	var/chargesa = 1
	var/insistinga = 0

/obj/machinery/wwish_granter/attack_hand(var/mob/user as mob)
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
		user << "You speak.  [pick("I want the station to disappear","Humanity is corrupt, mankind must be destroyed","I want to be rich", "I want to rule the world","I want immortality.")].  The Wish Granter answers."
		user << "Your head pounds for a moment, before your vision clears.  You are the avatar of the Wish Granter, and your power is LIMITLESS!  And it's all yours.  You need to make sure no one can take it from you.  No one can know, first."

		chargesa--
		insistinga = 0

		if (!(HULK in user.mutations))
			user.mutations.Add(HULK)

		if (!(LASER in user.mutations))
			user.mutations.Add(LASER)

		if (!(XRAY in user.mutations))
			user.mutations.Add(XRAY)
			user.sight |= (SEE_MOBS|SEE_OBJS|SEE_TURFS)
			user.see_in_dark = 8
			user.see_invisible = SEE_INVISIBLE_LEVEL_TWO

		if (!(COLD_RESISTANCE in user.mutations))
			user.mutations.Add(COLD_RESISTANCE)

		if (!(TK in user.mutations))
			user.mutations.Add(TK)

		if(!(HEAL in user.mutations))
			user.mutations.Add(HEAL)

		user << "You have a very bad feeling about this."

	return

/*
 * Meat Grinder
 */

/obj/effect/meatgrinder
	name = "Meat Grinder"
	desc = "What is that thing?"
	density = 1
	anchored = 1
	layer = 3
	icon = 'icons/obj/weapons.dmi'
	icon_state = "shadow_portal"
	var/triggerproc = "explode" //name of the proc thats called when the mine is triggered
	var/triggered = 0

/obj/effect/meatgrinder/New()
	icon_state = "shadow_portal"

/obj/effect/meatgrinder/HasEntered(AM as mob|obj)
	Bumped(AM)

/obj/effect/meatgrinder/Bumped(mob/M as mob|obj)

	if(triggered) return

	if(istype(M, /mob/living/carbon/human) || istype(M, /mob/living/carbon/monkey))
		for(var/mob/O in viewers(world.view, src.loc))
			O << "<font color='red'>[M] triggered the \icon[src] [src]</font>"
		triggered = 1
		call(src,triggerproc)(M)

/obj/effect/meatgrinder/proc/triggerrad1(obj)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	obj:radiation += 5000
	randmutb(obj)
	domutcheck(obj,null)
	spawn(0)
		del(src)

/obj/effect/mine/meatgrinder
	name = "Meat Grinder"
	icon_state = "shadow_portal"
	triggerproc = "triggerrad1"