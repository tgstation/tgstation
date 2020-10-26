/obj/machinery/card_trimmer
	name = "card trimmer"
	desc = "A machine that can replace the trim of Nanotrasen cards, changing its predefined access slots."
	icon_state = "autolathe"
	circuit = /obj/item/circuitboard/machine/card_trimmer
	layer = BELOW_OBJ_LAYER
	density = TRUE
	use_power = IDLE_POWER_USE
	active_power_usage = 20
	idle_power_usage = 5
	pass_flags = PASSTABLE

	var/obj/item/card/id/id = null // card in the machine
	var/operating = FALSE
	var/selected_trim = NONE
	var/list/valid_trims = list(TRIM_SERVICE, TRIM_SECURITY, TRIM_MEDICAL, TRIM_SCIENCE, TRIM_ENGINEERING, TRIM_SUPPLY, TRIM_COMMAND)
	var/list/radial_options = list()

/obj/machinery/card_trimmer/Initialize()
	. = ..()
	radial_options["None"] += image(icon = 'icons/obj/card.dmi', icon_state = "id") // include NONE trim
	for(var/trim in valid_trims)
		radial_options["[get_region_accesses_name(trim)]"] = image(icon = 'icons/obj/card.dmi', icon_state = ckey("trim[get_region_accesses_name(trim)]")) // all trims are trim + region_accesses_name


/obj/machinery/card_trimmer/attackby(obj/item/target_card, mob/user, params)
	if(istype(target_card, /obj/item/card/id))
		if(user)
			if(!user.transferItemToLoc(target_card, src))
				return FALSE
		else
			target_card.forceMove(src)
		id = target_card
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
		to_chat(user, "<span class='notice'>You insert a card into [src]</span>")
		return
	return ..()

/obj/machinery/card_trimmer/AltClick(mob/user)
	if(user.canUseTopic(src, !issilicon(usr)) && !operating)
		eject_card(user)

/obj/machinery/card_trimmer/ui_interact(mob/user)
	. = ..()

	if(operating || panel_open || !anchored || !user.canUseTopic(src, !issilicon(user)))
		return
	if(isAI(user) && (machine_stat & NOPOWER))
		return

	var/choice = show_radial_menu(user, src, radial_options, require_near = !issilicon(user))
	if(isnull(choice))
		return
	selected_trim = choice
	trim_card(user)

/obj/machinery/card_trimmer/proc/trim_card(mob/user)
	if(machine_stat & (NOPOWER|BROKEN))
		return
	if(operating || panel_open || !anchored)
		return
	if(isnull(id))
		to_chat(user, "<span class='notice'>\The [src] doesn't have a card in it.</span>")
		return
	visible_message("<span class='notice'>\The [src] starts to dispense a card.</span>")
	playsound(user, 'sound/items/poster_being_created.ogg', 20, TRUE)
	operating = TRUE
	id.access -= get_region_accesses(id.trim) // so you can't exploit changing trim to give accesses.
	id.trim = selected_trim
	id.update_label()
	addtimer(CALLBACK(src, .proc/eject_card), 5 SECONDS)

/obj/machinery/card_trimmer/proc/eject_card()
	if(isnull(id))
		return
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)
	id.forceMove(drop_location())
	id = null
	operating = FALSE
