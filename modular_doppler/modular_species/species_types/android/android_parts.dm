// easy define for head_flags of android heads that dont feature eyes (aka monitor heads (aka IPCs))
#define HEAD_MONITOR_FACE (HEAD_HAIR|HEAD_LIPS|HEAD_DEBRAIN)
// easy define for the android bodypart .dmi
#define ANDROID_BODYPARTS_DMI 'modular_doppler/modular_species/species_types/android/icons/android_parts.dmi'

/obj/item/bodypart/proc/change_type(mob/living/user, obj/item/tool)
	if(brute_dam || burn_dam)
		user.balloon_alert(user, "limb damaged!")
		return NONE

	var/list/possible_appearances = list()
	for(var/types in GLOB.frame_types)
		if(types == "none")
			continue
		LAZYADDASSOC(possible_appearances, types, image(icon = ANDROID_BODYPARTS_DMI, icon_state = "[types]_[body_zone]"))
	//pick
	var/new_type = show_radial_menu(user, src, possible_appearances, require_near = TRUE, radius = 48)
	if(!new_type)
		return NONE
	//weld
	if(tool.use_tool(src, user, delay = 2 SECONDS, volume = 20))
		var/type_to_spawn = text2path("[type]/[new_type]")
		if(!type_to_spawn)
			type_to_spawn = text2path("[parent_type]/[new_type]")
		var/obj/item/bodypart/new_bodypart = new type_to_spawn(loc)
	//inherit detail
		for(var/obj/item/organ/to_transfer in contents)
			to_transfer.bodypart_insert(new_bodypart)
		new_bodypart.name = name
		new_bodypart.desc = desc
		qdel(src)
		return ITEM_INTERACT_SUCCESS

///
// Overwrites
///
/obj/item/bodypart/head/robot/android
	biological_state = (BIO_ROBOTIC|BIO_BLOODED)
	brute_modifier = 1
	burn_modifier = 1

/obj/item/bodypart/head/robot/android/welder_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	return change_type(user, tool)

/obj/item/bodypart/head/robot/android/examine(mob/user)
	. = ..()
	. += span_blue("<b>Right-click</b> with a welding-tool to alter the limb appearance.")

/obj/item/bodypart/chest/robot/android
	biological_state = (BIO_ROBOTIC|BIO_BLOODED)
	brute_modifier = 1
	burn_modifier = 1

/obj/item/bodypart/chest/robot/android/welder_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	return change_type(user, tool)

/obj/item/bodypart/chest/robot/android/examine(mob/user)
	. = ..()
	. += span_blue("<b>Right-click</b> with a welding-tool to alter the limb appearance.")

/obj/item/bodypart/chest/robot/android/check_limbs()
	return

/obj/item/bodypart/arm/right/robot/android
	biological_state = (BIO_ROBOTIC|BIO_BLOODED)
	brute_modifier = 1
	burn_modifier = 1

/obj/item/bodypart/arm/right/robot/android/welder_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	return change_type(user, tool)

/obj/item/bodypart/arm/right/robot/android/examine(mob/user)
	. = ..()
	. += span_blue("<b>Right-click</b> with a welding-tool to alter the limb appearance.")


/obj/item/bodypart/arm/left/robot/android
	biological_state = (BIO_ROBOTIC|BIO_BLOODED)
	brute_modifier = 1
	burn_modifier = 1

/obj/item/bodypart/arm/left/robot/android/welder_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	return change_type(user, tool)

/obj/item/bodypart/arm/left/robot/android/examine(mob/user)
	. = ..()
	. += span_blue("<b>Right-click</b> with a welding-tool to alter the limb appearance.")

/obj/item/bodypart/leg/right/robot/android
	biological_state = (BIO_ROBOTIC|BIO_BLOODED)
	brute_modifier = 1
	burn_modifier = 1

/obj/item/bodypart/leg/right/robot/android/welder_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	return change_type(user, tool)

/obj/item/bodypart/leg/right/robot/android/examine(mob/user)
	. = ..()
	. += span_blue("<b>Right-click</b> with a welding-tool to alter the limb appearance.")

/obj/item/bodypart/leg/left/robot/android
	biological_state = (BIO_ROBOTIC|BIO_BLOODED)
	brute_modifier = 1
	burn_modifier = 1

/obj/item/bodypart/leg/left/robot/android/welder_act_secondary(mob/living/user, obj/item/tool)
	. = ..()
	return change_type(user, tool)

