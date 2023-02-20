/obj/item/organ/internal/cyberimp/arm
	name = "arm-mounted implant"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	zone = BODY_ZONE_R_ARM
	icon_state = "implant-toolkit"
	w_class = WEIGHT_CLASS_SMALL
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	///A ref for the arm we're taking up. Mostly for the unregister signal upon removal
	var/obj/hand
	//A list of typepaths to create and insert into ourself on init
	var/list/items_to_create = list()
	/// Used to store a list of all items inside, for multi-item implants.
	var/list/items_list = list()// I would use contents, but they shuffle on every activation/deactivation leading to interface inconsistencies.
	/// You can use this var for item path, it would be converted into an item on New().
	var/obj/item/active_item
	/// Sound played when extending
	var/extend_sound = 'sound/mecha/mechmove03.ogg'
	/// Sound played when retracting
	var/retract_sound = 'sound/mecha/mechmove03.ogg'

/obj/item/organ/internal/cyberimp/arm/Initialize(mapload)
	. = ..()
	if(ispath(active_item))
		active_item = new active_item(src)
		items_list += WEAKREF(active_item)

	for(var/typepath in items_to_create)
		var/atom/new_item = new typepath(src)
		items_list += WEAKREF(new_item)

	update_appearance()
	SetSlotFromZone()

/obj/item/organ/internal/cyberimp/arm/Destroy()
	hand = null
	active_item = null
	for(var/datum/weakref/ref in items_list)
		var/obj/item/to_del = ref.resolve()
		if(!to_del)
			continue
		qdel(to_del)
	items_list.Cut()
	return ..()

/obj/item/organ/internal/cyberimp/arm/proc/SetSlotFromZone()
	switch(zone)
		if(BODY_ZONE_L_ARM)
			slot = ORGAN_SLOT_LEFT_ARM_AUG
		if(BODY_ZONE_R_ARM)
			slot = ORGAN_SLOT_RIGHT_ARM_AUG
		else
			CRASH("Invalid zone for [type]")

/obj/item/organ/internal/cyberimp/arm/update_icon()
	. = ..()
	transform = (zone == BODY_ZONE_R_ARM) ? null : matrix(-1, 0, 0, 0, 1, 0)

/obj/item/organ/internal/cyberimp/arm/examine(mob/user)
	. = ..()
	if(status == ORGAN_ROBOTIC)
		. += span_info("[src] is assembled in the [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm configuration. You can use a screwdriver to reassemble it.")

/obj/item/organ/internal/cyberimp/arm/screwdriver_act(mob/living/user, obj/item/screwtool)
	. = ..()
	if(.)
		return TRUE
	screwtool.play_tool_sound(src)
	if(zone == BODY_ZONE_R_ARM)
		zone = BODY_ZONE_L_ARM
	else
		zone = BODY_ZONE_R_ARM
	SetSlotFromZone()
	to_chat(user, span_notice("You modify [src] to be installed on the [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."))
	update_appearance()

/obj/item/organ/internal/cyberimp/arm/Insert(mob/living/carbon/arm_owner, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	var/side = zone == BODY_ZONE_R_ARM? RIGHT_HANDS : LEFT_HANDS
	hand = arm_owner.hand_bodyparts[side]
	if(hand)
		RegisterSignal(hand, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_item_attack_self)) //If the limb gets an attack-self, open the menu. Only happens when hand is empty
		RegisterSignal(arm_owner, COMSIG_KB_MOB_DROPITEM_DOWN, PROC_REF(dropkey)) //We're nodrop, but we'll watch for the drop hotkey anyway and then stow if possible.

/obj/item/organ/internal/cyberimp/arm/Remove(mob/living/carbon/arm_owner, special = 0)
	Retract()
	if(hand)
		UnregisterSignal(hand, COMSIG_ITEM_ATTACK_SELF)
		UnregisterSignal(arm_owner, COMSIG_KB_MOB_DROPITEM_DOWN)
	..()

/obj/item/organ/internal/cyberimp/arm/proc/on_item_attack_self()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(ui_action_click))

/obj/item/organ/internal/cyberimp/arm/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF || status == ORGAN_ROBOTIC)
		return
	if(prob(15/severity) && owner)
		to_chat(owner, span_warning("The electromagnetic pulse causes [src] to malfunction!"))
		// give the owner an idea about why his implant is glitching
		Retract()

