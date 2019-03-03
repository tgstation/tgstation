GLOBAL_LIST_EMPTY(savedstationfloors)
GLOBAL_LIST_EMPTY(savedstationwalls)
GLOBAL_LIST_EMPTY(savedstationwindows)
GLOBAL_LIST_EMPTY(savedstationairlocks)
GLOBAL_LIST_EMPTY(savedstationwires)
GLOBAL_LIST_EMPTY(savedstationapcs)
proc
	SaveStation()
		set background = 1
		if(GLOB.savedstationfloors.len || GLOB.savedstationwalls.len || GLOB.savedstationwindows.len || GLOB.savedstationairlocks.len || GLOB.savedstationwires.len || GLOB.savedstationapcs.len)
			return
		var/stationz = 2
		for(var/turf/open/floor/F in world)
			if(F.z != stationz || istype(get_area(F),/area/shuttle))
				continue
			if(F.density)
				continue
			var/entrytext = "type=[F.type];dir=[F.dir];icon_state=[F.icon_state]"
			var/platingtext = "is_plating=0"
			if(istype(F,/turf/open/floor/plating))
				platingtext = "is_plating=1"
			entrytext += ";icon_regular_floor=[F.icon_regular_floor];[platingtext]"
			if(F.floor_tile)
				var/atom/A = F.floor_tile
				if(istype(A))
					entrytext += ";floor_tile=[A.type]"
			if(F.initial_gas_mix)
				var/newtext = F.initial_gas_mix
				while(findtext(newtext,";",1,length(newtext)+1))
					newtext = replacetext(newtext,";","SEMICOLIN",1,length(newtext)+1)
				if(newtext)
					entrytext += ";initial_gas_mix=[newtext]"
			GLOB.savedstationfloors["[F.x] [F.y]"] = entrytext
			var/list/windows = list()
			for(var/obj/structure/window/W in F)
				windows += W
			if(windows.len)
				var/hasgrille = 0
				for(var/obj/structure/grille/G in F)
					hasgrille = 1
					break
				for(var/obj/structure/window/W in windows)
					GLOB.savedstationwindows += "x=[W.x];y=[W.y];dir=[W.dir];hasgrille=[hasgrille];type=[W.type]"
		for(var/turf/closed/wall/W in world)
			if(W.z != stationz || istype(get_area(W),/area/shuttle))
				continue
			GLOB.savedstationwalls["[W.x] [W.y]"] = "type=[W.type]"
		for(var/obj/machinery/door/A in world)
			if(A.z != stationz || istype(get_area(A),/area/shuttle))
				continue
			var/theentry = "x=[A.x];y=[A.y];dir=[A.dir];name=[A.name];type=[A.type]"
			if(hasvar(A, "id"))
				if(isnum(A.vars["id"]))
					theentry += ";id=ISNUM[A.vars["id"]]"
				else
					theentry += ";id=[A.vars["id"]]"
			if(A.req_access_txt)
				var/newtext = A.req_access_txt
				while(findtext(newtext,";",1,length(newtext)+1))
					newtext = replacetext(newtext,";","SEMICOLIN",1,length(newtext)+1)
				if(newtext)
					theentry += ";req_access_txt=[newtext]"
			if(A.req_one_access_txt)
				var/newtext = A.req_one_access_txt
				while(findtext(newtext,";",1,length(newtext)+1))
					newtext = replacetext(newtext,";","SEMICOLIN",1,length(newtext)+1)
				if(newtext)
					theentry += ";req_one_access_txt=[newtext]"
			if(istype(A.req_access,/list))
				theentry += ";req_access=[tdmlist2text(A.req_access, " ")]"
			if(istype(A.req_one_access,/list))
				theentry += ";req_one_access=[tdmlist2text(A.req_one_access, " ")]"
			GLOB.savedstationairlocks += theentry
		for(var/obj/structure/cable/C in world)
			if(C.z != stationz || istype(get_area(C),/area/shuttle))
				continue
			GLOB.savedstationwires += "x=[C.x];y=[C.y];d1=[C.d1];d2=[C.d2]"
		for(var/obj/machinery/power/apc/apc in world)
			if(apc.z != stationz)
				continue
			var/area/A = get_area(apc)
			if(!A)
				continue
			GLOB.savedstationapcs += "x=[apc.x];y=[apc.y];z=[apc.z];name=[apc.name];dir=[apc.dir];tdir=[apc.tdir];cell_type=[apc.cell_type];APCAREA=[A.type]"

