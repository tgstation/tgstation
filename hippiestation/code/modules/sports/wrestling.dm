/obj/item/clothing/mask/hippie/wrestling
	name = "wrestling mustache"
	desc = "A high-tech mustache that can connect to an air tank."
	icon_state = "mustache"
	flags = BLOCK_GAS_SMOKE_EFFECT | MASKINTERNALS
	flags_inv = HIDEFACE|HIDEFACIALHAIR
	w_class = WEIGHT_CLASS_SMALL
	item_state = "mustache"
	flags_cover = MASKCOVERSMOUTH
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF

/obj/item/clothing/glasses/hippie/wrestling
	name = "wrestling goggles"
	desc = "An advanced pair of wrestling goggles."
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF
	icon_state = "wrestlinggoggles"
	flash_protect = 2
	flags_cover = GLASSESCOVERSEYES
	visor_flags_inv = HIDEEYES
	glass_colour_type = /datum/client_colour/glass_colour/gray

/obj/item/clothing/under/hippie/wrestling
	name = "wrestling unitard"
	desc = "Protects great from ranged attacks, but not against much else. A good wrestler does not need melee protection."
	resistance_flags = INDESTRUCTIBLE | FIRE_PROOF | ACID_PROOF
	body_parts_covered = CHEST|GROIN|LEGS
	flags = THICKMATERIAL
	armor = list(melee = 0, bullet = 70, laser = 60, energy = 50, bomb = 0, bio = 0, rad = 0, fire = 100, acid = 100)
	can_adjust = FALSE
	icon_state = "unitard"
	can_adjust = FALSE

/obj/item/clothing/under/wrestling/Initialize()
	..()
	color = pick("white","green","yellow")

/datum/action/slam/var/action_icon = 'hippiestation/icons/mob/actions.dmi'
/datum/action/strike/var/action_icon = 'hippiestation/icons/mob/actions.dmi'
/datum/action/kick/var/action_icon = 'hippiestation/icons/mob/actions.dmi'
/datum/action/throw_wrassle/var/action_icon = 'hippiestation/icons/mob/actions.dmi'