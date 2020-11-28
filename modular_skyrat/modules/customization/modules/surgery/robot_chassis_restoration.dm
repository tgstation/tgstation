/datum/surgery/robot_chassis_restoration
	name = "Full chassis restoration (Full heal + revival)"
	steps = list(
	/datum/surgery_step/mechanic_unwrench,
	/datum/surgery_step/pry_off_plating/fullbody,
	/datum/surgery_step/cut_wires/fullbody,
	/datum/surgery_step/replace_wires/fullbody,
	/datum/surgery_step/prepare_electronics,
	/datum/surgery_step/add_plating/fullbody,
	/datum/surgery_step/weld_plating/fullbody,
	/datum/surgery_step/finalize_chassis_restoration)

	target_mobtypes = list(/mob/living/carbon/human)
	possible_locs = list(BODY_ZONE_CHEST)
	requires_bodypart_type = BODYPART_ROBOTIC
	desc = "A surgical procedure that rebuilds a synthetic unit from their skeleton to full integrity, recommended if they are damaged far beyond repair."

/datum/surgery_step/pry_off_plating/fullbody
	time = 120

/datum/surgery_step/pry_off_plating/fullbody/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to pry off [target]'s plating...</span>",
			"[user] begins to pry off [target]'s plating.",
			"[user] begins to pry off [target]'s plating.")

/datum/surgery_step/cut_wires/fullbody
	time = 120

/datum/surgery_step/cut_wires/fullbody/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to cut [target]'s loose wires...</span>",
			"[user] begins to cut [target]'s loose wires.",
			"[user] begins to cut [target]'s loose wires.")

/datum/surgery_step/weld_plating/fullbody
	time = 120

/datum/surgery_step/weld_plating/fullbody/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to weld [target]'s plating...</span>",
			"[user] begins to weld [target]'s plating.",
			"[user] begins to weld [target]'s plating.")

/datum/surgery_step/replace_wires/fullbody
	time = 72
	cableamount = 15

/datum/surgery_step/replace_wires/fullbody/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to replace [target]'s wiring...</span>",
			"[user] begins to replace [target]'s wiring.",
			"[user] begins to replace [target]'s wiring.")

/datum/surgery_step/add_plating/fullbody
	time = 120
	metalamount = 15

/datum/surgery_step/add_plating/fullbody/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to add plating to [target]...</span>",
			"[user] begins to add plating to [target].",
			"[user] begins to add plating to [target].")

/datum/surgery_step/finalize_chassis_restoration
	name = "finalize chassis restoration (wrench)"
	implements = list(
		TOOL_WRENCH = 100)
	time = 120

/datum/surgery_step/finalize_chassis_restoration/preop(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	display_results(user, target, "<span class='notice'>You begin to finalize [target]'s chassis...</span>",
			"[user] begins to finalize [target]'s chassis.",
			"[user] begins to finalize [target]'s chassis.")

/datum/surgery_step/finalize_chassis_restoration/success(mob/user, mob/living/carbon/target, target_zone, obj/item/tool, datum/surgery/surgery)
	target.cure_husk()
	//Revival is handled by REVIVES_BY_HEALING
	target.heal_overall_damage(1000,1000,0, BODYPART_ROBOTIC)
	//I call this twice because for some reason health may not update and we may not get a revival, and I cant find a good clean solution to this
	target.heal_overall_damage(1,1,0, BODYPART_ROBOTIC)
	return TRUE