/obj/item/bodypart/leg/left/robot/android/examine(mob/user)
	. = ..()
	. += span_blue("<b>Right-click</b> with a welding-tool to alter the limb appearance.")

///
// Classic
///
/obj/item/bodypart/head/robot/android/classic
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "classic_head"
	limb_id = "classic"

/obj/item/bodypart/chest/robot/android/classic
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "classic_chest"
	limb_id = "classic"

/obj/item/bodypart/arm/right/robot/android/classic
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "classic_r_arm"
	limb_id = "classic"

/obj/item/bodypart/arm/left/robot/android/classic
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "classic_l_arm"
	limb_id = "classic"

/obj/item/bodypart/leg/right/robot/android/classic
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "classic_r_leg"
	limb_id = "classic"

/obj/item/bodypart/leg/left/robot/android/classic
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "classic_l_leg"
	limb_id = "classic"

///
// Bare
///
/obj/item/bodypart/head/robot/android/bare
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bare_head"
	limb_id = "bare"
	head_flags = HEAD_MONITOR_FACE

/obj/item/bodypart/head/robot/android/bare/on_adding(mob/living/carbon/new_owner)
	. = ..()
	new_owner.AddComponent(/datum/component/monitor_head)

/obj/item/bodypart/head/robot/android/bare/on_removal(mob/living/carbon/old_owner)
	. = ..()
	qdel(old_owner.GetComponent(/datum/component/monitor_head))

/obj/item/bodypart/chest/robot/android/bare
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bare_chest"
	limb_id = "bare"

/obj/item/bodypart/arm/right/robot/android/bare
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bare_r_arm"
	limb_id = "bare"

/obj/item/bodypart/arm/left/robot/android/bare
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bare_l_arm"
	limb_id = "bare"

/obj/item/bodypart/leg/right/robot/android/bare
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bare_r_leg"
	limb_id = "bare"

/obj/item/bodypart/leg/left/robot/android/bare
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bare_r_leg"
	limb_id = "bare"

///
// Mariinsky
///
/obj/item/bodypart/head/robot/android/mariinsky
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "mariinsky_head"
	limb_id = "mariinsky"

/obj/item/bodypart/chest/robot/android/mariinsky
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "mariinsky_chest"
	limb_id = "mariinsky"

/obj/item/bodypart/arm/right/robot/android/mariinsky
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "mariinsky_r_arm"
	limb_id = "mariinsky"

/obj/item/bodypart/arm/left/robot/android/mariinsky
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "mariinsky_l_arm"
	limb_id = "mariinsky"

/obj/item/bodypart/leg/right/robot/android/mariinsky
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "mariinsky_r_leg"
	limb_id = "mariinsky"

/obj/item/bodypart/leg/left/robot/android/mariinsky
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "mariinsky_r_leg"
	limb_id = "mariinsky"

///
// E3N
///
/obj/item/bodypart/head/robot/android/e_three_n
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "e_three_n_head"
	limb_id = "e_three_n"
	head_flags = HEAD_MONITOR_FACE

/obj/item/bodypart/chest/robot/android/e_three_n
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "e_three_n_chest"
	limb_id = "e_three_n"

/obj/item/bodypart/arm/right/robot/android/e_three_n
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "e_three_n_r_arm"
	limb_id = "e_three_n"

/obj/item/bodypart/arm/left/robot/android/e_three_n
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "e_three_n_l_arm"
	limb_id = "e_three_n"

/obj/item/bodypart/leg/right/robot/android/e_three_n
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "e_three_n_r_leg"
	limb_id = "e_three_n"

/obj/item/bodypart/leg/left/robot/android/e_three_n
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "e_three_n_r_leg"
	limb_id = "e_three_n"

///
// Morpheus
///
/obj/item/bodypart/head/robot/android/mc //morb
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "mc_head"
	limb_id = "mc"
	head_flags = HEAD_MONITOR_FACE

/obj/item/bodypart/head/robot/android/mc/on_adding(mob/living/carbon/new_owner)
	. = ..()
	new_owner.AddComponent(/datum/component/monitor_head)

/obj/item/bodypart/head/robot/android/mc/on_removal(mob/living/carbon/old_owner)
	. = ..()
	qdel(old_owner.GetComponent(/datum/component/monitor_head))

/obj/item/bodypart/chest/robot/android/mc
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "mc_chest"
	limb_id = "mc"

/obj/item/bodypart/arm/right/robot/android/mc
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "mc_r_arm"
	limb_id = "mc"

