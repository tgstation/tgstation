/obj/item/melee/cult_of_suffering_sword
	name = "Sword of Suffering"
	desc = "sword"
	icon = 'icons/obj/weapons/sword.dmi'
	icon_state = "chainswordon_cos"
	inhand_icon_state = "chainswordon"
	worn_icon_state = "chainswordon"
	slot_flags = ITEM_SLOT_BELT
	attack_verb_continuous = list("saws", "tears", "lacerates", "cuts", "chops", "dices")
	attack_verb_simple = list("saw", "tear", "lacerate", "cut", "chop", "dice")
	tool_behaviour = TOOL_SAW
	hitsound = 'sound/items/weapons/chainsawhit.ogg'
	toolspeed = 1.5 //slower than a real saw
