// How many times we try to generate the code
#define MAX_CODEGEN_RETRY_ATTEMPTS 5
// There are 10 digits
#define DIGIT_COUNT 10
/** A code-cracking puzzle gizmo
 * 	First, the user must pulse activate_puzzle - this randomizes the code and resets the attempt counter.
 * 	The user may pulse activate_puzzle a limited amount of times again to retry it.
 *
 * 	Next, the user needs to input a code.
 * 	Imagine a row of knobs, each of them with 10 notches, and a head that rotates the knobs.
 *  Pulsing cycle_position moves the head right,
 * 	pulsing cycle_digit makes the head bump the knob by 1 notch.
 *  If the head reaches the rightmost position, then cycle_position resets it, moving it back left.
 *  Similarly, pulsing cycle_digit when the knob is already in the rightmost notch resets it to the leftmost one.
 *
 * 	Finally, the user has to pulse try_crack to check if their input is correct.
 * 	If it's correct, a reward is dispensed and the puzzle gets deactivated.
 *  If it's not, some sort of feedback is provided.
 * 	If the user takes too many attempts to solve the code, they are punished.
 *
 * 	There may be restrictions set upon the code.
 * 	These are checked upon code generation and cracking attempt.
 */
/datum/gizmodes/code_crack
	abstract_type = /datum/gizmodes/code_crack
	guaranteed_active_gizmodes = list(
		/datum/gizpulse/activate_puzzle,
		/datum/gizpulse/cycle_position,
		/datum/gizpulse/cycle_digit,
		/datum/gizpulse/try_crack,
	)

	mode_pulses = list(
		/datum/gizpulse/mode_controle/direct_activate,
	)
	// Sound that plays upon puzzle activation
	var/init_jingle = "sound/machines/terminal/terminal_processing.ogg"
	// How many times you can activate the code-cracking puzzle
	var/puzzles_left = 3
	// How many attempts the user has to crack the code before the gizmo starts punishing them
	var/attempts_left = 10

	// Whether the puzzle is currently active
	var/active = FALSE
	// Code length
	var/code_length = 2
	// Solution to current puzzle
	var/list/solution = list(0, 0, 0, 0,)
	// Current code cracking input
	var/list/code_input = list(0, 0, 0, 0,)
	// Which position in the code is currently being cycled
	var/position = 0

	var/list/loot_table = null

// Proc that generates the code (solution to the puzzle)
// We retry generation if the code happened to be invalid
// Returns TRUE if generation was successful and FALSE otherwise
/datum/gizmodes/code_crack/proc/generate_code()
	SHOULD_CALL_PARENT(TRUE)
	solution.Cut()
	solution.len = code_length
	for(var/i in 1 to MAX_CODEGEN_RETRY_ATTEMPTS)
		for(var/j in 1 to code_length)
			solution[j] = rand(0, 9) // Randomize every digit
		if(validate_code(solution))
			return TRUE
	return FALSE

// Proc that checks if code is valid or not (matches the restrictions)
/datum/gizmodes/code_crack/proc/validate_code(list/code)
	// Restrictions are defined by the subtype
	return TRUE

// Proc that checks if user input matches the solution
/datum/gizmodes/code_crack/proc/check_code()
	for(var/i in 1 to code_length)
		if(code_input[i] != solution[i])
			return FALSE
	return TRUE

// Proc to dispense the reward from the loot table
/datum/gizmodes/code_crack/proc/dispense_reward(atom/movable/holder)
	SHOULD_CALL_PARENT(TRUE)
	var/loot = pick_weight_recursive(loot_table)
	new loot(get_turf(holder))
	playsound(holder,"sound/machines/machine_vend.ogg", 100)

// Proc that punishes the user when they go over the attempt limit
// Technically, user can try to crack the code as many times as they want, as long as they can endure the punishment
/datum/gizmodes/code_crack/proc/punishment(atom/movable/holder)
	// Punishment has to be defined by the subtype
	return

// Proc that produces feedback when the user inputs an incorrect code
// By default, all of these gizmos tell the user how many attempts are left
/datum/gizmodes/code_crack/proc/feedback(atom/movable/holder)
	SHOULD_CALL_PARENT(TRUE)
	// This is kind of ass, but there's probably no way around it
	var/static/list/digit_to_name = list("one", "two", "three", "four", "five", "six", "seven", "eight", "nine")
	if(attempts_left <= 0 || attempts_left >= 10)
		return
	playsound(holder, "sound/announcer/vox_fem/[digit_to_name[attempts_left]].ogg", 100)
	holder.say(digit_to_name[attempts_left])

