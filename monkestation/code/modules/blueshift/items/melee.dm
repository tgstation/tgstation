// Sabres, including the cargo variety

/obj/item/storage/belt/sabre/cargo
	name = "authentic shamshir leather sheath"
	desc = "A good-looking sheath that is advertised as being made of real Venusian black leather. It feels rather plastic-like to the touch, and it looks like it's made to fit a British cavalry sabre."
	icon = 'monkestation/code/modules/blueshift/icons/obj/clothing/belts.dmi'
	worn_icon = 'monkestation/code/modules/blueshift/icons/mob/clothing/belt.dmi'

/obj/item/storage/belt/sabre/cargo/PopulateContents()
	new /obj/item/melee/sabre/cargo(src)
	update_appearance()

/obj/item/melee/sabre
	force = 20 // Original: 15
	wound_bonus = 5 // Original: 10
	bare_wound_bonus = 20 // Original: 25 Both down slightly, to make up for the damage buff, since it'd get a bit wacky ontop of the armor pen.

/obj/item/melee/sabre/cargo
	name = "authentic shamshir sabre"
	desc = "An expertly crafted historical human sword once used by the Persians which has recently gained traction due to Venusian historal recreation sports. One small flaw, the Taj-based company who produces these has mistaken them for British cavalry sabres akin to those used by high ranking Nanotrasen officials. Atleast it cuts the same way!"
	icon = 'monkestation/code/modules/blueshift/icons/obj/melee.dmi'
	//lefthand_file = 'monkestation/code/modules/blueshift/icons/mob/inhands/weapons/swords_lefthand.dmi'
	//righthand_file = 'monkestation/code/modules/blueshift/icons/mob/inhands/weapons/swords_righthand.dmi'
	block_chance = 20
	armour_penetration = 25


// This is here so that people can't buy the Sabres and craft them into powercrepes
/datum/crafting_recipe/food/powercrepe
	blacklist = list(/obj/item/melee/sabre/cargo)
