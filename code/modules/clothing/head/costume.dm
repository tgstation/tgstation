/obj/item/clothing/head/costume
	icon = 'icons/obj/clothing/head/costume.dmi'
	worn_icon = 'icons/mob/clothing/head/costume.dmi'
	abstract_type = /obj/item/clothing/head/costume

/obj/item/clothing/head/costume/powdered_wig
	name = "powdered wig"
	desc = "A powdered wig."
	icon_state = "pwig"
	inhand_icon_state = "pwig"

/obj/item/clothing/head/costume/hasturhood
	name = "hastur's hood"
	desc = "It's <i>unspeakably</i> stylish."
	icon_state = "hasturhood"
	flags_inv = HIDEHAIR
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/syndicatefake
	name = "black space-helmet replica"
	icon = 'icons/obj/clothing/head/spacehelm.dmi'
	worn_icon = 'icons/mob/clothing/head/spacehelm.dmi'
	icon_state = "syndicate-helm-black-red"
	inhand_icon_state = "syndicate-helm-black-red"
	desc = "A plastic replica of a Syndicate agent's space helmet. You'll look just like a real murderous Syndicate agent in this! This is a toy, it is not made for use in space!"
	clothing_flags = SNUG_FIT | STACKABLE_HELMET_EXEMPT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/head/costume/cueball
	name = "cueball helmet"
	desc = "A large, featureless white orb meant to be worn on your head. How do you even see out of this thing?"
	icon_state = "cueball"
	inhand_icon_state = null
	clothing_flags = SNUG_FIT
	flags_cover = HEADCOVERSEYES|HEADCOVERSMOUTH
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/head/costume/snowman
	name = "snowman head"
	desc = "A ball of white styrofoam. So festive."
	icon_state = "snowman_h"
	inhand_icon_state = null
	clothing_flags = SNUG_FIT
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/head/costume/witchwig
	name = "witch costume wig"
	desc = "Eeeee~heheheheheheh!"
	icon_state = "witch"
	inhand_icon_state = null
	flags_inv = HIDEHAIR

/obj/item/clothing/head/costume/maid_headband
	name = "maid headband"
	desc = "Just like from one of those chinese cartoons!"
	greyscale_colors = "#494955#EEEEEE"
	icon = 'icons/map_icons/clothing/head/_head.dmi'
	icon_state = "/obj/item/clothing/head/costume/maid_headband"
	post_init_icon_state = "maid"
	greyscale_config = /datum/greyscale_config/maid_headband
	greyscale_config_worn = /datum/greyscale_config/maid_headband/worn
	greyscale_config_inhand_left = /datum/greyscale_config/maid_headband_inhands_left
	greyscale_config_inhand_right = /datum/greyscale_config/maid_headband_inhands_right
	inhand_icon_state = "maid"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/costume/chicken
	name = "chicken suit head"
	desc = "Bkaw!"
	icon_state = "chickenhead"
	inhand_icon_state = "chicken_head"
	clothing_flags = SNUG_FIT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/head/costume/griffin
	name = "griffon head"
	desc = "Why not 'eagle head'? Who knows."
	icon_state = "griffinhat"
	inhand_icon_state = null
	clothing_flags = SNUG_FIT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/head/costume/xenos
	name = "xenos helmet"
	icon_state = "xenos"
	inhand_icon_state = "xenos_helm"
	desc = "A helmet made out of chitinous alien hide."
	clothing_flags = SNUG_FIT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH

/obj/item/clothing/head/costume/lobsterhat
	name = "foam lobster head"
	desc = "When everything's going to crab, protecting your head is the best choice."
	icon_state = "lobster_hat"
	clothing_flags = SNUG_FIT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/head/costume/lobsterhat/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/speechmod, replacements = strings("crustacean_replacement.json", "crustacean"))

/obj/item/clothing/head/costume/drfreezehat
	name = "doctor freeze's wig"
	desc = "A cool wig for cool people."
	icon_state = "drfreeze_hat"
	flags_inv = HIDEHAIR

/obj/item/clothing/head/costume/shrine_wig
	name = "shrine maiden's wig"
	desc = "Purify in style!"
	flags_inv = HIDEHAIR //bald
	icon_state = "shrine_wig"
	inhand_icon_state = null
	worn_y_offset = 1

/obj/item/clothing/head/costume/cardborg
	name = "cardborg helmet"
	desc = "A helmet made out of a box."
	icon_state = "cardborg_h"
	inhand_icon_state = "cardborg_h"
	clothing_flags = SNUG_FIT
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

	dog_fashion = /datum/dog_fashion/head/cardborg

