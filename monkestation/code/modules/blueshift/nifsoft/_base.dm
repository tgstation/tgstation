GLOBAL_LIST_INIT(purchasable_nifsofts, list(
	/datum/nifsoft/hivemind,
	/datum/nifsoft/soul_poem,
	/datum/nifsoft/soulcatcher,
))

/datum/computer_file/program/nifsoft_downloader
	filename = "nifsoftcatalog"
	filedesc = "NIFSoft Catalog"
	extended_desc = "A virtual storefront that allows the user to install NIFSofts and purchase various NIF related products"
	category = PROGRAM_CATEGORY_DEVICE
	size = 3
	tgui_id = "NtosNifsoftCatalog"
	program_icon = "bag-shopping"
	usage_flags = PROGRAM_TABLET
	///What bank account is money being drawn out of?
	var/datum/bank_account/paying_account
	///What NIF are the NIFSofts being sent to?
	var/datum/weakref/target_nif

/datum/computer_file/program/nifsoft_downloader/Destroy(force)
	paying_account = null
	target_nif = null

	return ..()

//TGUI STUFF

/datum/computer_file/program/nifsoft_downloader/ui_data(mob/user)
	var/list/data = list()

	paying_account = computer.computer_id_slot?.registered_account || null
	data["paying_account"] = paying_account
	data["current_balance"] = computer.computer_id_slot?.registered_account?.account_balance

	var/rewards_points = 0

	if(target_nif)
		var/obj/item/organ/internal/cyberimp/brain/nif/buyer_nif = target_nif.resolve()
		if(buyer_nif)
			rewards_points = buyer_nif.rewards_points

	data["rewards_points"] = rewards_points
	return data

/datum/computer_file/program/nifsoft_downloader/ui_static_data(mob/user)
	var/list/data = list()
	var/list/product_list = list()

	var/mob/living/carbon/human/nif_user = user
	if(!ishuman(nif_user))
		target_nif = null

	else
		var/obj/item/organ/internal/cyberimp/brain/nif/user_nif = nif_user.get_organ_by_type(/obj/item/organ/internal/cyberimp/brain/nif)
		if(!user_nif)
			target_nif = null

		if(!target_nif || user_nif != target_nif.resolve())
			target_nif = WEAKREF(user_nif)

	data["target_nif"] = target_nif

	for(var/datum/nifsoft/buyable_nifsoft as anything in GLOB.purchasable_nifsofts)
		if(!buyable_nifsoft)
			continue

		var/list/nifsoft_details = list(
			"name" = initial(buyable_nifsoft.name),
			"desc" = initial(buyable_nifsoft.program_desc),
			"price" = initial(buyable_nifsoft.purchase_price),
			"rewards_points_rate" = initial(buyable_nifsoft.rewards_points_rate),
			"points_purchasable" = initial(buyable_nifsoft.rewards_points_eligible),
			"category" = initial(buyable_nifsoft.buying_category),
			"ui_icon" = initial(buyable_nifsoft.ui_icon),
			"reference" = buyable_nifsoft,
			"keepable" = initial(buyable_nifsoft.able_to_keep),
		)
		var/category = nifsoft_details["category"]
		if(!(category in product_list))
			product_list[category] += (list(name = category, products = list()))

		product_list[category]["products"] += list(nifsoft_details)

	for(var/product_category in product_list)
		data["product_list"] += list(product_list[product_category])

	return data

/datum/computer_file/program/nifsoft_downloader/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("purchase_product")
			var/datum/nifsoft/product_to_buy = text2path(params["product_to_buy"])
			if(!product_to_buy || !paying_account)
				return FALSE

			var/amount_to_charge = (params["product_cost"])
			var/rewards_purchase = (params["rewards_purchase"])

			if(!target_nif)
				paying_account.bank_card_talk("You need a NIF implant to purchase this.")
				return FALSE

			var/obj/item/organ/internal/cyberimp/brain/nif/buyer_nif = target_nif.resolve()

			if(rewards_purchase)
				if(buyer_nif.rewards_points < amount_to_charge)
					buyer_nif.send_message("You don't have enough reward points to buy this.", alert = TRUE)
					return FALSE

			else if(!paying_account.has_money(amount_to_charge))
				paying_account.bank_card_talk("You lack the money to make this purchase.")
				return FALSE

			if(!ispath(product_to_buy, /datum/nifsoft) || !buyer_nif)
				paying_account.bank_card_talk("You are unable to buy this.")
				return FALSE

			var/datum/nifsoft/installed_nifsoft = new product_to_buy(buyer_nif, rewards_purchase)
			if(!installed_nifsoft.parent_nif)
				paying_account.bank_card_talk("Install failed, your purchase has been refunded.")
				return FALSE

			if(rewards_purchase)
				buyer_nif.remove_rewards_points(amount_to_charge)
				buyer_nif.send_message("Purchase completed, [amount_to_charge] reward points have been removed from your NIF")
			else
				paying_account.adjust_money(-amount_to_charge, "NIFSoft purchase")
				paying_account.bank_card_talk("Transaction complete, you have been charged [amount_to_charge]cr.")

			return TRUE

