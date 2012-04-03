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
	name = "\improper Projectile"
	icon = 'projectiles.dmi'
	icon_state = "bullet"
	density = 1
	unacidable = 1
	anchored = 1 //There's a reason this is here, Mport. God fucking damn it -Agouri. Find&Fix by Pete. The reason this is here is to stop the curving of emitter shots.
	flags = FPRINT | TABLEPASS
	pass_flags = PASSTABLE
	mouse_opacity = 0
	var
		bumped = 0		//Prevents it from hitting more than one guy at once
		def_zone = ""	//Aiming at
		mob/firer = null//Who shot it
		silenced = 0	//Attack message
		yo = null
		xo = null
		current = null
		turf/original = null

		p_x = 16
		p_y = 16 // the pixel location of the tile that the player clicked. Default is the center

		damage = 10
		damage_type = BRUTE //BRUTE, BURN, TOX, OXY, CLONE are the only things that should be in here
		nodamage = 0 //Determines if the projectile will skip any damage inflictions
		flag = "bullet" //Defines what armor to use when it hits things.  Must be set to bullet, laser, energy,or bomb
		projectile_type = "/obj/item/projectile"
		//Effects
		stun = 0
		weaken = 0
		paralyze = 0
		irradiate = 0
		stutter = 0
		eyeblur = 0
		drowsy = 0


	proc/on_hit(var/atom/target, var/blocked = 0)
		if(blocked >= 2)	return 0//Full block
		if(!isliving(target))	return 0
		var/mob/living/L = target
		L.apply_effects(stun, weaken, paralyze, irradiate, stutter, eyeblur, drowsy, blocked)
		return 1


	proc/check_fire(var/mob/living/target as mob, var/mob/living/user as mob)  //Checks if you can hit them or not.
		if(!istype(target) || !istype(user))
			return 0
		var/obj/item/projectile/test/in_chamber = new /obj/item/projectile/test(get_step_to(user,target)) //Making the test....
		in_chamber.target = target
		in_chamber.flags = flags //Set the flags...
		in_chamber.pass_flags = pass_flags //And the pass flags to that of the real projectile...
		in_chamber.firer = user
		var/output = in_chamber.fired() //Test it!
		del(in_chamber) //No need for it anymore
		return output //Send it back to the gun!

	Bump(atom/A as mob|obj|turf|area)
		if(A == firer)
			loc = A.loc
			return //cannot shoot yourself

		if(bumped)	return

		bumped = 1
		if(firer && istype(A, /mob))
			var/mob/M = A
			if(!istype(A, /mob/living))
				loc = A.loc
				return // nope.avi

			if(!silenced)
				visible_message("\red [A] is hit by the [src]!")//X has fired Y is now given by the guns so you cant tell who shot you if you could not see the shooter
			else
				M << "\red You've been shot!"
			if(istype(firer, /mob))
				M.attack_log += text("\[[]\] <b>[]/[]</b> shot <b>[]/[]</b> with a <b>[]</b>", time_stamp(), firer, firer.ckey, M, M.ckey, src)
				firer.attack_log += text("\[[]\] <b>[]/[]</b> shot <b>[]/[]</b> with a <b>[]</b>", time_stamp(), firer, firer.ckey, M, M.ckey, src)
				log_admin("ATTACK: [firer] ([firer.ckey]) shot [M] ([M.ckey]) with [src].")
				message_admins("ATTACK: [firer] ([firer.ckey]) shot [M] ([M.ckey]) with [src].")
			else
				M.attack_log += text("\[[]\] <b>UNKNOWN SUBJECT (No longer exists)</b> shot <b>[]/[]</b> with a <b>[]</b>", time_stamp(), M, M.ckey, src)
				log_admin("ATTACK: UNKNOWN (no longer exists) shot [M] ([M.ckey]) with [src].")
				message_admins("ATTACK: UNKNOWN (no longer exists) shot [M] ([M.ckey]) with [src].")

		spawn(0)
			if(A)
				var/permutation = A.bullet_act(src, def_zone) // searches for return value
				if(permutation == -1) // the bullet passes through a dense object!
					bumped = 0 // reset bumped variable!
					if(istype(A, /turf))
						loc = A
					else
						loc = A.loc
					return

				if(istype(A,/turf))
					for(var/obj/O in A)
						O.bullet_act(src)
					for(var/mob/M in A)
						M.bullet_act(src, def_zone)

				density = 0
				invisibility = 101
				del(src)
		return


	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(air_group || (height==0)) return 1

		if(istype(mover, /obj/item/projectile))
			return prob(95)
		else
			return 1


	proc/fired()
		spawn while(src)
			if((!( current ) || loc == current))
				current = locate(min(max(x + xo, 1), world.maxx), min(max(y + yo, 1), world.maxy), z)
			if((x == 1 || x == world.maxx || y == 1 || y == world.maxy))
				del(src)
				return
			step_towards(src, current)
			sleep(1)
			if(!bumped)
				if(loc == original)
					for(var/mob/living/M in original)
						Bump(M)
						sleep(1)
		return

/obj/item/projectile/test //Used to see if you can hit them.
	invisibility = 101 //Nope!  Can't see me!
	yo = null
	xo = null
	var
		target = null
		result = 0 //To pass the message back to the gun.

	Bump(atom/A as mob|obj|turf|area)
		if(A == firer)
			loc = A.loc
			return //cannot shoot yourself
		if(istype(A, /obj/item/projectile))
			return
		if(istype(A, /mob/living))
			result = 2 //We hit someone, return 1!
			return
		result = 1
		return

	fired()
		var/turf/curloc = get_turf(src)
		var/turf/targloc = get_turf(target)
		yo = targloc.y - curloc.y
		xo = targloc.x - curloc.x
		target = targloc
		while(src) //Loop on through!
			if(result)
				return (result - 1)
			if((!( target ) || loc == target))
				target = locate(min(max(x + xo, 1), world.maxx), min(max(y + yo, 1), world.maxy), z) //Finding the target turf at map edge
			step_towards(src, target)
			var/mob/living/M = locate() in get_turf(src)
			if(istype(M)) //If there is someting living...
				return 1 //Return 1
			else
				M = locate() in get_step(src,target)
				if(istype(M))
					return 1