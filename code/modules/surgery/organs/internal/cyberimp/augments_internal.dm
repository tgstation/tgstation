
/obj/item/organ/cyberimp
	name = "cybernetic implant"
	desc = "A state-of-the-art implant that improves a baseline's functionality."
	abstract_type = /obj/item/organ/cyberimp
	organ_flags = ORGAN_ROBOTIC
	failing_desc = "seems to be broken."
	/// icon of the bodypart overlay we're going to be applying to our owner
	var/aug_icon = 'icons/mob/human/species/misc/bodypart_overlay_augmentations.dmi'
	/// icon_state of the bodypart overlay we're going to be applying to our owner
	var/aug_overlay = null
	/// Does the implant have an emissive overlay too?
	var/emissive_overlay = FALSE
	/// Bodypart overlay we're going to apply to whoever we're implanted into
	var/datum/bodypart_overlay/augment/bodypart_aug = null

/obj/item/organ/cyberimp/Initialize(mapload)
	. = ..()
	if (aug_overlay)
		bodypart_aug = new(src)

/obj/item/organ/cyberimp/Destroy()
	QDEL_NULL(bodypart_aug)
	return ..()

/obj/item/organ/cyberimp/proc/get_overlay_state()
	return aug_overlay

/obj/item/organ/cyberimp/proc/get_overlay(image_layer, obj/item/bodypart/limb)
	. = list()
	. += image(icon = aug_icon, icon_state = get_overlay_state(), layer = image_layer)
	if (emissive_overlay)
		. += emissive_appearance(aug_icon, "[get_overlay_state()]_e", limb.owner || limb, image_layer)

/obj/item/organ/cyberimp/on_bodypart_insert(obj/item/bodypart/limb)
	. = ..()
	if (bodypart_aug)
		limb.add_bodypart_overlay(bodypart_aug)

/obj/item/organ/cyberimp/on_bodypart_remove(obj/item/bodypart/limb)
	. = ..()
	if (bodypart_aug)
		limb.remove_bodypart_overlay(bodypart_aug)

/datum/bodypart_overlay/augment
	layers = EXTERNAL_ADJACENT
	/// Implant that owns this overlay
	var/obj/item/organ/cyberimp/implant

/datum/bodypart_overlay/augment/New(obj/item/organ/cyberimp/implant)
	. = ..()
	src.implant = implant

/datum/bodypart_overlay/augment/Destroy(force)
	implant = null
	return ..()

/datum/bodypart_overlay/augment/generate_icon_cache()
	. = ..()
	. += implant.get_overlay_state()

/datum/bodypart_overlay/augment/get_overlay(layer, obj/item/bodypart/limb)
	layer = bitflag_to_layer(layer)
	var/list/imageset = implant.get_overlay(layer, limb)
	if(blocks_emissive == EMISSIVE_BLOCK_NONE || !limb)
		return imageset

	var/list/all_images = list()
	for(var/image/overlay as anything in imageset)
		all_images += overlay
		all_images += emissive_blocker(overlay.icon, overlay.icon_state, limb, layer = overlay.layer, alpha = overlay.alpha)

	return all_images

/obj/item/organ/cyberimp/feel_for_damage(self_aware)
	// No feeling in implants (yet?)
	return ""

//[[[[BRAIN]]]]

/obj/item/organ/cyberimp/brain
	name = "cybernetic brain implant"
	desc = "Injectors of extra sub-routines for the brain."
	zone = BODY_ZONE_HEAD
	w_class = WEIGHT_CLASS_TINY
	/// Duration of stun when hit with worst-case emp
	var/emp_stun_duration = 20 SECONDS
	/// Duration of immobilization when hit with worst-case emp
	var/emp_immobilize_duration = 0 SECONDS

/obj/item/organ/cyberimp/brain/emp_act(severity)
	. = ..()
	if(isnull(owner) || (. & EMP_PROTECT_SELF))
		return
	if(emp_immobilize_duration > 0)
		owner.Immobilize(emp_immobilize_duration / severity)
	if(emp_stun_duration > 0)
		owner.Stun(emp_stun_duration / severity)
		to_chat(owner, span_warning("Your body seizes up!"))

