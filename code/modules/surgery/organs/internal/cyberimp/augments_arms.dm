/obj/item/organ/cyberimp/arm
	name = "arm-mounted implant"
	desc = "An implant that goes in your arm to improve it."
	abstract_type = /obj/item/organ/cyberimp/arm
	zone = BODY_ZONE_R_ARM
	slot = ORGAN_SLOT_RIGHT_ARM_AUG
	w_class = WEIGHT_CLASS_SMALL
	valid_zones = list(
		BODY_ZONE_R_ARM = ORGAN_SLOT_RIGHT_ARM_AUG,
		BODY_ZONE_L_ARM = ORGAN_SLOT_LEFT_ARM_AUG,
	)
	///A ref for the arm we're taking up. Mostly for the unregister signal upon removal
	var/obj/hand

/obj/item/organ/cyberimp/arm/get_overlay_state(image_layer, obj/item/bodypart/limb)
	return "[aug_overlay][zone == BODY_ZONE_L_ARM ? "_left" : "_right"]"

/obj/item/organ/cyberimp/arm/on_mob_insert(mob/living/carbon/arm_owner)
	. = ..()
	RegisterSignal(arm_owner, COMSIG_CARBON_POST_ATTACH_LIMB, PROC_REF(on_limb_attached))
	on_limb_attached(arm_owner, arm_owner.hand_bodyparts[zone == BODY_ZONE_R_ARM ? RIGHT_HANDS : LEFT_HANDS])

/obj/item/organ/cyberimp/arm/on_mob_remove(mob/living/carbon/arm_owner)
	. = ..()
	on_limb_detached(hand)

/obj/item/organ/cyberimp/arm/proc/on_limb_attached(mob/living/carbon/source, obj/item/bodypart/limb)
	SIGNAL_HANDLER
	if(!limb || QDELETED(limb) || limb.body_zone != zone)
		return
	if(hand)
		on_limb_detached(hand)
	RegisterSignal(limb, COMSIG_BODYPART_REMOVED, PROC_REF(on_limb_detached))
	hand = limb

/obj/item/organ/cyberimp/arm/proc/on_limb_detached(obj/item/bodypart/source)
	SIGNAL_HANDLER
	if(source != hand || QDELETED(hand))
		return
	UnregisterSignal(hand, COMSIG_BODYPART_REMOVED)
	hand = null

/obj/item/organ/cyberimp/arm/toolkit
	name = "arm-mounted toolkit"
	desc = "You shouldn't see this! Adminhelp and report this as an issue on github!"
	icon_state = "toolkit_generic"
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	//A list of typepaths to create and insert into ourself on init
	var/list/items_to_create = list()
	/// Used to store a list of all items inside, for multi-item implants.
	var/list/items_list = list()// I would use contents, but they shuffle on every activation/deactivation leading to interface inconsistencies.
	/// You can use this var for item path, it would be converted into an item on New().
	var/obj/item/active_item
	/// Sound played when extending
	var/extend_sound = 'sound/vehicles/mecha/mechmove03.ogg'
	/// Sound played when retracting
	var/retract_sound = 'sound/vehicles/mecha/mechmove03.ogg'
	/// Do we have a separate icon_state for the hand overlay?
	var/hand_state = TRUE

/obj/item/organ/cyberimp/arm/toolkit/Initialize(mapload)
	. = ..()
	if(ispath(active_item))
		active_item = new active_item(src)
		items_list += WEAKREF(active_item)

	for(var/typepath in items_to_create)
		var/atom/new_item = new typepath(src)
		items_list += WEAKREF(new_item)

/obj/item/organ/cyberimp/arm/toolkit/Destroy()
	hand = null
	active_item = null
	for(var/datum/weakref/ref in items_list)
		var/obj/item/to_del = ref.resolve()
		if(!to_del)
			continue
		qdel(to_del)
	items_list.Cut()
	return ..()

/datum/action/item_action/organ_action/toggle/toolkit
	desc = "You can also activate your empty hand or the tool in your hand to open the tools radial menu."

/obj/item/organ/cyberimp/arm/toolkit/on_mob_insert(mob/living/carbon/arm_owner)
	. = ..()
	RegisterSignal(arm_owner, COMSIG_KB_MOB_DROPITEM_DOWN, PROC_REF(dropkey)) //We're nodrop, but we'll watch for the drop hotkey anyway and then stow if possible.

