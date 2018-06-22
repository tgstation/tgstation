#define BASIC_BUILDMODE 1
#define ADV_BUILDMODE 2
#define VAR_BUILDMODE 3
#define THROW_BUILDMODE 4
#define AREA_BUILDMODE 5
#define COPY_BUILDMODE 6
#define NUM_BUILDMODES 6

//Buildmode Shuttle
//Builmode Move

/obj/screen/buildmode
	icon = 'icons/misc/buildmode.dmi'
	var/datum/buildmode/bd

/obj/screen/buildmode/New(bd)
	..()
	src.bd = bd

/obj/screen/buildmode/Destroy()
	bd.buttons -= src
	bd = null
	return ..()

/obj/screen/buildmode/mode
	icon_state = "buildmode1"
	name = "Toggle Mode"
	screen_loc = "NORTH,WEST"

/obj/screen/buildmode/mode/Click(location, control, params)
	var/list/pa = params2list(params)

	if(pa.Find("left"))
		bd.toggle_modes()
	else if(pa.Find("right"))
		bd.change_settings(usr)
	update_icon()
	return 1

/obj/screen/buildmode/mode/update_icon()
	icon_state = "buildmode[bd.mode]"
	return

/obj/screen/buildmode/help
	icon_state = "buildhelp"
	screen_loc = "NORTH,WEST+1"
	name = "Buildmode Help"

/obj/screen/buildmode/help/Click()
	bd.show_help(usr)
	return 1

/obj/screen/buildmode/bdir
	icon_state = "build"
	screen_loc = "NORTH,WEST+2"
	name = "Change Dir"


/obj/screen/buildmode/bdir/update_icon()
	setDir(bd.build_dir)
	return

/obj/screen/buildmode/quit
	icon_state = "buildquit"
	screen_loc = "NORTH,WEST+3"
	name = "Quit Buildmode"

/obj/screen/buildmode/quit/Click()
	bd.quit()
	return 1

/obj/screen/buildmode/bdir/Click()
	bd.change_dir()
	update_icon()
	return 1

/datum/buildmode
	var/mode = BASIC_BUILDMODE
	var/client/holder = null
	var/list/obj/screen/buttons = list()
	var/build_dir = SOUTH
	var/atom/movable/throw_atom = null
	var/turf/cornerA = null
	var/turf/cornerB = null
	var/generator_path = null
	var/varholder = "name"
	var/valueholder = "derp"
	var/objholder = /obj/structure/closet
	var/atom/movable/stored = null
	var/list/preview = list()

/datum/buildmode/New(client/c)
	create_buttons()
	holder = c
	holder.click_intercept = src
	holder.show_popup_menus = 0
	holder.screen += buttons

/datum/buildmode/proc/quit()
	holder.screen -= buttons
	holder.click_intercept = null
	holder.show_popup_menus = 1
	usr.client.images -= preview
	preview.Cut()
	qdel(src)
	return

/datum/buildmode/Destroy()
	stored = null
	QDEL_LIST(buttons)
	throw_atom = null
	holder = null
	preview.Cut()
	cornerA = null
	cornerB = null
	return ..()

/datum/buildmode/proc/create_buttons()
	buttons += new /obj/screen/buildmode/mode(src)
	buttons += new /obj/screen/buildmode/help(src)
	buttons += new /obj/screen/buildmode/bdir(src)
	buttons += new /obj/screen/buildmode/quit(src)

/datum/buildmode/proc/toggle_modes()
	mode = (mode % NUM_BUILDMODES) +1
	Reset()
	return

/datum/buildmode/proc/show_help(mob/user)
	var/list/dat = list()
	switch(mode)
		if(BASIC_BUILDMODE)
			dat += "***********************************************************"
			dat += "Left Mouse Button        = Construct / Upgrade"
			dat += "Right Mouse Button       = Deconstruct / Delete / Downgrade"
			dat += "Left Mouse Button + ctrl = R-Window"
			dat += "Left Mouse Button + alt  = Airlock"
			dat += ""
			dat += "Use the button in the upper left corner to"
			dat += "change the direction of built objects."
			dat += "***********************************************************"
		if(ADV_BUILDMODE)
			dat += "***********************************************************"
			dat += "Right Mouse Button on buildmode button = Set object type"
			dat += "Left Mouse Button + alt on turf/obj    = Copy object type"
			dat += "Left Mouse Button on turf/obj          = Place objects"
			dat += "Right Mouse Button                     = Delete objects"
			dat += ""
			dat += "Use the button in the upper left corner to"
			dat += "change the direction of built objects."
			dat += "***********************************************************"
		if(VAR_BUILDMODE)
			dat += "***********************************************************"
			dat += "Right Mouse Button on buildmode button = Select var(type) & value"
			dat += "Left Mouse Button on turf/obj/mob      = Set var(type) & value"
			dat += "Right Mouse Button on turf/obj/mob     = Reset var's value"
			dat += "***********************************************************"
		if(THROW_BUILDMODE)
			dat += "***********************************************************"
			dat += "Left Mouse Button on turf/obj/mob      = Select"
			dat += "Right Mouse Button on turf/obj/mob     = Throw"
			dat += "***********************************************************"
		if(AREA_BUILDMODE)
			dat += "***********************************************************"
			dat += "Left Mouse Button on turf/obj/mob      = Select corner"
			dat += "Right Mouse Button on turf/obj/mob     = Reset corner selection"
			dat += "Right Mouse Button on buildmode button = Select generator"
			dat += "***********************************************************"
		if(COPY_BUILDMODE)
			dat += "***********************************************************"
			dat += "Left Mouse Button on obj/turf/mob   = Spawn a Copy of selected target"
			dat += "Right Mouse Button on obj/mob = Select target to copy"
			dat += "***********************************************************"
	to_chat(user, "<font color='blue'>[dat.Join("\n")]</font>")

