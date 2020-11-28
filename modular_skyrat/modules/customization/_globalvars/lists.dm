//DO NOT CHANGE THOSE LISTS UNLESS YOU KNOW WHAT YOURE DOING (will mess savefiles)


GLOBAL_LIST_INIT(marking_zone_to_bitflag, list(BODY_ZONE_HEAD = HEAD,
										BODY_ZONE_CHEST = CHEST,
										BODY_ZONE_L_LEG = LEG_LEFT,
										BODY_ZONE_R_LEG = LEG_RIGHT,
										BODY_ZONE_L_ARM = ARM_LEFT,
										BODY_ZONE_R_ARM = ARM_RIGHT,
										BODY_ZONE_PRECISE_L_HAND = HAND_LEFT,
										BODY_ZONE_PRECISE_R_HAND = HAND_RIGHT
										))

//GLOBAL_LIST_INIT(marking_zones, list("Head","Chest","Left Leg","Right Leg","Left Arm","Right Arm","Left Hand","Right Hand"))

GLOBAL_LIST_INIT(marking_zones, list(BODY_ZONE_HEAD,BODY_ZONE_CHEST,BODY_ZONE_L_LEG,BODY_ZONE_R_LEG,BODY_ZONE_L_ARM,BODY_ZONE_R_ARM,BODY_ZONE_PRECISE_L_HAND,BODY_ZONE_PRECISE_R_HAND))

///Those are the values available from prefs
GLOBAL_LIST_INIT(robotic_styles_list, list("None" = "None",
										"Surplus" = 'icons/mob/augmentation/surplus_augments.dmi',
										"Cyborg" = 'icons/mob/augmentation/augments.dmi',
										"Engineering" = 'icons/mob/augmentation/augments_engineer.dmi',
										"Mining" = 'icons/mob/augmentation/augments_mining.dmi',
										"Security" = 'icons/mob/augmentation/augments_security.dmi',
										"Morpheus Cyberkinetics" = 'modular_skyrat/modules/customization/icons/mob/augmentation/mcgipc.dmi',
										"Bishop Cyberkinetics" = 'modular_skyrat/modules/customization/icons/mob/augmentation/bshipc.dmi',
										"Bishop Cyberkinetics 2.0" = 'modular_skyrat/modules/customization/icons/mob/augmentation/bs2ipc.dmi',
										"Hephaestus Industries" = 'modular_skyrat/modules/customization/icons/mob/augmentation/hsiipc.dmi',
										"Hephaestus Industries 2.0" = 'modular_skyrat/modules/customization/icons/mob/augmentation/hi2ipc.dmi',
										"Shellguard Munitions Standard Series" = 'modular_skyrat/modules/customization/icons/mob/augmentation/sgmipc.dmi',
										"Ward-Takahashi Manufacturing" = 'modular_skyrat/modules/customization/icons/mob/augmentation/wtmipc.dmi',
										"Xion Manufacturing Group" = 'modular_skyrat/modules/customization/icons/mob/augmentation/xmgipc.dmi',
										"Xion Manufacturing Group 2.0" = 'modular_skyrat/modules/customization/icons/mob/augmentation/xm2ipc.dmi',
										"Zeng-Hu Pharmaceuticals" = 'modular_skyrat/modules/customization/icons/mob/augmentation/zhpipc.dmi'
										))
