
//Bartender
/obj/item/clothing/head/chefhat
	name = "chef's hat"
	desc = "It's a hat used by chefs to keep hair out of your food. Judging by the food in the mess, they don't work."
	icon_state = "chef"
	item_state = "chef"
	desc = "The commander in chef's head wear."

//Captain
/obj/item/clothing/head/caphat
	name = "captain's hat"
	desc = "It's good being the king."
	icon_state = "captain"
	item_state = "that"
	flags_inv = 0
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)

//Captain: This is no longer space-worthy
/obj/item/clothing/head/caphat/parade
	name = "captain's parade cap"
	desc = "Worn only by Captains with an abundance of class."
	icon_state = "capcap"


//Head of Personnel
/obj/item/clothing/head/hopcap
	name = "head of personnel's cap"
	icon_state = "hopcap"
	desc = "The symbol of true bureaucratic micromanagement."
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)

//Chaplain
/obj/item/clothing/head/chaplain_hood
	name = "chaplain's hood"
	desc = "It's hood that covers the head. It keeps you warm during the space winters."
	icon_state = "chaplain_hood"
	flags = HEADCOVERSEYES|BLOCKHAIR

//Chaplain
/obj/item/clothing/head/nun_hood
	name = "nun hood"
	desc = "Maximum piety in this star system."
	icon_state = "nun_hood"
	flags = HEADCOVERSEYES|BLOCKHAIR

/obj/item/clothing/head/det_hat
	name = "detective's fedora"
	desc = "There's only one man who can sniff out the dirty stench of crime, and he's likely wearing this hat."
	icon_state = "detective"
	allowed = list(/obj/item/weapon/reagent_containers/food/snacks/candy_corn, /obj/item/weapon/pen)
	armor = list(melee = 50, bullet = 5, laser = 25, energy = 10, bomb = 0, bio = 0, rad = 0)

//Mime
/obj/item/clothing/head/beret
	name = "beret"
	desc = "A beret, a mime's favorite headwear."
	icon_state = "beret"

//Security

/obj/item/clothing/head/HoS
	name = "head of security hat"
	desc = "The robust hat of the Head of Security. For showing the officers who's in charge."
	icon_state = "hoscap"
	armor = list(melee = 80, bullet = 60, laser = 50, energy = 10, bomb = 25, bio = 10, rad = 0)
	flags = 0
	flags_inv = HIDEEARS

/obj/item/clothing/head/HoS/dermal
	name = "Dermal Armor Patch"
	desc = "An armored implant that automatically integrates just below the scalp for robust protection without sacrificing style."
	icon_state = "dermal"
	item_state = "dermal"
	flags_inv = 0

/obj/item/clothing/head/warden
	name = "warden's hat"
	desc = "It's a special armored hat issued to the Warden of a security force. Protects the head from impacts."
	icon_state = "policehelm"
	armor = list(melee = 60, bullet = 5, laser = 25, energy = 10, bomb = 25, bio = 0, rad = 0)
	flags = 0
	flags_inv = HIDEEARS

/obj/item/clothing/head/beret/sec
	name = "security beret"
	desc = "A robust beret with the security insignia emblazoned on it. For officers that are more inclined towards style than safety."
	icon_state = "beret_badge"
	armor = list(melee = 30, bullet = 5, laser = 15, energy = 10, bomb = 0, bio = 0, rad = 0)

/obj/item/clothing/head/beret/sec/navyhos
	name = "head of security's beret"
	desc = "A special beret with the Head of Security's insignia emblazoned on it. A symbol of excellence, a badge of courage, a mark of distinction."
	icon_state = "hosberet"

/obj/item/clothing/head/beret/sec/navywarden
	name = "warden's beret"
	desc = "A special beret with the Warden's insignia emblazoned on it. For wardens with class."
	icon_state = "wardenberet"

/obj/item/clothing/head/beret/sec/navyofficer
	desc = "A special beret with the security insignia emblazoned on it. For officers with class."
	icon_state = "officerberet"
