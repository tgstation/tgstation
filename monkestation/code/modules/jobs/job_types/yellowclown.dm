/datum/job/yellowclown
	title = JOB_SPOOKTOBER_YELLOWCLOWN
	description = "Team up with the regular clown, or start a rivalry! Search for ways to become EVEN MORE YELLOW."
	department_head = list(JOB_HEAD_OF_PERSONNEL)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = SUPERVISOR_HOP
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/yellowclown
	plasmaman_outfit = /datum/outfit/plasmaman/clown

	paycheck = PAYCHECK_CREW
	paycheck_department = ACCOUNT_SRV

	mind_traits = list(TRAIT_NAIVE)
	liver_traits = list(TRAIT_COMEDY_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_ASSISTANT
	departments_list = list(
		/datum/job_department/spooktober,
		)

	mail_goodies = list(
		/obj/item/food/grown/banana = 100,
		/obj/item/food/pie/cream = 50,
		/obj/item/clothing/shoes/clown_shoes/combat = 10,
		/obj/item/reagent_containers/spray/waterflower/lube = 20, // lube
		/obj/item/reagent_containers/spray/waterflower/superlube = 1 // Superlube, good lord.
	)

	family_heirlooms = list(/obj/item/bikehorn/golden)
	rpg_title = "Tow-Colored Jester"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN | JOB_SPOOKTOBER

	job_tone = "honk"


/datum/job/yellowclown/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	if(!ishuman(spawned))
		return
	spawned.apply_pref_name(/datum/preference/name/clown, player_client)
	var/obj/item/organ/internal/butt/butt = spawned.get_organ_slot(ORGAN_SLOT_BUTT)
	if(butt)
		butt.Remove(spawned, 1)
		QDEL_NULL(butt)
		butt = new/obj/item/organ/internal/butt/clown
		butt.Insert(spawned)

	var/obj/item/organ/internal/bladder/bladder = spawned.get_organ_slot(ORGAN_SLOT_BLADDER)
	if(bladder)
		bladder.Remove(spawned, 1)
		QDEL_NULL(bladder)
		bladder = new/obj/item/organ/internal/bladder/clown
		bladder.Insert(spawned)

/datum/outfit/job/yellowclown
	name = "Yellow Clown"
	jobtype = /datum/job/yellowclown

	id = /obj/item/card/id/advanced/rainbow
	id_trim = /datum/id_trim/job/clown
	uniform = /obj/item/clothing/under/rank/civilian/clown/yellow
	backpack_contents = list(
		/obj/item/stamp/clown = 1,
		/obj/item/reagent_containers/spray/waterflower = 1,
		/obj/item/food/grown/banana = 1,
		/obj/item/instrument/bikehorn = 1,
		)
	belt = /obj/item/modular_computer/pda/clown
	ears = /obj/item/radio/headset/headset_srv
	shoes = /obj/item/clothing/shoes/clown_shoes/yellow
	mask = /obj/item/clothing/mask/gas/clown_hat/yellow
	l_pocket = /obj/item/bikehorn

	backpack = /obj/item/storage/backpack/clown
	satchel = /obj/item/storage/backpack/clown
	duffelbag = /obj/item/storage/backpack/duffelbag/clown

	box = /obj/item/storage/box/survival/hug
	chameleon_extras = /obj/item/stamp/clown
	implants = list(/obj/item/implant/sad_trombone)

/datum/outfit/job/yellowclown/mod
	name = "Clown (MODsuit)"

	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/cosmohonk
	internals_slot = ITEM_SLOT_SUITSTORE

/datum/outfit/job/yellowclown/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_BANANIUM_SHIPMENTS))
		backpack_contents[/obj/item/stack/sheet/mineral/bananium/five] = 1

/datum/outfit/job/yellowclown/get_types_to_preload()
	. = ..()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_BANANIUM_SHIPMENTS))
		. += /obj/item/stack/sheet/mineral/bananium/five

/datum/outfit/job/yellowclown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	..()
	if(visualsOnly)
		return

	H.fully_replace_character_name(H.real_name, pick(GLOB.clown_names)) //rename the mob AFTER they're equipped so their ID gets updated properly.
	H.dna.add_mutation(/datum/mutation/human/clumsy)
	for(var/datum/mutation/human/clumsy/M in H.dna.mutations)
		M.mutadone_proof = TRUE
	var/datum/atom_hud/fan = GLOB.huds[DATA_HUD_FAN]
	fan.show_to(H)
	H.faction |= FACTION_CLOWN

