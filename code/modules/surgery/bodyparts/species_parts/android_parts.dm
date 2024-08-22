/**
 * This is ultra stupid, but essentially androids use robotic limb subtypes that are NOT
 * immune to being replaced on species change.
 * Yes, that is the entire reason these exist.
 */

/obj/item/bodypart/head/robot/android
	change_exempt_flags = null
	head_flags = HEAD_HAIR | HEAD_EYESPRITES

/obj/item/bodypart/chest/robot/android
	change_exempt_flags = null

/obj/item/bodypart/arm/left/robot/android
	change_exempt_flags = null

/obj/item/bodypart/arm/right/robot/android
	change_exempt_flags = null

/obj/item/bodypart/leg/left/robot/android
	change_exempt_flags = null

/obj/item/bodypart/leg/right/robot/android
	change_exempt_flags = null