#define DEFAULT_NIFSOFT_COOLDOWN 5 SECONDS

///The base NIFSoft
/datum/nifsoft
	///What is the name of the NIFSoft?
	var/name = "Generic NIFsoft"
	///What is the name of the program when looking at the program from inside of a NIF? This is good if you want to mask a NIFSoft's name.
	var/program_name
	///A description of what the program does. This is used when looking at programs in the NIF, along with installing them from the store.
	var/program_desc = "This program does stuff!"
	//What NIF does this program belong to?
	var/datum/weakref/parent_nif
	///Who is the NIF currently linked to?
	var/mob/living/carbon/human/linked_mob
	///How much does the program cost to buy in credits?
	var/purchase_price = 300
	///What catagory is the NIFSoft under?
	var/buying_category = NIFSOFT_CATEGORY_GENERAL
	///What font awesome icon is shown next to the name of the nifsoft?
	var/ui_icon = "floppy-disk"
	///What UI theme do we want to display to users if this NIFSoft has TGUI?
	var/ui_theme = "default"

	///Can the program be installed with other instances of itself?
	var/single_install = TRUE
	///Is the program mutually exclusive with another program?
	var/list/mutually_exclusive_programs = list()

	///Does the program have an active mode?
	var/active_mode = FALSE
	///Is the program active?
	var/active = FALSE
	///Does the what power cost does the program have while active?
	var/active_cost = 0
	///What is the power cost to activate the program?
	var/activation_cost = 0
	///Does the NIFSoft have a cooldown?
	var/cooldown = FALSE
	///Is the NIFSoft currently on cooldown?
	var/on_cooldown = FALSE
	///How long is the cooldown for?
	var/cooldown_duration = DEFAULT_NIFSOFT_COOLDOWN
	///What NIF models can this software be installed on?
	var/list/compatible_nifs = list(/obj/item/organ/internal/cyberimp/brain/nif)

	/// How much of the NIFSoft's purchase price is paid out as reward points, if any?
	var/rewards_points_rate = 0.5
	/// Can this item be purchased with reward points?
	var/rewards_points_eligible = TRUE
	///Does the NIFSoft have anything that is saved cross-round?
	var/persistence = FALSE
	/// Is the NIFSoft something that we want to allow the user to keep?
	var/able_to_keep = FALSE
	/// Are we keeping the NIFSoft installed between rounds? This is decided by the user
	var/keep_installed = FALSE

/datum/nifsoft/New(obj/item/organ/internal/cyberimp/brain/nif/recepient_nif, no_rewards_points = FALSE)
	. = ..()

	if(no_rewards_points) //This is mostly so that credits can't be farmed through printed or stolen NIFSoft disks
		rewards_points_rate = 0

	compatible_nifs += /obj/item/organ/internal/cyberimp/brain/nif/debug
	program_name = name

	if(!recepient_nif.install_nifsoft(src))
		qdel(src)

	load_persistence_data()
	update_theme()

/datum/nifsoft/Destroy()
	if(active)
		activate()

	linked_mob = null

	var/obj/item/organ/internal/cyberimp/brain/nif/installed_nif = parent_nif?.resolve()
	if(installed_nif)
		installed_nif.loaded_nifsofts.Remove(src)

	return ..()

