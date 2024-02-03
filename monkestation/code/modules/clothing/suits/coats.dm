// Winter Coat Varients

/obj/item/clothing/suit/hooded/wintercoat/cosmic
	name = "cosmic winter coat"
	desc = "A starry winter coat that even glows softly."
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/suit.dmi'
	icon_state = "coatcosmic"
	worn_icon_state = "coatcosmic"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/cosmic
	light_power = 1.8
	light_outer_range = 1.2

/obj/item/clothing/head/hooded/winterhood/cosmic
	desc = "A starry winter hood."
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "winterhood_cosmic"
	worn_icon_state = "winterhood_cosmic"

/obj/item/clothing/suit/hooded/wintercoat/ratvar
	name = "brass winter coat"
	desc = "A brass-plated button up winter coat. Instead of a zipper tab, it has a brass cog with a tiny red piece of plastic as an inset."
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/suit.dmi'
	icon_state = "coatratvar"
	worn_icon_state = "coatratvar"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/ratvar

/obj/item/clothing/head/hooded/winterhood/ratvar
	icon_state = "winterhood_ratvar"
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	desc = "A brass-plated winter hood to keep the cogs in the brain warm and turning."

/obj/item/clothing/suit/hooded/wintercoat/narsie
	name = "runed winter coat"
	desc = "A dusty button up winter coat in the tones of oblivion and ash. The zipper pull looks like a single drop of blood."
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/suit.dmi'
	icon_state = "coatnarsie"
	worn_icon_state = "coatnarsie"
	hoodtype = /obj/item/clothing/head/hooded/winterhood/narsie

/obj/item/clothing/head/hooded/winterhood/narsie
	desc = "A black winter hood to keep your blood warm and flowing."
	icon = 'monkestation/icons/obj/clothing/hats.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/head.dmi'
	icon_state = "winterhood_narsie"

// End Of Winter Coat Varients

// Costumes

/obj/item/clothing/suit/driscoll
	name = "driscoll poncho"
	desc = "Keeping you warm in the harsh cold of space."
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/suit.dmi'
	icon_state = "driscoll_suit"

/obj/item/clothing/suit/morningstar
	name = "morningstar coat"
	desc = "This coat costs more than you've ever made in your entire life."
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/suit.dmi'
	icon_state = "morningstar_suit"

/obj/item/clothing/suit/saints
	name = "Third Street Saints fur coat"
	desc = "Rated 10 out of 10 in Cosmo for best coat brand."
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/suit.dmi'
	icon_state = "saints_suit"

/obj/item/clothing/suit/phantom
	name = "phantom thief coat"
	desc = "Your foes will never see you coming in this stealthy yet stylish getup."
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/suit.dmi'
	icon_state = "phantom_suit"

// End Of Costume Stuff

// Other Coat Stuff

/obj/item/clothing/suit/heartcoat //ITS NOT A WINTER COAT, IT DOES NOT HAVE A HOOD
	name = "heart coat"
	desc = "A soft coat with a TailorCo brand on the tag."
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/suit.dmi'
	icon_state = "heartcoat"

/obj/item/clothing/suit/toggle/labcoat
	alternative_screams = list(	'monkestation/sound/voice/screams/misc/HL1 Scientist/scream_sci0.ogg',
								'monkestation/sound/voice/screams/misc/HL1 Scientist/scream_sci1.ogg',
								'monkestation/sound/voice/screams/misc/HL1 Scientist/scream_sci2.ogg')

/obj/item/clothing/suit/armor/guardmanvest
	name = "guardman's vest"
	desc = "It keeps your guts intact, thats really all that matters"
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	worn_icon = 'monkestation/icons/mob/clothing/suit.dmi'
	icon_state = "guardman_vest"


//Only basic and scientist labcoats get to STAPH

/obj/item/clothing/suit/toggle/labcoat/cmo
	alternative_screams = list()

/obj/item/clothing/suit/toggle/labcoat/emt
	alternative_screams = list()

/obj/item/clothing/suit/toggle/labcoat/brig_phys
	alternative_screams = list()

/obj/item/clothing/suit/toggle/labcoat/mad
	alternative_screams = list()

/obj/item/clothing/suit/toggle/labcoat/genetics
	alternative_screams = list()

