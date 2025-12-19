// Basic operations for moving back and forth between surgery states
/// First step of every surgery, makes an incision in the skin
/datum/surgery_operation/limb/incise_skin
	name = "make skin incision"
	// rnd_name = "Laparotomy / Craniotomy / Myotomy (Make Incision)" // Maybe we keep this one simple
	desc = "Make an incision in the patient's skin to access internal organs. \
		Causes \"cut skin\" surgical state."
	required_bodytype = ~BODYTYPE_ROBOTIC
	replaced_by = /datum/surgery_operation/limb/incise_skin/abductor
	implements = list(
		TOOL_SCALPEL = 1,
		/obj/item/melee/energy/sword = 1.33,
		/obj/item/knife = 1.5,
		/obj/item/shard = 2.25,
		/obj/item/screwdriver = 5,
		/obj/item/pen = 5,
		/obj/item = 3.33,
	)
	time = 1.6 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/scalpel2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD
	any_surgery_states_blocked = ALL_SURGERY_SKIN_STATES
	/// We can't cut mobs with this biostate
	var/biostate_blacklist = BIO_CHITIN

/datum/surgery_operation/limb/incise_skin/get_any_tool()
	return "Any sharp edged item"

/datum/surgery_operation/limb/incise_skin/get_default_radial_image()
	return image(/obj/item/scalpel)

/datum/surgery_operation/limb/incise_skin/tool_check(obj/item/tool)
	// Require edged sharpness OR a tool behavior match
	if((tool.get_sharpness() & SHARP_EDGED) || implements[tool.tool_behaviour])
		return TRUE
	// these are here by popular demand, even though they don't fit the above criteria
	if(istype(tool, /obj/item/pen) || istype(tool, /obj/item/screwdriver))
		return TRUE
	return FALSE

/datum/surgery_operation/limb/incise_skin/state_check(obj/item/bodypart/limb)
	return !(limb.biological_state & biostate_blacklist)

/datum/surgery_operation/limb/incise_skin/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to make an incision in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to make an incision in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to make an incision in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel a stabbing in your [limb.plaintext_zone].")

/datum/surgery_operation/limb/incise_skin/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..() // default success message
	limb.add_surgical_state(SURGERY_SKIN_CUT|SURGERY_VESSELS_UNCLAMPED) // ouch, cuts the vessels
	if(!limb.can_bleed())
		return

	var/blood_name = limb.owner.get_bloodtype()?.get_blood_name() || "Blood"
	display_results(
		surgeon,
		limb.owner,
		span_notice("[blood_name] pools around the incision in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[blood_name] pools around the incision in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[blood_name] pools around the incision in [limb.owner]'s [limb.plaintext_zone]."),
	)

/// Subtype for thick skinned creatures (Xenomorphs)
/datum/surgery_operation/limb/incise_skin/thick
	name = "make thick skin incision"
	implements = list(
		TOOL_SAW = 1,
		/obj/item/melee/energy/sword = 1.25,
		/obj/item/fireaxe = 1.5,
		/obj/item/knife/butcher = 2.5,
		/obj/item = 5,
	)
	biostate_blacklist = BIO_FLESH|BIO_METAL

/datum/surgery_operation/limb/incise_skin/thick/get_any_tool()
	return "Any sharp edged item with decent force"

/datum/surgery_operation/limb/incise_skin/thick/tool_check(obj/item/tool)
	return ..() && tool.force >= 10

/datum/surgery_operation/limb/incise_skin/abductor
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED | OPERATION_NO_WIKI
	required_bodytype = NONE
	biostate_blacklist = NONE // they got laser scalpels

