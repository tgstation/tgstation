// Basic operations for moving back and forth between surgery states

/// First step of every surgery, makes an incision in the skin
/datum/surgery_operation/limb/incise_skin
	name = "make incision"
	desc = "Make an incision in the patient's skin to access internal organs."
	required_bodytype = BODYTYPE_ORGANIC
	implements = list(
		TOOL_SCALPEL = 1,
		/obj/item/melee/energy/sword = 0.75,
		/obj/item/knife = 0.65,
		/obj/item/shard = 0.45,
		/obj/item = 0.3,
	)
	time = 1.6 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/scalpel2.ogg'
	operation_flags = OPERATION_AFFECTS_MOOD

/datum/surgery_operation/limb/incise_skin/get_default_radial_image(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool)
	var/image/base = ..()
	base.overlays += add_radial_overlays(/obj/item/scalpel)
	return base

/datum/surgery_operation/limb/incise_skin/tool_check(obj/item/tool)
	// Require sharpness OR a tool behavior match
	return (tool.get_sharpness() || implements[tool.tool_behaviour])

/datum/surgery_operation/limb/incise_skin/state_check(obj/item/bodypart/limb)
	if(limb.surgery_skin_state != SURGERY_SKIN_CLOSED)
		return FALSE
	return TRUE

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
	. = ..()
	limb.surgery_skin_state = SURGERY_SKIN_CUT
	limb.surgery_vessel_state = SURGERY_VESSELS_UNCLAMPED // ouch, cuts the vessels
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
	limb.adjustBleedStacks(10)

