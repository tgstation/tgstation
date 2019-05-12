/*
* All clothing related stuff goes here.
*/


/*
* Combat Boots
*/

/obj/item/clothing/shoes/perseus
	name = "combat boots"
	icon_state = "swat"
	icon = 'icons/oldschool/perseus.dmi'
	alternate_worn_icon = 'icons/oldschool/perseus_worn.dmi'
	flags_1 = NOSLIP_1
	armor = list("melee" = 25, "bullet" = 25, "laser" = 25, "energy" = 25, "bomb" = 50, "bio" = 10, "rad" = 0)
	var/obj/item/stun_knife/knife
	cold_protection = FEET
	min_cold_protection_temperature = SHOES_MIN_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

	attack_hand(var/mob/living/M)
		if(knife)
			knife.loc = get_turf(src)
			if(M.put_in_active_hand(knife))
				to_chat(M, "<div class='notice'>You slide the [knife] out of the [src].</div>")
				knife = 0
				update_icon()
			return
		..()

	attackby(var/obj/item/I, var/mob/living/M)
		if(istype(I, /obj/item/stun_knife))
			if(knife)	return
			M.dropItemToGround(I)
			knife = I
			I.forceMove(src)
			to_chat(M, "<div class='notice'>You slide the [I] into the [src].</div>")
			update_icon()

	update_icon()
		if(knife)
			icon_state = "[initial(icon_state)][knife.mode == 1 ? "k" : "kl"]"
		else
			icon_state = initial(icon_state)

/*
* Skin Suit
*/

/obj/item/clothing/under/space/skinsuit
	name = "Perseus skin suit"
	icon_state = "pers_skinsuit"
	icon = 'icons/oldschool/perseus.dmi'
	alternate_worn_icon = 'icons/oldschool/perseus_worn.dmi'
	item_state = "perc"
	item_color = "pers_skinsuit"
	desc = "Standard issue to Perseus Security personnel in space assignments. Maintains a safe internal atmosphere for the user."
	flags_1 = STOPSPRESSUREDMAGE_1
	min_cold_protection_temperature = SPACE_SUIT_MIN_TEMP_PROTECT
	w_class = 3
	has_sensor = 0
	resistance_flags = FIRE_PROOF | ACID_PROOF

/*
* Voice Mask
*/

/obj/item/clothing/mask/gas/perseus_voice
	name = "perseus combat mask"
	desc = "A close-fitting mask that can filter some environmental toxins or be connected to an air supply."
	icon_state = "persmask"
	icon = 'icons/oldschool/perseus.dmi'
	alternate_worn_icon = 'icons/oldschool/perseus_worn.dmi'
	item_state = "gas_alt"
	var/locked = /datum/extra_role/perseus
	permeability_coefficient = 0
	flags_cover = MASKCOVERSEYES
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/mask/gas/perseus_voice/disguise_voice()
	if(istype(loc,/mob/living/carbon))
		if(check_perseus(loc))
			return 1
	return ..()

/*
* Light Armor
*/

/obj/item/clothing/suit/armor/lightarmor
	name = "perseus light armor"
	desc = "An armored vest that protects against some damage."
	icon_state = "persarmour"
	item_state = "persarmour"
	icon = 'icons/oldschool/perseus.dmi'
	alternate_worn_icon = 'icons/oldschool/perseus_worn.dmi'
	armor = list("melee" = 30, "bullet" = 30, "laser" = 30, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0)
	body_parts_covered = CHEST|GROIN|LEGS|ARMS
	resistance_flags = FIRE_PROOF | ACID_PROOF

/*
* BlackPack
*/

/obj/item/storage/backpack/blackpack
	name = "backpack"
	desc = "A darkened backpack."
	icon_state = "blackpack"
	icon = 'icons/oldschool/perseus.dmi'
	alternate_worn_icon = 'icons/oldschool/perseus_worn.dmi'
	lefthand_file = 'icons/oldschool/perseus_inhand_left.dmi'
	righthand_file = 'icons/oldschool/perseus_inhand_right.dmi'

/*
* Gloves
*/

