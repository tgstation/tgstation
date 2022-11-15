/obj/item/organ/internal/brain/psyker
	name = "psyker brain"
	desc = "This brain is blue, split into two hemispheres, and has immense psychic powers. Why does that even exist?"
	icon_state = "brain-psyker"

/obj/item/organ/internal/brain/psyker/Insert(mob/living/carbon/inserted_into, special, drop_if_replaced, no_id_transfer)
	if(!istype(inserted_into.get_bodypart(BODY_ZONE_HEAD), /obj/item/bodypart/head/psyker))
		return
	. = ..()
	inserted_into.AddComponent(/datum/component/echolocation)

/obj/item/bodypart/head/psyker
	limb_id = BODYPART_ID_PSYKER
	is_dimorphic = FALSE
	should_draw_greyscale = FALSE
	bodypart_traits = list(TRAIT_DISFIGURED, TRAIT_BALD, TRAIT_SHAVED, TRAIT_BLIND)

/mob/living/carbon/human/proc/psykerize()
	if(stat == DEAD || !get_bodypart(BODY_ZONE_HEAD))
		return
	to_chat(src, span_userdanger("You feel unwell..."))
	sleep(5 SECONDS)
	if(stat == DEAD || !get_bodypart(BODY_ZONE_HEAD))
		return
	to_chat(src, span_userdanger("It hurts!"))
	emote("scream")
	apply_damage(30, BRUTE, BODY_ZONE_HEAD)
	sleep(5 SECONDS)
	var/obj/item/bodypart/head/old_head = get_bodypart(BODY_ZONE_HEAD)
	var/obj/item/organ/internal/brain/old_brain = getorganslot(ORGAN_SLOT_BRAIN)
	var/obj/item/organ/internal/old_eyes = getorganslot(ORGAN_SLOT_EYES)
	var/obj/item/organ/internal/old_tongue = getorganslot(ORGAN_SLOT_TONGUE)
	if(stat == DEAD || !old_head || !old_brain)
		return
	to_chat(src, span_userdanger("Your head splits open! Your brain mutates!"))
	var/obj/item/bodypart/head/psyker/psyker_head = new()
	psyker_head.receive_damage(brute = 50)
	if(!psyker_head.replace_limb(src, special = TRUE))
		return
	qdel(old_head)
	var/obj/item/organ/internal/brain/psyker/psyker_brain = new()
	old_brain.before_organ_replacement(psyker_brain)
	old_brain.Remove(src, special = TRUE, no_id_transfer = TRUE)
	qdel(old_brain)
	psyker_brain.Insert(src, special = TRUE, drop_if_replaced = FALSE)
	if(old_eyes)
		qdel(old_eyes)
	if(old_tongue)
		var/obj/item/organ/internal/tongue/tied/new_tongue = new()
		new_tongue.Insert(src, special = TRUE, drop_if_replaced = FALSE)

/datum/component/echolocation
	var/echo_range = 4
	var/cooldown_time = 2 SECONDS
	var/image_expiry_time = 1.5 SECONDS
	var/fade_in_time = 0.5 SECONDS
	var/fade_out_time = 0.5 SECONDS
	var/list/images = list()
	var/static/list/saved_appearances = list()
	COOLDOWN_DECLARE(cooldown_last)

/datum/component/echolocation/Initialize()
	. = ..()
	var/mob/echolocator = parent
	if(!istype(echolocator))
		return COMPONENT_INCOMPATIBLE
	echolocator.overlay_fullscreen("echo", /atom/movable/screen/fullscreen/echo)
	START_PROCESSING(SSobj, src)

/datum/component/echolocation/Destroy(force, silent)
	STOP_PROCESSING(SSobj, src)
	return ..()

/datum/component/echolocation/process()
	var/mob/echolocator = parent
	if(!echolocator.client)
		return
	echolocate()

/datum/component/echolocation/proc/echolocate()
	if(!COOLDOWN_FINISHED(src, cooldown_last))
		return
	COOLDOWN_START(src, cooldown_last, cooldown_time)
	var/mob/echolocator = parent
	var/list/filtered = list()
	var/list/seen = oview(echo_range, echolocator)
	for(var/atom/seen_atom as anything in seen)
		if(seen_atom.invisibility > echolocator.see_invisible || !seen_atom.alpha)
			continue
		if(is_type_in_list(seen_atom, list(/turf/closed, /obj, /mob/living)))
			filtered += seen_atom
	if(!length(filtered))
		return
	var/current_time = "[world.time]"
	images[current_time] = list()
	for(var/atom/filtered_atom as anything in filtered)
		show_image(saved_appearances["[filtered_atom.icon]-[filtered_atom.icon_state]"] || generate_appearance(filtered_atom), filtered_atom, current_time)
	addtimer(CALLBACK(src, .proc/fade_images, current_time), image_expiry_time)

/datum/component/echolocation/proc/show_image(image/input_appearance, atom/input, current_time)
	var/mob/echolocator = parent
	var/image/final_image = image(input_appearance)
	final_image.layer += EFFECTS_LAYER
	final_image.plane = FULLSCREEN_PLANE
	final_image.loc = input
	final_image.dir = input.dir
	final_image.alpha = 0
	images[current_time] += final_image
	if(echolocator.client)
		echolocator.client.images += final_image
	animate(final_image, alpha = 255, time = fade_in_time)

/datum/component/echolocation/proc/generate_appearance(atom/input)
	var/mutable_appearance/copied_appearance = new /mutable_appearance()
	copied_appearance.appearance = input
	if(istype(input, /obj/machinery/door/airlock)) //i hate you
		copied_appearance.icon = 'icons/obj/doors/airlocks/station/public.dmi'
		copied_appearance.icon_state = "closed"
	copied_appearance.color = list(85, 85, 85, 0, 85, 85, 85, 0, 85, 85, 85, 0, 0, 0, 0, 1, -254, -254, -254, 0)
	copied_appearance.filters += outline_filter(size = 1, color = COLOR_WHITE)
	copied_appearance.pixel_x = 0
	copied_appearance.pixel_x = 0
	saved_appearances["[input.icon]-[input.icon_state]"] = copied_appearance
	return copied_appearance

/datum/component/echolocation/proc/fade_images(from_when)
	for(var/image_echo as anything in images[from_when])
		animate(image_echo, alpha = 0, time = fade_out_time)
	addtimer(CALLBACK(src, .proc/delete_images, from_when), fade_out_time)

/datum/component/echolocation/proc/delete_images(from_when)
	var/mob/echolocator = parent
	for(var/image_echo as anything in images[from_when])
		if(echolocator.client)
			echolocator.client.images -= image_echo
		qdel(image_echo)
	images -= from_when

/atom/movable/screen/fullscreen/echo
	icon_state = "echo"