/// Activates the parent NIFSoft
/datum/nifsoft/proc/activate()
	var/obj/item/organ/internal/cyberimp/brain/nif/installed_nif = parent_nif?.resolve()

	if(!installed_nif)
		stack_trace("NIFSoft [src] activated on a null parent!") // NIFSoft is -really- broken
		return FALSE

	if(installed_nif.broken)
		installed_nif.balloon_alert(installed_nif.linked_mob, "your NIF is broken")
		return FALSE

	if(cooldown && on_cooldown)
		installed_nif.balloon_alert(installed_nif.linked_mob, "[src.name] is currently on cooldown.")
		return FALSE

	if(active)
		active = FALSE
		installed_nif.balloon_alert(installed_nif.linked_mob, "[src.name] is no longer running")
		installed_nif.power_usage -= active_cost
		return TRUE

	if(!installed_nif.change_power_level(activation_cost))
		return FALSE

	if(active_mode)
		installed_nif.balloon_alert(installed_nif.linked_mob, "[src.name] is now running")
		installed_nif.power_usage += active_cost
		active = TRUE

	if(cooldown)
		addtimer(CALLBACK(src, PROC_REF(remove_cooldown)), cooldown_duration)
		on_cooldown = TRUE

	return TRUE

///Refunds the activation cost of a NIFSoft.
/datum/nifsoft/proc/refund_activation_cost()
	var/obj/item/organ/internal/cyberimp/brain/nif/installed_nif = parent_nif?.resolve()
	if(!installed_nif)
		return
	installed_nif.change_power_level(-activation_cost)

///Removes the cooldown from a NIFSoft
/datum/nifsoft/proc/remove_cooldown()
	on_cooldown = FALSE

///Restores the name of the NIFSoft to default.
/datum/nifsoft/proc/restore_name()
	program_name = initial(name)

///How does the NIFSoft react if the user is EMP'ed?
/datum/nifsoft/proc/on_emp(emp_severity)
	if(active)
		activate()

	var/list/random_characters = list("#","!","%","^","*","$","@","^","A","b","c","D","F","W","H","Y","z","U","O","o")
	var/scrambled_name = "!"

	for(var/i in 1 to length(program_name))
		scrambled_name += pick(random_characters)

	program_name = scrambled_name
	addtimer(CALLBACK(src, PROC_REF(restore_name)), 60 SECONDS)

/datum/nifsoft/ui_state(mob/user)
	return GLOB.conscious_state

/// Updates the theme of the NIFSoft to match the parent NIF
/datum/nifsoft/proc/update_theme()
	var/obj/item/organ/internal/cyberimp/brain/nif/target_nif = parent_nif.resolve()
	if(!target_nif)
		return FALSE

	ui_theme = target_nif.current_theme
	return TRUE

/// A disk that can upload NIFSofts to a recpient with a NIFSoft installed.
/obj/item/disk/nifsoft_uploader
	name = "Generic NIFSoft datadisk"
	desc = "A datadisk that can be used to upload a loaded NIFSoft to the user's NIF"
	icon = 'monkestation/code/modules/blueshift/icons/obj/disks.dmi'
	icon_state = "base_disk"
	///What NIFSoft is currently loaded in?
	var/datum/nifsoft/loaded_nifsoft = /datum/nifsoft
	///Is the datadisk reusable?
	var/reusable = FALSE

/obj/item/disk/nifsoft_uploader/Initialize(mapload)
	. = ..()

	name = "[initial(loaded_nifsoft.name)] datadisk"

/obj/item/disk/nifsoft_uploader/examine(mob/user)
	. = ..()

	var/nifsoft_desc = initial(loaded_nifsoft.program_desc)

	if(nifsoft_desc)
		. += span_cyan("Program description: [nifsoft_desc]")


/// Attempts to install the NIFSoft on the disk to the target
/obj/item/disk/nifsoft_uploader/proc/attempt_software_install(mob/living/carbon/human/target)
	var/obj/item/organ/internal/cyberimp/brain/nif/installed_nif = target.get_organ_by_type(/obj/item/organ/internal/cyberimp/brain/nif)

	if(!ishuman(target) || !installed_nif)
		return FALSE

	var/datum/nifsoft/installed_nifsoft = new loaded_nifsoft(installed_nif, TRUE)

	if(!installed_nifsoft.parent_nif)
		balloon_alert(target, "installation failed")
		return FALSE

	if(!reusable)
		qdel(src)

/obj/item/disk/nifsoft_uploader/attack_self(mob/user, modifiers)
	attempt_software_install(user)

/obj/item/disk/nifsoft_uploader/attack(mob/living/mob, mob/living/user, params)
	if(mob != user && !do_after(user, 5 SECONDS, mob))
		balloon_alert(user, "installation failed")
		return FALSE

	attempt_software_install(mob)

#undef DEFAULT_NIFSOFT_COOLDOWN

