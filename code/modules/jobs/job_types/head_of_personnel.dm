/datum/job/head_of_personnel
	title = JOB_HEAD_OF_PERSONNEL
	description = "Alter access on ID cards, manage civil and supply departments, \
		protect Ian, run the station when the captain dies."
	auto_deadmin_role_flags = DEADMIN_POSITION_HEAD
	department_head = list(JOB_CAPTAIN)
	head_announce = list(RADIO_CHANNEL_SERVICE)
	faction = FACTION_STATION
	total_positions = 1
	spawn_positions = 1
	supervisors = SUPERVISOR_HOP
	selection_color = "#ddddff"
	req_admin_notify = 1
	minimal_player_age = 10
	exp_requirements = 180
	exp_required_type = EXP_TYPE_CREW
	exp_required_type_department = EXP_TYPE_SERVICE
	exp_granted_type = EXP_TYPE_CREW

	outfit = /datum/outfit/job/hop
	plasmaman_outfit = /datum/outfit/plasmaman/head_of_personnel
	departments_list = list(
		/datum/job_department/service,
		/datum/job_department/command,
		)

	paycheck = PAYCHECK_COMMAND
	paycheck_department = ACCOUNT_SRV
	bounty_types = CIV_JOB_RANDOM

	liver_traits = list(TRAIT_ROYAL_METABOLISM)

	display_order = JOB_DISPLAY_ORDER_HEAD_OF_PERSONNEL

	mail_goodies = list(
		/obj/item/card/id/advanced/silver = 10,
		/obj/item/stack/sheet/bone = 5
	)

	family_heirlooms = list(/obj/item/reagent_containers/food/drinks/trophy/silver_cup)
	rpg_title = "Guild Questgiver"
	job_flags = JOB_ANNOUNCE_ARRIVAL | JOB_CREW_MANIFEST | JOB_EQUIP_RANK | JOB_CREW_MEMBER | JOB_NEW_PLAYER_JOINABLE | JOB_BOLD_SELECT_TEXT | JOB_REOPEN_ON_ROUNDSTART_LOSS | JOB_ASSIGN_QUIRKS | JOB_CAN_BE_INTERN

	voice_of_god_power = 1.4 //Command staff has authority


/datum/job/head_of_personnel/get_captaincy_announcement(mob/living/captain)
	return "Due to staffing shortages, newly promoted Acting Captain [captain.real_name] on deck!"


/datum/outfit/job/hop
	name = "Head of Personnel"
	jobtype = /datum/job/head_of_personnel

	id = /obj/item/card/id/advanced/silver
	id_trim = /datum/id_trim/job/head_of_personnel
	uniform = /obj/item/clothing/under/rank/civilian/head_of_personnel
	backpack_contents = list(
		/obj/item/melee/baton/telescopic = 1,
		/obj/item/storage/box/ids = 1,
		)
	belt = /obj/item/modular_computer/tablet/pda/heads/hop
	ears = /obj/item/radio/headset/heads/hop
	head = /obj/item/clothing/head/hopcap
	shoes = /obj/item/clothing/shoes/laceup
	suit = /obj/item/clothing/suit/armor/vest/hop

	chameleon_extras = list(
		/obj/item/gun/energy/e_gun,
		/obj/item/stamp/hop,
		)

/datum/outfit/job/hop/pre_equip(mob/living/carbon/human/H)
	..()
	if(locate(/datum/holiday/ianbirthday) in SSevents.holidays)
		undershirt = /datum/sprite_accessory/undershirt/ian

//only pet worth reviving
/datum/job/head_of_personnel/get_mail_goodies(mob/recipient)
	. = ..()
	// Strange Reagent if the pet is dead.
	for(var/mob/living/simple_animal/pet/dog/corgi/ian/staff_pet in GLOB.dead_mob_list)
		. += list(/datum/reagent/medicine/strange_reagent = 20)
		break

/obj/item/paper/fluff/ids_for_dummies
	name = "Memo: New IDs and You"
	desc = "It looks like this was left by the last Head of Personnel to man this station. It explains some information about new IDs."
	default_raw_text = {"
<h1>Dummy's Guide To New IDs</h1>
<h2>The Basics</h2>
<p>Card Trim - This is the job assigned to the card. The card's trim decides what Basic accesses the card can hold. Basic accesses cost nothing! Grey ID cards cannot hold Head of Staff or Captain trims. Silver ID cards can hold Head of Staff trims but not Captain trims and are in a box in the Head of Personnel's office and orderable from cargo. Gold ID cards can hold all access. The only guaranteed Gold ID card is the Captain's Spare, held in a golden safe on the bridge with access codes given to the station's highest ranking officer. All other gold ID cards are carried exclusively by Captains.</p>
<p>Wildcards - These are any additional accesses a card has that are not part of the card's trim. Lower quality ID cards have fewer wildcards and the wildcards they do have are of lower rarity.</p>
<p>Job Changes - To change a job, you need to go to the PDA & ID Painter that's in every Head of Personnel office. This can be used to apply a new trim to an ID card, but this will wipe all that card's accesses in the process. You then take this ID card to any modular computer with the Plexagon Access Management app and when logged in with the appropriate Head of Staff or ID Console access can then select from Templates to quick-fill accesses or apply them manually.</p>
<p>Firing Staff - Terminating a staff member's employment will wipe any trim from their card, remove all access and instantly set them as demoted.</p>
<h2>Changing Jobs - Step by Step</h2>
<ol>
<li>Grab an appropriate ID card. Head of Staff jobs require a silver ID card. Captain requires a gold ID card.</li>
<li>Insert the ID card into the combined PDA Painter and ID Trimmer in the HoP office.</li>
<li>Select to appropriate trim then hit the button to apply it to the card. This will wipe all the card's access.</li>
<li>Remove the ID from the PDA/ID Painter and open up any modular computer with the Plexagon Access Management application downloaded.</li>
<li>Login to the app using an ID card with any Head of Staff private office access for limited access or the ID Console access for unlimited access.</li>
<li>Select a template from the drop-down. This will apply as many <b>basic</b> accesses as possible based on the trim of the ID card and may apply wildcard accesses for Head of Staff and Captain trims. For best results, match the template to the ID card's trim.</li>
<li>Manually tweak any other accesses as necessary. Add wildcard accesses. Tweak basic accesses.</li>
<li>Don't forget to set a custom occupation! SecHUDs now interface direct with the ID card's trim and display the trim's job icon even when a custom assignment is set.</li>
</ol>
	"}
