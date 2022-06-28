/datum/spellbook_entry
	var/name = "Entry Name"

	var/spell_type = null
	var/desc = ""
	var/category = "Offensive"
	var/cost = 2
	var/times = 0
	var/refundable = TRUE
	var/obj/effect/proc_holder/spell/S = null //Since spellbooks can be used by only one person anyway we can track the actual spell
	var/buy_word = "Learn"
	var/cooldown
	var/clothes_req = FALSE
	var/limit //used to prevent a spellbook_entry from being bought more than X times with one wizard spellbook
	var/list/no_coexistance_typecache //Used so you can't have specific spells together

/datum/spellbook_entry/New()
	..()
	no_coexistance_typecache = typecacheof(no_coexistance_typecache)

/datum/spellbook_entry/proc/IsAvailable() // For config prefs / gamemode restrictions - these are round applied
	return TRUE

/datum/spellbook_entry/proc/CanBuy(mob/living/carbon/human/user,obj/item/spellbook/book) // Specific circumstances
	if(book.uses<cost || limit == 0)
		return FALSE
	for(var/spell in user.mind.spell_list)
		if(is_type_in_typecache(spell, no_coexistance_typecache))
			return FALSE
	return TRUE

/datum/spellbook_entry/proc/Buy(mob/living/carbon/human/user,obj/item/spellbook/book) //return TRUE on success
	if(!S || QDELETED(S))
		S = new spell_type()
	//Check if we got the spell already
	for(var/obj/effect/proc_holder/spell/aspell in user.mind.spell_list)
		if(initial(S.name) != initial(aspell.name)) // Not using directly in case it was learned from one spellbook then upgraded in another
			continue
		if(aspell.spell_level >= aspell.level_max)
			to_chat(user,  span_warning("This spell cannot be improved further!"))
			return FALSE

		aspell.name = initial(aspell.name)
		aspell.spell_level++
		aspell.charge_max = round(LERP(initial(aspell.charge_max), aspell.cooldown_min, aspell.spell_level / aspell.level_max))
		if(aspell.charge_max < aspell.charge_counter)
			aspell.charge_counter = aspell.charge_max
		var/newname = "ERROR"
		switch(aspell.spell_level)
			if(1)
				to_chat(user, span_notice("You have improved [aspell.name] into Efficient [aspell.name]."))
				newname = "Efficient [aspell.name]"
			if(2)
				to_chat(user, span_notice("You have further improved [aspell.name] into Quickened [aspell.name]."))
				newname = "Quickened [aspell.name]"
			if(3)
				to_chat(user, span_notice("You have further improved [aspell.name] into Free [aspell.name]."))
				newname = "Free [aspell.name]"
			if(4)
				to_chat(user, span_notice("You have further improved [aspell.name] into Instant [aspell.name]."))
				newname = "Instant [aspell.name]"
		aspell.name = newname
		name = newname
		if(aspell.spell_level >= aspell.level_max)
			to_chat(user, span_warning("This spell cannot be strengthened any further!"))
		//we'll need to update the cooldowns for the spellbook
		GetInfo()
		log_spellbook("[key_name(user)] improved their knowledge of [src] to level [aspell.spell_level] for [cost] points")
		SSblackbox.record_feedback("nested tally", "wizard_spell_improved", 1, list("[name]", "[aspell.spell_level]"))
		return TRUE
	//No same spell found - just learn it
	log_spellbook("[key_name(user)] learned [src] for [cost] points")
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	user.mind.AddSpell(S)
	to_chat(user, span_notice("You have learned [S.name]."))
	return TRUE

/datum/spellbook_entry/proc/CanRefund(mob/living/carbon/human/user,obj/item/spellbook/book)
	if(!refundable)
		return FALSE
	if(!book.can_refund)
		return FALSE
	if(!S)
		S = new spell_type()
	for(var/obj/effect/proc_holder/spell/aspell in user.mind.spell_list)
		if(initial(S.name) == initial(aspell.name))
			return TRUE
	return FALSE

/datum/spellbook_entry/proc/Refund(mob/living/carbon/human/user,obj/item/spellbook/book) //return point value or -1 for failure
	var/area/centcom/wizard_station/A = GLOB.areas_by_type[/area/centcom/wizard_station]
	if(!(user in A.contents))
		to_chat(user, span_warning("You can only refund spells at the wizard lair!"))
		return -1
	if(!S)
		S = new spell_type()
	var/spell_levels = 0
	for(var/obj/effect/proc_holder/spell/aspell in user.mind.spell_list)
		if(initial(S.name) == initial(aspell.name))
			spell_levels = aspell.spell_level
			user.mind.spell_list.Remove(aspell)
			name = initial(name)
			log_spellbook("[key_name(user)] refunded [src] for [cost * (spell_levels+1)] points")
			qdel(S)
			return cost * (spell_levels+1)
	return -1


