/obj/item/policetaperoll/attack_self(mob/user as mob)
	if(icon_state == "rollstart")
		tapestartx = src.loc.x
		tapestarty = src.loc.y
		tapestartz = src.loc.z
		usr << "\blue You place the first end of the police tape."
		icon_state = "rollstop"
	else
		tapeendx = src.loc.x
		tapeendy = src.loc.y
		tapeendz = src.loc.z
		var/tapetest = 0
		if(tapestartx == tapeendx && tapestarty > tapeendy && tapestartz == tapeendz)
			for(var/Y=tapestarty,Y>=tapeendy,Y--)
				var/turf/T = get_turf(locate(tapestartx,Y,tapestartz))
				if(T.density == 1)
					usr << "\blue You can't run police tape through a wall!"
					icon_state = "rollstart"
					return
			for(var/Y=tapestarty,Y>=tapeendy,Y--)
				var/turf/T = get_turf(locate(tapestartx,Y,tapestartz))
				for(var/obj/item/policetape/Ptest in T)
					if(Ptest.icon_state == "vertical")
						tapetest = 1
				if(tapetest != 1)
					var/obj/item/policetape/P = new/obj/item/policetape(tapestartx,Y,tapestartz)
					P.loc = locate(tapestartx,Y,tapestartz)
					P.icon_state = "vertical"
			usr << "\blue You finish placing the police tape."	//Git Test

		if(tapestartx == tapeendx && tapestarty < tapeendy && tapestartz == tapeendz)
			for(var/Y=tapestarty,Y<=tapeendy,Y++)
				var/turf/T = get_turf(locate(tapestartx,Y,tapestartz))
				if(T.density == 1)
					usr << "\blue You can't run police tape through a wall!"
					icon_state = "rollstart"
					return
			for(var/Y=tapestarty,Y<=tapeendy,Y++)
				var/turf/T = get_turf(locate(tapestartx,Y,tapestartz))
				for(var/obj/item/policetape/Ptest in T)
					if(Ptest.icon_state == "vertical")
						tapetest = 1
				if(tapetest != 1)
					var/obj/item/policetape/P = new/obj/item/policetape(tapestartx,Y,tapestartz)
					P.loc = locate(tapestartx,Y,tapestartz)
					P.icon_state = "vertical"
			usr << "\blue You finish placing the police tape."

		if(tapestarty == tapeendy && tapestartx > tapeendx && tapestartz == tapeendz)
			for(var/X=tapestartx,X>=tapeendx,X--)
				var/turf/T = get_turf(locate(X,tapestarty,tapestartz))
				if(T.density == 1)
					usr << "\blue You can't run police tape through a wall!"
					icon_state = "rollstart"
					return
			for(var/X=tapestartx,X>=tapeendx,X--)
				var/turf/T = get_turf(locate(X,tapestarty,tapestartz))
				for(var/obj/item/policetape/Ptest in T)
					if(Ptest.icon_state == "horizontal")
						tapetest = 1
				if(tapetest != 1)
					var/obj/item/policetape/P = new/obj/item/policetape(X,tapestarty,tapestartz)
					P.loc = locate(X,tapestarty,tapestartz)
					P.icon_state = "horizontal"
			usr << "\blue You finish placing the police tape."

		if(tapestarty == tapeendy && tapestartx < tapeendx && tapestartz == tapeendz)
			for(var/X=tapestartx,X<=tapeendx,X++)
				var/turf/T = get_turf(locate(X,tapestarty,tapestartz))
				if(T.density == 1)
					usr << "\blue You can't run police tape through a wall!"
					icon_state = "rollstart"
					return
			for(var/X=tapestartx,X<=tapeendx,X++)
				var/turf/T = get_turf(locate(X,tapestarty,tapestartz))
				for(var/obj/item/policetape/Ptest in T)
					if(Ptest.icon_state == "horizontal")
						tapetest = 1
				if(tapetest != 1)
					var/obj/item/policetape/P = new/obj/item/policetape(X,tapestarty,tapestartz)
					P.loc = locate(X,tapestarty,tapestartz)
					P.icon_state = "horizontal"
			usr << "\blue You finish placing the police tape."

		if(tapestarty != tapeendy && tapestartx != tapeendx)
			usr << "\blue Police tape can only be laid horizontally or vertically."
		icon_state = "rollstart"

/obj/item/policetape/Bumped(M as mob)
	if(src.allowed(M))
		var/turf/T = get_turf(src)
		M:loc = T

/obj/item/policetape/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0)) return 1

	if ((mover.flags & 2 || istype(mover, /obj/effect/meteor) || mover.throwing == 1) )
		return 1
	else
		return 0

/obj/item/policetape/attackby(obj/item/weapon/W as obj, mob/user as mob)
	breaktape(W, user)

/obj/item/policetape/attack_hand(mob/user as mob)
	breaktape(null, user)

/obj/item/policetape/attack_paw(mob/user as mob)
	breaktape(/obj/item/weapon/wirecutters,user)

/obj/item/policetape/proc/breaktape(obj/item/weapon/W as obj, mob/user as mob)
	if(user.a_intent == "help" && ((!is_sharp(W) && src.allowed(user)) ||(!is_cut(W) && !src.allowed(user))))
		user << "You can't break the tape with that!"
		return
	user.show_viewers(text("\blue [] breaks the police tape!", user))
	var/OX = src.x
	var/OY = src.y
	if(src.icon_state == "horizontal")
		var/N = 0
		var/X = OX + 1
		var/turf/T = src.loc
		while(N != 1)
			N = 1
			T = locate(X,T.y,T.z)
			for (var/obj/item/policetape/P in T)
				N = 0
				if(P.icon_state == "horizontal")
					del(P)
			X += 1

		X = OX - 1
		N = 0
		while(N != 1)
			N = 1
			T = locate(X,T.y,T.z)
			for (var/obj/item/policetape/P in T)
				N = 0
				if(P.icon_state == "horizontal")
					del(P)
			X -= 1

	if(src.icon_state == "vertical")
		var/N = 0
		var/Y = OY + 1
		var/turf/T = src.loc
		while(N != 1)
			N = 1
			T = locate(T.x,Y,T.z)
			for (var/obj/item/policetape/P in T)
				N = 0
				if(P.icon_state == "vertical")
					del(P)
			Y += 1

		Y = OY - 1
		N = 0
		while(N != 1)
			N = 1
			T = locate(T.x,Y,T.z)
			for (var/obj/item/policetape/P in T)
				N = 0
				if(P.icon_state == "vertical")
					del(P)
			Y -= 1

	del(src)
	return

/obj/item/policetaperoll/afterattack(var/atom/A, mob/user as mob)
	if (istype(A, /obj/machinery/door/airlock))
		var/turf/T = get_turf(A)
		var/obj/item/policetape/P = new/obj/item/policetape(T.x,T.y,T.z)
		P.loc = locate(T.x,T.y,T.z)
		P.icon_state = "door"
		P.layer = 3.2
		user << "\blue You finish placing the police tape."