/obj/item/organ/internal/cyberimp/brain/nif
	///Currently Avalible themese for the NIFs
	var/static/list/ui_themes = list(
		"abductor",
		"cardtable",
		"hackerman",
		"malfunction",
		"default",
		"ntos",
		"ntos_darkmode",
		"ntOS95",
		"ntos_synth",
		"ntos_terminal",
		"wizard",
	)
	///What theme is currently being used on the NIF?
	var/current_theme = "default"

/obj/item/organ/internal/cyberimp/brain/nif/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)

	if(!ui)
		ui = new(user, src, "NifPanel", name)
		ui.open()

/obj/item/organ/internal/cyberimp/brain/nif/ui_state(mob/user)
	return GLOB.conscious_state

/obj/item/organ/internal/cyberimp/brain/nif/ui_status(mob/user)
	if(user == linked_mob)
		return UI_INTERACTIVE
	return UI_CLOSE

/obj/item/organ/internal/cyberimp/brain/nif/ui_static_data(mob/user)
	var/list/data = list()

	data["loaded_nifsofts"] = list()
	for(var/datum/nifsoft/nifsoft as anything in loaded_nifsofts)
		var/list/nifsoft_data = list(
			"name" = nifsoft.program_name,
			"desc" = nifsoft.program_desc,
			"active" = nifsoft.active,
			"active_mode" = nifsoft.active_mode,
			"activation_cost" = nifsoft.activation_cost,
			"active_cost" = nifsoft.active_cost,
			"reference" = REF(nifsoft),
			"ui_icon" = nifsoft.ui_icon,
			"able_to_keep" = nifsoft.able_to_keep,
			"keep_installed" = nifsoft.keep_installed,
		)
		data["loaded_nifsofts"] += list(nifsoft_data)

	data["ui_themes"] = ui_themes
	data["max_nifsofts"] = max_nifsofts
	data["max_durability"] = max_durability
	data["max_power"] = max_power_level
	data["max_blood_level"] = linked_mob.blood_volume
	data["product_notes"] = manufacturer_notes
	data["stored_points"] = rewards_points

	return data

/obj/item/organ/internal/cyberimp/brain/nif/ui_data(mob/user)
	var/list/data = list()
	//User Preference Variables
	data["linked_mob_name"] = linked_mob.name
	data["current_theme"] = current_theme

	//Power Variables
	data["power_level"] = power_level
	data["power_usage"] = power_usage

	data["nutrition_drain"] = nutrition_drain
	data["nutrition_level"] = linked_mob.nutrition

	data["blood_level"] = linked_mob.blood_volume
	data["blood_drain"] = blood_drain
	data["minimum_blood_level"] = minimum_blood_level

	//Durability Variables.
	data["durability"] = durability

	return data

/obj/item/organ/internal/cyberimp/brain/nif/ui_act(action, list/params)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle_nutrition_drain")
			toggle_nutrition_drain()

		if("toggle_blood_drain")
			toggle_blood_drain()

		if("change_examine_text")
			var/text_to_use = html_encode(params["new_text"])
			var/datum/component/nif_examine/examine_datum = linked_mob.GetComponent(/datum/component/nif_examine)

			if(!examine_datum)
				return FALSE

			if(!text_to_use || length(text_to_use) <= 6)
				examine_datum.nif_examine_text = "There's a certain spark to their eyes."
				return FALSE

			examine_datum.nif_examine_text = text_to_use

		if("uninstall_nifsoft")
			var/nifsoft_to_remove = locate(params["nifsoft_to_remove"]) in loaded_nifsofts
			if(!nifsoft_to_remove)
				return FALSE

			remove_nifsoft(nifsoft_to_remove)

		if("change_theme")
			var/target_theme = params["target_theme"]

			if(!target_theme || !(target_theme in ui_themes))
				return FALSE

			current_theme = target_theme
			for(var/datum/nifsoft/installed_nifsoft as anything in loaded_nifsofts)
				installed_nifsoft.update_theme()

		if("activate_nifsoft")
			var/datum/nifsoft/activated_nifsoft = locate(params["activated_nifsoft"]) in loaded_nifsofts
			if(!activated_nifsoft)
				return FALSE

			activated_nifsoft.activate()

		if("toggle_keeping_nifsoft")
			var/datum/nifsoft/nifsoft_to_keep = locate(params["nifsoft_to_keep"]) in loaded_nifsofts
			if(!nifsoft_to_keep || !nifsoft_to_keep.able_to_keep)
				return FALSE

			nifsoft_to_keep.keep_installed = !nifsoft_to_keep.keep_installed
			update_static_data_for_all_viewers()