/datum/spellbook_entry/proc/GetInfo()
	if(!spell_type)
		return
	if(!S)
		S = new spell_type()
	if(S.charge_type == "recharge")
		cooldown = S.charge_max/10
	if(S.clothes_req)
		clothes_req = TRUE

/datum/spellbook_entry/fireball
	name = "Fireball"
	desc = "Fires an explosive fireball at a target. Considered a classic among all wizards."
	spell_type = /obj/effect/proc_holder/spell/aimed/fireball

/datum/spellbook_entry/spell_cards
	name = "Spell Cards"
	desc = "Blazing hot rapid-fire homing cards. Send your foes to the shadow realm with their mystical power!"
	spell_type = /obj/effect/proc_holder/spell/aimed/spell_cards

/datum/spellbook_entry/rod_form
	name = "Rod Form"
	desc = "Take on the form of an immovable rod, destroying all in your path. Purchasing this spell multiple times will also increase the rod's damage and travel range."
	spell_type = /obj/effect/proc_holder/spell/targeted/rod_form

/datum/spellbook_entry/magicm
	name = "Magic Missile"
	desc = "Fires several, slow moving, magic projectiles at nearby targets."
	spell_type = /obj/effect/proc_holder/spell/targeted/projectile/magic_missile
	category = "Defensive"

/datum/spellbook_entry/disintegrate
	name = "Smite"
	desc = "Charges your hand with an unholy energy that can be used to cause a touched victim to violently explode."
	spell_type = /obj/effect/proc_holder/spell/targeted/touch/disintegrate

/datum/spellbook_entry/disabletech
	name = "Disable Tech"
	desc = "Disables all weapons, cameras and most other technology in range."
	spell_type = /obj/effect/proc_holder/spell/targeted/emplosion/disable_tech
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/repulse
	name = "Repulse"
	desc = "Throws everything around the user away."
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/repulse
	category = "Defensive"

/datum/spellbook_entry/lightning_packet
	name = "Thrown Lightning"
	desc = "Forged from eldrich energies, a packet of pure power, known as a spell packet will appear in your hand, that when thrown will stun the target."
	spell_type = /obj/effect/proc_holder/spell/targeted/conjure_item/spellpacket
	category = "Defensive"

/datum/spellbook_entry/timestop
	name = "Time Stop"
	desc = "Stops time for everyone except for you, allowing you to move freely while your enemies and even projectiles are frozen."
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/timestop
	category = "Defensive"

/datum/spellbook_entry/smoke
	name = "Smoke"
	desc = "Spawns a cloud of choking smoke at your location."
	spell_type = /obj/effect/proc_holder/spell/targeted/smoke
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/blind
	name = "Blind"
	desc = "Temporarily blinds a single target."
	spell_type = /obj/effect/proc_holder/spell/pointed/trigger/blind
	cost = 1

/datum/spellbook_entry/mindswap
	name = "Mindswap"
	desc = "Allows you to switch bodies with a target next to you. You will both fall asleep when this happens, and it will be quite obvious that you are the target's body if someone watches you do it."
	spell_type = /obj/effect/proc_holder/spell/pointed/mind_transfer
	category = "Mobility"

/datum/spellbook_entry/forcewall
	name = "Force Wall"
	desc = "Create a magical barrier that only you can pass through."
	spell_type = /obj/effect/proc_holder/spell/targeted/forcewall
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/blink
	name = "Blink"
	desc = "Randomly teleports you a short distance."
	spell_type = /obj/effect/proc_holder/spell/targeted/turf_teleport/blink
	category = "Mobility"

/datum/spellbook_entry/teleport
	name = "Teleport"
	desc = "Teleports you to an area of your selection."
	spell_type = /obj/effect/proc_holder/spell/targeted/area_teleport/teleport
	category = "Mobility"

/datum/spellbook_entry/mutate
	name = "Mutate"
	desc = "Causes you to turn into a hulk and gain laser vision for a short while."
	spell_type = /obj/effect/proc_holder/spell/targeted/genetic/mutate

/datum/spellbook_entry/jaunt
	name = "Ethereal Jaunt"
	desc = "Turns your form ethereal, temporarily making you invisible and able to pass through walls."
	spell_type = /obj/effect/proc_holder/spell/targeted/ethereal_jaunt
	category = "Mobility"

/datum/spellbook_entry/knock
	name = "Knock"
	desc = "Opens nearby doors and closets."
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/knock
	category = "Mobility"
	cost = 1

