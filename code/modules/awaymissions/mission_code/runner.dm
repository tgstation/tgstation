GLOBAL_VAR_INIT(vr_runner_active, FALSE)
GLOBAL_LIST_EMPTY(vr_runner_players)
GLOBAL_LIST_EMPTY(vr_runner_tiles)

/area/awaymission/vr/runner
	name = "VrRunner"
	icon_state = "awaycontent5"

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
	light_range = 4
	var/game_starting = FALSE
	var/game_start_time = FALSE
	var/fall_wait = 5 // time in deciseconds between randomly falling tiles

/obj/effect/portal/permanent/one_way/recall/pit_faller/teleport(atom/movable/M, force = FALSE)
	if(GLOB.vr_runner_active)
		return FALSE
	if(!ishuman(M))
		return FALSE
	. = ..()
	if(.)
		var/mob/living/carbon/human/H = M
		GLOB.vr_runner_players += H
		if(!game_starting)
			INVOKE_ASYNC(src, .proc/game_start_countdown)

/obj/effect/portal/permanent/one_way/recall/pit_faller/recall_effect(mob/user)
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		GLOB.vr_runner_players -= H
		if(GLOB.vr_runner_active)
			if(!GLOB.vr_runner_players.len)
				to_chat(H, "<span class='notice'>You win! You survived for [(world.time - game_start_time) / 10] second\s.</span>")
				end_game()
			else
				to_chat(H, "<span class='notice'>You survived for [(world.time - game_start_time) / 10] seconds. [GLOB.vr_runner_players.len] other player(s) remained.</span>")

/obj/effect/portal/permanent/one_way/recall/pit_faller/proc/game_start_countdown(wait_seconds = 10)
	game_starting = TRUE
	for(var/seconds_remaining = wait_seconds to 1 step -1)
		if(!GLOB.vr_runner_players.len)
			game_starting = FALSE
			return FALSE
		for(var/mob/living/carbon/human/H in GLOB.vr_runner_players)
			to_chat(H, "<span class='notice'>Game starting in [seconds_remaining].</span>")
		sleep(10)
	if(GLOB.vr_runner_players.len)
		GLOB.vr_runner_active = TRUE
		for(var/mob/living/carbon/human/H in GLOB.vr_runner_players)
			to_chat(H, "<span class='notice'>Game Started!</span>")
			var/turf/open/indestructible/runner/R = get_turf(H)
			INVOKE_ASYNC(R, /turf/open/indestructible/runner.proc/turf_fall)
		color = COLOR_RED
		INVOKE_ASYNC(src, .proc/random_falling_tiles)
	game_starting = FALSE
	game_start_time = world.time

/obj/effect/portal/permanent/one_way/recall/pit_faller/proc/random_falling_tiles()
	if(!GLOB.vr_runner_active)
		return FALSE
	for(var/turf/open/indestructible/runner/R in GLOB.vr_runner_tiles)
		if(R.color != COLOR_ALMOST_BLACK && prob(1))
			INVOKE_ASYNC(R, /turf/open/indestructible/runner.proc/turf_fall)
	sleep(fall_wait)
	random_falling_tiles()

/obj/effect/portal/permanent/one_way/recall/pit_faller/proc/end_game()
	color = initial(color)
	GLOB.vr_runner_active = FALSE
	game_starting = FALSE
	for(var/turf/open/indestructible/runner/R in GLOB.vr_runner_tiles)
		R.reset_fall()

/obj/effect/portal/permanent/one_way/destroy/pit_faller
	name = "Runner Exit Portal"
	id = "vr runner"

/turf/open/indestructible/runner
	name = "Shaky Ground"
	desc = "If you walk on that that you better keep running!"
	var/not_reset = FALSE // check so turfs dont fall after being reset
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
					var/obj/effect/proc_holder/spell/portal_recall/findspell = locate(/obj/effect/proc_holder/spell/portal_recall) in H.mind.spell_list
					findspell.Click(H)
			else
				qdel(A)
		else if(!not_reset) // make sure it's not already currently falling
			INVOKE_ASYNC(src, .proc/turf_fall)

/turf/open/indestructible/runner/proc/turf_fall()
	color = COLOR_RED
	not_reset = TRUE
	sleep(falling_time)
	if(!not_reset)
		return
	not_reset = FALSE
	color = COLOR_ALMOST_BLACK
	for(var/mob/living/carbon/human/H in contents)
		var/obj/effect/proc_holder/spell/portal_recall/findspell = locate(/obj/effect/proc_holder/spell/portal_recall) in H.mind.spell_list
		if(H)
			findspell.Click(H)

/turf/open/indestructible/runner/proc/reset_fall()
	not_reset = FALSE
	color = initial(color)
	return
