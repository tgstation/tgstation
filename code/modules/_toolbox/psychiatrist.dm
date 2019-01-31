#define ACCESS_PSYCHIATRIST 69
#define PSYCHIATRIST			(1<<14)

/obj/item/clothing/under/rank/psychiatrist
	desc = "It's a suit for a psychiatrist"
	name = "psychiatrist's suit"
	icon_state = "teal_suit"
	item_state = "g_suit"
	item_color = "teal_suit"
	can_adjust = 0

/obj/structure/closet/secure_closet/psychiatrist
	name = "enhanced therapy storage"
	req_access = list(ACCESS_PSYCHIATRIST)

/obj/structure/closet/secure_closet/psychiatrist/PopulateContents()
	new /obj/item/clothing/suit/straight_jacket (src)
	new /obj/item/clothing/suit/straight_jacket (src)
	new /obj/item/clothing/suit/straight_jacket (src)
	new /obj/item/clothing/mask/muzzle (src)
	new /obj/item/clothing/mask/muzzle (src)
	new /obj/item/clothing/mask/muzzle (src)
	new /obj/item/gun/syringe (src)
	new /obj/item/storage/box/syringes (src)
	new /obj/item/storage/box/syringes (src)
	new /obj/item/reagent_containers/glass/bottle/morphine (src)
	new /obj/item/reagent_containers/glass/bottle/morphine (src)
	new /obj/item/storage/pill_bottle/charcoal (src)
	new /obj/item/storage/pill_bottle/charcoal (src)


/obj/structure/closet/wardrobe/psychiatrist
	name = "psychiatry wardrobe"
	icon_door = "white"

/obj/structure/closet/wardrobe/psychiatrist/PopulateContents()
	new /obj/item/clothing/under/rank/psychiatrist (src)
	new /obj/item/clothing/under/rank/psychiatrist (src)
	new /obj/item/clothing/shoes/laceup (src)
	new /obj/item/clothing/shoes/laceup (src)
	new /obj/item/clothing/glasses/regular (src)
	new /obj/item/clothing/glasses/regular (src)
	new /obj/item/clothing/suit/toggle/labcoat (src)
	new /obj/item/clothing/suit/toggle/labcoat (src)

/obj/effect/landmark/start/psychiatrist
	name = "Psychiatrist"

/datum/outfit/job/psychiatrist
	name = "Psychiatrist"
	jobtype = /datum/job/psychiatrist

	ears = /obj/item/device/radio/headset/headset_med
	uniform = /obj/item/clothing/under/rank/psychiatrist
	shoes = /obj/item/clothing/shoes/laceup
	suit_store = /obj/item/device/flashlight/pen
	glasses = /obj/item/clothing/glasses/regular
	belt = /obj/item/device/pda/psychiatrist
	backpack = /obj/item/storage/backpack/satchel/leather
	satchel = /obj/item/storage/backpack/satchel/leather
	duffelbag = /obj/item/storage/backpack/satchel/leather
	backpack_contents = list(/obj/item/storage/box/psychiatrist=1,/obj/item/storage/box/psychiatrist/hard=1, /obj/item/paper/psychiatrist=1,/obj/item/clipboard=1)

/obj/item/device/pda/psychiatrist
	name = "psychiatry PDA"
	default_cartridge = /obj/item/cartridge/medical
	icon_state = "pda-genetics"

/obj/item/paper/psychiatrist
	name = "paper- 'Looneys 'n' You'"
	info = "<h1>Introduction</h1><p>Congratulations. After long hard years of training, seminars, and studies you have been selected to be the station's Psychiatrist! It's your job to \
	deal with the crazy, suicidal, mentally handicapped and otherwise disturbed members of this crew.</p>\
	<h1>Tools of the Trade</h1><p>Inside of your secure locker, you will find a <b>syringe gun</b> and some Morphine if things turn south. Your main tool of trade is <b>talk</b>, or \
	'psychotherapy' as a professional much like yourself would prefer to phrase it. Inside of your backpack you have two boxes: pharmacotherapy and psychopathology box. The first contains \
	lighter medication for those not-so-dire cases, whilst the other contains the serious stuff. Each pill bottle has its contets on the label, be sure to read it so as to not overdose your \
	patients. However, should that happen, you have two charcoal pill bottles in your secure locker. There are also some 'restraints' in there in case \
	your patients aren't being cooperative. Well, good luck!</p>"

