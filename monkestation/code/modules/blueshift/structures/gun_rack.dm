/obj/structure/rack
	icon = 'monkestation/code/modules/blueshift/icons/rack.dmi'

/obj/structure/rack/shelf
	name = "shelf"
	desc = "A shelf, for storing things on. Conveinent!"
	icon = 'monkestation/code/modules/blueshift/icons/rack.dmi'
	icon_state = "shelf"

/obj/item/gun
	var/on_rack = FALSE

/obj/item/gun/proc/place_on_rack()
	on_rack = TRUE
	var/matrix/M = matrix()
	M.Turn(-90)
	transform = M

/obj/item/gun/proc/remove_from_rack()
	if(on_rack)
		var/matrix/M = matrix()
		transform = M
		on_rack = FALSE

/obj/item/gun/pickup(mob/user)
	. = ..()
	remove_from_rack()

/obj/structure/rack/gunrack
	name = "gun rack"
	desc = "A gun rack for storing guns."
	icon_state = "gunrack"

/obj/structure/rack/gunrack/Initialize(mapload)
	. = ..()
	if(mapload)
		for(var/obj/item/I in loc.contents)
			if(istype(I, /obj/item/gun))
				var/obj/item/gun/to_place = I
				to_place.place_on_rack()

/obj/structure/rack/gunrack/attackby(obj/item/W, mob/living/user, params)
	var/list/modifiers = params2list(params)
	if (W.tool_behaviour == TOOL_WRENCH && LAZYACCESS(modifiers, RIGHT_CLICK))
		W.play_tool_sound(src)
		deconstruct(TRUE)
		return
	if(user.istate & ISTATE_HARM)
		return ..()
	if(user.transferItemToLoc(W, drop_location()))
		if(istype(W, /obj/item/gun))
			var/obj/item/gun/our_gun = W
			our_gun.place_on_rack()
			our_gun.pixel_x = rand(-10, 10)
		return TRUE