/// Pulls the skin back to access internals
/datum/surgery_operation/limb/retract_skin
	name = "retract skin"
	desc = "Retract the patient's skin to access their internal organs."
	required_bodytype = BODYTYPE_ORGANIC
	implements = list(
		TOOL_RETRACTOR = 1,
		TOOL_SCREWDRIVER = 0.45,
		TOOL_WIRECUTTER = 0.35,
		/obj/item/stack/rods = 0.35,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/retractor1.ogg'
	success_sound = 'sound/items/handling/surgery/retractor2.ogg'

/datum/surgery_operation/limb/retract_skin/get_default_radial_image(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool)
	var/image/base = ..()
	base.overlays += add_radial_overlays(/obj/item/retractor)
	return base

/datum/surgery_operation/limb/retract_skin/state_check(obj/item/bodypart/limb)
	if(limb.surgery_skin_state != SURGERY_SKIN_CUT)
		return FALSE
	return TRUE

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
	limb.surgery_skin_state = SURGERY_SKIN_OPEN

/// Closes the skin
/datum/surgery_operation/limb/close_skin
	name = "mend incision"
	desc = "Mend the incision in the patient's skin, closing it up."
	required_bodytype = BODYTYPE_ORGANIC
	implements = list(
		TOOL_CAUTERY = 1,
		/obj/item/gun/energy/laser = 0.9,
		TOOL_WELDER = 0.7,
		/obj/item = 0.3,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/cautery1.ogg'
	success_sound = 'sound/items/handling/surgery/cautery2.ogg'

/datum/surgery_operation/limb/close_skin/get_default_radial_image(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool)
	var/image/base = ..()
	base.overlays += add_radial_overlays(/obj/item/cautery)
	return base

/datum/surgery_operation/limb/close_skin/state_check(obj/item/bodypart/limb)
	if(limb.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/close_skin/tool_check(obj/item/tool)
	if(istype(tool, /obj/item/gun/energy/laser))
		var/obj/item/gun/energy/laser/lasergun = tool
		return lasergun.cell?.charge > 0

	// Require heat OR a tool behavior match
	return tool.get_temperature() > 0 || implements[tool.tool_behaviour]

/datum/surgery_operation/limb/close_skin/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to mend the incision in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to mend the incision in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to mend the incision in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "Your [limb.plaintext_zone] is being burned!")

/datum/surgery_operation/limb/close_skin/on_success(obj/item/bodypart/limb)
	. = ..()
	limb.surgery_skin_state = SURGERY_SKIN_CLOSED // Going from open to closed directly for simplicity
	limb.surgery_vessel_state = SURGERY_VESSELS_NORMAL // Blood vessels as well, all handled in one step
	// melbert todo : mend used to heal 45 brute for saw surgeries
	limb.adjustBleedStacks(-3)

/// Clamps bleeding blood vessels to prevent blood loss
/datum/surgery_operation/limb/clamp_bleeders
	name = "clamp bleeders"
	desc = "Clamp bleeding blood vessels in the patient's body to prevent blood loss."
	required_bodytype = BODYTYPE_ORGANIC
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_WIRECUTTER = 0.6,
		/obj/item/stack/package_wrap = 0.35,
		/obj/item/stack/cable_coil = 0.15,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'

/datum/surgery_operation/limb/clamp_bleeders/get_default_radial_image(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool)
	var/image/base = ..()
	base.overlays += add_radial_overlays(/obj/item/hemostat)
	return base

/datum/surgery_operation/limb/clamp_bleeders/state_check(obj/item/bodypart/limb)
	if(limb.surgery_vessel_state != SURGERY_VESSELS_UNCLAMPED)
		return FALSE
	return TRUE

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
	limb.surgery_vessel_state = SURGERY_VESSELS_CLAMPED
	// free brute healing if you do it after sawing bones
	if(limb.surgery_bone_state == SURGERY_BONE_SAWED)
		limb.heal_damage(20)
	// of course, this is what you came here for
	limb.adjustBleedStacks(-3)

/// Unclamps blood vessels to allow blood flow again
/datum/surgery_operation/limb/unclamp_bleeders
	name = "unclamp bleeders"
	desc = "Unclamp blood vessels in the patient's body to allow blood flow again."
	required_bodytype = BODYTYPE_ORGANIC
	implements = list(
		TOOL_HEMOSTAT = 1,
		TOOL_WIRECUTTER = 0.6,
		/obj/item/stack/package_wrap = 0.35,
		/obj/item/stack/cable_coil = 0.15,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/hemostat1.ogg'

/datum/surgery_operation/limb/unclamp_bleeders/get_default_radial_image(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool)
	var/image/base = ..()
	base.overlays += add_radial_overlays(/obj/item/hemostat)
	return base

/datum/surgery_operation/limb/unclamp_bleeders/state_check(obj/item/bodypart/limb)
	if(limb.surgery_vessel_state != SURGERY_VESSELS_CLAMPED)
		return FALSE
	return TRUE

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
	limb.surgery_vessel_state = SURGERY_VESSELS_UNCLAMPED

/// Saws through bones to access organs
/datum/surgery_operation/limb/saw_bones
	name = "saw bone"
	desc = "Saw through the patient's bones to access their internal organs."
	required_bodytype = BODYTYPE_ORGANIC
	implements = list(
		TOOL_SAW = 1,
		/obj/item/shovel/serrated = 0.75,
		/obj/item/melee/arm_blade = 0.75,
		/obj/item/fireaxe = 0.5,
		/obj/item/hatchet = 0.35,
		/obj/item/knife/butcher = 0.35,
		/obj/item = 0.25,
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

/datum/surgery_operation/limb/saw_bones/get_default_radial_image(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool)
	var/image/base = ..()
	base.overlays += add_radial_overlays(/obj/item/circular_saw)
	return base

/datum/surgery_operation/limb/saw_bones/state_check(obj/item/bodypart/limb)
	if(limb.surgery_bone_state != SURGERY_BONE_INTACT)
		return FALSE
	if(limb.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/saw_bones/tool_check(obj/item/tool)
	// Require sharpness and sufficient force OR a tool behavior match
	return ((tool.get_sharpness() && tool.force >= 10) || implements[tool.tool_behaviour])

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
	// melbert todo : check for bio state
	limb.surgery_bone_state = SURGERY_BONE_SAWED
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
	name = "fix bone"
	desc = "Repair a patient's cut or broken bones."
	required_bodytype = BODYTYPE_ORGANIC
	implements = list(
		/obj/item/stack/medical/bone_gel = 1,
		/obj/item/stack/sticky_tape/surgical = 1,
		/obj/item/stack/sticky_tape/super = 0.5,
		/obj/item/stack/sticky_tape = 0.3,
	)
	preop_sound = list(
		/obj/item/stack/medical/bone_gel = 'sound/misc/soggy.ogg',
		/obj/item/stack/sticky_tape/surgical = 'sound/items/duct_tape/duct_tape_rip.ogg',
		/obj/item/stack/sticky_tape/super = 'sound/items/duct_tape/duct_tape_rip.ogg',
		/obj/item/stack/sticky_tape = 'sound/items/duct_tape/duct_tape_rip.ogg',
	)
	time = 4 SECONDS

/datum/surgery_operation/limb/fix_bones/get_default_radial_image(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool)
	var/image/base = ..()
	base.overlays += add_radial_overlays(/obj/item/stack)
	return base

/datum/surgery_operation/limb/fix_bones/state_check(obj/item/bodypart/limb)
	if(limb.surgery_bone_state == SURGERY_BONE_INTACT)
		return FALSE
	if(limb.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/fix_bones/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to fix the bones in [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to fix the bones in [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to fix the bones in [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel a grinding sensation in your [limb.plaintext_zone] as the bones is being set back in place.")

/datum/surgery_operation/limb/fix_bones/on_success(obj/item/bodypart/limb)
	. = ..()
	limb.surgery_bone_state = SURGERY_BONE_INTACT
	limb.heal_damage(40)

/datum/surgery_operation/limb/drill_bones
	name = "drill bone"
	desc = "Drill through a patient's bones."
	required_bodytype = BODYTYPE_ORGANIC
	implements = list(
		TOOL_DRILL = 1,
		/obj/item/screwdriver/power = 0.8,
		/obj/item/pickaxe/drill = 0.6,
		TOOL_SCREWDRIVER = 0.25,
		/obj/item/kitchen/spoon = 0.2,
	)
	time = 3 SECONDS
	preop_sound = 'sound/items/handling/surgery/saw.ogg'
	success_sound = 'sound/items/handling/surgery/organ2.ogg'

/datum/surgery_operation/limb/drill_bones/get_default_radial_image(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool)
	var/image/base = ..()
	base.overlays += add_radial_overlays(/obj/item/surgicaldrill)
	return base

/datum/surgery_operation/limb/drill_bones/state_check(obj/item/bodypart/limb)
	if(limb.surgery_bone_state != SURGERY_BONE_INTACT)
		return FALSE
	if(limb.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	return TRUE

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
	limb.surgery_bone_state = SURGERY_BONE_DRILLED
	display_results(
		surgeon,
		limb.owner,
		span_notice("You drill into [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] drills into [limb.owner]'s [limb.plaintext_zone]!"),
		span_notice("[surgeon] drills into [limb.owner]'s [limb.plaintext_zone]!"),
	)

/datum/surgery_operation/limb/incise_organs
	name = "incise organs"
	desc = "Make an incision in patient's internal organ tissue to allow for manipulation or repair."
	required_bodytype = BODYTYPE_ORGANIC
	implements = list(
		TOOL_SCALPEL = 1,
		/obj/item/melee/energy/sword = 0.75,
		/obj/item/knife = 0.65,
		/obj/item/shard = 0.45,
		/obj/item = 0.3,
	)
	time = 2.4 SECONDS
	preop_sound = 'sound/items/handling/surgery/scalpel1.ogg'
	success_sound = 'sound/items/handling/surgery/organ1.ogg'

/datum/surgery_operation/limb/incise_organs/get_default_radial_image(obj/item/bodypart/chest/limb, mob/living/surgeon, obj/item/tool)
	var/image/base = ..()
	base.overlays += add_radial_overlays(/obj/item/scalpel)
	return base

/datum/surgery_operation/limb/incise_organs/state_check(obj/item/bodypart/limb)
	if(limb.surgery_skin_state < SURGERY_SKIN_OPEN)
		return FALSE
	if(limb.surgery_vessel_state != SURGERY_VESSELS_CLAMPED)
		return FALSE
	if(limb.surgery_bone_state < SURGERY_BONE_SAWED)
		return FALSE
	return TRUE

/datum/surgery_operation/limb/incise_organs/tool_check(obj/item/tool)
	// Require sharpness OR a tool behavior match
	return (tool.get_sharpness() || implements[tool.tool_behaviour])

/datum/surgery_operation/limb/incise_organs/on_preop(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You begin to make an incision in the organs of [limb.owner]'s [limb.plaintext_zone]..."),
		span_notice("[surgeon] begins to make an incision in the organs of [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] begins to make an incision in the organs of [limb.owner]'s [limb.plaintext_zone]."),
	)
	display_pain(limb.owner, "You feel a stabbing in your [limb.plaintext_zone].")

/datum/surgery_operation/limb/incise_organs/on_success(obj/item/bodypart/limb, mob/living/surgeon, obj/item/tool, list/operation_args)
	. = ..()
	limb.surgery_vessel_state = SURGERY_VESSELS_ORGANS_CUT
	limb.adjustBleedStacks(10)
	limb.receive_damage(10, sharpness = tool.get_sharpness(), wound_bonus = CANT_WOUND, damage_source = tool)
	display_results(
		surgeon,
		limb.owner,
		span_notice("You make an incision in the organs of [limb.owner]'s [limb.plaintext_zone]."),
		span_notice("[surgeon] makes an incision in the organs of [limb.owner]'s [limb.plaintext_zone]!"),
		span_notice("[surgeon] makes an incision in the organs of [limb.owner]'s [limb.plaintext_zone]!"),
	)
	display_pain(limb.owner, "You feel a sharp pain from inside your [limb.plaintext_zone]!")
