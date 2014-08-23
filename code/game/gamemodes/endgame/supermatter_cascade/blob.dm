// QUALITY COPYPASTA
/turf/unsimulated/wall/supermatter
	name = "supermatter"
	desc = "THE END IS right now actually."
	icon_state = "supermatter"
	luminosity = 5

	var/spawned=0 // DIR mask
	var/next_check=0
	var/list/avail_dirs = list(NORTH,SOUTH,EAST,WEST)

/turf/unsimulated/wall/supermatter/New()
	..()
	processing_objects.Add(src)
	next_check = world.time+5 SECONDS

/turf/unsimulated/wall/supermatter/Destroy()
	processing_objects.Remove(src)
	..()

/turf/unsimulated/wall/supermatter/proc/process()
	if(next_check>world.time) return
	if(avail_dirs.len==0)
		processing_objects.Remove(src)
		return 1
	next_check = world.time+5 SECONDS
	var/pdir = pick(avail_dirs)
	avail_dirs -= pdir
	var/turf/T=get_step(src,pdir)
	if(!istype(T,type))
		for(var/atom/movable/A in T)
			qdel(A)
		T.ChangeTurf(type)
	if(spawned & (NORTH|SOUTH|EAST|WEST))
		processing_objects -= src
		return

/turf/unsimulated/wall/supermatter/attack_paw(mob/user as mob)
	return attack_hand(user)

/turf/unsimulated/wall/supermatter/attack_robot(mob/user as mob)
	if(Adjacent(user))
		return attack_hand(user)
	else
		user << "<span class = \"warning\">What the fuck are you doing?</span>"
	return

// /vg/: Don't let ghosts fuck with this.
/turf/unsimulated/wall/supermatter/attack_ghost(mob/user as mob)
	src.examine()

/turf/unsimulated/wall/supermatter/attack_ai(mob/user as mob)
	user << "<span class = \"warning\">You attempt to interface with the control circuits but find they are not connected to your network.  Maybe in a future firmware update.</span>"

/turf/unsimulated/wall/supermatter/attack_hand(mob/user as mob)
	user.visible_message("<span class=\"warning\">\The [user] reaches out and touches \the [src], inducing a resonance... \his body starts to glow and bursts into flames before flashing into ash.</span>",\
		"<span class=\"danger\">You reach out and touch \the [src]. Everything starts burning and all you can hear is ringing. Your last thought is \"That was not a wise decision.\"</span>",\
		"<span class=\"warning\">You hear an unearthly noise as a wave of heat washes over you.</span>")

	playsound(src, 'sound/effects/supermatter.ogg', 50, 1)

	Consume(user)

/turf/unsimulated/wall/supermatter/attackby(obj/item/weapon/W as obj, mob/living/user as mob)
	user.visible_message("<span class=\"warning\">\The [user] touches \a [W] to \the [src] as a silence fills the room...</span>",\
		"<span class=\"danger\">You touch \the [W] to \the [src] when everything suddenly goes silent.\"</span>\n<span class=\"notice\">\The [W] flashes into dust as you flinch away from \the [src].</span>",\
		"<span class=\"warning\">Everything suddenly goes silent.</span>")

	playsound(src, 'sound/effects/supermatter.ogg', 50, 1)

	user.drop_from_inventory(W)
	Consume(W)

	user.apply_effect(150, IRRADIATE)


/turf/unsimulated/wall/supermatter/Bumped(atom/AM as mob|obj)
	if(istype(AM, /mob/living))
		AM.visible_message("<span class=\"warning\">\The [AM] slams into \the [src] inducing a resonance... \his body starts to glow and catch flame before flashing into ash.</span>",\
		"<span class=\"danger\">You slam into \the [src] as your ears are filled with unearthly ringing. Your last thought is \"Oh, fuck.\"</span>",\
		"<span class=\"warning\">You hear an unearthly noise as a wave of heat washes over you.</span>")
	else
		AM.visible_message("<span class=\"warning\">\The [AM] smacks into \the [src] and rapidly flashes to ash.</span>",\
		"<span class=\"warning\">You hear a loud crack as you are washed with a wave of heat.</span>")

	playsound(src, 'sound/effects/supermatter.ogg', 50, 1)

	Consume(AM)


/turf/unsimulated/wall/supermatter/proc/Consume(var/mob/living/user)
	if(istype(user))
		user.dust()
	else
		del user

		//Some poor sod got eaten, go ahead and irradiate people nearby.
	for(var/mob/living/l in range(10))
		if(l in view())
			l.show_message("<span class=\"warning\">As \the [src] slowly stops resonating, you find your skin covered in new radiation burns.</span>", 1,\
				"<span class=\"warning\">The unearthly ringing subsides and you notice you have new radiation burns.</span>", 2)
		else
			l.show_message("<span class=\"warning\">You hear an uneartly ringing and notice your skin is covered in fresh radiation burns.</span>", 2)
		var/rads = 500 * sqrt( 1 / (get_dist(l, src) + 1) )
		l.apply_effect(rads, IRRADIATE, 0) // Permit blocking