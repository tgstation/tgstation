// This file contains all boxes used by the Engineering department and its purpose on the station. Also contains stuff we use when we wanna fix up stuff as well or helping us live when shit goes southwardly.

/obj/item/storage/box/metalfoam
	name = "box of metal foam grenades"
	desc = "To be used to rapidly seal hull breaches."
	illustration = "grenade"

/obj/item/storage/box/metalfoam/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/grenade/chem_grenade/metalfoam(src)

/obj/item/storage/box/smart_metal_foam
	name = "box of smart metal foam grenades"
	desc = "Used to rapidly seal hull breaches. This variety conforms to the walls of its area."
	illustration = "grenade"

/obj/item/storage/box/smart_metal_foam/PopulateContents()
	for(var/i in 1 to 7)
		new/obj/item/grenade/chem_grenade/smart_metal_foam(src)

/obj/item/storage/box/plastic
	name = "plastic box"
	desc = "It's a solid, plastic shell box."
	icon_state = "plasticbox"
	foldable_result = null
	illustration = "writing"
	custom_materials = list(/datum/material/plastic = HALF_SHEET_MATERIAL_AMOUNT) //You lose most if recycled.

/obj/item/storage/box/emergencytank
	name = "emergency oxygen tank box"
	desc = "A box of emergency oxygen tanks."
	illustration = "emergencytank"

/obj/item/storage/box/emergencytank/PopulateContents()
	..()
	for(var/i in 1 to 7)
		new /obj/item/tank/internals/emergency_oxygen(src) //in case anyone ever wants to do anything with spawning them, apart from crafting the box

/obj/item/storage/box/engitank
	name = "extended-capacity emergency oxygen tank box"
	desc = "A box of extended-capacity emergency oxygen tanks."
	illustration = "extendedtank"

/obj/item/storage/box/engitank/PopulateContents()
	..()
	for(var/i in 1 to 7)
		new /obj/item/tank/internals/emergency_oxygen/engi(src) //in case anyone ever wants to do anything with spawning them, apart from crafting the box

/obj/item/storage/box/stickers/chief_engineer
	name = "CE approved sticker pack"
	desc = "With one of these stickers, inform the crew that the contraption in the corridor is COMPLETELY SAFE!"
	illustration = "label_ce"

/obj/item/storage/box/stickers/chief_engineer/PopulateContents()
	for(var/i in 1 to 3)
		new /obj/item/sticker/chief_engineer(src)
