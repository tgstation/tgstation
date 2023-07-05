/obj/item/clothing/shoes/cluwne
	desc = "The prankster's standard-issue clowning shoes. Damn, they're huge!"
	name = "clown shoes"
	icon_state = "clown"
	inhand_icon_state = "clown_shoes"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	item_flags = DROPDEL
	slowdown = SHOE_SPEED_SLOW
	/// Sad man
	var/enabled_waddle = TRUE
	/// List of possible sounds for the squeak component to use, allows for different clown shoe subtypes to have different sounds.
	var/list/squeak_sound = list('sound/effects/footstep/clownstep1.ogg' = 1, 'sound/effects/footstep/clownstep2.ogg' = 1)

/obj/item/clothing/shoes/cluwne/Initialize(mapload)
	.=..()
	LoadComponent(/datum/component/squeak, squeak_sound, 50, falloff_exponent = 20) //die off quick please
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT(type))

/obj/item/clothing/shoes/cluwne/equipped(mob/user, slot)
	if(!user.has_dna())
		return ..()
	if(slot == ITEM_SLOT_FEET)
		var/mob/living/carbon/player = user
		player.dna.add_mutation(/datum/mutation/human/cluwne)

		if(enabled_waddle)
			user.AddElement(/datum/element/waddling)

		if(is_clown_job(user.mind?.assigned_role))
			player.add_mood_event("clownshoes", /datum/mood_event/clownshoes)
	return ..()

/obj/item/clothing/shoes/cluwne/dropped(mob/living/user)
	. = ..()
	user.RemoveElement(/datum/element/waddling)
