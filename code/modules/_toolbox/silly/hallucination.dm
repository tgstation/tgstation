/datum/hallucination/uber_mice_attack
	var/duration = 30

/datum/hallucination/uber_mice_attack/New(mob/living/carbon/C, forced = TRUE)
	set waitfor = FALSE
	..()
	var/list/startlist = list()
	var/therange = world.view+2
	var/turf/Cturf = get_turf(C)
	var/initializetimeout = world.time+200
	while(world.time <= initializetimeout && !startlist.len)
		for(var/turf/T in range(therange,Cturf))
			if(get_dist(Cturf,T) == therange)
				var/turf/current = T
				var/turf/end = Cturf
				var/fail = 0
				var/timeout = therange+1
				while(current != end && timeout > 0)
					timeout--
					var/turf/thestep = get_step(current,get_dir(current,end))
					if(thestep.density || istype(thestep,/turf/closed) || (!thestep.Adjacent(current)))
						fail = 1
						break
					for(var/obj/O in thestep)
						if(O.density)
							fail = 1
							break
					if(timeout <= 0 && get_dist(thestep,end > 1))
						fail = 1
					if(fail)
						break
					current = thestep
				if(!fail)
					startlist += T
		if(!startlist.len)
			sleep(10)
			Cturf = get_turf(C)
	if(startlist.len)
		var/turf/start = pick(startlist)
		var/list/mouses = list()
		var/thedirs = list(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST)
		for(var/i=rand(30,40),i>0,i--)
			var/obj/effect/hallucination/simple/zerg_mouse/Z = new(start,C)
			mouses[Z] = pick(thedirs)
		if(mouses.len)
			var/endtime = world.time+(duration*10)
			var/laststaminahit = 0
			while(C && world.time <= endtime)
				if(C.stat != CONSCIOUS)
					break
				if((!laststaminahit || laststaminahit+10 < world.time) && C.staminaloss < 50)
					laststaminahit = world.time
					C.staminaloss = 50
				for(var/obj/effect/hallucination/simple/zerg_mouse/mouse in mouses)
					spawn(0)
						var/turf/NewCturf = get_turf(C)
						var/turf/standlocation = get_step(NewCturf,mouses[mouse])
						if(prob(10))
							C.playsound_local(get_turf(mouse), 'sound/effects/mousesqueek.ogg', 100)
						if(get_dist(mouse,NewCturf) <= 1 && prob(30))
							mouse.bite(C)
						if(get_dist(mouse,standlocation) > 0)
							if(prob(20))
								step(mouse,pick(thedirs))
							else
								step_towards(mouse,standlocation)
				sleep(2)
			for(var/obj/effect/hallucination/simple/zerg_mouse/Z in mouses)
				qdel(Z)

/obj/effect/hallucination/simple/zerg_mouse
	name = "mouse"
	image_icon = 'icons/mob/animal.dmi'
	image_state = "mouse"
	var/last_bite = 0
	var/bite_delay = 15
	var/bitefakedamage = 2

/obj/effect/hallucination/simple/zerg_mouse/New()
	var/thecolor = pick("gray","white","brown")
	image_state = "[image_state]_[thecolor]"
	name = "[thecolor] [name]"
	..()

/obj/effect/hallucination/simple/zerg_mouse/proc/bite(mob/living/carbon/M)
	if(ismob(M) && get_dist(src,get_turf(M)) <= 1 && last_bite+bite_delay < world.time)
		last_bite = world.time
		setDir(get_dir(get_turf(src),get_turf(M)))
		Show()
		M.playsound_local(get_turf(src), 'sound/weapons/bite.ogg', 50)
		var/theverb = list("bitten","chomped","gnawed")
		if(M.stat == CONSCIOUS)
			to_chat(M,"<div class='warning'>You were [pick(theverb)] by [name].</div>")
		if(istype(M))
			M.staminaloss = min(M.staminaloss+bitefakedamage,111)
			if(prob(20))
				M.blur_eyes(3)
			if(M.staminaloss >= 90)
				M.Unconscious(80, updating = TRUE, ignore_canunconscious = FALSE)
				M.Sleeping(rand(80,150), 0)
			do_attack_animation(M)

/mob/living/carbon/proc/test_mouses()
	if(istype(src))
		new /datum/hallucination/uber_mice_attack(src,FALSE)