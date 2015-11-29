

/obj/item/weapon/banner
	name = "banner"
	icon = 'icons/obj/items.dmi'
	icon_state = "banner"
	item_state = "banner"
	desc = "A banner with Nanotrasen's logo on it."
	var/moralecooldown = 0
	var/moralewait = 600


/obj/item/weapon/banner/attack_self(mob/living/carbon/human/user)
	if(moralecooldown + moralewait > world.time)
		return
	var/side = ""
	if(is_handofgod_redcultist(user))
		side = "red"
	else if (is_handofgod_bluecultist(user))
		side = "blue"

	if(!side)
		return
	user << "<span class='notice'>You increase the morale of your fellows!</span>"
	moralecooldown = world.time

	for(var/mob/living/carbon/human/H in range(4,get_turf(src)))
		if((side == "red") && is_handofgod_redcultist(H) || (side == "blue") && is_handofgod_bluecultist(H))
			H << "<span class='notice'>Your morale is increased by [user]'s banner!</span>"
			H.adjustBruteLoss(-15)
			H.adjustFireLoss(-15)
			H.AdjustStunned(-2)
			H.AdjustWeakened(-2)
			H.AdjustParalysis(-2)


/obj/item/weapon/banner/red
	name = "red banner"
	icon_state = "banner-red"
	item_state = "banner-red"
	desc = "A banner with the logo of the red deity."

/obj/item/weapon/banner/red/examine(mob/user)
	..()
	if(is_handofgod_redcultist(user))
		user << "A banner representing our might against the heretics. We may use it to increase the morale of our fellow members!"
	else if(is_handofgod_bluecultist(user))
		user << "A heretical banner that should be destroyed posthaste."


/obj/item/weapon/banner/blue
	name = "blue banner"
	icon_state = "banner-blue"
	item_state = "banner-blue"
	desc = "A banner with the logo of the blue deity"

/obj/item/weapon/banner/blue/examine(mob/user)
	..()

	if(is_handofgod_redcultist(user))
		user << "A heretical banner that should be destroyed posthaste."
	else if(is_handofgod_bluecultist(user))
		user << "A banner representing our might against the heretics. We may use it to increase the morale of our fellow members!"


/obj/item/weapon/storage/backpack/bannerpack
	name = "nanotrasen banner backpack"
	desc = "It's a backpack with lots of extra room.  A banner with Nanotrasen's logo is attached, that can't be removed."
	max_combined_w_class = 27 //6 more then normal, for the tradeoff of declaring yourself an antag at all times.
	icon_state = "bannerpack"


/obj/item/weapon/storage/backpack/bannerpack/red
	name = "red banner backpack"
	desc = "It's a backpack with lots of extra room.  A red banner is attached, that can't be removed."
	icon_state = "bannerpack-red"


/obj/item/weapon/storage/backpack/bannerpack/blue
	name = "blue banner backpack"
	desc = "It's a backpack with lots of extra room.  A blue banner is attached, that can't be removed."
	icon_state = "bannerpack-blue"



//this is all part of one item set
/obj/item/clothing/suit/armor/plate/crusader
	name = "Crusader's Armour"
	icon_state = "crusader"
	w_class = 4 //bulky
	slowdown = 2.0 //gotta pretend we're balanced.
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	armor = list(melee = 50, bullet = 50, laser = 50, energy = 40, bomb = 60, bio = 0, rad = 0)

/obj/item/clothing/suit/armor/plate/crusader/red
	icon_state = "crusader-red"

/obj/item/clothing/suit/armor/plate/crusader/blue
	icon_state = "crusader-blue"

/obj/item/clothing/suit/armor/plate/crusader/examine(mob/user)
	..()
	if(!is_handofgod_cultist(user))
		user << "Armour that's comprised of metal and cloth."
	else
		user << "Armour that was used to protect from backstabs, gunshots, explosives, and lasers.  The original wearers of this type of armour were trying to avoid being murdered.  Since they're not around anymore, you're not sure if they were successful or not."


/obj/item/clothing/head/helmet/plate/crusader
	name = "Crusader's Hood"
	icon_state = "crusader"
	w_class = 3 //normal
	flags = BLOCKHAIR
	armor = list(melee = 50, bullet = 50, laser = 50, energy = 40, bomb = 60, bio = 0, rad = 0)

/obj/item/clothing/head/helmet/plate/crusader/blue
	icon_state = "crusader-blue"

/obj/item/clothing/head/helmet/plate/crusader/red
	icon_state = "crusader-red"


/obj/item/clothing/head/helmet/plate/crusader/examine(mob/user)
	..()
	if(!is_handofgod_cultist(user))
		user << "A brownish hood."
	else
		user << "A hood that's very protective, despite being made of cloth.  Due to the tendency of the wearer to be targeted for assassinations, being protected from being shot in the face was very important.."



