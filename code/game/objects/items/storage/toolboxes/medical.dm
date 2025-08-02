/obj/item/storage/toolbox/medical
	name = "medical toolbox"
	desc = "A toolbox painted soft white and light blue. This is getting ridiculous."
	icon_state = "medical"
	inhand_icon_state = "toolbox_medical"
	attack_verb_continuous = list("treats", "surgeries", "tends", "tends wounds on")
	attack_verb_simple = list("treat", "surgery", "tend", "tend wounds on")
	w_class = WEIGHT_CLASS_BULKY
	material_flags = NONE
	force = 5 // its for healing
	wound_bonus = 25 // wounds are medical right?
	/// Tray we steal the og contents from.
	var/obj/item/surgery_tray/tray_type = /obj/item/surgery_tray

/obj/item/storage/toolbox/medical/PopulateContents()
	atom_storage.max_slots = 0
	atom_storage.max_total_storage = 0

	var/atom/fake_tray = new tray_type(null)
	for(var/obj/item/tool in fake_tray)
		tool.forceMove(src)
		atom_storage.max_slots += 1
		atom_storage.max_total_storage += tool.w_class

	qdel(fake_tray)

/obj/item/storage/toolbox/medical/full
	tray_type = /obj/item/surgery_tray/full

/obj/item/storage/toolbox/medical/coroner
	name = "coroner toolbox"
	desc = "A toolbox painted soft white and dark grey. This is getting beyond ridiculous."
	icon_state = "coroner"
	inhand_icon_state = "toolbox_coroner"
	attack_verb_continuous = list("dissects", "autopsies", "corones")
	attack_verb_simple = list("dissect", "autopsy", "corone")
	w_class = WEIGHT_CLASS_BULKY
	material_flags = NONE
	force = 17 // it's not for healing
	tray_type = /obj/item/surgery_tray/full/morgue

/obj/item/storage/toolbox/medical/coroner/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/bane, mob_biotypes = MOB_UNDEAD, damage_multiplier = 1) //Just in case one of the tennants get uppity
