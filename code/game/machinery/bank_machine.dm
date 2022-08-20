/obj/machinery/computer/bank_machine
	name = "bank machine"
	desc = "A machine used to deposit and withdraw station funds."
	icon_screen = "vault"
	icon_keyboard = "security_key"
	req_access = list(ACCESS_VAULT)
	///Whether the machine is currently being siphoned
	var/siphoning = FALSE
	///While siphoning, how much money do we have? Will drop this once siphon is complete.
	var/syphoning_credits = 0
	///Whether siphoning is authorized or not (has access)
	var/unauthorized = FALSE
	///Amount of time before the next warning over the radio is announced.
	var/next_warning = 0
	///The amount of time we have between warnings
	var/minimum_time_between_warnings = 40 SECONDS

	///The machine's internal radio, used to broadcast alerts.
	var/obj/item/radio/radio
	///The channel we announce a siphon over.
	var/radio_channel = RADIO_CHANNEL_COMMON

	///What department to check to link our bank account to.
	var/account_department = ACCOUNT_CAR
	///Weakref of our bank account.
	var/datum/weakref/bank_account_ref

/obj/machinery/computer/bank_machine/Initialize(mapload)
	. = ..()
	radio = new(src)
	radio.subspace_transmission = TRUE
	radio.canhear_range = 0
	radio.set_listening(FALSE)
	radio.recalculateChannels()
	var/datum/bank_account/department_account = SSeconomy.get_dep_account(account_department)
	if(department_account)
		bank_account_ref = WEAKREF(department_account)

/obj/machinery/computer/bank_machine/Destroy()
	QDEL_NULL(radio)
	bank_account_ref = null
	return ..()

/obj/machinery/computer/bank_machine/attackby(obj/item/weapon, mob/user, params)
	var/value = 0
	if(istype(weapon, /obj/item/stack/spacecash))
		var/obj/item/stack/spacecash/inserted_cash = weapon
		value = inserted_cash.value * inserted_cash.amount
	else if(istype(weapon, /obj/item/holochip))
		var/obj/item/holochip/inserted_holochip = weapon
		value = inserted_holochip.credits
	if(value)
		var/datum/bank_account/bank_account = bank_account_ref.resolve()
		if(bank_account)
			bank_account.adjust_money(value)
			to_chat(user, span_notice("You deposit [weapon]. The [bank_account.account_holder] is now [bank_account.account_balance] cr."))
		qdel(weapon)
		return
	return ..()

/obj/machinery/computer/bank_machine/process(delta_time)
	. = ..()
	if(!siphoning)
		return
	if (machine_stat & (BROKEN | NOPOWER))
		say("Insufficient power. Halting siphon.")
		end_siphon()
		return
	var/siphon_am = 100 * delta_time
	var/datum/bank_account/bank_account = bank_account_ref.resolve()
	if(!bank_account.has_money(siphon_am))
		say("[bank_account.account_holder] depleted. Halting siphon.")
		end_siphon()
		return

	playsound(src, 'sound/items/poster_being_created.ogg', 100, TRUE)
	syphoning_credits += siphon_am
	bank_account.adjust_money(-siphon_am)
	if(next_warning < world.time && prob(15))
		var/area/A = get_area(loc)
		var/message = "[unauthorized ? "Unauthorized c" : "C"]redit withdrawal underway in [initial(A.name)][unauthorized ? "!!" : "..."]"
		radio.talk_into(src, message, radio_channel)
		next_warning = world.time + minimum_time_between_warnings

/obj/machinery/computer/bank_machine/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BankMachine", name)
		ui.open()

/obj/machinery/computer/bank_machine/ui_data(mob/user)
	var/list/data = list()
	var/datum/bank_account/bank_account = bank_account_ref.resolve()

	if(bank_account)
		data["current_balance"] = bank_account.account_balance
	else
		data["current_balance"] = 0
	data["siphoning"] = siphoning
	data["station_name"] = station_name()

	return data

/obj/machinery/computer/bank_machine/ui_act(action, params, datum/tgui/ui)
	. = ..()
	if(.)
		return

	switch(action)
		if("siphon")
			say("Siphon of station credits has begun!")
			start_siphon(ui.user)
			. = TRUE
		if("halt")
			say("Station credit withdrawal halted.")
			end_siphon()
			. = TRUE

/obj/machinery/computer/bank_machine/proc/end_siphon()
	siphoning = FALSE
	unauthorized = FALSE
	new /obj/item/holochip(drop_location(), syphoning_credits) //get the loot
	syphoning_credits = 0

/obj/machinery/computer/bank_machine/proc/start_siphon(mob/living/carbon/user)
	siphoning = TRUE
	unauthorized = TRUE
	var/obj/item/card/id/card = user.get_idcard(hand_first = TRUE)
	if(istype(card))
		if(req_access in card.GetAccess())
			unauthorized = FALSE
