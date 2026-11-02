/**
 * EXCIDIUM (Ratwood code/modules/roguetown/roguemachine/bounty.dm): Ravox's bounty board. A subject with a NERVELOCK account
 * puts a price on someone's head (paid from the account), the realm hears of it, anyone reads the list or prints it for a fee,
 * and the patron may strike their own listing (the mammons are not returned). Whoever brings the wanted person to the CASTIFICO
 * chair collects every bounty on that name in coin (castifico.dm). Ratwood offers only people the patron knows and describes
 * the target's height, build and voice; the port lists every living subject and describes their race.
 */
/obj/structure/roguemachine/bounty/examine(mob/user)
	. = ..()
	. += span_info("Touch it to consult, set, print or strike bounties. [length(GLOB.rogue_head_bounties)] bount[length(GLOB.rogue_head_bounties) == 1 ? "y is" : "ies are"] posted.")

/// Every bounty posted this round (Ratwood GLOB.head_bounties).
GLOBAL_LIST_EMPTY(rogue_head_bounties)

/// A price on someone's head (Ratwood /datum/bounty).
/datum/rogue_bounty
	var/target
	var/race
	var/amount
	var/reason
	var/employer
	/// The posting as it reads on the board (Ratwood banner).
	var/banner

/// One of Ratwood's three wordings of a bounty (compose_bounty()).
/datum/rogue_bounty/proc/compose()
	switch(rand(1, 3))
		if(1)
			banner = "A dire bounty hangs upon the capture of [target], for '[reason]'. They are a criminal belonging to the [race] race. The patron, [employer], offers [amount] mammons for the task."
		if(2)
			banner = "The capture of [target] is wanted for '[reason]'. They are a reprobate belonging to the [race] race. The employer, [employer], offers [amount] mammons for the deed."
		else
			banner = "[employer] hath offered to pay [amount] mammons for the capture of [target]. By reason of the following: '[reason]'. They are a heathen belonging to the [race] race."

/obj/structure/roguemachine/bounty/interact(mob/user)
	if(!ishuman(user))
		return TRUE
	var/choice = tgui_input_list(user, "The Excidium listens", name, list("Consult Bounties", "Set Bounty", "Print List of Bounties", "Remove Bounty"))
	if(!choice || QDELETED(src) || !user.Adjacent(src))
		return TRUE
	switch(choice)
		if("Consult Bounties")
			consult_bounties(user)
		if("Set Bounty")
			set_bounty(user)
		if("Print List of Bounties")
			print_bounties(user)
		if("Remove Bounty")
			remove_bounty(user)
	return TRUE

/obj/structure/roguemachine/bounty/proc/consult_bounties(mob/user)
	if(!length(GLOB.rogue_head_bounties))
		say("No bounties are currently active.")
		return
	var/list/lines = list()
	for(var/datum/rogue_bounty/bounty as anything in GLOB.rogue_head_bounties)
		lines += bounty.banner
	var/datum/browser/popup = new(user, "rogue_bounties", name, 500, 400, src)
	popup.set_content(jointext(lines, "<hr>"))
	popup.open()

