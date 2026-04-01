///Fool's Day shit by maximal08
///Visual effect (bad coder moment)
/obj/effect/temp_lz
	name = "landing zone"
	icon = 'icons/obj/supplypods_32x32.dmi'
	icon_state = "LZ"
	layer = 6
	blend_mode = BLEND_ADD
	alpha = 200

/obj/effect/temp_lz/Initialize(loc)
	. = ..()
	spawn(20)
		if(src && !QDELETED(src))
			qdel(src)


// BASE COIN CLASS WITH FLIP ANIMATION

/obj/item/coin
	name = "coin"
	desc = "A simple coin."
	icon = 'icons/obj/economy.dmi'
	icon_state = "coin"
	item_flags = NOBLUDGEON


// PIANO COIN

/obj/item/coin/piano
	name = "Knockdown coin"
	desc = "A mystical coin with engraved piano keys. Flip it over to cause havoc once every 30 seconds."
	icon = 'icons/obj/economy.dmi'
	icon_state = "knockdown_front"
	item_flags = NOBLUDGEON

	var/last_used = 0
	var/cooldown_time = 300

/obj/item/coin/piano/Initialize(mapload)
	. = ..()
	last_used = 0
	icon_state = "knockdown_front"

/obj/item/coin/piano/attack_self(mob/living/user)
	if(!user || !user.loc)
		return
	if(world.time < last_used + cooldown_time)
		to_chat(user, span_notice("The coin is still recharging..."))
		return
	last_used = world.time
	flip_coin(user)

/obj/item/coin/piano/proc/flip_coin(mob/living/user)
	var/turf/front = get_step(user, user.dir)

	if(rand(0, 1))
		piano_drop(user, user.loc, user)
		icon_state = "knockdown_back"
	else if(front)
		piano_drop(user, front, user)
		icon_state = "knockdown_front"

/obj/item/coin/piano/proc/piano_drop(mob/living/user, turf/target, mob/living/coin_user)
	if(!target)
		return

	var/obj/effect/temp_lz/V = new(target)

	playsound(user.loc, 'sound/items/coinflip.ogg', 50, TRUE)

	spawn(5)
		if(V && !QDELETED(V))
			qdel(V)

		playsound(target, 'sound/effects/piano_hit.ogg', 100, TRUE)

		var/obj/structure/musician/piano/P = new(target)
		P.icon_state = P.broken_icon_state
		P.name = "crashed piano"
		P.desc = "A broken piano. Keys scattered everywhere."
		P.anchored = FALSE
		P.density = FALSE

		var/mob/living/victim = locate(/mob/living) in target
		if(victim)
			victim.adjust_brute_loss(20)
			victim.Paralyze(8)
			victim.visible_message(
				span_danger("A piano crashes down on [victim]!"),
				span_userdanger("A piano falls on you!"),
				span_hear("CRASH!"),
			)

		spawn(20)
			if(P && !QDELETED(P))
				qdel(P)


// DISARMING COIN

/obj/item/coin/disarming
	name = "Disarming coin"
	desc = "A cursed coin that numbs arms. Flip to disarm yourself or enemies nearby."
	icon = 'icons/obj/economy.dmi'
	icon_state = "disarming_front"
	item_flags = NOBLUDGEON

	var/last_used = 0
	var/cooldown_time = 300

/obj/item/coin/disarming/Initialize(mapload)
	. = ..()
	last_used = 0
	icon_state = "disarming_front"

/obj/item/coin/disarming/attack_self(mob/living/user)
	if(!user || !user.loc)
		return
	if(world.time < last_used + cooldown_time)
		to_chat(user, span_notice("The coin is still recharging..."))
		return
	last_used = world.time
	flip_coin(user)

/obj/item/coin/disarming/proc/flip_coin(mob/living/user)
	if(rand(0, 1))
		to_chat(user, span_warning("Heads: Self-Disarm!"))
		icon_state = "disarming_back"
		disarm_self(user)
	else
		to_chat(user, span_good("Tails: Area Disarm!"))
		icon_state = "disarming_front"
		disarm_area(user)

/obj/item/coin/disarming/proc/disarm_self(mob/living/user)
	user.add_traits(list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM))
	user.visible_message(
		span_danger("[user] spasms as their arms go numb!"),
		span_userdanger("Your arms become paralyzed!"),
		span_hear("You hear a strange buzzing sound!"),
	)

	spawn(50)
		if(user && !QDELETED(user))
			user.remove_traits(list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM))