/datum/spellbook_entry/fleshtostone
	name = "Flesh to Stone"
	desc = "Charges your hand with the power to turn victims into inert statues for a long period of time."
	spell_type = /obj/effect/proc_holder/spell/targeted/touch/flesh_to_stone

/datum/spellbook_entry/summonitem
	name = "Summon Item"
	desc = "Recalls a previously marked item to your hand from anywhere in the universe."
	spell_type = /obj/effect/proc_holder/spell/targeted/summonitem
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/lichdom
	name = "Bind Soul"
	desc = "A dark necromantic pact that can forever bind your soul to an item of your choosing, \
		turning you into an immortal Lich. So long as the item remains intact, you will revive from death, \
		no matter the circumstances. Be wary - with each revival, your body will become weaker, and \
		it will become easier for others to find your item of power."
	spell_type = /obj/effect/proc_holder/spell/targeted/lichdom
	category = "Defensive"

/datum/spellbook_entry/teslablast
	name = "Tesla Blast"
	desc = "Charge up a tesla arc and release it at a random nearby target! You can move freely while it charges. The arc jumps between targets and can knock them down."
	spell_type = /obj/effect/proc_holder/spell/targeted/tesla

/datum/spellbook_entry/lightningbolt
	name = "Lightning Bolt"
	desc = "Fire a lightning bolt at your foes! It will jump between targets, but can't knock them down."
	spell_type = /obj/effect/proc_holder/spell/aimed/lightningbolt
	cost = 1

/datum/spellbook_entry/infinite_guns
	name = "Lesser Summon Guns"
	desc = "Why reload when you have infinite guns? Summons an unending stream of bolt action rifles that deal little damage, but will knock targets down. Requires both hands free to use. Learning this spell makes you unable to learn Arcane Barrage."
	spell_type = /obj/effect/proc_holder/spell/targeted/infinite_guns/gun
	cost = 3
	no_coexistance_typecache = /obj/effect/proc_holder/spell/targeted/infinite_guns/arcane_barrage

/datum/spellbook_entry/infinite_guns/Refund(mob/living/carbon/human/user, obj/item/spellbook/book)
	for (var/obj/item/currentItem in user.get_all_gear())
		if (currentItem.type == /obj/item/gun/ballistic/rifle/enchanted)
			qdel(currentItem)
	return ..()

/datum/spellbook_entry/arcane_barrage
	name = "Arcane Barrage"
	desc = "Fire a torrent of arcane energy at your foes with this (powerful) spell. Deals much more damage than Lesser Summon Guns, but won't knock targets down. Requires both hands free to use. Learning this spell makes you unable to learn Lesser Summon Gun."
	spell_type = /obj/effect/proc_holder/spell/targeted/infinite_guns/arcane_barrage
	cost = 3
	no_coexistance_typecache = /obj/effect/proc_holder/spell/targeted/infinite_guns/gun

/datum/spellbook_entry/arcane_barrage/Refund(mob/living/carbon/human/user, obj/item/spellbook/book)
	for (var/obj/item/currentItem in user.get_all_gear())
		if (currentItem.type == /obj/item/gun/ballistic/rifle/enchanted/arcane_barrage)
			qdel(currentItem)
	return ..()

/datum/spellbook_entry/barnyard
	name = "Barnyard Curse"
	desc = "This spell dooms an unlucky soul to possess the speech and facial attributes of a barnyard animal."
	spell_type = /obj/effect/proc_holder/spell/pointed/barnyardcurse

/datum/spellbook_entry/charge
	name = "Charge"
	desc = "This spell can be used to recharge a variety of things in your hands, from magical artifacts to electrical components. A creative wizard can even use it to grant magical power to a fellow magic user."
	spell_type = /obj/effect/proc_holder/spell/targeted/charge
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/shapeshift
	name = "Wild Shapeshift"
	desc = "Take on the shape of another for a time to use their natural abilities. Once you've made your choice it cannot be changed."
	spell_type = /obj/effect/proc_holder/spell/targeted/shapeshift
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/tap
	name = "Soul Tap"
	desc = "Fuel your spells using your own soul!"
	spell_type = /obj/effect/proc_holder/spell/self/tap
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/spacetime_dist
	name = "Spacetime Distortion"
	desc = "Entangle the strings of space-time in an area around you, randomizing the layout and making proper movement impossible. The strings vibrate..."
	spell_type = /obj/effect/proc_holder/spell/spacetime_dist
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/the_traps
	name = "The Traps!"
	desc = "Summon a number of traps around you. They will damage and enrage any enemies that step on them."
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/the_traps
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/bees
	name = "Lesser Summon Bees"
	desc = "This spell magically kicks a transdimensional beehive, instantly summoning a swarm of bees to your location. These bees are NOT friendly to anyone."
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/creature/bee
	category = "Defensive"