/obj/item/organ/cyberimp/arm/toolkit/on_mob_remove(mob/living/carbon/arm_owner)
	. = ..()
	Retract()

/obj/item/organ/cyberimp/arm/toolkit/on_limb_attached(mob/living/carbon/source, obj/item/bodypart/limb)
	. = ..()
	RegisterSignal(limb, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_item_attack_self))

/obj/item/organ/cyberimp/arm/toolkit/on_limb_detached(obj/item/bodypart/source)
	if(source != hand || QDELETED(hand))
		return
	UnregisterSignal(hand, list(COMSIG_BODYPART_REMOVED, COMSIG_ITEM_ATTACK_SELF))
	hand = null

/obj/item/organ/cyberimp/arm/toolkit/proc/on_item_attack_self()
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(ui_action_click))

/obj/item/organ/cyberimp/arm/toolkit/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF || !IS_ROBOTIC_ORGAN(src))
		return
	if(prob(15/severity) && owner)
		to_chat(owner, span_warning("The electromagnetic pulse causes [src] to malfunction!"))
		// give the owner an idea about why his implant is glitching
		Retract()

/obj/item/organ/cyberimp/arm/toolkit/get_overlay(image_layer, obj/item/bodypart/limb)
	if (!hand_state)
		return ..()

	var/mutable_appearance/arm_overlay = mutable_appearance(
		icon = aug_icon,
		icon_state = get_overlay_state(),
		layer = image_layer,
	)
	var/mutable_appearance/hand_overlay = mutable_appearance(
		icon = aug_icon,
		icon_state = "[get_overlay_state()]_hand",
		layer = -BODYPARTS_HIGH_LAYER,
	)
	return list(arm_overlay, hand_overlay)

/**
 * Called when the mob uses the "drop item" hotkey
 *
 * Items inside toolset implants have TRAIT_NODROP, but we can still use the drop item hotkey as a
 * quick way to store implant items. In this case, we check to make sure the user has the correct arm
 * selected, and that the item is actually owned by us, and then we'll hand off the rest to Retract()
**/
/obj/item/organ/cyberimp/arm/toolkit/proc/dropkey(mob/living/carbon/host)
	SIGNAL_HANDLER
	if(!host)
		return //How did we even get here
	if(hand != host.hand_bodyparts[host.active_hand_index])
		return //wrong hand
	if(Retract())
		return COMSIG_KB_ACTIVATED

/obj/item/organ/cyberimp/arm/toolkit/proc/Retract()
	if(!active_item || (active_item in src))
		return FALSE
	active_item.resistance_flags = active_item::resistance_flags
	if(owner)
		owner.visible_message(
			span_notice("[owner] retracts [active_item] back into [owner.p_their()] [parse_zone(zone)]."),
			span_notice("[active_item] snaps back into your [parse_zone(zone)]."),
			span_hear("You hear a short mechanical noise."),
		)

		owner.transferItemToLoc(active_item, src, TRUE)
	else
		active_item.forceMove(src)

	UnregisterSignal(active_item, COMSIG_ITEM_ATTACK_SELF)
	UnregisterSignal(active_item, COMSIG_ITEM_ATTACK_SELF_SECONDARY)
	active_item = null
	playsound(get_turf(owner), retract_sound, 50, TRUE)
	return TRUE

