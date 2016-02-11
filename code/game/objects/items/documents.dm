/obj/item/documents
	name = "secret documents"
	desc = "\"Top Secret\" documents printed on special copy-protected paper."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "docs_generic"
	item_state = "paper"
	throwforce = 0
	w_class = 1
	throw_range = 1
	throw_speed = 1
	layer = 4
	pressure_resistance = 1

/obj/item/documents/nanotrasen
	desc = "\"Top Secret\" Nanotrasen documents printed on special copy-protected paper. It is filled with complex diagrams and lists of names, dates and coordinates."
	icon_state = "docs_verified"

/obj/item/documents/syndicate
	desc = "\"Top Secret\" documents printed on special copy-protected paper. It details sensitive Syndicate operational intelligence."

/obj/item/documents/syndicate/red
	name = "'Red' secret documents"
	desc = "\"Top Secret\" documents printed on special copy-protected paper. It details sensitive Syndicate operational intelligence. These documents are marked \"Red\"."
	icon_state = "docs_red"

/obj/item/documents/syndicate/blue
	name = "'Blue' secret documents"
	desc = "\"Top Secret\" documents printed on special copy-protected paper. It details sensitive Syndicate operational intelligence. These documents are marked \"Blue\"."
	icon_state = "docs_blue"