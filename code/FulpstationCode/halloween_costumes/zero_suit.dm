/obj/item/clothing/under/costume/zero_suit
	name = "plastic bounty hunter's plugsuit"
	desc = "A cheap plastic suit with zero practical use."
	icon_state = "zerosuit"
	icon = 'icons/fulpicons/halloween_costumes/samus_icon.dmi'
	mob_overlay_icon = 'icons/fulpicons/halloween_costumes/samus_worn.dmi'
	body_parts_covered = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	fitted = NO_FEMALE_UNIFORM
	alternate_worn_layer = GLOVES_LAYER //copied blindly from mech jumpsuit lmao
	can_adjust = FALSE

/obj/item/clothing/suit/space/hardsuit/toy/
	name = "toy hardsuit"
	desc = "Comes packaged with the 'My First Singularity Playset'"
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	clothing_flags = NONE
	min_cold_protection_temperature = null
	max_heat_protection_temperature = null
	cold_protection = null
	heat_protection = null
	slowdown = 0
	toggle_helmet_sound = 'sound/fulp_sounds/plastic_close.ogg'
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/toy

/obj/item/clothing/suit/space/hardsuit/toy/varia
	name = "plastic bounty hunter's hardsuit"
	desc = "It's variapparent that this is injection-moulded."
	icon_state = "varia_suit"
	icon = 'icons/fulpicons/halloween_costumes/samus_icon.dmi'
	mob_overlay_icon = 'icons/fulpicons/halloween_costumes/samus_worn.dmi'
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/gun/ballistic/shotgun/toy/toy_arm_cannon)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/toy/varia


/obj/item/clothing/head/helmet/space/hardsuit/toy
	name = "toy hardsuit helmet"
	desc = "With working flashlight!"
	max_integrity = 300
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 0)
	clothing_flags = NONE
	min_cold_protection_temperature = null
	max_heat_protection_temperature = null
	cold_protection = null
	heat_protection = null
	hardsuit_type = "engineering"

/obj/item/clothing/head/helmet/space/hardsuit/toy/varia
	name = "plastic bounty hunter's helmet"
	desc = "A cheap plastic helmet spring-loaded into the suit."
	icon_state = "hardsuit0-varia" //hardsuit helmet code is weird - has to follow this format: 'hardsuit0-[hardsuit_type]' and have 'hardsuit1-[hardsuit_type]'' as the icon for the light-on ver
	icon = 'icons/fulpicons/halloween_costumes/samus_icon.dmi'
	mob_overlay_icon = 'icons/fulpicons/halloween_costumes/samus_worn.dmi'
	hardsuit_type = "varia"

/obj/item/ammo_casing/caseless/foam_dart/arm_ball
	name = "small foam ball"
	desc = "Eat this, space pirates!"
	icon = 'icons/fulpicons/halloween_costumes/samus_icon.dmi'
	projectile_type = /obj/projectile/bullet/reusable/foam_dart/arm_ball
	icon_state = "ball"
	caliber = "arm_ball"

/obj/item/ammo_box/magazine/internal/shot/toy/arm_ball
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/arm_ball
	caliber = "arm_ball"

/obj/item/gun/ballistic/shotgun/toy/toy_arm_cannon
	name = "foam force arm cannon"
	desc = "The chozo manufacturing industry exports thousands of these things a year. Ages 8+"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/toy/arm_ball
	icon = 'icons/fulpicons/halloween_costumes/samus_icon.dmi'
	icon_state = "arm_cannon"
	item_state = "arm_cannon"
	lefthand_file = 'icons/fulpicons/halloween_costumes/samus_lefthand.dmi'
	righthand_file = 'icons/fulpicons/halloween_costumes/samus_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32

/obj/projectile/bullet/reusable/foam_dart/arm_ball
	name = "small foam ball"
	desc = "Eat this, space pirates!"
	icon = 'icons/fulpicons/halloween_costumes/samus_icon.dmi'
	icon_state = "ball"
	ammo_type = /obj/item/ammo_casing/caseless/foam_dart/arm_ball

/obj/item/gun/ballistic/shotgun/toy/toy_arm_cannon/shoot_live_shot(mob/living/user as mob|obj) //makes it automatic
	..()
	src.rack()

/obj/item/ammo_casing/caseless/foam_dart/arm_ball/attack_self() //prevents breaking via dart modding
	return

/obj/item/ammo_casing/caseless/foam_dart/arm_ball/attackby(obj/item/A) //prevents using a screwdriver on it
	if (A.tool_behaviour == TOOL_SCREWDRIVER)
		return
	..()

///obj/item/gun/ballistic/shotgun/toy/toy_arm_cannon/update_icon() //Prevents all the shitty overlays breaking the icon   // UPDATE 11/4/19 This proc throws errors now.
//	SEND_SIGNAL(src, COMSIG_OBJ_UPDATE_ICON)
//	return
