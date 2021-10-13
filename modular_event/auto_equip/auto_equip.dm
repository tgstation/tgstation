/// Automatically equips the VIP outfit for donators (as well as the trait), and those in tournament teams
SUBSYSTEM_DEF(auto_equip)
	name = "Event - Auto-equipment"
	flags = SS_NO_FIRE

	var/list/vips = list()

/datum/controller/subsystem/auto_equip/Initialize(start_timeofday)
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, .proc/on_job_after_spawn)

	return ..()

/datum/controller/subsystem/auto_equip/proc/on_job_after_spawn(datum/source, mob/living/spawned, client/client)
	SIGNAL_HANDLER

	if (!(client?.ckey in vips))
		return

	ADD_TRAIT(spawned, TRAIT_VIP, "[type]")

/datum/controller/subsystem/auto_equip/OnConfigLoad()
	vips.Cut()

	var/vip_file = "[config.directory]/vips.txt"
	if (!fexists(vip_file))
		log_config("Couldn't load vips.txt")
		message_admins("Couldn't load vips.txt")

		return

	log_config("Loading vips.txt")
	vips = world.file2list(vip_file)

/mob/living/carbon/human/dress_up_as_job(datum/job/equipping, visual_only)
	dna.species.pre_equip_species_outfit(equipping, src, visual_only)

	if (!istype(equipping, SSjob.overflow_role))
		equipOutfit(equipping.outfit, visual_only)
		return

	var/ckey = ckey(mind?.key)
	var/team_outfit

	for (var/team_name in GLOB.tournament_teams)
		var/datum/tournament_team/tournament_team = GLOB.tournament_teams[team_name]

		if (ckey in tournament_team.roster)
			team_outfit = tournament_team.outfit
			break

	if (team_outfit)
		// Equip everything else *after* team stuff, so they have their backpacks still.
		equipOutfit(team_outfit, visual_only)

	if (ckey in SSauto_equip.vips)
		equipOutfit(/datum/outfit/job/vip, visual_only)
	else
		equipOutfit(equipping.outfit, visual_only)

/datum/outfit/job/vip
	name = "Donator"
	box = /obj/item/storage/box/tournament/vip
	backpack_contents = list(/obj/item/storage/box/syndie_kit/chameleon = 1)

	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/bowler
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/suit/black_really
	glasses = /obj/item/clothing/glasses/hud/health
	gloves = /obj/item/clothing/gloves/color/white

// Tournament box
/obj/item/storage/box/tournament/PopulateContents()
	new /obj/item/clothing/mask/breath(src)

	if(!isplasmaman(loc))
		new /obj/item/tank/internals/emergency_oxygen(src)
	else
		new /obj/item/tank/internals/plasmaman/belt(src)

	new /obj/item/cowbell(src)
	new /obj/item/binoculars(src)
	new /obj/item/teleportation_scroll(src)

/obj/item/storage/box/tournament/vip/PopulateContents()
	..()

	new /obj/item/clothing/accessory/medal/bronze_heart/donator(src)

/obj/item/clothing/accessory/medal/bronze_heart/donator
	name = "Donator medal"
	desc = "A medal for those who gave back to help a good cause."
