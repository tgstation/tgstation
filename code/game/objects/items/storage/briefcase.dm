/obj/item/storage/briefcase
	name = "briefcase"
	desc = "It's made of AUTHENTIC faux-leather and has a price-tag still attached. Its owner must be a real professional."
	icon = 'icons/obj/storage/case.dmi'
	icon_state = "briefcase"
	inhand_icon_state = "briefcase"
	lefthand_file = 'icons/mob/inhands/equipment/briefcase_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/briefcase_righthand.dmi'
	flags_1 = CONDUCT_1
	force = 8
	hitsound = SFX_SWING_HIT
	throw_speed = 2
	throw_range = 4
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("bashes", "batters", "bludgeons", "thrashes", "whacks")
	attack_verb_simple = list("bash", "batter", "bludgeon", "thrash", "whack")
	resistance_flags = FLAMMABLE
	max_integrity = 150
	var/folder_path = /obj/item/folder //this is the path of the folder that gets spawned in New()

/obj/item/storage/briefcase/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_NORMAL
	atom_storage.max_total_storage = 21

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

/obj/item/storage/briefcase/suicide_act(mob/living/user)
	var/list/papers_found = list()
	var/turf/item_loc = get_turf(src)

	if(!item_loc)
		return OXYLOSS

	for(var/obj/item/potentially_paper in contents)
		if(istype(potentially_paper, /obj/item/paper) || istype(potentially_paper, /obj/item/paperplane))
			papers_found += potentially_paper
	if(!papers_found.len || !item_loc)
		user.visible_message(span_suicide("[user] bashes [user.p_them()]self in the head with [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
		return BRUTELOSS

	user.visible_message(span_suicide("[user] opens [src] and all of [user.p_their()] papers fly out!"))
	for(var/obj/item/paper as anything in papers_found)	//Throws the papers in a random direction
		var/turf/turf_to_throw_at = prob(20) ? item_loc : get_ranged_target_turf(item_loc, pick(GLOB.alldirs))
		paper.throw_at(turf_to_throw_at, 2)

	stoplag(1 SECONDS)
	user.say("ARGGHH, HOW WILL I GET THIS WORK DONE NOW?!!")
	user.visible_message(span_suicide("[user] looks overwhelmed with paperwork! It looks like [user.p_theyre()] trying to commit suicide!"))
	return OXYLOSS

/obj/item/storage/briefcase/sniperbundle
	desc = "Its label reads \"genuine hardened Captain leather\", but suspiciously has no other tags or branding. Smells like L'Air du Temps."
	force = 10

/obj/item/storage/briefcase/sniperbundle/PopulateContents()
	..() // in case you need any paperwork done after your rampage
	new /obj/item/gun/ballistic/rifle/sniper_rifle/syndicate(src)
	new /obj/item/clothing/neck/tie/red/hitman(src)
	new /obj/item/clothing/under/syndicate/sniper(src)
	new /obj/item/ammo_box/magazine/sniper_rounds/disruptor(src)
	new /obj/item/ammo_box/magazine/sniper_rounds/disruptor(src)
	new /obj/item/suppressor(src)

/obj/item/storage/briefcase/mosincase
	name = "ancient gun case"
	desc = "A weapon's case. Has the symbol of the Third Soviet Union stamped on the side."
	icon_state = "mosin_case"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	inhand_icon_state = "mosin_case"


/obj/item/storage/briefcase/mosincase/Initialize(mapload)
	. = ..()
	atom_storage.max_specific_storage = WEIGHT_CLASS_BULKY
	atom_storage.max_total_storage = 7 //enough to hold ONE mosin and the ammo boxes
	atom_storage.max_slots = 4

/obj/item/storage/briefcase/mosincase/PopulateContents()
	var/gun_to_add
	var/ammo_to_add
	var/roll_them_bones = rand(1,100)
	switch(roll_them_bones)
		if(90-100)
			gun_to_add = /obj/item/gun/ballistic/rifle/boltaction
			ammo_to_add = /obj/item/ammo_box/a762
		if(2-89)
			gun_to_add = /obj/item/gun/ballistic/rifle/boltaction/surplus
			ammo_to_add = /obj/item/ammo_box/a762/surplus
		if(1)
			gun_to_add = /obj/item/food/rationpack //sorry comrade, took gun, here is ration as compensation
			ammo_to_add = /obj/item/food/rationpack //very sorry
	new gun_to_add (src)
	for(var/i in 1 to 3)
		new ammo_to_add(src)
