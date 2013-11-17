/*
#define BRUTE "brute"
#define BURN "burn"
#define TOX "tox"
#define OXY "oxy"
#define CLONE "clone"

#define ADD "add"
#define SET "set"
*/

/obj/item/projectile
	name = "projectile"
	icon = 'icons/obj/projectiles.dmi'
	icon_state = "bullet"
	density = 1
	unacidable = 1
	anchored = 1 //There's a reason this is here, Mport. God fucking damn it -Agouri. Find&Fix by Pete. The reason this is here is to stop the curving of emitter shots.
	flags = FPRINT | TABLEPASS
	pass_flags = PASSTABLE
	mouse_opacity = 0
	var/bumped = 0		//Prevents it from hitting more than one guy at once
	var/def_zone = ""	//Aiming at
	var/mob/firer = null//Who shot it
	var/silenced = 0	//Attack message
	var/yo = null
	var/xo = null
	var/current = null
	var/obj/shot_from = null // the object which shot us
	var/atom/original = null // the original target clicked
	var/turf/starting = null // the projectile's starting turf
	var/list/permutated = list() // we've passed through these atoms, don't try to hit them again

	var/p_x = 16
	var/p_y = 16 // the pixel location of the tile that the player clicked. Default is the center

	var/damage = 10
	var/damage_type = BRUTE //BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here
	var/nodamage = 0 //Determines if the projectile will skip any damage inflictions
	var/flag = "bullet" //Defines what armor to use when it hits things.  Must be set to bullet, laser, energy,or bomb
	var/projectile_type = "/obj/item/projectile"
	var/kill_count = 50 //This will de-increment every process(). When 0, it will delete the projectile.
		//Effects
	var/stun = 0
	var/weaken = 0
	var/paralyze = 0
	var/irradiate = 0
	var/stutter = 0
	var/eyeblur = 0
	var/drowsy = 0
	var/forcedodge = 0


	proc/delete()
		// Garbage collect the projectiles
		loc = null

	proc/on_hit(var/atom/target, var/blocked = 0)
		if(blocked >= 2)		return 0//Full block
		if(!isliving(target))	return 0
		if(isanimal(target))	return 0
		var/mob/living/L = target
		L.apply_effects(stun, weaken, paralyze, irradiate, stutter, eyeblur, drowsy, blocked)
		return 1


	Bump(atom/A as mob|obj|turf|area)
		if(A == firer)
			loc = A.loc
			return 0 //cannot shoot yourself

		if(bumped)	return 0

		bumped = 1
		if(ismob(A))
			var/mob/M = A
			if(!istype(A, /mob/living))
				loc = A.loc
				return 0// nope.avi

			var/distance = get_dist(get_turf(A), starting) // Get the distance between the turf shot from and the mob we hit and use that for the calculations.
			def_zone = ran_zone(def_zone, max(100-(7*distance), 5)) //Lower accurancy/longer range tradeoff. 7 is a balanced number to use.
			if(silenced)
				M << "<span class='userdanger'>You've been shot in the [parse_zone(def_zone)] by [src]!</span>"
			else
				M.visible_message("<span class='danger'>[M] is hit by [src] in the [parse_zone(def_zone)]!", \
									"<span class='userdanger'>[M] is hit by [src] in the [parse_zone(def_zone)]!")	//X has fired Y is now given by the guns so you cant tell who shot you if you could not see the shooter

			if(istype(firer, /mob))
				M.attack_log += "\[[time_stamp()]\] <b>[firer]/[firer.ckey]</b> shot <b>[M]/[M.ckey]</b> with a <b>[src]</b>"
				firer.attack_log += "\[[time_stamp()]\] <b>[firer]/[firer.ckey]</b> shot <b>[M]/[M.ckey]</b> with a <b>[src]</b>"
				log_attack("<font color='red'>[firer] ([firer.ckey]) shot [M] ([M.ckey]) with a [src]</font>")
			else
				M.attack_log += "\[[time_stamp()]\] <b>UNKNOWN SUBJECT (No longer exists)</b> shot <b>[M]/[M.ckey]</b> with a <b>[src]</b>"
				log_attack("<font color='red'>UNKNOWN shot [M] ([M.ckey]) with a [src]</font>")

		spawn(0)
			if(A)
				// We get the location before running A.bullet_act, incase the proc deletes A and makes it null
				var/turf/new_loc = null
				if(istype(A, /turf))
					new_loc = A
				else
					new_loc = A.loc

				var/permutation = A.bullet_act(src, def_zone) // searches for return value, could be deleted after run so check A isn't null

				if(permutation == -1 || (forcedodge && !istype(A, /turf)))// the bullet passes through a dense object!
					bumped = 0 // reset bumped variable!
					loc = new_loc
					permutated.Add(A)
					return 0

				density = 0
				invisibility = 101
				delete()
				return 0
		return 1


	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(air_group || (height==0)) return 1

		if(istype(mover, /obj/item/projectile))
			return prob(95)
		else
			return 1


	process()
		if(kill_count < 1)
			delete()
			return
		kill_count--
		spawn while(src && src.loc)
			if((!( current ) || loc == current))
				current = locate(min(max(x + xo, 1), world.maxx), min(max(y + yo, 1), world.maxy), z)
			if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
				delete()
				return
			step_towards(src, current)
			sleep(1)
			if(!bumped && !isturf(original))
				if(loc == get_turf(original))
					if(!(original in permutated))
						Bump(original)
						sleep(1)
		return
