/obj/item/tail_pin
	icon_state = "tailpin"
	name = "tail pin"
	desc = "Offically branded 'pin the tail on the corgi' style party implement. Not intended to be used on people."
	force = 0
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 0
	throw_speed = 1
	embedding = EMBED_HARMLESS
	custom_materials = list(/datum/material/iron=1000)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("pokes", "jabs", "pins the tail on")
	attack_verb_simple = list("poke", "jab")
	sharpness = SHARP_POINTY
	max_integrity = 200
	layer = CORGI_ASS_PIN_LAYER

/obj/item/poster/tail_board
	name = "party game poster"
	poster_type = /obj/structure/sign/poster/party_game
	icon_state = "rolled_poster"

/obj/structure/sign/poster/party_game
	name = "pin the tail on the corgi"
	desc = "The rules are simple, pin the tail on the corgi, while blindfolded. Are you a bad enough dude to hit the target?"
	icon_state = "pinningposter"
	poster_item_name = "party game poster"
	poster_item_desc = "Place it on a wall to start playing pin the tail on the corgi."

/obj/structure/sign/poster/party_game/attackby(obj/item/I, mob/user, params)
	. = ..()
	if(!istype(I,/obj/item/tail_pin))
		return
	if(!(I.item_flags & ABSTRACT)) //We're using the same trick that tables use for placing objects x and y onto the click location.
		return
	if(!user.transferItemToLoc(I, drop_location(), silent = FALSE))
		return
	var/list/click_params = params2list(params)
	if(!click_params || !click_params["icon-x"] || !click_params["icon-y"])
		return
	I.pixel_x = clamp(text2num(click_params["icon-x"]) - 16, -(world.icon_size/2), world.icon_size/2)
	I.pixel_y = clamp(text2num(click_params["icon-y"]) - 16, -(world.icon_size/2), world.icon_size/2)
	return TRUE
