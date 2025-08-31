///Maximum credits dump threshold
#define CREDITS_DUMP_THRESHOLD 50
/**
 * # vending record datum
 * A datum that represents a product that is vendable
 */
/datum/data/vending_product
	name = "generic"
	///Typepath of the product that is created when this record "sells"
	var/product_path = null
	///How many of this product we currently have
	var/amount = 0
	///How many we can store at maximum
	var/max_amount = 0
	///The price of the item
	var/price
	///Whether spessmen with an ID with an age below AGE_MINOR (20 by default) can buy this item
	var/age_restricted = FALSE
	///Whether the product can be recolored by the GAGS system
	var/colorable
	/// The category the product was in, if any.
	/// Sourced directly from product_categories.
	var/category
	///List of items that have been returned to the vending machine.
	var/list/returned_products

/datum/data/vending_product/Destroy(force)
	returned_products = null
	return ..()

/**
 * # vending machines
 *
 * Captalism in the year 2525, everything in a vending machine, even love
 */
/obj/machinery/vending
	name = "\improper Vendomat"
	desc = "A generic vending machine."
	icon = 'icons/obj/machines/vending.dmi'
	icon_state = "generic"
	layer = BELOW_OBJ_LAYER
	density = TRUE
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	max_integrity = 300
	integrity_failure = 0.33
	armor_type = /datum/armor/machinery_vending
	circuit = /obj/item/circuitboard/machine/vendor
	payment_department = ACCOUNT_SRV
	light_power = 0.7
	light_range = MINIMUM_USEFUL_LIGHT_RANGE
	voice_filter = "alimiter=0.9,acompressor=threshold=0.2:ratio=20:attack=10:release=50:makeup=2,highpass=f=1000"

	///Next world time to send a purchase message
	var/purchase_message_cooldown
	///The ref of the last mob to shop with us
	var/last_shopper
	///Whether the vendor is tilted or not
	var/tilted = FALSE
	/// If tilted, this variable should always be the rotation that was applied when we were tilted. Stored for the purposes of unapplying it.
	var/tilted_rotation = 0
	///Whether this vendor can be tilted over or not
	var/tiltable = TRUE
	///Damage this vendor does when tilting onto an atom
	var/squish_damage = 75
	/// The chance, in percent, of this vendor performing a critical hit on anything it crushes via [tilt].
	var/crit_chance = 15
	///List of mobs stuck under the vendor
	var/list/pinned_mobs = list()
	///Icon for the maintenance panel overlay
	var/panel_type = "panel1"
	///Whether this vendor can be selected when building a custom vending machine
	var/allow_custom = FALSE

	/**
	  * List of products this machine sells
	  *
	  * form should be list(/type/path = amount, /type/path2 = amount2)
	  */
	var/list/products = list()

	/**
	 * List of products this machine sells, categorized.
	 * Can only be used as an alternative to `products`, not alongside it.
	 *
	 * Form should be list(
	 * 	"name" = "Category Name",
	 * 	"icon" = "UI Icon (Font Awesome or tgfont)",
	 * 	"products" = list(/type/path = amount, ...),
	 * )
	 */
	var/list/product_categories = null

	/**
	  * List of products this machine sells when you hack it
	  *
	  * form should be list(/type/path = amount, /type/path2 = amount2)
	  */
	var/list/contraband = list()

	/**
	  * List of premium products this machine sells
	  *
	  * form should be list(/type/path = amount, /type/path2 = amount2)
	  */
	var/list/premium = list()

	///String of slogans separated by semicolons, optional
	var/product_slogans = ""
	///String of small ad messages in the vending screen - random chance
	var/product_ads = ""

	///List of standard product records
	var/list/datum/data/vending_product/product_records = list()
	///List of contraband product records
	var/list/datum/data/vending_product/hidden_records = list()
	///List of premium product records
	var/list/datum/data/vending_product/coin_records = list()
	///List of slogans to scream at potential customers; built upon Iniitialize() of the vendor from product_slogans
	var/list/slogan_list = list()
	///List of ads built from product_ads upon Iniitialize()
	var/list/ad_list = list()
	///Message sent post vend (Thank you for shopping!)
	var/vend_reply
	///Last world tick we sent a vent reply
	var/last_reply = 0
	///Last world tick we sent a slogan message out
	var/last_slogan = 0
	///How many ticks until we can send another
	var/slogan_delay = 10 MINUTES
	///Icon when vending an item to the user
	var/icon_vend
	///Icon to flash when user is denied a vend
	var/icon_deny
	///World ticks the machine is electified for
	var/seconds_electrified = MACHINE_NOT_ELECTRIFIED
	///When this is TRUE, we fire items at customers! We're broken!
	var/shoot_inventory = FALSE
	///How likely this is to happen (prob 100) per second
	var/shoot_inventory_chance = 1
	//Stop spouting those godawful pitches!
	var/shut_up = FALSE
	///can we access the hidden inventory?
	var/extended_inventory = FALSE
	///Are we checking the users ID
	var/scan_id = TRUE
	///Default price of items if not overridden
	var/default_price = 25
	///Default price of premium items if not overridden
	var/extra_price = 50
	///fontawesome icon name to use in to display the user's balance in the vendor UI
	var/displayed_currency_icon = "coins"
	///String of the used currency to display in the vendor UI
	var/displayed_currency_name = " cr"
	///Whether our age check is currently functional
	var/age_restrictions = TRUE
	/// How many credits does this vending machine have? 20% of all sales go to this pool, and are given freely when the machine is restocked, or successfully tilted. Lost on deconstruction.
	var/credits_contained = 0
	/**
	  * Is this item on station or not
	  *
	  * if it doesn't originate from off-station during mapload, all_products_free gets automatically set to TRUE if it was unset previously.
	  * if it's off-station during mapload, it's also safe from the brand intelligence event
	  */
	var/onstation = TRUE
	/**
	 * DO NOT APPLY THIS GLOBALLY. For mapping var edits only.
	 * A variable to change on a per instance basis that allows the instance to avoid having onstation set for them during mapload.
	 * Setting this to TRUE means that the vending machine is treated as if it were still onstation if it spawns off-station during mapload.
	 * Useful to specify an off-station machine that will be affected by machine-brand intelligence for whatever reason.
	 */
	var/onstation_override = FALSE
	/**
	 * If this is set to TRUE, all products sold by the vending machine are free (cost nothing).
	 * If unset, this will get automatically set to TRUE during init if the machine originates from off-station during mapload.
	 * Defaults to null, set it to TRUE or FALSE explicitly on a per-machine basis if you want to force it to be a certain value.
	 */
	var/all_products_free

	//The type of refill canisters used by this machine.
	var/obj/item/vending_refill/refill_canister = null

	///Name of lighting mask for the vending machine
	var/light_mask

	//the path of the fish_source datum to use for the fishing_spot component
	var/fish_source_path = /datum/fish_source/vending