/// How much damage is done to the NIF if the user ends the round with it uninstalled?
#define LOSS_WITH_NIF_UNINSTALLED 25

/datum/modular_persistence
	// These are not handled by the prefs system. They are just stored here for convienience.
	/// The path to the current implanted NIF. Can be null.
	var/nif_path
	/// The current durability of the implanted NIF. Can be null.
	var/nif_durability
	/// The extra examine text for the user of the NIF. Can be null.
	var/nif_examine_text
	/// The theme of the implanted NIF. Can be null.
	var/nif_theme
	/// Whether the NIF is calibrated for use or not. Can be null.
	var/nif_is_calibrated
	/// How many rewards points does the NIF have stored on it?
	var/stored_rewards_points
	/// A string containing programs that are transfered from one round to the next.
	var/persistent_nifsofts

/// Saves the NIF data for a individual user.
/mob/living/carbon/human/proc/save_nif_data(datum/modular_persistence/persistence, remove_nif = FALSE)
	var/obj/item/organ/internal/cyberimp/brain/nif/installed_nif = get_organ_by_type(/obj/item/organ/internal/cyberimp/brain/nif)

	if(HAS_TRAIT(src, TRAIT_GHOSTROLE)) //Nothing is lost from playing a ghost role
		return FALSE

	if(remove_nif)
		qdel(installed_nif)
		persistence.nif_path = null
		persistence.nif_examine_text = null
		return

	if(!installed_nif || (installed_nif && !installed_nif.nif_persistence) || (installed_nif.durability <= 0)) // If you have a NIF on file but leave the round without one installed, you only take a durability loss instead of losing the implant.
		if(persistence.nif_path)
			if(persistence.nif_durability <= 0) //There is one round to repair the NIF after it breaks, otherwise it will be lost.
				persistence.nif_path = null
				persistence.nif_examine_text = null
				persistence.nif_durability = null
				return

			persistence.nif_durability = max((persistence.nif_durability - LOSS_WITH_NIF_UNINSTALLED), 0)
			return

		persistence.nif_path = null
		persistence.nif_examine_text = null
		return

	persistence.nif_path = installed_nif.type
	persistence.nif_durability = installed_nif.durability
	persistence.nif_theme = installed_nif.current_theme
	persistence.nif_is_calibrated = installed_nif.is_calibrated
	persistence.stored_rewards_points = installed_nif.rewards_points

	var/datum/component/nif_examine/examine_component = GetComponent(/datum/component/nif_examine)
	persistence.nif_examine_text = examine_component?.nif_examine_text

	var/persistent_nifsoft_paths = ""  // We need to convert all of the paths in the list into a single string
	for(var/datum/nifsoft/nifsoft as anything in installed_nif.loaded_nifsofts)
		if(nifsoft.persistence)
			nifsoft.save_persistence_data(persistence)

		if(!nifsoft.able_to_keep || !nifsoft.keep_installed)
			continue

		persistent_nifsoft_paths += "&[(nifsoft.type)]"

	persistence.persistent_nifsofts = persistent_nifsoft_paths

/// Loads the NIF data for an individual user.
/mob/living/carbon/human/proc/load_nif_data(datum/modular_persistence/persistence)
	if(HAS_TRAIT(src, TRAIT_GHOSTROLE))
		return FALSE

	if(!persistence.nif_path)
		return

	var/obj/item/organ/internal/cyberimp/brain/nif/new_nif = new persistence.nif_path

	new_nif.durability = persistence.nif_durability
	new_nif.current_theme = persistence.nif_theme
	new_nif.is_calibrated = persistence.nif_is_calibrated
	new_nif.rewards_points = persistence.stored_rewards_points

	var/list/persistent_nifsoft_paths = list()
	for(var/text as anything in splittext(persistence.persistent_nifsofts, "&"))
		var/datum/nifsoft/nifsoft_to_add = text2path(text)
		if(!ispath(nifsoft_to_add, /datum/nifsoft) || !initial(nifsoft_to_add.able_to_keep))
			continue

		persistent_nifsoft_paths.Add(nifsoft_to_add)

	new_nif.persistent_nifsofts = persistent_nifsoft_paths.Copy()
	new_nif.Insert(src)

	var/datum/component/nif_examine/examine_component = GetComponent(/datum/component/nif_examine)
	if(examine_component)
		examine_component.nif_examine_text = persistence.nif_examine_text

	var/obj/item/modular_computer/pda/found_pda = locate(/obj/item/modular_computer/pda) in contents
	if(!found_pda)
		return FALSE

	var/datum/computer_file/program/nifsoft_downloader/downloaded_app = new
	found_pda.store_file(downloaded_app)

