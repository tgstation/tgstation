/*****************Pickaxes & Drills & Shovels****************/
/obj/item/pickaxe
	name = "pickaxe"
	icon = 'icons/obj/mining.dmi'
	icon_state = "pickaxe"
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	force = 15
	throwforce = 10
	demolition_mod = 1.15
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	custom_materials = list(/datum/material/iron=2000) //one sheet, but where can you make them?
	tool_behaviour = TOOL_MINING
	toolspeed = 1
	usesound = list('sound/effects/picaxe1.ogg', 'sound/effects/picaxe2.ogg', 'sound/effects/picaxe3.ogg')
	attack_verb_continuous = list("hits", "pierces", "slices", "attacks")
	attack_verb_simple = list("hit", "pierce", "slice", "attack")

/obj/item/pickaxe/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] begins digging into [user.p_their()] chest! It looks like [user.p_theyre()] trying to commit suicide!"))
	if(use_tool(user, user, 30, volume=50))
		return BRUTELOSS
	user.visible_message(span_suicide("[user] couldn't do it!"))
	return SHAME

/obj/item/pickaxe/rusted
	name = "rusty pickaxe"
	desc = "A pickaxe that's been left to rust."
	attack_verb_continuous = list("ineffectively hits")
	attack_verb_simple = list("ineffectively hit")
	force = 1
	throwforce = 1

/obj/item/pickaxe/mini
	name = "compact pickaxe"
	desc = "A smaller, compact version of the standard pickaxe."
	icon_state = "minipick"
	inhand_icon_state = "pickaxe"
	worn_icon_state = "pickaxe"
	force = 10
	throwforce = 7
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron=1000)

/obj/item/pickaxe/silver
	name = "silver-plated pickaxe"
	icon_state = "spickaxe"
	toolspeed = 0.5 //mines faster than a normal pickaxe, bought from mining vendor
	desc = "A silver-plated pickaxe that mines slightly faster than standard-issue."
	force = 17

/obj/item/pickaxe/diamond
	name = "diamond-tipped pickaxe"
	icon_state = "dpickaxe"
	toolspeed = 0.3
	desc = "A pickaxe with a diamond pick head. Extremely robust at cracking rock walls and digging up dirt."
	force = 19

/obj/item/pickaxe/drill
	name = "mining drill"
	icon_state = "handdrill"
	slot_flags = ITEM_SLOT_BELT
	toolspeed = 0.6 //available from roundstart, faster than a pickaxe.
	usesound = 'sound/weapons/drill.ogg'
	hitsound = 'sound/weapons/drill.ogg'
	desc = "An electric mining drill for the especially scrawny."

/obj/item/pickaxe/drill/cyborg
	name = "cyborg mining drill"
	desc = "An integrated electric mining drill."
	flags_1 = NONE

/obj/item/pickaxe/drill/cyborg/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, CYBORG_ITEM_TRAIT)

/obj/item/pickaxe/drill/diamonddrill
	name = "diamond-tipped mining drill"
	icon_state = "diamonddrill"
	toolspeed = 0.2
	desc = "Yours is the drill that will pierce the heavens!"

/obj/item/pickaxe/drill/cyborg/diamond //This is the BORG version!
	name = "diamond-tipped cyborg mining drill" //To inherit the NODROP_1 flag, and easier to change borg specific drill mechanics.
	icon_state = "diamonddrill"
	toolspeed = 0.2

/obj/item/pickaxe/drill/jackhammer
	name = "sonic jackhammer"
	icon_state = "jackhammer"
	toolspeed = 0.1 //the epitome of powertools. extremely fast mining
	usesound = 'sound/weapons/sonic_jackhammer.ogg'
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	desc = "Cracks rocks with sonic blasts."

/obj/item/pickaxe/improvised
	name = "improvised pickaxe"
	desc = "A pickaxe made with a knife and crowbar taped together, how does it not break?"
	icon_state = "ipickaxe"
	worn_icon_state = "pickaxe"
	force = 10
	throwforce = 7
	toolspeed = 3 //3 times slower than a normal pickaxe
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron=12050) //metal needed for a crowbar and for a knife, why the FUCK does a knife cost 6 metal sheets while a crowbar costs 0.025 sheets? shit makes no sense fuck this