/// Pulls the skin back to access internals
/datum/surgery_operation/limb/retract_skin
	name = "retract skin"
	desc = "Retract the patient's skin to access their internal organs. \
		Causes \"skin open\" surgical state."
	required_bodytype = ~BODYTYPE_ROBOTIC
	replaced_by = /datum/surgery_operation/limb/retract_skin/abductor
	implements = list(
		TOOL_RETRACTOR = 1,
		TOOL_SCREWDRIVER = 2.25,
		TOOL_WIRECUTTER = 2.85,
		/obj/item/stack/rods = 2.85,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/retractor1.ogg'
	success_sound = 'sound/items/handling/surgery/retractor2.ogg'
	all_surgery_states_required = SURGERY_SKIN_CUT

/datum/surgery_operation/limb/retract_skin/get_default_radial_image()
	return image(/obj/item/retractor)

/datum/surgery_operation/limb/retract_skin/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to retract the skin in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to retract the skin in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to retract the skin in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel a severe stinging pain spreading across your [limb.plaintext_zone] as the skin is pulled back.")

/datum/surgery_operation/limb/retract_skin/on_success(obj/item/bodypart/limb)
	. = ..()
	limb.add_surgical_state(SURGERY_SKIN_OPEN)
	limb.remove_surgical_state(SURGERY_SKIN_CUT)

/datum/surgery_operation/limb/retract_skin/abductor
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED  | OPERATION_NO_WIKI
	required_bodytype = NONE

/// Closes the skin
/datum/surgery_operation/limb/close_skin
	name = "mend skin incision"
	desc = "Mend the incision in the patient's skin, closing it up. \
		Clears most surgical states."
	required_bodytype = ~BODYTYPE_ROBOTIC
	replaced_by = /datum/surgery_operation/limb/close_skin/abductor
	implements = list(
		TOOL_CAUTERY = 1,
		/obj/item/stack/medical/suture = 1,
		/obj/item/gun/energy/laser = 1.15,
		TOOL_WELDER = 1.5,
		/obj/item = 3.33,
	)
	time = 2.4 SECONDS
	preop_sound = list(
		/obj/item/stack/medical/suture = SFX_SUTURE_BEGIN,
		/obj/item = 'sound/items/handling/surgery/cautery1.ogg',
	)
	success_sound = list(
		/obj/item/stack/medical/suture = SFX_SUTURE_END,
		/obj/item = 'sound/items/handling/surgery/cautery2.ogg',
	)
	any_surgery_states_required = ALL_SURGERY_SKIN_STATES

/datum/surgery_operation/limb/close_skin/get_any_tool()
	return "Any heat source"

/datum/surgery_operation/limb/close_skin/get_default_radial_image()
	return image(/obj/item/cautery)

/datum/surgery_operation/limb/close_skin/all_required_strings()
	return ..() + list("the limb must have skin")

/datum/surgery_operation/limb/close_skin/state_check(obj/item/bodypart/limb)
	return LIMB_HAS_SKIN(limb)

/datum/surgery_operation/limb/close_skin/tool_check(obj/item/tool)
	if(istype(tool, /obj/item/stack/medical/suture))
		return TRUE

	if(istype(tool, /obj/item/gun/energy/laser))
		var/obj/item/gun/energy/laser/lasergun = tool
		return lasergun.cell?.charge > 0

	return tool.get_temperature() > 0

/datum/surgery_operation/limb/close_skin/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to mend the incision in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to mend the incision in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to mend the incision in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "Your [limb.plaintext_zone] is being [istype(tool, /obj/item/stack/medical/suture) ? "pinched" : "burned"]!")

/datum/surgery_operation/limb/close_skin/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	if(LIMB_HAS_SURGERY_STATE(limb, SURGERY_BONE_SAWED))
		limb.heal_damage(40)
	limb.remove_surgical_state(ALL_SURGERY_STATES_UNSET_ON_CLOSE)

/datum/surgery_operation/limb/close_skin/abductor
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED  | OPERATION_NO_WIKI
	required_bodytype = NONE

