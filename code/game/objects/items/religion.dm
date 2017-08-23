/obj/item/banner
	name = "banner"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "banner"
	item_state = "banner"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	desc = "A banner with Nanotrasen's logo on it."
	var/moralecooldown = 0
	var/moralewait = 600

/obj/item/banner/attack_self(mob/living/carbon/human/user)
	if(moralecooldown + moralewait > world.time)
		return
	to_chat(user, "<span class='notice'>You increase the morale of your fellows!</span>")
	moralecooldown = world.time

	for(var/mob/living/carbon/human/H in range(4,get_turf(src)))
		to_chat(H, "<span class='notice'>Your morale is increased by [user]'s banner!</span>")
		H.adjustBruteLoss(-15)
		H.adjustFireLoss(-15)
		H.AdjustStun(-40)
		H.AdjustKnockdown(-40)
		H.AdjustUnconscious(-40)

/obj/item/banner/red
	name = "red banner"
	icon_state = "banner-red"
	item_state = "banner-red"
	desc = "A banner with the logo of the red deity."

/obj/item/banner/blue
	name = "blue banner"
	icon_state = "banner-blue"
	item_state = "banner-blue"
	desc = "A banner with the logo of the blue deity"

/obj/item/storage/backpack/bannerpack
	name = "nanotrasen banner backpack"
	desc = "It's a backpack with lots of extra room.  A banner with Nanotrasen's logo is attached, that can't be removed."
	max_combined_w_class = 27 //6 more then normal, for the tradeoff of declaring yourself an antag at all times.
	icon_state = "bannerpack"

/obj/item/storage/backpack/bannerpack/red
	name = "red banner backpack"
	desc = "It's a backpack with lots of extra room.  A red banner is attached, that can't be removed."
	icon_state = "bannerpack-red"

/obj/item/storage/backpack/bannerpack/blue
	name = "blue banner backpack"
	desc = "It's a backpack with lots of extra room.  A blue banner is attached, that can't be removed."
	icon_state = "bannerpack-blue"

//this is all part of one item set
/obj/item/clothing/suit/armor/plate/crusader
	name = "Crusader's Armour"
	desc = "Armour that's comprised of metal and cloth."
	icon_state = "crusader"
	w_class = WEIGHT_CLASS_BULKY
	slowdown = 2.0 //gotta pretend we're balanced.
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor = list(melee = 50, bullet = 50, laser = 50, energy = 40, bomb = 60, bio = 0, rad = 0, fire = 60, acid = 60)

/obj/item/clothing/suit/armor/plate/crusader/red
	icon_state = "crusader-red"

/obj/item/clothing/suit/armor/plate/crusader/blue
	icon_state = "crusader-blue"

/obj/item/clothing/head/helmet/plate/crusader
	name = "Crusader's Hood"
	desc = "A brownish hood."
	icon_state = "crusader"
	w_class = WEIGHT_CLASS_NORMAL
	flags_inv = HIDEHAIR|HIDEEARS|HIDEFACE
	armor = list(melee = 50, bullet = 50, laser = 50, energy = 40, bomb = 60, bio = 0, rad = 0, fire = 60, acid = 60)

/obj/item/clothing/head/helmet/plate/crusader/blue
	icon_state = "crusader-blue"

/obj/item/clothing/head/helmet/plate/crusader/red
	icon_state = "crusader-red"

//Prophet helmet
/obj/item/clothing/head/helmet/plate/crusader/prophet
	name = "Prophet's Hat"
	desc = "A religious-looking hat."
	alternate_worn_icon = 'icons/mob/large-worn-icons/64x64/head.dmi'
	flags = 0
	armor = list(melee = 60, bullet = 60, laser = 60, energy = 50, bomb = 70, bio = 50, rad = 50, fire = 60, acid = 60) //religion protects you from disease and radiation, honk.
	worn_x_dimension = 64
	worn_y_dimension = 64

/obj/item/clothing/head/helmet/plate/crusader/prophet/red
	icon_state = "prophet-red"

/obj/item/clothing/head/helmet/plate/crusader/prophet/blue
	icon_state = "prophet-blue"

//Structure conversion staff
/obj/item/godstaff
	name = "godstaff"
	desc = "It's a stick..?"
	icon_state = "godstaff-red"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	var/conversion_color = "#ffffff"
	var/staffcooldown = 0
	var/staffwait = 30


/obj/item/godstaff/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(staffcooldown + staffwait > world.time)
		return
	user.visible_message("[user] chants deeply and waves their staff!")
	if(do_after(user, 20,1,src))
		target.add_atom_colour(conversion_color, WASHABLE_COLOUR_PRIORITY) //wololo
	staffcooldown = world.time

/obj/item/godstaff/red
	icon_state = "godstaff-red"
	conversion_color = "#ff0000"

/obj/item/godstaff/blue
	icon_state = "godstaff-blue"
	conversion_color = "#0000ff"

/obj/item/clothing/gloves/plate
	name = "Plate Gauntlets"
	icon_state = "crusader"
	desc = "They're like gloves, but made of metal."
	siemens_coefficient = 0
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT

/obj/item/clothing/gloves/plate/red
	icon_state = "crusader-red"

/obj/item/clothing/gloves/plate/blue
	icon_state = "crusader-blue"

/obj/item/clothing/shoes/plate
	name = "Plate Boots"
	desc = "Metal boots, they look heavy."
	icon_state = "crusader"
	w_class = WEIGHT_CLASS_NORMAL
	armor = list(melee = 50, bullet = 50, laser = 50, energy = 40, bomb = 60, bio = 0, rad = 0, fire = 60, acid = 60) //does this even do anything on boots?
	flags = NOSLIP
	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT


/obj/item/clothing/shoes/plate/red
	icon_state = "crusader-red"

/obj/item/clothing/shoes/plate/blue
	icon_state = "crusader-blue"


/obj/item/storage/box/itemset/crusader
	name = "Crusader's Armour Set" //i can't into ck2 references
	desc = "This armour is said to be based on the armor of kings on another world thousands of years ago, who tended to assassinate, conspire, and plot against everyone who tried to do the same to them.  Some things never change."


/obj/item/storage/box/itemset/crusader/blue/New()
	..()
	contents = list()
	sleep(1)
	new /obj/item/clothing/suit/armor/plate/crusader/blue(src)
	new /obj/item/clothing/head/helmet/plate/crusader/blue(src)
	new /obj/item/clothing/gloves/plate/blue(src)
	new /obj/item/clothing/shoes/plate/blue(src)


/obj/item/storage/box/itemset/crusader/red/New()
	..()
	contents = list()
	sleep(1)
	new /obj/item/clothing/suit/armor/plate/crusader/red(src)
	new /obj/item/clothing/head/helmet/plate/crusader/red(src)
	new /obj/item/clothing/gloves/plate/red(src)
	new /obj/item/clothing/shoes/plate/red(src)


/obj/item/claymore/weak
	desc = "This one is rusted."
	force = 30
	armour_penetration = 15
