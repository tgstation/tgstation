/obj/structure/cult
	density = 1
	anchored = 1
	icon = 'icons/obj/cult.dmi'

/obj/structure/cult/talisman
	name = "altar"
	desc = "A bloodstained altar dedicated to Nar-Sie"
	icon_state = "talismanaltar"


/obj/structure/cult/forge
	name = "daemon forge"
	desc = "A forge used in crafting the unholy weapons used by the armies of Nar-Sie"
	icon_state = "forge"

/obj/structure/cult/pylon
	name = "pylon"
	desc = "A floating crystal that hums with an unearthly energy"
	icon_state = "pylon"
	luminosity = 5

/obj/structure/cult/tome
	name = "desk"
	desc = "A desk covered in arcane manuscripts and tomes in unknown languages. Looking at the text makes your skin crawl"
	icon_state = "tomealtar"
//	luminosity = 5

//sprites for this no longer exist	-Pete
//(they were stolen from another game anyway)
/*
/obj/structure/cult/pillar
	name = "Pillar"
	desc = "This should not exist"
	icon_state = "pillar"
	icon = 'magic_pillar.dmi'
*/

/obj/effect/gateway
	name = "gateway"
	desc = "You're pretty sure that abyss is staring back"
	icon = 'icons/obj/cult.dmi'
	icon_state = "hole"
	density = 1
	unacidable = 1
	anchored = 1.0

/obj/effect/gateway/Bumped(mob/M as mob|obj)
	spawn(0)
		return
	return

/obj/effect/gateway/Crossed(AM as mob|obj)
	spawn(0)
		return
	return

/obj/effect/walltalisman
	name = "rune"
	desc = "A sickly rune, drawn in blood"
	icon = 'icons/obj/cult.dmi'
	icon_state = "uglystatic"
	flags = ON_BORDER
	anchored = 1
	density = 1
	unacidable = 1
	var/imbue = null

/obj/effect/walltalisman/Bumped(mob/M as mob)
	if(!iscultist(M))										//As it stands, these only affect non-cultists. If you wish to, feel free
		//var/delete = 1										//To add some that do affect cultists!
		switch(imbue)
			if("emp")										//The name of the effect.
				call(/obj/effect/rune/proc/emp)(M.loc,3)	//Calls the rune proc.
				qdel(src)									//Removes the wall talisman.
			if("ire", "ego", "nahlizet", "certum", "veri", "jatkaa", "balaq", "mgar", "karazet", "geeri")
				call(/obj/effect/rune/proc/teleport)(imbue)
				qdel(src)
			if("deafen")
				call(/obj/effect/rune/proc/deafen)()
				qdel(src)
			if("blind")
				call(/obj/effect/rune/proc/blind)()
				qdel(src)
			if("runestun")
				call(/obj/effect/rune/proc/runestun)(M)
				qdel(src)
//			user.take_organ_damage(5, 0)
		//if(src && src.imbue!="supply" && src.imbue!="runestun")
			//if(delete)
				//qdel(src)
		return
	else
		return


/obj/effect/walltalisman/CanPass(atom/movable/mover, turf/target, height=0)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/effect/walltalisman/CheckExit(atom/movable/mover as mob|obj, turf/target as turf)
	if(istype(mover) && mover.checkpass(PASSGLASS))
		return 1
	if(get_dir(loc, target) == dir)
		return !density
	else
		return 1

/obj/effect/walltalisman/CanAtmosPass(var/turf/T)
	if(get_dir(loc, T) == dir)
		return !density
	else
		return 1


/obj/effect/walltalisman/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/weapon/tome) && iscultist(user))   //Non-cultists are illiterate.
		user << "<span class='notice'>You disperse the energies of the wall talisman.</span>"
		qdel(src)
		return
	else if(istype(I, /obj/item/weapon/nullrod))              //So anyone can do it.
		user << "<span class='notice'>You disrupt the vile magic with the deadening field of the null rod!</span>"
		qdel(src)
		return
	return