/// Clamps bleeding blood vessels to prevent blood loss
/datum/surgery_operation/limb/clamp_bleeders
	name = "clamp bleeders"
	desc = "Clamp bleeding blood vessels in the patient's body to prevent blood loss. \
		Causes \"vessels clamped\" surgical state."
	required_bodytype = ~BODYTYPE_ROBOTIC
	operation_flags = OPERATION_PRIORITY_NEXT_STEP
	replaced_by = /datum/surgery_operation/limb/clamp_bleeders/abductor
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_WIRECUTTER = 1.67,
		/obj/item/stack/package_wrap = 2.85,
		/obj/item/stack/cable_coil = 6.67,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_VESSELS_UNCLAMPED

/datum/surgery_operation/limb/clamp_bleeders/get_default_radial_image()
	return image(/obj/item/hemostat)

/datum/surgery_operation/limb/clamp_bleeders/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to clamp bleeders in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to clamp bleeders in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to clamp bleeders in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel a pinch as the bleeding in your [limb.plaintext_zone] is slowed.")

/datum/surgery_operation/limb/clamp_bleeders/on_success(obj/item/bodypart/limb)
	. = ..()
	// free brute healing if you do it after sawing bones
	if(LIMB_HAS_SURGERY_STATE(limb, SURGERY_BONE_SAWED))
		limb.heal_damage(20)
	limb.add_surgical_state(SURGERY_VESSELS_CLAMPED)
	limb.remove_surgical_state(SURGERY_VESSELS_UNCLAMPED)

/datum/surgery_operation/limb/clamp_bleeders/abductor
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED  | OPERATION_NO_WIKI
	required_bodytype = NONE

/// Unclamps blood vessels to allow blood flow again
/datum/surgery_operation/limb/unclamp_bleeders
	name = "unclamp bleeders"
	desc = "Unclamp blood vessels in the patient's body to allow blood flow again. \
		Clears \"vessels clamped\" surgical state."
	required_bodytype = ~BODYTYPE_ROBOTIC
	replaced_by = /datum/surgery_operation/limb/unclamp_bleeders/abductor
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_WIRECUTTER = 1.67,
		/obj/item/stack/package_wrap = 2.85,
		/obj/item/stack/cable_coil = 6.67,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN|SURGERY_VESSELS_CLAMPED

/datum/surgery_operation/limb/unclamp_bleeders/get_default_radial_image()
	return image(/obj/item/hemostat)

/datum/surgery_operation/limb/unclamp_bleeders/all_required_strings()
	return ..() + list("the limb must have blood vessels")

/datum/surgery_operation/limb/unclamp_bleeders/state_check(obj/item/bodypart/limb)
	return LIMB_HAS_VESSELS(limb)

/datum/surgery_operation/limb/unclamp_bleeders/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to unclamp bleeders in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to unclamp bleeders in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to unclamp bleeders in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel a pressure release as blood starts flowing in your [limb.plaintext_zone] again.")

/datum/surgery_operation/limb/unclamp_bleeders/on_success(obj/item/bodypart/limb)
	. = ..()
	limb.add_surgical_state(SURGERY_VESSELS_UNCLAMPED)
	limb.remove_surgical_state(SURGERY_VESSELS_CLAMPED)

/datum/surgery_operation/limb/unclamp_bleeders/abductor
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED  | OPERATION_NO_WIKI
	required_bodytype = NONE

/// Saws through bones to access organs
/datum/surgery_operation/limb/saw_bones
	name = "saw limb bone"
	desc = "Saw through the patient's bones to access their internal organs. \
		Causes \"bone sawed\" surgical state."
	required_bodytype = ~BODYTYPE_ROBOTIC
	implements = list(
		TOOL_SAW = 1,
		/obj/item/shovel/serrated = 1.33,
		/obj/item/melee/arm_blade = 1.33,
		/obj/item/fireaxe = 2,
		/obj/item/hatchet = 2.85,
		/obj/item/knife/butcher = 2.85,
		/obj/item = 4,
	)
	time = 5.4 SECONDS
	preop_sound = list(
		/obj/item/circular_saw = 'sound/items/handling/surgery/saw.ogg',
		/obj/item/melee/arm_blade = 'sound/items/handling/surgery/scalpel1.ogg',
		/obj/item/fireaxe = 'sound/items/handling/surgery/scalpel1.ogg',
		/obj/item/hatchet = 'sound/items/handling/surgery/scalpel1.ogg',
		/obj/item/knife/butcher = 'sound/items/handling/surgery/scalpel1.ogg',
		/obj/item = 'sound/items/handling/surgery/scalpel1.ogg',
	)
	success_sound = 'sound/items/handling/surgery/organ2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED

