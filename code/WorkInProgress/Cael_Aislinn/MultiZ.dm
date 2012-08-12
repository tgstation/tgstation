/obj/multiz
	icon = 'multiz.dmi'
	density = 0
	opacity = 0
	anchored = 1
	var/istop = 1

	CanPass(obj/mover, turf/source, height, airflow)
		return airflow || !density

/obj/multiz/proc/targetZ()
	return src.z + (istop ? 1 : -1)

/obj/multiz/ladder
	icon_state = "ladderdown"
	name = "ladder"
	desc = "A Ladder.  You climb up and down it."

/obj/multiz/ladder/New()
	..()
	if (!istop)
		icon_state = "ladderup"
	else
		icon_state = "ladderdown"

/obj/multiz/ladder/attack_paw(var/mob/M)
	return attack_hand(M)

/obj/multiz/ladder/attackby(var/W, var/mob/M)
	return attack_hand(M)

/obj/multiz/ladder/attack_hand(var/mob/M)
	M.Move(locate(src.x, src.y, targetZ()))


/obj/multiz/ladder/hatch
	icon_state = "hatchdown"
	name = "hatch"
	desc = "A Hatch. You climb down it, and it will automatically seal against pressure loss behind you."

/obj/multiz/ladder/hatch/New()
	..()
	if(istop == 1)
		icon_state = "hatchdown"

/obj/multiz/ladder/hatch/hatchbottom
	icon_state = "hatchdown"

/obj/multiz/ladder/hatch/hatchbottom/New()
	istop = 0
	..()

/obj/multiz/ladder/hatch/attack_hand(var/mob/M)
	var/obj/multiz/ladder/hatch/Htop
	var/obj/multiz/ladder/hatch/Hbottom
	if(!istop && src.z > 1)
		Htop = locate(/obj/multiz/ladder/hatch, locate(src.x, src.y, src.z-1))
		Hbottom = src
	else
		Hbottom = locate(/obj/multiz/ladder/hatch, locate(src.x, src.y, src.z + 1))
		Htop = src

	if(!Htop)
		//world << "Htop == null"
		return
	if(!Hbottom)
		//world << "Hbottom == null"
		return

	if(Htop.icon_state == "hatchdown")
		flick("hatchdown-open",Htop)
		Hbottom.overlays += "green-ladderlight"
		spawn(7)
			if(M.z == src.z && get_dist(src,M) <= 1)
				M.Move(locate(src.x, src.y, targetZ()))
			flick("hatchdown-close",Htop)
			Hbottom.overlays -= "green-ladderlight"
			Hbottom.overlays += "red-ladderlight"
			spawn(7)
				Htop.icon_state = "hatchdown"
				Hbottom.overlays -= "red-ladderlight"

/*
/obj/multiz/ladder/blob_act()
	var/newblob = 1
	for(var/obj/blob in locate(src.x, src.y, targetZ()))
		newblob = 0
	if(newblob)
		new /obj/blob(locate(src.x, src.y, targetZ()))
*/
//Stairs.  var/dir on all four component objects should be the dir you'd walk from top to bottom
//active = bump to move down
//active/bottom = bump to move up
//enter = decorative downwards stairs
//enter/bottom = decorative upward stairs
/obj/multiz/stairs
	name = "Stairs"
	desc = "Stairs.  You walk up and down them."
	icon_state = "ramptop"

/obj/multiz/stairs/New()
	icon_state = istop ^ istype(src, /obj/multiz/stairs/active) ? "ramptop" : "rampbottom"

/obj/multiz/stairs/enter/bottom
	istop = 0

/obj/multiz/stairs/active
	density = 1

/obj/multiz/stairs/active/Bumped(var/atom/movable/M)
	if(istype(src, /obj/multiz/stairs/active/bottom) && !locate(/obj/multiz/stairs/enter) in M.loc)
		return //If on bottom, only let them go up stairs if they've moved to the entry tile first.
	//If it's the top, they can fall down just fine.
	if(ismob(M) && M:client)
		M:client.moving = 1
	M.Move(locate(src.x, src.y, targetZ()))
	if (ismob(M) && M:client)
		M:client.moving = 0

/obj/multiz/stairs/active/Click()
	if(!istype(usr,/mob/dead/observer))
		return ..()
	usr.client.moving = 1
	usr.Move(locate(src.x, src.y, targetZ()))
	usr.client.moving = 0
/obj/multiz/stairs/active/bottom
	istop = 0
	opacity = 1

