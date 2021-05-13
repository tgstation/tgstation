/datum/surgery/implant_removal
	name = "Implant removal"
	steps = list(
		/datum/surgery_step/incise,
		/datum/surgery_step/clamp_bleeders,
		/datum/surgery_step/retract_skin,
		/datum/surgery_step/extract_implant,
		/datum/surgery_step/close)
	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_CHEST)


//extract implant
/datum/surgery_step/extract_implant
	name = "extract implant"
	implements = list(
		TOOL_HEMOSTAT = 100,
		TOOL_CROWBAR = 65,
		/obj/item/kitchen/fork = 35)
	time = 64
	var/obj/item/implant/implant

/datum/surgery_step/extract_implant/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	for(var/obj/item/object in target.implants)
		implant = object
		break
	if(implant)
		display_results(user, target, "<span class='notice'>You begin to extract [implant] from [target]'s [target_zone]...</span>",
			"<span class='notice'>[user] begins to extract [implant] from [target]'s [target_zone].</span>",
			"<span class='notice'>[user] begins to extract something from [target]'s [target_zone].</span>")
	else
		display_results(user, target, "<span class='notice'>You look for an implant in [target]'s [target_zone]...</span>",
			"<span class='notice'>[user] looks for an implant in [target]'s [target_zone].</span>",
			"<span class='notice'>[user] looks for something in [target]'s [target_zone].</span>")

/datum/surgery_step/extract_implant/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery, default_display_results = FALSE)
	if(implant)
		display_results(user, target, "<span class='notice'>You successfully remove [implant] from [target]'s [target_zone].</span>",
			"<span class='notice'>[user] successfully removes [implant] from [target]'s [target_zone]!</span>",
			"<span class='notice'>[user] successfully removes something from [target]'s [target_zone]!</span>")
		implant.removed(target)

		var/obj/item/implantcase/case
		for(var/obj/item/implantcase/implant_case in user.held_items)
			case = implant_case
			break
		if(!case)
			case = locate(/obj/item/implantcase) in get_turf(target)
		if(case && !case.imp)
			case.imp = implant
			implant.forceMove(case)
			case.update_appearance()
			display_results(user, target, "<span class='notice'>You place [implant] into [case].</span>",
				"<span class='notice'>[user] places [implant] into [case]!</span>",
				"<span class='notice'>[user] places it into [case]!</span>")
		else
			qdel(implant)

	else
		to_chat(user, "<span class='warning'>You can't find anything in [target]'s [target_zone]!</span>")
	return ..()

/datum/surgery/implant_removal/mechanic
	name = "implant removal"
	requires_bodypart_type = BODYPART_ROBOTIC
	steps = list(
		/datum/surgery_step/mechanic_open,
		/datum/surgery_step/open_hatch,
		/datum/surgery_step/mechanic_unwrench,
		/datum/surgery_step/extract_implant,
		/datum/surgery_step/mechanic_wrench,
		/datum/surgery_step/mechanic_close)
