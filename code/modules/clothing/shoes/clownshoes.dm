/obj/item/clothing/shoes/proc/step_action() //this was made to rewrite clown shoes squeaking
	SEND_SIGNAL(src, COMSIG_SHOES_STEP_ACTION)

/obj/item/clothing/shoes/clown_shoes
	desc = "The prankster's standard-issue clowning shoes. Damn, they're huge! Ctrl-click to toggle waddle dampeners."
	name = "clown shoes"
	icon_state = "clown"
	inhand_icon_state = "clown_shoes"
	slowdown = SHOES_SLOWDOWN+1
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes/clown
	var/enabled_waddle = TRUE
	lace_time = 20 SECONDS // how the hell do these laces even work??

/obj/item/clothing/shoes/clown_shoes/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/clownstep1.ogg'=1,'sound/effects/clownstep2.ogg'=1), 50)

/obj/item/clothing/shoes/clown_shoes/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_FEET)
		if(enabled_waddle)
			user.AddElement(/datum/element/waddling)
		if(user.mind && user.mind.assigned_role == "Clown")
			SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "clownshoes", /datum/mood_event/clownshoes)

/obj/item/clothing/shoes/clown_shoes/dropped(mob/user)
	. = ..()
	user.RemoveElement(/datum/element/waddling)
	if(user.mind && user.mind.assigned_role == "Clown")
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "clownshoes")

/obj/item/clothing/shoes/clown_shoes/CtrlClick(mob/living/user)
	if(!isliving(user))
		return
	if(user.get_active_held_item() != src)
		to_chat(user, "<span class='warning'>You must hold the [src] in your hand to do this!</span>")
		return
	if (!enabled_waddle)
		to_chat(user, "<span class='notice'>You switch off the waddle dampeners!</span>")
		enabled_waddle = TRUE
	else
		to_chat(user, "<span class='notice'>You switch on the waddle dampeners!</span>")
		enabled_waddle = FALSE



/obj/item/clothing/shoes/clown_shoes/sec
	desc = "The law *IS* a joking matter! Ctrl-click to toggle waddle dampeners."
	name = "clown jacks"
	icon_state = "clown_sec"
	inhand_icon_state = "clown_shoes_sec"
	slowdown = SHOES_SLOWDOWN
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/shoes

/obj/item/clothing/shoes/clown_shoes/sec/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/footstep/wood5.ogg'=1), 100, 100, 0)


/obj/item/clothing/shoes/clown_shoes/prison
	desc = "That trial was a joke! A kangaroo court!  Ctrl-click to toggle waddle dampeners."
	name = "orange clown shoes"
	icon_state = "clown_prison"
	inhand_icon_state = "clown_shoes_prison"
	slowdown = 15

/obj/item/clothing/shoes/clown_shoes/prison/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/chain.ogg'=1), 50)