/datum/armor/machinery_vending
	melee = 20
	fire = 50
	acid = 70

/**
 * Initialize the vending machine
 *
 * Builds the vending machine inventory, sets up slogans and other such misc work
 *
 * This also sets the onstation var to:
 * * FALSE - if the machine was maploaded on a zlevel that doesn't pass the is_station_level check
 * * TRUE - all other cases
 */
/obj/machinery/vending/Initialize(mapload)
	//means we produce products with fixed amounts
	if(!refill_canister)
		circuit = null
		RefreshParts()

	. = ..()

	set_wires(new /datum/wires/vending(src))

	if(SStts.tts_enabled)
		var/static/vendor_voice_by_type = list()
		if(!vendor_voice_by_type[type])
			vendor_voice_by_type[type] = pick(SStts.available_speakers)
		voice = vendor_voice_by_type[type]

	slogan_list = splittext(product_slogans, ";")
	ad_list = splittext(product_ads, ";")
	// So not all machines speak at the exact same time.
	// The first time this machine says something will be at slogantime + this random value,
	// so if slogantime is 10 minutes, it will say it at somewhere between 10 and 20 minutes after the machine is crated.
	last_slogan = world.time + rand(0, slogan_delay)
	power_change()

	if(mapload) //check if it was initially created off station during mapload.
		if(!is_station_level(z))
			if(!onstation_override)
				onstation = FALSE
				if(isnull(all_products_free)) // Only auto-set the free products var if we haven't explicitly assigned a value to it yet.
					all_products_free = TRUE
			if(circuit)
				circuit.all_products_free = all_products_free //sync up the circuit so the pricing schema is carried over if it's reconstructed.

	else if(circuit)
		all_products_free = circuit.all_products_free //if it was constructed outside mapload, sync the vendor up with the circuit's var so you can't bypass price requirements by moving / reconstructing it off station.
	if(!all_products_free)
		AddComponent(/datum/component/payment, 0, SSeconomy.get_dep_account(payment_department), PAYMENT_VENDING)
	register_context()

	if(fish_source_path)
		AddComponent(/datum/component/fishing_spot, fish_source_path)

