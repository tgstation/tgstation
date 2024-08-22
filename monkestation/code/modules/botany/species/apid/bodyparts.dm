/obj/item/bodypart/head/apid
	icon = 'monkestation/code/modules/botany/icons/apid_sprites.dmi'
	icon_state = "apid_head"
	icon_static = 'monkestation/code/modules/botany/icons/apid_sprites.dmi'
	limb_id = SPECIES_APID
	is_dimorphic = TRUE
	should_draw_greyscale = FALSE
	brute_modifier = 1.25 //ethereal are weak to brute damage
	head_flags = HEAD_HAIR| HEAD_LIPS | HEAD_EYESPRITES | HEAD_EYEHOLES | HEAD_DEBRAIN

/obj/item/bodypart/chest/apid
	icon = 'monkestation/code/modules/botany/icons/apid_sprites.dmi'
	icon_state = "apid_chest_m"
	icon_static = 'monkestation/code/modules/botany/icons/apid_sprites.dmi'
	limb_id = SPECIES_APID
	is_dimorphic = TRUE
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/apid
	icon = 'monkestation/code/modules/botany/icons/apid_sprites.dmi'
	icon_state = "apid_l_arm"
	icon_static = 'monkestation/code/modules/botany/icons/apid_sprites.dmi'
	limb_id = SPECIES_APID
	should_draw_greyscale = FALSE
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'

/obj/item/bodypart/arm/right/apid
	icon = 'monkestation/code/modules/botany/icons/apid_sprites.dmi'
	icon_state = "apid_r_arm"
	icon_static = 'monkestation/code/modules/botany/icons/apid_sprites.dmi'
	limb_id = SPECIES_APID
	should_draw_greyscale = FALSE
	unarmed_attack_verb = "slash"
	unarmed_attack_effect = ATTACK_EFFECT_CLAW
	unarmed_attack_sound = 'sound/weapons/slash.ogg'
	unarmed_miss_sound = 'sound/weapons/slashmiss.ogg'

/obj/item/bodypart/leg/left/apid
	icon = 'monkestation/code/modules/botany/icons/apid_sprites.dmi'
	icon_state = "apid_l_leg"
	icon_static = 'monkestation/code/modules/botany/icons/apid_sprites.dmi'
	limb_id = SPECIES_APID
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right/apid
	icon = 'monkestation/code/modules/botany/icons/apid_sprites.dmi'
	icon_state = "apid_r_leg"
	icon_static = 'monkestation/code/modules/botany/icons/apid_sprites.dmi'
	limb_id = SPECIES_APID
	should_draw_greyscale = FALSE
