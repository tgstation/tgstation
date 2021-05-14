/obj/item/organ/cyberimp/arm
	name = "arm-mounted implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	zone = BODY_ZONE_R_ARM
	icon_state = "implant-toolkit"
	w_class = WEIGHT_CLASS_SMALL
	encode_info = AUGMENT_NT_LOWLEVEL

/obj/item/organ/cyberimp/arm/Initialize()
	. = ..()
	update_icon()
	SetSlotFromZone()

/obj/item/organ/cyberimp/arm/proc/SetSlotFromZone()
	switch(zone)
		if(BODY_ZONE_L_ARM)
			slot = ORGAN_SLOT_LEFT_ARM_AUG
		if(BODY_ZONE_R_ARM)
			slot = ORGAN_SLOT_RIGHT_ARM_AUG
		else
			CRASH("Invalid zone for [type]")

/obj/item/organ/cyberimp/arm/update_icon()
	. = ..()
	if(zone == BODY_ZONE_R_ARM)
		transform = null
	else // Mirroring the icon
		transform = matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/cyberimp/arm/examine(mob/user)
	. = ..()
	. += "<span class='info'>[src] is assembled in the [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm configuration. You can use a screwdriver to reassemble it.</span>"

/obj/item/organ/cyberimp/arm/screwdriver_act(mob/living/user, obj/item/I)
	. = ..()
	if(.)
		return TRUE
	I.play_tool_sound(src)
	if(zone == BODY_ZONE_R_ARM)
		zone = BODY_ZONE_L_ARM
	else
		zone = BODY_ZONE_R_ARM
	SetSlotFromZone()
	to_chat(user, "<span class='notice'>You modify [src] to be installed on the [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm.</span>")
	update_icon()

/obj/item/organ/cyberimp/arm/item_set
	actions_types = list(/datum/action/item_action/organ_action/toggle)

	///A ref for the arm we're taking up. Mostly for the unregister signal upon removal
	var/obj/hand
	/// Used to store a list of all items inside, for multi-item implants.
	var/list/items_list = list()// I would use contents, but they shuffle on every activation/deactivation leading to interface inconsistencies.
	/// You can use this var for item path, it would be converted into an item on New().
	var/obj/item/active_item

/obj/item/organ/cyberimp/arm/item_set/Initialize()
	. = ..()
	if(ispath(active_item))
		active_item = new active_item(src)
	items_list = contents.Copy()

/obj/item/organ/cyberimp/arm/item_set/update_implants()
	if(!check_compatibility())
		Retract()

/obj/item/organ/cyberimp/arm/item_set/Insert(mob/living/carbon/M, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	var/side = zone == BODY_ZONE_R_ARM? RIGHT_HANDS : LEFT_HANDS
	hand = owner.hand_bodyparts[side]
	if(hand)
		RegisterSignal(hand, COMSIG_ITEM_ATTACK_SELF, .proc/ui_action_click) //If the limb gets an attack-self, open the menu. Only happens when hand is empty
		RegisterSignal(M, COMSIG_KB_MOB_DROPITEM_DOWN, .proc/dropkey) //We're nodrop, but we'll watch for the drop hotkey anyway and then stow if possible.

/obj/item/organ/cyberimp/arm/item_set/Remove(mob/living/carbon/M, special = 0)
	Retract()
	if(hand)
		UnregisterSignal(hand, COMSIG_ITEM_ATTACK_SELF)
		UnregisterSignal(M, COMSIG_KB_MOB_DROPITEM_DOWN)
	..()

/obj/item/organ/cyberimp/arm/item_set/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(15/severity) && owner)
		to_chat(owner, "<span class='warning'>The electromagnetic pulse causes [src] to malfunction!</span>")
		// give the owner an idea about why his implant is glitching
		Retract()