/obj/item/organ/cyberimp/brain/anti_drop
	name = "anti-drop implant"
	desc = "This cybernetic brain implant will allow you to force your hand muscles to contract, preventing item dropping. Twitch ear to toggle."
	icon_state = "brain_implant_antidrop"
	var/active = FALSE
	var/list/stored_items = list()
	slot = ORGAN_SLOT_BRAIN_CEREBELLUM
	actions_types = list(/datum/action/item_action/organ_action/toggle)

/obj/item/organ/cyberimp/brain/anti_drop/ui_action_click()
	active = !active
	if(active)
		var/list/hold_list = owner.get_empty_held_indexes()
		if(LAZYLEN(hold_list) == owner.held_items.len)
			to_chat(owner, span_notice("You are not holding any items, your hands relax..."))
			active = FALSE
			return
		for(var/obj/item/held_item as anything in owner.held_items)
			if(!held_item)
				continue
			stored_items += held_item
			to_chat(owner, span_notice("Your [owner.get_held_index_name(owner.get_held_index_of_item(held_item))]'s grip tightens."))
			ADD_TRAIT(held_item, TRAIT_NODROP, IMPLANT_TRAIT)
			RegisterSignal(held_item, COMSIG_ITEM_DROPPED, PROC_REF(on_held_item_dropped))
	else
		release_items()
		to_chat(owner, span_notice("Your hands relax..."))


/obj/item/organ/cyberimp/brain/anti_drop/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	var/range = severity ? 10 : 5
	var/atom/throw_target
	if(active)
		release_items()
	for(var/obj/item/stored_item as anything in stored_items)
		throw_target = pick(oview(range))
		stored_item.throw_at(throw_target, range, 2)
		to_chat(owner, span_warning("Your [owner.get_held_index_name(owner.get_held_index_of_item(stored_item))] spasms and throws \the [stored_item]!"))
	stored_items = list()


/obj/item/organ/cyberimp/brain/anti_drop/proc/release_items()
	for(var/obj/item/stored_item as anything in stored_items)
		REMOVE_TRAIT(stored_item, TRAIT_NODROP, IMPLANT_TRAIT)
		UnregisterSignal(stored_item, COMSIG_ITEM_DROPPED)
	stored_items = list()


/obj/item/organ/cyberimp/brain/anti_drop/Remove(mob/living/carbon/implant_owner, special, movement_flags)
	if(active)
		ui_action_click()
	..()

/obj/item/organ/cyberimp/brain/anti_drop/proc/on_held_item_dropped(obj/item/source, mob/user)
	SIGNAL_HANDLER
	REMOVE_TRAIT(source, TRAIT_NODROP, IMPLANT_TRAIT)
	UnregisterSignal(source, COMSIG_ITEM_DROPPED)
	stored_items -= source

/obj/item/organ/cyberimp/brain/anti_stun
	name = "CNS rebooter implant"
	desc = "This implant will automatically give you back control over your central nervous system, reducing downtime when stunned."
	icon_state = "brain_implant_rebooter"
	slot = ORGAN_SLOT_BRAIN_CNS

	var/static/list/signalCache = list(
		COMSIG_LIVING_STATUS_STUN,
		COMSIG_LIVING_STATUS_IMMOBILIZE,
		COMSIG_LIVING_STATUS_PARALYZE,
	)

	///timer before the implant activates
	var/stun_cap_amount = 1 SECONDS
	///amount of time you are resistant to stuns and knockdowns
	var/stun_resistance_time = 6 SECONDS
	COOLDOWN_DECLARE(implant_cooldown)

/obj/item/organ/cyberimp/brain/anti_stun/on_mob_remove(mob/living/carbon/implant_owner)
	. = ..()
	UnregisterSignal(implant_owner, signalCache)
	UnregisterSignal(implant_owner, COMSIG_LIVING_ENTER_STAMCRIT)
	remove_stun_buffs(implant_owner)

/obj/item/organ/cyberimp/brain/anti_stun/on_mob_insert(mob/living/carbon/receiver)
	. = ..()
	RegisterSignals(receiver, signalCache, PROC_REF(on_signal))
	RegisterSignal(receiver, COMSIG_LIVING_ENTER_STAMCRIT, PROC_REF(on_stamcrit))

