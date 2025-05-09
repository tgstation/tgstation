/obj/item/clothing/suit/costume/wellworn_shirt
	name = "well-worn shirt"
	desc = "A worn out, curiously comfortable t-shirt. You wouldn't go so far as to say it feels like being hugged when you wear it, but it's pretty close. Good for sleeping in."
	inhand_icon_state = null
	icon = 'icons/map_icons/clothing/suit/costume.dmi'
	icon_state = "/obj/item/clothing/suit/costume/wellworn_shirt"
	post_init_icon_state = "wellworn_shirt"
	greyscale_config = /datum/greyscale_config/wellworn_shirt
	greyscale_config_worn = /datum/greyscale_config/wellworn_shirt/worn
	greyscale_colors = COLOR_WHITE
	species_exception = list(/datum/species/golem)
	flags_1 = IS_PLAYER_COLORABLE_1
	///How many times has this shirt been washed? (In an ideal world this is just the determinant of the transform matrix.)
	var/wash_count = 0

/obj/item/clothing/suit/costume/wellworn_shirt/machine_wash(obj/machinery/washing_machine/washer)
	. = ..()
	if(wash_count <= 5)
		transform *= TRANSFORM_USING_VARIABLE(0.8, 1)
		washer.visible_message("[src] appears to have shrunken after being washed.")
		wash_count += 1
	else
		washer.visible_message("[src] implodes due to repeated washing.")
		qdel(src)

/obj/item/clothing/suit/costume/wellworn_shirt/skub
	name = "pro-skub shirt"
	desc = "A worn out, curiously comfortable t-shirt proclaiming your pro-skub stance. Fuck those anti-skubbies."
	greyscale_colors = "#FFFF4D"
	icon_state = "/obj/item/clothing/suit/costume/wellworn_shirt/skub"
	post_init_icon_state = "wellworn_shirt_pro_skub"
	greyscale_config = /datum/greyscale_config/wellworn_shirt_skub
	greyscale_config_worn = /datum/greyscale_config/wellworn_shirt_skub/worn

/obj/item/clothing/suit/costume/wellworn_shirt/skub/anti
	name = "anti-skub shirt"
	desc = "A worn out, curiously comfortable t-shirt proclaiming your anti-skub stance. Fuck those pro-skubbies."
	icon_state = "/obj/item/clothing/suit/costume/wellworn_shirt/skub/anti"
	post_init_icon_state = "wellworn_shirt_anti_skub"

/obj/item/clothing/suit/costume/wellworn_shirt/graphic
	name = "well-worn graphic shirt"
	desc = "A worn out, curiously comfortable t-shirt with a character from Phanic the Weasel on the front. It adds some charm points to itself and the wearer, and reminds you of when the series was still good; way back in 2500."
	greyscale_colors = "#FFFFFF#46B45B"
	icon_state = "/obj/item/clothing/suit/costume/wellworn_shirt/graphic"
	post_init_icon_state = "wellworn_shirt_gamer"
	greyscale_config = /datum/greyscale_config/wellworn_shirt_graphic
	greyscale_config_worn = /datum/greyscale_config/wellworn_shirt_graphic/worn

/obj/item/clothing/suit/costume/wellworn_shirt/graphic/ian
	name = "well-worn ian shirt"
	desc = "A worn out, curiously comfortable t-shirt with a picture of Ian the Corgi. You wouldn't go so far as to say it feels like being hugged when you wear it, but it's pretty close. Good for sleeping in."
	icon_state = "/obj/item/clothing/suit/costume/wellworn_shirt/graphic/ian"
	post_init_icon_state = "wellworn_shirt_ian"
	greyscale_colors = "#FFFFFF#E1B26C"

/obj/item/clothing/suit/costume/wellworn_shirt/wornout
	name = "worn-out shirt"
	desc = "A pretty grubby, yet still comfortable t-shirt. You've been sleeping in this one for a bit too long."
	icon_state = "/obj/item/clothing/suit/costume/wellworn_shirt/wornout"
	post_init_icon_state = "wornout_shirt"

/obj/item/clothing/suit/costume/wellworn_shirt/wornout/graphic
	name = "worn-out graphic shirt"
	desc = "A pretty grubby, yet still comfortable t-shirt with a character from Phanic the Weasel on the front. The slightly raggedy nature recalls that one horrid title where they made him a vampire. You should get cheevos for sleeping in it this many days straight."
	greyscale_colors = "#FFFFFF#46B45B"
	icon_state = "/obj/item/clothing/suit/costume/wellworn_shirt/wornout/graphic"
	post_init_icon_state = "wornout_shirt_gamer"
	greyscale_config = /datum/greyscale_config/wornout_shirt_graphic
	greyscale_config_worn = /datum/greyscale_config/wornout_shirt_graphic/worn

/obj/item/clothing/suit/costume/wellworn_shirt/wornout/graphic/ian
	name = "worn-out ian shirt"
	desc = "A pretty grubby, yet still comfortable t-shirt with a picture of Ian the Corgi. It's gone past 'a bit worn' to 'well-loved;' excellent for use as pajamas."
	icon_state = "/obj/item/clothing/suit/costume/wellworn_shirt/wornout/graphic/ian"
	post_init_icon_state = "wornout_shirt_ian"
	greyscale_colors = "#FFFFFF#E1B26C"

/obj/item/clothing/suit/costume/wellworn_shirt/messy
	name = "messy worn-out shirt"
	desc = "This worn-out, somehow comfortable t-shirt has reached a more thorough understanding of grime; maybe the fact that it's still gone unwashed could function as a sort of camo?"
	icon_state = "/obj/item/clothing/suit/costume/wellworn_shirt/messy"
	post_init_icon_state = "messyworn_shirt"

/obj/item/clothing/suit/costume/wellworn_shirt/messy/graphic
	name = "messy graphic shirt"
	desc = "This worn-out, somehow comfortable t-shirt has reached a more thorough understanding of grime. Normies will never understand that this is a collector's item, and your sense of fashion absolutely mogs theirs. Phanic Phorever."
	icon_state = "/obj/item/clothing/suit/costume/wellworn_shirt/messy/graphic"
	post_init_icon_state = "messyworn_shirt_gamer"
	greyscale_config = /datum/greyscale_config/messyworn_shirt_graphic
	greyscale_config_worn = /datum/greyscale_config/messyworn_shirt_graphic/worn
	greyscale_colors = "#FFFFFF#46B45B"

/obj/item/clothing/suit/costume/wellworn_shirt/messy/graphic/ian
	name = "messy ian shirt"
	desc = "This worn-out, somehow comfortable t-shirt has reached a more thorough understanding of grime. You get the feeling like you understand how it's like to be a stray dog, yet Ian's face still comforts you."
	icon_state = "/obj/item/clothing/suit/costume/wellworn_shirt/messy/graphic/ian"
	post_init_icon_state = "messyworn_shirt_ian"
	greyscale_colors = "#FFFFFF#E1B26C"

/obj/item/clothing/suit/costume/wellworn_shirt/messy/graphic/gamer
	name = "gamer shirt"
	desc = "A baggy, extremely well-used shirt with vintage game character Phanic the Weasel far-too-boldly displayed on the chest. Your mind cannot hope to withstand the assault of remembering the Phanic Phanart you've seen; let alone the stench of this top."
