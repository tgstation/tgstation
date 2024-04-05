///A pinata that has a chance to drop candy items when struck with a melee weapon that deals at least 10 damage
/obj/structure/pinata
	name = "corgi pinata"
	desc = "A papier-mâché representation of a corgi that contains all sorts of sugary treats."
	icon = 'icons/obj/toys/toy.dmi'
	icon_state = "pinata_placed"
	base_icon_state = "pinata_placed"
	max_integrity = 300 //20 hits from a baseball bat
	anchored = TRUE
	///What sort of candy the pinata will contain
	var/candy_options = list(
		/obj/item/food/bubblegum,
		/obj/item/food/candy,
		/obj/item/food/chocolatebar,
		/obj/item/food/gumball,
		/obj/item/food/lollipop/cyborg,
	)
	///How much candy is dropped when the pinata is destroyed
	var/destruction_loot = 5
	///Debris dropped when the pinata is destroyed
	var/debris = /obj/effect/decal/cleanable/wrapping/pinata

/obj/structure/pinata/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/pinata, candy = candy_options, death_drop = destruction_loot)

/obj/structure/pinata/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir, armour_penetration)
	. = ..()
	if(get_integrity() < (max_integrity/2))
		icon_state = "[base_icon_state]_damaged"
	if(damage_amount >= 10) // Swing means minimum damage threshhold for dropping candy is met.
		flick("[icon_state]_swing", src)

/obj/structure/pinata/play_attack_sound(damage_amount, damage_type, damage_flag)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/weapons/slash.ogg', 50, TRUE)
			else
				playsound(src, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src, 'sound/items/welder.ogg', 100, TRUE)

/obj/structure/pinata/atom_deconstruct(disassembled)
	new debris(get_turf(src))

///An item that when used inhand spawns an immovable pinata
/obj/item/pinata
	name = "pinata assembly kit"
	desc = "A papier-mâché corgi that contains various candy, must be set up before you can smash it."
	icon = 'icons/obj/toys/toy.dmi'
	icon_state = "pinata"
	///The pinata that is created when this is placed.
	var/pinata_type = /obj/structure/pinata

/obj/item/pinata/attack_self(mob/user)
	var/turf/player_turf = get_turf(user)
	if(player_turf?.is_blocked_turf(TRUE))
		return FALSE
	balloon_alert_to_viewers("setting up pinata...")
	if(!do_after(user, 4 SECONDS, target = get_turf(user), progress = TRUE))
		balloon_alert(user, "cancelled!")
	new pinata_type(get_turf(user))
	balloon_alert(user, "pinata setup")
	qdel(src)

/obj/structure/pinata/syndie
	name = "syndicate corgi pinata"
	desc = "A papier-mâché representation of a corgi that contains all sorts of bombastic treats."
	icon_state = "pinata_syndie_placed"
	base_icon_state = "pinata_syndie_placed"
	destruction_loot = 2
	debris = /obj/effect/decal/cleanable/wrapping/pinata/syndie
	candy_options = list(
		/obj/item/food/bubblegum,
		/obj/item/food/candy,
		/obj/item/food/chocolatebar,
		/obj/item/food/gumball,
		/obj/item/food/lollipop,
		/obj/item/grenade/c4,
		/obj/item/grenade/clusterbuster/soap,
		/obj/item/grenade/empgrenade,
		/obj/item/grenade/frag,
		/obj/item/grenade/syndieminibomb,
	) //Candy items at the top, explosives at the bottom to be easier to read instead of fully alphabetized.

/obj/item/pinata/syndie
	name = "weapons grade pinata assembly kit"
	desc = "A papier-mâché corgi that contains various candy and explosives, must be set up before you can smash it."
	icon_state = "pinata_syndie"
	pinata_type = /obj/structure/pinata/syndie