/// Puts a price on a living subject's head (Ratwood set_bounty()): an amount within the Crown's bounds, paid from the account.
/obj/structure/roguemachine/bounty/proc/set_bounty(mob/living/carbon/human/user)
	var/list/candidates = list()
	for(var/mob/living/carbon/human/person as anything in GLOB.human_list)
		if(person != user && person.mind && person.stat != DEAD && person.real_name)
			candidates[person.real_name] = person
	if(!length(candidates))
		say("No target selected.")
		return
	var/target_name = tgui_input_list(user, "Whose name shall be etched on the wanted list?", name, sort_list(candidates))
	if(!target_name)
		return
	var/mob/living/carbon/human/target = candidates[target_name]
	var/least = rogue_value("trade_bounty_min")
	var/most = rogue_value("trade_bounty_max")
	var/amount = tgui_input_number(user, "How many mammons shall be stained red for their demise?", name, least, most, least)
	if(!amount || QDELETED(src) || QDELETED(target) || !user.Adjacent(src))
		return
	amount = round(amount)
	var/datum/bank_account/rogue/account = SSrogue_treasury.get_account(user)
	if(!account)
		say("You have no bank account.")
		return
	if(!account.has_money(amount))
		say("Insufficient balance funds.")
		return
	var/reason = tgui_input_text(user, "For what sins do you summon the hounds of hell?", name, max_length = MAX_MESSAGE_LEN)
	if(!reason)
		say("No reason given.")
		return
	if(tgui_alert(user, "Do you dare unleash this darkness upon the world? Your name will be known.", name, list("Yes", "No")) != "Yes")
		return
	if(QDELETED(src) || !user.Adjacent(src) || !SSrogue_treasury.burn(account, amount, "bounty placement - [target.real_name]"))
		return
	var/datum/rogue_bounty/bounty = new
	bounty.target = target.real_name
	bounty.race = target.dna?.species?.name || "unknown"
	bounty.amount = amount
	bounty.reason = reason
	bounty.employer = user.real_name
	bounty.compose()
	GLOB.rogue_head_bounties += bounty
	playsound(src, ROGUE_SOUND_MACHINE_TALK, 100, FALSE, -1)
	var/announcement = "The Excidium hungers for [target.real_name]."
	say(announcement)
	rogue_scom_announce(announcement)
	message_admins("[ADMIN_LOOKUPFLW(user)] has set a bounty on [ADMIN_LOOKUPFLW(target)] with the reason of: '[reason]'")
	log_game("BOUNTY: [key_name(user)] set [amount]m on [key_name(target)]: [reason]")

/// The patron strikes one of their own listings (Ratwood remove_bounty()); the mammons are not returned.
/obj/structure/roguemachine/bounty/proc/remove_bounty(mob/living/carbon/human/user)
	var/list/own = list()
	for(var/datum/rogue_bounty/bounty as anything in GLOB.rogue_head_bounties)
		if(bounty.employer == user.real_name)
			own[bounty.target] = bounty
	if(!length(own))
		say("You have no active bounty listings to remove.")
		return
	var/target_name = tgui_input_list(user, "Whose name shall be struck from the wanted list?", name, own)
	var/datum/rogue_bounty/bounty = own[target_name]
	if(!bounty || !(bounty in GLOB.rogue_head_bounties) || !user.Adjacent(src))
		return
	GLOB.rogue_head_bounties -= bounty
	say("Removing [target_name] from bounty list...")
	rogue_scom_announce("The bounty posting on [target_name] has been removed.")
	message_admins("[ADMIN_LOOKUPFLW(user)] has removed the bounty on [target_name]")

/// A written copy of the board for a fee to the Crown (Ratwood print_bounty_scroll(); the copy does not update itself).
/obj/structure/roguemachine/bounty/proc/print_bounties(mob/living/carbon/human/user)
	if(!length(GLOB.rogue_head_bounties))
		say("No bounties are currently active.")
		return
	var/cost = rogue_value("trade_bounty_print_cost")
	if(tgui_alert(user, "Print a list of active bounties for [cost] mammons?", name, list("Yes", "No")) != "Yes")
		return
	var/datum/bank_account/rogue/account = SSrogue_treasury.get_account(user)
	if(!account)
		say("You have no bank account.")
		return
	if(QDELETED(src) || !user.Adjacent(src) || !SSrogue_treasury.transfer(account, SSrogue_treasury.crown_purse, cost, "bounty scroll fee"))
		say("Insufficient funds in account. [cost] mammons required.")
		return
	var/obj/item/paper/scroll = new(drop_location())
	scroll.name = "bounty list"
	var/list/lines = list("WANTED BY THE EXCIDIUM")
	for(var/datum/rogue_bounty/bounty as anything in GLOB.rogue_head_bounties)
		lines += bounty.banner
	scroll.add_raw_text(jointext(lines, "\n\n"))
	scroll.update_appearance()
	user.put_in_hands(scroll)
	visible_message(span_notice("[src] prints out a weathered scroll."))
	say("Your scroll is ready.")
