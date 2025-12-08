//Originally coded by ISaidNo, later modified by Kelenius. Ported from Baystation12.

/obj/structure/closet/crate/secure/loot
	name = "abandoned crate"
	desc = "What could be inside?"
	icon_state = "securecrate"
	base_icon_state = "securecrate"
	integrity_failure = 0 //no breaking open the crate
	var/code = null
	/// Associated list of previous attempts w/ bulls & cows
	var/list/previous_attempts = list()
	var/attempts = 10
	var/code_length = 4
	var/qdel_on_open = FALSE
	var/spawned_loot = FALSE
	tamperproof = 90
	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND

	divable = FALSE // Stop people from "diving into" the crate accidentally, and then detonating it.

	/// Possible loot from the crate, selected according to a weighted list: [typepath] = probability %
	var/list/possible_loot = list(
		list( // Toys & Entertainment
			/obj/item/melee/skateboard/pro = 5,
			/obj/effect/spawner/abandoned_crate/snappop = 5,
			/obj/effect/spawner/abandoned_crate/posters = 5,
			/obj/item/toy/balloon/corgi = 2,
			/obj/effect/spawner/abandoned_crate/mecha = 2,
			/obj/item/toy/balloon/syndicate = 2,
			/obj/item/toy/plush/snakeplushie = 2,
			/obj/item/bikehorn/airhorn = 2,
			/obj/item/toy/plush/beeplushie = 2,
			/obj/item/toy/plush/lizard_plushie = 2,
			/obj/item/toy/plush/nukeplushie = 1,
			/obj/effect/spawner/abandoned_crate/bwoink = 1,
			/obj/effect/spawner/abandoned_crate/pay_day = 1,
			/obj/item/melee/skateboard/hoverboard = 1,
			/obj/item/implanter/sad_trombone = 1,
			) = 34, // sum of weights inside list

		list( // Weapons & Combat
			/obj/item/melee/baton = 2,
			/obj/item/clothing/gloves/boxing/evil = 1,
			/obj/item/melee/energy/sword/bananium = 1,
			/obj/item/katana = 1,
			) = 5,

		list( // Clothing
			/obj/item/storage/box/syndie_kit/chameleon/broken = 5,
			/obj/item/clothing/shoes/kindle_kicks = 2,
			/obj/effect/spawner/abandoned_crate/kitty = 2,
			/obj/effect/spawner/abandoned_crate/space_suit = 2,
			/obj/effect/spawner/abandoned_crate/fursuit = 2,
			) = 13,

		list( // Tools & Equipment
			/obj/item/modular_computer/pda/clear = 5,
			/obj/item/defibrillator/compact = 2,
			) = 7,

		list( // Materials
			/obj/effect/spawner/abandoned_crate/diamonds = 5,
			/obj/effect/spawner/abandoned_crate/bluespace_crystal = 2,
			/obj/effect/spawner/abandoned_crate/bananium = 2,
			) = 9,

		list( // Seed & Plants
			/obj/item/seeds/firelemon = 5,
			/obj/effect/spawner/abandoned_crate/weed = 1,
			) = 6,

		list( // Consumables
			/obj/effect/spawner/abandoned_crate/booze = 5,
			/obj/effect/spawner/abandoned_crate/boda = 5,
			/obj/item/reagent_containers/cup/glass/bottle/lizardwine = 1,
			) = 11,

		list( // Mobs
			/mob/living/basic/bot/honkbot = 5,
			/mob/living/basic/pet/gondola = 2,
			/obj/effect/spawner/abandoned_crate/bloodroaches = 1,
			) = 8,

		list( // Medical & Science
			/obj/item/dnainjector/xraymut = 1,
			/obj/item/dnainjector/wackymut = 1,
			) = 2,

		list( // Dangerous
			/obj/effect/spawner/abandoned_crate/gibtonite = 2,
			/obj/effect/spawner/abandoned_crate/mimic = 1,
			/obj/effect/spawner/abandoned_crate/bees = 1,
			) = 4,

		list( // Misc
			/obj/effect/spawner/random/structure/closet_empty/crate = 1, //crate with crate
			) = 1,
		)

/obj/structure/closet/crate/secure/loot/Initialize(mapload)
	. = ..()
	code = generate_code(code_length)

/// Generates a random code of specified length with no repeating digits
/obj/structure/closet/crate/secure/loot/proc/generate_code(length)
	var/list/digits = list("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
	var/list/code_digits = list()

	for(var/i in 1 to length)
		if(!digits.len)
			break
		var/digit = pick(digits)
		code_digits += digit
		digits -= digit //there are never matching digits in the answer

	return code_digits.Join("")

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/structure/closet/crate/secure/loot/attack_hand(mob/user, list/modifiers)
	if(!locked)
		return ..()
	if(!user.can_perform_action(src))
		return

	var/input = tgui_input_text(user, title = "Deca-code lock", message = "Enter [code_length] digits. All digits must be unique.", max_length = code_length)

	if(input == code)
		if(!spawned_loot)
			spawn_loot()
		tamperproof = 0 // set explosion chance to zero, so we dont accidently hit it with a multitool and instantly die
		togglelock(user)
		SStgui.close_user_uis(user, src)
		return

	if(!validate_input(input))
		to_chat(user, span_notice("You leave the crate alone."))
		return

	to_chat(user, span_warning("A red light flashes."))
	previous_attempts += list(bulls_and_cows(input))
	attempts--

	if(attempts <= 0)
		boom(user)

/// Checks if user input is a valid code attempt
/obj/structure/closet/crate/secure/loot/proc/validate_input(input)
	if(!input || code_length != length(input))
		return FALSE

	var/list/used_digits = list()
	for(var/i = 1 to length(input))
		var/char = input[i]
		if(!(char >= "0" && char <= "9")) //if a non-digit is found, reject the input
			return FALSE
		if(char in used_digits) //if a digit is repeated, reject the input
			return FALSE
		used_digits += char

	return TRUE

/obj/structure/closet/crate/secure/loot/click_alt(mob/living/user)
	attack_hand(user) //this helps you not blow up so easily by overriding unlocking which results in an immediate boom.
	return CLICK_ACTION_SUCCESS

/obj/structure/closet/crate/secure/loot/ui_interact(mob/user, datum/tgui/ui)
	. = ..()

	// Attempt to update tgui ui, open and update if needed.
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AbandonedCrate", name)
		ui.open()

/obj/structure/closet/crate/secure/loot/ui_data(mob/user)
	var/list/data = list()

	data["previous_attempts"] = previous_attempts
	data["attempts_left"] = attempts

	return data

/obj/structure/closet/crate/secure/loot/multitool_act(mob/living/user, obj/item/tool)
	if(!locked)
		return
	if(Adjacent(user))
		ui_interact(user)

	return ITEM_INTERACT_SUCCESS

/// Implements bulls and cows algorithm to compare guess against actual code
/obj/structure/closet/crate/secure/loot/proc/bulls_and_cows(guess)
	var/bulls = 0
	var/cows = 0

	for(var/i = 1 to code_length)
		var/guess_char = guess[i]
		var/code_char = code[i]

		if(guess_char == code_char)
			bulls++
		else if(findtext(code, guess_char))
			cows++

	return list("attempt" = guess, "bulls" = bulls, "cows" = cows)

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
			previous_attempts = list()
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
	var/loot = pick_weight_recursive(possible_loot)
	new loot(src)
	spawned_loot = TRUE
