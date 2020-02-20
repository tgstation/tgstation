/obj/item/storage/box/syndicate/junk
	name = "suspicious-looking box"
	icon_state = "syndiebox"
	illustration = "writing_syndie"

/obj/item/storage/box/syndicate/junk/PopulateContents()
	switch (pickweight(list("bastard" = 2, "fakeshield" = 2, "bedding" = 2, "snackkit" =1)))
		if ("bastard")
			new /obj/item/melee/bastardknife(src)
			new /obj/item/paper/fluff/stations/junk/bastardknife(src)

		if ("fakeshield")
			new /obj/item/implanter/fakeshieldshield(src)
			new /obj/item/paper/fluff/stations/junk/fakeshield(src)

		if ("bedding")
			new /obj/item/clothing/under/misc/syndiepjs(src)
			new /obj/item/bedsheet/syndie(src)
			new /obj/item/paper/fluff/stations/junk/syndiepjs(src)

		if ("snackkit")
			new /obj/item/reagent_containers/food/snacks/syndicake(src)
			new /obj/item/reagent_containers/food/snacks/tatortot(src)
			new /obj/item/reagent_containers/food/snacks/sosjerky/healthy(src)
			new /obj/item/kitchen/fork/plastitanium(src)
			new /obj/item/paper/fluff/stations/junk/snackkit(src)

/obj/item/paper/fluff/stations/junk
	name = "junk receipt"
	desc = "A receipt for your garbage."

/obj/item/melee/bastardknife
	name = "bastard knife"
	desc = "A well-worn knife that is sub-par in direct combat but is great for sliting throats."
	icon_state = "bastard"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 10
	throwforce = 12
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("rended", "gashed", "lanced", "ripped", "lacerated", "scored")
	sharpness = IS_SHARP
	hitsound = 'sound/weapons/bladeslice.ogg'
	slicetime = 0.25 //overkill beacause of cap but whatever

/obj/item/paper/fluff/stations/junk/bastardknife
	info = "This was an old weapon of choice of a field agent retrieved from an evidence locker several years after his capture. Its a lot duller than it used to be but has a nice edge for slicing incapacitated targets. We were going to throw it out, but maybe you can make some use of it."

/obj/item/implant/fakeshield
	name = "fake mindshield implant"
	desc = "Pretends to protect against brainwashing."
	activated = 0

/obj/item/implant/fakeshield/implant(mob/living/target, mob/user, silent = FALSE, force = FALSE)
	if(..())
		ADD_TRAIT(target, TRAIT_FAKE_MIND_SHIELD, "implant")
		target.sec_hud_set_implants()
		return TRUE

/obj/item/implant/fakeshield/removed(mob/target, silent = FALSE, special = 0)
	if(..())
		if(isliving(target))
			var/mob/living/L = target
			REMOVE_TRAIT(L, TRAIT_FAKE_MIND_SHIELD, "implant")
			L.sec_hud_set_implants()
		return TRUE
	return FALSE

/obj/item/implanter/fakeshieldshield
	name = "implanter (fake mindshield)"
	imp_type = /obj/item/implant/fakeshield

/obj/item/paper/fluff/stations/junk/fakeshield
	info = "After many months of investigation and decryption, the eggheads over at Cybersun Industries managed to perfectly replicate a signal cast by a mindshield implant. Unfortunately for them, the signal’s only purpose was to be read by security HUDs and was ineffective in blocking any sort of mind alerting effects."

/obj/item/clothing/under/misc/syndiepjs
	name = "syndie PJs"
	desc = "A suspicious set of sleepwear, for taking naps or being lazy instead of working."
	can_adjust = FALSE
	icon_state = "syndie_pyjamas"
	armor = list("laser" = 10, "acid" = 10)

/obj/item/paper/fluff/stations/junk/syndiepjs
	info = "We needed to get rid of these old pajamas and bedsheets after our resent dormitory renovation. The pajamas allow the wearer to recover from more grievous wounds by sleeping than normal and are minorly resistant against lasers. The new PJs we ordered are made with 100% organic gondola hide, unlike that cheap synth-thread one we gave you."

/obj/item/kitchen/fork/plastitanium
	name = "plastitanium fork"
	desc = "A fork made of plastitanium."
	throwforce = 10
	armour_penetration = 100

/obj/item/paper/fluff/stations/junk/snackkit
	info = "Enjoy this collection of old food left out in decrepit venders and on mess hall tables. Enjoy with this fancy plastitanium fork that has been made to piece even the hardest outer shells and armors of food and people alike."