/datum/spellbook_entry/item
	name = "Buy Item"
	refundable = FALSE
	buy_word = "Summon"
	var/item_path = null


/datum/spellbook_entry/item/Buy(mob/living/carbon/human/user,obj/item/spellbook/book)
	var/atom/spawned_path = new item_path(get_turf(user))
	log_spellbook("[key_name(user)] bought [src] for [cost] points")
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	return spawned_path

/datum/spellbook_entry/item/staffchange
	name = "Staff of Change"
	desc = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself."
	item_path = /obj/item/gun/magic/staff/change

/datum/spellbook_entry/item/staffanimation
	name = "Staff of Animation"
	desc = "An arcane staff capable of shooting bolts of eldritch energy which cause inanimate objects to come to life. This magic doesn't affect machines."
	item_path = /obj/item/gun/magic/staff/animate
	category = "Assistance"

/datum/spellbook_entry/item/staffchaos
	name = "Staff of Chaos"
	desc = "A caprious tool that can fire all sorts of magic without any rhyme or reason. Using it on people you care about is not recommended."
	item_path = /obj/item/gun/magic/staff/chaos

/datum/spellbook_entry/item/spellblade
	name = "Spellblade"
	desc = "A sword capable of firing blasts of energy which rip targets limb from limb."
	item_path = /obj/item/gun/magic/staff/spellblade

/datum/spellbook_entry/item/staffdoor
	name = "Staff of Door Creation"
	desc = "A particular staff that can mold solid walls into ornate doors. Useful for getting around in the absence of other transportation. Does not work on glass."
	item_path = /obj/item/gun/magic/staff/door
	cost = 1
	category = "Mobility"

/datum/spellbook_entry/item/staffhealing
	name = "Staff of Healing"
	desc = "An altruistic staff that can heal the lame and raise the dead."
	item_path = /obj/item/gun/magic/staff/healing
	cost = 1
	category = "Defensive"

/datum/spellbook_entry/item/lockerstaff
	name = "Staff of the Locker"
	desc = "A staff that shoots lockers. It eats anyone it hits on its way, leaving a welded locker with your victims behind."
	item_path = /obj/item/gun/magic/staff/locker
	category = "Defensive"

/datum/spellbook_entry/item/scryingorb
	name = "Scrying Orb"
	desc = "An incandescent orb of crackling energy. Using it will allow you to release your ghost while alive, allowing you to spy upon the station and talk to the deceased. In addition, buying it will permanently grant you X-ray vision."
	item_path = /obj/item/scrying
	category = "Defensive"

/datum/spellbook_entry/item/soulstones
	name = "Soulstone Shard Kit"
	desc = "Soul Stone Shards are ancient tools capable of capturing and harnessing the spirits of the dead and dying. The spell Artificer allows you to create arcane machines for the captured souls to pilot."
	item_path = /obj/item/storage/belt/soulstone/full
	category = "Assistance"

/datum/spellbook_entry/item/soulstones/Buy(mob/living/carbon/human/user,obj/item/spellbook/book)
	. =..()
	if(.)
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/construct(null))
	return .

/datum/spellbook_entry/item/necrostone
	name = "A Necromantic Stone"
	desc = "A Necromantic stone is able to resurrect three dead individuals as skeletal thralls for you to command."
	item_path = /obj/item/necromantic_stone
	category = "Assistance"

/datum/spellbook_entry/item/wands
	name = "Wand Assortment"
	desc = "A collection of wands that allow for a wide variety of utility. Wands have a limited number of charges, so be conservative with their use. Comes in a handy belt."
	item_path = /obj/item/storage/belt/wands/full
	category = "Defensive"

/datum/spellbook_entry/item/armor
	name = "Mastercrafted Armor Set"
	desc = "An artefact suit of armor that allows you to cast spells while providing more protection against attacks and the void of space, also grants a battlemage shield."
	item_path = /obj/item/mod/control/pre_equipped/enchanted
	category = "Defensive"

/datum/spellbook_entry/item/armor/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	. = ..()
	if(!.)
		return
	var/obj/item/mod/control/mod = .
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
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/item/contract
	name = "Contract of Apprenticeship"
	desc = "A magical contract binding an apprentice wizard to your service, using it will summon them to your side."
	item_path = /obj/item/antag_spawner/contract
	category = "Assistance"