//Prophet helmet
/obj/item/clothing/head/helmet/plate/crusader/prophet
	name = "Prophet's Hat"
	alternate_worn_icon = 'icons/mob/large-worn-icons/64x64/head.dmi'
	flags = 0
	armor = list(melee = 60, bullet = 60, laser = 60, energy = 50, bomb = 70, bio = 50, rad = 50) //religion protects you from disease and radiation, honk.
	worn_x_dimension = 64
	worn_y_dimension = 64
	var/datum/action/innate/godspeak/speak2god


/obj/item/clothing/head/helmet/plate/crusader/prophet/proc/assign_deity(mob/camera/god/G)
	if(speak2god)
		if(speak2god.owner)
			speak2god.Remove(speak2god.owner)
	else
		speak2god = new()
	speak2god.god = G


/obj/item/clothing/head/helmet/plate/crusader/prophet/equipped(mob/user, slot)
	if(slot == slot_head)
		if(speak2god)
			speak2god.Grant(user)
			user << "<span class='boldnotice'>You gain the ability to speak to the god this hat belongs to!</span>"


/obj/item/clothing/head/helmet/plate/crusader/prophet/dropped(mob/user)
	if(speak2god)
		if(speak2god.owner == user)
			speak2god.Remove(user)
			user << "<span class='boldnotice'>You lose the ability to speak to the god this hat belongs to!</span>"


/obj/item/clothing/head/helmet/plate/crusader/prophet/red
	icon_state = "prophet-red"


/obj/item/clothing/head/helmet/plate/crusader/prophet/blue
	icon_state = "prophet-blue"


/obj/item/clothing/head/helmet/plate/crusader/prophet/examine(mob/user)
	..()
	if(!is_handofgod_cultist(user))
		user << "A brownish, religious-looking hat."
	else
		user << "A hat bestowed upon a prophet of gods and demigods."
		if(speak2god && speak2god.god)
			user << "This hat belongs to the [speak2god.god.side] god."



//Structure conversion staff
/obj/item/weapon/godstaff
	name = "godstaff"
	icon_state = "godstaff-red"
	var/mob/camera/god/god = null

/obj/item/weapon/godstaff/examine(mob/user)
	..()
	if(!is_handofgod_cultist(user))
		user << "It's a stick..?"
	else
		user << "A powerful staff capable of changing the allegiance of god/demigod structures."


/obj/item/weapon/godstaff/red
	icon_state = "godstaff-red"

/obj/item/weapon/godstaff/blue
	icon_state = "godstaff-blue"



/obj/item/clothing/gloves/plate
	name = "Plate Gauntlets"
	icon_state = "crusader"
	siemens_coefficient = 0
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT


/obj/item/clothing/gloves/plate/red
	icon_state = "crusader-red"

/obj/item/clothing/gloves/plate/blue
	icon_state = "crusader-blue"


/obj/item/clothing/gloves/plate/examine(mob/user)
	..()
	if(!is_handofgod_cultist(user))
		usr << "They're like gloves, but made of metal."
	else
		usr << "Protective gloves that are also blessed to protect from heat and shock."


/obj/item/clothing/shoes/plate
	name = "Plate Boots"
	icon_state = "crusader"
	w_class = 3 //normal
	armor = list(melee = 50, bullet = 50, laser = 50, energy = 40, bomb = 60, bio = 0, rad = 0) //does this even do anything on boots?
	flags = NOSLIP
	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	heat_protection = FEET
	max_heat_protection_temperature = SHOES_MAX_TEMP_PROTECT


/obj/item/clothing/shoes/plate/red
	icon_state = "crusader-red"

/obj/item/clothing/shoes/plate/blue
	icon_state = "crusader-blue"


/obj/item/clothing/shoes/plate/examine(mob/user)
	..()
	if(!is_handofgod_cultist(user))
		usr << "Metal boots, they look heavy."
	else
		usr << "Heavy boots that are blessed for sure footing.  You'll be safe from being taken down by the heresy that is the banana peel."


/obj/item/weapon/storage/box/itemset/crusader
	name = "Crusader's Armour Set" //i can't into ck2 references
	desc = "This armour is said to be based on the armor of kings on another world thousands of years ago, who tended to assassinate, conspire, and plot against everyone who tried to do the same to them.  Some things never change."


/obj/item/weapon/storage/box/itemset/crusader/blue/New()
	..()
	contents = list()
	sleep(1)
	new /obj/item/clothing/suit/armor/plate/crusader/blue(src)
	new /obj/item/clothing/head/helmet/plate/crusader/blue(src)
	new /obj/item/clothing/gloves/plate/blue(src)
	new /obj/item/clothing/shoes/plate/blue(src)


/obj/item/weapon/storage/box/itemset/crusader/red/New()
	..()
	contents = list()
	sleep(1)
	new /obj/item/clothing/suit/armor/plate/crusader/red(src)
	new /obj/item/clothing/head/helmet/plate/crusader/red(src)
	new /obj/item/clothing/gloves/plate/red(src)
	new /obj/item/clothing/shoes/plate/red(src)


/obj/item/weapon/claymore/hog
	force = 30
	armour_penetration = 15