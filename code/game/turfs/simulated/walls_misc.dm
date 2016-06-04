/turf/closed/wall/mineral/cult
	name = "runed metal wall"
	desc = "A cold metal wall engraved with indecipherable symbols. Studying them causes your head to pound."
	icon = 'icons/turf/walls/cult_wall.dmi'
	icon_state = "cult"
	walltype = "cult"
	builtin_sheet = null
	canSmoothWith = null

/turf/closed/wall/mineral/cult/New()
	PoolOrNew(/obj/effect/overlay/temp/cult/turf, src)
	..()

/turf/closed/wall/mineral/cult/break_wall()
	new/obj/item/stack/sheet/runed_metal(get_turf(src), 1)
	return (new /obj/structure/girder/cult(src))

/turf/closed/wall/mineral/cult/devastate_wall()
	new/obj/item/stack/sheet/runed_metal(get_turf(src), 1)

/turf/closed/wall/mineral/cult/narsie_act()
	return

/turf/closed/wall/mineral/cult/artificer
	name = "runed stone wall"
	desc = "A cold stone wall engraved with indecipherable symbols. Studying them causes your head to pound."

/turf/closed/wall/mineral/cult/artificer/break_wall()
	PoolOrNew(/obj/effect/overlay/temp/cult/turf, get_turf(src))
	return null //excuse me we want no runed metal here

/turf/closed/wall/mineral/cult/artificer/devastate_wall()
	PoolOrNew(/obj/effect/overlay/temp/cult/turf, get_turf(src))

//Clockwork wall: Causes nearby tinkerer's caches to generate components.
/turf/closed/wall/clockwork
	name = "clockwork wall"
	desc = "A huge chunk of warm metal. The clanging of machinery emanates from within."
	icon = 'icons/turf/walls/clockwork_wall.dmi'
	icon_state = "clockwork_wall"
	canSmoothWith = list(/turf/closed/wall/clockwork)
	smooth = SMOOTH_MORE

/turf/closed/wall/clockwork/New()
	..()
	PoolOrNew(/obj/effect/overlay/temp/ratvar/wall, src)
	PoolOrNew(/obj/effect/overlay/temp/ratvar/beam, src)
	SSobj.processing += src
	clockwork_construction_value += 5

/turf/closed/wall/clockwork/Destroy()
	SSobj.processing -= src
	clockwork_construction_value -= 5
	..()

/turf/closed/wall/clockwork/process()
	if(prob(2))
		playsound(src, 'sound/magic/clockwork/fellowship_armory.ogg', rand(1, 5), 1, -4, 1, 1)
	for(var/obj/structure/clockwork/cache/C in range(1, src))
		if(prob(5))
			clockwork_component_cache[pick("belligerent_eye", "vanguard_cogwheel", "guvax_capacitor", "replicant_alloy", "hierophant_ansible")]++
			playsound(src, 'sound/magic/clockwork/fellowship_armory.ogg', rand(15, 20), 1, -3, 1, 1)

/turf/closed/wall/clockwork/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = I
		if(!WT.isOn())
			return 0
		user.visible_message("<span class='notice'>[user] begins slowly breaking down [src]...</span>", "<span class='notice'>You begin painstakingly destroying [src]...</span>")
		if(!do_after(user, 120 / WT.toolspeed, target = src))
			return 0
		if(!WT.remove_fuel(1, user))
			return 0
		user.visible_message("<span class='notice'>[user] breaks apart [src]!</span>", "<span class='notice'>You break apart [src]!</span>")
		break_wall()
		return 1
	return ..()

/turf/closed/wall/clockwork/break_wall()
	new/obj/item/clockwork/component/replicant_alloy(get_turf(src))
	return(new /obj/structure/girder(src))

/turf/closed/wall/clockwork/devastate_wall()
	return break_wall()

/turf/closed/wall/vault
	icon = 'icons/turf/walls.dmi'
	icon_state = "rockvault"

/turf/closed/wall/ice
	icon = 'icons/turf/walls/icedmetal_wall.dmi'
	icon_state = "iced"
	desc = "A wall covered in a thick sheet of ice."
	walltype = "iced"
	canSmoothWith = null
	hardness = 35
	slicing_duration = 150 //welding through the ice+metal

/turf/closed/wall/rust
	name = "rusted wall"
	desc = "A rusted metal wall."
	icon = 'icons/turf/walls/rusty_wall.dmi'
	icon_state = "arust"
	walltype = "arust"
	hardness = 45

/turf/closed/wall/r_wall/rust
	name = "rusted reinforced wall"
	desc = "A huge chunk of rusted reinforced metal."
	icon = 'icons/turf/walls/rusty_reinforced_wall.dmi'
	icon_state = "rrust"
	walltype = "rrust"
	hardness = 15

/turf/closed/wall/shuttle
	name = "wall"
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "wall"
	walltype = "shuttle"
	smooth = SMOOTH_FALSE

/turf/closed/wall/shuttle/smooth
	name = "wall"
	icon = 'icons/turf/walls/shuttle_wall.dmi'
	icon_state = "shuttle"
	walltype = "shuttle"
	smooth = SMOOTH_MORE|SMOOTH_DIAGONAL
	canSmoothWith = list(/turf/closed/wall/shuttle/smooth, /obj/structure/window/shuttle, /obj/structure/shuttle/engine)

/turf/closed/wall/shuttle/smooth/nodiagonal
	smooth = SMOOTH_MORE
	icon_state = "shuttle_nd"

/turf/closed/wall/shuttle/smooth/overspace
	icon_state = "overspace"
	fixed_underlay = list("space"=1)

//sub-type to be used for interior shuttle walls
//won't get an underlay of the destination turf on shuttle move
/turf/closed/wall/shuttle/interior/copyTurf(turf/T)
	if(T.type != type)
		T.ChangeTurf(type)
		if(underlays.len)
			T.underlays = underlays
	if(T.icon_state != icon_state)
		T.icon_state = icon_state
	if(T.icon != icon)
		T.icon = icon
	if(T.color != color)
		T.color = color
	if(T.dir != dir)
		T.dir = dir
	T.transform = transform
	return T

/turf/closed/wall/shuttle/copyTurf(turf/T)
	. = ..()
	T.transform = transform


//why don't shuttle walls habe smoothwall? now i gotta do rotation the dirty way
/turf/closed/wall/shuttle/shuttleRotate(rotation)
	var/matrix/M = transform
	M.Turn(rotation)
	transform = M