/obj/item/storage/box/psychiatrist
	name = "pharmacotherapy box"
	desc = "It appears to contain common over the counter medication."
	illustration = "pillbox"

/obj/item/storage/box/psychiatrist/PopulateContents()
	new /obj/item/storage/pill_bottle/stimulant(src)
	new /obj/item/storage/pill_bottle/stimulant(src)
	new /obj/item/storage/pill_bottle/psychiatrist/sedative(src)
	new /obj/item/storage/pill_bottle/psychiatrist/sedative(src)
	new /obj/item/storage/pill_bottle/psychiatrist/sedative_hard (src)
	new /obj/item/storage/pill_bottle/synaptizine(src)
	new /obj/item/storage/pill_bottle/haloperidol(src)

/obj/item/storage/box/psychiatrist/hard
	name = "psychopathology box"
	desc = "I should probably be careful with these..."
	illustration = "pillbox"

/obj/item/storage/box/psychiatrist/hard/PopulateContents()
	new /obj/item/storage/pill_bottle/psychiatrist/xanax(src)
	new /obj/item/storage/pill_bottle/psychiatrist/xanax(src)
	new /obj/item/storage/pill_bottle/psychiatrist/pervitin(src)
	new /obj/item/storage/pill_bottle/psychiatrist/pervitin(src)
	new /obj/item/storage/pill_bottle/psychiatrist/psilocybin(src)
	new /obj/item/storage/pill_bottle/psychiatrist/psilocybin(src)
	new /obj/item/storage/pill_bottle/psychiatrist/lsd(src)

// space drugs, mindbreaker
/*
	psilocybin (mushroomhallucinogen)
*/
/obj/item/reagent_containers/pill/psychiatrist/psilocybin
	name = "psilocybin pill"
	desc = "A hallucinogen commonly found in certain mushroom cultures."
	icon_state = "pill20"
	list_reagents = list("mushroomhallucinogen" = 5)

/obj/item/storage/pill_bottle/psychiatrist/psilocybin
	name = "bottle of psilocybin pills"
	desc = "Pill contents: 5u Psilocybin"

/obj/item/storage/pill_bottle/psychiatrist/psilocybin/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/psychiatrist/psilocybin(src)


/*
	LSD (Mindbreaker Toxin)
*/
/obj/item/reagent_containers/pill/psychiatrist/lsd
	name = "lsd pill"
	desc = "At one point was used in clinical trials."
	icon_state = "pill15"
	list_reagents = list("mindbreaker" = 10)

/obj/item/storage/pill_bottle/psychiatrist/lsd
	name = "bottle of lsd pills"
	desc = "Pill contents: 10u Mindbreaker Toxin"

/obj/item/storage/pill_bottle/psychiatrist/lsd/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/psychiatrist/lsd(src)


/*
	Pervitin (Meth)
*/
/obj/item/reagent_containers/pill/psychiatrist/pervitin
	name = "pervitin pill"
	desc = "Commonly used as an ADHD treatment."
	icon_state = "pill0"
	list_reagents = list("methamphetamine" = 5, "mannitol"=5)

/obj/item/storage/pill_bottle/psychiatrist/pervitin
	name = "bottle of pervitin pills"
	desc = "Pill contents: 5u Methamphetamine, 5u Mannitol"

/obj/item/storage/pill_bottle/psychiatrist/pervitin/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/psychiatrist/pervitin(src)

/*
	Xanax
*/
/obj/item/reagent_containers/pill/psychiatrist/xanax
	name = "xanax pill"
	desc = "Helps calm the nerves."
	icon_state = "pill0"
	list_reagents = list("krokodil" = 10)

/obj/item/storage/pill_bottle/psychiatrist/xanax
	name = "bottle of xanax pills"
	desc = "Pill contents: 10u Krokodil"