/obj/machinery/vending/atom_break(damage_flag)
	. = ..()
	if(!.)
		return

	var/dump_amount = 0
	var/found_anything = TRUE
	while (found_anything)
		found_anything = FALSE
		for(var/datum/data/vending_product/record as anything in shuffle(product_records))
			//first dump any of the items that have been returned, in case they contain the nuke disk or something
			for(var/i in 1 to LAZYLEN(record.returned_products))
				var/obj/item/returned_obj_to_dump = dispense(record, get_turf(src), dispense_returned = TRUE)
				step(returned_obj_to_dump, pick(GLOB.alldirs))

			if(record.amount <= 0) //Try to use a record that actually has something to dump.
				continue
			var/dump_path = record.product_path
			if(!dump_path)
				continue
			// busting open a vendor will destroy some of the contents
			if(found_anything && prob(80))
				record.amount--
				continue

			var/obj/obj_to_dump = dispense(record, loc)
			step(obj_to_dump, pick(GLOB.alldirs))
			found_anything = TRUE
			dump_amount++
			if (dump_amount >= 16)
				return

/obj/machinery/vending/on_deconstruction(disassembled)
	var/obj/item/vending_refill/installed_refill = locate() in component_parts
	if(!installed_refill)
		return

	var/list/datum/data/vending_product/record_list
	var/list/canister_list
	for(var/i in 1 to 3)
		switch(i)
			if (1)
				record_list = product_records
				canister_list = installed_refill.products
			if (2)
				record_list = hidden_records
				canister_list = installed_refill.contraband
			else
				record_list = coin_records
				canister_list = installed_refill.premium

		canister_list.Cut()
		for(var/datum/data/vending_product/record as anything in record_list)
			var/stock = record.amount - LAZYLEN(record.returned_products)
			if(stock)
				canister_list[record.product_path] = stock

/obj/machinery/vending/Destroy()
	QDEL_LIST(product_records)
	QDEL_LIST(hidden_records)
	QDEL_LIST(coin_records)
	return ..()

/obj/machinery/vending/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = NONE
	if(tilted && !held_item)
		context[SCREENTIP_CONTEXT_LMB] = "Right machine"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item?.tool_behaviour == TOOL_SCREWDRIVER)
		context[SCREENTIP_CONTEXT_LMB] = "[panel_open ? "Close" : "Open"] Panel"
		return CONTEXTUAL_SCREENTIP_SET

	if(panel_open && held_item?.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = anchored ? "Unsecure" : "Secure"
		return CONTEXTUAL_SCREENTIP_SET

	if(panel_open && held_item?.tool_behaviour == TOOL_CROWBAR)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET

	if(!isnull(held_item) && canLoadItem(held_item, user, send_message = FALSE))
		context[SCREENTIP_CONTEXT_LMB] = "Load item"
		return CONTEXTUAL_SCREENTIP_SET

	if(panel_open && istype(held_item, refill_canister))
		context[SCREENTIP_CONTEXT_LMB] = "Restock vending machine[credits_contained ? " and collect credits" : null]"
		return CONTEXTUAL_SCREENTIP_SET

/**
 * Returns the total loaded & max amount of items i.e list(total_loaded, total_maximum) in the vending machine based on the product records and premium records
 *
 * Arguments
 * * contraband - should we count contrabrand as well
*/
/obj/machinery/vending/proc/total_stock(contrabrand = TRUE)
	SHOULD_BE_PURE(TRUE)
	SHOULD_NOT_OVERRIDE(TRUE)
	RETURN_TYPE(/list)

	var/total_loaded = 0
	var/total_max = 0
	var/list/stock = product_records + coin_records
	if(contrabrand)
		stock += hidden_records
	for(var/datum/data/vending_product/record as anything in stock)
		total_loaded += record.amount
		total_max += record.max_amount
	return list(total_loaded, total_max)

/obj/machinery/vending/examine(mob/user)
	. = ..()
	if(isnull(refill_canister))
		return // you can add the comment here instead

	. += span_notice("Its maintainence panel can be [EXAMINE_HINT("screwed")] [panel_open ? "closed" : "open"]")
	if(panel_open)
		. += span_notice("The machine may be [EXAMINE_HINT("pried")] apart.")

	var/list/total_stock = total_stock()
	if(total_stock[2])
		if(total_stock[1] < total_stock[2])
			. += span_notice("\The [src] can be restocked with [span_boldnotice("\a [initial(refill_canister.machine_name)] [initial(refill_canister.name)]")] with the panel open.")
		else
			. += span_notice("\The [src] is fully stocked.")
	if(credits_contained < CREDITS_DUMP_THRESHOLD && credits_contained > 0)
		. += span_notice("It should have a handfull of credits stored based on the missing items.")
	else if (credits_contained > PAYCHECK_CREW)
		. += span_notice("It should have at least a full paycheck worth of credits inside!")

/obj/machinery/vending/update_appearance(updates = ALL)
	. = ..()
	if(machine_stat & BROKEN)
		set_light(0)
		return
	set_light(powered() ? MINIMUM_USEFUL_LIGHT_RANGE : 0)

/obj/machinery/vending/update_icon_state()
	if(machine_stat & BROKEN)
		icon_state = "[initial(icon_state)]-broken"
		return ..()
	icon_state = "[initial(icon_state)][powered() ? null : "-off"]"
	return ..()

/obj/machinery/vending/update_overlays()
	. = ..()
	if(panel_open)
		. += panel_type
	if(light_mask && !(machine_stat & BROKEN) && powered())
		. += emissive_appearance(icon, light_mask, src)

/obj/machinery/vending/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, all_products_free))
		if (all_products_free)
			qdel(GetComponent(/datum/component/payment))
		else
			AddComponent(/datum/component/payment, 0, SSeconomy.get_dep_account(payment_department), PAYMENT_VENDING)
		update_static_data_for_all_viewers()

