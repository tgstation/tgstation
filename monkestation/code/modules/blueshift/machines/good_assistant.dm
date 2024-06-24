#define GBP_PUNCH_REWARD 100

/obj/item/card/id
	COOLDOWN_DECLARE(gbp_redeem_cooldown)

/obj/item/gbp_punchcard
	name = "Good Assistant Points punchcard"
	desc = "The Good Assistant Points program is designed to supplement the income of otherwise unemployed or unpaid individuals on board Nanotrasen vessels and colonies.<br>\
	Simply get your punchcard stamped by a Head of Staff to earn 100 credits per punch upon turn-in at a Good Assistant Point machine!<br>\
	Maximum of six punches per any given card. Card replaced upon redemption of existing card. Do not lose your punchcard."
	icon = 'monkestation/code/modules/blueshift/icons/punchcard.dmi'
	icon_state = "punchcard_0"
	w_class = WEIGHT_CLASS_TINY
	var/max_punches = 6
	var/punches = 0
	COOLDOWN_DECLARE(gbp_punch_cooldown)

/obj/item/gbp_punchcard/starting
	icon_state = "punchcard_1"
	punches = 1 // GBP_PUNCH_REWARD credits by default

/obj/item/gbp_punchcard/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(istype(attacking_item, /obj/item/gbp_puncher))
		if(!COOLDOWN_FINISHED(src, gbp_punch_cooldown))
			balloon_alert(user, "cooldown! [DisplayTimeText(COOLDOWN_TIMELEFT(src, gbp_punch_cooldown))]")
			return
		if(punches < max_punches)
			punches++
			icon_state = "punchcard_[punches]"
			COOLDOWN_START(src, gbp_punch_cooldown, 90 SECONDS)
			log_econ("[user] punched a GAP card that is now at [punches]/[max_punches] punches.")
			playsound(attacking_item, 'sound/items/boxcutter_activate.ogg', 100)
			if(punches == max_punches)
				playsound(src, 'sound/items/party_horn.ogg', 100)
				say("Congratulations, you have finished your punchcard!")
		else
			balloon_alert(user, "no room!")

/obj/item/gbp_puncher
	name = "Good Assistant Points puncher"
	desc = "A puncher for use with the Good Assistant Points system. Use it on a punchcard to punch a hole. Expect to be hassled for punches by assistants."
	icon = 'monkestation/code/modules/blueshift/icons/punchcard.dmi'
	icon_state = "puncher"
	w_class = WEIGHT_CLASS_TINY

/obj/machinery/gbp_redemption
	name = "Good Assistant Points Redemption Machine"
	desc = "Turn your Good Assistant Points punchcards in here for a payout based on the amount of punches you have, and get a new card!"
	icon = 'monkestation/code/modules/blueshift/icons/punchcard.dmi'
	icon_state = "gbp_machine"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/gbp_redemption

/obj/machinery/gbp_redemption/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return

/obj/machinery/gbp_redemption/attackby(obj/item/attacking_item, mob/user, params)
	if(default_deconstruction_screwdriver(user, "gbp_machine_open", "gbp_machine", attacking_item))
		return

	if(default_pry_open(attacking_item, close_after_pry = TRUE))
		return

	if(default_deconstruction_crowbar(attacking_item))
		return

	if(istype(attacking_item, /obj/item/gbp_punchcard))
		var/obj/item/gbp_punchcard/punchcard = attacking_item
		var/amount_to_reward = punchcard.punches * GBP_PUNCH_REWARD
		if(!punchcard.punches)
			playsound(src, 'sound/machines/scanbuzz.ogg', 100)
			say("You can't redeem an unpunched card!")
			return

		var/obj/item/card/id/card_used
		if(isliving(user))
			var/mob/living/living_user = user
			card_used = living_user.get_idcard(TRUE)

		if(isnull(card_used))
			return

		if(!COOLDOWN_FINISHED(card_used, gbp_redeem_cooldown))
			balloon_alert(user, "cooldown! [DisplayTimeText(COOLDOWN_TIMELEFT(card_used, gbp_redeem_cooldown))]")
			return

		if(!card_used.registered_account || !istype(card_used.registered_account.account_job, /datum/job/assistant))
			playsound(src, 'sound/machines/scanbuzz.ogg', 100)
			say("You cannot redeem a punchcard without a valid assistant bank account!")
			return

		if(punchcard.punches < punchcard.max_punches)
			if(tgui_alert(user, "You haven't finished the punchcard! Are you sure you want to redeem, starting the 15 minute timer?", "A real goof effort right here", list("No", "Yes")) != "Yes")
				return

		if(!punchcard.punches) // check to see if someone left the dialog open to redeem a card twice
			return

		var/validated_punches = punchcard.punches
		punchcard.punches = 0
		playsound(src, 'sound/machines/printer.ogg', 100)
		card_used.registered_account.adjust_money(amount_to_reward, "GAP: [validated_punches] punches")
		log_econ("[amount_to_reward] credits were rewarded to [card_used.registered_account.account_holder]'s account for redeeming a GAP card.")
		say("Rewarded [amount_to_reward] to your account, and dispensed a ration pack! Thank you for being a Good Assistant! Please take your new punchcard.")
		COOLDOWN_START(card_used, gbp_redeem_cooldown, 12 MINUTES)
		user.temporarilyRemoveItemFromInventory(punchcard)
		qdel(punchcard)
		var/obj/item/storage/fancy/nugget_box/nuggies = new(get_turf(src))
		var/obj/item/gbp_punchcard/replacement_card = new(get_turf(src))
		user.put_in_hands(nuggies)
		user.put_in_hands(replacement_card)
		return

	return ..()

/obj/item/circuitboard/machine/gbp_redemption
	name = "Good Assistant Point Redemption Machine"
	greyscale_colors = CIRCUIT_COLOR_SUPPLY
	build_path = /obj/machinery/gbp_redemption
	req_components = list(
		/datum/stock_part/manipulator = 1)


/datum/outfit/job/rd/pre_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	backpack_contents += list(
		/obj/item/gbp_puncher = 1
	)

/datum/outfit/job/hos/pre_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	backpack_contents += list(
		/obj/item/gbp_puncher = 1,
	)

/datum/outfit/job/hop/pre_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	backpack_contents += list(
		/obj/item/gbp_puncher = 1,
	)

/datum/outfit/job/ce/pre_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	backpack_contents += list(
		/obj/item/gbp_puncher = 1,
	)

/datum/outfit/job/cmo/pre_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	backpack_contents += list(
		/obj/item/gbp_puncher = 1,
	)

/datum/outfit/job/captain/pre_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	backpack_contents += list(
		/obj/item/gbp_puncher = 1,
	)

/datum/outfit/job/quartermaster/pre_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	backpack_contents += list(
		/obj/item/gbp_puncher = 1,
	)

/datum/outfit/job/assistant/pre_equip(mob/living/carbon/human/human, visualsOnly)
	. = ..()
	backpack_contents += list(/obj/item/gbp_punchcard/starting)

/datum/design/board/gbp_machine
	name = "Good Assistant Points Redemption Machine Board"
	desc = "The circuit board for a Good Assistant Points Redemption Machine."
	id = "gbp_machine"
	build_path = /obj/item/circuitboard/machine/gbp_redemption
	category = list(
		RND_CATEGORY_MACHINE + RND_SUBCATEGORY_MACHINE_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

//Base Nodes
/datum/techweb_node/base/New()
	design_ids += list(
		"polarizer",
		"gbp_machine",
	)
	return ..()