/obj/item/bodypart/arm/left/robot/android/mc
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "mc_l_arm"
	limb_id = "mc"

/obj/item/bodypart/leg/right/robot/android/mc
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "mc_r_leg"
	limb_id = "mc"

/obj/item/bodypart/leg/left/robot/android/mc
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "mc_r_leg"
	limb_id = "mc"

///
// Bishop Cyberkinetics
///
/obj/item/bodypart/head/robot/android/bs_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bs_one_head"
	limb_id = "bs_one"
	head_flags = HEAD_MONITOR_FACE

/obj/item/bodypart/head/robot/android/bs_one/on_adding(mob/living/carbon/new_owner)
	. = ..()
	new_owner.AddComponent(/datum/component/monitor_head)

/obj/item/bodypart/head/robot/android/bs_one/on_removal(mob/living/carbon/old_owner)
	. = ..()
	qdel(old_owner.GetComponent(/datum/component/monitor_head))

/obj/item/bodypart/chest/robot/android/bs_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bs_one_chest"
	limb_id = "bs_one"

/obj/item/bodypart/arm/right/robot/android/bs_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bs_one_r_arm"
	limb_id = "bs_one"

/obj/item/bodypart/arm/left/robot/android/bs_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bs_one_l_arm"
	limb_id = "bs_one"

/obj/item/bodypart/leg/right/robot/android/bs_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bs_one_r_leg"
	limb_id = "bs_one"

/obj/item/bodypart/leg/left/robot/android/bs_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bs_one_r_leg"
	limb_id = "bs_one"

///
// Bishop Cyberkinetics 2.0
///
/obj/item/bodypart/head/robot/android/bs_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bs_two_head"
	limb_id = "bs_two"
	head_flags = HEAD_MONITOR_FACE

/obj/item/bodypart/head/robot/android/bs_two/on_adding(mob/living/carbon/new_owner)
	. = ..()
	new_owner.AddComponent(/datum/component/monitor_head)

/obj/item/bodypart/head/robot/android/bs_two/on_removal(mob/living/carbon/old_owner)
	. = ..()
	qdel(old_owner.GetComponent(/datum/component/monitor_head))

/obj/item/bodypart/chest/robot/android/bs_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bs_two_chest"
	limb_id = "bs_two"

/obj/item/bodypart/arm/right/robot/android/bs_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bs_two_r_arm"
	limb_id = "bs_two"

/obj/item/bodypart/arm/left/robot/android/bs_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bs_two_l_arm"
	limb_id = "bs_two"

/obj/item/bodypart/leg/right/robot/android/bs_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bs_two_r_leg"
	limb_id = "bs_two"

/obj/item/bodypart/leg/left/robot/android/bs_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bs_two_r_leg"
	limb_id = "bs_two"

///
// Hephaestus Industries
///
/obj/item/bodypart/head/robot/android/hi_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "hi_one_head"
	limb_id = "hi_one"
	head_flags = HEAD_MONITOR_FACE

/obj/item/bodypart/head/robot/android/hi_one/on_adding(mob/living/carbon/new_owner)
	. = ..()
	new_owner.AddComponent(/datum/component/monitor_head)

/obj/item/bodypart/head/robot/android/hi_one/on_removal(mob/living/carbon/old_owner)
	. = ..()
	qdel(old_owner.GetComponent(/datum/component/monitor_head))

/obj/item/bodypart/chest/robot/android/hi_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "hi_one_chest"
	limb_id = "hi_one"

/obj/item/bodypart/arm/right/robot/android/hi_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "hi_one_r_arm"
	limb_id = "hi_one"

/obj/item/bodypart/arm/left/robot/android/hi_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "hi_one_l_arm"
	limb_id = "hi_one"

/obj/item/bodypart/leg/right/robot/android/hi_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "hi_one_r_leg"
	limb_id = "hi_one"

/obj/item/bodypart/leg/left/robot/android/hi_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "hi_one_r_leg"
	limb_id = "hi_one"

///
// Hephaestus Industries 2.0
///
/obj/item/bodypart/head/robot/android/hi_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "hi_two_head"
	limb_id = "hi_two"
	head_flags = HEAD_MONITOR_FACE

/obj/item/bodypart/head/robot/android/hi_two/on_adding(mob/living/carbon/new_owner)
	. = ..()
	new_owner.AddComponent(/datum/component/monitor_head)

/obj/item/bodypart/head/robot/android/hi_two/on_removal(mob/living/carbon/old_owner)
	. = ..()
	qdel(old_owner.GetComponent(/datum/component/monitor_head))