/**
 * Called when the mob uses the "drop item" hotkey
 *
 * Items inside toolset implants have TRAIT_NODROP, but we can still use the drop item hotkey as a
 * quick way to store implant items. In this case, we check to make sure the user has the correct arm
 * selected, and that the item is actually owned by us, and then we'll hand off the rest to Retract()
**/
/obj/item/organ/cyberimp/arm/item_set/proc/dropkey(mob/living/carbon/host)
	if(!host)
		return //How did we even get here
	if(hand != host.hand_bodyparts[host.active_hand_index])
		return //wrong hand
	Retract()

/obj/item/organ/cyberimp/arm/item_set/proc/Retract()
	if(!active_item || (active_item in src))
		return

	owner.visible_message("<span class='notice'>[owner] retracts [active_item] back into [owner.p_their()] [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm.</span>",
		"<span class='notice'>[active_item] snaps back into your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm.</span>",
		"<span class='hear'>You hear a short mechanical noise.</span>")

	owner.transferItemToLoc(active_item, src, TRUE)
	active_item = null
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, TRUE)

/obj/item/organ/cyberimp/arm/item_set/proc/Extend(obj/item/item)
	if(!check_compatibility())
		return

	if(!(item in src))
		return

	active_item = item

	active_item.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	ADD_TRAIT(active_item, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	active_item.slot_flags = null
	active_item.set_custom_materials(null)

	var/side = zone == BODY_ZONE_R_ARM? RIGHT_HANDS : LEFT_HANDS
	var/hand = owner.get_empty_held_index_for_side(side)
	if(hand)
		owner.put_in_hand(active_item, hand)
	else
		var/list/hand_items = owner.get_held_items_for_side(side, all = TRUE)
		var/success = FALSE
		var/list/failure_message = list()
		for(var/i in 1 to hand_items.len) //Can't just use *in* here.
			var/I = hand_items[i]
			if(!owner.dropItemToGround(I))
				failure_message += "<span class='warning'>Your [I] interferes with [src]!</span>"
				continue
			to_chat(owner, "<span class='notice'>You drop [I] to activate [src]!</span>")
			success = owner.put_in_hand(active_item, owner.get_empty_held_index_for_side(side))
			break
		if(!success)
			for(var/i in failure_message)
				to_chat(owner, i)
			return
	owner.visible_message("<span class='notice'>[owner] extends [active_item] from [owner.p_their()] [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm.</span>",
		"<span class='notice'>You extend [active_item] from your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm.</span>",
		"<span class='hear'>You hear a short mechanical noise.</span>")
	playsound(get_turf(owner), 'sound/mecha/mechmove03.ogg', 50, TRUE)

/obj/item/organ/cyberimp/arm/item_set/ui_action_click()
	if(!check_compatibility())
		to_chat(owner, "<span class='warning'>The Neuralink beeps: ERR01 INCOMPATIBLE IMPLANT</span>")
		return

	if((organ_flags & ORGAN_FAILING) || (!active_item && !contents.len))
		to_chat(owner, "<span class='warning'>The implant doesn't respond. It seems to be broken...</span>")
		return

	if(!active_item || (active_item in src))
		active_item = null
		if(contents.len == 1)
			Extend(contents[1])
		else
			var/list/choice_list = list()
			for(var/obj/item/I in items_list)
				choice_list[I] = image(I)
			var/obj/item/choice = show_radial_menu(owner, owner, choice_list)
			if(owner && owner == usr && owner.stat != DEAD && (src in owner.internal_organs) && !active_item && (choice in contents))
				// This monster sanity check is a nice example of how bad input is.
				Extend(choice)
	else
		Retract()


/obj/item/organ/cyberimp/arm/item_set/gun/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(30/severity) && owner && !(organ_flags & ORGAN_FAILING))
		Retract()
		owner.visible_message("<span class='danger'>A loud bang comes from [owner]\'s [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm!</span>")
		playsound(get_turf(owner), 'sound/weapons/flashbang.ogg', 100, TRUE)
		to_chat(owner, "<span class='userdanger'>You feel an explosion erupt inside your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm as your implant breaks!</span>")
		owner.adjust_fire_stacks(20)
		owner.IgniteMob()
		owner.adjustFireLoss(25)
		organ_flags |= ORGAN_FAILING


