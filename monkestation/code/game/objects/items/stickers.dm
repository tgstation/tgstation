/obj/item/sticker/monkestation
	icon = 'monkestation/icons/obj/stickers.dmi'
	icon_state = "NULL"

/obj/item/sticker/monkestation/menacing
	name = "menacing sticker"
	icon_state = "menacing"

/obj/item/sticker/monkestation/_do
	name = "do sticker"
	icon_state = "do"

/obj/item/sticker/monkestation/numbers
	name = "number sticker"
	icon_state = "1"

/obj/item/sticker/monkestation/numbers/attack_self(mob/user, modifiers)
	. = ..()
	var/choice = tgui_input_number(user, "Choose a number", "Sticker Selection", 0, 9, 0)
	if(!choice)
		return
	icon_state = "[choice]"

/obj/item/sticker/monkestation/letter
	name = "letter sticker"
	icon_state = "A"
	icon_states = list("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")

/obj/item/sticker/monkestation/letter/attack_self(mob/user, modifiers)
	. = ..()
	var/list/letters = list("A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z")
	var/choice = tgui_input_list(user, "Choose a letter", "Sticker Selection", letters)
	if(!choice)
		return
	icon_state = choice

/obj/item/sticker/monkestation/googly_eyes
	name = "googly eye stickers"
	icon_state = "Left Anime"
	icon_states = list("Left Anime", "Right Anime", "Lizard Eye", "Eye", "Angry Liz Left", "Angry Liz Right", "Angry Left", "Angry Right")

/obj/item/sticker/monkestation/googly_eyes/attack_self(mob/user, modifiers)
	. = ..()
	var/list/eyes = list("Left Anime", "Right Anime", "Lizard Eye", "Eye", "Angry Liz Left", "Angry Liz Right", "Angry Left", "Angry Right")
	var/choice = tgui_input_list(user, "Choose a letter", "Sticker Selection", eyes)
	if(!choice)
		return
	icon_state = choice

/obj/item/sticker/monkestation/exclamation
	name = "! sticker"
	icon_state = "Exclamation"

/obj/item/sticker/monkestation/question
	name = "? sticker"
	icon_state = "Question"

/obj/item/sticker/monkestation/ook
	name = "ook sticker"
	icon_state = "Ook"

/obj/item/sticker/monkestation/banana
	name = "banana sticker"
	icon_state = "Banana"

/obj/item/sticker/monkestation/lightbulb
	name = "lightbulb sticker"
	icon_state = "Lightbulb"

/obj/item/sticker/monkestation/bad_times
	name = "bad times sticker"
	icon_state = "Bad Times"


/obj/item/storage/box/monkestation_stickers
	name = "Box of Ook Certified Stickers"
	desc = "Signed off on by the duke himself!"
	///How many stickers do we fill this box with
	var/sticker_count = 30
	///List of sticker types we are restricted to picking from, if any
	var/list/allowed_sticker_types

/obj/item/storage/box/monkestation_stickers/PopulateContents()
	var/list/subtypes_list = subtypesof(/obj/item/sticker/monkestation)
	for(var/i = 1 to sticker_count)
		var/obj/item/sticker/sticker_type = pick(allowed_sticker_types || subtypes_list)
		new sticker_type(src)

/obj/item/storage/box/monkestation_stickers/bad_time
	name = "Box of Uncertified Leak Stickers"
	desc = "NOT signed off on by NT."
	allowed_sticker_types = list(/obj/item/sticker/monkestation/bad_times)
