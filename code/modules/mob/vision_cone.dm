/mob
	var/obj/screen/fov = null//The screen object because I can't figure out how the hell TG does their screen objects so I'm just using legacy code.

client/
	var/list/hidden_atoms = list()
	var/list/hidden_mobs = list()
	var/list/hidden_images = list()



//Procs
/atom/proc/InCone(atom/center = usr, dir = NORTH)
	if(get_dist(center, src) == 0 || src == center) return 0
	var/d = get_dir(center, src)
	if(!d || d == dir) return 1
	if(dir & (dir-1))
		return (d & ~dir) ? 0 : 1
	if(!(d & dir)) return 0
	var/dx = abs(x - center.x)
	var/dy = abs(y - center.y)
	if(dx == dy) return 1
	if(dy > dx)
		return (dir & (NORTH|SOUTH)) ? 1 : 0
	return (dir & (EAST|WEST)) ? 1 : 0

/mob/dead/InCone(mob/center = usr, dir = NORTH)//So ghosts aren't calculated.
	return

/proc/cone(atom/center = usr, dir = NORTH, list/list = oview(center))
	for(var/atom/A in list)
		if(!A.InCone(center, dir))
			list -= A
	return list

/mob/proc/update_vision_cone()
	return

/mob/living/update_vision_cone()
	if(src.client)
		var/image/I = null
		for(I in src.client.hidden_atoms)
			I.override = 0
			client.images -= I
			qdel(I)
		for(var/hidden_hud in client.hidden_images)
			client.images += hidden_hud
			client.hidden_images -= hidden_hud
		rest_cone_act()
		src.client.hidden_atoms = list()
		src.client.hidden_mobs = list()
		client.hidden_images = list()
		src.fov.dir = src.dir
		if(fov.alpha != 0)
			var/mob/living/M
			for(M in cone(src, OPPOSITE_DIR(src.dir), view(10, src)))
				I = image("split", M)
				I.override = 1
				src.client.images += I
				src.client.hidden_atoms += I
				src.client.hidden_mobs += M
				if(src.pulling == M)//If we're pulling them we don't want them to be invisible, too hard to play like that.
					I.override = 0
		for(var/image/HUD in client.images)
			if(HUD.icon != 'icons/mob/hud.dmi')
				continue
			for(var/mob/living/M in client.hidden_mobs)
				if(HUD.loc == M)
					client.hidden_images += HUD
					client.images -= HUD
					break
	else
		return

/mob/proc/rest_cone_act()//For showing and hiding the cone when you rest or lie down.
	if(resting || lying)
		hide_cone()
	else
		show_cone()

//Making these generic procs so you can call them anywhere.
/mob/proc/show_cone()
	if(src.fov)
		src.fov.alpha = 255

/mob/proc/hide_cone()
	if(src.fov)
		src.fov.alpha = 0