/obj/item/clothing/shoes/clown_shoes/prison/allow_attack_hand_drop(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/C = user
		if(C.shoes == src)
			to_chat(user, "<span class='warning'>You need help taking these off!</span>")
			return FALSE
	return ..()

/obj/item/clothing/shoes/clown_shoes/prison/MouseDrop(atom/over)
	var/mob/m = usr
	if(ishuman(m))
		var/mob/living/carbon/human/c = m
		if(c.shoes == src)
			to_chat(c, "<span class='warning'>You need help taking these off!</span>")
			return
	return ..()


/obj/item/clothing/shoes/clown_shoes/engi
	desc = "These boots were made for working, but that's not what we're gonna do.  Ctrl-click to toggle waddle dampeners."
	name = "clown boots"
	icon_state = "clown_engi"
	inhand_icon_state = "clown_shoes_engi"

/obj/item/clothing/shoes/clown_shoes/engi/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/footstep/catwalk3.ogg'=1,'sound/effects/footstep/carpet5.ogg'=1), 100)


/obj/item/clothing/shoes/clown_shoes/hydro
	desc = "A bit prickly, and somewhat loose. Perhaps you can get a new sole? Ctrl-click to toggle waddle dampeners."
	name = "clown grass shoes"
	icon_state = "clown_hydro"
	inhand_icon_state = "clown_shoes_hydro"

/obj/item/clothing/shoes/clown_shoes/hydro/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/footstep/grass2.ogg'=1,'sound/effects/footstep/grass3.ogg'=1), 100)


/obj/item/clothing/shoes/clown_shoes/clogs
	desc = "Great sole support, but shouldn't these bee yellow? Ctrl-click to toggle waddle dampeners."
	name = "clown clogs"
	icon_state = "clown_clogs"
	inhand_icon_state = "clown_shoes_clogs"

/obj/item/clothing/shoes/clown_shoes/clogs/attackby(obj/H, mob/user, loc)
	..()
	if (H.type == /obj/item/reagent_containers/honeycomb || H.type== /obj/item/grown/sunflower)
		var/location = get_turf(user)
		new /obj/item/clothing/shoes/clown_shoes/dutch(location)
		qdel(H)
		qdel(src)
	return

/obj/item/clothing/shoes/clown_shoes/clogs/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/footstep/woodclaw1.ogg'=1,'sound/effects/footstep/woodclaw3.ogg'=1), 100)


/obj/item/clothing/shoes/clown_shoes/dutch
	desc = "Why are dutch clowns not tall? All the big one bounced out the ceiling! TURN ON YOUR WADDLE DAMPENERS WITH CTRL-CLICK FOR GODS SAKE!!"
	name = "dutch clown clogs"
	icon_state = "clown_dutch"
	inhand_icon_state = "clown_shoes_dutch"

/obj/item/clothing/shoes/clown_shoes/dutch/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/clownstepdutch.ogg'=1), 100)


/obj/item/clothing/shoes/clown_shoes/med
	desc = "A more sanitary version of the clown shoes.  Ctrl-click to toggle waddle dampeners."
	name = "medical clown crocks"
	icon_state = "clown_med"
	inhand_icon_state = "clown_shoes_med"

/obj/item/clothing/shoes/clown_shoes/med/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/clownstepcrocks.ogg'=1), 50)


/obj/item/clothing/shoes/clown_shoes/janny
	desc = "Clown shoes for when the joke has gone wrong.  Ctrl-click to toggle waddle dampeners."
	name = "clown rubberboots"
	icon_state = "clown_janny"
	inhand_icon_state = "clown_shoes_janny"
	permeability_coefficient = 0.01
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 40, "acid" = 75)
	can_be_bloody = FALSE

/obj/item/clothing/shoes/clown_shoes/janny/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/clownstepthicc.ogg'=1), 50)

/obj/item/clothing/shoes/clown_shoes/galoshes
	desc = "Clown shoes for when the joke has gone terribly wrong.  Ctrl-click to toggle waddle dampeners."
	name = "clown galoshes"
	icon_state = "clown_galoshes"
	inhand_icon_state = "clown_shoes_galoshes"
	permeability_coefficient = 0.01
	clothing_flags = NOSLIP
	slowdown = SHOES_SLOWDOWN+1
	strip_delay = 30
	equip_delay_other = 50
	resistance_flags = NONE
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 40, "acid" = 75)
	can_be_bloody = FALSE
	can_be_tied = FALSE

/obj/item/clothing/shoes/clown_shoes/galoshes/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/clownstepthicc.ogg'=1), 50)


/obj/item/clothing/shoes/clown_shoes/law
	desc = "For use in the court of miracles. Ctrl-click to toggle waddle dampeners."
	name = "laceup clown shoes"
	icon_state = "clown_law"
	inhand_icon_state = "clown_shoes_law"

/obj/item/clothing/shoes/clown_shoes/law/Initialize()
	. = ..()
	AddComponent(/datum/component/squeak, list('sound/effects/footstep/wood4.ogg'=1,'sound/effects/footstep/wood5.ogg'=1), 100)


/obj/item/clothing/shoes/clown_shoes/jester
	name = "jester shoes"
	desc = "A court jester's shoes, updated with modern squeaking technology."
	icon_state = "jester_shoes"

/obj/item/clothing/shoes/clown_shoes/jester/Initialize()
	. = ..()
	if(SSevents.holidays && SSevents.holidays[CHRISTMAS])
		AddComponent(/datum/component/squeak, list('sound/effects/clownstepbellchristmas.ogg'=1), 50)
	else AddComponent(/datum/component/squeak, list('sound/effects/clownstepbell.ogg'=1), 50)
