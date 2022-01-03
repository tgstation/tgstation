/obj/machinery/sewing_machine
	name = "sewing machine"
	desc = "Combine a pattern kit cloth, and optionally dye and/or measurements to produce clothes."
	icon = 'icons/obj/barber_and_tailor.dmi'
	icon_state = "sewing_machine"
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 500
	circuit = /obj/item/circuitboard/machine/sewing_machine
	density = TRUE
	var/obj/item/stack/sheet/cloth/cloth_to_use
	var/obj/item/dye/dye_to_use
	var/obj/item/pattern_kit/pattern_kit_to_use
	var/obj/item/measurements_paper/measurements_paper_to_use
	var/operating = FALSE

/obj/machinery/sewing_machine/attackby(obj/item/weapon, mob/user, params)
	. = ..()
	if(istype(weapon, /obj/item/stack/sheet/cloth) && !cloth_to_use)
		user.balloon_alert(user, "inserted [weapon]")
		cloth_to_use = weapon
		weapon.forceMove(src)
	if(istype(weapon, /obj/item/dye) && !dye_to_use)
		user.balloon_alert(user, "inserted [weapon]")
		dye_to_use = weapon
		weapon.forceMove(src)
	if(istype(weapon, /obj/item/pattern_kit) && !pattern_kit_to_use)
		user.balloon_alert(user, "inserted [weapon]")
		pattern_kit_to_use = weapon
		weapon.forceMove(src)
	if(istype(weapon, /obj/item/measurements_paper) && !measurements_paper_to_use)
		user.balloon_alert(user, "inserted [weapon]")
		measurements_paper_to_use = weapon
		weapon.forceMove(src)

/obj/machinery/sewing_machine/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(!cloth_to_use || !pattern_kit_to_use)
		to_chat(user, "There's no cloth or no pattern kit.")
		return
	if(operating)
		return
	operating = TRUE
	playsound(src, 'sound/items/sewing_machine.ogg', 100)
	user.balloon_alert(user, "sewing started")
	if(do_after(user, 8 SECONDS, src))
		var/obj/item/clothing/clothing_produced = new pattern_kit_to_use.clothing_to_make(get_turf(src))
		if(cloth_to_use.color)
			var/icon/greyscaled_icon = new(clothing_produced.icon)
			greyscaled_icon.GrayScale()
			clothing_produced.icon = greyscaled_icon
			var/icon/greyscaled_worn_icon = new(clothing_produced.worn_icon)
			greyscaled_worn_icon.GrayScale()
			clothing_produced.worn_icon = greyscaled_worn_icon
			clothing_produced.color = cloth_to_use.color
		if(dye_to_use)
			var/icon/greyscaled_icon = new(clothing_produced.icon)
			greyscaled_icon.GrayScale()
			clothing_produced.icon = greyscaled_icon
			var/icon/greyscaled_worn_icon = new(clothing_produced.worn_icon)
			greyscaled_worn_icon.GrayScale()
			clothing_produced.worn_icon = greyscaled_worn_icon
			clothing_produced.color = dye_to_use.color
			qdel(dye_to_use)
			dye_to_use = null
		cloth_to_use.use(1)
		if(QDELETED(cloth_to_use))
			user.balloon_alert(user, "out of cloth")
			cloth_to_use = null
		else
			user.balloon_alert(user, "[cloth_to_use.amount] cloth left")
		if(measurements_paper_to_use)
			clothing_produced.fitted_by_tailor = measurements_paper_to_use.human_ref
			measurements_paper_to_use.forceMove(get_turf(src))
			measurements_paper_to_use = null
		pattern_kit_to_use.forceMove(get_turf(src))
		pattern_kit_to_use = null
	operating = FALSE

