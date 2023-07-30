/obj/structure/rack
	icon = 'modular_bandastation/aesthetics/racks/icons/racks.dmi'

/obj/structure/rack/gunrack
	name = "gun rack"
	desc = "A gun rack for storing guns."
	icon_state = "gunrack"

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

/obj/structure/rack/gunrack/MouseDrop_T(obj/O, mob/user)
	if(!(istype(O, /obj/item/gun)))
		to_chat(user, span_warning("This item doesn't fit!"))
		return
	. = ..()
	if(.)
		add_fingerprint(user)
		var/obj/item/gun/our_gun = O
		our_gun.place_on_rack()

/obj/structure/rack/gunrack/attackby(obj/item/W, mob/living/user, params)
	if(!isgun(W))
		to_chat(user, span_warning("This item doesn't fit!"))
		return
	. = ..()
	if(.)
		add_fingerprint(user)
		var/obj/item/gun/our_gun = W
		our_gun.place_on_rack()
		var/list/click_params = params2list(params)
		//Center the icon where the user clicked.
		if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
			return
		//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
		W.pixel_x = clamp(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
		W.pixel_y = 0

/obj/structure/rack/gunrack/Initialize(mapload)
	. = ..()
	if(!mapload)
		return
	for(var/obj/item/gun/gun_inside in loc.contents)
		gun_inside.place_on_rack()

/obj/structure/rack/gunrack/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		density = FALSE
		var/obj/item/rack_parts/gun_rack/newparts = new(loc)
		transfer_fingerprints_to(newparts)
	for(var/obj/item/I in loc.contents)
		if(isgun(I))
			var/obj/item/gun/to_remove = I
			to_remove.remove_from_rack()
	qdel(src)

/obj/item/rack_parts/gun_rack
	name = "gun rack parts"
	desc = "Parts of a gun rack."
