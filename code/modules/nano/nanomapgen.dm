// This file is a modified version of https://raw2.github.com/Baystation12/OldCode-BS12/master/code/TakePicture.dm

#define NANOMAP_ICON_SIZE 4
#define NANOMAP_MAX_ICON_DIMENSION 1024

#define NANOMAP_TILES_PER_IMAGE (NANOMAP_MAX_ICON_DIMENSION / NANOMAP_ICON_SIZE)

#define NANOMAP_TERMINALERR 5
#define NANOMAP_INPROGRESS 2
#define NANOMAP_BADOUTPUT 2
#define NANOMAP_SUCCESS 1
#define NANOMAP_WATCHDOGSUCCESS 4
#define NANOMAP_WATCHDOGTERMINATE 3


//Call these procs to dump your world to a series of image files (!!)
//NOTE: Does not explicitly support non 32x32 icons or stuff with large pixel_* values, so don't blame me if it doesn't work perfectly

/mob/verb/nanomapgen_DumpImage()
	set category = "Server"
	set name = "Generate NanoUI Map"

	if(!src.client.holder)
		src << "Only administrators may use this command."
		return
	var/turf/T = get_turf(src)
	nanomapgen_DumpTile(1,1, T.z)

/mob/verb/nanomapgen_DumpImageAll()
	set category = "Server"
	set name = "Generate all NanoUI Maps"

	if(!src.client.holder)
		src << "Only administrators may use this command."
		return
	//var/turf/T = get_turf(src)
	nanomapgen_DumpTile(allz = 1)

/mob/proc/nanomapgen_DumpTile(var/startX = 1, var/startY = 1, var/currentZ = 1, var/endX = -1, var/endY = -1, var/allz = 0)

	if (endX < 0 || endX > world.maxx)
		endX = world.maxx

	if (endY < 0 || endY > world.maxy)
		endY = world.maxy

	if (startX > endX)
		world.log << "NanoMapGen: <B>ERROR: startX ([startX]) cannot be greater than endX ([endX])</B>"
		sleep(3)
		return NANOMAP_TERMINALERR

	if (startY > endX)
		world.log << "NanoMapGen: <B>ERROR: startY ([startY]) cannot be greater than endY ([endY])</B>"
		sleep(3)
		return NANOMAP_TERMINALERR

	var/icon/Tile = icon(file("nano/mapbase1024.png"))
	if (Tile.Width() != NANOMAP_MAX_ICON_DIMENSION || Tile.Height() != NANOMAP_MAX_ICON_DIMENSION)
		world.log << "NanoMapGen: <B>ERROR: BASE IMAGE DIMENSIONS ARE NOT [NANOMAP_MAX_ICON_DIMENSION]x[NANOMAP_MAX_ICON_DIMENSION]</B>"
		sleep(3)
		return NANOMAP_TERMINALERR

	world << "NanoMapGen: <B>GENERATE MAP ([startX],[startY],[currentZ]) to ([endX],[endY],[currentZ])</B>"

	var/count = 0;
	for(var/WorldX = startX, WorldX <= endX, WorldX++)
		for(var/WorldY = startY, WorldY <= endY, WorldY++)

			var/atom/Turf = locate(WorldX, WorldY, currentZ)

			var/icon/TurfIcon = new(Turf.icon, Turf.icon_state, Turf, 1, 0)
			TurfIcon.Scale(NANOMAP_ICON_SIZE, NANOMAP_ICON_SIZE)

			Tile.Blend(TurfIcon, ICON_OVERLAY, ((WorldX - 1) * NANOMAP_ICON_SIZE), ((WorldY - 1) * NANOMAP_ICON_SIZE))

			count++

			if (count % 1024 == 0)
				world.log << "NanoMapGen: [count] tiles done"
				sleep(5)

	world.log << "NanoMapGen: sending nanoMap.png to client"

	usr << browse(Tile, "window=picture;file=nanoMap[currentZ].png;display=0")

	world.log << "NanoMapGen: Done."

	if (Tile.Width() != NANOMAP_MAX_ICON_DIMENSION || Tile.Height() != NANOMAP_MAX_ICON_DIMENSION)
		return NANOMAP_BADOUTPUT
	if(allz)
		if(currentZ < world.maxz)
			var/newz = currentZ+1
			.(1,1,newz,-1,-1,1)
	return NANOMAP_SUCCESS