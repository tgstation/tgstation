GLOBAL_LIST_EMPTY(tails_list_monkey)

/datum/mutant_spritecat/monkey_tail
	name = "Monkey Tails"
	id = "tail_monkey"
	sprite_acc = /datum/sprite_accessory/tails/monkey
	default = "Monkey"

/datum/mutant_spritecat/monkey_tail/init_jank()
		init_sprite_accessory_subtypes(/datum/sprite_accessory/tails/monkey, GLOB.tails_list_monkey)
		world.log << "CELEBRATE: FOR THE MONKES HAVE TAILS"
		return ..()



/datum/sprite_accessory/tails/monkey
	name = "Debug"
	icon = 'icons/mob/human/species/monkey/monkey_tail.dmi'
	icon_state = "monkey"
	color_src = FALSE

/datum/sprite_accessory/tails/monkey/none
	name = "None"
	icon_state = "monkey"

/datum/sprite_accessory/tails/monkey/monkey
	name = "Monkey"
	icon_state = "monkey"



/datum/bodypart_overlay/mutant/tail/monkey/get_global_feature_list()
	return GLOB.tails_list_monkey
