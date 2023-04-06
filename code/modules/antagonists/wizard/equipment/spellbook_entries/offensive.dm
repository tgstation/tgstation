// Offensive wizard spells
/datum/spellbook_entry/fireball
	name = "Fireball"
	desc = "Fires an explosive fireball at a target. Considered a classic among all wizards."
	spell_type = /datum/action/cooldown/spell/pointed/projectile/fireball
	category = "Offensive"

/datum/spellbook_entry/spell_cards
	name = "Spell Cards"
	desc = "Blazing hot rapid-fire homing cards. Send your foes to the shadow realm with their mystical power!"
	spell_type = /datum/action/cooldown/spell/pointed/projectile/spell_cards
	category = "Offensive"

/datum/spellbook_entry/rod_form
	name = "Rod Form"
	desc = "Take on the form of an immovable rod, destroying all in your path. Purchasing this spell multiple times will also increase the rod's damage and travel range."
	spell_type = /datum/action/cooldown/spell/rod_form
	category = "Offensive"

/datum/spellbook_entry/disintegrate
	name = "Smite"
	desc = "Charges your hand with an unholy energy that can be used to cause a touched victim to violently explode."
	spell_type = /datum/action/cooldown/spell/touch/smite
	category = "Offensive"

/datum/spellbook_entry/blind
	name = "Blind"
	desc = "Temporarily blinds a single target."
	spell_type = /datum/action/cooldown/spell/pointed/blind
	category = "Offensive"
	cost = 1

/datum/spellbook_entry/mutate
	name = "Mutate"
	desc = "Causes you to turn into a hulk and gain laser vision for a short while."
	spell_type = /datum/action/cooldown/spell/apply_mutations/mutate
	category = "Offensive"

/datum/spellbook_entry/fleshtostone
	name = "Flesh to Stone"
	desc = "Charges your hand with the power to turn victims into inert statues for a long period of time."
	spell_type = /datum/action/cooldown/spell/touch/flesh_to_stone
	category = "Offensive"

/datum/spellbook_entry/teslablast
	name = "Tesla Blast"
	desc = "Charge up a tesla arc and release it at a random nearby target! You can move freely while it charges. The arc jumps between targets and can knock them down."
	spell_type = /datum/action/cooldown/spell/charged/beam/tesla
	category = "Offensive"

/datum/spellbook_entry/lightningbolt
	name = "Lightning Bolt"
	desc = "Fire a lightning bolt at your foes! It will jump between targets, but can't knock them down."
	spell_type = /datum/action/cooldown/spell/pointed/projectile/lightningbolt
	category = "Offensive"
	cost = 1

/datum/spellbook_entry/infinite_guns
	name = "Lesser Summon Guns"
	desc = "Why reload when you have infinite guns? Summons an unending stream of bolt action rifles that deal little damage, but will knock targets down. Requires both hands free to use. Learning this spell makes you unable to learn Arcane Barrage."
	spell_type = /datum/action/cooldown/spell/conjure_item/infinite_guns/gun
	category = "Offensive"
	cost = 3
	no_coexistance_typecache = list(/datum/action/cooldown/spell/conjure_item/infinite_guns/arcane_barrage)

/datum/spellbook_entry/arcane_barrage
	name = "Arcane Barrage"
	desc = "Fire a torrent of arcane energy at your foes with this (powerful) spell. Deals much more damage than Lesser Summon Guns, but won't knock targets down. Requires both hands free to use. Learning this spell makes you unable to learn Lesser Summon Gun."
	spell_type = /datum/action/cooldown/spell/conjure_item/infinite_guns/arcane_barrage
	category = "Offensive"
	cost = 3
	no_coexistance_typecache = list(/datum/action/cooldown/spell/conjure_item/infinite_guns/gun)

/datum/spellbook_entry/barnyard
	name = "Barnyard Curse"
	desc = "This spell dooms an unlucky soul to possess the speech and facial attributes of a barnyard animal."
	spell_type = /datum/action/cooldown/spell/pointed/barnyardcurse
	category = "Offensive"

/datum/spellbook_entry/splattercasting
	name = "Splattercasting"
	desc = "Dramatically lowers the cooldown on all spells, but each one will cost blood, as well as it naturally \
		draining from you over time. You can replenish it from your victims, specifically their necks."
	spell_type =  /datum/action/cooldown/spell/splattercasting
	category = "Offensive"
	no_coexistance_typecache = list(/datum/action/cooldown/spell/lichdom)

/datum/spellbook_entry/sanguine_strike
	name = "Exsanguinating Strike"
	desc = "Sanguine spell that enchants your next weapon strike to deal more damage, heal you for damage dealt, and refill blood."
	spell_type =  /datum/action/cooldown/spell/sanguine_strike
	category = "Offensive"

/datum/spellbook_entry/scream_for_me
	name = "Scream For Me"
	desc = "Sadistic sanguine spell that inflicts numerous severe blood wounds all over the victim's body."
	spell_type =  /datum/action/cooldown/spell/touch/scream_for_me
	cost = 1
	category = "Offensive"

/datum/spellbook_entry/item/staffchaos
	name = "Staff of Chaos"
	desc = "A caprious tool that can fire all sorts of magic without any rhyme or reason. Using it on people you care about is not recommended."
	item_path = /obj/item/gun/magic/staff/chaos
	category = "Offensive"

/datum/spellbook_entry/item/staffchange
	name = "Staff of Change"
	desc = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself."
	item_path = /obj/item/gun/magic/staff/change
	category = "Offensive"

/datum/spellbook_entry/item/mjolnir
	name = "Mjolnir"
	desc = "A mighty hammer on loan from Thor, God of Thunder. It crackles with barely contained power."
	item_path = /obj/item/mjollnir
	category = "Offensive"

/datum/spellbook_entry/item/singularity_hammer
	name = "Singularity Hammer"
	desc = "A hammer that creates an intensely powerful field of gravity where it strikes, pulling everything nearby to the point of impact."
	item_path = /obj/item/singularityhammer
	category = "Offensive"

/datum/spellbook_entry/item/spellblade
	name = "Spellblade"
	desc = "A sword capable of firing blasts of energy which rip targets limb from limb."
	item_path = /obj/item/gun/magic/staff/spellblade
	category = "Offensive"

/datum/spellbook_entry/item/highfrequencyblade
	name = "High Frequency Blade"
	desc = "An incredibly swift enchanted blade resonating at a frequency high enough to be able to slice through anything."
	item_path = /obj/item/highfrequencyblade/wizard
	category = "Offensive"
	cost = 3