/proc/tdmtext2list(text, delimiter="\n") //shit, toolbox didnt have this proc, i dont know what the new version is. just using the one from tdm.
	var/delim_len = length(delimiter)
	if(delim_len < 1) return list(text)
	. = list()
	var/last_found = 1
	var/found
	do
		found = findtext(text, delimiter, last_found, 0)
		. += copytext(text, last_found, found)
		last_found = found + delim_len
	while(found)

/proc/tdmlist2text(list/ls, sep)
	if(ls.len <= 1) // Early-out code for empty or singleton lists.
		return ls.len ? ls[1] : ""

	var/l = ls.len // Made local for sanic speed.
	var/i = 0 // Incremented every time a list index is accessed.

	if(sep != null)
		// Macros expand to long argument lists like so: sep, ls[++i], sep, ls[++i], sep, ls[++i], etc...
		#define S1    sep, ls[++i]
		#define S4    S1,  S1,  S1,  S1
		#define S16   S4,  S4,  S4,  S4
		#define S64   S16, S16, S16, S16

		. = "[ls[++i]]" // Make sure the initial element is converted to text.

		// Having the small concatenations come before the large ones boosted speed by an average of at least 5%.
		if(l-1 & 0x01) // 'i' will always be 1 here.
			. = text("[][][]", ., S1) // Append 1 element if the remaining elements are not a multiple of 2.
		if(l-i & 0x02)
			. = text("[][][][][]", ., S1, S1) // Append 2 elements if the remaining elements are not a multiple of 4.
		if(l-i & 0x04)
			. = text("[][][][][][][][][]", ., S4) // And so on....
		if(l-i & 0x08)
			. = text("[][][][][][][][][][][][][][][][][]", ., S4, S4)
		if(l-i & 0x10)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S16)
		if(l-i & 0x20)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S16, S16)
		if(l-i & 0x40)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64)
		while(l > i) // Chomp through the rest of the list, 128 elements at a time.
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64, S64)

		#undef S64
		#undef S16
		#undef S4
		#undef S1

	else
		// Macros expand to long argument lists like so: ls[++i], ls[++i], ls[++i], etc...
		#define S1    ls[++i]
		#define S4    S1,  S1,  S1,  S1
		#define S16   S4,  S4,  S4,  S4
		#define S64   S16, S16, S16, S16

		. = "[ls[++i]]" // Make sure the initial element is converted to text.

		if(l-1 & 0x01) // 'i' will always be 1 here.
			. += S1 // Append 1 element if the remaining elements are not a multiple of 2.
		if(l-i & 0x02)
			. = text("[][][]", ., S1, S1) // Append 2 elements if the remaining elements are not a multiple of 4.
		if(l-i & 0x04)
			. = text("[][][][][]", ., S4) // And so on...
		if(l-i & 0x08)
			. = text("[][][][][][][][][]", ., S4, S4)
		if(l-i & 0x10)
			. = text("[][][][][][][][][][][][][][][][][]", ., S16)
		if(l-i & 0x20)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S16, S16)
		if(l-i & 0x40)
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64)
		while(l > i) // Chomp through the rest of the list, 128 elements at a time.
			. = text("[][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]\
	            [][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][][]", ., S64, S64)

		#undef S64
		#undef S16
		#undef S4
		#undef S1

