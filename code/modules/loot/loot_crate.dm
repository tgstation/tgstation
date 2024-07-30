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
	var/spawned_loot = FALSE
	tamperproof = 90

	/// Stop people from "diving into" the crate accidentally, and then detonating it.
	divable = FALSE
	/// Loot table weighted list
	var/list/possible_loot = list(
		/datum/loot/booze_n_cigs = 5,
		/obj/item/melee/skateboard/pro = 5,
		/mob/living/basic/bot/honkbot = 5,
		/datum/loot/diamond = 5,
		/datum/loot/posters = 5,
		/datum/loot/soda = 5,
		/obj/item/seeds/firelemon = 5,
		/datum/loot/snappop = 5,
		/obj/item/modular_computer/pda/clear = 5,
		/obj/item/storage/box/syndie_kit/chameleon/broken = 5,
		/obj/item/melee/baton = 2,
		/obj/item/toy/balloon/corgi = 2,
		/datum/loot/mecha_toy = 2,
		/obj/item/toy/balloon/syndicate = 2,
		/datum/loot/space_suit = 2,
		/datum/loot/cats = 2,
		/obj/item/clothing/shoes/kindle_kicks = 2,
		/datum/loot/ian = 2,
		/datum/loot/gibtonite = 2,
		/datum/loot/bscrystal = 2,
		/obj/item/toy/plush/snakeplushie = 2,
		/mob/living/basic/pet/gondola = 2,
		/obj/item/bikehorn/airhorn = 2,
		/obj/item/toy/plush/lizard_plushie = 2,
		/datum/loot/bananium = 2,
		/obj/item/toy/plush/beeplushie = 2,
		/obj/item/defibrillator/compact = 2,
		/obj/item/spess_knife = 2,
		/datum/loot/weed = 1,
		/obj/item/reagent_containers/cup/glass/bottle/lizardwine = 1,
		/obj/item/melee/energy/sword/bananium = 1,
		/obj/item/dnainjector/wackymut = 1,
		/datum/loot/cockroaches = 1,
		/obj/item/katana = 1,
		/obj/item/dnainjector/xraymut = 1,
		/datum/loot/mimic = 1,
		/obj/item/toy/plush/nukeplushie = 1,
		/datum/loot/banhammer = 1,
		/datum/loot/heist = 1,
		/datum/loot/bees = 1,
		/obj/item/implanter/sad_trombone = 1,
		/obj/item/melee/skateboard/hoverboard = 1,
	)

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
			if(input)
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

/obj/structure/closet/crate/secure/loot/proc/spawn_loot()
	var/loot = pick_weight(possible_loot)
	new loot (src)
	spawned_loot = TRUE