/// Loads the modular persistence data for a NIFSoft
/datum/nifsoft/proc/load_persistence_data()
	if(!linked_mob || !persistence)
		return FALSE
	var/obj/item/organ/internal/brain/linked_brain = linked_mob.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(!linked_brain || !linked_brain.modular_persistence)
		return FALSE

	return linked_brain.modular_persistence


/// Saves the modular persistence data for a NIFSoft
/datum/nifsoft/proc/save_persistence_data(datum/modular_persistence/persistence)
	if(!persistence)
		return FALSE

	return TRUE

#undef LOSS_WITH_NIF_UNINSTALLED

///This is the standard 'baseline' NIF model.
/obj/item/organ/internal/cyberimp/brain/nif/standard
	name = "Standard Type NIF"
	desc = "'Standard-Type' is a classification for high-quality Nanite Implant Frameworks. This category primarily includes Framework patterns with high reliability, seamless bonding with a user, and a combination of storage space and processing power to run a wide array of programs."
	manufacturer_notes = "While countless manufacturers produce their own implementation of NIFs, open-source or not, there's less than a thousand Standard-Type models out there in the galaxy. These are the results of almost five years of improvements on older models of Frameworks, and are rather coveted due to being extremely difficult to 'homebrew."

/obj/item/organ/internal/cyberimp/brain/nif/roleplay_model
	name = "Econo-Deck Type NIF"
	desc = "'Econo-Deck' is a classification for lower-quality Nanite Implant Frameworks. Typically, these are off-brand 'economical' bootlegs of higher-quality Frameworks featuring lower-grade power cells, outdated and risky construction patterns, and far rougher calibration with a user."
	manufacturer_notes = "Most webspaces for hobbyists or hardcore users, Corpo neurologists, and developers of 'softs such as the Altspace Coven recommend against their purchase. Despite their affordability by the layman, it's a common notion in Framework user circles that a device directly hooked into a user's nervous system is never something which should be skimped on; hence, Econo-Decks typically find themselves in the hands of the truly desperate, criminals, or coming out of workshops as 'homebrews.'"

	max_power_level = 500
	max_nifsofts = 3
	calibration_time = 1 MINUTES
	max_durability = 50
	death_durability_loss = 10


/obj/item/organ/internal/cyberimp/brain/nif/roleplay_model/cheap
	name = "Trial-Lite Type NIF"
	desc = "'Trial-Lite' is a classification for temporary Nanite Implant Frameworks. These are typically distributed at promotional events, for the use of single-purpose NIFsofts, or at some Corporate dealerships to offer prospective users a look into the scene. Normally, Trial-Lite frameworks do not actually 'bond' with their user, forming an extremely loose connection before dissolving into scattered and dead nanomachines within a few hours, typically exhaled."
	manufacturer_notes = "Normally, Trial-Lite frameworks do not actually 'bond' with their user, forming an extremely loose connection before dissolving into scattered and dead nanomachines within a few hours, typically exhaled. It's so far been impossible to extend the lifespan of a Trial-Lite NIF, owing to their far inferior construction and programming."
	nif_persistence = FALSE

/obj/item/autosurgeon/organ/nif/disposable //Disposable, as in the fact that this only lasts for one shift
	name = "Econo-Deck Type Autosurgeon"
	starting_organ = /obj/item/organ/internal/cyberimp/brain/nif/roleplay_model/cheap
	uses = 1

/obj/item/organ/internal/cyberimp/brain/nif/standard/ghost_role
	nif_persistence = FALSE
	is_calibrated = TRUE

/obj/item/autosurgeon/organ/nif/ghost_role
	name = "Enhanced Standard Type NIF Autosurgeon"
	starting_organ = /obj/item/organ/internal/cyberimp/brain/nif/standard/ghost_role
	uses = 1

/// Action used to pull up the NIF menu
/datum/action/item_action/nif
	background_icon = 'monkestation/code/modules/blueshift/icons/mob/actions/action_backgrounds.dmi'
	background_icon_state = "android"
	button_icon = 'monkestation/code/modules/blueshift/icons/mob/actions/actions_nif.dmi'
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/item_action/nif/open_menu
	name = "Open NIF Menu"
	button_icon_state = "user"

