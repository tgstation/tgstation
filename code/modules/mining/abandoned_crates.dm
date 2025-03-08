//Originally coded by ISaidNo, later modified by Kelenius. Ported from Baystation12.

/obj/structure/closet/crate/secure/loot
	name = "abandoned crate"
	desc = "What could be inside?"
	icon_state = "securecrate"
	base_icon_state = "securecrate"
	integrity_failure = 0 //no breaking open the crate
	var/code = null
	var/lastattempt = null
	var/attempts = 10
	var/codelen = 4
	var/qdel_on_open = FALSE
	var/spawned_loot = FALSE
	tamperproof = 90

	// Stop people from "diving into" the crate accidentally, and then detonating it.
	divable = FALSE

/obj/structure/closet/crate/secure/loot/Initialize(mapload)
	. = ..()
	var/list/digits = list("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
	code = ""
	for(var/i in 1 to codelen)
		var/dig = pick(digits)
		code += dig
		digits -= dig  //there are never matching digits in the answer

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/closet/crate/secure/loot/attack_hand(mob/user, list/modifiers)
	if(locked)
		to_chat(user, span_notice("The crate is locked with a Deca-code lock."))
		var/input = input(usr, "Enter [codelen] digits. All digits must be unique.", "Deca-Code Lock", "") as text|null
		if(user.can_perform_action(src) && locked)
			var/list/sanitised = list()
			var/sanitycheck = TRUE
			var/char = ""
			var/length_input = length(input)
			for(var/i = 1, i <= length_input, i += length(char)) //put the guess into a list
				char = input[i]
				sanitised += text2num(char)
			for(var/i in 1 to length(sanitised) - 1) //compare each digit in the guess to all those following it
				for(var/j in i + 1 to length(sanitised))
					if(sanitised[i] == sanitised[j])
						sanitycheck = FALSE //if a digit is repeated, reject the input
			if(input == code)
				if(!spawned_loot)
					spawn_loot()
				tamperproof = 0 // set explosion chance to zero, so we dont accidently hit it with a multitool and instantly die
				togglelock(user)
			else if(!input || !sanitycheck || length(sanitised) != codelen)
				to_chat(user, span_notice("You leave the crate alone."))
			else
				to_chat(user, span_warning("A red light flashes."))
				lastattempt = input
				attempts--
				if(attempts == 0)
					boom(user)
		return

	return ..()

/obj/structure/closet/crate/secure/loot/click_alt(mob/living/user)
	attack_hand(user) //this helps you not blow up so easily by overriding unlocking which results in an immediate boom.
	return CLICK_ACTION_SUCCESS

/obj/structure/closet/crate/secure/loot/attackby(obj/item/W, mob/user)
	if(locked)
		if(W.tool_behaviour == TOOL_MULTITOOL)
			to_chat(user, span_notice("DECA-CODE LOCK REPORT:"))
			if(attempts == 1)
				to_chat(user, span_warning("* Anti-Tamper Bomb will activate on next failed access attempt."))
			else
				to_chat(user, span_notice("* Anti-Tamper Bomb will activate after [attempts] failed access attempts."))
			if(lastattempt != null)
				var/bulls = 0 //right position, right number
				var/cows = 0 //wrong position but in the puzzle

				var/lastattempt_char = ""
				var/length_lastattempt = length(lastattempt)
				var/lastattempt_it = 1

				var/code_char = ""
				var/length_code = length(code)
				var/code_it = 1

				while(lastattempt_it <= length_lastattempt && code_it <= length_code) // Go through list and count matches
					lastattempt_char = lastattempt[lastattempt_it]
					code_char = code[code_it]
					if(lastattempt_char == code_char)
						++bulls
					else if(findtext(code, lastattempt_char))
						++cows

					lastattempt_it += length(lastattempt_char)
					code_it += length(code_char)

				to_chat(user, span_notice("Last code attempt, [lastattempt], had [bulls] correct digits at correct positions and [cows] correct digits at incorrect positions."))
			return
	return ..()

/obj/structure/closet/crate/secure/loot/emag_act(mob/user, obj/item/card/emag/emag_card)
	. = ..()

	if(locked)
		boom(user) // no feedback since it just explodes, thats its own feedback
		return TRUE
	return

/obj/structure/closet/crate/secure/loot/togglelock(mob/user, silent = FALSE)
	if(!locked)
		. = ..() //Run the normal code.
		if(locked) //Double check if the crate actually locked itself when the normal code ran.
			//reset the anti-tampering, number of attempts and last attempt when the lock is re-enabled.
			tamperproof = initial(tamperproof)
			attempts = initial(attempts)
			lastattempt = null
		return
	if(tamperproof)
		return
	return ..()

/obj/structure/closet/crate/secure/loot/atom_deconstruct(disassembled = TRUE)
	if(locked)
		boom()
		return
	return ..()

/obj/structure/closet/crate/secure/loot/after_open(mob/living/user, force)
	. = ..()
	if(qdel_on_open)
		qdel(src)

/obj/structure/closet/crate/secure/loot/proc/spawn_loot()
	var/loot = rand(1,100) //100 different crates with varying chances of spawning
	switch(loot)
		if(1 to 5) //5% chance
			new /obj/item/reagent_containers/cup/glass/bottle/rum(src)
			new /obj/item/reagent_containers/cup/glass/bottle/whiskey(src)
			new /obj/item/reagent_containers/cup/glass/bottle/whiskey(src)
			new /obj/item/lighter(src)
			new /obj/item/reagent_containers/cup/glass/bottle/absinthe/premium(src)
			for(var/i in 1 to 3)
				new /obj/item/cigarette/rollie(src)
		if(6 to 10)
			new /obj/item/melee/skateboard/pro(src)
		if(11 to 15)
			new /mob/living/basic/bot/honkbot(src)
		if(16 to 20)
			new /obj/item/stack/ore/diamond(src, 10)
		if(21 to 25)
			for(var/i in 1 to 5)
				new /obj/item/poster/random_contraband(src)
		if(26 to 30)
			new /obj/item/vending_refill/sovietsoda(src)
			var/obj/item/circuitboard/machine/vendor/board = new (src)
			board.set_type(/obj/machinery/vending/sovietsoda)
		if(31 to 35)
			new /obj/item/seeds/firelemon(src)
		if(36 to 40)
			for(var/i in 1 to 5)
				new /obj/item/toy/snappop/phoenix(src)
		if(41 to 45)
			new /obj/item/modular_computer/pda/clear(src)
		if(46 to 50)
			new /obj/item/storage/box/syndie_kit/chameleon/broken
		if(51 to 52) // 2% chance
			new /obj/item/melee/baton(src)
		if(53 to 54)
			new /obj/item/toy/balloon/corgi(src)
		if(55 to 56)
			var/newitem = pick(subtypesof(/obj/item/toy/mecha))
			new newitem(src)
		if(57 to 58)
			new /obj/item/toy/balloon/syndicate(src)
		if(59 to 60)
			new /obj/item/borg/upgrade/modkit/aoe/mobs(src)
			new /obj/item/clothing/suit/space(src)
			new /obj/item/clothing/head/helmet/space(src)
		if(61 to 62)
			for(var/i in 1 to 5)
				new /obj/item/clothing/head/costume/kitty(src)
				new /obj/item/clothing/neck/petcollar(src)
		if(63 to 64)
			new /obj/item/clothing/shoes/kindle_kicks(src)
		if(65 to 66)
			new /obj/item/clothing/suit/costume/wellworn_shirt/graphic/ian(src)
			new /obj/item/clothing/suit/hooded/ian_costume(src)
		if(67 to 68)
			var/obj/item/gibtonite/free_bomb = new /obj/item/gibtonite(src)
			free_bomb.quality = rand(GIBTONITE_QUALITY_LOW, GIBTONITE_QUALITY_HIGH)
			free_bomb.GibtoniteReaction(null, "A secure loot closet has spawned a live")
		if(69 to 70)
			new /obj/item/stack/ore/bluespace_crystal(src, 5)
		if(71 to 72)
			new /obj/item/toy/plush/snakeplushie(src)
		if(73 to 74)
			new /mob/living/basic/pet/gondola(src)
		if(75 to 76)
			new /obj/item/bikehorn/airhorn(src)
		if(77 to 78)
			new /obj/item/toy/plush/lizard_plushie(src)
		if(79 to 80)
			new /obj/item/stack/sheet/mineral/bananium(src, 10)
		if(81 to 82)
			new /obj/item/bikehorn/airhorn(src)
		if(83 to 84)
			new /obj/item/toy/plush/beeplushie(src)
		if(85 to 86)
			new /obj/item/defibrillator/compact(src)
		if(87) //1% chance
			var/list/cannabis_seeds = typesof(/obj/item/seeds/cannabis)
			var/list/cannabis_plants = typesof(/obj/item/food/grown/cannabis)
			for(var/i in 1 to rand(2, 4))
				var/seed_type = pick(cannabis_seeds)
				new seed_type(src)
			for(var/i in 1 to rand(2, 4))
				var/cannabis_type = pick(cannabis_plants)
				new cannabis_type(src)
		if(88)
			new /obj/item/reagent_containers/cup/glass/bottle/lizardwine(src)
		if(89)
			new /obj/item/melee/energy/sword/bananium(src)
		if(90)
			new /obj/item/dnainjector/wackymut(src)
		if(91)
			for(var/i in 1 to 30)
				new /mob/living/basic/cockroach(src)
		if(92)
			new /obj/item/katana(src)
		if(93)
			new /obj/item/dnainjector/xraymut(src)
		if(94)
			new /mob/living/basic/mimic/crate(src)
			qdel_on_open = TRUE
		if(95)
			new /obj/item/toy/plush/nukeplushie(src)
		if(96)
			new /obj/item/banhammer(src)
			for(var/i in 1 to 3)
				var/obj/effect/mine/sound/bwoink/mine = new (src)
				mine.set_anchored(FALSE)
				mine.move_resist = MOVE_RESIST_DEFAULT
		if(97)
			for(var/i in 1 to 4)
				new /obj/item/clothing/mask/balaclava(src)
			new /obj/item/gun/ballistic/shotgun/toy(src)
			new /obj/item/gun/ballistic/automatic/pistol/toy(src)
			new /obj/item/gun/ballistic/automatic/toy(src)
			new /obj/item/gun/ballistic/automatic/l6_saw/toy/unrestricted(src)
			new /obj/item/ammo_box/foambox(src)
		if(98)
			for(var/i in 1 to 3)
				new /mob/living/basic/bee/toxin(src)
		if(99)
			new /obj/item/implanter/sad_trombone(src)
		if(100)
			new /obj/item/melee/skateboard/hoverboard(src)
	spawned_loot = TRUE
