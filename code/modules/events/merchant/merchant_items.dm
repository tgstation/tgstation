///This file is for merchant sold items that don't really have a better file to be in, or should be together to be found easier.

/**
 * ## silicon sentience chip!
 *
 * Only sold by the special robot trader, makes a robot sentient
 */
/obj/item/silicon_sentience
	name = "silicon sentience chip"
	desc = "Can be used to grant sentience to robots."
	icon_state = "sentience_chip"
	icon = 'icons/obj/module.dmi'

/obj/item/silicon_sentience/Initialize()
	. = ..()
	AddComponent(/datum/component/sentience_granter, SENTIENCE_ARTIFICIAL)

/**
 * ## LFLINE pack!
 *
 * Only sold by the special robot trader, LFLINE bulks you down but gives you the momento mori effect
 */
/obj/item/lfline
	name = "LFLINE pack"
	desc = "You wear this on your back, let it plug into your organs... and you're invincible! Allegedly."
	icon_state = "backpack"
	inhand_icon_state = "backpack"
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	resistance_flags = NONE
	max_integrity = 150

/// pirate merchant weapons (you can trade in your lasers for these) ///

/**
 * ## SKINSHEDDR
 *
 * Weapon that fires an embedding spikeball that actively rips apart the limb it is attached to
 */
/obj/item/gun/ballistic/rifle/boltaction/skinsheddr
	name = "SKINSHEDDR"
	desc = "A junkyard weapon used by pirates for its brutality, leading to quick submission of cargo. \
	Fires spikeballs that activate upon hitting a victim, shredding their limb apart."
	icon_state = "speargun"
	inhand_icon_state = "speargun"
	worn_icon_state = "speargun"
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/spikeball
	fire_sound = 'sound/weapons/gun/sniper/shot.ogg'
	can_be_sawn_off = FALSE
	can_jam = FALSE

/obj/item/ammo_box/magazine/internal/boltaction/spikeball
	max_ammo = 1
	caliber = CALIBER_SPIKEBALL
	ammo_type = /obj/item/ammo_casing/caseless/spikeball

/obj/item/ammo_casing/caseless/spikeball
	name = "spikeball"
	caliber = CALIBER_SPIKEBALL
	icon_state = "magspear"
	projectile_type = /obj/projectile/bullet/spikeball

///This projectile embeds into mobs, but has no special effects
/obj/projectile/scrapball
	name = "scrapball"
	icon_state = "glob_projectile"
	shrapnel_type = /obj/item/scrapball
	embedding = list("embed_chance" = 100, ignore_throwspeed_threshold = TRUE, "pain_mult" = 0, "jostle_pain_mult" = 0, "fall chance" = 0.5)
	nodamage = TRUE
	damage = 0

/obj/item/scrapball
	name = "scrapball"
	desc = "A bunch of metal scrap hammered into a spikey ball. Worrysome!"
	icon = 'icons/obj/xenobiology/vatgrowing.dmi'
	icon_state = "globule"
	embedding = list("pain_mult" = 4, "embed_chance" = 100, "fall_chance" = 0.4)

///This item is what is embedded into the mob, and actually handles healing of mending globules
/obj/item/sheddrball
	name = "SHEDDRball"
	desc = "A semicomplicated chunk of spinning blades that digs into the flesh of a victim and tears the limb apart."
	icon = 'icons/obj/xenobiology/vatgrowing.dmi'
	icon_state = "globule"
	embedding = list("embed_chance" = 100, ignore_throwspeed_threshold = TRUE, "pain_mult" = 0, "jostle_pain_mult" = 0, "fall chance" = 0.1)
	var/obj/item/bodypart/bodypart
	var/heals_left = 35

/obj/item/mending_globule/Destroy()
	. = ..()
	bodypart = null

/obj/item/mending_globule/embedded(mob/living/carbon/human/embedded_mob, obj/item/bodypart/part)
	. = ..()
	if(!istype(part))
		return
	bodypart = part
	START_PROCESSING(SSobj, src)

/obj/item/mending_globule/unembedded()
	. = ..()
	bodypart = null
	STOP_PROCESSING(SSobj, src)

///Handles the healing of the mending globule
/obj/item/mending_globule/process()
	if(!bodypart) //this is fucked
		return FALSE
	bodypart.heal_damage(1,1)
	heals_left--
	if(heals_left <= 0)
		qdel(src)

