/obj/item/melee/transforming
	sharpness = SHARP_EDGED
	bare_wound_bonus = 20
	stealthy_audio = TRUE //Most of these are antag weps so we dont want them to be /too/ overt.
	w_class = WEIGHT_CLASS_SMALL
	var/active = FALSE
	var/force_on = 30 //force when active
	var/faction_bonus_force = 0 //Bonus force dealt against certain factions
	var/throwforce_on = 20
	var/icon_state_on = "axe1"
	var/hitsound_on = 'sound/weapons/blade1.ogg'
	var/list/attack_verb_on = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	var/list/attack_verb_off = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	w_class = WEIGHT_CLASS_SMALL
	var/w_class_on = WEIGHT_CLASS_BULKY
	var/clumsy_check = TRUE
	/// If we get sharpened with a whetstone, save the bonus here for later use if we un/redeploy
	var/sharpened_bonus

/obj/item/meleeInitialize()
	. = ..()

	AddComponent(/datum/component/butchering, 50, 100, 0, hitsound)
	RegisterSignal(src, COMSIG_ITEM_SHARPEN_ACT, .proc/on_sharpen)