/obj/item/bodypart/chest/robot/android/hi_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "hi_two_chest"
	limb_id = "hi_two"

/obj/item/bodypart/arm/right/robot/android/hi_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "hi_two_r_arm"
	limb_id = "hi_two"

/obj/item/bodypart/arm/left/robot/android/hi_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "hi_two_l_arm"
	limb_id = "hi_two"

/obj/item/bodypart/leg/right/robot/android/hi_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "hi_two_r_leg"
	limb_id = "hi_two"

/obj/item/bodypart/leg/left/robot/android/hi_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "hi_two_r_leg"
	limb_id = "hi_two"

///
// Shellguard Munitions Standard Series 😎
///
/obj/item/bodypart/head/robot/android/sgm
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "sgm_head"
	limb_id = "sgm"
	head_flags = HEAD_MONITOR_FACE

/obj/item/bodypart/head/robot/android/sgm/on_adding(mob/living/carbon/new_owner)
	. = ..()
	new_owner.AddComponent(/datum/component/monitor_head)

/obj/item/bodypart/head/robot/android/sgm/on_removal(mob/living/carbon/old_owner)
	. = ..()
	qdel(old_owner.GetComponent(/datum/component/monitor_head))

/obj/item/bodypart/chest/robot/android/sgm
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "sgm_chest"
	limb_id = "sgm"

/obj/item/bodypart/arm/right/robot/android/sgm
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "sgm_r_arm"
	limb_id = "sgm"

/obj/item/bodypart/arm/left/robot/android/sgm
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "sgm_l_arm"
	limb_id = "sgm"

/obj/item/bodypart/leg/right/robot/android/sgm
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "sgm_r_leg"
	limb_id = "sgm"

/obj/item/bodypart/leg/left/robot/android/sgm
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "sgm_r_leg"
	limb_id = "sgm"

///
// Ward Takahashi Manufacturing
///
/obj/item/bodypart/head/robot/android/wtm
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "wtm_head"
	limb_id = "wtm"
	head_flags = HEAD_MONITOR_FACE

/obj/item/bodypart/head/robot/android/wtm/on_adding(mob/living/carbon/new_owner)
	. = ..()
	new_owner.AddComponent(/datum/component/monitor_head)

/obj/item/bodypart/head/robot/android/wtm/on_removal(mob/living/carbon/old_owner)
	. = ..()
	qdel(old_owner.GetComponent(/datum/component/monitor_head))

/obj/item/bodypart/chest/robot/android/wtm
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "wtm_chest"
	limb_id = "wtm"

/obj/item/bodypart/arm/right/robot/android/wtm
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "wtm_r_arm"
	limb_id = "wtm"

/obj/item/bodypart/arm/left/robot/android/wtm
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "wtm_l_arm"
	limb_id = "wtm"

/obj/item/bodypart/leg/right/robot/android/wtm
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "wtm_r_leg"
	limb_id = "wtm"

/obj/item/bodypart/leg/left/robot/android/wtm
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "wtm_r_leg"
	limb_id = "wtm"

///
// Xion Manufacturing Group
///
/obj/item/bodypart/head/robot/android/xmg_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "xmg_one_head"
	limb_id = "xmg_one_one"
	head_flags = HEAD_MONITOR_FACE

/obj/item/bodypart/head/robot/android/xmg_one/on_adding(mob/living/carbon/new_owner)
	. = ..()
	new_owner.AddComponent(/datum/component/monitor_head)

/obj/item/bodypart/head/robot/android/xmg_one/on_removal(mob/living/carbon/old_owner)
	. = ..()
	qdel(old_owner.GetComponent(/datum/component/monitor_head))

/obj/item/bodypart/chest/robot/android/xmg_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "xmg_one_chest"
	limb_id = "xmg_one_one"

/obj/item/bodypart/arm/right/robot/android/xmg_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "xmg_one_r_arm"
	limb_id = "xmg_one_one"

/obj/item/bodypart/arm/left/robot/android/xmg_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "xmg_one_l_arm"
	limb_id = "xmg_one_one"

/obj/item/bodypart/leg/right/robot/android/xmg_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "xmg_one_r_leg"
	limb_id = "xmg_one_one"

/obj/item/bodypart/leg/left/robot/android/xmg_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "xmg_one_r_leg"
	limb_id = "xmg_one_one"

///
// Xion Manufacturing Group 2.0
///
/obj/item/bodypart/head/robot/android/xmg_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "xmg_two_head"
	limb_id = "xmg_two"
	head_flags = HEAD_MONITOR_FACE