/obj/item/organ/cyberimp/arm/item_set/gun/laser
	name = "arm-mounted laser implant"
	desc = "A variant of the arm cannon implant that fires lethal laser beams. The cannon emerges from the subject's arm and remains inside when not in use."
	icon_state = "arm_laser"
	encode_info = AUGMENT_TG_LEVEL
	contents = newlist(/obj/item/gun/energy/laser/mounted)

/obj/item/organ/cyberimp/arm/item_set/gun/laser/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/item_set/gun/laser/Initialize()
	. = ..()
	var/obj/item/organ/cyberimp/arm/item_set/gun/laser/laserphasergun = locate(/obj/item/gun/energy/laser/mounted) in contents
	laserphasergun.icon = icon //No invisible laser guns kthx
	laserphasergun.icon_state = icon_state

/obj/item/organ/cyberimp/arm/item_set/gun/taser
	name = "arm-mounted taser implant"
	desc = "A variant of the arm cannon implant that fires electrodes and disabler shots. The cannon emerges from the subject's arm and remains inside when not in use."
	icon_state = "arm_taser"
	encode_info = AUGMENT_TG_LEVEL
	contents = newlist(/obj/item/gun/energy/e_gun/advtaser/mounted)

/obj/item/organ/cyberimp/arm/item_set/gun/taser/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/item_set/toolset
	name = "integrated toolset implant"
	desc = "A stripped-down version of the engineering cyborg toolset, designed to be installed on subject's arm. Contain advanced versions of every tool."
	encode_info = AUGMENT_NT_HIGHLEVEL
	contents = newlist(/obj/item/screwdriver/cyborg, /obj/item/wrench/cyborg, /obj/item/weldingtool/largetank/cyborg,
		/obj/item/crowbar/cyborg, /obj/item/wirecutters/cyborg, /obj/item/multitool/cyborg)

/obj/item/organ/cyberimp/arm/item_set/toolset/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/item_set/toolset/emag_act(mob/user)
	if(!(locate(/obj/item/kitchen/knife/combat/cyborg) in items_list))
		to_chat(user, "<span class='notice'>You unlock [src]'s integrated knife!</span>")
		items_list += new /obj/item/kitchen/knife/combat/cyborg(src)
		return 1
	return 0

/obj/item/organ/cyberimp/arm/item_set/esword
	name = "arm-mounted energy blade"
	desc = "An illegal and highly dangerous cybernetic implant that can project a deadly blade of concentrated energy."
	encode_info = AUGMENT_SYNDICATE_LEVEL
	contents = newlist(/obj/item/melee/transforming/energy/blade/hardlight)

/obj/item/organ/cyberimp/arm/item_set/medibeam
	name = "integrated medical beamgun"
	desc = "A cybernetic implant that allows the user to project a healing beam from their hand."
	encode_info = AUGMENT_TG_LEVEL
	contents = newlist(/obj/item/gun/medbeam)

/obj/item/organ/cyberimp/arm/item_set/flash
	name = "integrated high-intensity photon projector" //Why not
	desc = "An integrated projector mounted onto a user's arm that is able to be used as a powerful flash."
	encode_info = AUGMENT_NT_HIGHLEVEL
	contents = newlist(/obj/item/assembly/flash/armimplant)

/obj/item/organ/cyberimp/arm/item_set/flash/Initialize()
	. = ..()
	if(locate(/obj/item/assembly/flash/armimplant) in items_list)
		var/obj/item/assembly/flash/armimplant/F = locate(/obj/item/assembly/flash/armimplant) in items_list
		F.I = src

/obj/item/organ/cyberimp/arm/item_set/flash/Extend()
	. = ..()
	active_item.set_light_range(7)
	active_item.set_light_on(TRUE)