/obj/item/organ/cyberimp/arm/toolkit/proc/Extend(obj/item/augment)
	if(!(augment in src))
		return

	active_item = augment
	active_item.resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	ADD_TRAIT(active_item, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	active_item.slot_flags = null
	active_item.set_custom_materials(null)

	var/side = zone == BODY_ZONE_R_ARM ? RIGHT_HANDS : LEFT_HANDS
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
	owner.visible_message(span_notice("[owner] extends [active_item] from [owner.p_their()] [parse_zone(zone)]."),
		span_notice("You extend [active_item] from your [parse_zone(zone)]."),
		span_hear("You hear a short mechanical noise."))
	playsound(get_turf(owner), extend_sound, 50, TRUE)

	if(length(items_list) > 1)
		RegisterSignals(active_item, list(COMSIG_ITEM_ATTACK_SELF, COMSIG_ITEM_ATTACK_SELF_SECONDARY), PROC_REF(swap_tools)) // secondary for welders

/obj/item/organ/cyberimp/arm/toolkit/proc/swap_tools(active_item)
	SIGNAL_HANDLER
	Retract(active_item)
	INVOKE_ASYNC(src, PROC_REF(ui_action_click))

/obj/item/organ/cyberimp/arm/toolkit/ui_action_click()
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
			if(owner && owner == usr && owner.stat != DEAD && (src in owner.organs) && !active_item && (choice in contents))
				// This monster sanity check is a nice example of how bad input is.
				Extend(choice)
	else
		Retract()

/obj/item/organ/cyberimp/arm/toolkit/gun/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(30/severity) && owner && !(organ_flags & ORGAN_FAILING))
		Retract()
		owner.visible_message(span_danger("A loud bang comes from [owner]\'s [parse_zone(zone)]!"))
		playsound(get_turf(owner), 'sound/items/weapons/flashbang.ogg', 100, TRUE)
		to_chat(owner, span_userdanger("You feel an explosion erupt inside your [parse_zone(zone)] as your implant breaks!"))
		owner.adjust_fire_stacks(20)
		owner.ignite_mob()
		owner.adjustFireLoss(25)
		organ_flags |= ORGAN_FAILING

/obj/item/organ/cyberimp/arm/toolkit/gun/laser
	name = "arm-mounted laser implant"
	desc = "A variant of the arm cannon implant that fires lethal laser beams. The cannon emerges from the subject's arm and remains inside when not in use."
	icon_state = "arm_laser"
	items_to_create = list(/obj/item/gun/energy/laser/mounted/augment)

/obj/item/organ/cyberimp/arm/toolkit/gun/taser
	name = "arm-mounted taser implant"
	desc = "A variant of the arm cannon implant that fires electrodes and disabler shots. The cannon emerges from the subject's arm and remains inside when not in use."
	icon_state = "arm_taser"
	items_to_create = list(/obj/item/gun/energy/e_gun/advtaser/mounted)

/obj/item/organ/cyberimp/arm/toolkit/toolset
	name = "integrated toolset implant"
	desc = "A stripped-down version of the engineering cyborg toolset, designed to be installed on subject's arm. Contain advanced versions of every tool."
	icon_state = "toolkit_engineering"
	aug_overlay = "toolkit_engi"
	actions_types = list(/datum/action/item_action/organ_action/toggle/toolkit)
	items_to_create = list(
		/obj/item/screwdriver/cyborg,
		/obj/item/wrench/cyborg,
		/obj/item/weldingtool/largetank/cyborg,
		/obj/item/crowbar/cyborg,
		/obj/item/wirecutters/cyborg,
		/obj/item/multitool/cyborg,
	)

//The order of the item list for this implant is not alphabetized due to it actually affecting how it shows up playerside when opening the implant
/obj/item/organ/cyberimp/arm/toolkit/paperwork
	name = "integrated paperwork implant"
	desc = "A highly sought out implant among heads of personnel, and other high up command staff in Nanotrasen. This implant allows the user to always have the tools necessary for paperwork handy"
	icon_state = "toolkit_engineering"
	aug_overlay = "toolkit_engi"
	actions_types = list(/datum/action/item_action/organ_action/toggle/toolkit)
	items_to_create = list(
		/obj/item/pen/fountain,
		/obj/item/clipboard,
		/obj/item/taperecorder,
		/obj/item/lighter,
		/obj/item/laser_pointer,
		/obj/item/stamp,
		/obj/item/stamp/denied,
	)

/obj/item/organ/cyberimp/arm/toolkit/paperwork/emag_act(mob/user, obj/item/card/emag/emag_card)
	for(var/datum/weakref/created_item in items_list)
		var/obj/potential_tool = created_item.resolve()
		if(istype(/obj/item/stamp/chameleon, potential_tool))
			return FALSE

	balloon_alert(user, "experimental stamp unlocked")
	items_list += WEAKREF(new /obj/item/stamp/chameleon(src))
	return TRUE

/obj/item/organ/cyberimp/arm/toolkit/toolset/emag_act(mob/user, obj/item/card/emag/emag_card)
	for(var/datum/weakref/created_item in items_list)
		var/obj/potential_knife = created_item.resolve()
		if(istype(/obj/item/knife/combat/cyborg, potential_knife))
			return FALSE

	balloon_alert(user, "integrated knife unlocked")
	items_list += WEAKREF(new /obj/item/knife/combat/cyborg(src))
	return TRUE

