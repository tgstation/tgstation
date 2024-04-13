// Valentine's Day events //
// why are you playing spessmens on valentine's day you wizard //

#define VALENTINE_FILE "valentines.json"

// valentine / candy heart distribution //

/datum/round_event_control/valentines
	name = "Valentines!"
	holidayID = VALENTINES
	typepath = /datum/round_event/valentines
	weight = -1 //forces it to be called, regardless of weight
	max_occurrences = 1
	earliest_start = 0 MINUTES
	category = EVENT_CATEGORY_HOLIDAY
	description = "Puts people on dates! They must protect each other. \
		Some dates will have third wheels, and any odd ones out will be given the role of 'heartbreaker'."
	/// If TRUE, any odd candidate out will be given the role of "heartbreaker" and will be tasked with ruining the dates.
	var/heartbreaker = TRUE
	/// Probability that any given pair will be given a third wheel candidate
	var/third_wheel_chance = 4
	/// Items to give to all valentines
	var/list/items_to_give_out = list(
		/obj/item/paper/valentine,
		/obj/item/storage/fancy/heart_box,
		/obj/item/food/candyheart,
	)

/datum/round_event/valentines/proc/is_valid_valentine(mob/living/guy)
	if(guy.stat == DEAD)
		return FALSE
	if(isnull(guy.mind))
		return FALSE
	if(guy.onCentCom())
		return FALSE
	return TRUE

/datum/round_event/valentines/proc/give_valentines_things(mob/living/guy)
	var/datum/round_event_control/valentines/controller = control
	if(!istype(controller))
		return

	var/obj/item/storage/backpack/bag = locate() in guy.contents
	if(isnull(bag))
		return

	var/atom/drop_loc = guy.drop_location()
	for(var/thing_type in controller.items_to_give_out)
		var/obj/item/thing = new thing_type(drop_loc)
		if(!bag.atom_storage.attempt_insert(thing, override = TRUE, force = STORAGE_SOFT_LOCKED))
			guy.put_in_hands(thing)

/datum/round_event/valentines/proc/forge_valentines_objective(mob/living/lover, mob/living/date)
	var/datum/antagonist/valentine/valentine = new()
	valentine.date = date.mind
	lover.mind.special_role = "valentine"
	lover.mind.add_antag_datum(valentine) //These really should be teams but i can't be assed to incorporate third wheels right now

/datum/round_event/valentines/proc/forge_third_wheel(mob/living/sad_one, mob/living/date_one, mob/living/date_two)
	var/datum/antagonist/valentine/third_wheel/third_wheel = new()
	third_wheel.date = pick(date_one.mind, date_two.mind)
	sad_one.mind.special_role = "valentine"
	sad_one.mind.add_antag_datum(third_wheel)

/datum/round_event/valentines/start()
	var/datum/round_event_control/valentines/controller = control
	if(!istype(controller))
		return

	var/list/candidates = list()
	for(var/mob/living/player in GLOB.player_list)
		if(!is_valid_valentine(player))
			continue
		candidates += player

	var/list/mob/living/candidates_pruned = SSpolling.poll_candidates(
		question = "Do you want a Valentine?",
		group = candidates,
		poll_time = 30 SECONDS,
		flash_window = FALSE,
		start_signed_up = TRUE,
		alert_pic = /obj/item/storage/fancy/heart_box,
		custom_response_messages = list(
			POLL_RESPONSE_SIGNUP = "You have signed up for a date!",
			POLL_RESPONSE_ALREADY_SIGNED = "You are already signed up for a date.",
			POLL_RESPONSE_NOT_SIGNED = "You aren't signed up for a date.",
			POLL_RESPONSE_TOO_LATE_TO_UNREGISTER = "It's too late to decide against going on a date.",
			POLL_RESPONSE_UNREGISTERED = "You decide against going on a date.",
		),
		chat_text_border_icon = /obj/item/storage/fancy/heart_box,
	)

	for(var/mob/living/second_check as anything in candidates_pruned)
		if(is_valid_valentine(second_check))
			continue
		candidates_pruned -= second_check

	if(length(candidates_pruned) == 0)
		return
	if(length(candidates_pruned) == 1)
		to_chat(candidates_pruned[1], span_warning("You are the only one who wanted a Valentine..."))
		return

	while(length(candidates_pruned) >= 2)
		var/mob/living/date_one = pick_n_take(candidates_pruned)
		var/mob/living/date_two = pick_n_take(candidates_pruned)
		give_valentines_things(date_one)
		give_valentines_things(date_two)
		forge_valentines_objective(date_one, date_two)
		forge_valentines_objective(date_two, date_one)

		if((length(candidates_pruned) == 1 && !controller.heartbreaker) || (length(candidates_pruned) && prob(controller.third_wheel_chance)))
			var/mob/living/third_wheel = pick_n_take(candidates_pruned)
			give_valentines_things(third_wheel)
			forge_third_wheel(third_wheel, date_one, date_two)
			// Third wheel starts with a bouquet because that's funny
			var/third_wheel_bouquet = pick(typesof(/obj/item/bouquet))
			var/obj/item/bouquet = new third_wheel_bouquet(third_wheel.loc)
			third_wheel.put_in_hands(bouquet)

	if(controller.heartbreaker && length(candidates_pruned) == 1)
		candidates_pruned[1].mind.add_antag_datum(/datum/antagonist/heartbreaker)

/datum/round_event/valentines/announce(fake)
	priority_announce("It's Valentine's Day! Give a valentine to that special someone!")

/obj/item/paper/valentine
	name = "valentine"
	desc = "A Valentine's card! Wonder what it says..."
	icon = 'icons/obj/toys/playing_cards.dmi'
	icon_state = "sc_Ace of Hearts_syndicate" // shut up // bye felicia
	show_written_words = FALSE

/obj/item/paper/valentine/Initialize(mapload)
	default_raw_text = pick_list(VALENTINE_FILE, "valentines") || "A generic message of love or whatever."
	return ..()

/obj/item/food/candyheart
	name = "candy heart"
	icon = 'icons/obj/holiday/holiday_misc.dmi'
	icon_state = "candyheart"
	desc = "A heart-shaped candy that reads: "
	food_reagents = list(/datum/reagent/consumable/sugar = 2)
	junkiness = 5

/obj/item/food/candyheart/Initialize(mapload)
	. = ..()
	desc = pick(strings(VALENTINE_FILE, "candyhearts"))
	icon_state = pick("candyheart", "candyheart2", "candyheart3", "candyheart4")

#undef VALENTINE_FILE
