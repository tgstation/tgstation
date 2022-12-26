/obj/item/storage/box/disks_nanite
	name = "nanite program disks box"
	illustration = "disk_kit"

/obj/item/storage/box/disks_nanite/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/disk/nanite_program(src)

//Names are intentionally all the same - track your nanites, or use a hand labeler
//This also means that you can give flesh melting nanites to your victims if you feel like it

/obj/item/disk/nanite_program
	name = "nanite program disk"
	desc = "A disk capable of storing nanite programs. Can be customized using a Nanite Programming Console."
	icon = 'voidcrew/modules/nanites/icons/diskette.dmi'
	icon_state = "nanite"

	///Typepath of the program on the disk. If set, this will be the path added in initialize.
	var/datum/nanite_program/program

/obj/item/disk/nanite_program/Initialize(mapload)
	. = ..()
	if(program)
		program = new program

/obj/item/disk/nanite_program/aggressive_replication
	program = /datum/nanite_program/aggressive_replication

/obj/item/disk/nanite_program/metabolic_synthesis
	program = /datum/nanite_program/metabolic_synthesis

/obj/item/disk/nanite_program/viral
	program = /datum/nanite_program/viral

/obj/item/disk/nanite_program/meltdown
	program = /datum/nanite_program/meltdown

/obj/item/disk/nanite_program/monitoring
	program = /datum/nanite_program/monitoring

/obj/item/disk/nanite_program/relay
	program = /datum/nanite_program/relay

/obj/item/disk/nanite_program/emp
	program = /datum/nanite_program/emp

/obj/item/disk/nanite_program/spreading
	program = /datum/nanite_program/spreading

/obj/item/disk/nanite_program/regenerative
	program = /datum/nanite_program/regenerative

/obj/item/disk/nanite_program/regenerative_advanced
	program = /datum/nanite_program/regenerative_advanced

/obj/item/disk/nanite_program/temperature
	program = /datum/nanite_program/temperature

/obj/item/disk/nanite_program/purging
	program = /datum/nanite_program/purging

/obj/item/disk/nanite_program/purging_advanced
	program = /datum/nanite_program/purging_advanced

/obj/item/disk/nanite_program/brain_heal
	program = /datum/nanite_program/brain_heal

/obj/item/disk/nanite_program/brain_heal_advanced
	program = /datum/nanite_program/brain_heal_advanced

/obj/item/disk/nanite_program/blood_restoring
	program = /datum/nanite_program/blood_restoring

/obj/item/disk/nanite_program/repairing
	program = /datum/nanite_program/repairing

/obj/item/disk/nanite_program/nervous
	program = /datum/nanite_program/nervous

/obj/item/disk/nanite_program/hardening
	program = /datum/nanite_program/hardening

/obj/item/disk/nanite_program/coagulating
	program = /datum/nanite_program/coagulating

/obj/item/disk/nanite_program/necrotic
	program = /datum/nanite_program/necrotic

/obj/item/disk/nanite_program/brain_decay
	program = /datum/nanite_program/brain_decay

/obj/item/disk/nanite_program/pyro
	program = /datum/nanite_program/pyro

/obj/item/disk/nanite_program/cryo
	program = /datum/nanite_program/cryo

/obj/item/disk/nanite_program/toxic
	program = /datum/nanite_program/toxic

/obj/item/disk/nanite_program/suffocating
	program = /datum/nanite_program/suffocating

/obj/item/disk/nanite_program/heart_stop
	program = /datum/nanite_program/heart_stop

/obj/item/disk/nanite_program/explosive
	program = /datum/nanite_program/explosive

/obj/item/disk/nanite_program/shock
	program = /datum/nanite_program/shocking

/obj/item/disk/nanite_program/sleepy
	program = /datum/nanite_program/sleepy

/obj/item/disk/nanite_program/paralyzing
	program = /datum/nanite_program/paralyzing

/obj/item/disk/nanite_program/fake_death
	program = /datum/nanite_program/fake_death

/obj/item/disk/nanite_program/pacifying
	program = /datum/nanite_program/pacifying

/obj/item/disk/nanite_program/glitch
	program = /datum/nanite_program/glitch

/obj/item/disk/nanite_program/brain_misfire
	program = /datum/nanite_program/pacifying

/obj/item/disk/nanite_program/skin_decay
	program = /datum/nanite_program/pacifying

/obj/item/disk/nanite_program/nerve_decay
	program = /datum/nanite_program/pacifying

/obj/item/disk/nanite_program/refractive
	program = /datum/nanite_program/refractive

/obj/item/disk/nanite_program/conductive
	program = /datum/nanite_program/pacifying

/obj/item/disk/nanite_program/stun
	program = /datum/nanite_program/stun
