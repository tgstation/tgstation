/datum/spellbook_entry/lichdom/IsAvailible()
	return FALSE

/datum/spellbook_entry/teslablast
	cost = 1

/datum/spellbook_entry/lightningbolt
	cost = 2

/datum/spellbook_entry/infinite_guns
	cost = 2

/datum/spellbook_entry/arcane_barrage
	cost = 2

/datum/spellbook_entry/eruption
	cost = 1

/datum/spellbook_entry/item/plasma_fist
	cost = 3

/datum/spellbook_entry/item/mjolnir
	desc = "A mighty hammer on load from Thor, God of Thunder. It crackles with darely contained power. Counts as a staff."
	cost = 1

/datum/spellbook_entry/item/singularity_hammer
	desc = "A hammer that creates an intensely powerful field of gravity where it strikes, pulling everything nearby to the point of impact. Counts as a staff."
	cost = 1

/datum/spellbook_entry/cluwnecurse
	name = "Cluwne Curse"
	spell_type = /obj/effect/proc_holder/spell/targeted/cluwnecurse

/datum/spellbook_entry/eruption
	name = "Eruption"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/eruption
	cost = 1

/datum/spellbook_entry/fist
	name = "Fist"
	spell_type = /obj/effect/proc_holder/spell/aimed/fist

/datum/spellbook_entry/soulflare
	name = "Soulflare"
	spell_type = /obj/effect/proc_holder/spell/targeted/trigger/soulflare

/datum/spellbook_entry/corpseexplosion
	name = "Corpse Explosion"
	spell_type = /obj/effect/proc_holder/spell/targeted/explodecorpse

/datum/spellbook_entry/soulsplit
	name = "Soulsplit"
	spell_type = /obj/effect/proc_holder/spell/self/soulsplit
	category = "Mobility"

/datum/spellbook_entry/summon_bees
	name = "Conjure Bees"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/bees
	category = "Assistance"

/obj/item/book/granter/spell/smoke/lesser
	spell = /obj/effect/proc_holder/spell/targeted/smoke/lesser

/datum/spellbook_entry/item/voice
	name = "Voice Of God"
	desc = "Carefully harvested from Lavaland Colossi, these cords allow you to issue commands to those near you. Will not work on deaf people. Will drop upon resurrecting as a lich."
	item_path = /obj/item/device/autosurgeon/colossus
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/item/bookofdarkness
	name = "Book of Darkness"
	desc = "A forbidden tome, previously outlawed from the Wizard Federation for containing necromancy that is now being redistributed. Contains a powerful artifact that gets stronger with every soul it claims, a stunning spell that deals heavy damage to a single target, an incorporeal move spell and a spell that lets you explode corpses. Comes with a cool set of powerful robes as well that can carry the Staff of Revenant."
	item_path = /obj/item/bookofdarkness
	category = "Assistance"
	cost = 6
	limit = 1

/datum/spellbook_entry/item/staffofrevenant
	name = "Staff of Revenant"
	desc = "A weak staff that can drain the souls of the dead to become far more powerful than anything you can lay your hands on. Activate in your hand to view your progress, stats and if possible, progress to the next stage."
	item_path = /obj/item/gun/magic/staff/staffofrevenant
	category = "Defensive"

/datum/spellbook_entry/item/scryingorb/Buy(mob/living/carbon/human/user,obj/item/spellbook/book)
	if(..())
		if (!(user.dna.check_mutation(XRAY)))
			user.dna.add_mutation(XRAY)
	return 1

/datum/spellbook_entry/item/plasma_fist
	name = "Plasma Fist Scroll"
	desc = "Consider this more of a \"spell bundle.\" This artifact is NOT reccomended for weaklings. An ancient scroll that will teach you the art of Plasma Fist. With it's various combos you can knock people down in the area around you, light them on fire and finally perform the PLASMA FIST that will gib your target."
	item_path = /obj/item/plasma_fist_scroll
	cost = 3

/datum/spellbook_entry/summon/guns/IsAvailible()
	if (!..())
		return FALSE
	return (SSticker.mode.name != "ragin' mages" && !CONFIG_GET(flag/no_summon_guns))

/datum/spellbook_entry/summon/magic/IsAvailible()
	if (!..())
		return FALSE
	return (SSticker.mode.name != "ragin' mages" && !CONFIG_GET(flag/no_summon_magic))

/datum/spellbook_entry/summon/events/IsAvailible()
	if (!..())
		return FALSE
	return (SSticker.mode.name != "ragin' mages" && !CONFIG_GET(flag/no_summon_events))

/obj/item/spellbook
	persistence_replacement = /obj/item/book/granter/spell/random
