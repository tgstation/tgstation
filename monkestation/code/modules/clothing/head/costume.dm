/obj/item/clothing/head/tragic
	name = "tragic mime headpiece"
	desc = "A white mask approximating a human face, comes with a hood. Used by theatre actors who play as nameless extra characters."
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "tragic"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT

/obj/item/clothing/head/bee
	name = "bee hat"
	desc = "A hat made from beehide"
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "bee"
	flags_inv = HIDEHAIR
	worn_y_offset = 2

/obj/item/clothing/head/lizard
	name = "novelty lizard head"
	desc = "A giant sculpted foam lizard head.  It doesn't quite look like the lizards from this sector..."
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "lizardhead"
	flags_inv = HIDEHAIR
	worn_y_offset = 1

/obj/item/clothing/head/wonka
	name = "wonky hat"
	desc = "Come with me, and you'll be, in a world of OSHA violations!"
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "wonka"

/obj/item/clothing/head/knowingclown
	name = "Small but Knowing Clown hat"
	desc = "The Cap of a Small but All Knowing Clown"
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "knowingclownhat"
	worn_y_offset = 6

/obj/item/clothing/head/milkmanhat
	name = "milkman hat"
	desc = "Special delivery today!!!"
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "milkman_hat"

/obj/item/clothing/head/guardmanhelmet
	name = "guardman's helmet"
	desc = "Keeps your brain intact when fighting heretics"
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "guardman_helmet"

/*
BUNNY EARS
*/

/obj/item/clothing/head/playbunnyears
	name = "bunny ears headband"
	desc = "A pair of bunny ears attached to a headband. One of the ears is already crooked."
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head_32x48.dmi'
	icon_state = "playbunny_ears"
	clothing_flags = LARGE_WORN_ICON
	greyscale_colors = "#39393f"
	greyscale_config = /datum/greyscale_config/playbunnyears
	greyscale_config_worn = /datum/greyscale_config/playbunnyears_worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/playbunnyears/syndicate
	name = "blood-red bunny ears headband"
	desc = "An unusually suspicious pair of bunny ears attached to a headband. The headband looks reinforced with plasteel... but why?"
	icon_state = "syndibunny_ears"
	clothing_flags = SNUG_FIT | LARGE_WORN_ICON
	armor_type = /datum/armor/playbunnyears_syndicate
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/datum/armor/playbunnyears_syndicate
	melee = 30
	bullet = 20
	laser = 30
	energy = 35
	fire = 20
	bomb = 15
	acid = 50
	wound = 5

/obj/item/clothing/head/playbunnyears/centcom
	name = "centcom bunny ears headband"
	desc = "A pair of very professional bunny ears attached to a headband. The ears themselves came from an endangered species of green rabbits."
	icon_state = "playbunny_ears_centcom"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/head/playbunnyears/british
	name = "british bunny ears headband"
	desc = "A pair of classy bunny ears attached to a headband. Worn to honor the crown."
	icon_state = "playbunny_ears_brit"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/head/playbunnyears/communist
	name = "really red bunny ears headband"
	desc = "A pair of red and gold bunny ears attached to a headband. Commonly used by any collectivizing bunny waiters."
	icon_state = "playbunny_ears_communist"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null

/obj/item/clothing/head/playbunnyears/usa
	name = "usa bunny ears headband"
	desc = "A pair of star spangled bunny ears attached to a headband. The headband of a true patriot."
	icon_state = "playbunny_ears_usa"
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null
/*
END OF BUNNY EARS
*/
