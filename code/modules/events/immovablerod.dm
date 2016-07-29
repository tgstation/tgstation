//Immovable rod

//Passes through the station destroyed all dense objects and damage all dense turfs
//As well as hurting all dense mobs
//Recoded as a projectile for better movement/appearance

/datum/event/immovable_rod
	announceWhen = 100

/datum/event/immovable_rod/announce()
	command_alert("What the fuck was that?!", "General Alert")

/datum/event/immovable_rod/start()
	immovablerod()

/proc/immovablerod()
	var/startx = 0
	var/starty = 0
	var/endy = 0
	var/endx = 0
	var/startside = pick(cardinal)

//Starts near the transition edge of the zlevel at a random point on one of the four cardinal dirs
	switch(startside)
		if(NORTH)
			starty = world.maxy-TRANSITIONEDGE-5
			startx = rand(TRANSITIONEDGE+5,world.maxx-TRANSITIONEDGE-5)
		if(EAST)
			starty = rand(TRANSITIONEDGE+5,world.maxy-TRANSITIONEDGE-5)
			startx = world.maxx-TRANSITIONEDGE-5
		if(SOUTH)
			starty = TRANSITIONEDGE+5
			startx = rand(TRANSITIONEDGE+5,world.maxx-TRANSITIONEDGE-5)
		if(WEST)
			starty = rand(TRANSITIONEDGE+5,world.maxy-TRANSITIONEDGE-5)
			startx = TRANSITIONEDGE+5

//One of the turfs in the 60x60 square in the center of the zlevel
	endx = rand((world.maxx/2)-30,(world.maxx/2)+30)
	endy = rand((world.maxy/2)-30,(world.maxy/2)+30)

	new /obj/item/projectile/immovablerod(locate(startx, starty, 1), locate(endx, endy, 1))

/obj/item/projectile/immovablerod
	name = "\improper Immovable Rod"
	desc = "What the fuck is that?"
	icon = 'icons/obj/objects.dmi'
	icon_state = "immrod"
	throwforce = 100
	density = 1
	anchored = 1
	locked_atoms = list()
	grillepasschance = 0
	mouse_opacity = 1

/obj/item/projectile/immovablerod/New(atom/start, atom/end)
	..()
	step_delay = round(0.5, world.tick_lag)
	if(end)
		throw_at(end)

/obj/item/projectile/immovablerod/throw_at(atom/end)
	for(var/mob/dead/observer/people in observers)
		to_chat(people, "<span class = 'notice'>Immovable rod has been thrown at the station, <a href='?src=\ref[people];follow=\ref[src]'>Follow it</a></span>")
	original = end
	starting = loc
	current = loc
	OnFired()
	yo = target.y - y
	xo = target.x - x
	process()

/obj/item/projectile/immovablerod/ex_act()
	return

/obj/item/projectile/immovablerod/singularity_act(size,var/obj/machinery/singularity/singularity)
	singularity.expand(STAGE_FIVE) //An unstoppable object must have crazy mass, also seriously what are the chances of this
	qdel(src)

/obj/item/projectile/immovablerod/bresenham_step(var/distA, var/distB, var/dA, var/dB)
	if(step_delay)
		sleep(step_delay)
	if(error < 0)
		var/atom/newloc = get_step(src, dB)
		if(!newloc)
			bullet_die()
		forceMove(newloc)
		error += distA
		return 0//so that bullets going in diagonals don't move twice slower
	else
		var/atom/newloc = get_step(src, dA)
		if(!newloc)
			bullet_die()
		forceMove(newloc)
		error -= distB
		return 1

/obj/item/projectile/immovablerod/forceMove(atom/destination,var/no_tp=0)
	..()
	if(z != starting.z)
		qdel(src)
		return

	if(loc.density)
		loc.ex_act(2)
		if(prob(25))
			clong()

	for(var/atom/clong in loc)
		if(!clong.density)
			continue

		if(istype(clong, /obj))
			if(clong.density)
				clong.ex_act(1)

		else if(istype(clong, /mob))
			if(istype(clong, /mob/living/carbon/human))
				var/mob/living/carbon/human/H = clong
				H.visible_message("<span class='danger'>[H.name] is penetrated by an immovable rod!</span>" , "<span class='userdanger'>The rod penetrates you!</span>" , "<span class ='danger'>You hear a CLANG!</span>")
				H.gib()
			else if(clong.density || (istype(clong,/mob/living) && prob(10))) //Only 1 Ian was harmed in the coding of this object, RIP
				clong.visible_message("<span class='danger'>[clong] is scraped by an immovable rod!</span>" , "<span class='userdanger'>The rod scrapes part of you off!</span>" , "<span class ='danger'>You hear a CLANG!</span>")
				clong.ex_act(2)

		if(prob(25) && (!clong || !clong.density || clong.gcDestroyed)) //did we just clear some shit?
			clong()

/obj/item/projectile/immovablerod/proc/clong()
	playsound(src, 'sound/effects/bang.ogg', 50, 1)
	visible_message("CLANG")