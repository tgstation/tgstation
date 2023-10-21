/// Your mother appears to scold you.
/datum/hallucination/your_mother
	random_hallucination_weight = 2
	var/obj/effect/client_image_holder/hallucination/your_mother/mother

/datum/hallucination/your_mother/start()
	var/list/spawn_locs = list()
	for(var/turf/open/floor in view(hallucinator, 4))
		if(floor.is_blocked_turf(exclude_mobs = TRUE))
			continue
		spawn_locs += floor

	if(!length(spawn_locs))
		return FALSE
	var/turf/spawn_loc = pick(spawn_locs)
	mother = new(spawn_loc, hallucinator, src)
	mother.AddComponent(/datum/component/leash, owner = hallucinator, distance = get_dist(hallucinator, mother)) //basically makes mother follow them
	point_at(hallucinator)
	talk("[hallucinator]!!!!")
	var/list/scold_lines = list(
		pick(list("CLEAN YOUR ROOM THIS INSTANT!", "IT'S TIME TO WAKE UP FOR SCHOOL!!")),
		pick(list("YOU INSULT YOUR GRANDPARENTS!", "USELESS!")),
		pick(list("I BROUGHT YOU INTO THIS WORLD, I CAN TAKE YOU OUT!!!", "YOU'RE GROUNDED!!")),
	)
	var/delay = 2 SECONDS
	for(var/line in scold_lines)
		addtimer(CALLBACK(src, PROC_REF(talk), line), delay)
		delay += 2 SECONDS
	addtimer(CALLBACK(src, PROC_REF(exit)), delay + 4 SECONDS)
	return TRUE

/datum/hallucination/your_mother/proc/point_at(atom/target)
	var/turf/tile = get_turf(target)
	if(!tile)
		return

	var/obj/visual = image('icons/hud/screen_gen.dmi', mother.loc, "arrow", FLY_LAYER)

	INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(flick_overlay_global), visual, list(hallucinator.client), 2.5 SECONDS)
	animate(visual, pixel_x = (tile.x - mother.x) * world.icon_size, pixel_y = (tile.y - mother.y) * world.icon_size, time = 1.7, easing = EASE_OUT)

/datum/hallucination/your_mother/proc/talk(text)
	var/plus_runechat = hallucinator.client?.prefs.read_preference(/datum/preference/toggle/enable_runechat)
	var/datum/language/understood_language = hallucinator.get_random_understood_language()
	var/spans = list(mother.speech_span)

	if(!plus_runechat)
		var/image/speech_overlay = image('icons/mob/effects/talk.dmi', mother, "default0", layer = ABOVE_MOB_LAYER)
		INVOKE_ASYNC(GLOBAL_PROC, GLOBAL_PROC_REF(flick_overlay_global), speech_overlay, list(hallucinator.client), 30)
	else
		hallucinator.create_chat_message(mother, understood_language, text, spans)

	var/message = hallucinator.compose_message(mother, understood_language, text, null, spans, visible_name = TRUE)
	to_chat(hallucinator, message)

/datum/hallucination/your_mother/proc/exit()
	qdel(src)

/datum/outfit/yourmother
	name = "Your Mother"

	uniform = /obj/item/clothing/under/color/jumpskirt/red
	neck = /obj/item/clothing/neck/beads
	shoes = /obj/item/clothing/shoes/sandal

/datum/outfit/yourmother/post_equip(mob/living/carbon/human/user, visualsOnly = FALSE)
	. = ..()
	user.set_hairstyle("Braided", update = TRUE) //get_dynamic_human_appearance uses bald dummies

/obj/effect/client_image_holder/hallucination/your_mother
	gender = FEMALE
	image_icon = 'icons/mob/simple/simple_human.dmi'
	name = "Your mother"
	desc = "She is not happy."
	image_state = ""

/obj/effect/client_image_holder/hallucination/your_mother/Initialize(mapload, list/mobs_which_see_us, datum/hallucination/parent)
	. = ..()
	var/mob/living/carbon/hallucinator = parent.hallucinator
	image_icon = getFlatIcon(get_dynamic_human_appearance(/datum/outfit/yourmother, hallucinator.dna.species.type))
	regenerate_image()