/datum/surgery_operation/limb/saw_bones/get_any_tool()
	return "Any sharp edged item with decent force"

/datum/surgery_operation/limb/saw_bones/get_default_radial_image()
	return image(/obj/item/circular_saw)

/datum/surgery_operation/limb/saw_bones/tool_check(obj/item/tool)
	// Require edged sharpness and sufficient force OR a tool behavior match
	return (((tool.get_sharpness() & SHARP_EDGED) && tool.force >= 10) || implements[tool.tool_behaviour])

/datum/surgery_operation/limb/saw_bones/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to saw through the bone in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to saw through the bone in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to saw through the bone in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel a horrid ache spread through the inside of your [limb.plaintext_zone]!")

/datum/surgery_operation/limb/saw_bones/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.add_surgical_state(SURGERY_BONE_SAWED)
	limb.receive_damage(50, sharpness = tool.get_sharpness(), wound_bonus = CANT_WOUND, damage_source = tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You saw [limb.owner]'s [limb.plaintext_zone] open."),
		span_notice("[surgeon] saws [limb.owner]'s [limb.plaintext_zone] open!"),
		span_notice("[surgeon] saws [limb.owner]'s [limb.plaintext_zone] open!"),
	)
	display_pain(limb.owner, "It feels like something just broke in your [limb.plaintext_zone]!")

/// Fixes sawed bones back together
/datum/surgery_operation/limb/fix_bones
	name = "fix limb bone"
	desc = "Repair a patient's cut or broken bones. \
		Clears \"bone sawed\" and \"bone drilled\" surgical states."
	required_bodytype = ~BODYTYPE_ROBOTIC
	implements = list(
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/sticky_tape/surgical = 1,
		/obj/item/stack/sticky_tape/super = 2,
		/obj/item/stack/sticky_tape = 3.33,
	)
	preop_sound = list(
		/obj/item/stack/medical/bone_gel = 'sound/misc/soggy.ogg',
		/obj/item/stack/sticky_tape/surgical = 'sound/items/duct_tape/duct_tape_rip.ogg',
		/obj/item/stack/sticky_tape/super = 'sound/items/duct_tape/duct_tape_rip.ogg',
		/obj/item/stack/sticky_tape = 'sound/items/duct_tape/duct_tape_rip.ogg',
	)
	time = 4 SECONDS
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_required = SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED

/datum/surgery_operation/limb/fix_bones/get_default_radial_image()
	return image(/obj/item/stack/medical/bone_gel)

/datum/surgery_operation/limb/fix_bones/all_required_strings()
	return ..() + list("the limb must have bones")

/datum/surgery_operation/limb/fix_bones/state_check(obj/item/bodypart/limb)
	return LIMB_HAS_BONES(limb)

/datum/surgery_operation/limb/fix_bones/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to fix the bones in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to fix the bones in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to fix the bones in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel a grinding sensation in your [limb.plaintext_zone] as the bones are set back in place.")

/datum/surgery_operation/limb/fix_bones/on_success(obj/item/bodypart/limb)
	. = ..()
	limb.remove_surgical_state(SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED)
	limb.heal_damage(40)

