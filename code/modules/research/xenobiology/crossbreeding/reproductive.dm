/*
Reproductive extracts:
	When fed three monkey cubes, produces between
	1 and 4 normal slime extracts of the same colour.
*/


/obj/item/slimecross/reproductive
	name = "reproductive extract"
	desc = "It pulses with a strange hunger."
	icon_state = "reproductive"
	effect = "reproductive"
	effect_desc = "When fed monkey cubes it produces more extracts. Bio bag compatible as well."
	var/extract_type = /obj/item/slime_extract/
	var/cooldown = 3 SECONDS
	var/feedAmount = 3
	var/last_produce = 0

/obj/item/slimecross/reproductive/examine()
	. = ..()
	. += span_danger("It appears to have eaten [length(contents)] Monkey Cube[p_s()]")

/obj/item/slimecross/reproductive/Initialize(mapload)
	. = ..()
	create_storage(type = /datum/storage/extract_inventory)

/obj/item/slimecross/reproductive/attackby(obj/item/O, mob/user)
	var/datum/storage/extract_inventory/slime_storage = atom_storage
	if(!istype(slime_storage))
		return

	if((last_produce + cooldown) > world.time)
		to_chat(user, span_warning("[src] is still digesting!"))
		return

	if(length(contents) >= feedAmount) //if for some reason the contents are full, but it didnt digest, attempt to digest again
		to_chat(user, span_warning("[src] appears to be full but is not digesting! Maybe poking it stimulated it to digest."))
		slime_storage?.processCubes(user)
		return

	if(istype(O, /obj/item/storage/bag/xeno))
		var/list/inserted = list()
		O.atom_storage.remove_type(/obj/item/food/monkeycube, src, feedAmount - length(contents), TRUE, FALSE, user, inserted)
		if(inserted.len)
			to_chat(user, span_notice("You feed [length(inserted)] Monkey Cube[p_s()] to [src], and it pulses gently."))
			playsound(src, 'sound/items/eatfood.ogg', 20, TRUE)
			slime_storage?.processCubes(user)
		else
			to_chat(user, span_warning("There are no monkey cubes in the bio bag!"))
		return

	else if(istype(O, /obj/item/food/monkeycube))
		if(atom_storage?.attempt_insert(src, O, user, override = TRUE, force = TRUE))
			to_chat(user, span_notice("You feed 1 Monkey Cube to [src], and it pulses gently."))
			slime_storage?.processCubes(user)
			playsound(src, 'sound/items/eatfood.ogg', 20, TRUE)
			return
		else
			to_chat(user, span_notice("The [src] rejects the Monkey Cube!")) //in case it fails to insert for whatever reason you get feedback

/obj/item/slimecross/reproductive/grey
	extract_type = /obj/item/slime_extract/grey
	colour = "grey"

/obj/item/slimecross/reproductive/orange
	extract_type = /obj/item/slime_extract/orange
	colour = "orange"

/obj/item/slimecross/reproductive/purple
	extract_type = /obj/item/slime_extract/purple
	colour = "purple"

/obj/item/slimecross/reproductive/blue
	extract_type = /obj/item/slime_extract/blue
	colour = "blue"

/obj/item/slimecross/reproductive/metal
	extract_type = /obj/item/slime_extract/metal
	colour = "metal"

/obj/item/slimecross/reproductive/yellow
	extract_type = /obj/item/slime_extract/yellow
	colour = "yellow"

/obj/item/slimecross/reproductive/darkpurple
	extract_type = /obj/item/slime_extract/darkpurple
	colour = "dark purple"

/obj/item/slimecross/reproductive/darkblue
	extract_type = /obj/item/slime_extract/darkblue
	colour = "dark blue"

/obj/item/slimecross/reproductive/silver
	extract_type = /obj/item/slime_extract/silver
	colour = "silver"

/obj/item/slimecross/reproductive/bluespace
	extract_type = /obj/item/slime_extract/bluespace
	colour = "bluespace"

/obj/item/slimecross/reproductive/sepia
	extract_type = /obj/item/slime_extract/sepia
	colour = "sepia"

/obj/item/slimecross/reproductive/cerulean
	extract_type = /obj/item/slime_extract/cerulean
	colour = "cerulean"

/obj/item/slimecross/reproductive/pyrite
	extract_type = /obj/item/slime_extract/pyrite
	colour = "pyrite"

/obj/item/slimecross/reproductive/red
	extract_type = /obj/item/slime_extract/red
	colour = "red"

/obj/item/slimecross/reproductive/green
	extract_type = /obj/item/slime_extract/green
	colour = "green"

/obj/item/slimecross/reproductive/pink
	extract_type = /obj/item/slime_extract/pink
	colour = "pink"

/obj/item/slimecross/reproductive/gold
	extract_type = /obj/item/slime_extract/gold
	colour = "gold"

/obj/item/slimecross/reproductive/oil
	extract_type = /obj/item/slime_extract/oil
	colour = "oil"

/obj/item/slimecross/reproductive/black
	extract_type = /obj/item/slime_extract/black
	colour = "black"

/obj/item/slimecross/reproductive/lightpink
	extract_type = /obj/item/slime_extract/lightpink
	colour = "light pink"

/obj/item/slimecross/reproductive/adamantine
	extract_type = /obj/item/slime_extract/adamantine
	colour = "adamantine"

/obj/item/slimecross/reproductive/rainbow
	extract_type = /obj/item/slime_extract/rainbow
	colour = "rainbow"