/obj/item/clothing/gloves/specops
	desc = "Made of a slightly more resilient material for longer durability."
	name = "PercTech Combat Gloves"
	icon_state = "persgloves"
	item_state = "persgloves"
	icon = 'icons/oldschool/perseus.dmi'
	alternate_worn_icon = 'icons/oldschool/perseus_worn.dmi'
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	heat_protection = HANDS
	cold_protection = HANDS
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	resistance_flags = FIRE_PROOF | ACID_PROOF

/*
* Black Jacket
*/

/obj/item/clothing/suit/blackjacket
	name = "Black jacket"
	desc = "A black jacket."
	icon_state = "blackjacket"
	icon = 'icons/oldschool/perseus.dmi'
	alternate_worn_icon = 'icons/oldschool/perseus_worn.dmi'
	item_state = "blackjacket"
	resistance_flags = FIRE_PROOF | ACID_PROOF

/*
* Perseus Uniform
*/

/obj/item/clothing/under/perseus_uniform
	name = "Perseus uniform"
	desc = "A very plain dark blue jumpsuit."
	icon_state = "pers_blue"
	icon = 'icons/oldschool/perseus.dmi'
	alternate_worn_icon = 'icons/oldschool/perseus_worn.dmi'
	item_state = "bl_suit"
	item_color = "bl_suit"
	resistance_flags = FIRE_PROOF | ACID_PROOF


/*
* Commander Fatigues
*/

/obj/item/clothing/under/perseus_fatigues
	name = "Commander's Fatigues"
	desc = "Casual clothing for a commanding officer."
	icon_state = "persjumpsuit"
	icon = 'icons/oldschool/perseus.dmi'
	alternate_worn_icon = 'icons/oldschool/perseus_worn.dmi'
	item_state = "bl_suit"
	item_color = "persfatigues"
	resistance_flags = FIRE_PROOF | ACID_PROOF


/*
* Riot Shield
*/

/obj/item/shield/riot/perc
	name = "PercTech Riot Shield"
	desc = "A PercTech shield adept at blocking blunt objects from connecting with the torso of the shield wielder."
	//icon = 'icons/obj/weapons.dmi'
	icon_state = "perc_shield"
	icon = 'icons/oldschool/perseus.dmi'
	lefthand_file = 'icons/oldschool/perseus_inhand_left.dmi'
	righthand_file = 'icons/oldschool/perseus_inhand_right.dmi'
	item_state = "p_riot"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/folded = 0

/obj/item/shield/riot/perc/attack_self(mob/user)
	folded = !folded
	icon_state = "[initial(icon_state)][folded ? "_folded" : ""]"
	item_state = "[initial(item_state)][folded ? "_folded" : ""]"
	w_class = folded ? initial(w_class) - 1 : initial(w_class)
	to_chat(user, "You [folded ? "fold" : "unfold"] \the [src].")
	user.update_inv_hands()
	playsound(src.loc, 'sound/weapons/batonextend.ogg', 50, 1)
	add_fingerprint(user)
/*
* Perseus Beret
*/

/obj/item/clothing/head/helmet/space/persberet
	name = "perseus commander beret"
	desc = "Only given to the elite of the Perseus elite."
	icon_state = "persberet"
	icon = 'icons/oldschool/perseus.dmi'
	alternate_worn_icon = 'icons/oldschool/perseus_worn.dmi'
	flags_1 = STOPSPRESSUREDMAGE_1 | THICKMATERIAL_1
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	flags_inv = HIDEFACE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = 0
	armor = list("melee" = 35, "bullet" = 30, "laser" = 30, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0)
/*
* Perseus Helmet
*/

/obj/item/clothing/head/helmet/space/pershelmet
	name = "perseus security helmet"
	desc = "Standard issue to Perseus' specialist enforcer team."
	icon_state = "pershelmet"
	icon = 'icons/oldschool/perseus.dmi'
	alternate_worn_icon = 'icons/oldschool/perseus_worn.dmi'
	flags_1 = THICKMATERIAL_1 | STOPSPRESSUREDMAGE_1
	flags_cover = HEADCOVERSEYES | HEADCOVERSMOUTH
	flags_inv = HIDEFACE | HIDEHAIR
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list("melee" = 35, "bullet" = 30, "laser" = 30, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0)