/datum/surgery_operation/limb/drill_bones
	name = "drill limb bone"
	desc = "Drill through a patient's bones. \
		Causes \"bone drilled\" surgical state."
	required_bodytype = ~BODYTYPE_ROBOTIC
	implements = list(
		TOOL_DRILL = 1,
		/obj/item/screwdriver/power = 1.25,
		/obj/item/pickaxe/drill = 1.67,
		TOOL_SCREWDRIVER = 4,
		/obj/item/kitchen/spoon = 5,
		/obj/item = 6.67,
	)
	time = 3 SECONDS
	preop_sound = 'sound/items/handling/surgery/saw.ogg'
	success_sound = 'sound/items/handling/surgery/organ2.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_BONE_SAWED|SURGERY_BONE_DRILLED

/datum/surgery_operation/limb/drill_bones/get_any_tool()
	return "Any sharp pointed item with decent force"

/datum/surgery_operation/limb/drill_bones/get_default_radial_image()
	return image(/obj/item/surgicaldrill)

/datum/surgery_operation/limb/drill_bones/tool_check(obj/item/tool)
	// Require pointy sharpness and sufficient force OR a tool behavior match
	return (((tool.get_sharpness() & SHARP_POINTY) && tool.force >= 10) || implements[tool.tool_behaviour])

/datum/surgery_operation/limb/drill_bones/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to drill into the bone in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to drill into the bone in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to drill into the bone in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel a horrible piercing pain in your [limb.plaintext_zone]!")

/datum/surgery_operation/limb/drill_bones/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.add_surgical_state(SURGERY_BONE_DRILLED)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You drill into [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] drills into [limb.owner]'s [limb.plaintext_zone]!"),
		span_notice("[surgeon] drills into [limb.owner]'s [limb.plaintext_zone]!"),
	)

/datum/surgery_operation/limb/incise_organs
	name = "incise organs"
	desc = "Make an incision in patient's internal organ tissue to allow for manipulation or repair. \
		Causes \"organs cut\" surgical state."
	required_bodytype = ~BODYTYPE_ROBOTIC
	replaced_by = /datum/surgery_operation/limb/incise_organs/abductor
	implements = list(
		TOOL_SCALPEL = 1,
		/obj/item/melee/energy/sword = 1.33,
		/obj/item/knife = 1.5,
		/obj/item/shard = 2.25,
		/obj/item/pen = 5,
		/obj/item = 3.33,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/organ1.ogg'
	all_surgery_states_required = SURGERY_SKIN_OPEN
	any_surgery_states_blocked = SURGERY_ORGANS_CUT

/datum/surgery_operation/limb/incise_organs/get_any_tool()
	return "Any sharp edged item"

/datum/surgery_operation/limb/incise_organs/get_default_radial_image()
	return image(/obj/item/scalpel)

/datum/surgery_operation/limb/incise_organs/tool_check(obj/item/tool)
	// Require edged sharpness OR a tool behavior match. Also saws are a no-go, you'll rip up the organs!
	return ((tool.get_sharpness() & SHARP_EDGED) || implements[tool.tool_behaviour]) && tool.tool_behaviour != TOOL_SAW

/datum/surgery_operation/limb/incise_organs/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to make an incision in the organs within [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to make an incision in the organs within [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to make an incision in the organs within [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel a stabbing in your [limb.plaintext_zone].")

/datum/surgery_operation/limb/incise_organs/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.add_surgical_state(SURGERY_ORGANS_CUT)
	limb.receive_damage(10, sharpness = tool.get_sharpness(), wound_bonus = CANT_WOUND, damage_source = tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You make an incision in the organs within [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] makes an incision in the organs within [limb.owner]'s [limb.plaintext_zone]!"),
		span_notice("[surgeon] makes an incision in the organs within [limb.owner]'s [limb.plaintext_zone]!"),
	)
	display_pain(limb.owner, "You feel a sharp pain from inside your [limb.plaintext_zone]!")

/datum/surgery_operation/limb/incise_organs/abductor
	operation_flags = parent_type::operation_flags | OPERATION_IGNORE_CLOTHES | OPERATION_LOCKED  | OPERATION_NO_WIKI
	required_bodytype = NONE

/datum/surgery_operation/limb/incise_organs/abductor/state_check(obj/item/bodypart/limb)
	return TRUE // You can incise chests without sawing ribs