/datum/spellbook_entry/item/guardian
	name = "Guardian Deck"
	desc = "A deck of guardian tarot cards, capable of binding a personal guardian to your body. There are multiple types of guardian available, but all of them will transfer some amount of damage to you. \
	It would be wise to avoid buying these with anything capable of causing you to swap bodies with others."
	item_path = /obj/item/guardiancreator/choose/wizard
	category = "Assistance"

/datum/spellbook_entry/item/guardian/Buy(mob/living/carbon/human/user,obj/item/spellbook/book)
	. = ..()
	if(.)
		new /obj/item/paper/guides/antag/guardian/wizard(get_turf(user))

/datum/spellbook_entry/item/bloodbottle
	name = "Bottle of Blood"
	desc = "A bottle of magically infused blood, the smell of which will attract extradimensional beings when broken. Be careful though, the kinds of creatures summoned by blood magic are indiscriminate in their killing, and you yourself may become a victim."
	item_path = /obj/item/antag_spawner/slaughter_demon
	limit = 3
	category = "Assistance"

/datum/spellbook_entry/item/hugbottle
	name = "Bottle of Tickles"
	desc = "A bottle of magically infused fun, the smell of which will \
		attract adorable extradimensional beings when broken. These beings \
		are similar to slaughter demons, but they do not permanently kill \
		their victims, instead putting them in an extradimensional hugspace, \
		to be released on the demon's death. Chaotic, but not ultimately \
		damaging. The crew's reaction to the other hand could be very \
		destructive."
	item_path = /obj/item/antag_spawner/slaughter_demon/laughter
	cost = 1 //non-destructive; it's just a jape, sibling!
	limit = 3
	category = "Assistance"

/datum/spellbook_entry/item/mjolnir
	name = "Mjolnir"
	desc = "A mighty hammer on loan from Thor, God of Thunder. It crackles with barely contained power."
	item_path = /obj/item/mjollnir

/datum/spellbook_entry/item/singularity_hammer
	name = "Singularity Hammer"
	desc = "A hammer that creates an intensely powerful field of gravity where it strikes, pulling everything nearby to the point of impact."
	item_path = /obj/item/singularityhammer

/datum/spellbook_entry/item/warpwhistle
	name = "Warp Whistle"
	desc = "A strange whistle that will transport you to a distant safe place on the station. There is a window of vulnerability at the beginning of every use."
	item_path = /obj/item/warp_whistle
	category = "Mobility"
	cost = 1

/datum/spellbook_entry/item/highfrequencyblade
	name = "High Frequency Blade"
	desc = "An incredibly swift enchanted blade resonating at a frequency high enough to be able to slice through anything."
	item_path = /obj/item/highfrequencyblade/wizard
	cost = 3

/datum/spellbook_entry/duffelbag
	name = "Bestow Cursed Duffel Bag"
	desc = "A curse that firmly attaches a demonic duffel bag to the target's back. The duffel bag will make the person it's attached to take periodical damage if it is not fed regularly, and regardless of whether or not it's been fed, it will slow the person wearing it down significantly."
	spell_type = /obj/effect/proc_holder/spell/targeted/touch/duffelbag
	category = "Defensive"
	cost = 1

//THESE ARE NOT PURCHASABLE SPELLS! They're references to old spells that got removed + shit that sounds stupid but fun so we can painfully lock behind a dimmer component

/datum/spellbook_entry/challenge
	name = "Take the Challenge"
	refundable = FALSE
	category = "Challenges"
	buy_word = "Accept"

/datum/spellbook_entry/challenge/multiverse
	name = "Multiverse Sword"
	desc = "The Station gets a multiverse sword to stop you. Can you withstand the hordes of multiverse realities?"

/datum/spellbook_entry/challenge/antiwizard
	name = "Friendly Wizard Scum"
	desc = "A \"Friendly\" Wizard will protect the station, and try to kill you. They get a spellbook much like you, but will use it for \"GOOD\"."

/// How much threat we need to let these rituals happen on dynamic
#define MINIMUM_THREAT_FOR_RITUALS 100

/datum/spellbook_entry/summon
	name = "Summon Stuff"
	category = "Rituals"
	limit = 1
	refundable = FALSE
	buy_word = "Cast"

/datum/spellbook_entry/summon/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	log_spellbook("[key_name(user)] cast [src] for [cost] points")
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	times++
	return TRUE

/datum/spellbook_entry/summon/ghosts
	name = "Summon Ghosts"
	desc = "Spook the crew out by making them see dead people. Be warned, ghosts are capricious and occasionally vindicative, and some will use their incredibly minor abilities to frustrate you."
	cost = 0

/datum/spellbook_entry/summon/ghosts/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	summon_ghosts(user)
	playsound(get_turf(user), 'sound/effects/ghost2.ogg', 50, TRUE)
	return ..()

