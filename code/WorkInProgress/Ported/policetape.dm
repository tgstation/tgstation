
/obj/item/taperoll/police
	name = "police tape"
	desc = "A roll of police tape used to block off crime scenes from the public."
	icon_state = "police_start"
	tape_type = /obj/item/tape/police
	icon_base = "police"

/obj/item/tape/police
	name = "police tape"
	desc = "A length of police tape.  Do not cross."
	req_access = list(access_security)
	icon_base = "police"

/obj/item/taperoll/engineering
	name = "engineering tape"
	desc = "A roll of engineering tape used to block off working areas from the public."
	icon_state = "engineering_start"
	tape_type = /obj/item/tape/engineering
	icon_base = "engineering"

/obj/item/tape/engineering
	name = "engineering tape"
	desc = "A length of engineering tape. Better not cross it."
	req_access = list(access_engine,access_atmospherics)
	icon_base = "engineering"

/obj/item/taperoll/attack_self(mob/user as mob)
	if(icon_state == "[icon_base]_start")
		start = get_turf(src)
		usr << "\blue You place the first end of the [src]."
		icon_state = "[icon_base]_stop"
	else
		icon_state = "[icon_base]_start"
		end = get_turf(src)
		if(start.y != end.y && start.x != end.x || start.z != end.z)
			usr << "\blue [src] can only be laid horizontally or vertically."

		var/turf/cur = start
		var/dir
		if (start.x == end.x)
			var/d = end.y-start.y
			if(d) d = d/abs(d)
			end = get_turf(locate(end.x,end.y+d,end.z))
			dir = "v"
		else
			var/d = end.x-start.x
			if(d) d = d/abs(d)
			end = get_turf(locate(end.x+d,end.y,end.z))
			dir = "h"

		var/can_place = 1
		while (cur!=end && can_place)
			if(cur.density == 1)
				can_place = 0
			else
				for(var/obj/O in cur)
					if(O.density)
						can_place = 0
						break
			cur = get_step_towards(cur,end)
		if (!can_place)
			usr << "\blue You can't run \the [src] through that!"
			return

		cur = start
		var/tapetest = 0
		while (cur!=end)
			for(var/obj/item/tape/Ptest in cur)
				if(Ptest.icon_state == "[Ptest.icon_base]_[dir]")
					tapetest = 1
			if(tapetest != 1)
				var/obj/item/tape/P = new tape_type(cur)
				P.icon_state = "[P.icon_base]_[dir]"
			cur = get_step_towards(cur,end)
	//is_blocked_turf(var/turf/T)
		usr << "\blue You finish placing the [src]."	//Git Test

/obj/item/taperoll/police/afterattack(var/atom/A, mob/user as mob)
	if (istype(A, /obj/machinery/door/airlock))
		var/turf/T = get_turf(A)
		var/obj/item/tape/P = new tape_type(T.x,T.y,T.z)
		P.loc = locate(T.x,T.y,T.z)
		P.icon_state = "[src.icon_base]_door"
		P.layer = 3.2
		user << "\blue You finish placing the [src]."

/obj/item/tape/Bumped(M as mob)
	if(src.allowed(M))
		var/turf/T = get_turf(src)
		M:loc = T

/obj/item/tape/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(!density) return 1
	if(air_group || (height==0)) return 1

	if ((mover.flags & 2 || istype(mover, /obj/effect/meteor) || mover.throwing == 1) )
		return 1
	else
		return 0

/obj/item/tape/attackby(obj/item/weapon/W as obj, mob/user as mob)
	breaktape(W, user)

/obj/item/tape/attack_hand(mob/user as mob)
	if (user.a_intent == "help" && src.allowed(user))
		user.show_viewers("\blue [user] lifts [src], allowing passage.")
		src.density = 0
		spawn(200)
			src.density = 1
	else
		breaktape(null, user)

/obj/item/tape/attack_paw(mob/user as mob)
	breaktape(/obj/item/weapon/wirecutters,user)

/obj/item/tape/proc/breaktape(obj/item/weapon/W as obj, mob/user as mob)
	if(user.a_intent == "help" && ((!is_sharp(W) && src.allowed(user)) ||(!is_cut(W) && !src.allowed(user))))
		user << "You can't break the [src] with that!"
		return
	user.show_viewers("\blue [user] breaks the [src]!")

	var/dir[2]
	var/icon_dir = src.icon_state
	if(icon_dir == "[src.icon_base]_h")
		dir[1] = EAST
		dir[2] = WEST
	if(icon_dir == "[src.icon_base]_v")
		dir[1] = NORTH
		dir[2] = SOUTH

	for(var/i=1;i<3;i++)
		var/N = 0
		var/turf/cur = get_step(src,dir[i])
		while(N != 1)
			N = 1
			for (var/obj/item/tape/P in cur)
				if(P.icon_state == icon_dir)
					N = 0
					del(P)
			cur = get_step(cur,dir[i])

	del(src)
	return