/obj/item/organ/cyberimp/arm/toolkit/esword
	name = "arm-mounted energy blade"
	desc = "An illegal and highly dangerous cybernetic implant that can project a deadly blade of concentrated energy."
	items_to_create = list(/obj/item/melee/energy/blade/hardlight)

/obj/item/organ/cyberimp/arm/toolkit/medibeam
	name = "integrated medical beamgun"
	desc = "A cybernetic implant that allows the user to project a healing beam from their hand."
	icon_state = "toolkit_surgical"
	aug_overlay = "toolkit_med"
	items_to_create = list(/obj/item/gun/medbeam)

/obj/item/organ/cyberimp/arm/toolkit/flash
	name = "integrated high-intensity photon projector" //Why not
	desc = "An integrated projector mounted onto a user's arm that is able to be used as a powerful flash."
	aug_overlay = "toolkit"
	items_to_create = list(/obj/item/assembly/flash/armimplant)

/obj/item/organ/cyberimp/arm/toolkit/flash/Initialize(mapload)
	. = ..()
	for(var/datum/weakref/created_item in items_list)
		var/obj/potential_flash = created_item.resolve()
		if(!istype(potential_flash, /obj/item/assembly/flash/armimplant))
			continue
		var/obj/item/assembly/flash/armimplant/flash = potential_flash
		flash.arm = WEAKREF(src)

/obj/item/organ/cyberimp/arm/toolkit/flash/Extend()
	. = ..()
	active_item.set_light_range(7)
	active_item.set_light_on(TRUE)

/obj/item/organ/cyberimp/arm/toolkit/flash/Retract()
	if(active_item)
		active_item.set_light_on(FALSE)
	return ..()

/obj/item/organ/cyberimp/arm/toolkit/baton
	name = "arm electrification implant"
	desc = "An illegal combat implant that allows the user to administer disabling shocks from their arm."
	aug_overlay = "toolkit"
	items_to_create = list(/obj/item/borg/stun)

/obj/item/organ/cyberimp/arm/toolkit/combat
	name = "combat cybernetics implant"
	desc = "A powerful cybernetic implant that contains combat modules built into the user's arm."
	aug_overlay = "toolkit"
	items_to_create = list(
		/obj/item/melee/energy/blade/hardlight,
		/obj/item/gun/medbeam,
		/obj/item/borg/stun,
		/obj/item/assembly/flash/armimplant,
	)

/obj/item/organ/cyberimp/arm/toolkit/combat/Initialize(mapload)
	. = ..()
	for(var/datum/weakref/created_item in items_list)
		var/obj/potential_flash = created_item.resolve()
		if(!istype(potential_flash, /obj/item/assembly/flash/armimplant))
			continue
		var/obj/item/assembly/flash/armimplant/flash = potential_flash
		flash.arm = WEAKREF(src)

/obj/item/organ/cyberimp/arm/toolkit/surgery
	name = "surgical toolset implant"
	desc = "A set of surgical tools hidden behind a concealed panel on the user's arm."
	icon_state = "toolkit_surgical"
	aug_overlay = "toolkit_med"
	actions_types = list(/datum/action/item_action/organ_action/toggle/toolkit)
	items_to_create = list(
		/obj/item/retractor/augment,
		/obj/item/hemostat/augment,
		/obj/item/cautery/augment,
		/obj/item/surgicaldrill/augment,
		/obj/item/scalpel/augment,
		/obj/item/circular_saw/augment,
		/obj/item/surgical_drapes,
	)

/obj/item/organ/cyberimp/arm/toolkit/surgery/emagged
	name = "hacked surgical toolset implant"
	desc = "A set of surgical tools hidden behind a concealed panel on the user's arm. This one seems to have been tampered with."
	aug_overlay = "toolkit_med"
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

/obj/item/organ/cyberimp/arm/toolkit/surgery/cruel
	name = "morbid surgical toolset implant"
	desc = "A modified set of surgical tools hidden behind a concealed panel on the user's arm. These tools seem twisted and cruel, designed to maximize pain while operating with incredible precision."
	icon_state = "toolkit_surgical_cruel"
	aug_overlay = "toolkit_med"
	actions_types = list(/datum/action/item_action/organ_action/toggle/toolkit)
	items_to_create = list(
		/obj/item/retractor/cruel/augment,
		/obj/item/hemostat/cruel/augment,
		/obj/item/cautery/cruel/augment,
		/obj/item/surgicaldrill/cruel/augment,
		/obj/item/scalpel/cruel/augment,
		/obj/item/circular_saw/cruel/augment,
		/obj/item/surgical_drapes,
	)

