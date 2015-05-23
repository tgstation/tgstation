/proc/togglebuildmode(mob/M as mob in player_list)
	set name = "Toggle Build Mode"
	set category = "Special Verbs"
	if(M.client)
		if(M.client.buildmode)
			log_admin("[key_name(usr)] has left build mode.")
			M.client.buildmode = 0
			M.client.show_popup_menus = 1
			for(var/obj/effect/bmode/buildholder/H)
				if(H.cl == M.client)
					qdel(H)
		else
			message_admins("[key_name(usr)] has entered build mode.")
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
	icon = 'icons/misc/buildmode.dmi'
	var/obj/effect/bmode/buildholder/master = null

/obj/effect/bmode/builddir
	icon_state = "build"
	screen_loc = "NORTH,WEST"

/obj/effect/bmode/builddir/Click()
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
	return 1

/obj/effect/bmode/buildhelp
	icon = 'icons/misc/buildmode.dmi'
	icon_state = "buildhelp"
	screen_loc = "NORTH,WEST+1"

/obj/effect/bmode/buildhelp/Click()
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
			usr << "\blue Left Mouse Button on turf/obj/mob      = Select"
			usr << "\blue Right Mouse Button on turf/obj/mob     = Throw"
			usr << "\blue ***********************************************************"
	return 1

/obj/effect/bmode/buildquit
	icon_state = "buildquit"
	screen_loc = "NORTH,WEST+3"

/obj/effect/bmode/buildquit/Click()
	togglebuildmode(master.cl.mob)
	return 1

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
	var/objholder = /obj/structure/closet

/obj/effect/bmode/buildmode/Click(location, control, params)
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
				return 1
			if(2)
				objholder = text2path(input(usr,"Enter typepath:" ,"Typepath","/obj/structure/closet"))
				if(!ispath(objholder))
					objholder = /obj/structure/closet
					alert("That path is not allowed.")
				else
					if(ispath(objholder,/mob) && !check_rights(R_DEBUG,0))
						objholder = /obj/structure/closet
			if(3)
				var/list/locked = list("vars", "key", "ckey", "client", "firemut", "ishulk", "telekinesis", "xray", "virus", "viruses", "cuffed", "ka", "last_eaten", "urine")

				master.buildmode.varholder = input(usr,"Enter variable name:" ,"Name", "name")
				if(master.buildmode.varholder in locked && !check_rights(R_DEBUG,0))
					return 1
				var/thetype = input(usr,"Select variable type:" ,"Type") in list("text","number","mob-reference","obj-reference","turf-reference")
				if(!thetype) return 1
				switch(thetype)
					if("text")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value", "value") as text
					if("number")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value", 123) as num
					if("mob-reference")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value") as mob in mob_list
					if("obj-reference")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value") as obj in world
					if("turf-reference")
						master.buildmode.valueholder = input(usr,"Enter variable value:" ,"Value") as turf in world
	return 1


/proc/build_click(var/mob/user, buildmode, params, var/obj/object)
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
				var/turf/T = object
				if(istype(object,/turf/space))
					T.ChangeTurf(/turf/simulated/floor/plasteel)
				else if(istype(object,/turf/simulated/floor))
					T.ChangeTurf(/turf/simulated/wall)
				else if(istype(object,/turf/simulated/wall))
					T.ChangeTurf(/turf/simulated/wall/r_wall)
				log_admin("Build Mode: [key_name(usr)] built [T] at ([T.x],[T.y],[T.z])")
				return
			else if(pa.Find("right"))
				log_admin("Build Mode: [key_name(usr)] deleted [object] at ([object.x],[object.y],[object.z])")
				if(istype(object,/turf/simulated/wall))
					var/turf/T = object
					T.ChangeTurf(/turf/simulated/floor/plasteel)
				else if(istype(object,/turf/simulated/floor))
					var/turf/T = object
					T.ChangeTurf(/turf/space)
				else if(istype(object,/turf/simulated/wall/r_wall))
					var/turf/T = object
					T.ChangeTurf(/turf/simulated/wall)
				else if(istype(object,/obj))
					qdel(object)
				return
			else if(istype(object,/turf) && pa.Find("alt") && pa.Find("left"))
				log_admin("Build Mode: [key_name(usr)] built an airlock at ([object.x],[object.y],[object.z])")
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
				log_admin("Build Mode: [key_name(usr)] built a window at ([object.x],[object.y],[object.z])")
		if(2)
			if(pa.Find("left"))
				if(ispath(holder.buildmode.objholder,/turf))
					var/turf/T = get_turf(object)
					log_admin("Build Mode: [key_name(usr)] modified [T] ([T.x],[T.y],[T.z]) to [holder.buildmode.objholder]")
					T.ChangeTurf(holder.buildmode.objholder)
				else
					var/obj/A = new holder.buildmode.objholder (get_turf(object))
					A.dir = holder.builddir.dir
					log_admin("Build Mode: [key_name(usr)] modified [A]'s ([A.x],[A.y],[A.z]) dir to [holder.builddir.dir]")
			else if(pa.Find("right"))
				if(isobj(object))
					log_admin("Build Mode: [key_name(usr)] deleted [object] at ([object.x],[object.y],[object.z])")
					qdel(object)

		if(3)
			if(pa.Find("left")) //I cant believe this shit actually compiles.
				if(object.vars.Find(holder.buildmode.varholder))
					log_admin("Build Mode: [key_name(usr)] modified [object.name]'s [holder.buildmode.varholder] to [holder.buildmode.valueholder]")
					object.vars[holder.buildmode.varholder] = holder.buildmode.valueholder
				else
					usr << "<span class='warning'>[initial(object.name)] does not have a var called '[holder.buildmode.varholder]'</span>"
			if(pa.Find("right"))
				if(object.vars.Find(holder.buildmode.varholder))
					log_admin("Build Mode: [key_name(usr)] modified [object.name]'s [holder.buildmode.varholder] to [holder.buildmode.valueholder]")
					object.vars[holder.buildmode.varholder] = initial(object.vars[holder.buildmode.varholder])
				else
					usr << "<span class='warning'>[initial(object.name)] does not have a var called '[holder.buildmode.varholder]'</span>"

		if(4)
			if(pa.Find("left"))
				if(isturf(object))
					return
				holder.throw_atom = object
			if(pa.Find("right"))
				if(holder.throw_atom)
					holder.throw_atom.throw_at(object, 10, 1)
					log_admin("Build Mode: [key_name(usr)] threw [holder.throw_atom] at [object] ([object.x],[object.y],[object.z])")

