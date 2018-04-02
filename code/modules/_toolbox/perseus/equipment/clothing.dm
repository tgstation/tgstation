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
	armor = list(melee = 80, bullet = 60, laser = 50,energy = 25, bomb = 50, bio = 10, rad = 0)
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
			M.drop_item()
			knife = I
			I.loc = src
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
	w_class = 3
	has_sensor = 0
	resistance_flags = FIRE_PROOF | ACID_PROOF


/*
* Voice Mask
*/

/obj/item/clothing/mask/gas/voice/var/locked = 0

/obj/item/clothing/mask/gas/voice/proc/GetDisplayVoice(mob/living/carbon/human/H)
	if (H && H.wear_mask == src)
		if (H.wear_id)
			var/obj/item/card/id/ID = H.wear_id.GetID()
			if (ID)
				return ID.registered_name
		else
			return "Unknown"
	return H.real_name


/obj/item/clothing/mask/gas/voice/perseus_voice
	name = "perseus combat mask"
	desc = "A close-fitting mask that can filter some environmental toxins or be connected to an air supply."
	icon_state = "persmask"
	icon = 'icons/oldschool/perseus.dmi'
	alternate_worn_icon = 'icons/oldschool/perseus_worn.dmi'
	item_state = "gas_alt"
	locked = /obj/item/implant/enforcer
	permeability_coefficient = 0
	flags_cover = MASKCOVERSEYES
	resistance_flags = FIRE_PROOF | ACID_PROOF

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
	armor = list(melee = 50, bullet = 15, laser = 50, energy = 10, bomb = 25, bio = 0, rad = 0)
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
	icon = 'icons/obj/weapons.dmi'
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
	flags = HEADCOVERSEYES | STOPSPRESSUREDMAGE | THICKMATERIAL
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEFACE
	resistance_flags = FIRE_PROOF | ACID_PROOF
	flags_inv = 0
	armor = list(melee = 70, bullet = 55, laser = 45, taser = 10, bomb = 25, bio = 10, rad = 0)
/*
* Perseus Helmet
*/

/obj/item/clothing/head/helmet/space/pershelmet
	name = "perseus security helmet"
	desc = "Standard issue to Perseus' specialist enforcer team."
	icon_state = "pershelmet"
	icon = 'icons/oldschool/perseus.dmi'
	alternate_worn_icon = 'icons/oldschool/perseus_worn.dmi'
	flags = THICKMATERIAL | STOPSPRESSUREDMAGE
	flags_cover = HEADCOVERSEYES
	flags_inv = HIDEFACE | HIDEHAIR
	armor = list(melee = 70, bullet = 55, laser = 45, taser = 10, bomb = 25, bio = 10, rad = 0)

/*
* Perseus Winter Coat
*/
/obj/item/clothing/suit/wintercoat/perseus
	name = "perseus winter coat"
	desc = "A coat that protects against the bitter cold."
	icon_state = "coatperc"
	icon = 'icons/oldschool/perseus.dmi'
	alternate_worn_icon = 'icons/oldschool/perseus_worn.dmi'

/obj/item/clothing/glasses/perseus
	name = "PercVision"
	desc = "A combination of thermals and nightvision."
	icon_state = "percnight"
	icon = 'icons/oldschool/perseus.dmi'
	alternate_worn_icon = 'icons/oldschool/perseus_worn.dmi'
	item_state = "glasses"
	origin_tech = "magnets=3"
	vision_flags = SEE_MOBS
	invis_view = 2
	flash_protect = 1
	darkness_view = 8
	invis_view = SEE_INVISIBLE_MINIMUM