/obj/machinery/vending/emp_act(severity)
	. = ..()
	var/datum/language_holder/vending_languages = get_language_holder()
	var/datum/wires/vending/vending_wires = wires
	// if the language wire got pulsed during an EMP, this will make sure the language_iterator is synched correctly
	vending_languages.selected_language = vending_languages.spoken_languages[vending_wires.language_iterator]

/obj/machinery/vending/unbuckle_mob(mob/living/buckled_mob, force = FALSE, can_fall = TRUE)
	if(!force)
		return
	. = ..()

/obj/machinery/vending/emag_act(mob/user, obj/item/card/emag/emag_card)
	if(obj_flags & EMAGGED)
		return FALSE
	obj_flags |= EMAGGED
	balloon_alert(user, "product lock disabled")
	return TRUE


/obj/machinery/vending/power_change()
	. = ..()
	if(powered())
		START_PROCESSING(SSmachines, src)

/obj/machinery/vending/process(seconds_per_tick)
	if(!is_operational)
		return PROCESS_KILL

	if(seconds_electrified > MACHINE_NOT_ELECTRIFIED)
		seconds_electrified--

	//Pitch to the people!  Really sell it!
	if(last_slogan + slogan_delay <= world.time && slogan_list.len && !shut_up && SPT_PROB(2.5, seconds_per_tick))
		say(pick(slogan_list))
		last_slogan = world.time

	if(shoot_inventory && SPT_PROB(shoot_inventory_chance, seconds_per_tick))
		throw_item()


//===============================SPEACH===================================================
/obj/machinery/vending/can_speak(allow_mimes)
	return is_operational && !shut_up && ..()


/**
 * Speak the given message verbally
 * Checks if the machine is powered and the message exists
 *
 * Arguments:
 * * message - the message to speak
 */
/obj/machinery/vending/proc/speak(message)
	if(!is_operational)
		return
	if(!message)
		return

	say(message)

/datum/aas_config_entry/vendomat_age_control
	name = "Security Alert: Underaged Substance Abuse"
	announcement_lines_map = list(
		"Message" = "SECURITY ALERT: Underaged crewmember %PERSON recorded attempting to purchase %PRODUCT in %LOCATION by %VENDOR. Please watch for substance abuse."
	)
	vars_and_tooltips_map = list(
		"PERSON" = "will be replaced with the name of the crewmember",
		"PRODUCT" = "with the product, he attempted to purchase",
		"LOCATION" = "with place of purchase",
		"VENDOR" = "with the vending machine"
	)
//=============================================================================
