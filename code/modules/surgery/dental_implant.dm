/datum/surgery/dental_implant
	name = "Dental implant"
	steps = list(/datum/surgery_step/drill, /datum/surgery_step/insert_object)
	possible_locs = list(BODY_ZONE_PRECISE_MOUTH)

/datum/surgery_step/insert_object
	name = "insert pill or signaling device"
	implements = list(/obj/item/reagent_containers/pill = 100, /obj/item/assembly/signaler = 100)
	time = 16

/datum/surgery_step/insert_object/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to wedge [tool] in [target]'s [parse_zone(target_zone)]...</span>",
			"<span class='notice'>[user] begins to wedge \the [tool] in [target]'s [parse_zone(target_zone)].</span>",
			"<span class='notice'>[user] begins to wedge something in [target]'s [parse_zone(target_zone)].</span>")

/datum/surgery_step/insert_object/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(!istype(tool))
		return 0

	user.transferItemToLoc(tool, target, TRUE)

	if(istype(tool,/obj/item/reagent_containers/pill))
		var/datum/action/item_action/hands_free/activate_pill/P = new(tool)
		P.button.name = "Activate [tool.name]"
		P.target = tool
		P.Grant(target)	//The pill never actually goes in an inventory slot, so the owner doesn't inherit actions from it

	else if(tool.type == /obj/item/assembly/signaler)
		var/datum/action/item_action/hands_free/activate_signaler/S = new(tool)
		S.button.name = "Activate [tool.name]"
		S.target = tool
		S.Grant(target)

	display_results(user, target, "<span class='notice'>You wedge [tool] into [target]'s [parse_zone(target_zone)].</span>",
			"<span class='notice'>[user] wedges the [tool] into [target]'s [parse_zone(target_zone)]!</span>",
			"<span class='notice'>[user] wedges something into [target]'s [parse_zone(target_zone)]!</span>")
	return ..()

/datum/action/item_action/hands_free/activate_pill
	name = "Activate Pill"

/datum/action/item_action/hands_free/activate_pill/Trigger()
	if(!..())
		return FALSE
	to_chat(owner, "<span class='notice'>You grit your teeth and burst the implanted [target.name]!</span>")
	log_combat(owner, null, "swallowed an implanted pill", target)
	if(target.reagents.total_volume)
		target.reagents.trans_to(owner, target.reagents.total_volume, transfered_by = owner, method = INGEST)
	qdel(target)
	return TRUE

/datum/action/item_action/hands_free/activate_signaler
	name = "Activate Signaling Device"

/datum/action/item_action/hands_free/activate_signaler/Trigger()
	var/mob/living/carbon/C = owner
	if(!..())
		return FALSE
	var/obj/item/assembly/signaler/sig = target
	if(C.InCritical()) // Presently not needed, since apparently you can't activate pill implants while in crit, but futureproofing
		to_chat(owner, "<span class='notice'>You slide your jaw weakly...</span>")
		return FALSE
	to_chat(owner, "<span class='notice'>You slide your jaw and hear a dull click.</span>")
	log_combat(owner, null, "activated an implanted signaling device [format_frequency(sig.frequency)]", target)
	if(sig && sig.next_activate <= world.time)
		sig.pulsed()
	return TRUE
