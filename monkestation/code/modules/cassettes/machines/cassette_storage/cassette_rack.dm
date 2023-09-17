/obj/structure/cassette_rack
	name = "cassette pouch"
	desc = "safely holds cassettes for storage"

	icon = 'monkestation/code/modules/cassettes/icons/radio_station.dmi'
	icon_state = "cassette_pouch"

	anchored = FALSE
	density = FALSE

	var/list/held_cassettes = list()
	var/max_cassettes = 28


/obj/structure/cassette_rack/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(!istype(attacking_item, /obj/item/device/cassette_tape))
		return

	if(length(held_cassettes) >= max_cassettes)
		to_chat(user, span_warning("You can't fit anything else inside the [src]."))
		return


	var/matrix/old_matrix = src.transform
	animate(src, time = 1.5, loop = 0, transform = src.transform.Scale(1.07, 0.9))
	animate(time = 2, transform = old_matrix)

	playsound(src, SFX_RUSTLE, 50, TRUE, -5)

	attacking_item.forceMove(src)
	held_cassettes |= attacking_item
	to_chat(user, span_notice("You put [attacking_item] into \the [src]."))
	update_appearance()

/obj/structure/cassette_rack/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!length(held_cassettes))
		return
	var/obj/item/choice = tgui_input_list(user, "Choose a cassette to remove", src, held_cassettes)
	if(!choice)
		return

	user.put_in_hands(choice)
	held_cassettes -= choice

	var/matrix/old_matrix = src.transform
	animate(src, time = 1.5, loop = 0, transform = src.transform.Scale(1.07, 0.9))
	animate(time = 2, transform = old_matrix)

	playsound(src, SFX_RUSTLE, 50, TRUE, -5)

	to_chat(user, span_notice("You take [choice] from \the [src]."))
	update_appearance()

/obj/structure/cassette_rack/update_overlays()
	. = ..()
	var/number = 0
	if(length(held_cassettes))
		number = CEILING(length(held_cassettes) / 7 , 1)

	. += mutable_appearance(icon, "[icon_state]_[number]")