/obj/item/coin/disarming/proc/disarm_area(mob/living/user)
	var/turf/center = get_turf(user)
	if(!center)
		return

	var/obj/effect/temp_lz/V = new(center)

	playsound(user.loc, 'sound/items/coinflip.ogg', 50, TRUE)

	spawn(5)
		if(V && !QDELETED(V))
			qdel(V)

		for(var/mob/living/target in range(1, center))
			if(target == user)
				continue
			target.add_traits(list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM))
			target.visible_message(
				span_danger("[target] spasms as their arms go numb!"),
				span_userdanger("Your arms become paralyzed!"),
				span_hear("You hear a strange buzzing sound!"),
			)

			spawn(50)
				if(target && !QDELETED(target))
					target.remove_traits(list(TRAIT_PARALYSIS_L_ARM, TRAIT_PARALYSIS_R_ARM))

// COLOSSUS COIN

/obj/item/coin/colossus
	name = "Colossus coin"
	desc = "A massive coin that alters your stature. Flip to become giant or dwarf."
	icon = 'icons/obj/economy.dmi'
	icon_state = "colossus_front"
	item_flags = NOBLUDGEON

	var/last_used = 0
	var/cooldown_time = 600

/obj/item/coin/colossus/Initialize(mapload)
	. = ..()
	last_used = -cooldown_time
	icon_state = "colossus_front"

/obj/item/coin/colossus/attack_self(mob/living/user)
	if(!user || !user.loc)
		return
	if(!ishuman(user))
		to_chat(user, span_warning("Only humans can use this coin!"))
		return
	if(world.time < last_used + cooldown_time)
		to_chat(user, span_notice("The coin is still recharging..."))
		return
	last_used = world.time
	flip_coin(user)

/obj/item/coin/colossus/proc/flip_coin(mob/living/user)
	if(rand(0, 1))
		to_chat(user, span_warning("Heads: Giant Form!"))
		icon_state = "colossus_front"
		giant_form(user)
	else
		to_chat(user, span_good("Tails: Dwarf Form!"))
		icon_state = "colossus_back"
		dwarf_form(user)

