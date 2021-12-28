/**
 * # secret documents
 *
 * Indestructible antag objective that can be photocopied.
 *
 * Photocopying this is handled in photocopier.dm.
 * Cannot be destroyed, but can be spaced.
 * Save for the inhand, this does not actually have anything in common with /obj/item/paper.
*/
/obj/item/documents
	name = "secret documents"
	desc = "\"Top Secret\" documents."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "docs_generic"
	inhand_icon_state = "paper"
	throwforce = 0
	atom_size = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	layer = MOB_LAYER
	pressure_resistance = 2
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF

///Nanotrasen documents
/obj/item/documents/nanotrasen
	desc = "\"Top Secret\" Nanotrasen documents, filled with complex diagrams and lists of names, dates and coordinates."
	icon_state = "docs_verified"

///Syndicate documents
/obj/item/documents/syndicate
	desc = "\"Top Secret\" documents detailing sensitive Syndicate operational intelligence."

///Syndicate documents with a red seal
/obj/item/documents/syndicate/red
	name = "red secret documents"
	desc = "\"Top Secret\" documents detailing sensitive Syndicate operational intelligence. These documents are verified with a red wax seal."
	icon_state = "docs_red"

///Syndicate documents with a blue seal
/obj/item/documents/syndicate/blue
	name = "blue secret documents"
	desc = "\"Top Secret\" documents detailing sensitive Syndicate operational intelligence. These documents are verified with a blue wax seal."
	icon_state = "docs_blue"

///Syndicate mining documents
/obj/item/documents/syndicate/mining
	desc = "\"Top Secret\" documents detailing Syndicate plasma mining operations."

/**
 * # secret documents (photocopy)
 *
 * Outcome of photocopying documents. Can be copied, and can have a blue/red seal forged.
*/
/obj/item/documents/photocopy
	desc = "A copy of some top-secret documents. Nobody will notice they aren't the originals... right?"
	///What seal was forged on the documents (color name string)
	var/forgedseal = 0
	///What was copied
	var/copy_type = null

/obj/item/documents/photocopy/Initialize(mapload, obj/item/documents/copy=null)
	. = ..()
	if(copy)
		copy_type = copy.type
		if(istype(copy, /obj/item/documents/photocopy)) // Copy Of A Copy Of A Copy
			var/obj/item/documents/photocopy/C = copy
			copy_type = C.copy_type

/obj/item/documents/photocopy/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/toy/crayon/red) || istype(O, /obj/item/toy/crayon/blue))
		if (forgedseal)
			to_chat(user, span_warning("You have already forged a seal on [src]!"))
		else
			var/obj/item/toy/crayon/C = O
			name = "[C.crayon_color] secret documents"
			icon_state = "docs_[C.crayon_color]"
			forgedseal = C.crayon_color
			to_chat(user, span_notice("You forge the official seal with a [C.crayon_color] crayon. No one will notice... right?"))
			update_appearance()
