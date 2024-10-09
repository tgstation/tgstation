// easy define for head_flags of android heads that dont feature eyes (aka monitor heads (aka IPCs))
#define HEAD_MONITOR_FACE (HEAD_HAIR|HEAD_LIPS|HEAD_DEBRAIN)
// easy define for the android bodypart .dmi
#define ANDROID_BODYPARTS_DMI 'modular_doppler/modular_species/species_types/android/icons/android_parts.dmi'

///
// Overwrites
///
/obj/item/bodypart/head/robot/android
	biological_state = (BIO_ROBOTIC|BIO_BLOODED)
	brute_modifier = 1
	burn_modifier = 1

/obj/item/bodypart/chest/robot/android
	biological_state = (BIO_ROBOTIC|BIO_BLOODED)
	brute_modifier = 1
	burn_modifier = 1

/obj/item/bodypart/chest/robot/android/check_limbs()
	return

/obj/item/bodypart/arm/right/robot/android
	biological_state = (BIO_ROBOTIC|BIO_BLOODED)
	brute_modifier = 1
	burn_modifier = 1

/obj/item/bodypart/arm/left/robot/android
	biological_state = (BIO_ROBOTIC|BIO_BLOODED)
	brute_modifier = 1
	burn_modifier = 1

/obj/item/bodypart/leg/right/robot/android
	biological_state = (BIO_ROBOTIC|BIO_BLOODED)
	brute_modifier = 1
	burn_modifier = 1

/obj/item/bodypart/leg/left/robot/android
	biological_state = (BIO_ROBOTIC|BIO_BLOODED)
	brute_modifier = 1
	burn_modifier = 1

///
// Classic (this may look empty, but its a load-bearing definition)
///
/obj/item/bodypart/head/robot/android/classic

/obj/item/bodypart/chest/robot/android/classic

/obj/item/bodypart/arm/right/robot/android/classic

/obj/item/bodypart/arm/left/robot/android/classic

/obj/item/bodypart/leg/right/robot/android/classic

/obj/item/bodypart/leg/left/robot/android/classic

///
// Bare
///
/obj/item/bodypart/head/robot/android/bare
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "synth_head"
	limb_id = "synth"
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
	icon_state = "synth_chest"
	limb_id = "synth"

/obj/item/bodypart/arm/right/robot/android/bare
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "synth_r_arm"
	limb_id = "synth"

/obj/item/bodypart/arm/left/robot/android/bare
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "synth_l_arm"
	limb_id = "synth"

/obj/item/bodypart/leg/right/robot/android/bare
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "synth_r_leg"
	limb_id = "synth"

/obj/item/bodypart/leg/left/robot/android/bare
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "synth_r_leg"
	limb_id = "synth"

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
	icon_state = "e3n_head"
	limb_id = "e3n"
	head_flags = HEAD_MONITOR_FACE

/obj/item/bodypart/chest/robot/android/e_three_n
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "e3n_chest"
	limb_id = "e3n"

/obj/item/bodypart/arm/right/robot/android/e_three_n
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "e3n_r_arm"
	limb_id = "e3n"

/obj/item/bodypart/arm/left/robot/android/e_three_n
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "e3n_l_arm"
	limb_id = "e3n"

/obj/item/bodypart/leg/right/robot/android/e_three_n
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "e3n_r_leg"
	limb_id = "e3n"

/obj/item/bodypart/leg/left/robot/android/e_three_n
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "e3n_r_leg"
	limb_id = "e3n"

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
	icon_state = "bs_head"
	limb_id = "bs"
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
	icon_state = "bs_chest"
	limb_id = "bs"

/obj/item/bodypart/arm/right/robot/android/bs_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bs_r_arm"
	limb_id = "bs"

/obj/item/bodypart/arm/left/robot/android/bs_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bs_l_arm"
	limb_id = "bs"

/obj/item/bodypart/leg/right/robot/android/bs_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bs_r_leg"
	limb_id = "bs"

/obj/item/bodypart/leg/left/robot/android/bs_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bs_r_leg"
	limb_id = "bs"

///
// Bishop Cyberkinetics 2.0
///
/obj/item/bodypart/head/robot/android/bs_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bs2_head"
	limb_id = "bs2"
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
	icon_state = "bs2_chest"
	limb_id = "bs2"

/obj/item/bodypart/arm/right/robot/android/bs_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bs2_r_arm"
	limb_id = "bs2"

/obj/item/bodypart/arm/left/robot/android/bs_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bs2_l_arm"
	limb_id = "bs2"

/obj/item/bodypart/leg/right/robot/android/bs_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bs2_r_leg"
	limb_id = "bs2"

/obj/item/bodypart/leg/left/robot/android/bs_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "bs2_r_leg"
	limb_id = "bs2"

///
// Hephaestus Industries
///
/obj/item/bodypart/head/robot/android/hi_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "hi_head"
	limb_id = "hi"
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
	icon_state = "hi_chest"
	limb_id = "hi"

/obj/item/bodypart/arm/right/robot/android/hi_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "hi_r_arm"
	limb_id = "hi"

/obj/item/bodypart/arm/left/robot/android/hi_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "hi_l_arm"
	limb_id = "hi"

/obj/item/bodypart/leg/right/robot/android/hi_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "hi_r_leg"
	limb_id = "hi"

/obj/item/bodypart/leg/left/robot/android/hi_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "hi_r_leg"
	limb_id = "hi"

///
// Hephaestus Industries 2.0
///
/obj/item/bodypart/head/robot/android/hi_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "hi2_head"
	limb_id = "hi2"
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
	icon_state = "hi2_chest"
	limb_id = "hi2"

/obj/item/bodypart/arm/right/robot/android/hi_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "hi2_r_arm"
	limb_id = "hi2"

/obj/item/bodypart/arm/left/robot/android/hi_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "hi2_l_arm"
	limb_id = "hi2"

/obj/item/bodypart/leg/right/robot/android/hi_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "hi2_r_leg"
	limb_id = "hi2"

/obj/item/bodypart/leg/left/robot/android/hi_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "hi2_r_leg"
	limb_id = "hi2"

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
	icon_state = "xmg_head"
	limb_id = "xmg"
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
	icon_state = "xmg_chest"
	limb_id = "xmg"

/obj/item/bodypart/arm/right/robot/android/xmg_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "xmg_r_arm"
	limb_id = "xmg"

/obj/item/bodypart/arm/left/robot/android/xmg_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "xmg_l_arm"
	limb_id = "xmg"

/obj/item/bodypart/leg/right/robot/android/xmg_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "xmg_r_leg"
	limb_id = "xmg"

/obj/item/bodypart/leg/left/robot/android/xmg_one
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "xmg_r_leg"
	limb_id = "xmg"

///
// Xion Manufacturing Group 2.0
///
/obj/item/bodypart/head/robot/android/xmg_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "xmg2_head"
	limb_id = "xmg2"
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
	icon_state = "xmg2_chest"
	limb_id = "xmg2"

/obj/item/bodypart/arm/right/robot/android/xmg_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "xmg2_r_arm"
	limb_id = "xmg2"

/obj/item/bodypart/arm/left/robot/android/xmg_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "xmg2_l_arm"
	limb_id = "xmg2"

/obj/item/bodypart/leg/right/robot/android/xmg_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "xmg2_r_leg"
	limb_id = "xmg2"

/obj/item/bodypart/leg/left/robot/android/xmg_two
	icon_static = ANDROID_BODYPARTS_DMI
	icon = ANDROID_BODYPARTS_DMI
	icon_state = "xmg2_r_leg"
	limb_id = "xmg2"


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
