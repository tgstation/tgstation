/obj/item/organ/cyberimp/arm/botany
	name = "hydroponics toolset implant"
	desc = "A rather simple arm implant containing tools used in gardening and botanical research."
	icon_state = "toolkit_generic"
	actions_types = list(/datum/action/item_action/organ_action/toggle/toolkit)
	items_to_create = list(/obj/item/cultivator,
		/obj/item/shovel/spade,
		/obj/item/hatchet,
		/obj/item/cultivator,
		/obj/item/plant_analyzer,
		/obj/item/secateurs,
	)

/obj/item/implant_mounted_chainsaw
	name = "integrated chainsaw"
	desc = "A chainsaw that conceals inside your arm."
	icon = 'icons/obj/weapons/chainsaw.dmi'
	icon_state = "chainsaw_on"
	inhand_icon_state = "mounted_chainsaw"
	lefthand_file = 'icons/mob/inhands/weapons/chainsaw_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/chainsaw_righthand.dmi'
	force = 24
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	sharpness = SHARP_EDGED
	attack_verb_continuous = list("saws", "tears", "lacerates", "cuts", "chops", "dices")
	attack_verb_simple = list("saw", "tear", "lacerate", "cut", "chop", "dice")
	hitsound = 'sound/items/weapons/chainsawhit.ogg'
	tool_behaviour = TOOL_SAW
	toolspeed = 1

/obj/item/organ/cyberimp/arm/botany/emag_act()
	if(obj_flags & EMAGGED)
		return FALSE
	for(var/datum/weakref/created_item in items_list)
	to_chat(usr, span_notice("You unlock [src]'s deluxe landscaping equipment!"))
	items_list += WEAKREF(new /obj/item/implant_mounted_chainsaw(src)) //time to landscape the station
	obj_flags |= EMAGGED
	return TRUE

/obj/item/organ/cyberimp/arm/janitor
	name = "sanitation toolset implant"
	desc = "A set of janitorial tools on the user's arm."
	actions_types = list(/datum/action/item_action/organ_action/toggle/toolkit)
	items_to_create = list(/obj/item/lightreplacer,
		/obj/item/holosign_creator,
		/obj/item/mop,
		/obj/item/reagent_containers/spray/cleaner,
		/obj/item/lightreplacer,
		/obj/item/wirebrush,
		)

/obj/item/organ/cyberimp/arm/janitor/emag_act()
	if(obj_flags & EMAGGED)
		return FALSE
	for(var/datum/weakref/created_item in items_list)
	to_chat(usr, span_notice("You unlock [src]'s integrated deluxe cleaning supplies!"))
	items_list += WEAKREF(new /obj/item/soap/syndie(src)) //We add not replace.
	items_list += WEAKREF(new /obj/item/reagent_containers/spray/cyborg_lube(src))
	obj_flags |= EMAGGED
	return TRUE

/obj/item/organ/cyberimp/arm/razor_claws
	name = "razor claws implant"
	desc = "A set of hidden, retractable blades built into the fingertips; cyborg mercenary approved."
	items_to_create = list(/obj/item/knife/razor_claws)
	actions_types = list(/datum/action/item_action/organ_action/toggle/razor_claws)
	icon = 'modular_doppler/modular_medical/icons/implants.dmi'
	icon_state = "wolverine"
	extend_sound = 'sound/items/unsheath.ogg'
	retract_sound = 'sound/items/sheath.ogg'

/datum/action/item_action/organ_action/toggle/razor_claws
	name = "Extend Claws"
	desc = "You can also activate the claws in your hand to change their mode."
	button_icon = 'modular_doppler/modular_medical/icons/organ_actions.dmi'
	button_icon_state = "wolverine"

/obj/item/knife/razor_claws
	name = "implanted razor claws"
	desc = "A set of sharp, retractable claws built into the fingertips, five double-edged blades sure to turn people into mincemeat. Capable of shifting into 'Precision' mode to act similar to wirecutters."
	icon = 'modular_doppler/modular_medical/icons/implants.dmi'
	righthand_file = 'modular_doppler/modular_medical/icons/implants_righthand.dmi'
	lefthand_file = 'modular_doppler/modular_medical/icons/implants_lefthand.dmi'
	icon_state = "wolverine"
	inhand_icon_state = "wolverine"
	var/knife_force = 10
	w_class = WEIGHT_CLASS_BULKY
	var/knife_wound_bonus = 5
	var/cutter_force = 6
	var/cutter_wound_bonus = 0
	var/cutter_bare_wound_bonus = 15
	tool_behaviour = TOOL_KNIFE
	toolspeed = 1