/datum/spellbook_entry/summon/guns
	name = "Summon Guns"
	desc = "Nothing could possibly go wrong with arming a crew of lunatics just itching for an excuse to kill you. There is a good chance that they will shoot each other first."

/datum/spellbook_entry/summon/guns/IsAvailable()
	// Summon Guns requires 100 threat.
	var/datum/game_mode/dynamic/mode = SSticker.mode
	if(mode.threat_level < MINIMUM_THREAT_FOR_RITUALS)
		return FALSE
	// Also must be config enabled
	return !CONFIG_GET(flag/no_summon_guns)

/datum/spellbook_entry/summon/guns/Buy(mob/living/carbon/human/user,obj/item/spellbook/book)
	summon_guns(user, 10)
	playsound(get_turf(user), 'sound/magic/castsummon.ogg', 50, TRUE)
	return ..()

/datum/spellbook_entry/summon/magic
	name = "Summon Magic"
	desc = "Share the wonders of magic with the crew and show them why they aren't to be trusted with it at the same time."

/datum/spellbook_entry/summon/magic/IsAvailable()
	// Summon Magic requires 100 threat.
	var/datum/game_mode/dynamic/mode = SSticker.mode
	if(mode.threat_level < MINIMUM_THREAT_FOR_RITUALS)
		return FALSE
	// Also must be config enabled
	return !CONFIG_GET(flag/no_summon_magic)

/datum/spellbook_entry/summon/magic/Buy(mob/living/carbon/human/user,obj/item/spellbook/book)
	summon_magic(user, 10)
	playsound(get_turf(user), 'sound/magic/castsummon.ogg', 50, TRUE)
	return ..()

/datum/spellbook_entry/summon/events
	name = "Summon Events"
	desc = "Give Murphy's law a little push and replace all events with special wizard ones that will confound and confuse everyone. Multiple castings increase the rate of these events."
	cost = 2
	limit = 5 // Each purchase can intensify it.

/datum/spellbook_entry/summon/events/IsAvailable()
	// Summon Events requires 100 threat.
	var/datum/game_mode/dynamic/mode = SSticker.mode
	if(mode.threat_level < MINIMUM_THREAT_FOR_RITUALS)
		return FALSE
	// Also, must be config enabled
	return !CONFIG_GET(flag/no_summon_events)

/datum/spellbook_entry/summon/events/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	summon_events(user)
	playsound(get_turf(user), 'sound/magic/castsummon.ogg', 50, TRUE)
	return ..()

/datum/spellbook_entry/summon/events/GetInfo()
	if(times > 0)
		. += "You have cast it [times] time\s.<br>"
	return .

/datum/spellbook_entry/summon/curse_of_madness
	name = "Curse of Madness"
	desc = "Curses the station, warping the minds of everyone inside, causing lasting traumas. Warning: this spell can affect you if not cast from a safe distance."
	cost = 4

/datum/spellbook_entry/summon/curse_of_madness/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	var/message = tgui_input_text(user, "Whisper a secret truth to drive your victims to madness", "Whispers of Madness")
	if(!message)
		return FALSE
	curse_of_madness(user, message)
	playsound(user, 'sound/magic/mandswap.ogg', 50, TRUE)
	return ..()

#undef MINIMUM_THREAT_FOR_RITUALS

/obj/item/spellbook
	name = "spell book"
	desc = "An unearthly tome that glows with power."
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	worn_icon_state = "book"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/uses = 10

	/// The bonus that you get from going semi-random.
	var/semi_random_bonus = 2

	/// The bonus that you get from going full random.
	var/full_random_bonus = 5

	/// Determines if this spellbook can refund anything.
	var/can_refund = TRUE

	/// The mind that first used the book. Automatically assigned when a wizard spawns.
	var/datum/mind/owner

	var/list/entries = list()

/obj/item/spellbook/examine(mob/user)
	. = ..()
	if(owner)
		. += {"There is a small signature on the front cover: "[owner]"."}
	else
		. += "It appears to have no author."

/obj/item/spellbook/Initialize(mapload)
	. = ..()
	prepare_spells()
	RegisterSignal(src, COMSIG_ITEM_MAGICALLY_CHARGED, .proc/on_magic_charge)

/**
 * Signal proc for [COMSIG_ITEM_MAGICALLY_CHARGED]
 *
 * Has no effect on charge, but gives a funny message to people who think they're clever.
 */
