// Wizard spells that assist the caster in some way
/datum/spellbook_entry/summonitem
	name = "Summon Item"
	desc = "Recalls a previously marked item to your hand from anywhere in the universe."
	spell_type = /datum/action/cooldown/spell/summonitem
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/charge
	name = "Charge"
	desc = "This spell can be used to recharge a variety of things in your hands, from magical artifacts to electrical components. A creative wizard can even use it to grant magical power to a fellow magic user."
	spell_type = /datum/action/cooldown/spell/charge
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/shapeshift
	name = "Wild Shapeshift"
	desc = "Take on the shape of another for a time to use their natural abilities. Once you've made your choice it cannot be changed."
	spell_type = /datum/action/cooldown/spell/shapeshift/wizard
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/tap
	name = "Soul Tap"
	desc = "Fuel your spells using your own soul!"
	spell_type = /datum/action/cooldown/spell/tap
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/item/staffanimation
	name = "Staff of Animation"
	desc = "An arcane staff capable of shooting bolts of eldritch energy which cause inanimate objects to come to life. This magic doesn't affect machines."
	item_path = /obj/item/gun/magic/staff/animate
	category = "Assistance"

/datum/spellbook_entry/item/soulstones
	name = "Soulstone Shard Kit"
	desc = "Soul Stone Shards are ancient tools capable of capturing and harnessing the spirits of the dead and dying. \
		The spell Artificer allows you to create arcane machines for the captured souls to pilot."
	item_path = /obj/item/storage/belt/soulstone/full
	category = "Assistance"

/datum/spellbook_entry/item/soulstones/try_equip_item(mob/living/carbon/human/user, obj/item/to_equip)
	var/was_equipped = user.equip_to_slot_if_possible(to_equip, ITEM_SLOT_BELT, disable_warning = TRUE)
	to_chat(user, span_notice("\A [to_equip.name] has been summoned [was_equipped ? "on your waist" : "at your feet"]."))

/datum/spellbook_entry/item/soulstones/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book)
	. =..()
	if(!.)
		return

	var/datum/action/cooldown/spell/conjure/construct/bonus_spell = new(user.mind || user)
	bonus_spell.Grant(user)

/datum/spellbook_entry/item/necrostone
	name = "A Necromantic Stone"
	desc = "A Necromantic stone is able to resurrect three dead individuals as skeletal thralls for you to command."
	item_path = /obj/item/necromantic_stone
	category = "Assistance"

/datum/spellbook_entry/item/contract
	name = "Contract of Apprenticeship"
	desc = "A magical contract binding an apprentice wizard to your service, using it will summon them to your side."
	item_path = /obj/item/antag_spawner/contract
	category = "Assistance"
	refundable = TRUE

/datum/spellbook_entry/item/guardian
	name = "Guardian Deck"
	desc = "A deck of guardian tarot cards, capable of binding a personal guardian to your body. There are multiple types of guardian available, but all of them will transfer some amount of damage to you. \
	It would be wise to avoid buying these with anything capable of causing you to swap bodies with others."
	item_path = /obj/item/guardiancreator/choose/wizard
	category = "Assistance"

/datum/spellbook_entry/item/bloodbottle
	name = "Bottle of Blood"
	desc = "A bottle of magically infused blood, the smell of which will \
		attract extradimensional beings when broken. Be careful though, \
		the kinds of creatures summoned by blood magic are indiscriminate \
		in their killing, and you yourself may become a victim."
	item_path = /obj/item/antag_spawner/slaughter_demon
	limit = 3
	category = "Assistance"
	refundable = TRUE

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
	refundable = TRUE
