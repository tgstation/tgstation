




//lavaland_surface_seed_vault.dmm
//Seed Vault

/obj/effect/spawner/lootdrop/seed_vault
	name = "seed vault seeds"
	lootcount = 1

	loot = list(/obj/item/seeds/gatfruit = 10,
				/obj/item/seeds/cherryseed = 15,
				/obj/item/seeds/glowberryseed = 10,
				/obj/item/seeds/moonflowerseed = 8,
				)

/obj/effect/landmark/corpse/seed_vault
	name = "sleeper"
	mobname = "Vault Creature"
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	mob_species = /datum/species/pod
	flavour_text = {"You are a strange, artificial creature. In the face of impending apocalyptic events, your creators tasked you with maintaining an emergency seed vault. You are to tend to the plants and await their return to aid in rebuilding civilization. You've been waiting quite a while though..."}