#define DOAFTER_SOURCE_STRONGARM_INTERACTION "strongarm interaction"

// Strong-Arm Implant //

/obj/item/organ/cyberimp/arm/strongarm
	name = "\proper Strong-Arm empowered musculature implant"
	desc = "When implanted, this cybernetic implant will enhance the muscles of the arm to deliver more power-per-action. Install one in each arm \
		to pry open doors with your bare hands!"
	icon_state = "muscle_implant"
	zone = BODY_ZONE_R_ARM
	slot = ORGAN_SLOT_RIGHT_ARM_MUSCLE
	valid_zones = list(
		BODY_ZONE_R_ARM = ORGAN_SLOT_RIGHT_ARM_MUSCLE,
		BODY_ZONE_L_ARM = ORGAN_SLOT_LEFT_ARM_MUSCLE,
	)
	aug_overlay = "strongarm"

	///The amount of damage the implant adds to our unarmed attacks.
	var/punch_damage = 5
	///Biotypes we apply an additional amount of damage too
	var/biotype_bonus_targets = MOB_BEAST | MOB_SPECIAL | MOB_MINING
	///Extra damage dealt to our targeted mobs
	var/biotype_bonus_damage = 20
	///IF true, the throw attack will not smash people into walls
	var/non_harmful_throw = TRUE
	///How far away your attack will throw your oponent
	var/attack_throw_range = 1
	///Minimum throw power of the attack
	var/throw_power_min = 1
	///Maximum throw power of the attack
	var/throw_power_max = 4
	///How long will the implant malfunction if it is EMP'd
	var/emp_base_duration = 9 SECONDS
	///How long before we get another slam punch; consider that these usually come in pairs of two
	var/slam_cooldown_duration = 5 SECONDS
	///Tracks how soon we can perform another slam attack
	COOLDOWN_DECLARE(slam_cooldown)

/obj/item/organ/cyberimp/arm/strongarm/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/organ_set_bonus, /datum/status_effect/organ_set_bonus/strongarm)

/obj/item/organ/cyberimp/arm/strongarm/on_mob_insert(mob/living/carbon/arm_owner)
	. = ..()
	if(ishuman(arm_owner)) //Sorry, only humans
		RegisterSignal(arm_owner, COMSIG_LIVING_EARLY_UNARMED_ATTACK, PROC_REF(on_attack_hand))

/obj/item/organ/cyberimp/arm/strongarm/on_mob_remove(mob/living/carbon/arm_owner)
	. = ..()
	UnregisterSignal(arm_owner, COMSIG_LIVING_EARLY_UNARMED_ATTACK)

/obj/item/organ/cyberimp/arm/strongarm/emp_act(severity)
	. = ..()
	if((organ_flags & ORGAN_FAILING) || . & EMP_PROTECT_SELF)
		return
	owner.balloon_alert(owner, "your arm spasms wildly!")
	organ_flags |= ORGAN_FAILING
	addtimer(CALLBACK(src, PROC_REF(reboot)), 90 / severity)

/obj/item/organ/cyberimp/arm/strongarm/proc/reboot()
	organ_flags &= ~ORGAN_FAILING
	owner.balloon_alert(owner, "your arm stops spasming!")