/datum/buildmode/proc/change_settings(mob/user)
	switch(mode)
		if(BASIC_BUILDMODE)
			return 1
		if(ADV_BUILDMODE)
			var/target_path = input(user,"Enter typepath:" ,"Typepath","/obj/structure/closet")
			objholder = text2path(target_path)
			if(!ispath(objholder))
				objholder = pick_closest_path(target_path)
				if(!objholder)
					objholder = /obj/structure/closet
					alert("That path is not allowed.")
			else
				if(ispath(objholder, /mob) && !check_rights(R_DEBUG,0))
					objholder = /obj/structure/closet
		if(VAR_BUILDMODE)
			var/list/locked = list("vars", "key", "ckey", "client", "firemut", "ishulk", "telekinesis", "xray", "virus", "viruses", "cuffed", "ka", "last_eaten", "urine")

			varholder = input(user,"Enter variable name:" ,"Name", "name")
			if(varholder in locked && !check_rights(R_DEBUG,0))
				return 1
			var/thetype = input(user,"Select variable type:" ,"Type") in list("text","number","mob-reference","obj-reference","turf-reference")
			if(!thetype)
				return 1
			switch(thetype)
				if("text")
					valueholder = input(user,"Enter variable value:" ,"Value", "value") as text
				if("number")
					valueholder = input(user,"Enter variable value:" ,"Value", 123) as num
				if("mob-reference")
					valueholder = input(user,"Enter variable value:" ,"Value") as mob in GLOB.mob_list
				if("obj-reference")
					valueholder = input(user,"Enter variable value:" ,"Value") as obj in world
				if("turf-reference")
					valueholder = input(user,"Enter variable value:" ,"Value") as turf in world
		if(AREA_BUILDMODE)
			var/list/gen_paths = subtypesof(/datum/mapGenerator)
			var/list/options = list()
			for(var/path in gen_paths)
				var/datum/mapGenerator/MP = path
				options[initial(MP.buildmode_name)] = path
			var/type = input(user,"Select Generator Type","Type") as null|anything in options
			if(!type)
				return

			generator_path = options[type]
			cornerA = null
			cornerB = null

/datum/buildmode/proc/change_dir()
	switch(build_dir)
		if(NORTH)
			build_dir = EAST
		if(EAST)
			build_dir = SOUTH
		if(SOUTH)
			build_dir = WEST
		if(WEST)
			build_dir = NORTHWEST
		if(NORTHWEST)
			build_dir = NORTH
	return 1

/datum/buildmode/proc/Reset()//Reset temporary variables
	cornerA = null
	cornerB = null

/proc/togglebuildmode(mob/M in GLOB.player_list)
	set name = "Toggle Build Mode"
	set category = "Special Verbs"
	if(M.client)
		if(istype(M.client.click_intercept, /datum/buildmode))
			var/datum/buildmode/B = M.client.click_intercept
			B.quit()
			log_admin("[key_name(usr)] has left build mode.")
		else
			new/datum/buildmode(M.client)
			message_admins("[key_name(usr)] has entered build mode.")
			log_admin("[key_name(usr)] has entered build mode.")


