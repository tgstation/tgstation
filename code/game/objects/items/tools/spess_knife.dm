/obj/item/spess_knife
	name = "spess knife"
	desc = "An all-in-one tool combining knife, screwdriver, cutters and many more."
	icon = 'icons/obj/tools.dmi'
	icon_state = "spess_knife"
	inhand_icon_state = "screwdriver" // TODO
	worn_icon_state = "screwdriver" // TODO
	belt_icon_state = "screwdriver" // TODO
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = FIRE_PROOF
	tool_behaviour = null
	toolspeed = 2 // Two times worse than default tools
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT)
	/// The sound played on_attack_self
	var/switch_sound = 'sound/weapons/empty.ogg'
	hitsound = SFX_SWING_HIT

/obj/item/spess_knife/attack_self(mob/user, modifiers)
	if(isnull(tool_behaviour))
		tool_behaviour = pick_weight(list(
			TOOL_KNIFE = 30,
			TOOL_SCREWDRIVER = 30,
			TOOL_WIRECUTTER = 30,
			TOOL_WRENCH = 5,
			TOOL_SHOVEL = 2,
			TOOL_SAW = 2,
			TOOL_ROLLINGPIN = 1,
		))
	else
		tool_behaviour = null

	update_tool_parameters()

	if (tool_behaviour)
		balloon_alert(user, "[tool_behaviour] out")
	else
		balloon_alert(user, "folded")

	update_icon_state()
	playsound(user ? user : src, switch_sound, 50, TRUE)
	. = ..()

/// Used to update sounds and tool parameters during switching
/obj/item/spess_knife/proc/update_tool_parameters()
	switch(tool_behaviour)
		if(null)
			hitsound = initial(hitsound)
			usesound = initial(usesound)
		if(TOOL_KNIFE)
			hitsound = 'sound/weapons/bladeslice.ogg'
			usesound = initial(usesound)
		if(TOOL_SCREWDRIVER)
			hitsound = 'sound/weapons/bladeslice.ogg'
			usesound = list('sound/items/screwdriver.ogg', 'sound/items/screwdriver2.ogg')
		if(TOOL_WIRECUTTER)
			hitsound = 'sound/items/wirecutter.ogg'
			usesound = 'sound/items/wirecutter.ogg'
		if(TOOL_WRENCH)
			hitsound = initial(hitsound)
			usesound = 'sound/items/ratchet.ogg'
		if(TOOL_SHOVEL)
			hitsound = initial(hitsound)
			usesound = 'sound/effects/shovel_dig.ogg'
		if(TOOL_SAW)
			hitsound = 'sound/weapons/circsawhit.ogg'
			usesound = initial(usesound)
		if(TOOL_ROLLINGPIN)
			hitsound = initial(hitsound)
			usesound = initial(usesound)
		else
			hitsound = initial(hitsound)
			usesound = initial(usesound)

/obj/item/spess_knife/examine()
	. = ..()

	if(tool_behaviour)
		. += "It has a [tool_behaviour] extended out."
	else
		. += "It's folded."

/obj/item/spess_knife/update_icon_state()
	icon_state = initial(icon_state)

	if (tool_behaviour)
		icon_state += "_[sanitize_css_class_name(tool_behaviour)]"

	return ..()