/obj/item/organ/cyberimp/arm/item_set/flash/Retract()
	active_item.set_light_on(FALSE)
	return ..()

/obj/item/organ/cyberimp/arm/item_set/baton
	name = "arm electrification implant"
	desc = "An illegal combat implant that allows the user to administer disabling shocks from their arm."
	encode_info = AUGMENT_TG_LEVEL
	contents = newlist(/obj/item/borg/stun)

/obj/item/organ/cyberimp/arm/item_set/combat
	name = "combat cybernetics implant"
	desc = "A powerful cybernetic implant that contains combat modules built into the user's arm."
	encode_info = AUGMENT_TG_LEVEL
	contents = newlist(/obj/item/melee/transforming/energy/blade/hardlight, /obj/item/gun/medbeam, /obj/item/borg/stun, /obj/item/assembly/flash/armimplant)

/obj/item/organ/cyberimp/arm/item_set/combat/Initialize()
	. = ..()
	if(locate(/obj/item/assembly/flash/armimplant) in items_list)
		var/obj/item/assembly/flash/armimplant/F = locate(/obj/item/assembly/flash/armimplant) in items_list
		F.I = src

/obj/item/organ/cyberimp/arm/item_set/surgery
	name = "surgical toolset implant"
	desc = "A set of surgical tools hidden behind a concealed panel on the user's arm."
	contents = newlist(/obj/item/retractor/augment, /obj/item/hemostat/augment, /obj/item/cautery/augment, /obj/item/surgicaldrill/augment, /obj/item/scalpel/augment, /obj/item/circular_saw/augment, /obj/item/surgical_drapes)
	encode_info = AUGMENT_NT_HIGHLEVEL

/obj/item/organ/cyberimp/arm/item_set/cook
	name = "kitchenware toolset implant"
	desc = "A set of kitchen tools hidden behind a concealed panel on the user's arm."
	contents = newlist(/obj/item/kitchen/rollingpin,/obj/item/kitchen/knife,/obj/item/reagent_containers/glass/beaker)
	encode_info = AUGMENT_NT_LOWLEVEL

/obj/item/organ/cyberimp/arm/item_set/janitor
	name = "janitorial toolset implant"
	desc = "A set of janitorial tools hidden behind a concealed panel on the user's arm."
	contents = newlist(/obj/item/mop/advanced,/obj/item/reagent_containers/glass/bucket,/obj/item/soap,/obj/item/reagent_containers/spray/cleaner)
	encode_info = AUGMENT_NT_LOWLEVEL

/obj/item/organ/cyberimp/arm/item_set/detective
	name = "detective's toolset implant"
	desc = "A set of detective tools hidden behind a concealed panel on the user's arm."
	contents = newlist(/obj/item/evidencebag,/obj/item/evidencebag,/obj/item/evidencebag,/obj/item/detective_scanner,/obj/item/lighter)
	encode_info = AUGMENT_NT_HIGHLEVEL

/obj/item/organ/cyberimp/arm/item_set/detective/Destroy()
	on_destruction()
	return ..()

/obj/item/organ/cyberimp/arm/item_set/detective/proc/on_destruction()
	//We need to drop whatever is in the evidence bags
	for(var/obj/item/evidencebag/baggie in contents)
		var/obj/item/located = locate() in baggie
		if(located)
			located.forceMove(drop_location())

/obj/item/organ/cyberimp/arm/item_set/chemical
	name = "chemical toolset implant"
	desc = "A set of chemical tools hidden behind a concealed panel on the user's arm."
	contents = newlist(/obj/item/reagent_containers/glass/beaker,/obj/item/reagent_containers/glass/beaker,/obj/item/reagent_containers/glass/beaker,/obj/item/reagent_containers/dropper)
	encode_info = AUGMENT_NT_HIGHLEVEL

