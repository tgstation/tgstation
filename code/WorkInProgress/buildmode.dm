/proc/togglebuildmode(mob/M as mob in world)
	set name = "Toggle Build Mode"
	set category = "Special Verbs"
	if(M.client)
		if(M.client.buildmode)
			log_admin("[key_name(usr)] has left build mode.")
			M.client.buildmode = 0
			M.client.show_popup_menus = 1
			for(var/obj/effect/bmode/buildholder/H)
				if(H.cl == M.client)
					del(H)
		else
			log_admin("[key_name(usr)] has entered build mode.")
			M.client.buildmode = 1
			M.client.show_popup_menus = 0

			var/obj/effect/bmode/buildholder/H = new/obj/effect/bmode/buildholder()
			var/obj/effect/bmode/builddir/A = new/obj/effect/bmode/builddir(H)
			A.master = H
			var/obj/effect/bmode/buildhelp/B = new/obj/effect/bmode/buildhelp(H)
			B.master = H
			var/obj/effect/bmode/buildmode/C = new/obj/effect/bmode/buildmode(H)
			C.master = H
			var/obj/effect/bmode/buildquit/D = new/obj/effect/bmode/buildquit(H)
			D.master = H

			H.builddir = A
			H.buildhelp = B
			H.buildmode = C
			H.buildquit = D
			M.client.screen += A
			M.client.screen += B
			M.client.screen += C
			M.client.screen += D
			H.cl = M.client

/obj/effect/bmode//Cleaning up the tree a bit
	density = 1
	anchored = 1
	layer = 20
	dir = NORTH
	icon = 'buildmode.dmi'
	var/obj/effect/bmode/buildholder/master = null

/obj/effect/bmode/builddir
	icon_state = "build"
	screen_loc = "NORTH,WEST"
	Click()
		switch(dir)
			if(NORTH)
				dir = EAST
			if(EAST)
				dir = SOUTH
			if(SOUTH)
				dir = WEST
			if(WEST)
				dir = NORTHWEST
			if(NORTHWEST)
				dir = NORTH
		return

/obj/effect/bmode/buildhelp
	icon = 'buildmode.dmi'
	icon_state = "buildhelp"
	screen_loc = "NORTH,WEST+1"
	Click()
		switch(master.cl.buildmode)
			if(1)
				usr << "\blue ***********************************************************"
				usr << "\blue Left Mouse Button        = Construct / Upgrade"
				usr << "\blue Right Mouse Button       = Deconstruct / Delete / Downgrade"
				usr << "\blue Left Mouse Button + ctrl = R-Window"
				usr << "\blue Left Mouse Button + alt  = Airlock"
				usr << ""
				usr << "\blue Use the button in the upper left corner to"
				usr << "\blue change the direction of built objects."
				usr << "\blue ***********************************************************"
			if(2)
				usr << "\blue ***********************************************************"
				usr << "\blue Right Mouse Button on buildmode button = Set object type"
				usr << "\blue Left Mouse Button on turf/obj          = Place objects"
				usr << "\blue Right Mouse Button                     = Delete objects"
				usr << ""
				usr << "\blue Use the button in the upper left corner to"
				usr << "\blue change the direction of built objects."
				usr << "\blue ***********************************************************"
			if(3)
				usr << "\blue ***********************************************************"
				usr << "\blue Right Mouse Button on buildmode button = Select var(type) & value"
				usr << "\blue Left Mouse Button on turf/obj/mob      = Set var(type) & value"
				usr << "\blue Right Mouse Button on turf/obj/mob     = Reset var's value"
				usr << "\blue ***********************************************************"
			if(4)
				usr << "\blue ***********************************************************"
				usr << "\blue Left Mouse Button on turf/obj/mob      = Throw"
				usr << "\blue Right Mouse Button on turf/obj/mob     = Select"
				usr << "\blue ***********************************************************"
		return

/obj/effect/bmode/buildquit
	icon_state = "buildquit"
	screen_loc = "NORTH,WEST+3"

	Click()
		togglebuildmode(master.cl.mob)

/obj/effect/bmode/buildholder
	density = 0
	anchored = 1
	var/client/cl = null
	var/obj/effect/bmode/builddir/builddir = null
	var/obj/effect/bmode/buildhelp/buildhelp = null
	var/obj/effect/bmode/buildmode/buildmode = null
	var/obj/effect/bmode/buildquit/buildquit = null
	var/atom/movable/throw_atom = null