/datum/action/item_action/nif/open_menu/Trigger(trigger_flags)
	. = ..()
	var/obj/item/organ/internal/cyberimp/brain/nif/target_nif = target

	if(target_nif.calibrating)
		target_nif.send_message("The NIF is still calibrating, please wait!", TRUE)
		return FALSE

	if(target_nif.durability < 1)
		target_nif.send_message("Durability low!", TRUE)
		return FALSE

	if(target_nif.broken)
		target_nif.send_message("The NIF is unable to be used at this time!", TRUE)
		return FALSE

	if(!.)
		return

	target_nif.ui_interact(usr)


///NIFSoft Remover. This is mostly here so that security and antags have a way to remove NIFSofts from someome
/obj/item/nifsoft_remover
	name = "Lopland 'Wrangler' NIF-Cutter"
	desc = "A small device that lets the user remove NIFSofts from a NIF user"
	special_desc = "Given the relatively recent and sudden proliferation of NIFs, their use in crime both petty and organized has skyrocketed in recent years. \
	The existence of nanomachine-based real-time burst communication that cannot be effectively monitored or hacked into has given most PMCs cause enough for concern \
	to invent their own devices. This one is a 'Wrangler' model NIF-Cutter, used for crudely wiping programs directly off a user's Framework."
	icon = 'monkestation/code/modules/blueshift/icons/obj/devices.dmi'
	icon_state = "nifsoft_remover"

	///Is a disk with the corresponding NIFSoft created when said NIFSoft is removed?
	var/create_disk = FALSE

/obj/item/nifsoft_remover/attack(mob/living/carbon/human/target_mob, mob/living/user)
	. = ..()
	var/obj/item/organ/internal/cyberimp/brain/nif/target_nif = target_mob.get_organ_by_type(/obj/item/organ/internal/cyberimp/brain/nif)

	if(!target_nif || !length(target_nif.loaded_nifsofts))
		balloon_alert(user, "[target_mob] has no NIFSofts!")
		return

	var/list/installed_nifsofts = target_nif.loaded_nifsofts
	var/datum/nifsoft/nifsoft_to_remove = tgui_input_list(user, "Chose a NIFSoft to remove.", "[src]", installed_nifsofts)

	if(!nifsoft_to_remove)
		return FALSE

	user.visible_message(span_warning("[user] starts to use [src] on [target_mob]"), span_notice("You start to use [src] on [target_mob]"))
	if(!do_after(user, 5 SECONDS, target_mob))
		balloon_alert(user, "removal cancelled!")
		return FALSE

	if(!target_nif.remove_nifsoft(nifsoft_to_remove))
		balloon_alert(user, "removal failed!")
		return FALSE

	to_chat(user, span_notice("You successfully remove [nifsoft_to_remove]."))
	user.log_message("removed [nifsoft_to_remove] from [target_mob]" ,LOG_GAME)

	if(create_disk)
		var/obj/item/disk/nifsoft_uploader/new_disk = new
		new_disk.loaded_nifsoft = nifsoft_to_remove.type
		new_disk.name = "[nifsoft_to_remove] datadisk"

		user.put_in_hands(new_disk)

	qdel(nifsoft_to_remove)

	return TRUE

/obj/item/nifsoft_remover/syndie
	name = "Cybersun 'Scalpel' NIF-Cutter"
	desc = "A modified version of a NIFSoft remover that allows the user to remove a NIFSoft and have a blank copy of the removed NIFSoft saved to a disk."
	special_desc = "In the upper echelons of the corporate world, Nanite Implant Frameworks are everywhere. Valuable targets will almost always be in constant NIF communication with at least one or two points of contact in the event of an emergency. To bypass this unfortunate conundrum, Cybersun Industries invented the 'Scalpel' NIF-Cutter. A device no larger than a PDA, this gift to the field of neurological theft is capable of extracting specific programs from a target in five seconds or less. On top of that, high-grade programming allows for the tool to copy the specific 'soft to a disk for the wielder's own use."
	icon_state = "nifsoft_remover_syndie"
	create_disk = TRUE

/datum/uplink_item/device_tools/nifsoft_remover
	name = "Cybersun 'Scalpel' NIF-Cutter"
	desc = "A modified version of a NIFSoft remover that allows the user to remove a NIFSoft and have a blank copy of the removed NIFSoft saved to a disk."
	item = /obj/item/nifsoft_remover/syndie
	cost = 3

