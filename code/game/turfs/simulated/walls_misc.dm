/turf/simulated/wall/cult
	name = "wall"
	desc = "The patterns engraved on the wall seem to shift as you try to focus on them. You feel sick"
	icon_state = "cult"
	walltype = "cult"
	builtin_sheet = null

/turf/simulated/wall/cult/break_wall()
	new /obj/effect/decal/cleanable/blood(src)
	new /obj/structure/cultgirder(src)

/turf/simulated/wall/cult/devastate_wall()
	new /obj/effect/decal/cleanable/blood(src)
	new /obj/effect/decal/remains/human(src)

/turf/simulated/wall/cult/narsie_act()
	return

/turf/simulated/wall/vault
	icon_state = "rockvault"

/turf/simulated/wall/rust
	name = "rusted wall"
	desc = "A rusted metal wall."
	icon_state = "arust"
	walltype = "arust"
	hardness = 45

/turf/simulated/wall/r_wall/rust
	name = "rusted reinforced wall"
	desc = "A huge chunk of rusted reinforced metal."
	icon_state = "rrust"
	walltype = "rrust"
	hardness = 15

/turf/simulated/wall/riveted
	icon_state = "riveted"
	walltype = "riveted"

/turf/simulated/wall/riveted/relativewall()
	return

/turf/simulated/wall/abductor
	icon_state = "alien1"
	walltype = "alien"

/turf/simulated/wall/abductor/relativewall()
	return

/turf/simulated/wall/fakeglass
	name = "window"
	icon_state = "fakewindows"
	walltype = "fakewindows"
	opacity = 0

/turf/simulated/wall/fakeglass/relativewall()
	return

/turf/simulated/wall/fakedoor
	name = "Centcom Access"
	icon = 'icons/obj/doors/Doorele.dmi'
	walltype = "door"
	icon_state = "door_closed"

/turf/simulated/wall/fakedoor/relativewall()
	return

/turf/simulated/wall/shuttle
	name = "wall"
	icon = 'icons/turf/shuttle.dmi'
	icon_state = "wall1"
	walltype = "shuttle"

/turf/simulated/wall/shuttle/relativewall()
	return

//sub-type to be used for interior shuttle walls
//won't get an underlay of the destination turf on shuttle move
/turf/simulated/wall/shuttle/interior/copyTurf(turf/T)
	if(T.type != type)
		T = new type(T)
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
	return T