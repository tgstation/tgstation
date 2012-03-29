//add custom items you give to people here, and put their icons in custom_items.dmi
/obj/item/fluff // so that they don't spam up the object tree
	icon = 'custom_items.dmi'
	w_class = 1.0

/obj/item/fluff/wes_solari_1
	name = "Family Photograph"
	desc = "A family photograph of a couple and a young child, Written on the back it says \"See you soon Dad -Roy\"."
	icon_state = "wes_solari_1"

/obj/item/fluff/victor_kaminsky_1
	name = "\improper Golden Detective's Badge"
	desc = "NanoTrasen Security Department detective's badge, made from gold. Badge number is 564."
	icon_state = "victor_kaminsky_1"

/obj/item/fluff/victor_kaminsky_1/attack_self(mob/user as mob)
	for(var/mob/O in viewers(user, null))
		O.show_message(text("[] shows you: \icon[] [].", user, src, src.name), 1)
	src.add_fingerprint(user)

/obj/item/fluff/sarah_calvera_1
	name = "Old Photo"
	desc = "Looks like it was made on a really old, cheap camera. Low quality. The camera shows a young hispanic looking girl with red hair wearing a white dress is standing in front of an old looking wall. On the back there is a note in black marker that reads \"Sara, Siempre pensé que eras tan linda con ese vestido. Tu hermano, Carlos.\""
	icon_state = "sarah_calvera_1"

/obj/item/fluff/angelo_wilkerson_1
	name = "Fancy Watch"
	desc = "An old and expensive pocket watch. Engraved on the bottom is \"Odium est Source De Dolor\". On the back, there is an engraving that does not match the bottom and looks more recent. \"Angelo, If you find this, you shall never see me again. Please, for your sake, go anywhere and do anything but stay. I'm proud of you and I will always love you. Your father, Jacob Wilkerson.\" Jacob Wilkerson... Wasn't he that serial killer?"
	icon_state = "angelo_wilkerson_1"

/obj/item/clothing/glasses/meson/fluff/book_berner_1
	name = "Bespectacled Mesonic Surveyors"
	desc = "One of the older meson scanner models retrofitted to perform like its modern counterparts."
	icon = 'custom_items.dmi'
	icon_state = "book_berner_1"

/obj/item/fluff/sarah_carbrokes_1
	name = "Locket"
	desc = "A grey locket with a picture of a black haired man in it. The text above it reads: \"Edwin Carbrokes\"."
	icon_state = "sarah_carbrokes_1"

/obj/item/clothing/glasses/fluff/serithi_artalis_1
	name = "Extranet HUD"
	desc = "A heads-up display with limited connectivity to the NanoTrasen Extranet, capable of displaying information from official NanoTrasen records."
	icon_state = "serithi_artalis_1"