///NIF Repair Kit.
/obj/item/nif_repair_kit
	name = "Cerulean NIF Regenerator"
	desc = "A repair kit that allows for NIFs to be repaired without the use of surgery"
	special_desc = "The effects of capitalism and industry run deep, and they run within the Nanite Implant Framework industry as well. \
	Frameworks, complicated devices as they are, are normally locked at the firmware level to requiring specific 'approved' brands of repair paste or repair-docks. \
	This hacked-kit has been developed by the Altspace Coven as a freeware alternative, spread far and wide throughout extra-Solarian space for quality of life \
	for users located on the peripheries of society."
	icon = 'monkestation/code/modules/blueshift/icons/obj/devices.dmi'
	icon_state = "repair_paste"
	w_class = WEIGHT_CLASS_SMALL
	///How much does this repair each time it is used?
	var/repair_amount = 20
	///How many times can this be used?
	var/uses = 5

/obj/item/nif_repair_kit/attack(mob/living/carbon/human/mob_to_repair, mob/living/user)
	. = ..()

	var/obj/item/organ/internal/cyberimp/brain/nif/installed_nif = mob_to_repair.get_organ_by_type(/obj/item/organ/internal/cyberimp/brain/nif)
	if(!installed_nif)
		balloon_alert(user, "[mob_to_repair] lacks a NIF")

	if(!do_after(user, 5 SECONDS, mob_to_repair))
		balloon_alert(user, "repair cancelled")
		return FALSE

	if(!installed_nif.adjust_durability(repair_amount))
		balloon_alert(user, "target NIF is at max duarbility")
		return FALSE

	to_chat(user, span_notice("You successfully repair [mob_to_repair]'s NIF"))
	to_chat(mob_to_repair, span_notice("[user] successfully repairs your NIF"))

	uses -= 1
	if(!uses)
		qdel(src)

/obj/item/nif_hud_adapter
	name = "Scrying Lens Adapter"
	desc = "A kit that modifies select glasses to display HUDs for NIFs"
	icon = 'monkestation/code/modules/blueshift/icons/donator/obj/kits.dmi'
	icon_state = "partskit"

	/// Can this item be used multiple times? If not, it will delete itself after being used.
	var/multiple_uses = FALSE
	/// List containing all of the glasses that we want to work with this.
	var/static/list/glasses_whitelist = list(
		/obj/item/clothing/glasses/trickblindfold,
		/obj/item/clothing/glasses/monocle,
		/obj/item/clothing/glasses/fake_sunglasses,
		/obj/item/clothing/glasses/regular,
		/obj/item/clothing/glasses/eyepatch,
		/obj/item/clothing/glasses/osi,
		/obj/item/clothing/glasses/phantom,
		/obj/item/clothing/glasses/salesman, // Now's your chance.
		/obj/item/clothing/glasses/thin,
		/obj/item/clothing/glasses/biker,
		/obj/item/clothing/glasses/sunglasses/gar,
		/obj/item/clothing/glasses/heat,
		/obj/item/clothing/glasses/cold,
		/obj/item/clothing/glasses/orange,
		/obj/item/clothing/glasses/red,
		/obj/item/clothing/glasses/psych,
	)

/obj/item/nif_hud_adapter/examine(mob/user)
	. = ..()
	var/list/compatible_glasses_names = list()
	for(var/obj/item/glasses_type as anything in glasses_whitelist)
		var/glasses_name = initial(glasses_type.name)
		if(!glasses_name)
			continue

		compatible_glasses_names += glasses_name

	if(length(compatible_glasses_names))
		. += span_cyan("\n This item will work on the following glasses: [english_list(compatible_glasses_names)].")

	return .

/obj/item/nif_hud_adapter/afterattack(obj/item/clothing/glasses/target_glasses, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag || !istype(target_glasses))
		return FALSE

	if(!is_type_in_list(target_glasses, glasses_whitelist))
		balloon_alert("incompatible!")
		return FALSE

	if(HAS_TRAIT(target_glasses, TRAIT_NIFSOFT_HUD_GRANTER))
		balloon_alert("already upgraded!")
		return FALSE

	user.visible_message(span_notice("[user] upgrades [target_glasses] with [src]."), span_notice("You upgrade [target_glasses] to be NIF HUD compatible."))
	target_glasses.name = "\improper HUD-upgraded " + target_glasses.name
	target_glasses.AddElement(/datum/element/nifsoft_hud)
	playsound(target_glasses.loc, 'sound/weapons/circsawhit.ogg', 50, vary = TRUE)

	if(!multiple_uses)
		qdel(src)