/datum/buildmode/proc/InterceptClickOn(user,params,atom/object) //Click Intercept
	var/list/pa = params2list(params)
	var/right_click = pa.Find("right")
	var/left_click = pa.Find("left")
	var/alt_click = pa.Find("alt")
	var/ctrl_click = pa.Find("ctrl")

	//Clicking on UI elements shouldn't try to build things in nullspace.
	if(istype(object,/obj/screen))
		return FALSE

	. = TRUE
	switch(mode)
		if(BASIC_BUILDMODE)
			if(isturf(object) && left_click && !alt_click && !ctrl_click)
				var/turf/T = object
				if(isspaceturf(object))
					T.PlaceOnTop(/turf/open/floor/plating)
				else if(isplatingturf(object))
					T.PlaceOnTop(/turf/open/floor/plasteel)
				else if(isfloorturf(object))
					T.PlaceOnTop(/turf/closed/wall)
				else if(iswallturf(object))
					T.PlaceOnTop(/turf/closed/wall/r_wall)
				log_admin("Build Mode: [key_name(user)] built [T] at [AREACOORD(T)]")
				return
			else if(right_click)
				log_admin("Build Mode: [key_name(user)] deleted [object] at [AREACOORD(object)]")
				if(isturf(object))
					var/turf/T = object
					T.ScrapeAway()
				else if(isobj(object))
					qdel(object)
				return
			else if(isturf(object) && alt_click && left_click)
				log_admin("Build Mode: [key_name(user)] built an airlock at [AREACOORD(object)]")
				new/obj/machinery/door/airlock(get_turf(object))
			else if(isturf(object) && ctrl_click && left_click)
				var/obj/structure/window/reinforced/window
				if(build_dir == NORTHWEST)
					window = new /obj/structure/window/reinforced/fulltile(get_turf(object))
				else
					window = new /obj/structure/window/reinforced(get_turf(object))
				window.setDir(build_dir)
				log_admin("Build Mode: [key_name(user)] built a window at [AREACOORD(object)]")
		if(ADV_BUILDMODE)
			if(left_click && alt_click)
				objholder = object.type
				to_chat(user, "<span class='notice'>[initial(object.name)] ([object.type]) selected.</span>")
			else if(left_click)
				if(ispath(objholder, /turf))
					var/turf/T = get_turf(object)
					log_admin("Build Mode: [key_name(user)] modified [T] in [AREACOORD(object)] to [objholder]")
					T.PlaceOnTop(objholder)
				else
					var/obj/A = new objholder (get_turf(object))
					A.setDir(build_dir)
					log_admin("Build Mode: [key_name(user)] modified [A]'s [COORD(A)] dir to [build_dir]")
			else if(right_click)
				if(isobj(object))
					log_admin("Build Mode: [key_name(user)] deleted [object] at [AREACOORD(object)]")
					qdel(object)

		if(VAR_BUILDMODE)
			if(left_click) //I cant believe this shit actually compiles.
				if(object.vars.Find(varholder))
					if(object.vv_edit_var(varholder, valueholder))
						log_admin("Build Mode: [key_name(user)] modified [object.name]'s [varholder] to [valueholder]")
					else
						to_chat(user, "<span class='warning'>Varedit rejected</span>")
				else
					to_chat(user, "<span class='warning'>[initial(object.name)] does not have a var called '[varholder]'</span>")
			if(right_click)
				if(object.vars.Find(varholder))
					if(object.vv_edit_var(varholder, initial(object.vars[varholder])))
						log_admin("Build Mode: [key_name(user)] modified [object.name]'s [varholder] to [valueholder]")
					else
						to_chat(user, "<span class='warning'>Varedit rejected</span>")
				else
					to_chat(user, "<span class='warning'>[initial(object.name)] does not have a var called '[varholder]'</span>")

		if(THROW_BUILDMODE)
			if(left_click)
				if(isturf(object))
					return
				throw_atom = object
			if(right_click)
				if(throw_atom)
					throw_atom.throw_at(object, 10, 1,user)
					log_admin("Build Mode: [key_name(user)] threw [throw_atom] at [object] in [AREACOORD(object)]")
		if(AREA_BUILDMODE)
			if(left_click) //rectangular
				if(!cornerA)
					cornerA = get_turf(object)
					preview += image('icons/turf/overlays.dmi',cornerA,"greenOverlay")
					usr.client.images -= preview
					usr.client.images += preview
					return
				if(cornerA && !cornerB)
					cornerB = get_turf(object)
					preview += image('icons/turf/overlays.dmi',cornerB,"blueOverlay")
					usr.client.images -= preview
					usr.client.images += preview
					to_chat(user, "<span class='boldwarning'>Region selected, if you're happy with your selection left click again, otherwise right click.</span>")
					return
				if(cornerA && cornerB)
					if(!generator_path)
						to_chat(user, "<span class='warning'>Select generator type first.</span>")
						return
					var/datum/mapGenerator/G = new generator_path
					if(istype(G, /datum/mapGenerator/repair/reload_station_map))
						if(GLOB.reloading_map)
							to_chat(user, "<span class='boldwarning'>You are already reloading an area! Please wait for it to fully finish loading before trying to load another!</span>")
							return
					G.defineRegion(cornerA, cornerB, 1)
					for(var/t in G.map)
						preview += image('icons/turf/overlays.dmi', t ,"redOverlay")
					usr.client.images -= preview
					usr.client.images += preview
					var/confirm = alert("Are you sure you want run the map generator?", "Run generator", "Yes", "No")
					if(confirm == "Yes")
						G.generate()
					cornerA = null
					cornerB = null
					usr.client.images -= preview
					preview.Cut()
					return
			//Something wrong - Reset
			cornerA = null
			cornerB = null
		if(COPY_BUILDMODE)
			if(left_click)
				var/turf/T = get_turf(object)
				if(stored)
					DuplicateObject(stored,perfectcopy=1,newloc=T)
			else if(right_click)
				if(ismovableatom(object)) // No copying turfs for now.
					stored = object