/obj/item/bodypart/head/robot/android/xmg_two/on_adding(mob/living/carbon/new_owner)
	. = ..()
	new_owner.AddComponent(/datum/component/monitor_head)

/obj/item/bodypart/head/robot/android/xmg_two/on_removal(mob/living/carbon/old_owner)
	. = ..()
	qdel(old_owner.GetComponent(/datum/component/monitor_head))

/obj/item/bodypart/chest/robot/android/xmg_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "xmg_two_chest"
	limb_id = "xmg_two"

/obj/item/bodypart/arm/right/robot/android/xmg_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "xmg_two_r_arm"
	limb_id = "xmg_two"

/obj/item/bodypart/arm/left/robot/android/xmg_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "xmg_two_l_arm"
	limb_id = "xmg_two"

/obj/item/bodypart/leg/right/robot/android/xmg_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "xmg_two_r_leg"
	limb_id = "xmg_two"

/obj/item/bodypart/leg/left/robot/android/xmg_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "xmg_two_r_leg"
	limb_id = "xmg_two"


///
// Zeng-Hu Pharmaceuticals
///
/obj/item/bodypart/head/robot/android/zhp
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "zhp_head"
	limb_id = "zhp"
	head_flags = HEAD_MONITOR_FACE

/obj/item/bodypart/head/robot/android/zhp/on_adding(mob/living/carbon/new_owner)
	. = ..()
	new_owner.AddComponent(/datum/component/monitor_head)

/obj/item/bodypart/head/robot/android/zhp/on_removal(mob/living/carbon/old_owner)
	. = ..()
	qdel(old_owner.GetComponent(/datum/component/monitor_head))

/obj/item/bodypart/chest/robot/android/zhp
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "zhp_chest"
	limb_id = "zhp"

/obj/item/bodypart/arm/right/robot/android/zhp
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "zhp_r_arm"
	limb_id = "zhp"

/obj/item/bodypart/arm/left/robot/android/zhp
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "zhp_l_arm"
	limb_id = "zhp"

/obj/item/bodypart/leg/right/robot/android/zhp
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "zhp_r_leg"
	limb_id = "zhp"

/obj/item/bodypart/leg/left/robot/android/zhp
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "zhp_r_leg"
	limb_id = "zhp"

#undef HEAD_MONITOR_FACE
#undef ANDROID_BODYPARTS_DMI

/datum/design/android_head
	name = "Android Head"
	id = "android_head"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/head/robot/android
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*10,
		/datum/material/silver=SHEET_MATERIAL_AMOUNT*3,
	)
	construction_time = 20 SECONDS
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ADVANCED_LIMBS
	)

/datum/design/android_chest
	name = "Android Chest"
	id = "android_chest"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/chest/robot/android
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*10,
		/datum/material/silver=SHEET_MATERIAL_AMOUNT*3,
	)
	construction_time = 20 SECONDS
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ADVANCED_LIMBS
	)

/datum/design/android_l_arm
	name = "Android Left Arm"
	id = "android_l_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/left/robot/android
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*10,
		/datum/material/silver=SHEET_MATERIAL_AMOUNT*3,
	)
	construction_time = 20 SECONDS
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ADVANCED_LIMBS
	)

/datum/design/android_r_arm
	name = "Android Right Arm"
	id = "android_r_arm"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/arm/right/robot/android
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*10,
		/datum/material/silver=SHEET_MATERIAL_AMOUNT*3,
	)
	construction_time = 20 SECONDS
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ADVANCED_LIMBS
	)

/datum/design/android_l_leg
	name = "Android Left Leg"
	id = "android_l_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/left/robot/android
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*10,
		/datum/material/silver=SHEET_MATERIAL_AMOUNT*3,
	)
	construction_time = 20 SECONDS
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ADVANCED_LIMBS
	)

/datum/design/android_r_leg
	name = "Android Right Leg"
	id = "android_r_leg"
	build_type = MECHFAB
	build_path = /obj/item/bodypart/leg/right/robot/android
	materials = list(
		/datum/material/iron=SHEET_MATERIAL_AMOUNT*10,
		/datum/material/silver=SHEET_MATERIAL_AMOUNT*3,
	)
	construction_time = 20 SECONDS
	category = list(
		RND_CATEGORY_CYBERNETICS + RND_SUBCATEGORY_CYBERNETICS_ADVANCED_LIMBS
	)
