/obj/item/caution
	desc = "Caution! Wet Floor!"
	name = "wet floor sign"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "caution"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 1
	throwforce = 3
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("warned", "cautioned", "smashed")

/obj/item/skub
	desc = "It's skub."
	name = "skub"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "skub"
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("skubbed")

/obj/item/skub/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] has declared themself as anti-skub! The skub tears them apart!</span>")

	user.gib()
	playsound(src, 'sound/items/eatfood.ogg', 50, 1, -1)
	return MANUAL_SUICIDE


/obj/item/suspiciousphone
	name = "suspicious phone"
	desc = "This device raises pink levels to unknown highs."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "suspiciousphone"
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("dumped")
	var/dumped = FALSE
	var/mob/living/carbon/human/bogdanoff
	var/obj/structure/checkoutmachine/checkout
	var/list/acounts_to_rob

/obj/item/suspiciousphone/attack_self(mob/user)
	if(!ishuman(user))
		to_chat(user, "<span class='warning'>This device is too advanced for you!</span>")
		return
	if(dumped)
		to_chat(user, "<span class='warning'>You already activated Protocol CRAB-17.</span>")
		return FALSE

	if(alert(user, "Are you sure you want to crash this market with no survivors?", "Protocol CRAB-17", "Yes", "No") == "Yes")
		if(dumped) //Prevents fuckers from cheesing alert
			return FALSE
		sound_to_playing_players('sound/items/dump_it.ogg', 75)
		bogdanoff = user
		var/turf/targetturf
		if(GLOB.blobstart.len > 0)
			targetturf = get_turf(pick(GLOB.blobstart))
		else
			targetturf = bogdanoff.loc
		checkout = new(targetturf)
		addtimer(CALLBACK(src, .proc/crab17), 100)
		dumped = TRUE	

/obj/item/suspiciousphone/proc/crab17()
	acounts_to_rob = SSeconomy.bank_accounts
	acounts_to_rob -= bogdanoff.get_bank_account()
	priority_announce("The spacecoin bubble has popped! Get to the credit deposit machine at [get_area(checkout).name] and cash out before you lose all of your funds!", sender_override = "CRAB-17 Protocol")
	for(var/i in acounts_to_rob)
		var/datum/bank_account/B = i
		B.being_dumped = TRUE
		dump()

/obj/item/suspiciousphone/proc/dump()
	var/percentage_lost = (rand(1, 10) / 100)
	for(var/i in acounts_to_rob)
		var/datum/bank_account/B = i
		if(!B.being_dumped)
			continue
		var/amount = B.account_balance * percentage_lost 
		bogdanoff.get_bank_account().transfer_money(B, amount)
		B.bank_card_talk("You have lost [percentage_lost]% of your funds!")
	addtimer(CALLBACK(src, .proc/dump), 150) //Drain every 15 seconds

/obj/structure/checkoutmachine
	name = "credit deposit machine"
	desc = "This is good for spacecoin because"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "console"

/obj/structure/checkoutmachine/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/card/id))
		var/obj/item/card/id/card = W
		if(!card.registered_account)
			return
		if(!card.registered_account.being_dumped)
			to_chat(user, "<span class='warning'>It appears that your funds is safe from draining!</span>")
			return
		if(do_after(user, 40, target = src))
			if(!card.registered_account.being_dumped)
				return
			to_chat(user, "<span class='warning'>You quickly cash out your funds to a more secure banking location. Funds are safu.</span>")
			card.registered_account.being_dumped = FALSE	
	else
		return ..()
