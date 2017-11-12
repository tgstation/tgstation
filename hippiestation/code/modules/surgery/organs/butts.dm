/obj/item/organ/butt
	name = "butt"
	desc = "extremely treasured body part"
	alternate_worn_icon = 'hippiestation/icons/mob/head.dmi'
	icon = 'hippiestation/icons/obj/butts.dmi'
	icon_state = "butt"
	item_state = "butt"
	zone = "groin"
	slot = "butt"
	throwforce = 5
	throw_speed = 4
	force = 5
	hitsound = 'hippiestation/sound/effects/fart.ogg'
	body_parts_covered = HEAD
	slot_flags = SLOT_HEAD
	embed_chance = 5 //This is a joke
	var/loose = 0
	var/max_combined_w_class = 3
	var/max_w_class = 2
	var/storage_slots = 2
	var/obj/item/storage/internal/pocket/butt/inv = /obj/item/storage/internal/pocket/butt

/obj/item/organ/butt/xeno //XENOMORPH BUTTS ARE BEST BUTTS yes i agree
	name = "alien butt"
	desc = "best trophy ever"
	icon_state = "xenobutt"
	item_state = "xenobutt"
	storage_slots = 3
	max_combined_w_class = 5

/obj/item/organ/butt/bluebutt // bluespace butts, science
	name = "butt of holding"
	desc = "This butt has bluespace properties, letting you store more items in it. Four tiny items, or two small ones, or one normal one can fit."
	icon_state = "bluebutt"
	item_state = "bluebutt"
	status = ORGAN_ROBOTIC
	origin_tech = "bluespace=5;biotech=4"
	max_combined_w_class = 12
	max_w_class = 3
	storage_slots = 4

/obj/item/organ/butt/Insert(mob/living/carbon/human/H, special = 0, drop_if_replaced = TRUE)
	..()
	inv = new(H)
	inv.max_w_class = max_w_class
	inv.storage_slots = storage_slots
	inv.max_combined_w_class = max_combined_w_class

/obj/item/organ/butt/Remove(mob/living/carbon/M, special = 0)
	var/turf/T = get_turf(M)
	if(inv)
		for(var/i in inv.contents)
			var/obj/item/I = i
			inv.remove_from_storage(I, T)
	QDEL_NULL(inv)
	..()

/obj/item/organ/butt/on_life()
	if(owner && inv)
		for(var/obj/item/I in inv.contents)
			if(I.is_sharp() || is_pointed(I))
				owner.bleed(4)

/obj/item/organ/butt/Destroy()
	if(inv && owner)
		var/turf/T = get_turf(owner)
		for(var/i in inv.contents)
			var/obj/item/I = i
			inv.remove_from_storage(I, T)
	QDEL_NULL(inv)
	..()

/obj/item/organ/butt/attackby(var/obj/item/W, mob/user as mob, params) // copypasting bot manufucturing process, im a lazy fuck

	if(istype(W, /obj/item/bodypart/l_arm/robot) || istype(W, /obj/item/bodypart/r_arm/robot))
		if(istype(src, /obj/item/organ/butt/bluebutt)) //nobody sprited a blue butt buttbot
			to_chat(user, "<span class='warning'>Why the heck would you want to make a robot out of this?</span>")
			return
		user.dropItemToGround(W)
		qdel(W)
		var/turf/T = get_turf(src.loc)
		var/mob/living/simple_animal/bot/buttbot/B = new /mob/living/simple_animal/bot/buttbot(T)
		if(istype(src, /obj/item/organ/butt/xeno))
			B.xeno = 1
			B.icon_state = "buttbot_xeno"
			B.speech_list = list("hissing butts", "hiss hiss motherfucker", "nice trophy nerd", "butt", "woop get an alien inspection")
		to_chat(user, "<span class='notice'>You add the robot arm to the butt and... What?</span>")
		user.dropItemToGround(src)
		qdel(src)

/obj/item/organ/butt/throw_impact(atom/hit_atom)
	..()
	playsound(src, 'hippiestation/sound/effects/fart.ogg', 50, 1, 5)

/mob/living/carbon/proc/regeneratebutt()
	if(!getorganslot("butt"))
		if(ishuman(src) || ismonkey(src))
			var/obj/item/organ/butt/B = new()
			B.Insert(src)
		if(isalien(src))
			var/obj/item/organ/butt/xeno/X = new()
			X.Insert(src)
