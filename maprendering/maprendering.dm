/client/proc/maprender()
	set category = "Mapping"
	set name = "Generate Map Render"

	if(!holder)
		to_chat(src, "Only administrators may use this command.")
		return
	if(alert("Sure you want to do this? It should NEVER be done in an active round and cannot be cancelled", "generate maps", "Yes", "No") == "No")
		return

	var/allz = alert("Do you wish to generate a specific zlevel or all zlevels?", "Generate what levels?", "All", "Specific", "Cancel")

	var/zlevel = 1
	if(allz == "Cancel")
		return
	else if(allz == "Specific")
		zlevel = input("Input zlevel you wish to render") as num

	message_admins("[ckey]/[src] started rendering maps")
	log_admin("[ckey]/[src] started rendering maps")

	maprenders(zlevel, allz == "All" ? 1 : 0)

/client/proc/maprenders(var/currentz = 1, var/allz = 0)

	to_chat(world, "Map Render: <B>GENERATE MAP FOR [allz? "ALL ZLEVELS" : "LEVEL [currentz]"]</B>")
	var/mapname = replacetext(map.nameLong, " ", "")

	var/startz = currentz
	var/endz = currentz
	if(allz)
		startz = 1
		endz = world.maxz

	var/const/icon_size = 64 //Depends on map render icon, in this case we're doing 2048x2048 pixels at 32x32 per tile

	for(var/z = startz to endz)
		for(var/x = 0 to world.maxx step icon_size)
			for(var/y = 0 to world.maxy step icon_size)
				var/list/pixel_shift_objects = list()
				var/icon/map_icon = new/icon('maprendering/maprender.png') //2048 pixels, thats 32 tiles of 32 pixels
				for(var/a = 1 to icon_size)
					for(var/b = 1 to icon_size)
						//Finding turf and all turf contents
						var/turf/currentturf = locate(x+a,y+b,z)
						if(!currentturf || (currentturf.flags & NO_MINIMAP))
							continue
						var/list/allturfcontents = currentturf.contents.Copy()

						//Remove the following line to allow lighting to be considered, if you do this it must be blended with BLEND_MULTIPLY instead of ICON_OVERLAY
						allturfcontents -= locate(/atom/movable/lighting_overlay) in allturfcontents

						for(var/atom/movable/A in allturfcontents)
							if(A.locs.len > 1) //Fix for multitile objects I wish I didn't have to do this its probably slow
								if(A.locs[1] != A.loc)
									allturfcontents -= A

						//Remove the following line if you want to add space to your renders, I think it is cheaper to merely use a pregenned image for this
						if(!istype(currentturf,/turf/space))
							allturfcontents += currentturf

						//Due to processing order, a pixelshifted object will be overriden in certain directions,
						//we'll apply it at the end, they're almost always at the top layer anyway
						for(var/atom/A in allturfcontents)
							if(A.pixel_x || A.pixel_y)
								allturfcontents -= A
								pixel_shift_objects += A

						if(!allturfcontents.len)
							continue

						//Initializing our layer sorting variables
						var/list/sorting = list()
						var/atom/currentAtom = allturfcontents[1]
						var/currentLayer
						sorting[allturfcontents[1]] = currentAtom.layer
						allturfcontents -= currentAtom
						var/currentIndex = 1
						var/compareIndex = 1

						if(allturfcontents.len)
							//Simple insertion sort, simple variant of the form in getflaticon
							while(currentIndex <= allturfcontents.len)
								currentAtom = allturfcontents[currentIndex]
								currentLayer = currentAtom.layer

								for(compareIndex=1,compareIndex<=sorting.len,compareIndex++)
									if(currentLayer < sorting[sorting[compareIndex]])
										sorting.Insert(compareIndex,currentAtom)
										sorting[currentAtom] = currentLayer
										break
								if(compareIndex>sorting.len)
									sorting[currentAtom]=currentLayer

								currentIndex++

						//Preparing to blend get flat icon of
						for(var/atom/A in sorting)
							var/icon/icontoblend = getFlatIcon(A = A, dir = A.dir, cache = 0)
							map_icon.Blend(icontoblend, ICON_OVERLAY, ((a-1)*world.icon_size)+1, ((b-1)*world.icon_size)+1)
						sleep(-1)

				for(var/atom/A in pixel_shift_objects)
					var/icon/icontoblend = getFlatIcon(A = A, dir = A.dir, cache = 0)
					//This part is tricky since we've skipped a and b, since these are map objects they have valid x,y. a and b should be the modulo'd value of x,y with icon_size
					map_icon.Blend(icontoblend, ICON_OVERLAY, (((A.x % icon_size)-1)*world.icon_size)+1+A.pixel_x, (((A.y % icon_size)-1)*world.icon_size)+1+A.pixel_y)

				if(y >= world.maxy)
					map_icon.DrawBox(rgb(255,255,255,255), x1 = 1, y1 = 1, x2 = 32*icon_size, y2 = 32*(icon_size-world.maxy % icon_size))
				if(x >= world.maxx)
					map_icon.DrawBox(rgb(255,255,255,255), x1 = 32*(icon_size - world.maxx % icon_size), y1 = 1, x2 = 32*icon_size, y2 = 32*icon_size)

				world.log << "Completed image z: [z], x: [x] to [x/icon_size], y: [round((world.maxy-y)/icon_size)]"
				var/resultpath = "maprendering/renderoutput/[mapname]/[z]/maprender[round((world.maxy-y)/icon_size)]-[x/icon_size].png"
				// BYOND BUG: map_icon now contains 4 directions? Create a new icon with only a single state.
				var/icon/result_icon = new/icon()

				result_icon.Insert(map_icon, "", SOUTH, 1, 0)
				if(fexists(resultpath))
					fdel(resultpath)
				fcopy(result_icon, resultpath)