/**
 * Called when the mob uses the "drop item" hotkey
 *
 * Items inside toolset implants have TRAIT_NODROP, but we can still use the drop item hotkey as a
 * quick way to store implant items. In this case, we check to make sure the user has the correct arm
 * selected, and that the item is actually owned by us, and then we'll hand off the rest to Retract()
**/
/obj/item/organ/internal/cyberimp/arm/proc/dropkey(mob/living/carbon/host)
	SIGNAL_HANDLER
	if(!host)
		return //How did we even get here
	if(hand != host.hand_bodyparts[host.active_hand_index])
		return //wrong hand
	if(Retract())
		return COMSIG_KB_ACTIVATED

/obj/item/organ/internal/cyberimp/arm/proc/Retract()
	if(!active_item || (active_item in src))
		return FALSE

	owner?.visible_message(span_notice("[owner] retracts [active_item] back into [owner.p_their()] [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."),
		span_notice("[active_item] snaps back into your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."),
		span_hear("You hear a short mechanical noise."))

	owner.transferItemToLoc(active_item, src, TRUE)
	active_item = null
	playsound(get_turf(owner), retract_sound, 50, TRUE)
	return TRUE

/obj/item/organ/internal/cyberimp/arm/proc/Extend(obj/item/augment)
	if(!(augment in src))
		return

	active_item = augment

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
			var/hand_item = hand_items[i]
			if(!owner.dropItemToGround(hand_item))
				failure_message += span_warning("Your [hand_item] interferes with [src]!")
				continue
			to_chat(owner, span_notice("You drop [hand_item] to activate [src]!"))
			success = owner.put_in_hand(active_item, owner.get_empty_held_index_for_side(side))
			break
		if(!success)
			for(var/i in failure_message)
				to_chat(owner, i)
			return
	owner.visible_message(span_notice("[owner] extends [active_item] from [owner.p_their()] [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."),
		span_notice("You extend [active_item] from your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm."),
		span_hear("You hear a short mechanical noise."))
	playsound(get_turf(owner), extend_sound, 50, TRUE)

/obj/item/organ/internal/cyberimp/arm/ui_action_click()
	if((organ_flags & ORGAN_FAILING) || (!active_item && !contents.len))
		to_chat(owner, span_warning("The implant doesn't respond. It seems to be broken..."))
		return

	if(!active_item || (active_item in src))
		active_item = null
		if(contents.len == 1)
			Extend(contents[1])
		else
			var/list/choice_list = list()
			for(var/datum/weakref/augment_ref in items_list)
				var/obj/item/augment_item = augment_ref.resolve()
				if(!augment_item)
					items_list -= augment_ref
					continue
				choice_list[augment_item] = image(augment_item)
			var/obj/item/choice = show_radial_menu(owner, owner, choice_list)
			if(owner && owner == usr && owner.stat != DEAD && (src in owner.internal_organs) && !active_item && (choice in contents))
				// This monster sanity check is a nice example of how bad input is.
				Extend(choice)
	else
		Retract()


/obj/item/organ/internal/cyberimp/arm/gun/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(30/severity) && owner && !(organ_flags & ORGAN_FAILING))
		Retract()
		owner.visible_message(span_danger("A loud bang comes from [owner]\'s [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm!"))
		playsound(get_turf(owner), 'sound/weapons/flashbang.ogg', 100, TRUE)
		to_chat(owner, span_userdanger("You feel an explosion erupt inside your [zone == BODY_ZONE_R_ARM ? "right" : "left"] arm as your implant breaks!"))
		owner.adjust_fire_stacks(20)
		owner.ignite_mob()
		owner.adjustFireLoss(25)
		organ_flags |= ORGAN_FAILING


/obj/item/organ/internal/cyberimp/arm/gun/laser
	name = "arm-mounted laser implant"
	desc = "A variant of the arm cannon implant that fires lethal laser beams. The cannon emerges from the subject's arm and remains inside when not in use."
	icon_state = "arm_laser"
	items_to_create = list(/obj/item/gun/energy/laser/mounted/augment)

/obj/item/organ/internal/cyberimp/arm/gun/laser/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/internal/cyberimp/arm/gun/taser
	name = "arm-mounted taser implant"
	desc = "A variant of the arm cannon implant that fires electrodes and disabler shots. The cannon emerges from the subject's arm and remains inside when not in use."
	icon_state = "arm_taser"
	items_to_create = list(/obj/item/gun/energy/e_gun/advtaser/mounted)

