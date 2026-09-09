/datum/outfit/syndicate/clownop
	name = "Clown Operative - Basic"
	uniform = /obj/item/clothing/under/syndicate
	shoes = /obj/item/clothing/shoes/clown_shoes/combat
	mask = /obj/item/clothing/mask/gas/clown_hat/clownops
	gloves = /obj/item/clothing/gloves/combat
	back = /obj/item/storage/backpack/clown
	ears = /obj/item/radio/headset/syndicate/alt
	l_pocket = /obj/item/modular_computer/pda/nukeops
	r_pocket = /obj/item/bikehorn
	id = /obj/item/card/id/advanced/chameleon/elite
	backpack_contents = list(
		/obj/item/gun/ballistic/automatic/pistol/toy/riot/clandestine = 1, //The clown op equivalent to the Ansem
		/obj/item/reagent_containers/spray/waterflower/lube/super = 1,
		/obj/item/mod/skin_applier/honkerative = 1,
	)
	box = /obj/item/storage/box/survival/syndie
	implants = list(/obj/item/implant/sad_trombone, /obj/item/implant/tacmap/nuclear)

	uplink_type = /obj/item/uplink/clownop

	id_trim = /datum/id_trim/chameleon/operative/clown

/datum/outfit/syndicate/clownop/post_equip(mob/living/carbon/human/nukie, visuals_only)
	. = ..()
	var/obj/item/gun/ballistic/automatic/pistol/toy/riot/clandestine/gun = locate() in back
	if(!isnull(gun))
		qdel(gun.pin)
		var/obj/item/firing_pin/clown/ultra/new_pin = new()
		new_pin.gun_insert(null, gun, TRUE)

	nukie.dna.add_mutation(/datum/mutation/clumsy, MUTATION_SOURCE_MUTATOR)

/datum/outfit/syndicate/clownop/no_crystals
	name = "Clown Operative - Reinforcement"
	tc = 0

/datum/outfit/syndicate/clownop/leader
	name = "Clown Operative Leader - Basic"
	command_radio = TRUE

	id_trim = /datum/id_trim/chameleon/operative/clown_leader
	implants = list(/obj/item/implant/sad_trombone, /obj/item/implant/tacmap/nuclear/leader)
