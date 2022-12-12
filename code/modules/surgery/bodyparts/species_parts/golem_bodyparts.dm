/**
 * GOLEMS
 * THESE FUCKING SUCK SO GOD DAMN MUCH.
 * IDEALLY EVERY FUCKING GOLEM SUBTYPE SHOULD HAVE IT'S OWN BODYPARTS BUT **HOLY FUCK**
 * WOULD THAT BE A PAINFUL TASK.
 */
/obj/item/bodypart/head/golem
	name = "golem head"
	limb_id = SPECIES_GOLEM
	is_dimorphic = FALSE
	dmg_overlay_type = null

/obj/item/bodypart/chest/golem
	name = "golem chest"
	limb_id = SPECIES_GOLEM
	is_dimorphic = TRUE
	dmg_overlay_type = null
	bodypart_traits = list(TRAIT_NO_JUMPSUIT)

/obj/item/bodypart/arm/left/golem
	name = "golem left arm"
	limb_id = SPECIES_GOLEM
	dmg_overlay_type = null
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)
	unarmed_damage_low = 5 // I'd like to take the moment that maintaining all of these random ass golem speciese is hell and oranges was right
	unarmed_damage_high = 14
	unarmed_stun_threshold = 11

/obj/item/bodypart/arm/right/golem
	name = "golem right arm"
	limb_id = SPECIES_GOLEM
	dmg_overlay_type = null
	bodypart_traits = list(TRAIT_CHUNKYFINGERS)
	unarmed_damage_low = 5
	unarmed_damage_high = 14
	unarmed_stun_threshold = 11

/obj/item/bodypart/leg/left/golem
	name = "golem left leg"
	limb_id = SPECIES_GOLEM
	dmg_overlay_type = null
	unarmed_damage_low = 7
	unarmed_damage_high = 21
	unarmed_stun_threshold = 11

/obj/item/bodypart/leg/right/golem
	name = "golem right leg"
	limb_id = SPECIES_GOLEM
	dmg_overlay_type = null
	unarmed_damage_low = 7
	unarmed_damage_high = 21
	unarmed_stun_threshold = 11

/// CULT GOLEM
/obj/item/bodypart/head/golem/cult
	name = "cult golem head"
	limb_id = SPECIES_GOLEM_CULT
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/chest/golem/cult
	name = "cult golem chest"
	limb_id = SPECIES_GOLEM_CULT
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/golem/cult
	name = "cult golem left arm"
	limb_id = SPECIES_GOLEM_CULT
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/right/golem/cult
	name = "cult golem right arm"
	limb_id = SPECIES_GOLEM_CULT
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/left/golem/cult
	name = "cult golem left leg"
	limb_id = SPECIES_GOLEM_CULT
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right/golem/cult
	name = "cult golem right leg"
	limb_id = SPECIES_GOLEM_CULT
	should_draw_greyscale = FALSE

/// CLOTH GOLEM
/obj/item/bodypart/head/golem/cloth
	name = "cloth golem head"
	limb_id = SPECIES_GOLEM_CLOTH
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/chest/golem/cloth
	name = "cloth golem chest"
	limb_id = SPECIES_GOLEM_CLOTH
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/golem/cloth
	name = "cloth golem left arm"
	limb_id = SPECIES_GOLEM_CLOTH
	should_draw_greyscale = FALSE
	unarmed_damage_low = 4
	unarmed_stun_threshold = 7
	unarmed_damage_high = 8

/obj/item/bodypart/arm/right/golem/cloth
	name = "cloth golem right arm"
	limb_id = SPECIES_GOLEM_CLOTH
	should_draw_greyscale = FALSE
	unarmed_damage_low = 4
	unarmed_stun_threshold = 7
	unarmed_damage_high = 8

/obj/item/bodypart/leg/left/golem/cloth
	name = "cloth golem left leg"
	limb_id = SPECIES_GOLEM_CLOTH
	should_draw_greyscale = FALSE
	unarmed_damage_low = 6
	unarmed_stun_threshold = 7
	unarmed_damage_high = 12

/obj/item/bodypart/leg/right/golem/cloth
	name = "cloth golem right leg"
	limb_id = SPECIES_GOLEM_CLOTH
	should_draw_greyscale = FALSE
	unarmed_damage_low = 6
	unarmed_stun_threshold = 7
	unarmed_damage_high = 12

/// CARDBOARD GOLEM
/obj/item/bodypart/head/golem/cardboard
	name = "cardboard golem head"
	limb_id = SPECIES_GOLEM_CARDBOARD
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/chest/golem/cardboard
	name = "cardboard golem chest"
	limb_id = SPECIES_GOLEM_CARDBOARD
	is_dimorphic = TRUE
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/golem/cardboard
	name = "cardboard golem left arm"
	limb_id = SPECIES_GOLEM_CARDBOARD
	should_draw_greyscale = FALSE
	unarmed_attack_verb = "whip"
	unarmed_attack_sound = 'sound/weapons/whip.ogg'
	unarmed_miss_sound = 'sound/weapons/etherealmiss.ogg'
	unarmed_damage_low = 4
	unarmed_stun_threshold = 7
	unarmed_damage_high = 8