proc
	FixStation(list/aoelist = list())
		set background = 1
		var/stationz = 2
		for(var/text in GLOB.savedstationfloors)
			var/spacepos = findtext(text," ",1,length(text)+1)
			var/turf/T = locate(text2num(copytext(text,1,spacepos)), text2num(copytext(text,spacepos+1,length(text)+1)),stationz)
			if(!istype(T,/turf))
				continue
			if(aoelist.len && !(T in aoelist))
				continue
			var/do_icon_update = 0
			var/list/paramslist = params2list(GLOB.savedstationfloors[text])
			if(istype(paramslist) && paramslist.len)
				var/thetype = text2path(paramslist["type"])
				if(ispath(thetype) && T.type != thetype)
					T.ChangeTurf(thetype)
					do_icon_update = 1
				T.dir = text2num(paramslist["dir"])
				if(istype(T,/turf/open/floor))
					var/turf/open/floor/F = T
					if(F.burnt)
						F.burnt = 0
						do_icon_update = 1
					if(F.broken)
						F.broken = 0
						do_icon_update = 1
					F.icon_regular_floor = paramslist["icon_regular_floor"]
					if(istype(F.floor_tile,/obj/item/stack/tile/grass) || F == /obj/item/stack/tile/grass)
						for(var/direction in list(NORTH,SOUTH,EAST,WEST))
							var/turf/open/floor/FF = get_step(F,direction)
							if(istype(FF,/turf/open/floor))
								FF.update_icon()
					else if(istype(T,/obj/item/stack/tile/carpet) || F == /obj/item/stack/tile/carpet)
						for(var/direction in list(NORTH,SOUTH,EAST,WEST,NORTHEAST,NORTHWEST,SOUTHEAST,SOUTHWEST))
							var/turf/open/floor/FF = get_step(F,direction)
							if(istype(FF,/turf/open/floor))
								FF.update_icon()
					F.levelupdate()
					do_icon_update = 1
					for(var/obj/item/stack/tile/tile in F)
						if(tile.amount <= 2)
							qdel(tile)
					if(do_icon_update)
						F.update_icon()
					var/theinitialgas = paramslist["initial_gas_mix"]
					while(findtext(theinitialgas,"SEMICOLIN",1,length(theinitialgas)+1))
						theinitialgas = replacetext(theinitialgas,"SEMICOLIN",";",1,length(theinitialgas)+1)
					if(F.initial_gas_mix != theinitialgas)
						F.initial_gas_mix = theinitialgas
					if(F.air)
						var/list/gasparams = params2list(F.initial_gas_mix)
						if(istype(gasparams,/list) && gasparams.len && F.air.gases && F.air.gases.len)
							var/updateair = 0
							if(gasparams["TEMP"])
								var/tempmin = max(text2num(gasparams["TEMP"])-10,0)
								var/tempmax = text2num(gasparams["TEMP"])+10
								if(F.air.temperature && (F.air.temperature <= tempmin || F.air.temperature >= tempmax))
									updateair = 1
							for(var/thing in F.air.gases)
								if(thing in gasparams)
									var/themin = max(text2num(gasparams[thing])-5,0)
									var/themax = text2num(gasparams[thing])+5
									if(F.air.gases[thing] && F.air.gases[thing][MOLES])
										var/currentmoles = F.air.gases[thing][MOLES]
										if((currentmoles <= themin || currentmoles >= themax))
											updateair = 1
											break
								else
									updateair = 1
									break
							if(!updateair)
								for(var/thing in gasparams)
									if(!(thing in F.air.gases))
										updateair = 1
										break
							if(updateair)
								F.air.parse_gas_string(F.initial_gas_mix)
		for(var/text in GLOB.savedstationwalls)
			var/spacepos = findtext(text," ",1,length(text)+1)
			var/turf/T = locate(text2num(copytext(text,1,spacepos)), text2num(copytext(text,spacepos+1,length(text)+1)),stationz)
			if(!istype(T) || T.density)
				continue
			if(aoelist.len && !(T in aoelist))
				continue
			var/list/paramslist = params2list(GLOB.savedstationwalls[text])
			if(istype(paramslist) && paramslist.len)
				var/thetype = text2path(paramslist["type"])
				if(ispath(thetype) && T.type != thetype)
					var/hasdoor = 0
					for(var/obj/S in T)
						if(istype(S,/obj/machinery/door/airlock))
							hasdoor = 1
							break
					if(hasdoor)
						continue
					for(var/obj/S in T)
						if(istype(S, /obj/structure/girder)||istype(S, /obj/structure/grille))
							qdel(S)
					T.ChangeTurf(thetype)
		for(var/F in GLOB.savedstationwindows)
			var/list/paramslist = params2list(F)
			if(!istype(paramslist)||!paramslist.len)
				continue
			var/numx = text2num(paramslist["x"])
			var/numy = text2num(paramslist["y"])
			var/numdir = text2num(paramslist["dir"])
			var/numgrille = text2num(paramslist["hasgrille"])
			var/thetype = text2path(paramslist["type"])
			var/turf/T = locate(numx,numy,stationz)
			if(!istype(T))
				continue
			if(aoelist.len && !(T in aoelist))
				continue
			var/foundwindow = 0
			var/foundgrille = 0
			for(var/obj/structure/window/R in T)
				if(R.dir == numdir)
					foundwindow = 1
			for(var/obj/structure/grille/G in T)
				if(istype(G,/obj/structure/grille/broken))
					qdel(G)
				else
					foundgrille = 1
			if(foundwindow == 0)
				var/obj/structure/window/reinforced/R = new thetype(T)
				R.dir = numdir
			if(foundgrille == 0 && numgrille == 1)
				new /obj/structure/grille(T)
		for(var/A in GLOB.savedstationairlocks)
			var/list/paramslist = params2list(A)
			if(!istype(paramslist)||!paramslist.len)
				continue
			var/thex = text2num(paramslist["x"])
			var/they = text2num(paramslist["y"])
			var/turf/T = locate(thex,they,stationz)
			if(!T || T.density)
				continue
			if(aoelist.len && !(T in aoelist))
				continue
			if(istype(T,/turf/open/floor))
				var/thetype = text2path(paramslist["type"])
				if(!ispath(thetype))
					continue
				var/thedir = text2num(paramslist["dir"])
				var/thename = paramslist["name"]
				var/theid = paramslist["id"]
				if(theid)
					if(findtext(theid,"ISNUM",1,length(theid)+1))
						theid = text2num(replacetext(theid,"ISNUM","",1,length(theid)+1))

				var/list/theaccess = tdmtext2list(paramslist["req_access"]," ")
				var/list/theoneaccess = tdmtext2list(paramslist["req_one_access"]," ")
				var/txtaccess = paramslist["req_access_txt"]
				var/txtoneaccess = paramslist["req_one_access_txt"]
				while(findtext(txtaccess,"SEMICOLIN",1,length(txtaccess)+1))
					txtaccess = replacetext(txtaccess,"SEMICOLIN",";",1,length(txtaccess)+1)
				while(findtext(txtoneaccess,"SEMICOLIN",1,length(txtoneaccess)+1))
					txtoneaccess = replacetext(txtoneaccess,"SEMICOLIN",";",1,length(txtoneaccess)+1)
				var/hasairlock = 0
				for(var/obj/machinery/door/D in T)
					if(D.type == thetype && D.dir == thedir)
						hasairlock = 1
						break
				if(!hasairlock)
					var/obj/machinery/door/D = new thetype(T)
					D.name = thename
					if("id" in D.vars)
						D.vars["id"] = theid
					D.req_access_txt = txtaccess
					D.req_one_access_txt = txtoneaccess
					if(istype(theaccess) && theaccess.len)
						var/exists = 0
						for(var/E in theaccess)
							if(E)
								exists = 1
								break
						if(exists)
							D.req_access = theaccess
						else
							D.req_access = null
					if(istype(theoneaccess) && theoneaccess.len)
						var/exists = 0
						for(var/E in theoneaccess)
							if(E)
								exists = 1
								break
						if(exists)
							D.req_one_access = theoneaccess
						else
							D.req_one_access = null
					if(istype(D,/obj/machinery/door/window))
						var/obj/machinery/door/window/W = D
						W.dir = thedir
						W.icon_state = "[W.icon_state]open"
						W.density = 0
						spawn(0)
							W.close()
		FixWiring(aoelist)