/obj/item/shovel
	name = "shovel"
	desc = "A large tool for digging and moving dirt."
	icon = 'icons/obj/mining.dmi'
	icon_state = "shovel"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	force = 8
	throwforce = 4
	tool_behaviour = TOOL_SHOVEL
	toolspeed = 1
	usesound = 'sound/effects/shovel_dig.ogg'
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron=50)
	attack_verb_continuous = list("bashes", "bludgeons", "thrashes", "whacks")
	attack_verb_simple = list("bash", "bludgeon", "thrash", "whack")
	sharpness = SHARP_EDGED

/obj/item/shovel/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 150, 40) //it's sharp, so it works, but barely.

/obj/item/shovel/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] begins digging their own grave! It looks like [user.p_theyre()] trying to commit suicide!"))
	if(use_tool(user, user, 30, volume=50))
		return BRUTELOSS
	user.visible_message(span_suicide("[user] couldn't do it!"))
	return SHAME

/obj/item/shovel/spade
	name = "spade"
	desc = "A small tool for digging and moving dirt."
	icon_state = "spade"
	lefthand_file = 'icons/mob/inhands/equipment/hydroponics_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/hydroponics_righthand.dmi'
	force = 5
	throwforce = 7
	w_class = WEIGHT_CLASS_SMALL

/obj/item/shovel/serrated
	name = "serrated bone shovel"
	desc = "A wicked tool that cleaves through dirt just as easily as it does flesh. The design was styled after ancient lavaland tribal designs."
	icon_state = "shovel_bone"
	worn_icon_state = "shovel_serr"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	force = 15
	throwforce = 12
	w_class = WEIGHT_CLASS_NORMAL
	toolspeed = 0.7
	attack_verb_continuous = list("slashes", "impales", "stabs", "slices")
	attack_verb_simple = list("slash", "impale", "stab", "slice")
	sharpness = SHARP_EDGED

/obj/item/trench_tool
	name = "entrenching tool"
	desc = "The multi-purpose tool you always needed."
	icon = 'icons/obj/mining.dmi'
	icon_state = "trench_tool"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 15
	throwforce = 6
	w_class = WEIGHT_CLASS_SMALL
	tool_behaviour = TOOL_WRENCH
	toolspeed = 0.75
	usesound = 'sound/items/ratchet.ogg'
	attack_verb_continuous = list("bashes", "bludgeons", "thrashes", "whacks")
	attack_verb_simple = list("bash", "bludgeon", "thrash", "whack")
	wound_bonus = 10

/obj/item/trench_tool/examine(mob/user)
	. = ..()
	. += span_notice("It functions as a [tool_behaviour] tool.")

/obj/item/trench_tool/attack_self(mob/user, modifiers)
	. = ..()
	if(!user)
		return
	var/list/tool_list = list(
		"Wrench" = image(icon = icon, icon_state = "trench_tool"),
		"Shovel" = image(icon = icon, icon_state = "trench_tool_shovel"),
		"Pick" = image(icon = icon, icon_state = "trench_tool_pick"),
		)
	var/tool_result = show_radial_menu(user, src, tool_list, custom_check = CALLBACK(src, .proc/check_menu, user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user) || !tool_result)
		return
	switch(tool_result)
		if("Wrench")
			icon_state = "trench_tool"
			tool_behaviour = TOOL_WRENCH
			sharpness = NONE
			toolspeed = 0.75
			w_class = WEIGHT_CLASS_SMALL
			usesound = 'sound/items/ratchet.ogg'
			attack_verb_continuous = list("bashes", "bludgeons", "thrashes", "whacks")
			attack_verb_simple = list("bash", "bludgeon", "thrash", "whack")
		if("Shovel")
			icon_state = "trench_tool_shovel"
			tool_behaviour = TOOL_SHOVEL
			sharpness = SHARP_EDGED
			toolspeed = 0.25
			w_class = WEIGHT_CLASS_NORMAL
			usesound = 'sound/effects/shovel_dig.ogg'
			attack_verb_continuous = list("slashes", "impales", "stabs", "slices")
			attack_verb_simple = list("slash", "impale", "stab", "slice")
		if("Pick")
			icon_state = "trench_tool_pick"
			tool_behaviour = TOOL_MINING
			sharpness = SHARP_POINTY
			toolspeed = 0.5
			w_class = WEIGHT_CLASS_NORMAL
			usesound = 'sound/effects/picaxe1.ogg'
			attack_verb_continuous = list("hits", "pierces", "slices", "attacks")
			attack_verb_simple = list("hit", "pierce", "slice", "attack")
	playsound(src, 'sound/items/ratchet.ogg', 50, vary = TRUE)
	user.update_inv_hands()

/obj/item/trench_tool/proc/check_menu(mob/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE
