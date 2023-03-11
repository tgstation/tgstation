/obj/item/choice_beacon/space_suit
	name = "space suit delivery beacon"
	desc = "Summon your space suit"
	icon_state = "gangtool-suit"
	w_class = WEIGHT_CLASS_BULKY

/obj/item/choice_beacon/space_suit/captain

/obj/item/choice_beacon/space_suit/captain/generate_display_names()
	var/static/list/captain_suits
	if(!captain_suits)
		captain_suits = list()
		var/list/possible_captain_suits = list(
			/obj/item/clothing/suit/space/hardsuit/swat/captain,
			/obj/item/mod/control/pre_equipped/magnate,
		)
		for(var/obj/item/suit as anything in possible_captain_suits)
			captain_suits[initial(suit.name)] = suit
	return captain_suits

/obj/item/choice_beacon/space_suit/engineering

/obj/item/choice_beacon/space_suit/engineering/generate_display_names()
	var/static/list/engineering_suits
	if(!engineering_suits)
		engineering_suits = list()
		var/list/possible_engineering_suits = list(
			/obj/item/clothing/suit/space/hardsuit/engine,
			/obj/item/mod/control/pre_equipped/engineering,
		)
		for(var/obj/item/suit as anything in possible_engineering_suits)
			engineering_suits[initial(suit.name)] = suit
	return engineering_suits

/obj/item/choice_beacon/space_suit/atmos

/obj/item/choice_beacon/space_suit/atmos/generate_display_names()
	var/static/list/atmos_suits
	if(!atmos_suits)
		atmos_suits = list()
		var/list/possible_atmos_suits = list(
			/obj/item/clothing/suit/space/hardsuit/atmos,
			/obj/item/mod/control/pre_equipped/atmospheric,
		)
		for(var/obj/item/suit as anything in possible_atmos_suits)
			atmos_suits[initial(suit.name)] = suit
	return atmos_suits

/obj/item/choice_beacon/space_suit/ce

/obj/item/choice_beacon/space_suit/ce/generate_display_names()
	var/static/list/ce_suits
	if(!ce_suits)
		ce_suits = list()
		var/list/possible_ce_suits = list(
			/obj/item/clothing/suit/space/hardsuit/engine/elite,
			/obj/item/mod/control/pre_equipped/advanced,
		)
		for(var/obj/item/suit as anything in possible_ce_suits)
			ce_suits[initial(suit.name)] = suit
	return ce_suits

/obj/item/choice_beacon/space_suit/security

/obj/item/choice_beacon/space_suit/security/generate_display_names()
	var/static/list/security_suits
	if(!security_suits)
		security_suits = list()
		var/list/possible_security_suits = list(
			/obj/item/clothing/suit/space/hardsuit/security,
			/obj/item/mod/control/pre_equipped/security,
		)
		for(var/obj/item/suit as anything in possible_security_suits)
			security_suits[initial(suit.name)] = suit
	return security_suits

/obj/item/choice_beacon/space_suit/hos

/obj/item/choice_beacon/space_suit/hos/generate_display_names()
	var/static/list/hos_suits
	if(!hos_suits)
		hos_suits = list()
		var/list/possible_hos_suits = list(
			/obj/item/clothing/suit/space/hardsuit/security/hos,
			/obj/item/mod/control/pre_equipped/safeguard,
		)
		for(var/obj/item/suit as anything in possible_hos_suits)
			hos_suits[initial(suit.name)] = suit
	return hos_suits

/obj/item/choice_beacon/space_suit/mining

/obj/item/choice_beacon/space_suit/mining/generate_display_names()
	var/static/list/mining_suits
	if(!mining_suits)
		mining_suits = list()
		var/list/possible_mining_suits = list(
			/obj/item/clothing/suit/space/hardsuit/mining,
			/obj/item/mod/control/pre_equipped/mining,
		)
		for(var/obj/item/suit as anything in possible_mining_suits)
			mining_suits[initial(suit.name)] = suit
	return mining_suits

/obj/item/choice_beacon/space_suit/cmo

/obj/item/choice_beacon/space_suit/cmo/generate_display_names()
	var/static/list/cmo_suits
	if(!cmo_suits)
		cmo_suits = list()
		var/list/possible_cmo_suits = list(
			/obj/item/clothing/suit/space/hardsuit/medical,
			/obj/item/mod/control/pre_equipped/rescue,
		)
		for(var/obj/item/suit as anything in possible_cmo_suits)
			cmo_suits[initial(suit.name)] = suit
	return cmo_suits

/obj/item/choice_beacon/space_suit/rd

/obj/item/choice_beacon/space_suit/rd/generate_display_names()
	var/static/list/rd_suits
	if(!rd_suits)
		rd_suits = list()
		var/list/possible_rd_suits = list(
			/obj/item/clothing/suit/space/hardsuit/rd,
			/obj/item/mod/control/pre_equipped/research,
		)
		for(var/obj/item/suit as anything in possible_rd_suits)
			rd_suits[initial(suit.name)] = suit
	return rd_suits

/obj/item/choice_beacon/space_suit/syndi

/obj/item/choice_beacon/space_suit/syndi/generate_display_names()
	var/static/list/syndi_suits
	if(!syndi_suits)
		syndi_suits = list()
		var/list/possible_syndi_suits = list(
			/obj/item/clothing/suit/space/hardsuit/syndi,
			/obj/item/mod/control/pre_equipped/nuclear,
		)
		for(var/obj/item/suit as anything in possible_syndi_suits)
			syndi_suits[initial(suit.name)] = suit
	return syndi_suits

/obj/item/choice_beacon/space_suit/clown
	w_class = WEIGHT_CLASS_TINY

/obj/item/choice_beacon/space_suit/clown/generate_display_names()
	var/static/list/clown_suits
	if(!clown_suits)
		clown_suits = list()
		var/list/possible_clown_suits = list(
			/obj/item/clothing/suit/space/hardsuit/clown,
			/obj/item/mod/control/pre_equipped/cosmohonk,
		)
		for(var/obj/item/suit as anything in possible_clown_suits)
			clown_suits[initial(suit.name)] = suit
	return clown_suits
