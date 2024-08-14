/obj/item/clothing/gloves/fingerless/punch_mitts
	name = "punching mitts"
	desc = "Fingerless gloves with nasty spikes attached. Allows the wearer to utilize the ill-reputed fighting technique known as Hunter Boxing. The style \
		allows the user to punch wildlife rapidly to death. Supposedly, this is an incredible workout, but few people are insane enough to attempt to \
		punch every dangerous creature they encounter in the wild to death with their bare hands. Also kinda works against humanoids as well. \
		Not that you would...right?"
	icon_state = "punch_mitts"

/obj/item/clothing/gloves/fingerless/punch_mitts/Initialize(mapload)
	. = ..()

	AddComponent(/datum/component/martial_art_giver, /datum/martial_art/boxing/hunter)