/obj/item/organ/cyberimp/brain/anti_stun/proc/on_signal(datum/source, amount)
	SIGNAL_HANDLER
	if(!(organ_flags & ORGAN_FAILING) && amount > 0)
		addtimer(CALLBACK(src, PROC_REF(clear_stuns)), stun_cap_amount, TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/item/organ/cyberimp/brain/anti_stun/proc/on_stamcrit(datum/source)
	SIGNAL_HANDLER
	if(!(organ_flags & ORGAN_FAILING))
		addtimer(CALLBACK(src, PROC_REF(clear_stuns)), stun_cap_amount, TIMER_UNIQUE|TIMER_OVERRIDE)

/obj/item/organ/cyberimp/brain/anti_stun/proc/clear_stuns()
	if(isnull(owner) || (organ_flags & ORGAN_FAILING) || !COOLDOWN_FINISHED(src, implant_cooldown))
		return

	owner.SetStun(0)
	owner.SetKnockdown(0)
	owner.SetImmobilized(0)
	owner.SetParalyzed(0)
	owner.set_stamina_loss(0)
	addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob/living, set_stamina_loss), 0), stun_resistance_time)

	var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
	sparks.set_up(5, 1, src)
	sparks.start()

	give_stun_buffs(owner)
	addtimer(CALLBACK(src, PROC_REF(remove_stun_buffs), owner), stun_resistance_time)

	COOLDOWN_START(src, implant_cooldown, 60 SECONDS)
	addtimer(CALLBACK(src, PROC_REF(implant_ready)),60 SECONDS)

/obj/item/organ/cyberimp/brain/anti_stun/proc/implant_ready()
	if(owner)
		to_chat(owner, span_purple("Your rebooter implant is ready."))

/obj/item/organ/cyberimp/brain/anti_stun/proc/give_stun_buffs(mob/living/give_to = owner)
	give_to.add_traits(list(TRAIT_STUNIMMUNE, TRAIT_BATON_RESISTANCE), REF(src))
	give_to.add_movespeed_mod_immunities(REF(src), /datum/movespeed_modifier/damage_slowdown)

/obj/item/organ/cyberimp/brain/anti_stun/proc/remove_stun_buffs(mob/living/remove_from = owner)
	remove_from.remove_traits(list(TRAIT_STUNIMMUNE, TRAIT_BATON_RESISTANCE), REF(src))
	remove_from.remove_movespeed_mod_immunities(REF(src), /datum/movespeed_modifier/damage_slowdown)

/obj/item/organ/cyberimp/brain/anti_stun/emp_act(severity)
	. = ..()
	if((organ_flags & ORGAN_FAILING) || . & EMP_PROTECT_SELF)
		return
	organ_flags |= ORGAN_FAILING
	addtimer(CALLBACK(src, PROC_REF(reboot)), 90 / severity)

/obj/item/organ/cyberimp/brain/anti_stun/proc/reboot()
	organ_flags &= ~ORGAN_FAILING
	implant_ready()

/obj/item/organ/cyberimp/brain/connector
	name = "CNS skillchip connector implant"
	desc = "This cybernetic adds a port to the back of your head, where you can remove or add skillchips at will."
	icon_state = "brain_implant_connector"
	slot = ORGAN_SLOT_BRAIN_CNS
	actions_types = list(/datum/action/item_action/organ_action/use)