/obj/item/spellbook/proc/on_magic_charge(datum/source, obj/effect/proc_holder/spell/targeted/charge/spell, mob/living/caster)
	SIGNAL_HANDLER

	var/static/list/clever_girl = list(
		"NICE TRY BUT NO!",
		"CLEVER BUT NOT CLEVER ENOUGH!",
		"SUCH FLAGRANT CHEESING IS WHY WE ACCEPTED YOUR APPLICATION!",
		"CUTE! VERY CUTE!",
		"YOU DIDN'T THINK IT'D BE THAT EASY, DID YOU?",
	)

	to_chat(caster, span_warning("Glowing red letters appear on the front cover..."))
	to_chat(caster, span_red(pick(clever_girl)))

	return COMPONENT_ITEM_BURNT_OUT

/obj/item/spellbook/attack_self(mob/user)
	if(!owner)
		if(!user.mind)
			return
		to_chat(user, span_notice("You bind the spellbook to yourself."))
		owner = user.mind
		return
	if(user.mind != owner)
		if(user.mind.special_role == ROLE_WIZARD_APPRENTICE)
			to_chat(user, "If you got caught sneaking a peek from your teacher's spellbook, you'd likely be expelled from the Wizard Academy. Better not.")
		else
			to_chat(user, span_warning("The [name] does not recognize you as its owner and refuses to open!"))
		return
	return ..()

/obj/item/spellbook/attackby(obj/item/O, mob/user, params)
	if(!can_refund)
		to_chat(user, span_warning("You can't refund anything!"))
		return

	if(istype(O, /obj/item/antag_spawner/contract))
		var/obj/item/antag_spawner/contract/contract = O
		if(contract.used)
			to_chat(user, span_warning("The contract has been used, you can't get your points back now!"))
		else
			to_chat(user, span_notice("You feed the contract back into the spellbook, refunding your points."))
			uses += 2
			for(var/datum/spellbook_entry/item/contract/CT in entries)
				if(!isnull(CT.limit))
					CT.limit++
			qdel(O)
	else if(istype(O, /obj/item/antag_spawner/slaughter_demon))
		to_chat(user, span_notice("On second thought, maybe summoning a demon is a bad idea. You refund your points."))
		if(istype(O, /obj/item/antag_spawner/slaughter_demon/laughter))
			uses += 1
			for(var/datum/spellbook_entry/item/hugbottle/HB in entries)
				if(!isnull(HB.limit))
					HB.limit++
		else
			uses += 2
			for(var/datum/spellbook_entry/item/bloodbottle/BB in entries)
				if(!isnull(BB.limit))
					BB.limit++
		qdel(O)

/obj/item/spellbook/proc/prepare_spells()
	var/entry_types = subtypesof(/datum/spellbook_entry) - /datum/spellbook_entry/item - /datum/spellbook_entry/summon - /datum/spellbook_entry/challenge
	for(var/type in entry_types)
		var/datum/spellbook_entry/possible_entry = new type
		if(possible_entry.IsAvailable())
			possible_entry.GetInfo() //loads up things for the entry that require checking spell instance.
			entries |= possible_entry
		else
			qdel(possible_entry)

/obj/item/spellbook/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Spellbook")
		ui.open()

/obj/item/spellbook/ui_data(mob/user)
	var/list/data = list()
	data["owner"] = owner
	data["points"] = uses
	data["semi_random_bonus"] = initial(uses) + semi_random_bonus
	data["full_random_bonus"] = initial(uses) + full_random_bonus
	return data

//This is a MASSIVE amount of data, please be careful if you remove it from static.
/obj/item/spellbook/ui_static_data(mob/user)
	var/list/data = list()
	var/list/entry_data = list()
	for(var/datum/spellbook_entry/entry as anything in entries)
		var/list/individual_entry_data = list()
		individual_entry_data["name"] = entry.name
		individual_entry_data["desc"] = entry.desc
		individual_entry_data["ref"] = REF(entry)
		individual_entry_data["clothes_req"] = entry.clothes_req
		individual_entry_data["cost"] = entry.cost
		individual_entry_data["times"] = entry.times
		individual_entry_data["cooldown"] = entry.cooldown
		individual_entry_data["cat"] = entry.category
		individual_entry_data["refundable"] = entry.refundable
		individual_entry_data["limit"] = entry.limit
		individual_entry_data["buyword"] = entry.buy_word
		entry_data += list(individual_entry_data)
	data["entries"] = entry_data
	return data