proc/FixWiring(list/aoelist = list())
	var/stationz = 2
	var/dogridupdate = 0
	//var/fixedthestation = 0
	for(var/W in GLOB.savedstationwires)
		var/list/paramslist = params2list(W)
		if(!istype(paramslist,/list) || !paramslist.len)
			continue
		var/turf/T = locate(text2num(paramslist["x"]),text2num(paramslist["y"]),stationz)
		if(!istype(T) || istype(T, /turf/open/space))
			continue
		if(aoelist.len && !(T in aoelist))
			continue
		var/numd1 = text2num(paramslist["d1"])
		var/numd2 = text2num(paramslist["d2"])
		var/buildwire = 1
		for(var/obj/structure/cable/check in T)
			if(check.d1 == numd1 && check.d2 == numd2)
				buildwire = 0
		if(buildwire)
			var/obj/structure/cable/C = new(T)
			dogridupdate = 1
			GLOB.cable_list -= src
			C.d1 = numd1
			C.d2 = numd2
			C.update_icon()
			GLOB.cable_list += src
		for(var/obj/item/stack/cable_coil/C in T)
			if(!C.fingerprintslast && C.amount <= 5)
				qdel(C)
	for(var/apctext in GLOB.savedstationapcs)
		var/list/paramslist = params2list(apctext)
		if(!istype(paramslist) || !paramslist.len)
			continue
		var/areatype = text2path(paramslist["APCAREA"])
		var/obj/machinery/power/apc/apc
		if(ispath(areatype))
			var/list/apcsareascheck = list()
			var/area/check = locate(areatype)
			if(istype(check))
				apcsareascheck += check
				for(var/area/A in check.related)
					if(!(A in apcsareascheck))
						apcsareascheck += A
				for(var/area/A in apcsareascheck)
					for(var/obj/machinery/power/apc/thing in A)
						apc = thing
						break
					if(apc)
						break
		var/turf/T = locate(text2num(paramslist["x"]),text2num(paramslist["y"]),text2num(paramslist["z"]))
		if(aoelist.len && !(T in aoelist))
			continue
		if(!apc && T && istype(T.loc,areatype))
			apc = new(T)
			dogridupdate = 1
			apc.area = get_area(apc)
			apc.name = paramslist["name"]
			apc.dir = text2num(paramslist["dir"])
			apc.tdir = text2num(paramslist["tdir"])
			for(var/obj/machinery/power/terminal/terminal in T)
				if(!terminal.master && terminal.dir == apc.tdir)
					qdel(terminal)
			apc.cell_type = text2num(paramslist["cell_type"])
			apc.pixel_x = (apc.tdir & 3)? 0 : (apc.tdir == 4 ? 24 : -24)
			apc.pixel_y = (apc.tdir & 3)? (apc.tdir ==1 ? 24 : -24) : 0
			if(apc.cell)
				apc.cell.maxcharge = apc.cell_type
				apc.cell.charge = apc.cell_type
		if(istype(apc))
			if(!apc.cell)
				var/obj/item/stock_parts/cell/newcell = new(apc)
				if(apc.cell_type)
					newcell.maxcharge = apc.cell_type
					var/divided = round(apc.cell_type/2, 1)
					newcell.charge = divided
				apc.cell = newcell
			if(!apc.terminal)
				apc.make_terminal()
			if(!apc.terminal.powernet||!(apc.terminal in apc.terminal.powernet.nodes))
				apc.connect_to_network()
			if(apc.wires)
				apc.wires.cut_wires.Cut()
			apc.stat = 0
			apc.has_electronics = 2
			apc.operating = 1
			apc.opened = 0
			apc.panel_open = 0
			apc.obj_flags &= ~EMAGGED
			apc.locked = 1
			apc.equipment = apc.setsubsystem(3)
			apc.lighting = apc.setsubsystem(3)
			apc.environ = apc.setsubsystem(3)
			apc.update_icon()
			apc.update()
	if(dogridupdate)
		SSmachines.makepowernets()

