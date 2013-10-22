/obj/structure/stool/bed/chair/segway
	name = "security segway"
	desc = "Gives the illusion of authority."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "sec_seg_idle"
	anchored = 1
	density = 1

	var/health = 100
	var/delay = 5	//Move delay to simulate a speed
	var/allowMove = 1
	var/datum/global_iterator/space_move //Handling space movement (i.e. drift forever)

/obj/structure/stool/bed/chair/segway/New()
	handle_rotation()
	space_move = new /datum/global_iterator/space_movement(null,0)
	return

/obj/structure/stool/bed/chair/segway/relaymove(mob/user, direction)
	if(user.stat || user.stunned || user.weakened || user.paralysis)
		unbuckle()
		icon_state = "sec_seg_idle"
	if(istype(user.l_hand, /obj/item/sec_seg_key) || istype(user.r_hand, /obj/item/sec_seg_key))
		if(!allowMove)
			return
		if(src.space_move.active())
			return
		allowMove = 0
		step(src, direction)
		update_mob()
		handle_rotation()
		if(istype(src.loc, /turf/space))
			src.space_move.start(list(src,direction))
		if(istype(src.loc, /turf/simulated))
			var/turf/simulated/T = src.loc
			if(T.wet == 2)	//Lube! Fall off!
				playsound(src, 'sound/misc/slip.ogg', 50, 1, -3)
				buckled_mob.Stun(8)
				buckled_mob.Weaken(5)
				unbuckle()
				step(src, dir)
		sleep(delay)
		allowMove = 1
	else
		user << "<span class='notice'>Requires key in hand to drive.</span>"

/obj/structure/stool/bed/chair/segway/Move()
	. = ..()
	if(buckled_mob)
		if(buckled_mob.buckled == src)
			buckled_mob.loc = loc
	return .

/obj/structure/stool/bed/chair/segway/Bump(var/atom/obstacle)
	if(istype(obstacle, /mob))
		step(obstacle, src.dir)
	else
		obstacle.Bumped(src)
	return

/obj/structure/stool/bed/chair/segway/buckle_mob(mob/M, mob/user)
        if(M != user || !ismob(M) || get_dist(src, user) > 1 || user.restrained() || user.lying || user.stat || M.buckled || istype(user, /mob/living/silicon))
                return

        unbuckle()

        M.visible_message(\
                "<span class='notice'>[M] climbs onto the segway!</span>",\
                "<span class='notice'>You climb onto the segway!</span>")
        M.buckled = src
        M.loc = loc
        M.dir = dir
        M.update_canmove()
        buckled_mob = M
        update_mob()
        add_fingerprint(user)
        icon_state = "sec_seg_move"
        buckled_mob.pixel_x = 0
        buckled_mob.pixel_y = 5

/obj/structure/stool/bed/chair/segway/unbuckle()
        if(buckled_mob)
                buckled_mob.pixel_x = 0
                buckled_mob.pixel_y = 0
        ..()

/obj/structure/stool/bed/chair/segway/handle_rotation()
        if(dir == NORTH)
                layer = OBJ_LAYER
        else
                layer = FLY_LAYER

        if(buckled_mob)
                if(buckled_mob.loc != loc)
                        buckled_mob.buckled = null
                        buckled_mob.buckled = src

        update_mob()

/obj/structure/stool/bed/chair/segway/proc/update_mob()
        if(buckled_mob)
                buckled_mob.dir = dir

/obj/structure/stool/bed/chair/segway/bullet_act(var/obj/item/projectile/Proj)
	if(buckled_mob)
		return buckled_mob.bullet_act(Proj)
	else if(istype(Proj, /obj/item/projectile/beam))
		damage(Proj.damage)

/obj/structure/stool/bed/chair/segway/proc/damage(amount)
	health -= amount			
	if(health <= 0)
		if(buckled_mob)
			buckled_mob << "The segway was destroyed!"
		Del()

/obj/item/sec_seg_key
	name = "security segway key"
	desc = "A key for a security segway. You feel the choice of keyring could be more professional."
	icon = 'icons/obj/vehicles.dmi'
	icon_state = "keys" 	//Needs a proper sprite
	w_class = 1

/datum/global_iterator/space_movement	//moon_theme.mp3
	delay = 5
	
	process(var/obj/structure/stool/bed/chair/segway/seg as obj,direction)
		if(!step(seg, direction))
			src.stop()
