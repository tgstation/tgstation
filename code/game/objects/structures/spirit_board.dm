/obj/structure/spirit_board
	name = "spirit board"
	desc = "A wooden board with letters etched into it, used in seances."
	icon = 'icons/obj/structures.dmi'
	icon_state = "spirit_board"
	resistance_flags = FLAMMABLE
	density = TRUE
	anchored = FALSE
	/// Whether no one has moved the planchette yet.
	var/virgin = TRUE //applies especially to admins
	/// How long between planchette movements.
	COOLDOWN_DECLARE(next_use)
	/// Where the planchette is currently pointing.
	var/planchette
	/// Ckey of last mob to use the board.
	var/lastuser = null
	/// List of options ghosts (or people) can pick from.
	var/list/ghosty_options = list(
		"A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z",
		"1","2","3","4","5","6","7","8","9","0",
		"Yes","No",
	)
	/// Number of living, willing mobs adjacent to the board required for a seance to occur.
	var/required_user_count = 2

/obj/structure/spirit_board/Initialize(mapload)
	. = ..()
	if(prob(1))
		name = "luigi board"
	planchette = ghosty_options[1]

/obj/structure/spirit_board/examine()
	. = ..()
	if(planchette)
		. += span_notice("The planchette is currently at the letter \"[planchette]\".")
	else
		. += span_notice("The planchette is in the middle of the board on no particular letter.")

/obj/structure/spirit_board/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return .
	spirit_board_pick_letter(user)
	return TRUE

/obj/structure/spirit_board/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(.)
		return .
	spirit_board_pick_letter(user)
	return TRUE

/obj/structure/spirit_board/proc/spirit_board_pick_letter(mob/ghost)
	if(!spirit_board_checks(ghost))
		return

	if(virgin)
		virgin = FALSE
		notify_ghosts("Someone has begun playing with \a [src] in [get_area(src)]!", source = src, header = "Spirit board")

	var/new_planchette = tgui_input_list(ghost, "Choose the letter.", "Seance!", ghosty_options)
	if(isnull(new_planchette))
		return
	if(!Adjacent(ghost) || !COOLDOWN_FINISHED(src, next_use))
		return
	planchette = new_planchette
	ghost.log_message("picked a letter on [src], which was \"[planchette]\".", LOG_GAME)
	COOLDOWN_START(src, next_use, rand(3 SECONDS, 5 SECONDS))
	lastuser = ghost.ckey
	for(var/mob/viewer in range(2, src))
		if(isnull(viewer.client))
			continue
		if(viewer.stat != CONSCIOUS && viewer.stat != DEAD) // You gotta be awake or dead to pay the toll
			continue
		if(viewer.is_blind())
			to_chat(viewer, span_hear("You hear a scraping sound..."))
		else
			to_chat(viewer, span_notice("The planchette slowly moves... and stops at the letter \"[planchette]\"."))

/obj/structure/spirit_board/proc/spirit_board_checks(mob/ghost)
	var/cd_penalty = (ghost.ckey == lastuser) ? 1 SECONDS : 0 SECONDS //Give some other people a chance, hog.

	if(next_use - cd_penalty > world.time)
		return FALSE //No feedback here, hiding the cooldown a little makes it harder to tell who's really picking letters.

	var/turf/play_turf = get_turf(src)
	if(play_turf?.get_lumcount() > 0.2)
		to_chat(ghost, span_warning("It's too bright here to use [src]!"))
		return FALSE

	if(required_user_count > 0)
		var/users_in_range = 0
		for(var/mob/living/player in orange(1, src))
			if(isnull(player.ckey) || isnull(player.client))
				continue

			if(player.client?.is_afk() || player.stat != CONSCIOUS || HAS_TRAIT(player, TRAIT_HANDS_BLOCKED))//no playing with braindeads or corpses or handcuffed dudes.
				to_chat(ghost, span_warning("[player] doesn't seem to be paying attention..."))
				continue

			users_in_range++

		if(users_in_range < required_user_count)
			to_chat(ghost, span_warning("There aren't enough people around to use [src]!"))
			return FALSE

	return TRUE
