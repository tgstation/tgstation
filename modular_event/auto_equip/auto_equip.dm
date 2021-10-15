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
	for (var/vip in world.file2list(vip_file))
		vips += ckey(vip)

/mob/living/carbon/human/dress_up_as_job(datum/job/equipping, visual_only)
	dna.species.pre_equip_species_outfit(equipping, src, visual_only)

	if (!istype(equipping, SSjob.overflow_role))
		equipOutfit(equipping.outfit, visual_only)
		return

	var/ckey = ckey(mind?.key)
	var/team_outfit
	var/team_camo

	for (var/team_name in GLOB.tournament_teams)
		var/datum/tournament_team/tournament_team = GLOB.tournament_teams[team_name]

		if (ckey in tournament_team.roster)
			team_outfit = tournament_team.outfit
			team_camo = tournament_team.camo_placeholder
			break

	if (team_outfit)
		// Equip everything else *after* team stuff, so they have their backpacks still.
		equipInertOutfit(team_outfit, team_camo)

	if (ckey in SSauto_equip.vips)
		equipOutfit(/datum/outfit/job/vip, visual_only)
	else
		equipOutfit(equipping.outfit, visual_only)

/mob/living/carbon/human/proc/equipInertOutfit(datum/outfit/model_outfit, datum/outfit/camo_outfit, changeable = TRUE)
	camo_outfit.equip(src)

	// mostly copy pasta from chameleon_outfit/proc/select_outfit but a lot less restrictive
	var/list/outfit_parts = model_outfit.get_chameleon_disguise_info()
	for(var/V in chameleon_item_actions)
		var/datum/action/item_action/chameleon/change/change_action = V
		for(var/outfit_part in outfit_parts)
			if(ispath(outfit_part, change_action.chameleon_type))
				change_action.update_look(src, outfit_part)
				break
		var/atom/target = change_action.target
		// make the gear fully combat inert
		target.armor = new

	//hardsuit helmets/suit hoods
	if(model_outfit.toggle_helmet && (ispath(model_outfit.suit, /obj/item/clothing/suit/space/hardsuit) || ispath(model_outfit.suit, /obj/item/clothing/suit/hooded)))
		//make sure they are actually wearing the suit, not just holding it, and that they have a chameleon hat
		if(istype(wear_suit, /obj/item/clothing/suit/chameleon) && istype(head, /obj/item/clothing/head/chameleon))
			var/helmet_type
			if(ispath(model_outfit.suit, /obj/item/clothing/suit/space/hardsuit))
				var/obj/item/clothing/suit/space/hardsuit/hardsuit = model_outfit.suit
				helmet_type = initial(hardsuit.helmettype)
			else
				var/obj/item/clothing/suit/hooded/hooded = model_outfit.suit
				helmet_type = initial(hooded.hoodtype)

			if(helmet_type)
				var/obj/item/clothing/head/chameleon/hat = head
				hat.chameleon_action.update_look(src, helmet_type)

	if(!changeable)
		for(var/action in chameleon_item_actions)
			qdel(action) // we can't just QDEL_LIST instead because the Cut() will fail

/datum/outfit/job/vip
	name = "Donator"
	id = /obj/item/card/id/advanced/gold
	id_trim = /datum/id_trim/centcom/vip

	box = /obj/item/storage/box/tournament/vip
	backpack_contents = list(/obj/item/storage/box/syndie_kit/chameleon = 1)

	shoes = /obj/item/clothing/shoes/laceup
	head = /obj/item/clothing/head/bowler
	ears = /obj/item/radio/headset/headset_srv
	uniform = /obj/item/clothing/under/suit/black_really
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
	new /obj/item/clothing/glasses/hud/health(src)

/obj/item/clothing/accessory/medal/bronze_heart/donator
	name = "Donator medal"
	desc = "A medal for those who gave back to help a good cause."
