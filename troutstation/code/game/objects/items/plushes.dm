/obj/item/toy/plush/maddie
	icon = 'troutstation/icons/obj/toys/plushes.dmi'
	name = "maddie plushie"
	desc = "Oh hey, that's a plushie of Maddie. You love her!"
	icon_state = "plushie_maddie"
	inhand_icon_state = null
	attack_verb_continuous = list("squeaks at", "strikes", "bashes")
	attack_verb_simple = list("squeak at", "strike", "bash")
	squeak_override = list('troutstation/sound/items/toy_squeak/mrdSqueak.ogg' = 1)
	gender = FEMALE

/obj/item/toy/plush/goatplushie
	icon = 'troutstation/icons/obj/toys/plushes.dmi'
	name = "strange goat plushie"
	icon_state = "goat"
	desc = "Despite its cuddly appearance and plush nature, it will beat you up all the same. Goats never change."
	squeak_override = list('sound/items/weapons/punch1.ogg'=1)
	/// Whether or not this goat is currently taking in a monsterous doink
	var/going_hard = FALSE
	/// Whether or not this goat has been flattened like a funny pancake
	var/splat = FALSE

/obj/item/toy/plush/goatplushie/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_TURF_INDUSTRIAL_LIFT_ENTER = PROC_REF(splat),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/toy/plush/goatplushie/attackby(obj/item/cigarette/rollie/fat_dart, mob/user, list/modifiers, list/attack_modifiers)
	if(!istype(fat_dart))
		return ..()
	if(splat)
		to_chat(user, span_notice("[src] doesn't seem to be able to go hard right now."))
		return
	if(going_hard)
		to_chat(user, span_notice("[src] is already going too hard!"))
		return
	if(!fat_dart.lit)
		to_chat(user, span_notice("You'll have to light that first!"))
		return
	to_chat(user, span_notice("You put [fat_dart] into [src]'s mouth."))
	qdel(fat_dart)
	going_hard = TRUE
	update_icon(UPDATE_OVERLAYS)

/obj/item/toy/plush/goatplushie/proc/splat(datum/source)
	SIGNAL_HANDLER
	if(splat)
		return
	if(going_hard)
		going_hard = FALSE
		update_icon(UPDATE_OVERLAYS)
	icon_state = "goat_splat"
	playsound(src, SFX_DESECRATION, 50, TRUE)
	visible_message(span_danger("[src] gets absolutely flattened!"))
	splat = TRUE

/obj/item/toy/plush/goatplushie/examine()
	. = ..()
	if(splat)
		. += span_notice("[src] might need medical attention.")
	if(going_hard)
		. += span_notice("[src] is going so hard, feel free to take a picture.")

/obj/item/toy/plush/goatplushie/update_overlays()
	. = ..()
	if(going_hard)
		. += "goat_dart"


/obj/item/toy/plush/rufran
	icon = 'troutstation/icons/obj/toys/plushes.dmi'
	name = "rufran plushie"
	desc = "An adorable stuffed toy that resembles a moth and a bird. You feel like it looked smaller earlier."
	icon_state = "plushie_rufran"
	var/size = 1

/obj/item/toy/plush/rufran/attackby(obj/item/dnainjector/gigantism/serum, mob/user, list/modifiers, list/attack_modifiers)
	if(serum.used==FALSE && istype(serum, /obj/item/dnainjector/gigantism) && size < 2.5)
		to_chat(user, span_notice("You inject [src] with the gigantism serum!"))
		size += 0.5
		AddElement(/datum/element/item_scaling, size, size)
		playsound(get_turf(user), 'sound/effects/creak/creak1.ogg', 100, TRUE)
		// actually use the injector
		serum.used = TRUE
		serum.desc = "A cheap single use autoinjector that injects the user with DNA. This one is used up."
		serum.icon_state = "dnainjector0"
		serum.inhand_icon_state = "dnainjector0"
		if(size==1.5)
			w_class = WEIGHT_CLASS_BULKY
		if(size==2)
			w_class = WEIGHT_CLASS_HUGE
			AddComponent(/datum/component/two_handed, require_twohands = TRUE)
		if(size==2.5)
			w_class = WEIGHT_CLASS_GIGANTIC
			interaction_flags_item = NONE
		return
	if(serum.used==TRUE)
		to_chat(user, span_warning("This injector is used up!"))
		return
	if(size >= 2.5)
		to_chat(user, span_warning("[src] can't get any bigger!"))
		return

/obj/item/toy/plush/rufran/examine()
	. = ..()
	if(size == 1.5)
		. += span_notice("It looks big!")
	if(size == 2)
		. += span_notice("It looks huge!")
	if(size == 2.5)
		. += span_notice("It looks massive!")
	if(size > 2.5)
		. += span_notice("wuh oh")