// Proc that resets user input
/datum/gizmodes/code_crack/proc/reset_input()
	code_input.Cut()
	code_input.len = code_length // stretch it
	for(var/i in 1 to code_length)
		code_input[i] = 0 // Fill it with zeroes
	position = initial(position)

// Gizpulses

// Gizpulse to activate the puzzle
/datum/gizpulse/activate_puzzle/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/datum/gizmodes/code_crack/puzzle_holder = astype(master)
	if(!puzzle_holder)
		return
	// If the puzzle cannot be retried, produce a bad buzz and stop
	if(puzzle_holder.puzzles_left <= 0)
		playsound(holder, "sound/machines/uplink/uplinkerror.ogg", 100)
		return
	// If it can be tried again (or is launched for the first time), do what we gotta do
	if(!puzzle_holder.generate_code()) // Code generation may fail, if the restrictions are too severe
		playsound(holder, "sound/items/ceramic_break.ogg", 100)
		return
	playsound(holder, puzzle_holder.init_jingle, 100)
	puzzle_holder.puzzles_left--
	puzzle_holder.active = TRUE
	puzzle_holder.reset_input()
	puzzle_holder.attempts_left = initial(puzzle_holder.attempts_left)

// Gizpulse to cycle the currently selected position
// Example (if code_input is 0000):
// 0000 -> 0000
// ^		^
/datum/gizpulse/cycle_position/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/datum/gizmodes/code_crack/puzzle_holder = astype(master)
	if(!puzzle_holder)
		return
	if(!puzzle_holder.active) // If the puzzle is inactive, produce a loud buzz and get out
		playsound(holder,"sound/machines/scanner/scanbuzz.ogg", 100)
		return
	// Cycle position: 0 -> 1 -> 2 -> .. -> (code_length - 1) -> reset back to 0
	puzzle_holder.position = (puzzle_holder.position + 1) % puzzle_holder.code_length

	// If we simply bumped the position by 1, produce a single piston-move sound
	if(puzzle_holder.position != 0)
		playsound(holder, "sound/machines/eject.ogg", 100)
		return
	// Otherwise, produce a different sound, indicating the position has been reset
	playsound(holder, "sound/items/weapons/autoguninsert.ogg", 100)

// Gizpulse to cycle the currently selected digit
// Example (if second digit is selected and code_input is 0000):
//	0000 -> 0100
//   ^		 ^
/datum/gizpulse/cycle_digit/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/datum/gizmodes/code_crack/puzzle_holder = astype(master)
	if(!puzzle_holder)
		return
	if(!puzzle_holder.active) // If the puzzle is inactive, produce a loud buzz and get out
		playsound(holder,"sound/machines/scanner/scanbuzz.ogg", 100)
		return

	// List indices start with 1, so we add 1 here
	var/position = puzzle_holder.position + 1
	var/previous_digit = puzzle_holder.code_input[position]
	// Cycle the digit
	puzzle_holder.code_input[position] = (previous_digit + 1) % DIGIT_COUNT

	// If we simply bumped the digit by 1, produce a single click
	if(previous_digit != DIGIT_COUNT - 1)
		playsound(holder, "sound/machines/creak.ogg", 100)
		return
	// Otherwise, produce a different sound, indicating the digit has been reset
	playsound(holder, "sound/items/reel/reel4.ogg", 100)

// Gizpulse that actually cracks the code
/datum/gizpulse/try_crack/activate(atom/movable/holder, datum/gizmodes/master, datum/gizmo_interface/interface)
	var/datum/gizmodes/code_crack/puzzle_holder = astype(master)
	if(!puzzle_holder)
		return
	if(!puzzle_holder.active) // If the puzzle is inactive, produce a loud buzz and get out
		playsound(holder,"sound/machines/scanner/scanbuzz.ogg", 100)
		return

	// If the input is invalid, emit an invalid-input sound and let the user make corrections
	var/validity = puzzle_holder.validate_code(puzzle_holder.code_input)
	if(!validity)
		playsound(holder, "sound/machines/terminal/terminal_error.ogg", 100)
		return

	// If the input is correct, dispense a reward and reset the puzzle
	var/correctness = puzzle_holder.check_code()
	if(correctness)
		puzzle_holder.dispense_reward(holder)
		puzzle_holder.active = FALSE
		return

	// If the input is incorrect..
	puzzle_holder.attempts_left--
	if(puzzle_holder.attempts_left <= 0)
		puzzle_holder.punishment(holder)
	puzzle_holder.feedback(holder)
	puzzle_holder.reset_input()
	// Play the input reset sound
	playsound(holder, "sound/machines/terminal/terminal_eject.ogg", 100)

