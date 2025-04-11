/datum/action/cooldown/spell/shapeshift/wolf
	name = "Wolf Form"
	desc = "Take on the shape a wolf."
	invocation = span_danger("<b>%CASTER</b> lets out a mighty growl!")
	invocation_self_message = span_danger("You let out a mighty growl!")
	invocation_type = INVOCATION_EMOTE
	spell_requirements = NONE

	possible_shapes = list(/mob/living/basic/mining/wolf)

/obj/item/clothing/neck/cloak/wolf_coat
	name = "wolf pelt cloak"
	desc = "A cloak made of very lively wolf fur, feels warm to touch."
	icon_state = "admincloak"
	body_parts_covered = CHEST|GROIN|ARMS

	actions_types = list(/datum/action/cooldown/spell/shapeshift/wolf)