/obj/item/organ/internal/cyberimp/arm/gun/taser/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/internal/cyberimp/arm/toolset
	name = "integrated toolset implant"
	desc = "A stripped-down version of the engineering cyborg toolset, designed to be installed on subject's arm. Contain advanced versions of every tool."
	items_to_create = list(
		/obj/item/screwdriver/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
	)

/obj/item/organ/internal/cyberimp/arm/toolset/l
	zone = BODY_ZONE_L_ARM

/obj/item/organ/internal/cyberimp/arm/toolset/emag_act(mob/user)
	for(var/datum/weakref/created_item in items_list)
		var/obj/potential_knife = created_item.resolve()
		if(istype(/obj/item/knife/combat/cyborg, potential_knife))
			return FALSE

	to_chat(user, span_notice("You unlock [src]'s integrated knife!"))
	items_list += WEAKREF(new /obj/item/knife/combat/cyborg(src))
	return TRUE

/obj/item/organ/internal/cyberimp/arm/esword
	name = "arm-mounted energy blade"
	desc = "An illegal and highly dangerous cybernetic implant that can project a deadly blade of concentrated energy."
	items_to_create = list(/obj/item/melee/energy/blade/hardlight)

/obj/item/organ/internal/cyberimp/arm/medibeam
	name = "integrated medical beamgun"
	desc = "A cybernetic implant that allows the user to project a healing beam from their hand."
	items_to_create = list(/obj/item/gun/medbeam)


/obj/item/organ/internal/cyberimp/arm/flash
	name = "integrated high-intensity photon projector" //Why not
	desc = "An integrated projector mounted onto a user's arm that is able to be used as a powerful flash."
	items_to_create = list(/obj/item/assembly/flash/armimplant)

/obj/item/organ/internal/cyberimp/arm/flash/Initialize(mapload)
	. = ..()
	for(var/datum/weakref/created_item in items_list)
		var/obj/potential_flash = created_item.resolve()
		if(!istype(potential_flash, /obj/item/assembly/flash/armimplant))
			continue
		var/obj/item/assembly/flash/armimplant/flash = potential_flash
		flash.arm = WEAKREF(src) // Todo: wipe single letter vars out of assembly code

/obj/item/organ/internal/cyberimp/arm/flash/Extend()
	. = ..()
	active_item.set_light_range(7)
	active_item.set_light_on(TRUE)

/obj/item/organ/internal/cyberimp/arm/flash/Retract()
	if(active_item)
		active_item.set_light_on(FALSE)
	return ..()

/obj/item/organ/internal/cyberimp/arm/baton
	name = "arm electrification implant"
	desc = "An illegal combat implant that allows the user to administer disabling shocks from their arm."
	items_to_create = list(/obj/item/borg/stun)

/obj/item/organ/internal/cyberimp/arm/combat
	name = "combat cybernetics implant"
	desc = "A powerful cybernetic implant that contains combat modules built into the user's arm."
	items_to_create = list(
		/obj/item/melee/energy/blade/hardlight,
		/obj/item/gun/medbeam,
		/obj/item/borg/stun,
		/obj/item/assembly/flash/armimplant,
	)

/obj/item/organ/internal/cyberimp/arm/combat/Initialize(mapload)
	. = ..()
	for(var/datum/weakref/created_item in items_list)
		var/obj/potential_flash = created_item.resolve()
		if(!istype(potential_flash, /obj/item/assembly/flash/armimplant))
			continue
		var/obj/item/assembly/flash/armimplant/flash = potential_flash
		flash.arm = WEAKREF(src) // Todo: wipe single letter vars out of assembly code

/obj/item/organ/internal/cyberimp/arm/surgery
	name = "surgical toolset implant"
	desc = "A set of surgical tools hidden behind a concealed panel on the user's arm."
	items_to_create = list(
		/obj/item/retractor/augment,
		/obj/item/hemostat/augment,
		/obj/item/cautery/augment,
		/obj/item/surgicaldrill/augment,
		/obj/item/scalpel/augment,
		/obj/item/circular_saw/augment,
		/obj/item/surgical_drapes,
	)

/obj/item/organ/internal/cyberimp/arm/surgery/emagged
	name = "hacked surgical toolset implant"
	desc = "A set of surgical tools hidden behind a concealed panel on the user's arm. This one seems to have been tampered with."
	items_to_create = list(
		/obj/item/retractor/augment,
		/obj/item/hemostat/augment,
		/obj/item/cautery/augment,
		/obj/item/surgicaldrill/augment,
		/obj/item/scalpel/augment,
		/obj/item/circular_saw/augment,
		/obj/item/surgical_drapes,
		/obj/item/knife/combat/cyborg,
	)

