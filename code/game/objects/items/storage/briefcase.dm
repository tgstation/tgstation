/obj/item/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon_state = "briefcase"
	lefthand_file = 'icons/mob/inhands/equipment/briefcase_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/briefcase_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 8
	hitsound = "swing_hit"
	throw_speed = 2
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("bashes", "batters", "bludgeons", "thrashes", "whacks")
	attack_verb_simple = list("bash", "batter", "bludgeon", "thrash", "whack")
	resistance_flags = FLAMMABLE
	max_integrity = 150
	var/folder_path = /obj/item/folder //this is the path of the folder that gets spawned in New()

/obj/item/storage/briefcase/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_w_class = WEIGHT_CLASS_NORMAL
	STR.max_combined_w_class = 21

/obj/item/storage/briefcase/PopulateContents()
	new /obj/item/pen(src)
	var/obj/item/folder/folder = new folder_path(src)
	for(var/i in 1 to 6)
		new /obj/item/paper(folder)

/obj/item/storage/briefcase/lawyer
	folder_path = /obj/item/folder/blue

/obj/item/storage/briefcase/lawyer/PopulateContents()
	new /obj/item/stamp/law(src)
	..()

/obj/item/storage/briefcase/sniperbundle
	desc = "Its label reads \"genuine hardened Captain leather\", but suspiciously has no other tags or branding. Smells like L'Air du Temps."
	force = 10

/obj/item/storage/briefcase/sniperbundle/PopulateContents()
	..() // in case you need any paperwork done after your rampage
	new /obj/item/gun/ballistic/automatic/sniper_rifle/syndicate(src)
	new /obj/item/clothing/neck/tie/red(src)
	new /obj/item/clothing/under/syndicate/sniper(src)
	new /obj/item/ammo_box/magazine/sniper_rounds/soporific(src)
	new /obj/item/ammo_box/magazine/sniper_rounds/soporific(src)
	new /obj/item/suppressor/specialoffer(src)

/obj/item/storage/briefcase/case
	name = "case"
	icon_state = "case"
	force = 2
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/storage/briefcase/case/lobotomy
	name = "lobotomy kit"

/obj/item/storage/briefcase/case/lobotomy/PopulateContents()
	new /obj/item/surgical_drapes(src)
	new /obj/item/orbitoclast(src)
	new /obj/item/hammer(src)
	new /obj/item/cautery(src)
	new /obj/item/reagent_containers/glass/bottle/morphine(src)
	new /obj/item/paper/guides/lobotomy(src)
	new /obj/item/healthanalyzer(src)

/obj/item/paper/guides/lobotomy
	name = "Lobotomies For Dummies"
	info = "Doing a Lobotomy is easy.<br> Target the eyes, use your drapes, orbitoclast, hammer, orbitoclast, then finish off with a cautery.<br> However, to retrieve special powers from this is a little harder.<br> You must fail the lobotomizing step (second orbitoclast) to cause some traumas.<br> If these traumas are too bad, do the step correctly (Removes Severe Traumas by just cutting off more of the Brain) then fail it again.<br> To fail a step on purpose, you must be on disarm intent."
