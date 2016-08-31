//Unique treasure items from lavaland mobs. See necropolis_chests.dm for loot tables.

/obj/item/clothing/suit/gravity_harness //Allows flight over chasms and provides decent melee protection.
	name = "gravity harness"
	desc = "A heavy metal construction made of old-fashioned wires and lights. It's gently thrumming."
	icon_state = "gravity_harness"
	armor = list(melee = 40, bullet = 10, laser = 0, energy = 0, bomb = 0, bio = 0, rad = 0) //Pretty good protection so it compares to the explorer suit
	burn_state = FIRE_PROOF
	w_class = 3
	throw_range = 1
	throw_speed = 1
	origin_tech = "materials=5;magnets=7;engineering=5"
	actions_types = list(/datum/action/item_action/toggle_harness)
	var/online = FALSE

/obj/item/clothing/suit/gravity_harness/New()
	..()
	name = "[pick("grimy", "dirty", "dusty", "soot-covered")] [name]" //A T M O S P H E R E
	icon_state = "[icon_state]_0"

/obj/item/clothing/suit/gravity_harness/attack_self(mob/living/carbon/human/user)
	if(!user.canUseTopic(src) || !istype(user))
		return
	if(user.get_item_by_slot(slot_wear_suit) != src)
		user << "<span class='warning'>You need to put on [src] before you can use it!</span>"
		return
	if(user.dna.species.id != "human")
		user << "<span class='warning'>You can't seem to get [src] to fit...</span>"
		return
	online = !online
	icon_state = "[initial(icon_state)]_[online]"
	user.update_gravity(user.mob_has_gravity())
	user.update_inv_wear_suit()
	if(online)
		name = initial(name) //Get rid of all that grime
		user.visible_message("<span class='notice'>[user]'s [name] shudders to life!</span>", "<span class='notice'>[src] violently shudders before humming to life as its lights turn on.</span>")
		user.dna.species.specflags += FLYING
	else
		user.visible_message("<span class='notice'>[user]'s [name] falls dark.</span>", "<span class='notice'>[src] turns off.</span>")
		user.dna.species.specflags -= FLYING

/obj/item/clothing/suit/gravity_harness/negates_gravity()
	return online


/obj/item/clothing/glasses/prismatic_lens //Grants night, thermal, and reagent vision.
	name = "prismatic lens"
	desc = "An odd disc made of some sort of fused crystal. Its color shifts rapidly."
	icon_state = "prismatic_lens"
	vision_flags = SEE_TURFS|SEE_MOBS|SEE_OBJS
	darkness_view = 8
	scan_reagents = 1
	invis_view = SEE_INVISIBLE_MINIMUM
