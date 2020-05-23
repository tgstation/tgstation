/obj/item/living_heart
	name = "Living Heart"
	desc = "Link to the worlds beyond."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "living_heart"
	///Target
	var/datum/mind/target

/obj/item/living_heart/attack_self(mob/user)
	. = ..()
	if(!IS_E_CULTIST(user))
		return
	if(!target)
		return
	var/dist = get_dist(user.loc,target.current.loc)

	switch(dist)
		if(0 to 5)
			to_chat(user,"<span class='warning'>[target.current.real_name] is near you</span>")
		if(6 to 15)
			to_chat(user,"<span class='warning'>[target.current.real_name] is somewhere in your vicinty</span>")
		if(16 to 64)
			to_chat(user,"<span class='warning'>[target.current.real_name] is far away from you</span>")
		else
			to_chat(user,"<span class='warning'>[target.current.real_name] is beyond our reach</span>")

	if(target.current.stat == DEAD)
		to_chat(user,"<span class='warning'>[target.current.real_name] is dead. Bring them onto a transmutation rune!</span>")

/obj/item/melee/sickly_blade
	name = "Sickly blade"
	desc = "Twisted sickle with an ornamental eye. The eyes looks at you."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eldritch_blade"
	item_state = "eldritch_blade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	sharpness = IS_SHARP
	w_class = WEIGHT_CLASS_BULKY
	force = 15
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "rended")

/obj/item/melee/sickly_blade/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	var/datum/antagonist/e_cult/cultie = user.mind.has_antag_datum(/datum/antagonist/e_cult)
	if(!cultie)
		return
	for(var/X in cultie.get_all_knowledge())
		var/datum/eldritch_knowledge/EK = X
		EK.eldritch_blade_act(target,user,proximity_flag,click_parameters)

/obj/item/melee/sickly_blade/rust
	name = "Rusted Blade"

/obj/item/melee/sickly_blade/ash
	name = "Ashen Blade"

/obj/item/melee/sickly_blade/flesh
	name = "Flesh Blade"

/obj/item/clothing/neck/eldritch_amulet
	name = "Warm Eldritch Medallion"
	desc = "Eldritch medallion that let's you see."
	icon = 'icons/obj/eldritch.dmi'
	icon_state = "eye_medalion"
	item_state = ""	//no inhands
	w_class = WEIGHT_CLASS_SMALL
	trinket_flag = SEE_MOBS
	trinket_lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE

/obj/item/clothing/neck/eldritch_amulet/piercing
	name = "Piercing Eldritch Medallion"
	trinket_flag = SEE_TURFS|SEE_MOBS|SEE_OBJS

/obj/item/clothing/head/hooded/cult_hoodie/eldritch
	name = "ominous hood"
	icon_state = "eldritch"
	desc = "A torn, dust-caked hood. Strange eyes line the inside."

/obj/item/clothing/suit/hooded/cultrobes/eldritch
	name = "ominous armor"
	desc = "A ragged, dusty set of robes. Strange eyes line the inside."
	icon_state = "eldritch_armor"
	item_state = "eldritch_armor"
	allowed = list(/obj/item/melee/sickly_blade, /obj/item/forbidden_book)
	hoodtype = /obj/item/clothing/head/hooded/cult_hoodie/eldritch

/obj/item/reagent_containers/glass/beaker/eldritch
	name = "flask of eldritch essence"
	desc = "Toxic to the close minded. Healing to those with knowledge of the beyond."
	icon = 'icons/obj/drinks.dmi'
	icon_state = "holyflask"
	color = "#359656"
	list_reagents = list(/datum/reagent/eldritch = 50)