/obj/item/knife/razor_claws/attack_self(mob/user)
	playsound(get_turf(user), 'sound/items/tools/change_drill.ogg', 50, TRUE)
	if(tool_behaviour != TOOL_WIRECUTTER)
		tool_behaviour = TOOL_WIRECUTTER
		to_chat(user, span_notice("You shift [src] into Precision mode, for wirecutting."))
		icon_state = "precision_wolverine"
		inhand_icon_state = "precision_wolverine"
		force = cutter_force
		wound_bonus = cutter_wound_bonus
		bare_wound_bonus = cutter_bare_wound_bonus
		sharpness = NONE
		hitsound = 'sound/items/tools/wirecutter.ogg'
		usesound = 'sound/items/tools/wirecutter.ogg'
		attack_verb_continuous = list("bashes", "batters", "bludgeons", "thrashes", "whacks")
		attack_verb_simple = list("bash", "batter", "bludgeon", "thrash", "whack")
	else
		tool_behaviour = TOOL_KNIFE
		to_chat(user, span_notice("You shift [src] into Killing mode, for slicing."))
		icon_state = "wolverine"
		inhand_icon_state = "wolverine"
		force = knife_force
		sharpness = SHARP_EDGED
		wound_bonus = knife_wound_bonus
		bare_wound_bonus = 15
		hitsound = 'sound/items/weapons/bladeslice.ogg'
		usesound = 'sound/items/weapons/bladeslice.ogg'
		attack_verb_continuous = list("slashes", "tears", "slices", "tears", "lacerates", "rips", "dices", "cuts", "rends")
		attack_verb_simple = list("slash", "tear", "slice", "tear", "lacerate", "rip", "dice", "cut", "rend")

/obj/item/knife/razor_claws/attackby(obj/item/stone, mob/user, param)
	if(!istype(stone, /obj/item/scratching_stone))
		return ..()

	knife_force = 15
	knife_wound_bonus = 15
	armour_penetration = 10 //Let's give them some AP for the trouble.
	item_flags |= NEEDS_PERMIT

	if(tool_behaviour == TOOL_KNIFE)
		force = knife_force
		wound_bonus = knife_wound_bonus

	name = "enhanced razor claws"
	desc += span_warning("\n\nThese have undergone a special honing process; they'll kill people even faster than they used to.")
	user.visible_message(span_warning("[user] sharpens [src], [stone] disintegrating!"), span_warning("You sharpen [src], making it much more deadly than before, but [stone] disintegrates under the stress."))
	playsound(src, 'sound/items/unsheath.ogg', 25, TRUE)
	qdel(stone)
	return ..()

/obj/item/scratching_stone
	name = "scratching stone"
	icon = 'icons/obj/service/kitchen.dmi'
	icon_state = "sharpener"
	desc = "A specialized kind of whetstone, made of unknown alloys to hone a cyborg mercenary's claws to the best they can be. This one looks like a shitty second-hand sold by razorkids. It's got like, what, maybe one use left?"
	force = 5
	throwforce = 10 //Hey, you can at least use it as a brick.

/datum/supply_pack/goody/scratching_stone
	name = "Scratching Stone"
	desc = "A high-grade sharpening stone made of specialized alloys, meant to sharpen razor-claws. Unfortunately, this particular one has by far seen better days."
	cost = CARGO_CRATE_VALUE * 4 //800 credits
	contains = list(/obj/item/scratching_stone)
	contraband = TRUE

/obj/item/organ/cyberimp/arm/mining_drill
	name = "\improper Dalba Masterworks 'Burrower' Integrated Drill"
	desc = "Extending from a stabilization bracer built into the upper forearm, this implant allows for a steel mining drill to extend over the user's hand. Little by little, we advance a bit further with each turn. That's how a drill works!"
	icon = 'modular_doppler/modular_medical/icons/implants.dmi'
	icon_state = "steel"
	items_to_create = list(/obj/item/pickaxe/drill/implant)
	/// The bodypart overlay datum we should apply to whatever mob we are put into's someone's arm
	var/datum/bodypart_overlay/simple/steel_drill/drill_overlay