/obj/item/organ/cyberimp/arm/item_set/atmospherics
	name = "atmospherics toolset implant"
	desc = "A set of atmospheric tools hidden behind a concealed panel on the user's arm."
	contents = newlist(/obj/item/extinguisher,/obj/item/analyzer,/obj/item/crowbar,/obj/item/holosign_creator/atmos)
	encode_info = AUGMENT_NT_HIGHLEVEL

/obj/item/organ/cyberimp/arm/item_set/tablet
	name = "inbuilt tablet implant"
	desc = "A set of surgical tools hidden behind a concealed panel on the user's arm."
	contents = newlist(/obj/item/modular_computer/tablet/preset/cheap)
	encode_info = AUGMENT_NT_LOWLEVEL

/obj/item/organ/cyberimp/arm/item_set/connector
	name = "universal connection implant"
	desc = "Special inhand implant that allows you to connect your brain directly into the protocl sphere of implants, which allows for you to hack them and make the compatible."
	icon_state = "hand_implant"
	implant_overlay = "hand_implant_overlay"
	implant_color = "#39992d"
	encode_info = AUGMENT_NO_REQ
	contents = newlist(/obj/item/cyberlink_connector)

/obj/item/organ/cyberimp/arm/item_set/mantis
	name = "C.H.R.O.M.A.T.A. mantis blade implants"
	desc = "High tech mantis blade implants, easily portable weapon, that has a high wound potential."
	contents = newlist(/obj/item/mantis_blade)
	encode_info = AUGMENT_TG_LEVEL

/obj/item/organ/cyberimp/arm/item_set/syndie_mantis
	name = "A.R.A.S.A.K.A. mantis blade implants"
	desc = "Modernized mantis blade designed coined by Tiger operatives, much sharper blade with energy actuators makes it a much deadlier weapon."
	contents = newlist(/obj/item/mantis_blade/syndicate)
	encode_info = AUGMENT_SYNDICATE_LEVEL

/obj/item/organ/cyberimp/arm/item_set/syndie_mantis/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/cyberimp/arm/ammo_counter
	name = "S.M.A.R.T. ammo logistics system"
	desc = "Special inhand implant that allows transmits the current ammo and energy data straight to the user's visual cortex."
	icon_state = "hand_implant"
	implant_overlay = "hand_implant_overlay"
	implant_color = "#750137"
	encode_info = AUGMENT_NT_HIGHLEVEL

	var/atom/movable/screen/cybernetics/ammo_counter/counter_ref
	var/obj/item/gun/our_gun

/obj/item/organ/cyberimp/arm/ammo_counter/Insert(mob/living/carbon/M, special, drop_if_replaced)
	. = ..()
	RegisterSignal(M,COMSIG_CARBON_ITEM_PICKED_UP,.proc/add_to_hand)
	RegisterSignal(M,COMSIG_CARBON_ITEM_DROPPED,.proc/remove_from_hand)

/obj/item/organ/cyberimp/arm/ammo_counter/Remove(mob/living/carbon/M, special)
	. = ..()
	UnregisterSignal(M,COMSIG_CARBON_ITEM_PICKED_UP)
	UnregisterSignal(M,COMSIG_CARBON_ITEM_DROPPED)
	our_gun = null
	update_hud_elements()

/obj/item/organ/cyberimp/arm/ammo_counter/update_implants()
	update_hud_elements()

/obj/item/organ/cyberimp/arm/ammo_counter/proc/update_hud_elements()
	SIGNAL_HANDLER
	if(!owner || !owner?.stat || !owner?.hud_used)
		return

	if(!check_compatibility())
		return

	var/datum/hud/H = owner.hud_used

	if(!our_gun)
		if(!H.cybernetics_ammo[zone])
			return
		H.cybernetics_ammo[zone] = null

		counter_ref.hud = null
		H.infodisplay -= counter_ref
		H.mymob.client.screen -= counter_ref
		QDEL_NULL(counter_ref)
		return

	if(!H.cybernetics_ammo[zone])
		counter_ref = new()
		counter_ref.screen_loc =  zone == BODY_ZONE_L_ARM ? ui_hand_position(1,1,9) : ui_hand_position(2,1,9)
		H.cybernetics_ammo[zone] = counter_ref
		counter_ref.hud = H
		H.infodisplay += counter_ref
		H.mymob.client.screen += counter_ref

	var/display
	if(istype(our_gun,/obj/item/gun/ballistic))
		var/obj/item/gun/ballistic/balgun = our_gun
		display = balgun.magazine.ammo_count()
	else
		var/obj/item/gun/energy/egun = our_gun
		var/obj/item/ammo_casing/energy/shot = egun.ammo_type[egun.select]
		display = FLOOR(egun.cell.charge / shot.e_cost,1)
	counter_ref.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='white'>[display]</font></div>")