/obj/item/bodypart/arm/right/golem/cardboard
	name = "cardboard golem right arm"
	limb_id = SPECIES_GOLEM_CARDBOARD
	should_draw_greyscale = FALSE
	unarmed_attack_verb = "whip"
	unarmed_attack_sound = 'sound/weapons/whip.ogg'
	unarmed_miss_sound = 'sound/weapons/etherealmiss.ogg'
	unarmed_damage_low = 4
	unarmed_stun_threshold = 7
	unarmed_damage_high = 8

/obj/item/bodypart/leg/left/golem/cardboard
	name = "cardboard golem left leg"
	limb_id = SPECIES_GOLEM_CARDBOARD
	should_draw_greyscale = FALSE
	unarmed_attack_sound = 'sound/weapons/whip.ogg'
	unarmed_miss_sound = 'sound/weapons/etherealmiss.ogg'
	unarmed_damage_low = 6
	unarmed_stun_threshold = 7
	unarmed_damage_high = 12

/obj/item/bodypart/leg/right/golem/cardboard
	name = "cardboard golem right leg"
	limb_id = SPECIES_GOLEM_CARDBOARD
	should_draw_greyscale = FALSE
	unarmed_attack_sound = 'sound/weapons/whip.ogg'
	unarmed_miss_sound = 'sound/weapons/etherealmiss.ogg'
	unarmed_damage_low = 6
	unarmed_stun_threshold = 7
	unarmed_damage_high = 12

/// DURATHREAD GOLEM
/obj/item/bodypart/head/golem/durathread
	name = "durathread golem head"
	limb_id = SPECIES_GOLEM_DURATHREAD
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/chest/golem/durathread
	name = "durathread golem chest"
	limb_id = SPECIES_GOLEM_DURATHREAD
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/golem/durathread
	name = "durathread golem left arm"
	limb_id = SPECIES_GOLEM_DURATHREAD
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/right/golem/durathread
	name = "durathread golem right arm"
	limb_id = SPECIES_GOLEM_DURATHREAD
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/left/golem/durathread
	name = "durathread golem left leg"
	limb_id = SPECIES_GOLEM_DURATHREAD
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right/golem/durathread
	name = "durathread golem right leg"
	limb_id = SPECIES_GOLEM_DURATHREAD
	should_draw_greyscale = FALSE

/// BONE GOLEM
/obj/item/bodypart/head/golem/bone
	name = "bone golem head"
	limb_id = SPECIES_GOLEM_BONE
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/chest/golem/bone
	name = "bone golem chest"
	limb_id = SPECIES_GOLEM_BONE
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/golem/bone
	name = "bone golem left arm"
	limb_id = SPECIES_GOLEM_BONE
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/right/golem/bone
	name = "bone golem right arm"
	limb_id = SPECIES_GOLEM_BONE
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/left/golem/bone
	name = "bone golem left leg"
	limb_id = SPECIES_GOLEM_BONE
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right/golem/bone
	name = "bone golem right leg"
	limb_id = SPECIES_GOLEM_BONE
	should_draw_greyscale = FALSE

/// SNOW GOLEM
/obj/item/bodypart/head/golem/snow
	name = "snow golem head"
	limb_id = SPECIES_GOLEM_SNOW
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE

/obj/item/bodypart/chest/golem/snow
	name = "snow golem chest"
	limb_id = SPECIES_GOLEM_SNOW
	is_dimorphic = TRUE //WHO MADE SNOW BREASTS?
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/left/golem/snow
	name = "snow golem left arm"
	limb_id = SPECIES_GOLEM_SNOW
	should_draw_greyscale = FALSE

/obj/item/bodypart/arm/right/golem/snow
	name = "snow golem right arm"
	limb_id = SPECIES_GOLEM_SNOW
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/left/golem/snow
	name = "snow golem left leg"
	limb_id = SPECIES_GOLEM_SNOW
	should_draw_greyscale = FALSE

/obj/item/bodypart/leg/right/golem/snow
	name = "snow golem right leg"
	limb_id = SPECIES_GOLEM_SNOW
	should_draw_greyscale = FALSE

/// URANIUM GOLEM
/obj/item/bodypart/head/golem/uranium
	name = "uranium golem head"
	limb_id = SPECIES_GOLEM_URANIUM

/obj/item/bodypart/chest/golem/uranium
	name = "uranium golem chest"
	limb_id = SPECIES_GOLEM_URANIUM

/obj/item/bodypart/arm/left/golem/uranium
	name = "uranium golem left arm"
	limb_id = SPECIES_GOLEM_URANIUM
	attack_type = BURN
	unarmed_attack_verb = "burn"
	unarmed_attack_sound = 'sound/weapons/sear.ogg'
	unarmed_damage_low = 1
	unarmed_damage_high = 10
	unarmed_stun_threshold = 9

