/obj/item/hunting_contract
	name = "\improper Hunter's Contract"
	desc = "A contract detailing all the guidelines a good hunter needs."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	///have we claimed our weapon?
	var/bought = FALSE
	///the datum containing all weapons
	var/list/datum/hunter_weapons/weapons = list()
	///the weapon that we have purchased
	var/selected_item
	///the owner of this contract
	var/datum/antagonist/monsterhunter/owner
	///is the contract used up?
	var/used_up = FALSE

/obj/item/hunting_contract/Initialize(mapload, datum/antagonist/monsterhunter/hunter)
	. = ..()
	for(var/items in subtypesof(/datum/hunter_weapons))
		weapons += new items
	if(hunter)
		owner = hunter

/obj/item/hunting_contract/ui_interact(mob/living/user, datum/tgui/ui)
	if(!IS_MONSTERHUNTER(user))
		to_chat(user, span_notice("You are unable to decipher the symbols."))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HunterContract", name)
		ui.open()

/obj/item/hunting_contract/ui_status(mob/user)
	if(isliving(user) && !IS_MONSTERHUNTER(user))
		return UI_CLOSE
	return ..()

/obj/item/hunting_contract/ui_data(mob/user)
	var/list/data = list()
	data["bought"] = bought
	data["items"] = list()
	data["objectives"] = list()
	if(length(weapons))
		for(var/datum/hunter_weapons/contraband as anything in weapons)
			data["items"] += list(list(
				"id" = contraband.type,
				"name" = contraband.name,
				"desc" = contraband.desc
			))
	var/check_completed = TRUE  ///determines if all objectives have been completed
	if(owner)
		for(var/datum/objective/obj as anything in owner.objectives)
			data["objectives"] += list(list(
				"explanation" = obj.explanation_text,
				"completed" = (obj.check_completion())
			))
			if(!obj.check_completion())
				check_completed = FALSE
		data["all_completed"] = check_completed
		data["number_of_rabbits"] = owner.rabbits_spotted
		data["rabbits_found"] = !length(owner.rabbits)
		data["used_up"] = used_up
	return data

/obj/item/hunting_contract/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("select")
			if(isnull(params["item"]))
				return
			var/item = text2path(params["item"])
			selected_item = item
			. = TRUE
			purchase(selected_item, usr)
		if("claim_reward")
			if(used_up)
				return
			var/turf/current_turf = get_turf(src)
			if(!is_station_level(current_turf.z))
				to_chat(usr, span_warning("The pull of the ice moon isn't strong enough here..."))
				return
			SEND_SIGNAL(owner, COMSIG_BEASTIFY)
			used_up = TRUE


/obj/item/hunting_contract/proc/purchase(item, user)
	var/obj/item/purchased
	for(var/datum/hunter_weapons/contraband as anything in weapons)
		if(contraband.type != item)
			continue
		bought = TRUE
		purchased = new contraband.item

	var/datum/action/cooldown/spell/summonitem/recall = new()
	recall.mark_item(purchased)
	recall.Grant(user)

	podspawn(list(
		"target" = get_turf(user),
		"style" = STYLE_SYNDICATE,
		"spawn" = purchased
	))

/obj/item/hunting_contract/Destroy()
	owner = null
	weapons = null
	return ..()

/datum/hunter_weapons
	///name of the weapon
	var/name
	///description of the weapon that will appear on the UI
	var/desc
	///path of the weapon
	var/item

/datum/hunter_weapons/threaded_cane
	name = "Threaded Cane"
	desc = "cane made out of heavy metal, can transform into a whip to strike foes from afar."
	item = /obj/item/melee/trick_weapon/threaded_cane

/datum/hunter_weapons/hunter_axe
	name = "Hunter's Axe"
	desc = "simple axe for hunters that lean towards barbarian tactics, can transform into a double bladed axe."
	item = /obj/item/melee/trick_weapon/hunter_axe

/datum/hunter_weapons/darkmoon_greatsword
	name = "Darkmoon Greatsword"
	desc = "a heavy sword hilt that would knock anyone out cold, can transform into the darkmoonlight greatsword. "
	item = /obj/item/melee/trick_weapon/darkmoon

/datum/hunter_weapons/beast_claw
	name = "Beast Claw"
	desc = "A claw made from the bones of monster. It can be transformed into a heavier, more wound-inducing version."
	item = /obj/item/melee/trick_weapon/beast_claw
