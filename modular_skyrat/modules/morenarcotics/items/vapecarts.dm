/obj/item/reagent_containers/vapecart
	name = "vape cart"
	desc = "A vape cart filled with nicotine."
	icon = 'modular_skyrat/modules/morenarcotics/icons/crack.dmi'
	icon_state = "vapecart"
	fill_icon_state = "vapecart"
	volume = 50
	possible_transfer_amounts = list()
	list_reagents = list(/datum/reagent/drug/nicotine = 50)
	fill_icon_thresholds = list(0, 5, 20, 40)
	custom_price = PAYCHECK_ASSISTANT

/obj/item/reagent_containers/vapecart/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(istype(target, /obj/item/clothing/mask/vape))
		var/obj/item/clothing/mask/vape/target_vape = target
		if(target_vape.screw == TRUE && !target_vape.reagents.total_volume)
			src.reagents.trans_to(target_vape, src.volume, transfered_by = user)
			qdel(src)
			to_chat(user, span_notice("You plug the [src.name] into the vape.</span>"))
		else if(!target_vape.screw)
			to_chat(user, span_warning("You need to open the cap to do that!</span>"))
		else
			to_chat(user, span_warning("[target_vape] is already full!</span>"))

/obj/item/reagent_containers/vapecart/empty
	name = "customizable vape cart"
	desc = "Fill with whatever hazardous concoction of chemicals you desire!"
	list_reagents = list()
	reagent_flags = OPENCONTAINER
	var/labelled = FALSE

/obj/item/reagent_containers/vapecart/empty/attack_self(mob/user)
	if(reagents.total_volume > 0)
		to_chat(user, span_notice("You empty [src] of all reagents.</span>"))
		reagents.clear_reagents()

/obj/item/reagent_containers/vapecart/empty/attackby(obj/item/attacked_item, mob/user, params)
	if (istype(attacked_item, /obj/item/pen) || istype(attacked_item, /obj/item/toy/crayon))
		if(!user.is_literate())
			to_chat(user, span_notice("You scribble illegibly on the label of the vape cart!</span>"))
			return
		var/new_title = stripped_input(user, "What would you like to label the vape cart?", name, null, 53)
		if(!user.canUseTopic(src, BE_CLOSE))
			return
		if(user.get_active_held_item() != attacked_item)
			return
		if(new_title)
			labelled = TRUE
			name = "[new_title]"
		else
			labelled = FALSE
			update_name()
	else
		return ..()

/obj/item/reagent_containers/vapecart/empty/update_name(updates)
	. = ..()
	if(labelled)
		return
	name = "customizable vape cart"

//thc carts
/obj/item/reagent_containers/vapecart/bluekush
	name = "Dr. Breen's Blue Kush Reserve cart"
	desc = "Don't smoke the carts... They put something in it... t-to make you forget! I don't even remember how I got here..."
	list_reagents = list(/datum/reagent/drug/thc = 20, /datum/reagent/consumable/berryjuice = 10)
	custom_price = PAYCHECK_MEDIUM

/obj/item/reagent_containers/vapecart/reddiesel
	name = "Resistance Red Diesel cart"
	desc = "Seems to be endorsed by a real scientist!"
	list_reagents = list(/datum/reagent/drug/thc = 20, /datum/reagent/consumable/dr_gibb = 10)
	custom_price = PAYCHECK_MEDIUM

/obj/item/reagent_containers/vapecart/pwrgame
	name = "Pwr Haze cart"
	desc = "When did Pwr Game get into the cart business?"
	list_reagents = list(/datum/reagent/drug/thc = 20, /datum/reagent/consumable/pwr_game = 10)
	custom_price = PAYCHECK_MEDIUM

/obj/item/reagent_containers/vapecart/cheese
	name = "Cheesie Honker OG Kush cart"
	desc = "*Contains no real cheese."
	list_reagents = list(/datum/reagent/drug/thc = 20, /datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/sugar = 3)
	custom_price = PAYCHECK_MEDIUM

/obj/item/reagent_containers/vapecart/syndicate
	name = "Syndikush Green Crack cart"
	desc = "Green Crack is a strain of sativa, not actual crack."
	list_reagents = list(/datum/reagent/drug/thc = 20, /datum/reagent/medicine/stimulants = 10)
	custom_price = PAYCHECK_MEDIUM
