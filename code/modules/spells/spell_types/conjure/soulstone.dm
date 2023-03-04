/datum/action/cooldown/spell/conjure/soulstone
	name = "Summon Soulstone"
	desc = "This spell reaches into Nar'Sie's realm, summoning one of the legendary fragments across time and space."
	background_icon_state = "bg_demon"
	overlay_icon_state = "bg_demon_border"

	button_icon = 'icons/mob/actions/actions_cult.dmi'
	button_icon_state = "summonsoulstone"

	school = SCHOOL_CONJURATION
	cooldown_time = 4 MINUTES
	invocation_type = INVOCATION_NONE
	spell_requirements = NONE

	summon_radius = 0
	summon_type = list(/obj/item/soulstone)

/datum/action/cooldown/spell/conjure/soulstone/cult
	name = "Create Nar'sian Soulstone"
	cooldown_time = 6 MINUTES

/datum/action/cooldown/spell/conjure/soulstone/noncult
	name = "Create Soulstone"
	summon_type = list(/obj/item/soulstone/anybody)

/datum/action/cooldown/spell/conjure/soulstone/purified
	name = "Create Purified Soulstone"
	summon_type = list(/obj/item/soulstone/anybody/purified)

/datum/action/cooldown/spell/conjure/soulstone/mystic
	name = "Create Mystic Soulstone"
	summon_type = list(/obj/item/soulstone/mystic)
