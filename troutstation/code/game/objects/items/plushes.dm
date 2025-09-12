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

#define RUFRAN_NORMAL_SIZE 1
#define RUFRAN_BIG_SIZE 1.5
#define RUFRAN_HUGE_SIZE 2
#define RUFRAN_GIGANTIC_SIZE 2.5
#define RUFRAN_SIZE_INCREMENT 0.5

/obj/item/toy/plush/rufran
	icon = 'troutstation/icons/obj/toys/plushes.dmi'
	name = "rufran plushie"
	desc = "An adorable stuffed toy that resembles a moth and a bird. You feel like it looked smaller earlier."
	icon_state = "plushie_rufran"
	squeak_override = list('sound/mobs/humanoids/moth/scream_moth.ogg'=1)
	var/size = RUFRAN_NORMAL_SIZE

/obj/item/toy/plush/rufran/attackby(obj/item/dnainjector/serum, mob/user, list/modifiers, list/attack_modifiers)
	if(serum.used)
		to_chat(user, span_warning("This injector is used up!"))
		return
	if(size >= RUFRAN_GIGANTIC_SIZE)
		to_chat(user, span_warning("[src] can't get any bigger!"))
		return
	if(/datum/mutation/gigantism in serum.add_mutations || serum.add_mutations[1].name == "Gigantism")
		to_chat(user, span_notice("You inject [src] with the gigantism serum!"))
		size += RUFRAN_SIZE_INCREMENT
		AddElement(/datum/element/item_scaling, size, size)
		playsound(get_turf(user), 'sound/effects/creak/creak1.ogg', 100, TRUE)
		// actually use the injector
		serum.used = TRUE
		serum.desc = "A cheap single use autoinjector that injects the user with DNA. This one is used up."
		serum.icon_state = "dnainjector0"
		serum.inhand_icon_state = "dnainjector0"
		// important: biggest number first, then descending order
		if(size >= RUFRAN_GIGANTIC_SIZE)
			w_class = WEIGHT_CLASS_GIGANTIC
			interaction_flags_item = NONE
		else if(size >= RUFRAN_HUGE_SIZE)
			w_class = WEIGHT_CLASS_HUGE
			AddComponent(/datum/component/two_handed, require_twohands = TRUE)
		else if(size >= RUFRAN_BIG_SIZE)
			w_class = WEIGHT_CLASS_BULKY
		return


/obj/item/toy/plush/rufran/examine()
	. = ..()
	// important: biggest number first, then descending order
	if(size >= RUFRAN_GIGANTIC_SIZE + 1E-4) // god i hate float comparisons sometimes
		. += span_notice("wuh oh")
	else if(size >= RUFRAN_GIGANTIC_SIZE)
		. += span_notice("It looks massive!")
	else if(size >= RUFRAN_HUGE_SIZE)
		. += span_notice("It looks huge!")
	else if(size >= RUFRAN_BIG_SIZE)
		. += span_notice("It looks big!")

// i have no fucking idea why anyone would reuse these macros but good practice is good practice
#undef RUFRAN_NORMAL_SIZE
#undef RUFRAN_BIG_SIZE
#undef RUFRAN_HUGE_SIZE
#undef RUFRAN_GIGANTIC_SIZE
#undef RUFRAN_SIZE_INCREMENT