/obj/effect/bmode/buildmode
	icon_state = "buildmode1"
	screen_loc = "NORTH,WEST+2"
	var/varholder = "name"
	var/valueholder = "derp"
	var/objholder = "/obj/structure/closet"

	Click(location, control, params)
		var/list/pa = params2list(params)

		if(pa.Find("left"))
			switch(master.cl.buildmode)
				if(1)
					master.cl.buildmode = 2
					src.icon_state = "buildmode2"
				if(2)
					master.cl.buildmode = 3
					src.icon_state = "buildmode3"
				if(3)
					master.cl.buildmode = 4
					src.icon_state = "buildmode4"
				if(4)
					master.cl.buildmode = 1
					src.icon_state = "buildmode1"

		else if(pa.Find("right"))
			switch(master.cl.buildmode)
				if(1)
					return
				if(2)
					objholder = input(usr,"Enter typepath:" ,"Typepath","/obj/structure/closet")
					var/list/removed_paths = list("/obj/effect/bhole")
					if(objholder in removed_paths)
						alert("That path is not allowed.")
						objholder = "/obj/structure/closet"
					else if (dd_hasprefix(objholder, "/mob") && !(usr.client.holder.rank in list("Game Master", "Game Admin", "Badmin")))
						objholder = "/obj/structure/closet"
				if(3)
					var/list/locked = list("vars", "key", "ckey", "client", "firemut", "ishulk", "telekinesis", "xray", "virus", "viruses", "cuffed", "ka", "last_eaten", "urine")

					master.buildmode.varholder = input(usr,"Enter variable name:" ,"Name", "name")
					if(master.buildmode.varholder in locked && !(usr.client.holder.rank in list("Game Master", "Game Admin")))
						return
					var/thetype = input(usr,"Select variable type:" ,"Type") in list("text","number","mob-reference","obj-reference","turf-reference")
					if(!thetype) return
					switch(thetype)
						if("text")
							master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value", "value") as text
						if("number")
							master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value", 123) as num
						if("mob-reference")
							master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value") as mob in world
						if("obj-reference")
							master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value") as obj in world
						if("turf-reference")
							master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value") as turf in world


/proc/build_click(var/mob/user, buildmode, location, control, params, var/obj/object)
	var/obj/effect/bmode/buildholder/holder = null
	for(var/obj/effect/bmode/buildholder/H)
		if(H.cl == user.client)
			holder = H
			break
	if(!holder) return
	var/list/pa = params2list(params)

	switch(buildmode)
		if(1)
			if(istype(object,/turf) && pa.Find("left") && !pa.Find("alt") && !pa.Find("ctrl") )
				if(istype(object,/turf/space))
					var/turf/T = object
					T.ReplaceWithFloor()
					return
				else if(istype(object,/turf/simulated/floor))
					var/turf/T = object
					T.ReplaceWithWall()
					return
				else if(istype(object,/turf/simulated/wall))
					var/turf/T = object
					T.ReplaceWithRWall()
					return
			else if(pa.Find("right"))
				if(istype(object,/turf/simulated/wall))
					var/turf/T = object
					T.ReplaceWithFloor()
					return
				else if(istype(object,/turf/simulated/floor))
					var/turf/T = object
					T.ReplaceWithSpace()
					return
				else if(istype(object,/turf/simulated/wall/r_wall))
					var/turf/T = object
					T.ReplaceWithWall()
					return
				else if(istype(object,/obj))
					del(object)
					return
			else if(istype(object,/turf) && pa.Find("alt") && pa.Find("left"))
				new/obj/machinery/door/airlock(get_turf(object))
			else if(istype(object,/turf) && pa.Find("ctrl") && pa.Find("left"))
				switch(holder.builddir.dir)
					if(NORTH)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.dir = NORTH
					if(SOUTH)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.dir = SOUTH
					if(EAST)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.dir = EAST
					if(WEST)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.dir = WEST
					if(NORTHWEST)
						var/obj/structure/window/reinforced/WIN = new/obj/structure/window/reinforced(get_turf(object))
						WIN.dir = NORTHWEST
		if(2)
			if(pa.Find("left"))
				var/obj/A = new holder.buildmode.objholder (get_turf(object))
				A.dir = holder.builddir.dir
				blink(A)
			else if(pa.Find("right"))
				if(isobj(object)) del(object)

		if(3)
			if(pa.Find("left")) //I cant believe this shit actually compiles.
				if(object.vars.Find(holder.buildmode.varholder))
					log_admin("[key_name(usr)] modified [object.name]'s [holder.buildmode.varholder] to [holder.buildmode.valueholder]")
					object.vars[holder.buildmode.varholder] = holder.buildmode.valueholder
					blink(object)
				else
					usr << "\red [initial(object.name)] does not have a var called '[holder.buildmode.varholder]'"
			if(pa.Find("right"))
				if(object.vars.Find(holder.buildmode.varholder))
					log_admin("[key_name(usr)] modified [object.name]'s [holder.buildmode.varholder] to [holder.buildmode.valueholder]")
					object.vars[holder.buildmode.varholder] = initial(object.vars[holder.buildmode.varholder])
					blink(object)
				else
					usr << "\red [initial(object.name)] does not have a var called '[holder.buildmode.varholder]'"

		if(4)
			if(pa.Find("left"))
				holder.throw_atom = object
			if(pa.Find("right"))
				if(holder.throw_atom)
					holder.throw_atom.throw_at(object, 10, 1)

/proc/blink(atom/A)
	A.icon += rgb(0,75,75)
	spawn(5)
		if(A)
			A.icon = initial(A.icon)