// Tutorial version
// Restrictions: none
// Code length: 2
// Feedback: over/under
// Punishment: evil rat
// Loot: cheese
// Also, dispenses a hard-mode code-crack gizmo upon completion
/datum/gizmodes/code_crack/tutorial
	loot_table = list(
		list( // Cheese slices
			/obj/item/food/cheese/firm_cheese_slice = 1,
			/obj/item/food/cheese/wedge = 1,
		) = 39,
		/obj/item/food/cheese/wheel = 20, // Normal cheese
		list( // Firm cheese
			/obj/item/food/cheese/curd_cheese = 1,
			/obj/item/food/cheese/cheese_curds = 1,
			/obj/item/food/cheese/firm_cheese = 1,
		) = 20,
		/obj/item/food/cheese/mozzarella = 20, // Mozzarella
		/obj/item/food/cheese/royal = 1, // Royal
	)
	var/dispensed_hardmode = FALSE

/datum/gizmodes/code_crack/tutorial/dispense_reward(atom/movable/holder)
	if(!dispensed_hardmode)
		dispensed_hardmode = TRUE
		// Hard-mode
		new /obj/item/gizmo/moo(get_turf(holder))
	..()

/datum/gizmodes/code_crack/tutorial/feedback(atom/movable/holder)
	for(var/i in 1 to code_length)
		if(code_input[i] < solution[i])
			playsound(holder, "sound/machines/defib/defib_saftyOff.ogg", 100)
			holder.visible_message(span_notice("[holder] pings low."))
		else if(code_input[i] > solution[i])
			playsound(holder, "sound/machines/defib/defib_saftyOn.ogg", 100)
			holder.visible_message(span_notice("[holder] pings high."))
		else
			playsound(holder, "sound/machines/defib/defib_ready.ogg", 100)
			holder.visible_message(span_notice("[holder] pings affirmatively."))
		sleep(0.5 SECONDS)
	..()

/datum/gizmodes/code_crack/tutorial/punishment(atom/movable/holder)
	// Evil rat
	new /mob/living/basic/mouse/rat(get_turf(holder))

// Hardmode
// Restrictions: all digits must be unique
// Code length: 2-3
// Feedback: bulls and cows (number of correctly placed digits, number of incorrectly placed digits that are included in the code)
// Punishment: explosion
// Loot: all sorts of stuff
/datum/gizmodes/code_crack/moo
	// Moo
	init_jingle = "sound/mobs/non-humanoids/cow/cow.ogg"
	loot_table = /obj/structure/closet/crate/secure/loot::possible_loot
	var/min_code_length = 2
	var/max_code_length = 3

// All digits must be unique
/datum/gizmodes/code_crack/moo/validate_code(code)
	for(var/i in 1 to code_length)
		for(var/j in 1 to i-1)
			if(code[i] == code[j])
				return FALSE
	return TRUE

/datum/gizmodes/code_crack/moo/generate_code()
	code_length = rand(min_code_length, max_code_length)
	return ..()

/datum/gizmodes/code_crack/moo/feedback(atom/movable/holder)
	var/bulls = 0
	var/cows = 0
	for(var/i in 1 to code_length)
		for(var/j in 1 to code_length)
			if(code_input[i] == solution[j])
				if(i == j) 	// Digit is correct and correctly placed
					bulls++
				else	 	// Digit is correct, but incorrectly placed
					cows++
				break
	// Bull beeps, cow beeps and the sound from parent call shouldn't play simultaneously, so sleep() is probably unavoidable here
	for(var/i in 1 to bulls)
		playsound(holder, "sound/machines/synth/synth_yes.ogg", 100)
		sleep(0.25 SECONDS)
	for(var/i in 1 to cows)
		playsound(holder, "sound/machines/synth/synth_no.ogg", 100)
		sleep(0.25 SECONDS)

	holder.visible_message(span_notice("[holder] emits [bulls] high-pitched beeps and [cows] low-pitched ones."))

	..()

/datum/gizmodes/code_crack/moo/punishment(atom/movable/holder)
	var/obj/item/grenade/syndieminibomb/punishment = new(get_turf(holder))
	punishment.arm_grenade(null, 5 SECONDS)
	qdel(holder)

#undef MAX_CODEGEN_RETRY_ATTEMPTS
#undef DIGIT_COUNT