/obj/item/organ/cyberimp/arm/ammo_counter/proc/add_to_hand(datum/source,obj/item/maybegun)
	SIGNAL_HANDLER

	var/obj/item/bodypart/bp = owner.get_active_hand()

	if(bp.body_zone != zone)
		return

	if(istype(maybegun,/obj/item/gun/ballistic))
		our_gun = maybegun
		RegisterSignal(owner,COMSIG_MOB_FIRED_GUN,.proc/update_hud_elements)

	if(istype(maybegun,/obj/item/gun/energy))
		var/obj/item/gun/energy/egun = maybegun
		our_gun = egun
		RegisterSignal(egun.cell,COMSIG_CELL_CHANGE_POWER,.proc/update_hud_elements)

	update_hud_elements()

/obj/item/organ/cyberimp/arm/ammo_counter/proc/remove_from_hand(datum/source,obj/item/maybegun)
	SIGNAL_HANDLER

	if(our_gun != maybegun)
		return

	if(istype(maybegun,/obj/item/gun/ballistic))
		UnregisterSignal(owner,COMSIG_MOB_FIRED_GUN)

	if(istype(maybegun,/obj/item/gun/energy))
		var/obj/item/gun/energy/egun = maybegun
		UnregisterSignal(egun.cell,COMSIG_CELL_CHANGE_POWER)


	our_gun = null
	update_hud_elements()

/obj/item/organ/cyberimp/arm/ammo_counter/syndicate
	encode_info = AUGMENT_SYNDICATE_LEVEL

/obj/item/organ/cyberimp/arm/cooler
	name = "sub-dermal cooling implant"
	desc = "Special inhand implant that cools you down if overheated."
	icon_state = "hand_implant"
	implant_overlay = "hand_implant_overlay"
	implant_color = "#00e1ff"
	encode_info = AUGMENT_NT_LOWLEVEL

/obj/item/organ/cyberimp/arm/cooler/on_life()
	. = ..()
	if(!check_compatibility())
		return
	var/amt = BODYTEMP_NORMAL - owner.get_body_temp_normal()
	if(amt == 0)
		return
	owner.add_body_temperature_change("dermal_cooler_[zone]",clamp(amt,-1,0))

/obj/item/organ/cyberimp/arm/cooler/Remove(mob/living/carbon/M, special)
	. = ..()
	owner.remove_body_temperature_change("dermal_cooler_[zone]")

/obj/item/organ/cyberimp/arm/heater
	name = "sub-dermal heater implant"
	desc = "Special inhand implant that heats you up if overcooled."
	icon_state = "hand_implant"
	implant_overlay = "hand_implant_overlay"
	implant_color = "#ff9100"
	encode_info = AUGMENT_NT_LOWLEVEL

/obj/item/organ/cyberimp/arm/heater/on_life()
	. = ..()
	if(!check_compatibility())
		return
	var/amt = BODYTEMP_NORMAL - owner.get_body_temp_normal()
	if(amt == 0)
		return
	owner.add_body_temperature_change("dermal_heater_[zone]",clamp(amt,0,1))

/obj/item/organ/cyberimp/arm/heater/Remove(mob/living/carbon/M, special)
	. = ..()
	owner.remove_body_temperature_change("dermal_heater_[zone]")

