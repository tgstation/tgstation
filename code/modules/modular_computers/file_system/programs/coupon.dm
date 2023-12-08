#define COUPON_PAPER_USE 1
#define COUPON_TONER_USE 0.250

/datum/computer_file/program/coupon
	filename = "couponmaster"
	filedesc = "Coupon Master"
	downloader_category = PROGRAM_CATEGORY_DEVICE
	extended_desc = "Program for receiving discounts for several cargo goodies. After redeeming a coupon, hit a photocopier with your PDA to print it."
	requires_ntnet = TRUE
	size = 5
	tgui_id = "NtosCouponMaster"
	program_icon = "ticket"
	usage_flags = PROGRAM_PDA //It relies on the PDA messenger to let you know of new codes
	detomatix_resistance = DETOMATIX_RESIST_MALUS

/datum/computer_file/program/coupon/on_install()
	. = ..()
	SSmodular_computers.discount_coupons = list()

/datum/computer_file/program/coupon/ui_data(mob/user)
	var/list/data = list()
	data["redeemed_coupons"] = list()
	data["valid_id"] = FALSE
	var/obj/item/card/id/user_id = computer.computer_id_slot
	if(user_id?.registered_account)
		for(var/list/coupon in user_id.registered_account.redeemed_coupons)
			data["redeemed_coupons"] += list(coupon)
		data["valid_id"] = TRUE
	return data

/datum/computer_file/program/coupon/ui_act(action, params, datum/tgui/ui)
	var/obj/item/card/id/user_id = computer.computer_id_slot
	if(!(user_id?.registered_account))
		return TRUE
	switch(action)
		if("redeem")
			var/code = params["code"]
			if(!length(code))
				return TRUE
			var/list/coupon_deets = SSmodular_computers.discount_coupons[code]
			if(!coupon_deets)
				user_id.registered_account.bank_card_talk("Invalid coupon.")
				return TRUE
			if(code in user_id.registered_account.redeemed_coupons)
				user_id.registered_account.bank_card_talk("Coupon [code] already redeemed.")
				return TRUE
			LAZYADD(user_id.registered_account.redeemed_coupons, coupon_deets.Copy())
			var/static/list/goodbye = list(
				"Have a wonderful day.",
				"Don't forget to print it.",
				"Time to get shopping!",
				"Enjoy your discount!",
				"Congratulations!",
				"Bye Bye~.",
			)
			user_id.registered_account.bank_card_talk("Coupon [code] redeemed. [goodbye]")
			//Well, guess you're redeeming something else too.
			if(prob(40) && computer.used_capacity < computer.max_capacity)
				var/datum/computer_file/warez = new()
				warez.filename = random_string(rand(6, 12), GLOB.alphabet + GLOB.alphabet_upper + GLOB.numerals)
				warez.filetype = pick("DAT", "XXX", "TMP", "FILE", "MNT", "MINER", "SYS", "PNG.EXE")
				warez.size = min(rand(1, 4), computer.max_capacity - computer.used_capacity)
				if(prob(20))
					warez.undeletable = TRUE
				computer.store_file(warez)

/datum/computer_file/program/coupon/tap(atom/tapped_atom, mob/living/user, params)
	if(!istype(tapped_atom, /obj/machinery/photocopier))
		return FALSE
	var/obj/item/card/id/user_id = computer.computer_id_slot
	if(!(user_id?.registered_account))
		computer.balloon_alert(user, "no bank account found!")
		return TRUE
	var/obj/machinery/photocopier/copier = tapped_atom
	if(copier.check_busy(user))
		return TRUE
	var/num_coupons = 0
	for(var/coupon in user_id.registered_account.redeemed_coupons)
		if(!coupon["printed"])
			num_coupons++
	copier.do_copies(CALLBACK(src, PROC_REF(print_coupon), user_id.registered_account), user, COUPON_PAPER_USE, COUPON_TONER_USE, num_coupons)

/datum/computer_file/program/coupon/proc/print_coupon(datum/bank_account/account)
	var/list/coupon_deets
	for(var/possible_coupon in account.redeemed_coupons)
		if(!possible_coupon["printed"])
			coupon_deets = possible_coupon
			break
	if(!coupon_deets)
		return null
	coupon_deets["printed"] = TRUE
	var/obj/item/coupon/coupon = new
	coupon.generate(coupon_deets["discount"], coupon_deets["goody"])
	return coupon

#undef COUPON_PAPER_USE
#undef COUPON_TONER_USE
