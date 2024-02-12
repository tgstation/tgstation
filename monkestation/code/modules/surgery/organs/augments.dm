/obj/item/organ/internal/cyberimp/arm/power_cord
	name = "power cord implant"
	desc = "An internal power cord hooked up to a battery. Useful if you run on volts."
	contents = newlist(/obj/item/apc_powercord)
	zone = "l_arm"

/obj/item/organ/internal/cyberimp/brain/linked_surgery
	name = "surgical serverlink brain implant"
	desc = "A brain implant with a bluespace technology that lets you perform an advanced surgery through your station research server."
	slot = ORGAN_SLOT_BRAIN_SURGICAL_IMPLANT
	actions_types = list(/datum/action/item_action/organ_action/toggle)
	var/list/loaded_surgeries = list()
	var/static/datum/techweb/linked_techweb

/obj/item/organ/internal/cyberimp/brain/linked_surgery/Initialize()
	. = ..()
	if(isnull(linked_techweb))
		linked_techweb = SSresearch.science_tech

/obj/item/organ/internal/cyberimp/brain/linked_surgery/proc/on_step_completion(mob/living/user, datum/surgery_step/current_step, mob/living/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results)
	SIGNAL_HANDLER
	if(organ_flags & ORGAN_FAILING)
		return
	var/possible_steps = list()
	if(current_step.repeatable)
		possible_steps += "[current_step.name]"
	var/datum/surgery_step/next_step = surgery.get_surgery_next_step()
	if(!isnull(next_step))
		possible_steps += "[next_step.name]"
		qdel(next_step)
	if(length(possible_steps))
		target.balloon_alert(owner, "next step: [english_list(possible_steps, and_text = " or ")]")
	else
		target.balloon_alert(owner, "surgery done!")


/obj/item/organ/internal/cyberimp/brain/linked_surgery/proc/check_surgery(mob/user, datum/surgery/surgery, mob/patient)
	SIGNAL_HANDLER
	if(organ_flags & ORGAN_FAILING)
		return FALSE
	if(surgery.replaced_by in loaded_surgeries)
		return COMPONENT_CANCEL_SURGERY
	if(surgery.type in loaded_surgeries)
		return COMPONENT_FORCE_SURGERY

/obj/item/organ/internal/cyberimp/brain/linked_surgery/on_insert(mob/living/carbon/organ_owner, special)
	. = ..()
	update_surgeries(download_from_held = FALSE)
	RegisterSignal(organ_owner, COMSIG_SURGERY_STARTING, PROC_REF(check_surgery))
	RegisterSignal(organ_owner, COMSIG_MOB_SURGERY_STEP_SUCCESS, PROC_REF(on_step_completion))

/obj/item/organ/internal/cyberimp/brain/linked_surgery/on_remove(mob/living/carbon/organ_owner, special)
	. = ..()
	UnregisterSignal(organ_owner, list(COMSIG_SURGERY_STARTING, COMSIG_MOB_SURGERY_STEP_SUCCESS))

/obj/item/organ/internal/cyberimp/brain/linked_surgery/ui_action_click(mob/user, actiontype)
	if(CHECK_BITFIELD(organ_flags, ORGAN_FAILING))
		to_chat(user, span_warning("\The [src] does not respond!"))
		return
	update_surgeries()

/obj/item/organ/internal/cyberimp/brain/linked_surgery/proc/update_surgeries(download_from_held = TRUE)
	var/list/prev_amt = length(loaded_surgeries)
	for(var/design in linked_techweb.researched_designs)
		var/datum/design/surgery/surgery_design = SSresearch.techweb_design_by_id(design)
		if(!istype(surgery_design))
			continue
		loaded_surgeries |= surgery_design.surgery
	if(download_from_held)
		for(var/held_item in owner.held_items)
			if(!held_item)
				continue
			var/list/surgeries_to_add = list()
			if(istype(held_item, /obj/item/disk/surgery))
				var/obj/item/disk/surgery/surgery_disk = held_item
				for(var/surgery in surgery_disk.surgeries)
					surgeries_to_add |= surgery
			else if(istype(held_item, /obj/item/disk/tech_disk))
				var/obj/item/disk/tech_disk/tech_disk = held_item
				for(var/design in tech_disk.stored_research.researched_designs)
					var/datum/design/surgery/surgery_design = SSresearch.techweb_design_by_id(design)
					if(!istype(surgery_design))
						continue
					surgeries_to_add |= surgery_design.surgery
			else if(istype(held_item, /obj/item/disk/nuclear))
				// funny joke message
				to_chat(owner, span_warning("Do you <i>want</i> to explode? You can't get surgery data from \the [held_item]!"))
				continue
			else
				continue
			if(!length(surgeries_to_add))
				owner.balloon_alert(owner, "no new surgery data found")
				continue
			owner.balloon_alert(owner, "downloading surgery data...")
			if(!do_after(owner, 5 SECONDS, held_item))
				owner.balloon_alert(owner, "surgery download interrupted!")
				return
			loaded_surgeries |= surgeries_to_add
	var/new_amt = length(loaded_surgeries)
	var/diff = new_amt - prev_amt
	if(diff)
		owner.balloon_alert(owner, "installed [diff] new surgeries, [new_amt] total loaded")
	else
		owner.balloon_alert(owner, "no new surgery data found")

/obj/item/organ/internal/cyberimp/brain/linked_surgery/perfect
	name = "hacked surgical serverlink brain implant"
	desc = "A brain implant with a bluespace technology that lets you perform any advanced surgery through hacked Nanotrasen servers."
	organ_flags = ORGAN_SYNTHETIC | ORGAN_HIDDEN
	organ_traits = list(TRAIT_PERFECT_SURGEON)
	actions_types = null
	var/list/blocked_surgeries = list(
		/datum/surgery/advanced/brainwashing_sleeper, // this one has special handling
		/datum/surgery/advanced/necrotic_revival,
		/datum/surgery/organ_extraction
	)

// Special behavior to allow for sleeper agent surgery to be done if the traitor has the objective
/obj/item/organ/internal/cyberimp/brain/linked_surgery/perfect/check_surgery(mob/user, datum/surgery/surgery, mob/patient)
	. = ..()
	if(istype(surgery, /datum/surgery/advanced/brainwashing_sleeper))
		var/datum/antagonist/traitor/traitor_datum = user.mind?.has_antag_datum(/datum/antagonist/traitor)
		var/list/active_objectives = traitor_datum?.uplink_handler?.active_objectives
		if(!length(active_objectives))
			return
		if(locate(/datum/traitor_objective/sleeper_protocol) in active_objectives)
			return COMPONENT_FORCE_SURGERY


/obj/item/organ/internal/cyberimp/brain/linked_surgery/perfect/update_surgeries(download_from_held = TRUE)
	loaded_surgeries.Cut()
	for(var/datum/surgery/surgery as() in GLOB.surgeries_list)
		if(surgery.type in blocked_surgeries)
			continue
		if(!length(surgery.steps))
			continue
		loaded_surgeries |= surgery.type

/obj/item/organ/internal/cyberimp/brain/linked_surgery/perfect/debug
	blocked_surgeries = list()