/turf/simulated/floor/open
	name = "open space"
	intact = 0
	icon_state = "black"
	pathweight = 100000 //Seriously, don't try and path over this one numbnuts
	var/icon/darkoverlays = null
	var/turf/floorbelow
	//floorstrength = 1
	mouse_opacity = 2

	New()
		..()
		spawn(1)
			if(!istype(src, /turf/simulated/floor/open)) //This should not be needed but is.
				return
			floorbelow = locate(x, y, z + 1)
			if(floorbelow)
				//Fortunately, I've done this before. - Aryn
				if(istype(floorbelow,/turf/space) || floorbelow.z > 4)
					new/turf/space(src)
				else if(!istype(floorbelow,/turf/simulated/floor))
					new/turf/simulated/floor/plating(src)
				else
					//if(ticker)
						//find_zone()
					update()
			else
				new/turf/space(src)

	Del()
		. = ..()

	Enter(var/atom/movable/AM)
		if (..()) //TODO make this check if gravity is active (future use) - Sukasa
			spawn(1)
				if(AM)
					AM.Move(locate(x, y, z + 1))
					if (istype(AM, /mob/living/carbon/human))
						var/mob/living/carbon/human/H = AM
						var/damage = rand(5,15)
						H.apply_damage(2*damage, BRUTE, "head")
						H.apply_damage(2*damage, BRUTE, "chest")
						H.apply_damage(0.5*damage, BRUTE, "l_leg")
						H.apply_damage(0.5*damage, BRUTE, "r_leg")
						H.apply_damage(0.5*damage, BRUTE, "l_arm")
						H.apply_damage(0.5*damage, BRUTE, "r_arm")

/*
/obj/effect/decal/cleanable/blood
	name = "Blood"
	desc = "It's red and disgusting."
	density = 0
	anchored = 1
	layer = 2
	icon = 'blood.dmi'
	icon_state = "floor1"
	random_icon_states = list("floor1", "floor2", "floor3", "floor4", "floor5", "floor6", "floor7")
	var/list/viruses = list()
	blood_DNA = list()
	var/datum/disease2/disease/virus2 = null
	var/OriginalMob = null

	Del()
		for(var/datum/disease/D in viruses)
			D.cure(0)
		..()
*/

	//					var/obj/effect/decal/cleanable/blood/B = new(src.loc)
	//					var/list/blood_DNA_temp[1]
	//					blood_DNA_temp[1] = list(H.dna.unique_enzymes, H.dna.b_type)
	//					B.blood_DNA =  blood_DNA_temp
	//					B.virus2 = H.virus2
	//					for(var/datum/disease/D in H.viruses)
	//						var/datum/disease/newDisease = new D.type
	//						B.viruses += newDisease
	//						newDisease.holder = B

						H:weakened = max(H:weakened,2)
						H:updatehealth()
		return ..()

	attackby()
		//nothing

	proc/update() //Update the overlayss to make the openspace turf show what's down a level
		if(!floorbelow) return
		/*src.clearoverlays()
		src.addoverlay(floorbelow)
		for(var/obj/o in floorbelow.contents)
			src.addoverlay(image(o, dir=o.dir, layer = TURF_LAYER+0.05*o.layer))
		var/image/I = image('ULIcons.dmi', "[min(max(floorbelow.LightLevelRed - 4, 0), 7)]-[min(max(floorbelow.LightLevelGreen - 4, 0), 7)]-[min(max(floorbelow.LightLevelBlue - 4, 0), 7)]")
		I.layer = TURF_LAYER + 0.2
		src.addoverlay(I)
		I = image('ULIcons.dmi', "1-1-1")
		I.layer = TURF_LAYER + 0.2
		src.addoverlay(I)*/

var/maxZ = 6
var/minZ = 2

// Maybe it's best to have this hardcoded for whatever we'd add to the map, in order to avoid exploits
// (such as mining base => admin station)
// Note that this assumes the ship's top is at z=1 and bottom at z=4
/obj/item/weapon/tank/jetpack/proc/move_z(cardinal, mob/user as mob)
	if (user.z > 1)
		user << "\red There is nothing of interest in that direction."
		return
	if(allow_thrust(0.01, user))
		switch(cardinal)
			if (UP) // Going up!
				if(user.z > maxZ) // If we aren't at the very top of the ship
					var/turf/T = locate(user.x, user.y, user.z - 1)
					// You can only jetpack up if there's space above, and you're sitting on either hull (on the exterior), or space
					//if(T && istype(T, /turf/space) && (istype(user.loc, /turf/space) || istype(user.loc, /turf/space/*/hull*/)))
					//check through turf contents to make sure there's nothing blocking the way
					if(T && istype(T, /turf/space))
						var/blocked = 0
						for(var/atom/A in T.contents)
							if(T.density)
								blocked = 1
								user << "\red You bump into [T.name]."
								break
						if(!blocked)
							user.Move(T)
					else
						user << "\red You bump into the ship's plating."
				else
					user << "\red The ship's gravity well keeps you in orbit!" // Assuming the ship starts on z level 1, you don't want to go past it

			if (DOWN) // Going down!
				if (user.z < 1) // If we aren't at the very bottom of the ship, or out in space
					var/turf/T = locate(user.x, user.y, user.z + 1)
					// You can only jetpack down if you're sitting on space and there's space down below, or hull
					if(T && (istype(T, /turf/space) || istype(T, /turf/space/*/hull*/)) && istype(user.loc, /turf/space))
						var/blocked = 0
						for(var/atom/A in T.contents)
							if(T.density)
								blocked = 1
								user << "\red You bump into [T.name]."
								break
						if(!blocked)
							user.Move(T)
					else
						user << "\red You bump into the ship's plating."
				else
					user << "\red The ship's gravity well keeps you in orbit!"