/obj/item/clothing/head/costume/cardborg/equipped(mob/living/user, slot)
	..()
	if(ishuman(user) && (slot & ITEM_SLOT_HEAD))
		var/mob/living/carbon/human/human_user = user
		if(istype(human_user.wear_suit, /obj/item/clothing/suit/costume/cardborg))
			var/obj/item/clothing/suit/costume/cardborg/suit = human_user.wear_suit
			suit.disguise(user, src)

/obj/item/clothing/head/costume/bronze
	name = "bronze hat"
	desc = "A crude helmet made out of bronze plates. It offers very little in the way of protection."
	icon_state = "clockwork_helmet_old"
	clothing_flags = SNUG_FIT
	flags_inv = HIDEEARS|HIDEHAIR
	armor_type = /datum/armor/costume_bronze

/obj/item/clothing/head/costume/fancy
	name = "fancy hat"
	icon = 'icons/map_icons/clothing/head/_head.dmi'
	icon_state = "/obj/item/clothing/head/costume/fancy"
	post_init_icon_state = "fancy_hat"
	greyscale_config = /datum/greyscale_config/fancy_hat
	greyscale_config_worn = /datum/greyscale_config/fancy_hat/worn
	greyscale_colors = "#E3C937#782A81"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/costume/football_helmet
	name = "football helmet"
	icon = 'icons/map_icons/clothing/head/_head.dmi'
	icon_state = "/obj/item/clothing/head/costume/football_helmet"
	post_init_icon_state = "football_helmet"
	greyscale_config = /datum/greyscale_config/football_helmet
	greyscale_config_worn = /datum/greyscale_config/football_helmet/worn
	greyscale_colors = "#D74722"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/costume/tv_head
	name = "television helmet"
	desc = "A mysterious headgear made from the hollowed out remains of a status display. How very retro-retro-futuristic of you."
	icon_state = "IPC_helmet"
	inhand_icon_state = "syringe_kit"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi' //Grandfathered in from the wallframe for status displays.
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	clothing_flags = SNUG_FIT
	flags_cover = HEADCOVERSEYES|HEADCOVERSMOUTH
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/datum/armor/costume_bronze
	melee = 5
	laser = -5
	energy = -15
	bomb = 10
	fire = 20
	acid = 20

/obj/item/clothing/head/costume/irs
	name = "internal revenue service cap"
	desc = "Even in space, you can't avoid the tax collectors."
	icon_state = "irs_hat"
	inhand_icon_state = null

/obj/item/clothing/head/costume/tmc
	name = "Lost M.C. bandana"
	desc = "A small, red bandana tied thin."
	icon_state = "tmc_hat"
	inhand_icon_state = null

/obj/item/clothing/head/costume/deckers
	name = "Decker headphones"
	desc = "A neon-blue pair of headphones. They look neo-futuristic."
	icon_state = "decker_hat"
	inhand_icon_state = null
	equip_sound = SFX_HEADSET_EQUIP
	pickup_sound = SFX_HEADSET_PICKUP
	drop_sound = 'sound/items/handling/headset/headset_drop1.ogg'

/obj/item/clothing/head/costume/yuri
	name = "yuri initiate helmet"
	desc = "A strange, whitish helmet with 3 eyeholes."
	icon_state = "yuri_helmet"
	inhand_icon_state = null
	clothing_flags = SNUG_FIT
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDESNOUT

/obj/item/clothing/head/costume/allies
	name = "allies helmet"
	desc = "An ancient military helmet worn by the bravest of warriors. \
	It's only a replica, and probably wouldn't protect you from anything."
	icon_state = "allies_helmet"
	inhand_icon_state = null

/obj/item/clothing/head/costume/hairpin
	name = "fancy hairpin"
	desc = "A delicate hairpin normally paired with traditional clothing"
	icon_state = "hairpin_fancy"
	inhand_icon_state = "hairpin_fancy"


/obj/item/clothing/head/costume/snakeeater
	name = "strange bandana"
	desc = "A bandana. It seems to have a little carp embroidered on the inside, as well as the kanji '魚'."
	icon_state = "snake_eater"
	inhand_icon_state = null
	clothing_traits = list(TRAIT_FISH_EATER)

/obj/item/clothing/head/costume/knight
	name = "fake medieval helmet"
	desc = "A classic metal helmet. Though, this one seems to be very obviously fake..."
	icon = 'icons/obj/clothing/head/helmet.dmi'
	worn_icon = 'icons/mob/clothing/head/helmet.dmi'
	icon_state = "knight_green"
	inhand_icon_state = "knight_helmet"
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR|HIDESNOUT
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	dog_fashion = null