/obj/item/coin/colossus/proc/giant_form(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	H.add_traits(list(TRAIT_CHUNKYFINGERS, TRAIT_PUSHIMMUNE, TRAIT_STUNIMMUNE))
	H.reagents.add_reagent(/datum/reagent/growthserum, 50)

	H.visible_message(
		span_danger("[H] grows to massive size!"),
		span_userdanger("You feel enormous and powerful!"),
		span_hear("You hear a deep rumbling sound!"),
	)

	spawn(300)
		if(H && !QDELETED(H))
			H.remove_traits(list(TRAIT_CHUNKYFINGERS, TRAIT_PUSHIMMUNE, TRAIT_STUNIMMUNE))
			H.reagents.remove_reagent(/datum/reagent/growthserum, 50)

/obj/item/coin/colossus/proc/dwarf_form(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	H.add_traits(list(TRAIT_DWARF))

	H.visible_message(
		span_warning("[H] shrinks to a small size!"),
		span_warning("You feel small and vulnerable!"),
		span_hear("You hear a high-pitched tinkling sound!"),
	)

	spawn(300)
		if(H && !QDELETED(H))
			H.remove_traits(list(TRAIT_DWARF))

// PHANTOM COIN

/obj/item/coin/phantom
	name = "Shadow Weave coin"
	desc = "A ghostly coin that alters your perception. Flip to blind yourself or become ethereal."
	icon = 'icons/obj/economy.dmi'
	icon_state = "shadow_weave_front"
	item_flags = NOBLUDGEON

	var/last_used = 0
	var/cooldown_time = 300

/obj/item/coin/phantom/Initialize(mapload)
	. = ..()
	last_used = -cooldown_time
	icon_state = "shadow_weave_front"

/obj/item/coin/phantom/attack_self(mob/living/user)
	if(!user || !user.loc)
		return
	if(!ishuman(user))
		to_chat(user, span_warning("Only humans can use this coin!"))
		return
	if(world.time < last_used + cooldown_time)
		to_chat(user, span_notice("The coin is still recharging..."))
		return
	last_used = world.time
	flip_coin(user)

/obj/item/coin/phantom/proc/flip_coin(mob/living/user)
	if(rand(0, 1))
		to_chat(user, span_warning("Heads: Blindness!"))
		icon_state = "shadow_weave_back"
		blind_self(user)
	else
		to_chat(user, span_good("Tails: Ethereal Form!"))
		icon_state = "shadow_weave_front"
		ethereal_form(user)

/obj/item/coin/phantom/proc/blind_self(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	H.adjust_temp_blindness(10 SECONDS)

	H.visible_message(
		span_danger("[H] clutches their eyes in pain!"),
		span_userdanger("Your vision goes completely dark!"),
		span_hear("You hear a strange clicking sound!"),
	)

/obj/item/coin/phantom/proc/ethereal_form(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/H = user

	H.alpha = 20
	H.update_icon()

	H.visible_message(
		span_danger("[H] becomes semi-transparent!"),
		span_userdanger("You feel ethereal and ghostly!"),
		span_hear("You hear a soft whispering sound!"),
	)

	spawn(50)
		if(H && !QDELETED(H))
			H.alpha = 255
			H.update_icon()

// SILENCE COIN

/obj/item/coin/silence
	name = "Silence coin"
	desc = "A hushed coin that steals voices. Flip to silence yourself or enemies nearby."
	icon = 'icons/obj/economy.dmi'
	icon_state = "silence_front"
	item_flags = NOBLUDGEON

	var/last_used = 0
	var/cooldown_time = 200

/obj/item/coin/silence/Initialize(mapload)
	. = ..()
	last_used = -cooldown_time
	icon_state = "silence_front"

/obj/item/coin/silence/attack_self(mob/living/user)
	if(!user || !user.loc)
		return
	if(world.time < last_used + cooldown_time)
		to_chat(user, span_notice("The coin is still recharging..."))
		return
	last_used = world.time
	flip_coin(user)

/obj/item/coin/silence/proc/flip_coin(mob/living/user)
	if(rand(0, 1))
		to_chat(user, span_warning("Heads: Self-Silence!"))
		icon_state = "silence_back"
		silence_self(user)
	else
		to_chat(user, span_good("Tails: Area Silence!"))
		icon_state = "silence_front"
		silence_area(user)

/obj/item/coin/silence/proc/silence_self(mob/living/user)
	user.add_traits(list(TRAIT_MUTE))
	user.visible_message(
		span_danger("[user] clutches their throat, unable to speak!"),
		span_userdanger("You lose your voice!"),
		span_hear("You hear a soft hushing sound!"),
	)

	spawn(150)
		if(user && !QDELETED(user))
			user.remove_traits(list(TRAIT_MUTE))

/obj/item/coin/silence/proc/silence_area(mob/living/user)
	var/turf/center = get_turf(user)
	if(!center)
		return

	var/obj/effect/temp_lz/V = new(center)

	playsound(user.loc, 'sound/items/coinflip.ogg', 50, TRUE)

	spawn(5)
		if(V && !QDELETED(V))
			qdel(V)

		for(var/mob/living/target in range(1, center))
			if(target == user)
				continue
			target.add_traits(list(TRAIT_MUTE))
			target.visible_message(
				span_danger("[target] clutches their throat, unable to speak!"),
				span_userdanger("You lose your voice!"),
				span_hear("You hear a soft hushing sound!"),
			)

			spawn(150)
				if(target && !QDELETED(target))
					target.remove_traits(list(TRAIT_MUTE))

/datum/quirk/deadlocks_gambit
	name = "Deadlock's Gambit"
	desc = "Your fate is forever tied to a mysterious coin. You can't remember where you got it, but you can't seem to lose it either."
	icon = FA_ICON_COINS
	value = 6
	gain_text = span_warning("A strange coin materializes in your pocket. It feels... decisive.")
	lose_text = span_notice("The coin is gone. For better or worse, your fate is your own again.")
	medical_record_text = "Patient exhibits compulsive attachment to a single randomised object of uncertain origin."
	medical_symptom_text = "Subject carries a mysterious coin at all times, frequently flipping it \
		to make decisions. Shows signs of magical thinking and probability bias."

/datum/quirk/deadlocks_gambit/add(mob/living/L)
	var/list/coins = list(
		/obj/item/coin/piano,
		/obj/item/coin/disarming,
		/obj/item/coin/colossus,
		/obj/item/coin/phantom,
		/obj/item/coin/silence,
	)

	var/coin_type = pick(coins)
	var/obj/item/coin/C = new coin_type(quirk_holder.loc)

	if(quirk_holder && !QDELETED(quirk_holder))
		quirk_holder.put_in_hands(C)
		to_chat(quirk_holder, span_notice("You find [C] in your pocket..."))
