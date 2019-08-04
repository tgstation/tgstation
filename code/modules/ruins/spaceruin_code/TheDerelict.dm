///////////	thederelict items

/obj/item/paper/fluff/ruins/thederelict/equipment
	info = "If the equipment breaks there should be enough spare parts in our engineering storage near the north east solar array."
	name = "Equipment Inventory"

/obj/item/paper/fluff/ruins/thederelict/syndie_mission
	name = "Mission Objectives"
	info = "The Syndicate have cunningly disguised a Syndicate Uplink as your PDA. Simply enter the code \"678 Bravo\" into the ringtone select to unlock its hidden features. <br><br><b>Objective #1</b>. Kill the God damn AI in a fire blast that it rocks the station. <b>Success!</b>  <br><b>Objective #2</b>. Escape alive. <b>Failed.</b>"

/obj/item/paper/fluff/ruins/thederelict/nukie_objectives
	name = "Objectives of a Nuclear Operative"
	info = "<b>Objective #1</b>: Destroy the station with a nuclear device."

/obj/item/paper/crumpled/bloody/ruins/thederelict/unfinished
	name = "unfinished paper scrap"
	desc = "Looks like someone started shakily writing a will in space common, but were interrupted by something bloody..."
	info = "I, Victor Belyakov, do hereby leave my _- "
/obj/item/paper/fluff/ruins/thederelict/vaultraider
	name = "Vault Raider Objectives"
	info = "<b>Objectives #1</b>: Find out whatever is being hidden in Kosmichekaya Stantsiya 13s Vault"


/// Vault controller for use on the derelict/KS13.
/obj/machinery/computer/vaultcontroller
	name = "vault controller"
	desc = "It seems to be powering and controlling the vault locks."
	icon_screen = "power"
	icon_keyboard = "power_key"
	light_color = LIGHT_COLOR_YELLOW
	use_power = NO_POWER_USE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/obj/structure/cable/attached_cable
	var/obj/machinery/door/airlock/outer
	var/obj/machinery/door/airlock/inner
	var/locked = TRUE
	var/siphoned_power = 0
	var/siphon_max = 5e7


/obj/machinery/computer/monitor/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It appears to be powered via a cable connector.</span>"


///Initializing airlock links, set during mapping.
/obj/machinery/computer/vaultcontroller/Initialize()
	..()
	for(var/obj/machinery/door/airlock/I in GLOB.machines)
		if(I.id_tag == "derelictvaultouter")
			outer = I
		if(I.id_tag == "derelictvaultinner")
			inner = I
		if(outer && inner)
			break


/obj/machinery/computer/vaultcontroller/process()
	update_cable()
	if(attached_cable)
		attempt_siphon()


/obj/machinery/computer/vaultcontroller/proc/update_cable()
	var/turf/T = get_turf(src)
	attached_cable = locate(/obj/structure/cable) in T


/obj/machinery/computer/vaultcontroller/proc/attempt_siphon()
	var/surpluspower = attached_cable.surplus()
	if(surpluspower)
		attached_cable.add_load(surpluspower)
		siphoned_power += surpluspower


/obj/machinery/computer/vaultcontroller/proc/activate_lock()
	if(locked)
		unlock_vault()
	else
		lock_vault()


/obj/machinery/computer/vaultcontroller/proc/lock_vault()
	if(outer && !outer.density)
		outer.safe = FALSE //Make sure its forced closed, always
		outer.unbolt()
		outer.close()
		outer.bolt()
	if(inner && !inner.density)
		inner.safe = FALSE //Make sure its forced closed, always
		inner.unbolt()
		inner.close()
		inner.bolt()
	locked = TRUE


/obj/machinery/computer/vaultcontroller/proc/unlock_vault()
	if(outer && outer.density)
		outer.unbolt()
		outer.open()
		outer.bolt()
	if(inner && inner.density)
		inner.unbolt()
		inner.open()
		inner.bolt()
	locked = FALSE


/obj/machinery/computer/vaultcontroller/ui_interact(mob/user, ui_key = "main", datum/tgui/ui = null, force_open = FALSE, \
											datum/tgui/master_ui = null, datum/ui_state/state = GLOB.default_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "vault_controller", name, 400, 400, master_ui, state)
		ui.open()


/obj/machinery/computer/vaultcontroller/ui_act(action, params)
	if(..())
		return
	//switch(action)


/obj/machinery/computer/vaultcontroller/ui_data()
	var/list/data = list()
	data["stored"] = siphoned_power
	data["max"] = siphon_max

	return data