/obj/item/organ/cyberimp/brain/connector/ui_action_click()

	to_chat(owner, span_warning("You start fiddling around with [src]..."))
	playsound(owner, 'sound/items/taperecorder/tape_flip.ogg', 20, vary = TRUE) // asmr

	if(!do_after(owner, 1.5 SECONDS, owner)) // othwerwise it doesnt appear
		to_chat(owner, span_warning("You were interrupted!"))
		return

	if(organ_flags & ORGAN_FAILING)
		var/holy_shit_my_brain = remove_brain()
		if(holy_shit_my_brain)
			to_chat(owner, span_warning("You take [holy_shit_my_brain] out of [src]. You stare at it for a moment in confusion."))
		return

	var/obj/item/skillchip/skillchip = owner.get_active_held_item()
	if(skillchip)
		if(istype(skillchip, /obj/item/skillchip))
			insert_skillchip(skillchip)
		else
			to_chat(owner, span_warning("You try to insert [owner.get_active_held_item()] into [src], but it won't fit!")) // make it kill you if you shove a crayon inside or something
	else // no inhand item, assume removal
		var/obj/item/organ/brain/chippy_brain = owner.get_organ_by_type(/obj/item/organ/brain)
		if(!chippy_brain)
			CRASH("we using a brain implant wit no brain")
		remove_skillchip(chippy_brain)

/obj/item/organ/cyberimp/brain/connector/proc/insert_skillchip(obj/item/skillchip/skillchip)
	var/fail_string = owner.implant_skillchip(skillchip, force = FALSE)
	if(fail_string)
		to_chat(owner, span_warning(fail_string))
		playsound(owner, 'sound/machines/buzz/buzz-sigh.ogg', 10, vary = TRUE)
		return

	var/refail_string = skillchip.try_activate_skillchip(silent = FALSE, force = FALSE)
	if(refail_string)
		to_chat(owner, span_warning(fail_string))
		playsound(owner, 'sound/machines/buzz/buzz-two.ogg', 10, vary = TRUE)
		return

	// success!
	playsound(owner, 'sound/machines/chime.ogg', 10, vary = TRUE)

/obj/item/organ/cyberimp/brain/connector/proc/remove_skillchip(obj/item/organ/brain/chippy_brain)
	var/obj/item/skillchip/skillchip = show_radial_menu(owner, owner, chippy_brain.skillchips)
	if(skillchip)
		owner.remove_skillchip(skillchip, silent = FALSE)
		skillchip.forceMove(owner.drop_location())
		owner.put_in_hands(skillchip, del_on_fail = FALSE)
		playsound(owner, 'sound/machines/click.ogg', 10, vary = TRUE)
		to_chat(owner, span_warning("You take [skillchip] out of [src]."))
		return

	to_chat(owner, span_warning("Your brain is empty!")) // heh

/obj/item/organ/cyberimp/brain/connector/emp_act(severity)
	. = ..()
	if((organ_flags & ORGAN_FAILING) || . & EMP_PROTECT_SELF)
		return
	organ_flags |= ORGAN_FAILING
	var/loops = 1
	if(severity != EMP_LIGHT)
		loops = 2
	for(var/i in 1 to loops)
		// you either lose a chip or a bit of your brain
		owner.visible_message(span_warning("Something falls to the ground from behind [owner]'s head."),\
			span_boldwarning("You feel something fall off from behind your head."))
		var/obj/item/organ/brain/chippy_brain = owner.get_organ_by_type(ORGAN_SLOT_BRAIN)
		var/obj/item/skillchip/skillchip = chippy_brain?.skillchips[1]
		if(skillchip)
			owner.remove_skillchip(skillchip, silent = TRUE)
			skillchip.forceMove(owner.drop_location())
			playsound(owner, 'sound/machines/terminal/terminal_eject.ogg', 25, TRUE)
		else
			remove_brain()
	addtimer(CALLBACK(src, PROC_REF(reboot)), 90 / severity)

/obj/item/organ/cyberimp/brain/connector/proc/remove_brain(obj/item/organ/brain/chippy_brain, severity = 1)
	playsound(owner, 'sound/effects/meatslap.ogg', 25, TRUE)
	if(!chippy_brain)
		return
	chippy_brain.apply_organ_damage(20 * severity)
	chippy_brain.maxHealth -= 15 * severity // a bit of your brain fell off. again.
	if(chippy_brain.damage >= chippy_brain.maxHealth)
		chippy_brain.forceMove(owner.drop_location())
		owner.visible_message(span_userdanger("[owner]'s brain falls off the back of [owner.p_their()] head!!!"), span_boldwarning("You feel like you're missing something."))
		return chippy_brain

	var/gib_type = /obj/effect/decal/cleanable/blood/gibs/up
	if (IS_ROBOTIC_ORGAN(chippy_brain))
		gib_type = /obj/effect/decal/cleanable/blood/gibs/robot_debris/up
	new gib_type(get_turf(owner), owner.get_static_viruses(), owner.get_blood_dna_list())
	return FALSE

