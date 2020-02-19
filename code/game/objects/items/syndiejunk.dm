/obj/item/storage/box/syndicate/junk
	name = "suspicious-looking box"
	icon_state = "syndiebox"
	illustration = "writing_syndie"

/obj/item/storage/box/syndicate/junk/PopulateContents()
	switch (pick(list("bastard", "fakeshield")))
		if ("bastard")
			new /obj/item/melee/bastardknife(src)
			new /obj/item/paper/fluff/stations/junk/bastardknife(src)

		if ("fakeshield")
			new /obj/item/implanter/fakeshieldshield(src)
			new /obj/item/paper/fluff/stations/junk/fakeshield(src)

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