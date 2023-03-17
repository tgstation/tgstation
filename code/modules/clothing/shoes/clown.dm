/obj/item/clothing/shoes/clown_shoes
	desc = "The prankster's standard-issue clowning shoes. Damn, they're huge! Ctrl-click to toggle waddle dampeners."
	name = "clown shoes"
	icon_state = "clown"
	inhand_icon_state = "clown_shoes"
	slowdown = SHOES_SLOWDOWN+1
	var/enabled_waddle = TRUE
	///List of possible sounds for the squeak component to use, allows for different clown shoe subtypes to have different sounds.
	var/list/squeak_sound = list('sound/effects/clownstep1.ogg'=1,'sound/effects/clownstep2.ogg'=1)
	lace_time = 20 SECONDS // how the hell do these laces even work??
	species_exception = list(/datum/species/golem/bananium)

/obj/item/clothing/shoes/clown_shoes/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/shoes/clown)
	LoadComponent(/datum/component/squeak, squeak_sound, 50, falloff_exponent = 20) //die off quick please
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_CLOWN, CELL_VIRUS_TABLE_GENERIC, rand(2,3), 0)

/obj/item/clothing/shoes/clown_shoes/equipped(mob/living/user, slot)
	. = ..()
	if(slot & ITEM_SLOT_FEET)
		if(enabled_waddle)
			user.AddElement(/datum/element/waddling)
		if(is_clown_job(user.mind?.assigned_role))
			user.add_mood_event("clownshoes", /datum/mood_event/clownshoes)

/obj/item/clothing/shoes/clown_shoes/dropped(mob/living/user)
	. = ..()
	user.RemoveElement(/datum/element/waddling)
	if(is_clown_job(user.mind?.assigned_role))
		user.clear_mood_event("clownshoes")

/obj/item/clothing/shoes/clown_shoes/CtrlClick(mob/living/user)
	if(!isliving(user))
		return
	if(user.get_active_held_item() != src)
		to_chat(user, span_warning("You must hold the [src] in your hand to do this!"))
		return
	if (!enabled_waddle)
		to_chat(user, span_notice("You switch off the waddle dampeners!"))
		enabled_waddle = TRUE
	else
		to_chat(user, span_notice("You switch on the waddle dampeners!"))
		enabled_waddle = FALSE

/obj/item/clothing/shoes/clown_shoes/jester
	name = "jester shoes"
	desc = "A court jester's shoes, updated with modern squeaking technology."
	icon_state = "jester_shoes"

/obj/item/clothing/shoes/clown_shoes/meown_shoes
	name = "meown shoes"
	desc = "The adorable sound they make when you walk will mean making friends is more likely."
	icon_state = "meown_shoes"
	squeak_sound = list('sound/effects/meowstep1.ogg'=1) //mew mew mew mew

/obj/item/clothing/shoes/clown_shoes/ducky_shoes
	name = "ducky shoes"
	desc = "I got boots, that go *quack quack quack quack quack."
	icon_state = "ducky_shoes"
	inhand_icon_state = "ducky_shoes"
	squeak_sound = list('sound/effects/quack.ogg'=1) //quack quack quack quack
