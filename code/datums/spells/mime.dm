/obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall
	name = "Invisible wall"
	desc = "Create an invisible wall on your location."
	school = "mime"
	panel = "Mime"
	summon_type = list(/obj/effect/forcefield/mime)
	invocation_type = "emote"
	summon_lifespan = 300
	charge_max = 300
	clothes_req = 0
	range = 0
	cast_sound = null


/obj/effect/proc_holder/spell/aoe_turf/conjure/mime_wall/Click()
	if(usr)
		invocation = "<B>[usr.real_name]</B> looks as if a wall is in front of them."
	else
		invocation_type ="none"
	..()

/obj/effect/forcefield/mime
	icon_state = "empty"
	name = "invisible wall"
	desc = "You have a bad feeling about this."
	var/timeleft = 300
	var/last_process = 0

/obj/effect/forcefield/mime/New()
	..()
	last_process = world.time
	processing_objects.Add(src)

/obj/effect/forcefield/mime/process()
	timeleft -= (world.time - last_process)
	if(timeleft <= 0)
		processing_objects.Remove(src)
		del(src)
