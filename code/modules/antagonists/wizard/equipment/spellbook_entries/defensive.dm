#define SPELLBOOK_CATEGORY_DEFENSIVE "Defensive"
// Defensive wizard spells
/datum/spellbook_entry/magicm
	name = "Magic Missile"
	desc = "Fires several, slow moving, magic projectiles at nearby targets."
	spell_type = /datum/action/cooldown/spell/aoe/magic_missile
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/disabletech
	name = "Disable Tech"
	desc = "Disables all weapons, cameras and most other technology in range."
	spell_type = /datum/action/cooldown/spell/emp/disable_tech
	category = SPELLBOOK_CATEGORY_DEFENSIVE
	cost = 1

/datum/spellbook_entry/repulse
	name = "Repulse"
	desc = "Throws everything around the user away."
	spell_type = /datum/action/cooldown/spell/aoe/repulse/wizard
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/lightning_packet
	name = "Thrown Lightning"
	desc = "Forged from eldrich energies, a packet of pure power, \
		known as a spell packet will appear in your hand, that when thrown will stun the target."
	spell_type = /datum/action/cooldown/spell/conjure_item/spellpacket
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/timestop
	name = "Time Stop"
	desc = "Stops time for everyone except for you, allowing you to move freely \
		while your enemies and even projectiles are frozen."
	spell_type = /datum/action/cooldown/spell/timestop
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/smoke
	name = "Smoke"
	desc = "Spawns a cloud of choking smoke at your location."
	spell_type = /datum/action/cooldown/spell/smoke
	category = SPELLBOOK_CATEGORY_DEFENSIVE
	cost = 1

/datum/spellbook_entry/forcewall
	name = "Force Wall"
	desc = "Create a magical barrier that only you can pass through."
	spell_type = /datum/action/cooldown/spell/forcewall
	category = SPELLBOOK_CATEGORY_DEFENSIVE
	cost = 1

/datum/spellbook_entry/lichdom
	name = "Bind Soul"
	desc = "A dark necromantic pact that can forever bind your soul to an item of your choosing, \
		turning you into an immortal Lich. So long as the item remains intact, you will revive from death, \
		no matter the circumstances. Be wary - with each revival, your body will become weaker, and \
		it will become easier for others to find your item of power."
	spell_type =  /datum/action/cooldown/spell/lichdom
	category = SPELLBOOK_CATEGORY_DEFENSIVE
	no_coexistence_typecache = list(/datum/action/cooldown/spell/splattercasting, /datum/spellbook_entry/perks/wormborn)

/datum/spellbook_entry/chuunibyou
	name = "Chuuni Invocations"
	desc = "Makes all your spells shout invocations, and the invocations become... stupid. You heal slightly after casting a spell."
	spell_type =  /datum/action/cooldown/spell/chuuni_invocations
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/spacetime_dist
	name = "Spacetime Distortion"
	desc = "Entangle the strings of space-time in an area around you, \
		randomizing the layout and making proper movement impossible. The strings vibrate..."
	spell_type = /datum/action/cooldown/spell/spacetime_dist
	category = SPELLBOOK_CATEGORY_DEFENSIVE
	cost = 1

/datum/spellbook_entry/the_traps
	name = "The Traps!"
	desc = "Summon a number of traps around you. They will damage and enrage any enemies that step on them."
	spell_type = /datum/action/cooldown/spell/conjure/the_traps
	category = SPELLBOOK_CATEGORY_DEFENSIVE
	cost = 1

/datum/spellbook_entry/bees
	name = "Lesser Summon Bees"
	desc = "This spell magically kicks a transdimensional beehive, \
		instantly summoning a swarm of bees to your location. These bees are NOT friendly to anyone."
	spell_type = /datum/action/cooldown/spell/conjure/bee
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/duffelbag
	name = "Bestow Cursed Duffel Bag"
	desc = "A curse that firmly attaches a demonic duffel bag to the target's back. \
		The duffel bag will make the person it's attached to take periodical damage \
		if it is not fed regularly, and regardless of whether or not it's been fed, \
		it will slow the person wearing it down significantly."
	spell_type = /datum/action/cooldown/spell/touch/duffelbag
	category = SPELLBOOK_CATEGORY_DEFENSIVE
	cost = 1

/datum/spellbook_entry/item/staffhealing
	name = "Staff of Healing"
	desc = "An altruistic staff that can heal the lame and raise the dead."
	item_path = /obj/item/gun/magic/staff/healing
	cost = 1
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/item/lockerstaff
	name = "Staff of the Locker"
	desc = "A staff that shoots lockers. It eats anyone it hits on its way, leaving a welded locker with your victims behind."
	item_path = /obj/item/gun/magic/staff/locker
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/item/scryingorb
	name = "Scrying Orb"
	desc = "An incandescent orb of crackling energy. Using it will allow you to release your ghost while alive, allowing you to spy upon the station and talk to the deceased. In addition, buying it will permanently grant you X-ray vision."
	item_path = /obj/item/scrying
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/item/wands
	name = "Wand Assortment"
	desc = "A collection of wands that allow for a wide variety of utility. \
		Wands have a limited number of charges, so be conservative with their use. Comes in a handy belt."
	item_path = /obj/item/storage/belt/wands/full
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/item/wands/try_equip_item(mob/living/carbon/human/user, obj/item/to_equip)
	var/was_equipped = user.equip_to_slot_if_possible(to_equip, ITEM_SLOT_BELT, disable_warning = TRUE)
	to_chat(user, span_notice("\A [to_equip.name] has been summoned [was_equipped ? "on your waist" : "at your feet"]."))

/datum/spellbook_entry/item/armor
	name = "Mastercrafted Armor Set"
	desc = "An artefact suit of armor that allows you to cast spells \
		while providing more protection against attacks and the void of space. \
		Also grants a battlemage shield."
	item_path = /obj/item/mod/control/pre_equipped/enchanted
	category = SPELLBOOK_CATEGORY_DEFENSIVE

/datum/spellbook_entry/item/armor/try_equip_item(mob/living/carbon/human/user, obj/item/to_equip)
	var/obj/item/mod/control/mod = to_equip
	var/obj/item/mod/module/storage/storage = locate() in mod.modules
	var/obj/item/back = user.back
	if(back)
		if(!user.dropItemToGround(back))
			return
		for(var/obj/item/item as anything in back.contents)
			item.forceMove(storage)
	if(!user.equip_to_slot_if_possible(mod, mod.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE))
		return
	if(!user.dropItemToGround(user.wear_suit) || !user.dropItemToGround(user.head))
		return
	mod.quick_activation()

/datum/spellbook_entry/item/battlemage_charge
	name = "Battlemage Armour Charges"
	desc = "A powerful defensive rune, it will grant eight additional charges to a battlemage shield."
	item_path = /obj/item/wizard_armour_charge
	category = SPELLBOOK_CATEGORY_DEFENSIVE
	cost = 1

#undef SPELLBOOK_CATEGORY_DEFENSIVE
