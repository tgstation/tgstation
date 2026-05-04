
/**
 * Upon completion of a civilian bounty, one of these is created.
 * It is sold to cargo to give the cargo budget bounty money, and the person who completed it cash.
 */
/obj/item/bounty_cube
	name = "bounty cube"
	desc = "A bundle of compressed hardlight data, containing a completed bounty. Sell this on the cargo shuttle to claim it!"
	icon = 'icons/obj/economy.dmi'
	icon_state = "bounty_cube"
	///Value of the bounty that this bounty cube sells for.
	var/bounty_value = 0
	///Multiplier for the bounty payout received by the Supply budget if the cube is sent without having to nag.
	var/speed_bonus = 0.2
	///Percentage of the bounty payout received by the people who completed the bounty. Split between multiple people in the event multiple people finished a global bounty.
	var/holder_cut = BOUNTY_CUT_STANDARD
	///Multiplier for the bounty payout received by the person who claims the handling tip.
	var/handler_tip = 0.1
	///Time between nags.
	var/nag_cooldown = 5 MINUTES
	///How much the time between nags extends each nag.
	var/nag_cooldown_multiplier = 1.25
	///Next world tick to nag Supply listeners.
	var/next_nag_time
	///Who completed the bounty.
	var/bounty_holder
	///What job the bounty holder had.
	var/bounty_holder_job
	///What the bounty was for.
	var/bounty_name
	///Bank account of the people who completed the bounty.
	var/list/datum/bank_account/bounty_holder_accounts
	///Bank account of the person who receives the handling tip.
	var/datum/bank_account/bounty_handler_account

/obj/item/bounty_cube/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_BARCODES, INNATE_TRAIT) // Don't allow anyone to override our pricetag component with a barcode

/obj/item/bounty_cube/examine()
	. = ..()
	if(speed_bonus)
		. += span_notice("<b>[time2text(next_nag_time - world.time,"mm:ss", NO_TIMEZONE)]</b> remains until <b>[bounty_value * speed_bonus]</b> [MONEY_NAME_SINGULAR] speedy delivery bonus lost.")
	if(handler_tip && !bounty_handler_account)
		. += span_notice("Scan this in the cargo shuttle with an export scanner to register your bank account for the <b>[bounty_value * handler_tip]</b> [MONEY_NAME_SINGULAR] handling tip.")

/obj/item/bounty_cube/process(seconds_per_tick)
	//if our nag cooldown has finished and we aren't on Centcom or in transit, then nag
	if(COOLDOWN_FINISHED(src, next_nag_time) && !is_centcom_level(z) && !is_reserved_level(z))
		//set up our fallback message, in case of AAS being broken it will be sent to card holders
		var/nag_message = "[src] is unsent in [get_area(src)]."

		//nag on Supply channel and reduce the speed bonus multiplier to nothing
		var/obj/machinery/announcement_system/aas = get_announcement_system(/datum/aas_config_entry/bounty_cube_unsent, src, list(RADIO_CHANNEL_SUPPLY))
		if (aas)
			nag_message = aas.compile_config_message(/datum/aas_config_entry/bounty_cube_unsent, list("LOCATION" = get_area_name(src), "COST" = bounty_value), "Regular Message")
			if (speed_bonus)
				aas.announce(/datum/aas_config_entry/bounty_cube_unsent, list("LOCATION" = get_area_name(src), "COST" = bounty_value, "BONUSLOST" = bounty_value * speed_bonus), list(RADIO_CHANNEL_SUPPLY), "When Bonus Lost")
			else
				aas.broadcast("[nag_message]", list(RADIO_CHANNEL_SUPPLY))
		speed_bonus = 0

		//alert the holder
		for(var/datum/bank_account/bounty_holder_account in bounty_holder_accounts)
			bounty_holder_account.bank_card_talk("[nag_message]")

		//if someone has registered for the handling tip, nag them
		bounty_handler_account?.bank_card_talk(nag_message)

		//increase our cooldown length and start it again
		nag_cooldown = nag_cooldown * nag_cooldown_multiplier
		COOLDOWN_START(src, next_nag_time, nag_cooldown)

/**
 * Configures the bounty cube's name, value, and annouces to the crew
 */
/obj/item/bounty_cube/proc/set_up(datum/bounty/my_bounty, obj/item/card/id/holder_id)
	bounty_value = my_bounty.get_bounty_reward()
	bounty_name = my_bounty.name
	bounty_holder = holder_id.registered_name
	bounty_holder_job = holder_id.assignment
	bounty_holder_accounts = my_bounty.contribution

	name = "\improper [bounty_value] [MONEY_SYMBOL] [name]"
	desc += " The sales tag indicates it was <i>[bounty_holder] ([bounty_holder_job])</i>'s reward for completing the <i>[bounty_name]</i> bounty."
	AddComponent(/datum/component/pricetag, bounty_holder_accounts.Copy(), holder_cut, FALSE)
	AddComponent(/datum/component/gps, "[src]")

	START_PROCESSING(SSobj, src)
	COOLDOWN_START(src, next_nag_time, nag_cooldown)
	aas_config_announce(/datum/aas_config_entry/bounty_cube_created, list(
		"LOCATION" = get_area_name(src),
		"PERSON" = bounty_holder,
		"RANK" = bounty_holder_job,
		"BONUSTIME" = time2text(next_nag_time - world.time,"mm:ss", NO_TIMEZONE),
		"COST" = bounty_value
	), src, list(RADIO_CHANNEL_SUPPLY))

//for when you need a REAL bounty cube to test with and don't want to do a bounty each time your code changes
/obj/item/bounty_cube/debug_cube
	name = "debug bounty cube"
	desc = "Use in-hand to set it up with a random bounty. Requires an ID it can detect with a bank account attached. \
	This will alert Supply over the radio with your name and location, and cargo techs will be dispatched with kill on sight clearance."
	var/set_up = FALSE

/obj/item/bounty_cube/debug_cube/attack_self(mob/user)
	if(!isliving(user))
		to_chat(user, span_warning("You aren't eligible to use this!"))
		return ..()

	if(!set_up)
		var/mob/living/squeezer = user
		if(squeezer.get_bank_account())
			set_up(random_bounty(), squeezer.get_idcard())
			set_up = TRUE
			return ..()
		to_chat(user, span_notice("It can't detect your bank account."))

	return ..()

// Bounty Cube AAS Config Entries

/datum/aas_config_entry/bounty_cube_created
	name = "Cargo Alert: Bounty Cube Created"
	announcement_lines_map = list(
		"Message" = "A %COST cr bounty cube has been created in %LOCATION by %PERSON (%RANK). Speedy delivery bonus lost in %BONUSTIME.")
	vars_and_tooltips_map = list(
		"LOCATION" = "will be replaced with the location of the cube.",
		"PERSON" = "with who created the cube.",
		"RANK" = "with their job.",
		"BONUSTIME" = "with the time left for speedy delivery tip.",
		"COST" = "with the cost of the cube.",
	)

/datum/aas_config_entry/bounty_cube_unsent
	name = "Cargo Alert: Bounty Cube Unsent"
	announcement_lines_map = list(
		"Regular Message" = "The %COST cr bounty cube is unsent in %LOCATION.",
		"When Bonus Lost" = "The %COST cr bounty cube is unsent in %LOCATION. Speedy delivery bonus of %BONUSLOST credits lost.")
	vars_and_tooltips_map = list(
		"LOCATION" = "will be replaced with the location of the cube.",
		"COST" = "with the cost of the cube.",
		"BONUSLOST" = "with the lost bonus tip, it will be sent just for When Bonus Lost message!",
	)