/obj/item/organ/cyberimp/arm/strongarm/proc/on_attack_hand(mob/living/carbon/human/source, atom/target, proximity, modifiers)
	SIGNAL_HANDLER

	if(source.get_active_hand() != hand || !proximity)
		return NONE
	if(!source.combat_mode || LAZYACCESS(modifiers, RIGHT_CLICK))
		return NONE
	if(!isliving(target))
		return NONE
	if(HAS_TRAIT(source, TRAIT_HULK)) //NO HULK
		return NONE
	if(!COOLDOWN_FINISHED(src, slam_cooldown))
		return NONE
	if(!source.can_unarmed_attack())
		return COMPONENT_SKIP_ATTACK

	var/mob/living/living_target = target
	source.changeNext_move(CLICK_CD_MELEE)
	var/picked_hit_type = pick("punch", "smash", "pummel", "bash", "slam")

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
		if(human_target.check_block(source, punch_damage, "[source]'s' [picked_hit_type]"))
			source.do_attack_animation(target)
			playsound(living_target.loc, 'sound/items/weapons/punchmiss.ogg', 25, TRUE, -1)
			log_combat(source, target, "attempted to [picked_hit_type]", "muscle implant")
			return COMPONENT_CANCEL_ATTACK_CHAIN

	var/ground_bounce = FALSE // funny flavor. if you hit someone who's floored you slam them into the ground, breaking tiles
	var/turf/target_turf = get_turf(living_target)

	var/obj/item/bodypart/attacking_bodypart = hand
	var/potential_damage = punch_damage
	var/potential_effectiveness = attacking_bodypart.unarmed_effectiveness
	var/potential_pummel_bonus = attacking_bodypart.unarmed_pummeling_bonus
	potential_damage += rand(attacking_bodypart.unarmed_damage_low, attacking_bodypart.unarmed_damage_high)

	if(living_target.pulledby && living_target.pulledby.grab_state >= GRAB_AGGRESSIVE) // get pummeled idiot
		potential_damage *= potential_pummel_bonus
		potential_effectiveness *= potential_pummel_bonus
		if(living_target.body_position == LYING_DOWN)
			ground_bounce = TRUE

	var/is_correct_biotype = living_target.mob_biotypes & biotype_bonus_targets
	if(biotype_bonus_targets && is_correct_biotype) //If we are punching one of our special biotype targets, increase the damage floor by a factor of two.
		potential_damage += biotype_bonus_damage

	source.do_attack_animation(target, ATTACK_EFFECT_SMASH)
	playsound(living_target.loc, 'sound/items/weapons/punch1.ogg', 25, TRUE, -1)

	var/target_zone = living_target.get_random_valid_zone(source.zone_selected)
	var/armor_block = living_target.run_armor_check(target_zone, MELEE, armour_penetration = potential_effectiveness)
	living_target.apply_damage(potential_damage * 2, attacking_bodypart.attack_type, target_zone, armor_block)

	if(source.body_position != LYING_DOWN) //Throw them if we are standing
		var/atom/throw_target = get_edge_target_turf(living_target, source.dir)
		living_target.throw_at(throw_target, attack_throw_range, rand(throw_power_min,throw_power_max), source, gentle = non_harmful_throw)
		if(ground_bounce)
			if(isfloorturf(target_turf))
				var/turf/open/floor/crunched = target_turf
				crunched.crush() // crunch

	living_target.visible_message(
		span_danger("[source] [picked_hit_type]ed [living_target][ground_bounce ? " into [target_turf]" : ""]!"),
		span_userdanger("You're [picked_hit_type]ed by [source][ground_bounce ? " into [target_turf]" : ""]!"),
		span_hear("You hear a sickening sound of flesh hitting flesh!"),
		COMBAT_MESSAGE_RANGE,
		source,
	)

	to_chat(source, span_danger("You [picked_hit_type] [target][ground_bounce ? " into [target_turf]" : ""]!"))

	log_combat(source, target, "[picked_hit_type]ed", "muscle implant")

	COOLDOWN_START(src, slam_cooldown, slam_cooldown_duration)

	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/status_effect/organ_set_bonus/strongarm
	id = "organ_set_bonus_strongarm"
	organs_needed = 2
	bonus_activate_text = span_notice("Your improved arms allow you to open airlocks by force with your bare hands!")
	bonus_deactivate_text = span_notice("You can no longer force open airlocks with your bare hands.")
	required_biotype = NONE

/datum/status_effect/organ_set_bonus/strongarm/enable_bonus(obj/item/organ/inserted_organ)
	. = ..()
	if(!.)
		return
	owner.AddElement(/datum/element/door_pryer, pry_time = 6 SECONDS, interaction_key = DOAFTER_SOURCE_STRONGARM_INTERACTION)

/datum/status_effect/organ_set_bonus/strongarm/disable_bonus(obj/item/organ/removed_organ)
	. = ..()
	owner.RemoveElement(/datum/element/door_pryer, pry_time = 6 SECONDS, interaction_key = DOAFTER_SOURCE_STRONGARM_INTERACTION)

#undef DOAFTER_SOURCE_STRONGARM_INTERACTION