/*
* Perseus Winter Coat
*/
/obj/item/clothing/suit/wintercoat/perseus
	name = "perseus winter coat"
	desc = "A coat that protects against the bitter cold."
	icon_state = "coatperc"
	icon = 'icons/oldschool/perseus.dmi'
	alternate_worn_icon = 'icons/oldschool/perseus_worn.dmi'

/*
* Perseus Belt
*/
/obj/item/storage/belt/security/perseus
	name = "PercTech Combat Belt"
	desc = "Designed for holding small combat equipment for enforcers."
	icon = 'icons/oldschool/perseus.dmi'
	icon_state = "perctechbelt"
	item_state = "perctechbelt"
	alternate_worn_icon = 'icons/oldschool/perseus_worn.dmi'
	storage_slots = 7
	max_w_class = WEIGHT_CLASS_SMALL
	can_hold = list(
		/obj/item/grenade,
		/obj/item/reagent_containers/spray/pepper,
		/obj/item/restraints/handcuffs,
		/obj/item/device/assembly/flash/handheld,
		/obj/item/clothing/glasses,
		/obj/item/ammo_casing/shotgun,
		/obj/item/ammo_box,
		/obj/item/reagent_containers/food/snacks/donut,
		/obj/item/kitchen/knife/combat,
		/obj/item/device/flashlight,
		/obj/item/device/radio,
		/obj/item/clothing/gloves,
		/obj/item/restraints/legcuffs/bola,
		/obj/item/holosign_creator/security,
		/obj/item/stock_parts/cell/magazine/ep90,
		/obj/item/stun_knife,
		/obj/item/reagent_containers/pill,
		/obj/item/stimpack,
		/obj/item/c4_ex/breach
		)
	content_overlays = FALSE

/*
* Perseus Headset
*/
/obj/item/device/radio/headset/perseus
	name = "Perseus Enforcer's Headset"
	desc = "Standard headset of the Perseus Enforcer.\nTo access the security channel, use :s. For command, use :c."
	icon = 'icons/oldschool/perseus.dmi'
	icon_state = "perseus_headset"
	keyslot = new /obj/item/device/encryptionkey/perseus

/obj/item/device/encryptionkey/perseus
	name = "Perseus encryption key"
	desc = "An encryption key for a radio headset.  To access the security channel, use :s. For command, use :c."
	icon_state = "cap_cypherkey"
	channels = list("Security" = 1, "Command" = 1)

/obj/item/clothing/glasses/perseus
	name = "PercVision"
	desc = "A combination of thermals and nightvision."
	icon_state = "percnight"
	icon = 'icons/oldschool/perseus.dmi'
	alternate_worn_icon = 'icons/oldschool/perseus_worn.dmi'
	item_state = "glasses"
	flash_protect = 1
	vision_flags = SEE_BLACKNESS
	var/emagged = 0
	var/locked = /datum/extra_role/perseus
	var/authorized_darkness_view = 8
	var/authorized_vision_flags = SEE_MOBS
	var/authorized_lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	//origin_tech = "magnets=3"
	//invis_view = SEE_INVISIBLE_MINIMUM

/obj/item/clothing/glasses/perseus/emp_act(severity)
	thermal_overload()
	..()

/obj/item/clothing/glasses/perseus/New()
	SSobj.processing += src
	. = ..()

/obj/item/clothing/glasses/perseus/process()
	var/mob/living/carbon/human/H = loc
	var/datum/extra_role/perseus
	if(istype(H))
		perseus = check_perseus(H)
	if(!perseus)
		H = null
	if(perseus || emagged)
		darkness_view = authorized_darkness_view
		vision_flags = authorized_vision_flags
		lighting_alpha = authorized_lighting_alpha
	else
		darkness_view = initial(darkness_view)
		vision_flags = initial(vision_flags)
		lighting_alpha = initial(lighting_alpha)
	if(H)
		H.update_sight()

/obj/item/clothing/glasses/perseus/emag_act()
	emagged = 1
	return .. ()
