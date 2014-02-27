/mob/living/gib(var/animation = 1)
	var/prev_lying = lying
	death(1)

	var/atom/movable/overlay/animate = setup_animation(animation, prev_lying)
	if(animate)
		gib_animation(animate)

	spawn_gibs()

	end_animation(animate) // Will qdel(src)

/mob/living/proc/spawn_gibs()
	gibs(loc, viruses)

/mob/living/proc/gib_animation(var/animate, var/flick_name = "gibbed")
	flick(flick_name, animate)

/mob/living/dust(var/animation = 0)
	death(1)
	var/atom/movable/overlay/animate = setup_animation(animation, 0)
	if(animate)
		dust_animation(animate)

	spawn_dust()
	end_animation(animate)

/mob/living/proc/spawn_dust()
	new /obj/effect/decal/cleanable/ash(loc)

/mob/living/proc/dust_animation(var/animate, var/flick_name = "")
	flick(flick_name, animate)

/mob/living/death(gibbed)
	timeofdeath = world.time

	living_mob_list -= src
	if(!gibbed)
		dead_mob_list += src


/mob/living/proc/setup_animation(var/animation, var/prev_lying)
	var/atom/movable/overlay/animate = null
	notransform = 1
	canmove = 0
	icon = null
	invisibility = 101
	alpha = 0

	if(!prev_lying && animation)
		animate = new(loc)
		animate.icon_state = "blank"
		animate.icon = 'icons/mob/mob.dmi'
		animate.master = src
	return animate

/mob/living/proc/end_animation(var/animate)
	if(!animate)
		qdel(src)
	else
		spawn(15)
			if(animate)		qdel(animate)
			if(src)			qdel(src)