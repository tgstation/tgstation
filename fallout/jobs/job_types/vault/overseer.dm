datum/job/f13/vault/overseer
    title = "Vault Overseer"
    flag = OVERSEER
    total_positions = 1
	spawn_positions = 1
    description = "I am the vault"
    supervisor = "guh"

    outfit = /datum/outfit/job/overseer

/datum/outfit/job/overseer
    ..()
	name = "Vault Overseer"
	jobtype = /datum/job/f13/vault/overseer

/datum/outfit/job/overseer/pre_equip(mob/living/carbon/human/H)
	..()