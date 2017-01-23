/datum/antagonist/wizard
	name = ROLE_WIZARD

	text_on_gain = "You are a wizard, Harry!"
	text_on_lose = "You are a muggle, Harry!"

	possible_objectives = list(/datum/objective/steal, /datum/objective/assassinate)

	ignore_job_selection = TRUE
	landmark_spawn = "wizard"

/datum/antagonist/wizard/apply_innate_effects()
	if(!owner)
		return
	ticker.mode.update_wiz_icons_added(owner)

/datum/antagonist/wizard/remove_innate_effects()
	if(!owner)
		return
	ticker.mode.update_wiz_icons_removed(owner)

/datum/antagonist/wizard/on_gain()
	. = ..()
	name_wizard()

/datum/antagonist/wizard/give_equipment() // to do: improve this proc
	if(!owner || !ishuman(owner.current) || !give_special_equipment)
		return
	var/mob/living/carbon/human/wizard_mob = owner.current
	qdel(wizard_mob.wear_suit)
	qdel(wizard_mob.head)
	qdel(wizard_mob.shoes)
	for(var/obj/item/I in wizard_mob.held_items)
		wizard_mob.unEquip(I)
		qdel(I)
	qdel(wizard_mob.r_store)
	qdel(wizard_mob.l_store)

	wizard_mob.set_species(/datum/species/human)
	wizard_mob.equip_to_slot_or_del(new /obj/item/device/radio/headset(wizard_mob), slot_ears)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/under/color/lightpurple(wizard_mob), slot_w_uniform)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/shoes/sandal/magic(wizard_mob), slot_shoes)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/suit/wizrobe(wizard_mob), slot_wear_suit)
	wizard_mob.equip_to_slot_or_del(new /obj/item/clothing/head/wizard(wizard_mob), slot_head)
	wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/backpack(wizard_mob), slot_back)
	wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/storage/box/survival(wizard_mob), slot_in_backpack)
	wizard_mob.equip_to_slot_or_del(new /obj/item/weapon/teleportation_scroll(wizard_mob), slot_r_store)
	var/obj/item/weapon/spellbook/spellbook = new /obj/item/weapon/spellbook(wizard_mob)
	spellbook.owner = wizard_mob
	wizard_mob.put_in_hands_or_del(spellbook)

	wizard_mob << "You will find a list of available spells in your spell book. Choose your magic arsenal carefully."
	wizard_mob << "The spellbook is bound to you, and others cannot use it."
	wizard_mob << "In your pockets you will find a teleport scroll. Use it as needed."
	wizard_mob.mind.store_memory("<B>Remember:</B> do not forget to prepare your spells.")

/datum/antagonist/wizard/generate_objectives()
	var/is_hijacker = prob(TRAITOR_HIJACK_CHANCE)
	if(is_hijacker)
		var/datum/objective/hijack/hi_jack = new
		hi_jack.owner = owner
		current_objectives += hi_jack
	else
		var/objective_type = pick(possible_objectives)
		var/datum/objective/O = new objective_type
		O.owner = owner
		O.find_target()
		current_objectives += O
		if(prob(30))
			var/datum/objective/survive/survival = new
			survival.owner = owner
			current_objectives += survival
		else
			var/datum/objective/escape/irun = new
			irun.owner = owner
			current_objectives += irun

/datum/antagonist/wizard/proc/name_wizard()
	if(!(owner && owner.current))
		return
	var/wiz_name = "[pick(wizard_first)] [pick(wizard_second)]"
	var/custom_name = copytext(sanitize(input(owner.current, "You are the Space Wizard. Would you like to change your name to something else?", "Name change", wiz_name) as null|text), 1, MAX_NAME_LEN)
	if(custom_name)
		wiz_name = custom_name

	owner.current.real_name = wiz_name
	owner.current.name = wiz_name
	owner.name = wiz_name
