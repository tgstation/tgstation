/datum/uplink_item/role_restricted/bag_of_encounters
	name = "Bag of Encounters"
	desc = "An inconspicious bag of dice, recovered from a Space Wizard's dungeon. Each dice within will summon a challenge for the crew: 1d4 Bears, 1d6 Space Carp or 1d20 angry Bees!\
			Be sure to give the bag a shake before use, so that the creatures will recognise you as their true dungeon master, no matter who rolls the dice."
	item = /obj/item/storage/pill_bottle/encounter_dice
	cost = 8
	restricted_roles = list("Curator")
	limited_stock = 1 //for testing at least


/datum/uplink_item/badass/balloongold
	name = "Golden Syndicate Balloons"
	desc = "For showing that you and two other Syndies are true genuine 100% BAD ASS SYNDIES."
	item = /obj/item/storage/box/syndieballoons
	cost = 60
	cant_discount = TRUE
	illegal_tech = FALSE

/datum/uplink_item/role_restricted/susp_bowler
	name = "Suspicious Bowler"
	desc = "A strange, deep black bowler with an extremely sharp, weighted brim. The material used to make the brim of the bowler allows for it to pierce armor, often embeding within the designated target."
	item = /obj/item/clothing/head/susp_bowler
	cost = 5
	cant_discount = FALSE
	illegal_tech = TRUE
	restricted_roles = list("Bartender")

/datum/uplink_item/role_restricted/mech_firing_pin
	name = "Concealed Weapon Bay (Mech Firing Pin Included)"
	desc = "A concealed weapon bay that hides an equipped mech weapon from plain sight. \
			Only one can fit on a mecha. \
			This one comes complete with a handy firing pin that can only be installed into mech weapons."
	item = /obj/item/storage/box/syndicate/bundle_mech
	cost = 7 //So you cannot use it to get 3 unlocked mech weapons.
	restricted_roles = list("Roboticist", "Research Director")

/datum/uplink_item/role_restricted/sith_starter_kit
	name = "Sith Starter Kit"
	desc = "Has everything you need to get started with the Dark Side! \
			Includes smelly old man robes, snazzy red light saber and genuine Sith sacred texts \
			describing the secrets of saber fighting, force lightning and force push."
	item = /obj/item/storage/box/syndicate/bundle_sith
	cost = 19
	restricted_roles = list("Chaplain", "Curator")

/datum/uplink_item/role_restricted/laser_tag_kit_red
	name = "X-TREME Laser Tag Kit (RADICAL RED)"
	desc = "New X-TREME laser tag kit for when you want to play for keeps! \
			Now with SUPER stun and RADICAL lethal mode! \
			Comes complete with gun and reflective laser vest. Adult supervision recommended. \
			Swipe gun with ID to toggle state of the art stealth parental locks!"
	item = /obj/item/storage/box/syndicate/laser_tag_kit_red
	cost = 14
	restricted_roles = list("Clown", "Mime", "Assistant")

/datum/uplink_item/role_restricted/laser_tag_kit_blue
	name = "X-TREME Laser Tag Kit (BITCHIN' BLUE)"
	desc = "New X-TREME laser tag kit for when you want to play for keeps! \
			Now with SUPER stun and RADICAL lethal mode! \
			Comes complete with gun and reflective laser vest. Adult supervision recommended. \
			Swipe gun with ID to toggle state of the art stealth parental locks!"
	item = /obj/item/storage/box/syndicate/laser_tag_kit_blue
	cost = 14
	restricted_roles = list("Clown", "Mime", "Assistant")

/datum/uplink_item/role_restricted/laser_tag_partypack_red
	name = "X-TREME Laser Tag Party Pack (RADICAL RED)"
	desc = "The new X-TREME laser tag party pack is deadly fun for the whole family! \
			Now with SUPER stun and RADICAL lethal mode! \
			Comes complete with 4 guns and reflective laser vests. Adult supervision recommended. \
			Swipe gun with ID to toggle state of the art stealth parental locks!"
	include_modes = list(/datum/game_mode/nuclear/clown_ops)
	item = /obj/structure/closet/crate/laser_tag_partypack_red
	cost = 50

/datum/uplink_item/role_restricted/laser_tag_partypack_blue
	name = "X-TREME Laser Tag Party Pack (BITCHIN' BLUE)"
	desc = "The new X-TREME laser tag party pack is deadly fun for the whole family! \
			Now with SUPER stun and RADICAL lethal mode! \
			Comes complete with 4 guns and reflective laser vests. Adult supervision recommended. \
			Swipe gun with ID to toggle state of the art stealth parental locks!"
	include_modes = list(/datum/game_mode/nuclear/clown_ops)
	item = /obj/structure/closet/crate/laser_tag_partypack_blue
	cost = 50

/datum/uplink_item/device_tools/budget_emag
	name = "Budget Cryptographic Sequencer"
	desc = "The cryptographic sequencer, electromagnetic card, or emag, is a small card that unlocks hidden functions \
			in electronic devices, subverts intended functions, and easily breaks security mechanisms.  \
			This is a cheap knockoff Space-China budget version that holds 2 charges, and regains 1 charge every 30 seconds."
	item = /obj/item/card/emag/budget
	cost = 6