/obj/item/storage/pill_bottle/psychiatrist/xanax/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/psychiatrist/xanax(src)

/*
	Light Sedatives
*/

/obj/item/reagent_containers/pill/psychiatrist/sedative
	name = "light sedative pill"
	desc = "Helps people with insomnia."
	icon_state = "pill3"
	list_reagents = list("morphine" = 10)

/obj/item/storage/pill_bottle/psychiatrist/sedative
	name = "bottle of light sedative pills"
	desc = "Pill contents: 10u Morphine"

/obj/item/storage/pill_bottle/psychiatrist/sedative/PopulateContents()
	for(var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/psychiatrist/sedative(src)

/*
	Hard Sedatives
*/

/obj/item/reagent_containers/pill/psychiatrist/sedative_hard
	name = "heavy sedative pill"
	desc = "Used to take someone down quickly."
	icon_state = "pill4"
	list_reagents = list("morphine" = 20, "chloralhydrate" = 10)

/obj/item/storage/pill_bottle/psychiatrist/sedative_hard
	name = "bottle of heavy sedative pills"
	desc = "Pill contents: 10u Chloral Hydrate, 20u Morphine"

/obj/item/storage/pill_bottle/psychiatrist/sedative_hard/PopulateContents()
	for (var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/psychiatrist/sedative_hard(src)

/*
	Synaptizine
*/

/obj/item/reagent_containers/pill/synaptizine
	name = "synaptizine pill (5u)"
	desc = "Helps Hallucinations go away much faster, and helps you recover from stuns faster. Also Purges Mindbreaker Toxin very quickly. Mildly toxic."
	icon_state = "pill7"
	list_reagents = list("synaptizine"=5)

/obj/item/storage/pill_bottle/synaptizine
	name = "bottle of synaptizine pills"
	desc = "Pill contents: 5u Synaptizine"

/obj/item/storage/pill_bottle/synaptizine/PopulateContents()
	for (var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/synaptizine(src)

/*
	Haloperidol
*/

/obj/item/reagent_containers/pill/haloperidol
	name = "haloperidol pill (5u)"
	desc = "Helps fight against the effects of most drugs, while purging them. However also causes drowsiness and stamina damage."
	icon_state = "pill15"
	list_reagents = list("haloperidol"=5)

/obj/item/storage/pill_bottle/haloperidol
	name = "bottle of haloperidol pills"
	desc = "Pill contents: 5u Haloperidol"

/obj/item/storage/pill_bottle/haloperidol/PopulateContents()
	for (var/i in 1 to 7)
		new /obj/item/reagent_containers/pill/haloperidol(src)


/datum/supply_pack/medical/psychiatrist
	name = "Psychiatric Care Crate"
	cost = 3000
	access = ACCESS_PSYCHIATRIST
	contains = list(/obj/item/storage/box/psychiatrist,/obj/item/storage/box/psychiatrist,/obj/item/storage/box/psychiatrist/hard,/obj/item/storage/box/psychiatrist/hard,/obj/item/paper/psychiatrist)
	crate_name = "psychiatric care crate"
	crate_type = /obj/structure/closet/crate/secure/plasma
	dangerous = TRUE

/datum/job/psychiatrist
	title = "Psychiatrist"
	flag = PSYCHIATRIST
	department_head = list("Chief Medical Officer")
	department_flag = MEDSCI
	faction = "Station"
	total_positions = 1
	spawn_positions = 1
	supervisors = "the chief medical officer"
	selection_color = "#ffeef0"
	exp_type = EXP_TYPE_CREW
	exp_requirements = 60
	antag_rep = 17

	outfit = /datum/outfit/job/psychiatrist

	access = list(ACCESS_MEDICAL, ACCESS_MORGUE, ACCESS_CHEMISTRY, ACCESS_CLONING, ACCESS_MINERAL_STOREROOM, ACCESS_PSYCHIATRIST)
	minimal_access = list(ACCESS_MEDICAL, ACCESS_PSYCHIATRIST)
	position_after_type = /datum/job/virologist

/area/medical/psychiatry
	name = "Psychiatry Office"
	icon_state = "patients"