/obj/item/clothing/suit/toggle/labcoat/chemist
	alternative_screams = list()

/obj/item/clothing/suit/toggle/labcoat/virologist
	alternative_screams = list()

// End of Coat stuff

// Sec Dusters

/obj/item/clothing/suit/armor/secduster
	name = "security duster"
	desc = "A standard-issue armored duster that keeps a security officer protected and fashionable."
	worn_icon = 'monkestation/icons/mob/suit.dmi'
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	icon_state = "cowboy_sec_default"
	var/obj/item/clothing/mask/breath/sec_bandana/mask
	var/obj/item/clothing/suit/armor/secduster/suit
	var/mask_adjusted = 0
	var/adjusted_flags = null
	var/masktype = /obj/item/clothing/mask/breath/sec_bandana
	actions_types = list(/datum/action/item_action/toggle_mask)

/obj/item/clothing/suit/armor/secduster/attack_self(mob/user)
	user.changeNext_move(CLICK_CD_MELEE)
	..()

/obj/item/clothing/suit/armor/secduster/Destroy()
	if(!QDELETED(suit))
		qdel(suit)
	suit = null
	return ..()

/obj/item/clothing/suit/armor/secduster/attack_self(mob/user)
	user.update_worn_mask()	//so our mob-overlays update
	for(var/X in actions)
		var/datum/action/A = X
		A.update_button_status()

/obj/item/clothing/suit/armor/secduster/dropped(mob/user)
	..()
	if(suit)
		suit.RemoveMask()

/obj/item/clothing/suit/armor/secduster/item_action_slot_check(slot)
	if(slot == ITEM_SLOT_OCLOTHING)
		return 1

//departmental sec colors
/obj/item/clothing/suit/armor/secduster/medical
	name = "medical security duster"
	icon_state = "cowboy_sec_medical"
	masktype = /obj/item/clothing/mask/breath/sec_bandana/medical

/obj/item/clothing/suit/armor/secduster/engineering
	name = "engineering security duster"
	icon_state = "cowboy_sec_engi"
	desc = "Duster? I hardly know 'er!"
	masktype = /obj/item/clothing/mask/breath/sec_bandana/engineering

/obj/item/clothing/suit/armor/secduster/cargo
	name = "cargo security duster"
	icon_state = "cowboy_sec_cargo"
	masktype = /obj/item/clothing/mask/breath/sec_bandana/cargo

/obj/item/clothing/suit/armor/secduster/science
	name = "science security duster"
	icon_state = "cowboy_sec_science"
	masktype = /obj/item/clothing/mask/breath/sec_bandana/science

//End of Sec Dusters

//Bunny costume Jackets

/obj/item/clothing/suit/jacket/tailcoat
	name = "tailcoat"
	desc = "A coat usually worn by bunny themed waiters and the like."
	worn_icon = 'monkestation/icons/mob/clothing/suit.dmi'
	icon = 'monkestation/icons/obj/clothing/suits.dmi'
	icon_state = "tailcoat"
	greyscale_colors = "#39393f"
	greyscale_config = /datum/greyscale_config/tailcoat
	greyscale_config_worn = /datum/greyscale_config/tailcoat_worn
	flags_1 = IS_PLAYER_COLORABLE_1


/obj/item/clothing/suit/jacket/tailcoat/syndicate
	name = "suspicious tailcoat"
	desc = "A oddly intimidating coat usually worn by bunny themed assassins. It's reinforced with some extremely flexible lightweight alloy. How much did they pay for this?"
	icon_state = "tailcoat_syndi"
	armor_type = /datum/armor/tailcoat_syndi
	greyscale_colors = null
	greyscale_config = null
	greyscale_config_worn = null


/datum/armor/tailcoat_syndi
	melee = 30
	bullet = 20
	laser = 30
	energy = 35
	fire = 20
	bomb = 15
	acid = 50
	wound = 5

/obj/item/clothing/suit/jacket/tailcoat/syndicate/Initialize(mapload)
	. = ..()
	allowed += list(
		/obj/item/ammo_box,
		/obj/item/ammo_casing,
		/obj/item/gun/ballistic,
		/obj/item/gun/energy,
		/obj/item/restraints/handcuffs,
		/obj/item/knife/combat,
		/obj/item/melee/baton,
	)

//End of Bunny Costume Jackets