/obj/item/organ/cyberimp/brain/connector/proc/reboot()
	organ_flags &= ~ORGAN_FAILING

/obj/item/organ/cyberimp/brain/surgical_processor
	name = "surgical processor implant"
	desc = "A cybernetic brain implant that allows you to perform advanced operations anywhere, anytime."
	icon_state = "brain_implant_antidrop"
	slot = ORGAN_SLOT_BRAIN_HIPPOCAMPUS
	emp_stun_duration = 0 SECONDS
	emp_immobilize_duration = 4 SECONDS
	/// Lazylist of surgeries this implant provides
	var/list/loaded_surgeries

/obj/item/organ/cyberimp/brain/surgical_processor/examine(mob/user)
	. = ..()
	if(length(loaded_surgeries))
		. += span_info("Load surgeries from an operating compuer or a disk containing surgery data. Loaded surgeries:")
		for(var/datum/surgery_operation/downloaded_surgery as anything in GLOB.operations.get_instances_from(loaded_surgeries))
			if(!(downloaded_surgery.operation_flags & OPERATION_LOCKED))
				continue
			// for simplicitly, filters out mechanical subtypes of normal surgeries
			if((downloaded_surgery.operation_flags & OPERATION_MECHANIC) && (downloaded_surgery.parent_type in loaded_surgeries))
				continue
			. += span_info("&bull; [capitalize(downloaded_surgery.rnd_name || downloaded_surgery.name)]")

	else
		. += span_info("Load surgeries from an operating compuer or a disk containing surgery data.")
		. += span_info("No surgeries loaded. Surgeries must be loaded <i>before</i> installation.")

/obj/item/organ/cyberimp/brain/surgical_processor/proc/load_surgeries(mob/living/user, obj/design_holder)
	balloon_alert(user, "copying designs...")
	playsound(src, 'sound/machines/terminal/terminal_processing.ogg', 25, TRUE)
	if(do_after(user, 1 SECONDS, target = design_holder))
		if(istype(design_holder, /obj/item/disk/surgery))
			var/obj/item/disk/surgery/surgery_disk = design_holder
			LAZYOR(loaded_surgeries, surgery_disk.surgeries)
		else
			var/obj/machinery/computer/operating/surgery_computer = design_holder
			LAZYOR(loaded_surgeries, surgery_computer.advanced_surgeries)
		playsound(src, 'sound/machines/terminal/terminal_success.ogg', 25, TRUE)
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/item/organ/cyberimp/brain/surgical_processor/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(istype(interacting_with, /obj/item/disk/surgery) || istype(interacting_with, /obj/machinery/computer/operating))
		return load_surgeries(user, interacting_with)
	return NONE

/obj/item/organ/cyberimp/brain/surgical_processor/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/disk/surgery))
		return load_surgeries(user, tool)
	return NONE

