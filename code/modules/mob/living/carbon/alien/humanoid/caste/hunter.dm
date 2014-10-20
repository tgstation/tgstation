/mob/living/carbon/alien/humanoid/hunter
	name = "alien hunter"
	caste = "h"
	maxHealth = 150
	health = 150
	storedPlasma = 100
	max_plasma = 150
	icon_state = "alienh_s"
	plasma_rate = 5

/mob/living/carbon/alien/humanoid/hunter/New()
	create_reagents(100)
	if(name == "alien hunter")
		name = text("alien hunter ([rand(1, 1000)])")
	real_name = name
	..()

/mob/living/carbon/alien/humanoid/hunter/handle_regular_hud_updates()
	..() //-Yvarov

	if (healths)
		if (stat != 2)
			switch(health)
				if(150 to INFINITY)
					healths.icon_state = "health0"
				if(100 to 150)
					healths.icon_state = "health1"
				if(50 to 100)
					healths.icon_state = "health2"
				if(25 to 50)
					healths.icon_state = "health3"
				if(0 to 25)
					healths.icon_state = "health4"
				else
					healths.icon_state = "health5"
		else
			healths.icon_state = "health6"


/mob/living/carbon/alien/humanoid/hunter/handle_environment()
	if(m_intent == "run" || resting)
		..()
	else
		adjustToxLoss(-heal_rate)

/mob/living/carbon/alien/humanoid/hunter/movement_delay()
	. = -1		//hunters are sanic
	. += ..()	//but they still need to slow down on stun


//Hunter verbs

/mob/living/carbon/alien/humanoid/hunter/proc/toggle_leap()
	leap_on_click = !leap_on_click
	leap_icon.icon_state = "leap_[leap_on_click ? "on":"off"]"
	src << "<span class='noticealien'>You will now [leap_on_click ? "leap at":"slash at"] enemies!</span>"

/mob/living/carbon/alien/humanoid/hunter/ClickOn(var/atom/A, var/params)
	face_atom(A)
	if(leap_on_click)
		leap_at(A)
	else
		..()


#define MAX_ALIEN_LEAP_DIST 7

/mob/living/carbon/alien/humanoid/hunter/proc/leap_at(var/atom/A)
	if(leaping) //Leap while you leap, so you can leap while you leap
		return

	if(!has_gravity(src) || !has_gravity(A))
		src << "<span class='alertalien'>It is unsafe to leap without gravity!</span>"
		//It's also extremely buggy visually, so it's balance+bugfix
		return
	if(lying)
		return

	leaping = 1
	update_icons()
	throw_at(A,MAX_ALIEN_LEAP_DIST,1)
	leaping = 0
	update_icons()

/mob/living/carbon/alien/humanoid/throw_impact(A)
	var/msg = ""

	if(A)
		if(istype(A, /mob/living))
			var/mob/living/L = A
			msg = "<span class ='alertalien'>[src] pounces on [A]!</span>"
			L.Weaken(5)
			sleep(2)//Runtime prevention (infinite bump() calls on hulks)
			step_towards(src,L)
		else
			msg = "<span class ='alertalien'>[src] smashes into [A]!</span>"
			weakened = 2

		if(leaping)
			leaping = 0
			update_canmove()
			visible_message(msg)


/mob/living/carbon/alien/humanoid/float(on)
	if(leaping)
		return
	..()


//Modified throw_at() that will use diagonal dirs where appropriate
//instead of locking it to cardinal dirs
/mob/living/carbon/alien/humanoid/throw_at(atom/target, range, speed)
	if(!target || !src || (flags & NODROP))	return 0

	src.throwing = 1

	var/dist_x = abs(target.x - src.x)
	var/dist_y = abs(target.y - src.y)
	var/dist_travelled = 0
	var/dist_since_sleep = 0

	var/tdist_x = dist_x;
	var/tdist_y = dist_y;

	if(dist_x <= dist_y)
		tdist_x = dist_y;
		tdist_y = dist_x;

	var/error = tdist_x/2 - tdist_y
	while(target && (((((dist_x > dist_y) && ((src.x < target.x) || (src.x > target.x))) || ((dist_x <= dist_y) && ((src.y < target.y) || (src.y > target.y))) || (src.x > target.x)) && dist_travelled < range) || !has_gravity(src)))

		if(!src.throwing) break
		if(!istype(src.loc, /turf)) break

		var/atom/step = get_step(src, get_dir(src,target))
		if(!step)
			break
		src.Move(step)
		hit_check()
		error += (error < 0) ? tdist_x : -tdist_y;
		dist_travelled++
		dist_since_sleep++
		if(dist_since_sleep >= speed)
			dist_since_sleep = 0
			sleep(1)


	src.throwing = 0
	if(isobj(src))
		src.throw_impact(get_turf(src))

	return 1
