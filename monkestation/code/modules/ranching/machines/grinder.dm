/obj/machinery/chicken_grinder
	name = "The Grinder"
	desc = "This is how chicken nuggets are made boys and girls."
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 500

	///placeholder
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "grinder"

	max_integrity = 300
	circuit = /obj/item/circuitboard/machine/chicken_grinder
	///the amount of chicken soul stored
	var/stored_chicken_soul = 0

	var/list/egg_types = list()

/obj/machinery/chicken_grinder/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/hovering_information, /datum/hover_data/chicken_grinder)
	register_context()

/obj/machinery/chicken_grinder/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	. = ..()
	context[SCREENTIP_CONTEXT_ALT_LMB] = "Try to create an egg."

/obj/machinery/chicken_grinder/attackby(obj/item/weapon, mob/user, params)
	. = ..()
	if(istype(weapon, /obj/item/chicken_carrier))
		var/obj/item/chicken_carrier/carrier = weapon

		if(!carrier.stored_chicken)
			return

		add_fingerprint(user)

		if(do_after(user, 1 SECONDS, target = src))
			SET_PLANE_EXPLICIT(carrier.stored_chicken, PLANE_TO_TRUE(initial(carrier.stored_chicken.plane)), src)
			carrier.stored_chicken.layer = initial(layer)
			carrier.stored_chicken.forceMove(src)
			carrier.stored_chicken = null
			carrier.update_appearance()

/obj/machinery/chicken_grinder/attack_hand(mob/user)
	if(machine_stat & (NOPOWER|BROKEN))
		return

	if(!anchored)
		to_chat(user, "<span class='notice'>[src] cannot be used unless bolted to the ground.</span>")
		return

	if(user.pulling && istype(user.pulling, /mob/living/basic/chicken))
		var/mob/living/L = user.pulling
		var/mob/living/basic/chicken/C = L
		if(C.buckled ||C.has_buckled_mobs())
			to_chat(user, "<span class='warning'>[C] is attached to something!</span>")
			return

		user.visible_message("<span class='danger'>[user] starts to put [C] into the gibber!</span>")

		add_fingerprint(user)

		if(do_after(user, 1 SECONDS, target = src))
			if(C && user.pulling == C && !C.buckled)
				user.visible_message("<span class='danger'>[user] stuffs [C] into the gibber!</span>")
				C.forceMove(src)
				update_icon()
	else
		start_grinding(user)

/obj/machinery/chicken_grinder/proc/start_grinding(mob/user)
	use_power(1000)
	visible_message("<span class='italics'>You hear a loud squelchy grinding sound.</span>")
	playsound(loc, 'sound/machines/juicer.ogg', 50, 1)
	update_icon()

	var/offset = prob(50) ? -2 : 2
	animate(src, pixel_x = pixel_x + offset, time = 0.2, loop = 200) //start shaking

	for(var/mob/living/basic/chicken/chicken as anything in contents)
		if(!istype(chicken))
			continue

		if(!(chicken.egg_type in egg_types))
			egg_types |= chicken.egg_type

		log_combat(user, chicken, "gibbed")
		chicken.death(1)
		chicken.ghostize()
		qdel(chicken)
		stored_chicken_soul += 20

	for(var/mob/living/basic/chick/chicken as anything in contents)
		if(!istype(chicken))
			continue

		log_combat(user, chicken, "gibbed")
		chicken.death(1)
		chicken.ghostize()
		qdel(chicken)
		stored_chicken_soul += 10

/obj/machinery/chicken_grinder/AltClick(mob/user)
	. = ..()
	var/choice = tgui_input_list(user, "Choose an egg type", src, egg_types)
	if(!choice)
		return
	if(stored_chicken_soul >= 40)
		new choice (src.loc)
		stored_chicken_soul -= 40
	else
		to_chat(user, span_notice("You don't have enough chicken essence to produce an egg"))

/datum/hover_data/chicken_grinder
	var/obj/effect/overlay/hover/text_holder

/datum/hover_data/chicken_grinder/New(datum/component/hovering_information, atom/parent)
	. = ..()
	text_holder = new(null)
	text_holder.maptext_width = 64
	text_holder.maptext_y = 32
	text_holder.maptext_x = -4

/datum/hover_data/chicken_grinder/setup_data(obj/machinery/chicken_grinder/source, mob/enterer)
	. = ..()
	text_holder.maptext = "Essence: [source.stored_chicken_soul]"
	var/image/new_image = new(source)
	new_image.appearance = text_holder.appearance
	SET_PLANE_EXPLICIT(new_image, new_image.plane, source)
	if(!isturf(source.loc))
		new_image.loc = source.loc
	else
		new_image.loc = source
	add_client_image(new_image, enterer.client)