/obj/item/organ/internal/cyberimp/arm/muscle
	name = "\proper Strong-Arm empowered musculature implant"
	desc = "When implanted, this cybernetic implant will enhance the muscles of the arm to deliver more power-per-action."
	icon_state = "muscle_implant"

	zone = BODY_ZONE_R_ARM
	slot = ORGAN_SLOT_RIGHT_ARM_AUG

	actions_types = list()
	
	///The amount of damage dealt by the empowered attack.
	var/punch_damage = 13
	///Will the punch smash people into walls?
	var/gentle = TRUE
	///How far away your attack will throw your oponent
	var/attack_throw_range = 1
	///Minimum throw power of the attack
	var/throw_power_min = 1
	///Maximum throw power of the attack
	var/throw_power_max = 4
	///How long will the implant malfunction if it is EMP'd
	var/emp_base_duration = 9 SECONDS 

/obj/item/organ/internal/cyberimp/arm/muscle/Insert(mob/living/carbon/reciever, special = FALSE, drop_if_replaced = TRUE)
	. = ..()
	if(ishuman(reciever)) //Sorry, only humans
		RegisterSignal(reciever, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, PROC_REF(on_attack_hand))

/obj/item/organ/internal/cyberimp/arm/muscle/Remove(mob/living/carbon/implant_owner, special = 0)
	. = ..()
	UnregisterSignal(implant_owner, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)

/obj/item/organ/internal/cyberimp/arm/muscle/emp_act(severity)
	. = ..()
	if((organ_flags & ORGAN_FAILING) || . & EMP_PROTECT_SELF)
		return
	owner.balloon_alert(owner, "your arm spasms wildly!")
	organ_flags |= ORGAN_FAILING
	addtimer(CALLBACK(src, PROC_REF(reboot)), 90 / severity)

/obj/item/organ/internal/cyberimp/arm/muscle/proc/reboot()
	organ_flags &= ~ORGAN_FAILING
	owner.balloon_alert(owner, "your arm stops spasming!")

/obj/item/organ/internal/cyberimp/arm/muscle/proc/on_attack_hand(mob/living/carbon/human/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER

	if(source.get_active_hand() != source.get_bodypart(check_zone(zone)) || !proximity)
		return
	if(!source.combat_mode || LAZYACCESS(modifiers, RIGHT_CLICK))
		return
	if(!isliving(target))
		return

	var/mob/living/living_target = target

	source.changeNext_move(CLICK_CD_MELEE)
	var/picked_hit_type = pick("punch", "smash", "kick")

	if(organ_flags & ORGAN_FAILING)
		if(source.body_position != LYING_DOWN && living_target != source && prob(50))
			to_chat(source, span_danger("You try to [picked_hit_type] [living_target], but lose your balance and fall!"))
			source.Knockdown(3 SECONDS)
			source.forceMove(get_turf(living_target))
		else
			to_chat(source, span_danger("Your muscles spasm!"))
			source.Paralyze(1 SECONDS)
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(ishuman(target))
		var/mob/living/carbon/human/human_target = target
		if(human_target.check_shields(source, punch_damage, "[source]'s' [picked_hit_type]"))
			source.do_attack_animation(target)
			playsound(living_target.loc, 'sound/weapons/punchmiss.ogg', 25, TRUE, -1)
			log_combat(source, target, "attempted to [picked_hit_type]", "muscle implant")
			return COMPONENT_CANCEL_ATTACK_CHAIN

	source.do_attack_animation(target, ATTACK_EFFECT_SMASH)
	playsound(living_target.loc, 'sound/weapons/punch1.ogg', 25, TRUE, -1)

	living_target.apply_damage(punch_damage, BRUTE)

	if(source.body_position != LYING_DOWN) //Throw them if we are standing
		var/atom/throw_target = get_edge_target_turf(living_target, source.dir)
		living_target.throw_at(throw_target, attack_throw_range, rand(throw_power_min,throw_power_max), source, gentle)

	living_target.visible_message(
		span_danger("[source] [picked_hit_type]ed [living_target]!"), 
		span_userdanger("You're [picked_hit_type]ed by [source]!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		COMBAT_MESSAGE_RANGE,
		source,
	)

	to_chat(source, span_danger("You [picked_hit_type] [target]!"))

	log_combat(source, target, "[picked_hit_type]ed", "muscle implant")

	return COMPONENT_CANCEL_ATTACK_CHAIN
