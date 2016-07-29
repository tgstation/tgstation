<<<<<<< HEAD
/mob/living/carbon/alien/humanoid/hunter
	name = "alien hunter"
	caste = "h"
	maxHealth = 125
	health = 125
	icon_state = "alienh_s"
	var/obj/screen/leap_icon = null

/mob/living/carbon/alien/humanoid/hunter/New()
	internal_organs += new /obj/item/organ/alien/plasmavessel/small
	..()

/mob/living/carbon/alien/humanoid/hunter/movement_delay()
	. = -1		//hunters are sanic
	. += ..()	//but they still need to slow down on stun


//Hunter verbs

/mob/living/carbon/alien/humanoid/hunter/proc/toggle_leap(message = 1)
	leap_on_click = !leap_on_click
	leap_icon.icon_state = "leap_[leap_on_click ? "on":"off"]"
	update_icons()
	if(message)
		src << "<span class='noticealien'>You will now [leap_on_click ? "leap at":"slash at"] enemies!</span>"
	else
		return


/mob/living/carbon/alien/humanoid/hunter/ClickOn(atom/A, params)
	face_atom(A)
	if(leap_on_click)
		leap_at(A)
	else
		..()


#define MAX_ALIEN_LEAP_DIST 7

/mob/living/carbon/alien/humanoid/hunter/proc/leap_at(atom/A)
	if(pounce_cooldown)
		src << "<span class='alertalien'>You are too fatigued to pounce right now!</span>"
		return

	if(leaping || stat || buckled || lying)
		return

	if(!has_gravity(src) || !has_gravity(A))
		src << "<span class='alertalien'>It is unsafe to leap without gravity!</span>"
		//It's also extremely buggy visually, so it's balance+bugfix
		return

	else //Maybe uses plasma in the future, although that wouldn't make any sense...
		leaping = 1
		update_icons()
		throw_at(A,MAX_ALIEN_LEAP_DIST,1, spin=0, diagonals_first = 1)
		leaping = 0
		update_icons()

/mob/living/carbon/alien/humanoid/hunter/throw_impact(atom/A)

	if(!leaping)
		return ..()

	if(A)
		if(istype(A, /mob/living))
			var/mob/living/L = A
			var/blocked = 0
			if(ishuman(A))
				var/mob/living/carbon/human/H = A
				if(H.check_shields(90, "the [name]", src, attack_type = THROWN_PROJECTILE_ATTACK))
					blocked = 1
			if(!blocked)
				L.visible_message("<span class ='danger'>[src] pounces on [L]!</span>", "<span class ='userdanger'>[src] pounces on you!</span>")
				L.Weaken(5)
				sleep(2)//Runtime prevention (infinite bump() calls on hulks)
				step_towards(src,L)

			toggle_leap(0)
			pounce_cooldown = !pounce_cooldown
			spawn(pounce_cooldown_time) //3s by default
				pounce_cooldown = !pounce_cooldown
		else if(A.density && !A.CanPass(src))
			visible_message("<span class ='danger'>[src] smashes into [A]!</span>", "<span class ='alertalien'>[src] smashes into [A]!</span>")
			weakened = 2

		if(leaping)
			leaping = 0
			update_icons()
			update_canmove()


/mob/living/carbon/alien/humanoid/float(on)
	if(leaping)
		return
	..()


=======
/mob/living/carbon/alien/humanoid/hunter
	name = "alien hunter" //The alien hunter, not Alien Hunter
	caste = "h"
	maxHealth = 250
	health = 250
	storedPlasma = 100
	max_plasma = 150
	icon_state = "alienh_s"
	plasma_rate = 5

/mob/living/carbon/alien/humanoid/hunter/movement_delay()
	var/tally = -2 + move_delay_add + config.alien_delay //Hunters are fast

	var/turf/T = loc
	if(istype(T))
		tally = T.adjust_slowdown(src, tally)

	return tally

/mob/living/carbon/alien/humanoid/hunter/New()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien hunter")
		name = text("alien hunter ([rand(1, 1000)])")
	real_name = name
	..()
	add_language(LANGUAGE_XENO)
	default_language = all_languages[LANGUAGE_XENO]

/mob/living/carbon/alien/humanoid/hunter
	handle_regular_hud_updates()

		..() //-Yvarov

		if(healths)
			if(stat != 2)
				switch(health)
					if(250 to INFINITY)
						healths.icon_state = "health0"
					if(150 to 250)
						healths.icon_state = "health1"
					if(100 to 150)
						healths.icon_state = "health2"
					if(50 to 100)
						healths.icon_state = "health3"
					if(0 to 50)
						healths.icon_state = "health4"
					else
						healths.icon_state = "health5"
			else
				healths.icon_state = "health6"


	handle_environment()
		if(m_intent == "run" || resting)
			..()
		else
			adjustToxLoss(-heal_rate)


//Hunter verbs
//This ought to be fixed, maybe not now though
/*
/mob/living/carbon/alien/humanoid/hunter/verb/invis()
	set name = "Invisibility (50)"
	set desc = "Makes you invisible for 15 seconds"
	set category = "Alien"

	if(alien_invis)
		update_icons()
	else
		if(powerc(50))
			adjustToxLoss(-50)
			alien_invis = 1.0
			update_icons()
			to_chat(src, "<span class='good'>You are now invisible.</span>")
			visible_message("<span class='danger'>\The [src] fades into the surroundings!</span>", "<span class='alien'>You are now invisible</span>")
			spawn(250)
				if(!isnull(src)) //Don't want the game to runtime error when the mob no-longer exists.
					alien_invis = 0.0
					update_icons()
					to_chat(src, "<span class='alien'>You are no longer invisible.</span>")
	return
*/
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
