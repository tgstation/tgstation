/obj/singularity/narsie //Moving narsie to a child object of the singularity so it can be made to function differently. --NEO
	name = "Nar-sie's Avatar"
	desc = "Your mind begins to bubble and ooze as it tries to comprehend what it sees."
	icon = 'icons/obj/magic_terror.dmi'
	pixel_x = -89
	pixel_y = -85
	current_size = 9
	consume_range = 6

/obj/singularity/narsie/large
	name = "Nar-Sie"
	icon = 'icons/obj/narsie.dmi'
	// Pixel stuff centers Narsie.
	pixel_x = -236
	pixel_y = -256
	current_size = 12
	consume_range = 12

/obj/singularity/narsie/large/New()
	..()
	world << "<font size='15' color='red'><b>NAR-SIE HAS RISEN</b></font>"
	world << pick(sound('sound/hallucinations/im_here1.ogg'), sound('sound/hallucinations/im_here2.ogg'))
	var/area/A = get_area(src)
	if(A)
		notify_ghosts("Nar-Sie has risen in \the [A.name]. Reach out to the Geometer to be given a new shell for your soul.")
	narsie_spawn_animation()
	sleep(70)
	SSshuttle.emergency.request(null, 0.3) // Cannot recall

/obj/singularity/narsie/proc/narsie_spawn_animation()
	icon = 'icons/obj/narsie_spawn_anim.dmi'
	dir = SOUTH
	move_self = 0
	flick("narsie_spawn_anim",src)
	sleep(11)
	move_self = 1
	icon = initial(icon)

/obj/singularity/narsie/process()
	eat()
	if(!target || prob(5))
		pickcultist()
	move()
	if(prob(25))
		mezzer()

/obj/singularity/narsie/Move(NewLoc)
	for(var/obj/O in NewLoc)
		if(O.density)
			godsmack(O)
	godsmack(NewLoc)
	loc = NewLoc

/obj/singularity/narsie/Bump(atom/A)
	godsmack(A)
	return

/obj/singularity/narsie/Bumped(atom/A)
	godsmack(A)
	return

/obj/singularity/narsie/proc/godsmack(var/atom/A) //you dare stand before a goddess?!
	if(isobj(A))
		var/obj/O = A
		O.ex_act(1.0)
		if(O && !qdeleted(O))
			qdel(O)
	else
		if(isturf(A))
			A.narsie_act()

/obj/singularity/narsie/mezzer()
	for(var/mob/living/carbon/M in oviewers(8, src))
		if(M.stat == CONSCIOUS)
			if(!iscultist(M))
				M << "<span class='warning'>You feel your sanity crumble away in an instant as you gaze upon [src.name]...</span>"
				M.apply_effect(3, STUN)

/obj/singularity/narsie/consume(var/atom/A)
	A.narsie_act()

/obj/singularity/narsie/ex_act()
	return

/obj/singularity/narsie/proc/pickcultist() //picks() living, cultists first. Otherwise ghosts.
	var/list/cultists = list()
	var/list/noncultists = list()
	for(var/mob/living/carbon/food in living_mob_list)
		var/turf/pos = get_turf(food)
		if(pos.z != src.z)
			continue
		if(iscultist(food))
			cultists += food
		else
			noncultists += food
		if(cultists.len)
			acquire(pick(cultists))
			return
		if(noncultists.len)
			acquire(pick(noncultists))
			return
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

/obj/singularity/narsie/proc/acquire(var/mob/food)
	target << "<span class='notice'>NAR-SIE HAS LOST INTEREST IN YOU</span>"
	target = food
	if(ishuman(target))
		target << "<span class ='userdanger'>NAR-SIE HUNGERS FOR YOUR SOUL</span>"
	else
		target << "<span class ='userdanger'>NAR-SIE HAS CHOSEN YOU TO LEAD HIM TO HIS NEXT MEAL</span>"

/obj/singularity/narsie/large/attack_ghost(mob/dead/observer/user as mob)
	if(!(src in view()))
		user << "Your soul is too far away."
		return
	makeNewConstruct(/mob/living/simple_animal/construct/harvester, user, null, 1)
	PoolOrNew(/obj/effect/effect/smoke/sleeping, user.loc)





//Wizard away mission narsie
/obj/singularity/narsie/wizard

/obj/singularity/narsie/wizard/eat()
	set background = BACKGROUND_ENABLED
	for(var/atom/X in orange(consume_range,src))
		if(isturf(X) || istype(X, /atom/movable))
			consume(X)
	return