/datum/bodypart_overlay/simple/steel_drill
	icon = 'modular_doppler/modular_medical/icons/implants_onmob.dmi'
	layers = EXTERNAL_FRONT

/datum/bodypart_overlay/simple/steel_drill/left
	icon_state = "steel_left"

/datum/bodypart_overlay/simple/steel_drill/right
	icon_state = "steel_right"

/obj/item/organ/cyberimp/arm/mining_drill/on_bodypart_insert(obj/item/bodypart/limb, movement_flags)
	. = ..()
	if(zone == BODY_ZONE_L_ARM)
		drill_overlay = new /datum/bodypart_overlay/simple/steel_drill/left
	else
		drill_overlay = new /datum/bodypart_overlay/simple/steel_drill/right
	limb.add_bodypart_overlay(drill_overlay)
	owner?.update_body_parts()

/obj/item/organ/cyberimp/arm/mining_drill/on_mob_remove(mob/living/carbon/arm_owner)
	. = ..()
	bodypart_owner?.remove_bodypart_overlay(drill_overlay)
	arm_owner.update_body_parts()
	QDEL_NULL(drill_overlay)

/obj/item/pickaxe/drill/implant
	name = "integrated mining drill"
	desc = "Extending from a stabilization bracer built into the upper forearm, this implant allows for a steel mining drill to extend over the user's hand. Little by little, we advance a bit further with each turn. That's how a drill works!"
	slot_flags = NONE
	icon = 'modular_doppler/modular_medical/icons/implants.dmi'
	righthand_file = 'modular_doppler/modular_medical/icons/implants_righthand.dmi'
	lefthand_file = 'modular_doppler/modular_medical/icons/implants_lefthand.dmi'
	icon_state = "steel"
	inhand_icon_state = "steel"
	toolspeed = 0.6 //faster than a pickaxe
	usesound = 'sound/items/weapons/drill.ogg'
	hitsound = 'sound/items/weapons/drill.ogg'
	/// How recent the spin emote was
	var/recent_spin = 0
	/// The delay for how often you should be able to do it to prevent spam
	var/spin_delay = 10 SECONDS

/obj/item/pickaxe/drill/implant/click_alt(mob/user)
	spin()
	return CLICK_ACTION_SUCCESS

/obj/item/pickaxe/drill/implant/verb/spin()
	set name = "Spin Drillbit"
	set category = "Object"
	set desc = "Click to spin your drill's head. It won't do practically anything, but it's pretty cool anyway."

	var/mob/user = usr

	if(user.stat || !in_range(user, src))
		return

	if (recent_spin > world.time)
		return
	recent_spin = world.time + spin_delay

	playsound(user, 'modular_doppler/modular_sounds/sound/machines/whirr.ogg', 50, FALSE)
	user.visible_message(span_warning("[user] spins [src]'s bit, accelerating for a moment to <span class='bolddanger'>thousands of RPM.</span>"), span_notice("You spin [src]'s bit, accelerating for a moment to <span class='bolddanger'>thousands of RPM.</span>"))

/obj/item/organ/cyberimp/arm/mining_drill/diamond
	name = "\improper Dalba Masterworks 'Tunneler' Diamond Integrated Drill"
	desc = "Extending from a stabilization bracer built into the upper forearm, this implant allows for a masterwork diamond mining drill to extend over the user's hand. This drill will open a hole in the universe, and that hole will be a path for those behind us!"
	icon_state = "diamond"
	items_to_create = list(/obj/item/pickaxe/drill/implant/diamond)

/obj/item/pickaxe/drill/implant/diamond
	name = "integrated diamond mining drill"
	desc = "Extending from a stabilization bracer built into the upper forearm, this implant allows for a masterwork diamond mining drill to extend over the user's hand. This drill will open a hole in the universe, and that hole will be a path for those behind us!"
	icon_state = "diamond"
	inhand_icon_state = "diamond"
	toolspeed = 0.2
	force = 20
	demolition_mod = 1.25
	usesound = 'sound/items/weapons/drill.ogg'
	hitsound = 'sound/items/weapons/drill.ogg'
