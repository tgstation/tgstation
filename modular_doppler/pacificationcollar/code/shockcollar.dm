/obj/item/electropack/shockcollar
	name = "shock collar"
	desc = "A reinforced metal collar. It has some sort of wiring near the front."
	icon = 'modular_doppler/pacificationcollar/icons/obj/shock.dmi'
	worn_icon = 'modular_doppler/pacificationcollar/icons/mob/shock.dmi'
	icon_state = "shockcollar"
	inhand_icon_state = null
	body_parts_covered = NECK
	slot_flags = ITEM_SLOT_NECK
	w_class = WEIGHT_CLASS_SMALL
	strip_delay = 60
	obj_flags = parent_type::obj_flags | UNIQUE_RENAME
	// equip_delay_other = 60
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)
	var/random = TRUE
	var/freq_in_name = FALSE

/datum/crafting_recipe/shockcollar
	name = "Shock Collar"
	result = /obj/item/electropack/shockcollar
	reqs = list(
		/obj/item/stack/sheet/iron = 5,
		/obj/item/stack/rods = 2,
		/obj/item/stack/cable_coil = 15,
		/obj/item/stock_parts/power_store/cell = 1
	)
	tool_behaviors = list(TOOL_SCREWDRIVER, TOOL_WRENCH)
	time = 5 SECONDS
	category = CAT_EQUIPMENT

/obj/item/electropack/shockcollar/allow_attack_hand_drop(mob/user)
	if(user.get_item_by_slot(ITEM_SLOT_NECK) == src)
		to_chat(user, span_warning("The collar is fastened tight! You'll need help if you want to take it off!"))
		return FALSE
	return ..()

/obj/item/electropack/shockcollar/receive_signal(datum/signal/signal)
	if(!signal || signal.data["code"] != code)
		return

	if(isliving(loc) && on) //the "on" arg is currently useless
		var/mob/living/carbon/human/affected_mob = loc
		if(!affected_mob.get_item_by_slot(ITEM_SLOT_NECK)) //**properly** stops pocket shockers
			return
		if(shock_cooldown == TRUE)
			return
		shock_cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, shock_cooldown, FALSE), 100)

		to_chat(affected_mob, span_danger("You feel a sharp shock from the collar!"))
		var/datum/effect_system/spark_spread/created_sparks = new /datum/effect_system/spark_spread
		created_sparks.set_up(3, 1, affected_mob)
		created_sparks.start()

		affected_mob.Paralyze(30)
		affected_mob.adjust_stutter(30 SECONDS)

	if(master)
		if(isassembly(master))
			var/obj/item/assembly/master_as_assembly = master
			master_as_assembly.pulsed()
		master.receive_signal()
	return

/obj/item/electropack/shockcollar/Initialize(mapload)
	if(random)
		code = rand(1, 100)
		frequency = rand(MIN_FREE_FREQ, MAX_FREE_FREQ)
		if(ISMULTIPLE(frequency, 2)) // Signaller frequencies are always uneven!
			frequency++
	if(freq_in_name)
		name = initial(name) + " - freq: [frequency/10] code: [code]"
	return ..()

/obj/item/electropack/shockcollar/ui_act(action, params)
	. = ..()
	icon_state = src::icon_state

/obj/item/electropack/shockcollar/pacify
	name = "pacifying collar"
	desc = "A reinforced metal collar that latches onto the wearer and prevents harmful thoughts."

/obj/item/electropack/shockcollar/pacify/equipped(mob/living/carbon/human/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_NECK)
		ADD_TRAIT(user, TRAIT_PACIFISM, "pacifying-collar")

/obj/item/electropack/shockcollar/pacify/dropped(mob/living/carbon/human/user)
	. = ..()
	REMOVE_TRAIT(user, TRAIT_PACIFISM, "pacifying-collar")