/proc/AOEFixStation(range = world.view,atom/center)
	if(!istype(center,/atom/movable) && !istype(center,/turf))
		return
	center = get_turf(center)
	if(!isturf(center))
		return
	var/list/aoelist = list()
	for(var/turf/T in range(range,center))
		aoelist += T
	FixStation(aoelist)

/proc/AOERestoreAir(range = world.view,atom/center)
	if(!istype(center,/atom/movable) && !istype(center,/turf))
		return
	center = get_turf(center)
	if(!isturf(center))
		return
	var/list/aoelist = list()
	for(var/turf/T in range(range,center))
		aoelist += T
	var/stationz = 2
	for(var/text in GLOB.savedstationfloors)
		var/spacepos = findtext(text," ",1,length(text)+1)
		var/turf/T = locate(text2num(copytext(text,1,spacepos)), text2num(copytext(text,spacepos+1,length(text)+1)),stationz)
		if(!istype(T,/turf) || !(T in aoelist))
			continue
		var/list/paramslist = params2list(GLOB.savedstationfloors[text])
		if(istype(paramslist) && paramslist.len && istype(T,/turf/open/floor))
			var/turf/open/floor/F = T
			var/theinitialgas = paramslist["initial_gas_mix"]
			while(findtext(theinitialgas,"SEMICOLIN",1,length(theinitialgas)+1))
				theinitialgas = replacetext(theinitialgas,"SEMICOLIN",";",1,length(theinitialgas)+1)
			if(F.initial_gas_mix != theinitialgas)
				F.initial_gas_mix = theinitialgas
			if(F.air)
				var/list/gasparams = params2list(F.initial_gas_mix)
				if(istype(gasparams,/list) && gasparams.len && F.air.gases && F.air.gases.len)
					var/updateair = 0
					if(gasparams["TEMP"])
						var/tempmin = max(text2num(gasparams["TEMP"])-10,0)
						var/tempmax = text2num(gasparams["TEMP"])+10
						if(F.air.temperature && (F.air.temperature <= tempmin || F.air.temperature >= tempmax))
							updateair = 1
					for(var/thing in F.air.gases)
						if(thing in gasparams)
							var/themin = max(text2num(gasparams[thing])-5,0)
							var/themax = text2num(gasparams[thing])+5
							if(F.air.gases[thing] && F.air.gases[thing][MOLES])
								var/currentmoles = F.air.gases[thing][MOLES]
								if((currentmoles <= themin || currentmoles >= themax))
									updateair = 1
									break
						else
							updateair = 1
							break
					if(!updateair)
						for(var/thing in gasparams)
							if(!(thing in F.air.gases))
								updateair = 1
								break
					if(updateair)
						F.air.parse_gas_string(F.initial_gas_mix)

