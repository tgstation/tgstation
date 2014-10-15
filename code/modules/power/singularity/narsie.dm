/obj/machinery/singularity/narsie //Moving narsie to a child object of the singularity so it can be made to function differently. --NEO
	name = "Nar-sie's Avatar"
	desc = "Your mind begins to bubble and ooze as it tries to comprehend what it sees."
	icon = 'icons/obj/magic_terror.dmi'
	pixel_x = -89
	pixel_y = -85
	current_size = 9 //It moves/eats like a max-size singulo, aside from range. --NEO
	contained = 0 //Are we going to move around?
	dissipate = 0 //Do we lose energy over time?
	move_self = 1 //Do we move on our own?
	grav_pull = 5 //How many tiles out do we pull?
	consume_range = 6 //How many tiles out do we eat
	uneatable = list(/turf/space, /obj/effect/overlay, /mob/living/simple_animal/construct)

/obj/machinery/singularity/narsie/large
	name = "Nar-Sie"
	icon = 'icons/obj/narsie.dmi'
	// Pixel stuff centers Narsie.
	pixel_x = -236
	pixel_y = -256
	current_size = 12
	move_self = 1 //Do we move on our own?
	grav_pull = 10
	consume_range = 12 //How many tiles out do we eat

/obj/machinery/singularity/narsie/large/New()
	..()
	world << "<font size='15' color='red'><b>NAR-SIE HAS RISEN</b></font>"
	world << pick(sound('sound/hallucinations/im_here1.ogg'), sound('sound/hallucinations/im_here2.ogg'))

	var/area/A = get_area(src)
	if(A)
		notify_ghosts("Nar-Sie has risen in \the [A.name]. Reach out to the Geometer to be given a new shell for your soul.")

	narsie_spawn_animation()

	sleep(70)
	if(emergency_shuttle)
		emergency_shuttle.incall(0.3) // Cannot recall


/obj/machinery/singularity/narsie/large/attack_ghost(mob/dead/observer/user as mob)
	makeNewConstruct(/mob/living/simple_animal/construct/harvester, user, null, 1)
	new /obj/effect/effect/sleep_smoke(user.loc)


/obj/machinery/singularity/narsie/process()
	eat()
	if(!target || prob(5))
		pickcultist()
	move()
	if(prob(25))
		mezzer()


/obj/machinery/singularity/narsie/Bump(atom/A)//you dare stand before a god?!
	godsmack(A)
	return

/obj/machinery/singularity/narsie/Bumped(atom/A)
	godsmack(A)
	return

/obj/machinery/singularity/narsie/proc/godsmack(var/atom/A)
	if(istype(A,/obj/))
		var/obj/O = A
		O.ex_act(1.0)
		if(O) qdel(O)

	else if(isturf(A))
		var/turf/T = A
		T.ChangeTurf(/turf/simulated/floor/engine/cult)


/obj/machinery/singularity/narsie/mezzer()
	for(var/mob/living/carbon/M in oviewers(8, src))
		if(M.stat == CONSCIOUS)
			if(!iscultist(M))
				M << "<span class='warning'>You feel your sanity crumble away in an instant as you gaze upon [src.name]...</span>"
				M.apply_effect(3, STUN)


/obj/machinery/singularity/narsie/consume(var/atom/A)
	if(is_type_in_list(A, uneatable))
		return 0

	if(istype(A,/mob/living/))
		var/mob/living/C = A
		if(C.client)
			makeNewConstruct(/mob/living/simple_animal/construct/harvester, C, null, 1)
		C.spawn_dust()
		C.gib()
		return

	if(isturf(A))
		var/turf/T = A
		if(istype(T, /turf/simulated/floor) && !istype(T, /turf/simulated/floor/engine/cult))
			if(prob(20)) T.ChangeTurf(/turf/simulated/floor/engine/cult)

		else if(istype(T,/turf/simulated/wall) && !istype(T, /turf/simulated/wall/cult))
			if(prob(20)) T.ChangeTurf(/turf/simulated/wall/cult)
	return


/obj/machinery/singularity/narsie/ex_act() //No throwing bombs at it either. --NEO
	return


/obj/machinery/singularity/narsie/proc/pickcultist() //Narsie rewards his cultists with being devoured first, then picks a ghost to follow. --NEO
	var/list/cultists = list()
	var/list/noncultists = list()
	for(var/mob/living/carbon/food in living_mob_list) //we don't care about constructs or cult-Ians or whatever. cult-monkeys are fair game i guess
		var/turf/pos = get_turf(food)
		if(pos.z != src.z)
			continue

		if(iscultist(food))
			cultists += food
		else
			noncultists += food

		if(cultists.len) //cultists get higher priority
			acquire(pick(cultists))
			return

		if(noncultists.len)
			acquire(pick(noncultists))
			return

	//no living humans, follow a ghost instead.
	for(var/mob/dead/observer/ghost in player_list)
		if(!ghost.client)
			continue
		var/turf/pos = get_turf(ghost)
		if(pos.z != src.z)
			continue
		cultists += ghost
	if(cultists.len)
		acquire(pick(cultists))
		return


/obj/machinery/singularity/narsie/proc/acquire(var/mob/food)
	target << "<span class='notice'>NAR-SIE HAS LOST INTEREST IN YOU</span>"
	target = food
	if(ishuman(target))
		target << "<span class ='userdanger'>NAR-SIE HUNGERS FOR YOUR SOUL</span>"
	else
		target << "<span class ='userdanger'>NAR-SIE HAS CHOSEN YOU TO LEAD HIM TO HIS NEXT MEAL</span>"

//Wizard narsie
/obj/machinery/singularity/narsie/wizard
	grav_pull = 0

/obj/machinery/singularity/narsie/wizard/eat()
	set background = BACKGROUND_ENABLED
//	if(defer_powernet_rebuild != 2)
//		defer_powernet_rebuild = 1
	for(var/atom/X in orange(consume_range,src))
		if(isturf(X) || istype(X, /atom/movable))
			consume(X)
//	if(defer_powernet_rebuild != 2)
//		defer_powernet_rebuild = 0
	return


/obj/machinery/singularity/narsie/proc/narsie_spawn_animation()
	icon = 'icons/obj/narsie_spawn_anim.dmi'
	dir = SOUTH
	move_self = 0
	flick("narsie_spawn_anim",src)
	sleep(11)
	move_self = 1
	icon = initial(icon)

