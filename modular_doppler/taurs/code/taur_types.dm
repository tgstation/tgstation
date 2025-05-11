/datum/sprite_accessory/taur
	icon = 'modular_doppler/taurs/icons/taur.dmi'
	dimension_x = 64
	center = TRUE
	/// The taur organ we will insert.
	var/obj/item/organ/organ_type = /obj/item/organ/taur_body/quadruped // quadruped by default, dont forget to override if you make another bodytype
	/// The primary layer of our body - most bodies use ADJ, but some use FRONT. Used for prefs rendering.
	var/primary_layer = "ADJ"

/datum/sprite_accessory/taur/deer
	name = "Deer"
	icon_state = "deer"
	organ_type = /obj/item/organ/taur_body/quadruped/deer

/datum/sprite_accessory/taur/tarantula
	name = "Tarantula"
	icon_state = "tarantula"
	organ_type = /obj/item/organ/taur_body/spider

/datum/sprite_accessory/taur/naga
	name = "Naga"
	icon_state = "naga"
	organ_type = /obj/item/organ/taur_body/serpentine

/datum/sprite_accessory/taur/naga/striped
	name = "Naga, Striped"
	icon_state = "naga_striped"

/datum/sprite_accessory/taur/naga/rattle
	name = "Naga, Rattle"
	icon_state = "nagarattle"

/datum/sprite_accessory/taur/tentacle
	name = "Tentacle"
	icon_state = "tentaclealt"
	organ_type = /obj/item/organ/taur_body/tentacle
	primary_layer = "FRONT"

/datum/sprite_accessory/taur/canine
	name = "Canine"
	icon_state = "canine"
	organ_type = /obj/item/organ/taur_body/quadruped/paw

/datum/sprite_accessory/taur/feline
	name = "Feline"
	icon_state = "feline"
	organ_type = /obj/item/organ/taur_body/quadruped/paw

/datum/sprite_accessory/taur/synthfeline
	name = "Cybernetic Feline"
	icon_state = "synthfeline"
	organ_type = /obj/item/organ/taur_body/quadruped/paw/synth

/datum/sprite_accessory/taur/synthwolf
	name = "Cybernetic Wolf"
	icon_state = "synthwolf"
	organ_type = /obj/item/organ/taur_body/quadruped/synth

/datum/sprite_accessory/taur/synthnaga
	name = "Cybernetic Naga"
	icon_state = "synthnaga"
	organ_type = /obj/item/organ/taur_body/serpentine/synth

/datum/sprite_accessory/taur/biglegs
	name = "Big Legs"
	icon_state = "biglegs"
	organ_type = /obj/item/organ/taur_body/anthro

/datum/sprite_accessory/taur/biglegs/stanced
	name = "Big Legs, Stanced"
	icon_state = "biglegs_stanced"

/datum/sprite_accessory/taur/biglegs/bird
	name = "Big Legs, Bird"
	icon_state = "biglegs_bird"

/datum/sprite_accessory/taur/biglegs/stanced/bird
	name = "Big Legs, Stanced Bird"
	icon_state = "biglegs_bird_stanced"

/datum/sprite_accessory/taur/biglegs/peg
	name = "Big Legs, Pegs"
	icon_state = "biglegs_peg"

/datum/sprite_accessory/taur/biglegs/stanced/peg
	name = "Big Legs, Stanced Pegs"
	icon_state = "biglegs_peg_stanced"
