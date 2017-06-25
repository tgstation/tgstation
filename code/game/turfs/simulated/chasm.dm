
//////////////CHASM//////////////////

/turf/open/chasm
	name = "chasm"
	desc = "Watch your step."
	baseturf = /turf/open/chasm
	smooth = SMOOTH_TRUE | SMOOTH_BORDER | SMOOTH_MORE
	icon = 'icons/turf/floors/Chasms.dmi'
	icon_state = "smooth"
	canSmoothWith = list(/turf/open/floor/fakepit, /turf/open/chasm)
	density = TRUE //This will prevent hostile mobs from pathing into chasms, while the canpass override will still let it function like an open turf
	var/drop_x = 1
	var/drop_y = 1
	var/drop_z = 1

/turf/open/chasm/Entered(atom/movable/AM)
	START_PROCESSING(SSobj, src)
	drop_stuff(AM)

/turf/open/chasm/process()
	if(!drop_stuff())
		STOP_PROCESSING(SSobj, src)

/turf/open/chasm/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "basalt"
	return TRUE

/turf/open/chasm/attackby(obj/item/C, mob/user, params, area/area_restriction)
	..()
	if(istype(C, /obj/item/stack/rods))
		var/obj/item/stack/rods/R = C
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(!L)
			if(R.use(1))
				to_chat(user, "<span class='notice'>You construct a lattice.</span>")
				playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
				ReplaceWithLattice()
			else
				to_chat(user, "<span class='warning'>You need one rod to build a lattice.</span>")
			return
	if(istype(C, /obj/item/stack/tile/plasteel))
		var/obj/structure/lattice/L = locate(/obj/structure/lattice, src)
		if(L)
			var/obj/item/stack/tile/plasteel/S = C
			if(S.use(1))
				qdel(L)
				playsound(src, 'sound/weapons/genhit.ogg', 50, 1)
				to_chat(user, "<span class='notice'>You build a floor.</span>")
				ChangeTurf(/turf/open/floor/plating)
			else
				to_chat(user, "<span class='warning'>You need one floor tile to build a floor!</span>")
		else
			to_chat(user, "<span class='warning'>The plating is going to need some support! Place metal rods first.</span>")

/turf/open/chasm/proc/drop_stuff(AM)
	. = 0
	var/thing_to_check = src
	if(AM)
		thing_to_check = list(AM)
	for(var/thing in thing_to_check)
		if(droppable(thing))
			. = 1
			INVOKE_ASYNC(src, .proc/drop, thing)

/turf/open/chasm/proc/droppable(atom/movable/AM)
	if(!isliving(AM) && !isobj(AM))
		return 0
	if(istype(AM, /obj/singularity) || istype(AM, /obj/item/projectile) || AM.throwing)
		return 0
	if(istype(AM, /obj/effect/portal))
		//Portals aren't affected by gravity. Probably.
		return 0
	//Flies right over the chasm
	if(isliving(AM))
		var/mob/MM = AM
		if(MM.movement_type & FLYING)
			return 0
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(istype(H.belt, /obj/item/device/wormhole_jaunter))
			var/obj/item/device/wormhole_jaunter/J = H.belt
			//To freak out any bystanders
			visible_message("<span class='boldwarning'>[H] falls into [src]!</span>")
			J.chasm_react(H)
			return 0
	return 1

/turf/open/chasm/proc/drop(atom/movable/AM)
	//Make sure the item is still there after our sleep
	if(!AM || QDELETED(AM))
		return

	var/turf/T = locate(drop_x, drop_y, drop_z)
	if(T)
		AM.visible_message("<span class='boldwarning'>[AM] falls into [src]!</span>", "<span class='userdanger'>GAH! Ah... where are you?</span>")
		T.visible_message("<span class='boldwarning'>[AM] falls from above!</span>")
		AM.forceMove(T)
		if(isliving(AM))
			var/mob/living/L = AM
			L.Knockdown(100)
			L.adjustBruteLoss(30)


/turf/open/chasm/straight_down/Initialize()
	..()
	drop_x = x
	drop_y = y
	if(z+1 <= world.maxz)
		drop_z = z+1


/turf/open/chasm/straight_down/lava_land_surface
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS
	planetary_atmos = TRUE
	baseturf = /turf/open/chasm/straight_down/lava_land_surface
	light_range = 1.9 //slightly less range than lava
	light_power = 0.65 //less bright, too
	light_color = LIGHT_COLOR_LAVA //let's just say you're falling into lava, that makes sense right

/turf/open/chasm/straight_down/lava_land_surface/drop(atom/movable/AM)
	//Make sure the item is still there after our sleep
	if(!AM || QDELETED(AM))
		return
	AM.visible_message("<span class='boldwarning'>[AM] falls into [src]!</span>", "<span class='userdanger'>You stumble and stare into an abyss before you. It stares back, and you fall \
	into the enveloping dark.</span>")
	if(isliving(AM))
		var/mob/living/L = AM
		L.notransform = TRUE
		L.Stun(200)
		L.resting = TRUE
	var/oldtransform = AM.transform
	var/oldcolor = AM.color
	var/oldalpha = AM.alpha
	animate(AM, transform = matrix() - matrix(), alpha = 0, color = rgb(0, 0, 0), time = 10)
	for(var/i in 1 to 5)
		//Make sure the item is still there after our sleep
		if(!AM || QDELETED(AM))
			return
		AM.pixel_y--
		sleep(2)

	//Make sure the item is still there after our sleep
	if(!AM || QDELETED(AM))
		return

	if(iscyborg(AM))
		var/mob/living/silicon/robot/S = AM
		qdel(S.mmi)

	qdel(AM)

	if(AM && !QDELETED(AM))	//It's indestructible
		visible_message("<span class='boldwarning'>[src] spits out the [AM]!</span>")
		AM.alpha = oldalpha
		AM.color = oldcolor
		AM.transform = oldtransform
		AM.throw_at(get_edge_target_turf(src,pick(GLOB.alldirs)),rand(1, 10),rand(1, 10))

/turf/open/chasm/straight_down/lava_land_surface/normal_air
	initial_gas_mix = "o2=22;n2=82;TEMP=293.15"



/turf/open/chasm/CanPass(atom/movable/mover, turf/target, height=0)
	return 1



//Jungle

/turf/open/chasm/jungle
	icon = 'icons/turf/floors/junglechasm.dmi'
	planetary_atmos = TRUE
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS

/turf/open/chasm/jungle/get_smooth_underlay_icon(mutable_appearance/underlay_appearance, turf/asking_turf, adjacency_dir)
	underlay_appearance.icon = 'icons/turf/floors.dmi'
	underlay_appearance.icon_state = "dirt"
	return TRUE

/turf/open/chasm/straight_down/jungle
	icon = 'icons/turf/floors/junglechasm.dmi'
	planetary_atmos = TRUE
	initial_gas_mix = LAVALAND_DEFAULT_ATMOS