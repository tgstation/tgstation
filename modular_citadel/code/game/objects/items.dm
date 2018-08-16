/obj/item
	var/total_mass //Total mass in arbitrary pound-like values. If there's no balance reasons for an item to have otherwise, this var should be the item's weight in pounds.

	var/list/alternate_screams = list() //REEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEEE

// lazy for screaming.
/obj/item/clothing/head/xenos
	alternate_screams = list('sound/voice/hiss6.ogg')

/obj/item/clothing/head/cardborg
	alternate_screams = list('modular_citadel/sound/voice/scream_silicon.ogg')

/obj/item/clothing/head/ushanka
	alternate_screams = list('modular_citadel/sound/misc/cyka1.ogg', 'modular_citadel/sound/misc/cheekibreeki.ogg')