/obj/item/organ/cyberimp/brain/surgical_processor/on_mob_insert(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	RegisterSignal(organ_owner, COMSIG_LIVING_OPERATING_ON, PROC_REF(check_surgery))

/obj/item/organ/cyberimp/brain/surgical_processor/on_mob_remove(mob/living/carbon/organ_owner, special, movement_flags)
	. = ..()
	UnregisterSignal(organ_owner, COMSIG_LIVING_OPERATING_ON)

/obj/item/organ/cyberimp/brain/surgical_processor/proc/check_surgery(datum/source, mob/living/patient, list/operations)
	SIGNAL_HANDLER

	if(organ_flags & (ORGAN_FAILING|ORGAN_EMP))
		return

	operations |= loaded_surgeries

/obj/item/organ/cyberimp/brain/surgical_processor/emp_act(severity)
	. = ..()
	if(isnull(owner) || (. & EMP_PROTECT_SELF))
		return

	var/obj/item/organ/surgeon_brain = owner.get_organ_by_type(/obj/item/organ/brain)
	surgeon_brain.apply_organ_damage(20 / severity, maximum = 120)


	var/duration = (30 SECONDS) / severity
	if(owner.mob_mood?.mood_modifier > 0)
		// forced insanity - reset to "only a little crazy" after
		owner.mob_mood.set_sanity(SANITY_INSANE)
		addtimer(CALLBACK(owner.mob_mood, TYPE_PROC_REF(/datum/mood, reset_sanity), SANITY_UNSTABLE + 10), duration, TIMER_DELETE_ME)
		// and some moodlets to sell the sanity loss
		owner.add_mood_event("surgery_emp", /datum/mood_event/surgery_emp_active)
		addtimer(CALLBACK(owner, TYPE_PROC_REF(/mob/living, add_mood_event), "surgery_emp", /datum/mood_event/surgery_emp_expired), duration, TIMER_DELETE_ME)

	// causes the surgeon to go crazy and start stabbing people
	owner.apply_status_effect(/datum/status_effect/forced_combat, duration, (rand(8, 16) / severity))
	to_chat(owner, span_boldwarning("Your surgical processor malfunctions, giving you an overwhelming urge to incise, saw, and stitch!"))

/datum/mood_event/surgery_emp_active
	description = "THE PATIENT WILL NOT SURVIVE UNLESS THE OPERATION IS COMPLETE!"
	mood_change = -90
	timeout = 1 MINUTES
	special_screen_obj = "mood_despair"

/datum/mood_event/surgery_emp_expired
	description = "I lost control - Thankfully it's over now."
	timeout = 5 MINUTES

/obj/item/organ/cyberimp/brain/surgical_processor/pre_loaded
	loaded_surgeries = list(
		/datum/surgery_operation/basic/tend_wounds/combo/upgraded/master,
		/datum/surgery_operation/limb/bioware/cortex_folding,
		/datum/surgery_operation/limb/bioware/cortex_folding/mechanic,
		/datum/surgery_operation/limb/bioware/cortex_imprint,
		/datum/surgery_operation/limb/bioware/cortex_imprint/mechanic,
		/datum/surgery_operation/limb/bioware/ligament_hook,
		/datum/surgery_operation/limb/bioware/ligament_hook/mechanic,
		/datum/surgery_operation/limb/bioware/ligament_reinforcement,
		/datum/surgery_operation/limb/bioware/ligament_reinforcement/mechanic,
		/datum/surgery_operation/limb/bioware/muscled_veins,
		/datum/surgery_operation/limb/bioware/muscled_veins/mechanic,
		/datum/surgery_operation/limb/bioware/nerve_grounding,
		/datum/surgery_operation/limb/bioware/nerve_grounding/mechanic,
		/datum/surgery_operation/limb/bioware/nerve_splicing,
		/datum/surgery_operation/limb/bioware/nerve_splicing/mechanic,
		/datum/surgery_operation/limb/bioware/vein_threading,
		/datum/surgery_operation/limb/bioware/vein_threading/mechanic,
		/datum/surgery_operation/organ/brainwash,
		/datum/surgery_operation/organ/brainwash/mechanic,
		/datum/surgery_operation/organ/pacify,
		/datum/surgery_operation/organ/pacify/mechanic,
	)

//[[[[MOUTH]]]]
/obj/item/organ/cyberimp/mouth
	zone = BODY_ZONE_PRECISE_MOUTH

/obj/item/organ/cyberimp/mouth/breathing_tube
	name = "breathing tube implant"
	desc = "This simple implant adds an internals connector to your back, allowing you to use internals without a mask and protecting you from being choked."
	icon_state = "implant_mask"
	slot = ORGAN_SLOT_BREATHING_TUBE
	w_class = WEIGHT_CLASS_TINY
	aug_overlay = "breathing_tube"

/obj/item/organ/cyberimp/mouth/breathing_tube/emp_act(severity)
	. = ..()
	if(!owner || . & EMP_PROTECT_SELF)
		return
	if(prob(60/severity))
		to_chat(owner, span_warning("Your breathing tube suddenly closes!"))
		owner.losebreath += 2