/datum/admins/proc/AdminFixStation()
	set name = "Repair Station"
	set category = "Special Verbs"
	if(!(usr.client && usr.client.holder && usr.client.holder.rank.rights & R_ADMIN))
		return
	var/list/repairtypes = list("AOE repair","AOE restore air","Full Station Repair")
	var/repairtype = input(usr,"What type of repair do you wish to perform?","Repair Station","AOE repair") as null|anything in repairtypes
	if(!(repairtype in repairtypes))
		return
	switch(repairtype)
		if("AOE repair")
			var/aoerange = input(usr,"This will repair all station turfs around you. Please enter a radius that should be repaired.","Repair Station",7) as num
			var/turf/T = get_turf(usr)
			if(T.z != 2)
				to_chat(usr,"\red You must be on the station z-level.")
				return
			AOEFixStation(aoerange,usr)
			var/text = "[usr] performed an aoe repair."
			if(istype(T))
				text = "[usr] performed an aoe repair at \"[get_area(T)]\" [T.x] [T.y] [T.z]."
			message_admins("[text]")
		if("AOE restore air")
			var/aoerange = input(usr,"This will restore the air of the surrounding area to what it was at the start of the round. Please enter a radius that should be restored.","Repair Station",7) as num
			var/turf/T = get_turf(usr)
			if(T.z != 2)
				to_chat(usr,"\red You must be on the station z-level.")
				return
			AOERestoreAir(aoerange,usr)
			var/text = "[usr] performed an aoe restore air."
			if(istype(T))
				text = "[usr] performed an aoe restore air at \"[get_area(T)]\" [T.x] [T.y] [T.z]."
			message_admins("[text]")
		if("Full Station Repair")
			var/warning = alert(usr,"This will repair the entire station and could vastely impact the current round. Do you wish to continue?","Repair Station","Yes","Cancel")
			if(warning != "Yes")
				return
			FixStation()
			message_admins("[usr] has performed a full station repair.")
	return