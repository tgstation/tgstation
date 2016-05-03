/mob/living/silicon/robot/gib(animation = 1)
	..()

/mob/living/silicon/robot/spawn_gibs()
	robogibs(loc, viruses)

/mob/living/silicon/robot/gib_animation(animate)
	..(animate, "gibbed-r")

/mob/living/silicon/robot/dust(animation = 1)
	if(mmi)
		qdel(mmi)
	..()

/mob/living/silicon/robot/spawn_dust()
	new /obj/effect/decal/remains/robot(loc)

/mob/living/silicon/robot/dust_animation(animate)
	..(animate, "dust-r")

/mob/living/silicon/robot/death(gibbed)
	if(stat == DEAD)
		return
	if(!gibbed)
		visible_message("<b>[src]</b> shudders violently for a moment before falling still, its eyes slowly darkening.")
	locked = 0 //unlock cover
	stat = DEAD
	update_canmove()
	if(camera && camera.status)
		camera.toggle_cam(src,0)
	update_headlamp(1) //So borg lights are disabled when killed.

	uneq_all() // particularly to ensure sight modes are cleared

	update_icons()

	sql_report_cyborg_death(src)

	return ..()