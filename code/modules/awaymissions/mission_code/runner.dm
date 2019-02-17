GLOBAL_VAR_INIT(vr_runner_active, 0)
GLOBAL_LIST_EMPTY(vr_runner_players)
GLOBAL_LIST_EMPTY(vr_runner_tiles)

/area/awaymission/vr/runner
	name = "VrRunner"
	icon_state = "awaycontent4"
	requires_power = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED

/datum/outfit/vr/runner
	name = "Runner Equipment"
	shoes = /obj/item/clothing/shoes/bhop

/obj/effect/portal/permanent/one_way/recall/pit_faller
	name = "Runner Portal"
	desc = "A game of eternal running, where one misstep means certain death."
	equipment = /datum/outfit/vr/runner
	recall_equipment = /datum/outfit/vr
	id = "vr runner"
	light_color = LIGHT_COLOR_FIRE
	light_power = 1
	light_range = 2
	var/game_starting = 0
	var/one_player = 0

/obj/effect/portal/permanent/one_way/recall/pit_faller/teleport(atom/movable/M, force = FALSE)
	if(GLOB.vr_runner_active)
		return FALSE
	. = ..()
	if(. && ishuman(M))
		GLOB.vr_runner_players += M
		if(!game_starting)
			INVOKE_ASYNC(src, .proc/game_start_countdown)

/obj/effect/portal/permanent/one_way/recall/pit_faller/proc/game_start_countdown(wait_seconds = 15)
	game_starting = 1
	for(var/seconds_remaining = wait_seconds to 1 step -1)
		if(GLOB.vr_runner_players.len == 0)
			return FALSE
		for(var/mob/living/carbon/human/H in GLOB.vr_runner_players)
			var/obj/effect/proc_holder/spell/portal_recall/findspell = locate(/obj/effect/proc_holder/spell/portal_recall) in H.mind.spell_list
			if(!findspell)
				GLOB.vr_runner_players -= H
				continue
			to_chat(H, "<span class='notice'>Game starting in [seconds_remaining].</span>")
		sleep(10)
	if(GLOB.vr_runner_players.len > 0)
		for(var/mob/living/carbon/human/H in GLOB.vr_runner_players)
			to_chat(H, "<span class='notice'>Game Started!</span>")
			var/turf/open/indestructible/runner/R = get_turf(H)
			INVOKE_ASYNC(R, /turf/open/indestructible/runner.proc/turf_fall)
		color = COLOR_RED
		GLOB.vr_runner_active = 1
		if(GLOB.vr_runner_players.len == 1)
			one_player = 1
		INVOKE_ASYNC(src, .proc/game_check_end_loop)
	game_starting = 0

/obj/effect/portal/permanent/one_way/recall/pit_faller/proc/game_check_end_loop()
	for(var/mob/living/carbon/human/H in GLOB.vr_runner_players)
		var/obj/effect/proc_holder/spell/portal_recall/findspell = locate(/obj/effect/proc_holder/spell/portal_recall) in H.mind.spell_list
		if(!findspell)
			GLOB.vr_runner_players -= H
	if(!one_player && GLOB.vr_runner_players.len <= 1)
		return end_game()
	if(GLOB.vr_runner_players.len == 0)
		return end_game()
	sleep(1)
	INVOKE_ASYNC(src, .proc/game_check_end_loop)


/obj/effect/portal/permanent/one_way/recall/pit_faller/proc/end_game()
	color = initial(color)
	GLOB.vr_runner_active = 0
	game_starting = 0
	for(var/turf/open/indestructible/runner/R in GLOB.vr_runner_tiles)
		R.reset_fall()
	for(var/mob/living/carbon/human/H in GLOB.vr_runner_players)
		to_chat(H, "<span class='notice'>You win!</span>")
		GLOB.vr_runner_players -= H
		var/obj/effect/proc_holder/spell/portal_recall/findspell = locate(/obj/effect/proc_holder/spell/portal_recall) in H.mind.spell_list
		findspell.Click(H)

/obj/effect/portal/permanent/one_way/destroy/pit_faller
	name = "Runner Exit Portal"
	id = "vr runner"

/turf/open/indestructible/runner
	name = "Shaky Ground"
	desc = "If you walk on that that you better keep running!"
	var/not_reset = 0 // check so turfs dont fall after being reset
	var/falling_time = 15 // time it takes for the turf to fall

/turf/open/indestructible/runner/Initialize()
	. = ..()
	GLOB.vr_runner_tiles += src

/turf/open/indestructible/runner/Entered(atom/movable/A)
	. = ..()
	if(isliving(A) && GLOB.vr_runner_active)
		if(color == COLOR_ALMOST_BLACK)
			if(locate(A) in GLOB.vr_runner_players)
				if(!A.throwing)
					var/mob/living/carbon/human/H = A
					GLOB.vr_runner_players -= H
					var/obj/effect/proc_holder/spell/portal_recall/findspell = locate(/obj/effect/proc_holder/spell/portal_recall) in H.mind.spell_list
					findspell.Click(H)
			else
				qdel(A)
		else if(color == initial(color))
			INVOKE_ASYNC(src, .proc/turf_fall)

/turf/open/indestructible/runner/proc/turf_fall()
	color = COLOR_RED
	not_reset = 1
	sleep(falling_time)
	if(!not_reset)
		return
	not_reset = 0
	color = COLOR_ALMOST_BLACK
	for(var/mob/living/carbon/human/H in GLOB.vr_runner_players)
		var/turf/open/indestructible/runner/R = get_turf(H)
		if(src == R)
			GLOB.vr_runner_players -= H
			var/obj/effect/proc_holder/spell/portal_recall/findspell = locate(/obj/effect/proc_holder/spell/portal_recall) in H.mind.spell_list
			findspell.Click(H)
	return

/turf/open/indestructible/runner/proc/reset_fall()
	not_reset = 0
	color = initial(color)
	return