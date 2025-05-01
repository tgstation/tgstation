/obj/item/keycard/hotmeta
	name = "omninous key"
	desc = "This feels like it belongs to a door."
	icon = 'icons/obj/fluff/hotmeta_keys.dmi'
	puzzle_id = "omninous"

/obj/item/keycard/hotmeta/lizard
	name = "green key"
	icon_state = "lizard_key"
	puzzle_id = "lizard"

/obj/item/keycard/hotmeta/drake
	name = "red key"
	icon_state = "drake_key"
	puzzle_id = "drake"

/obj/item/keycard/hotmeta/hierophant
	name = "purple key"
	icon_state = "hiero_key"
	puzzle_id = "hiero"

/obj/item/keycard/hotmeta/legion
	name = "blue key"
	icon_state = "legion_key"
	puzzle_id = "legion"

/obj/machinery/door/puzzle/keycard/hotmeta
	name = "wooden door"
	desc = "A dusty, scratched door with a thick lock attached."
	icon = 'icons/obj/doors/puzzledoor/wood.dmi'
	puzzle_id = "omninous"
	open_message = "The door opens with a loud creak."

/obj/machinery/door/puzzle/keycard/hotmeta/lizard
	puzzle_id = "lizard"
	color = "#044116"
	desc = "A dusty, scratched door with a thick lock attached."

/obj/machinery/door/puzzle/keycard/hotmeta/drake
	puzzle_id = "drake"
	color = "#830c0c"
	desc = "A dusty, scratched door with a thick lock attached."

/obj/machinery/door/puzzle/keycard/hotmeta/hierophant
	puzzle_id = "hiero"
	color = "#770a65"
	desc = "A dusty, scratched door with a thick lock attached."

/obj/machinery/door/puzzle/keycard/hotmeta/legion
	puzzle_id = "legion"
	color = "#2b0496"
	desc = "A dusty, scratched door with a thick lock attached."

/mob/living/simple_animal/hostile/megafauna/hierophant/hotmeta
	crusher_loot = list(/obj/item/hierophant_club, /obj/item/crusher_trophy/vortex_talisman, /obj/item/keycard/hotmeta/hierophant)
	icon = 'icons/mob/simple/lavaland/hotmeta_hierophant_new.dmi'

/mob/living/simple_animal/hostile/megafauna/dragon/hotmeta
	crusher_loot = list(/obj/item/hierophant_club, /obj/item/crusher_trophy/vortex_talisman, /obj/item/keycard/hotmeta/drake)

/mob/living/simple_animal/hostile/megafauna/legion/hotmeta
	crusher_loot = list(/obj/item/hierophant_club, /obj/item/crusher_trophy/vortex_talisman, /obj/item/keycard/hotmeta/legion)