/obj/item/bodypart/arm/right/golem/uranium
	name = "uranium golem right arm"
	limb_id = SPECIES_GOLEM_URANIUM
	attack_type = BURN
	unarmed_attack_verb = "burn"
	unarmed_attack_sound = 'sound/weapons/sear.ogg'
	unarmed_damage_low = 1
	unarmed_damage_high = 10
	unarmed_stun_threshold = 9

/obj/item/bodypart/leg/left/golem/uranium
	name = "uranium golem left leg"
	limb_id = SPECIES_GOLEM_URANIUM
	attack_type = BURN
	unarmed_attack_sound = 'sound/weapons/sear.ogg'
	unarmed_damage_low = 2
	unarmed_damage_high = 15
	unarmed_stun_threshold = 9

/obj/item/bodypart/leg/right/golem/uranium
	name = "uranium golem right leg"
	limb_id = SPECIES_GOLEM_URANIUM
	attack_type = BURN
	unarmed_attack_sound = 'sound/weapons/sear.ogg'
	unarmed_damage_low = 2
	unarmed_damage_high = 15
	unarmed_stun_threshold = 9

/// PLASTEEL GOLEM
/obj/item/bodypart/head/golem/plasteel
	name = "plasteel golem head"
	limb_id = SPECIES_GOLEM_PLASTEEL

/obj/item/bodypart/chest/golem/plasteel
	name = "plasteel golem chest"
	limb_id = SPECIES_GOLEM_PLASTEEL

/obj/item/bodypart/arm/left/golem/plasteel
	name = "plasteel golem left arm"
	limb_id = SPECIES_GOLEM_PLASTEEL
	unarmed_attack_verb = "smash"
	unarmed_attack_effect = ATTACK_EFFECT_SMASH
	unarmed_attack_sound = 'sound/effects/meteorimpact.ogg' //hits pretty hard
	unarmed_damage_low = 12
	unarmed_damage_high = 21
	unarmed_stun_threshold = 18

/obj/item/bodypart/arm/right/golem/plasteel
	name = "plasteel golem right arm"
	limb_id = SPECIES_GOLEM_PLASTEEL
	unarmed_attack_verb = "smash"
	unarmed_attack_effect = ATTACK_EFFECT_SMASH
	unarmed_attack_sound = 'sound/effects/meteorimpact.ogg'
	unarmed_damage_low = 12
	unarmed_damage_high = 21
	unarmed_stun_threshold = 18

/obj/item/bodypart/leg/left/golem/plasteel
	name = "plasteel golem left leg"
	limb_id = SPECIES_GOLEM_PLASTEEL
	unarmed_attack_effect = ATTACK_EFFECT_SMASH
	unarmed_attack_sound = 'sound/effects/meteorimpact.ogg'
	unarmed_damage_low = 18
	unarmed_damage_high = 32
	unarmed_stun_threshold = 18

/obj/item/bodypart/leg/right/golem/plasteel
	name = "plasteel golem right leg"
	limb_id = SPECIES_GOLEM_PLASTEEL
	unarmed_attack_effect = ATTACK_EFFECT_SMASH
	unarmed_attack_sound = 'sound/effects/meteorimpact.ogg'
	unarmed_damage_low = 18
	unarmed_damage_high = 32
	unarmed_stun_threshold = 18

/// BANANIUM GOLEM
/obj/item/bodypart/head/golem/bananium
	name = "bananium golem head"
	limb_id = SPECIES_GOLEM_BANANIUM

/obj/item/bodypart/chest/golem/bananium
	name = "bananium golem chest"
	limb_id = SPECIES_GOLEM_BANANIUM

/obj/item/bodypart/arm/left/golem/bananium
	name = "bananium golem left arm"
	limb_id = SPECIES_GOLEM_BANANIUM
	unarmed_attack_verb = "honk"
	unarmed_attack_sound = 'sound/items/airhorn2.ogg'
	unarmed_damage_low = 0
	unarmed_damage_high = 1
	unarmed_stun_threshold = 2 //Harmless and can't stun

/obj/item/bodypart/arm/right/golem/bananium
	name = "bananium golem right arm"
	limb_id = SPECIES_GOLEM_BANANIUM
	unarmed_attack_verb = "honk"
	unarmed_attack_sound = 'sound/items/airhorn2.ogg'
	unarmed_damage_low = 0
	unarmed_damage_high = 1
	unarmed_stun_threshold = 2

/obj/item/bodypart/leg/left/golem/bananium
	name = "bananium golem left leg"
	limb_id = SPECIES_GOLEM_BANANIUM
	unarmed_attack_verb = "honk"
	unarmed_attack_sound = 'sound/items/airhorn2.ogg'
	unarmed_damage_low = 0
	unarmed_damage_high = 1
	unarmed_stun_threshold = 2

/obj/item/bodypart/leg/right/golem/bananium
	name = "bananium golem right leg"
	limb_id = SPECIES_GOLEM_BANANIUM
	unarmed_attack_verb = "honk"
	unarmed_attack_sound = 'sound/items/airhorn2.ogg'
	unarmed_damage_low = 0
	unarmed_damage_high = 1
	unarmed_stun_threshold = 2
