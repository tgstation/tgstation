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
	icon_state = type

	var/matrix/M = matrix()
	M.Turn(rotation)
	src.transform = M

	color = main

/obj/effect/decal/cleanable/crayon/gang
	var/gang

/obj/effect/decal/cleanable/crayon/gang/New()
	world << "DEBUG: A[ticker.mode.A_territory.len] B[ticker.mode.B_territory.len] Goal[start_state.num_territories / 2]"

/obj/effect/decal/cleanable/crayon/gang/Destroy()
	var/area/territory = get_area(src)
	var/list/recipients

	if(gang == "A")
		recipients = ticker.mode.A_tools
		ticker.mode.A_territory -= territory.type
	if(gang == "B")
		recipients = ticker.mode.B_tools
		ticker.mode.B_territory -= territory.type
	if(recipients.len)
		ticker.mode.message_gangtools(recipients,"Territory lost: [territory]")