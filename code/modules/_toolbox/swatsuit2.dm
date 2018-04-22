/obj/item/clothing/head/helmet/space/hardsuit/swat //Regular swat suit, not modified like the UEG suit.
	name = "MK.II SWAT helmet"
	desc = "A tactical SWAT helmet boasting better protection."
	icon = 'icons/oldschool/clothing/hatsueg.dmi'
	icon_state = "ueghelm"
	item_state = "ueghelm"
	alternate_worn_icon = 'icons/oldschool/clothing/headueg.dmi'
	armor = list("melee" = 40, "bullet" = 50, "laser" = 50, "energy" = 25, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100)
	strip_delay = 120
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = HIDEEARS|HIDEEYES|HIDEFACE|HIDEHAIR
	heat_protection = HEAD
	max_heat_protection_temperature = FIRE_IMMUNITY_HELM_MAX_TEMP_PROTECT
	actions_types = list()

/obj/item/clothing/head/helmet/space/hardsuit/ueg/attack_self(mob/user)
	return

/obj/item/clothing/suit/space/hardsuit/swat
	name = "MK.II SWAT suit"
	desc = "A suit with streamlined joints and armor made out of superior materials, insulated against intense heat. The most advanced tactical armor available, usually reserved for heavy hitter corporate security."
	icon = 'icons/oldschool/clothing/suitsueg.dmi'
	icon_state = "uegarmor"
	item_state = "uegarmor"
	alternate_worn_icon = 'icons/oldschool/clothing/suitueg.dmi'
	allowed = list(/obj/item/gun,/obj/item/ammo_box,/obj/item/ammo_casing,/obj/item/melee/baton,/obj/item/restraints/handcuffs,/obj/item/tank/internals,/obj/item/kitchen/knife/combat)
	armor = list("melee" = 40, "bullet" = 50, "laser" = 50, "energy" = 25, "bomb" = 50, "bio" = 100, "rad" = 50, "fire" = 100, "acid" = 100)
	strip_delay = 130
	resistance_flags = FIRE_PROOF | ACID_PROOF
	heat_protection = CHEST|GROIN|LEGS|FEET|ARMS|HANDS
	max_heat_protection_temperature = FIRE_IMMUNITY_SUIT_MAX_TEMP_PROTECT
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/swat