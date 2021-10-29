//////////////////////////////////////////////////////////////////////////////
//////////////////////// Emergency Race Stuff ////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/goody/airsuppliesnitrogen
	name = "Emergency Air Supplies (Nitrogen)"
	desc = "A vox breathing mask and nitrogen tank."
	cost = PAYCHECK_MEDIUM
	contains = list(/obj/item/tank/internals/nitrogen/belt,
                    /obj/item/clothing/mask/breath/vox)

/datum/supply_pack/goody/airsuppliesoxygen
	name = "Emergency Air Supplies (Oxygen)"
	desc = "A breathing mask and emergency oxygen tank."
	cost = PAYCHECK_MEDIUM
	contains = list(/obj/item/tank/internals/emergency_oxygen,
                    /obj/item/clothing/mask/breath)

/datum/supply_pack/goody/airsuppliesplasma
	name = "Emergency Air Supplies (Plasma)"
	desc = "A breathing mask and plasmaman plasma tank."
	cost = PAYCHECK_MEDIUM
	contains = list(/obj/item/tank/internals/plasmaman/belt,
                    /obj/item/clothing/mask/breath)

//////////////////////////////////////////////////////////////////////////////
///////////////////////////// Misc Stuff /////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/goody/crayons
	name = "Box of Crayons"
	desc = "Colorful!"
	cost = PAYCHECK_MEDIUM * 2
	contains = list(/obj/item/storage/crayons)

/datum/supply_pack/goody/diamondring
	name = "Diamond Ring"
	desc = "Show them your love is like a diamond: unbreakable and everlasting. No refunds."
	cost = PAYCHECK_MEDIUM * 50
	contains = list(/obj/item/storage/fancy/ringbox/diamond)
	crate_name = "diamond ring crate"

/datum/supply_pack/goody/paperbin
	name = "Paper Bin"
	desc = "Pushing paperwork is always easier when you have paper to push!"
	cost = PAYCHECK_MEDIUM * 4
	contains = list(/obj/item/paper_bin)

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Weapons or Ammo /////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/goody/makarov
	name = "Makarov Self Defense Pistol"
	desc = "A small, slow firing and low capacity pistol, but hey, it's better then a crowbar, right? (Does not include a weapons permit.)"
	cost = PAYCHECK_MEDIUM * 28
	contraband = TRUE
	contains = list(/obj/item/storage/box/gunset/makarov)

/datum/supply_pack/goody/pepperball
	name = "PepperBall Self Defense Weapon"
	desc = "A 'state of the art' self defense weapon, firing balls of condensed pepperspray, don't aim for the face."
	cost = PAYCHECK_MEDIUM * 17
	contains = list(/obj/item/storage/box/gunset/pepperball)

/datum/supply_pack/goody/gunmaint
	name = "Gun Maintenance Kits"
	desc = "Keep your pa's rifle in best condition, with two sets of cleaning supplies. Or your standard issue pistol if you're an itchy trigger, we're not here to judge."
	cost = PAYCHECK_MEDIUM * 3
	contains = list(/obj/item/gun_maintenance_supplies,
					/obj/item/gun_maintenance_supplies)

//////////////////////////////////////////////////////////////////////////////
//////////////////////////// Carpet Packs ////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////

/datum/supply_pack/goody/carpet
	name = "Classic Carpet Single-Pack"
	desc = "Plasteel floor tiles getting on your nerves? This 50 units stack of extra soft carpet will tie any room together."
	cost = PAYCHECK_MEDIUM * 3
	contains = list(/obj/item/stack/tile/carpet/fifty)

/datum/supply_pack/goody/carpet/black
	name = "Black Carpet Single-Pack"
	contains = list(/obj/item/stack/tile/carpet/black/fifty)

/datum/supply_pack/goody/carpet/premium
	name = "Royal Black Carpet Single-Pack"
	desc = "Exotic carpets for all your decorating needs. This 50 unit stack of extra soft carpet will tie any room together."
	cost = PAYCHECK_MEDIUM * 3.5
	contains = list(/obj/item/stack/tile/carpet/royalblack/fifty)

/datum/supply_pack/goody/carpet/premium/royalblue
	name = "Royal Blue Carpet Single-Pack"
	contains = list(/obj/item/stack/tile/carpet/royalblue/fifty)

/datum/supply_pack/goody/carpet/premium/red
	name = "Red Carpet Single-Pack"
	contains = list(/obj/item/stack/tile/carpet/red/fifty)

/datum/supply_pack/goody/carpet/premium/purple
	name = "Purple Carpet Single-Pack"
	contains = list(/obj/item/stack/tile/carpet/purple/fifty)

/datum/supply_pack/goody/carpet/premium/orange
	name = "Orange Carpet Single-Pack"
	contains = list(/obj/item/stack/tile/carpet/orange/fifty)

/datum/supply_pack/goody/carpet/premium/green
	name = "Green Carpet Single-Pack"
	contains = list(/obj/item/stack/tile/carpet/green/fifty)

/datum/supply_pack/goody/carpet/premium/cyan
	name = "Cyan Carpet Single-Pack"
	contains = list(/obj/item/stack/tile/carpet/cyan/fifty)

/datum/supply_pack/goody/carpet/premium/blue
	name = "Blue Carpet Single-Pack"
	contains = list(/obj/item/stack/tile/carpet/blue/fifty)
