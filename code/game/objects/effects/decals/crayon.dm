/obj/effect/decal/cleanable/crayon
	name = "rune"
	desc = "A rune drawn in crayon."
	icon = 'icons/effects/crayondecal.dmi'
	icon_state = "rune1"
	layer = 2.1
	anchored = 1

/obj/effect/decal/cleanable/crayon/examine()
	set src in view(2)
	..()
	return


/obj/effect/decal/cleanable/crayon/New(location, main = "#FFFFFF", var/type = "rune1", var/e_name = "rune", var/rotation = 0)
	..()
	loc = location

	name = e_name
	desc = "A [name] drawn in crayon."
	if(type == "poseur tag")
		gang_name() //Generate gang names so they get removed from the pool
		type = pick(gang_name_pool)
	icon_state = type

	var/matrix/M = matrix()
	M.Turn(rotation)
	src.transform = M

	color = main

/obj/effect/decal/cleanable/crayon/gang
	layer = 3.6 //Harder to hide
	var/gang

/obj/effect/decal/cleanable/crayon/gang/New(location, var/type, var/e_name = "gang tag", var/rotation = 0)
	if(!type)
		qdel(src)

	var/area/territory = get_area(location)
	var/color

	if(type == "A")
		gang = type
		color = "#00b4ff"
		icon_state = gang_name("A")
		desc = "A territory marker left by the [gang_name("A")] Gang."
		ticker.mode.A_territory_new |= list(territory.type = territory.name)
		ticker.mode.A_territory_lost -= territory.type
	else if(type == "B")
		gang = type
		color = "#ff3232"
		icon_state = gang_name("B")
		desc = "A territory marker left by the [gang_name("B")] Gang."
		ticker.mode.B_territory_new |= list(territory.type = territory.name)
		ticker.mode.B_territory_lost -= territory.type

	..(location, color, icon_state, e_name, rotation)

/obj/effect/decal/cleanable/crayon/gang/Destroy()
	var/area/territory = get_area(src)

	if(gang == "A")
		ticker.mode.A_territory_new -= territory.type
		ticker.mode.A_territory_lost |= list(territory.type = territory.name)
	if(gang == "B")
		ticker.mode.B_territory_new -= territory.type
		ticker.mode.B_territory_lost |= list(territory.type = territory.name)
	..()