/obj/item/spellbook/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/wizard = usr
	if(!istype(wizard))
		to_chat(wizard, span_warning("The book doesn't seem to listen to lower life forms."))
		return
	switch(action)
		if("purchase")
			var/datum/spellbook_entry/entry = locate(params["spellref"]) in entries
			if(entry?.CanBuy(wizard,src))
				if(entry.Buy(wizard,src))
					if(entry.limit)
						entry.limit--
					uses -= entry.cost
			return TRUE
		if("refund")
			var/datum/spellbook_entry/entry = locate(params["spellref"]) in entries
			if(entry?.refundable)
				var/result = entry.Refund(wizard,src)
				if(result > 0)
					if(!isnull(entry.limit))
						entry.limit += result
					uses += result
			return TRUE
	//actions that are only available if you have full spell points
	if(uses < initial(uses))
		to_chat(wizard, span_warning("You need to have all your spell points to do this!"))
		return
	switch(action)
		if("semirandomize")
			semirandomize(wizard, semi_random_bonus)
			update_static_data(wizard) //update statics!
		if("randomize")
			randomize(wizard, full_random_bonus)
			update_static_data(wizard) //update statics!
		if("purchase_loadout")
			wizard_loadout(wizard, locate(params["id"]))

/obj/item/spellbook/proc/wizard_loadout(mob/living/carbon/human/wizard, loadout)
	var/list/wanted_spell_names
	switch(loadout)
		if(WIZARD_LOADOUT_CLASSIC) //(Fireball>2, MM>2, Smite>2, Jauntx2>4) = 10
			wanted_spell_names = list("Fireball" = 1, "Magic Missile" = 1, "Smite" = 1, "Ethereal Jaunt" = 2)
		if(WIZARD_LOADOUT_MJOLNIR) //(Mjolnir>2, Summon Itemx3>3, Mutate>2, Force Wall>1, Blink>2) = 10
			wanted_spell_names = list("Mjolnir" = 1, "Summon Item" = 3, "Mutate" = 1, "Force Wall" = 1, "Blink" = 1)
		if(WIZARD_LOADOUT_WIZARMY) //(Soulstones>2, Staff of Change>2, A Necromantic Stone>2, Teleport>2, Ethereal Jaunt>2) = 10
			wanted_spell_names = list("Soulstone Shard Kit" = 1, "Staff of Change" = 1, "A Necromantic Stone" = 1, "Teleport" = 1, "Ethereal Jaunt" = 1)
		if(WIZARD_LOADOUT_SOULTAP) //(Soul Tap>1, Smite>2, Flesh to Stone>2, Mindswap>2, Knock>1, Teleport>2) = 10
			wanted_spell_names = list("Soul Tap" = 1, "Smite" = 1, "Flesh to Stone" = 1, "Mindswap" = 1, "Knock" = 1, "Teleport" = 1)

	for(var/datum/spellbook_entry/entry as anything in entries)
		if(!(entry.name in wanted_spell_names))
			continue
		if(entry.CanBuy(wizard,src))
			var/purchase_count = wanted_spell_names[entry.name]
			wanted_spell_names -= entry.name
			for(var/i in 1 to purchase_count)
				entry.Buy(wizard,src)
				if(entry.limit)
					entry.limit--
				uses -= entry.cost
			entry.refundable = FALSE //once you go loading out, you never go back
		if(!length(wanted_spell_names))
			break

	if(length(wanted_spell_names))
		stack_trace("Wizard Loadout \"[loadout]\" could not find valid spells to buy in the spellbook. Either you input a name that doesn't exist, or you overspent")
	if(uses)
		stack_trace("Wizard Loadout \"[loadout]\" does not use 10 wizard spell slots. Stop scamming players out.")

/obj/item/spellbook/proc/semirandomize(mob/living/carbon/human/wizard, bonus_to_give = 0)
	var/list/needed_cats = list("Offensive", "Mobility")
	var/list/shuffled_entries = shuffle(entries)
	for(var/i in 1 to 2)
		for(var/datum/spellbook_entry/entry as anything in shuffled_entries)
			if(!(entry.category in needed_cats))
				continue
			if(entry?.CanBuy(wizard,src))
				if(entry.Buy(wizard,src))
					needed_cats -= entry.category //so the next loop doesn't find another offense spell
					entry.refundable = FALSE //once you go random, you never go back
					if(entry.limit)
						entry.limit--
					uses -= entry.cost
				break
	//we have given two specific category spells to the wizard. the rest are completely random!
	randomize(wizard, bonus_to_give = bonus_to_give)

/obj/item/spellbook/proc/randomize(mob/living/carbon/human/wizard, bonus_to_give = 0)
	var/list/entries_copy = entries.Copy()
	uses += bonus_to_give
	while(uses > 0 && length(entries_copy))
		var/datum/spellbook_entry/entry = pick(entries_copy)
		if(!entry?.CanBuy(wizard,src) || !entry.Buy(wizard,src))
			entries_copy -= entry
			continue

		entry.refundable = FALSE //once you go random, you never go back
		if(entry.limit)
			entry.limit--
		uses -= entry.cost

	can_refund = FALSE
