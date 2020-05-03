///Vatbeasts are creatures from vatgrowing and are literaly a beast in a vat, yup.
/mob/living/simple_animal/hostile/vatbeast
	name = "Vatbeast"
	icon = 'icons/mob/vatgrowing.dmi'
	icon_state = "vat_beast"
	icon_dead = "vat_beast_dead"
	mob_biotypes = MOB_ORGANIC
	gender = NEUTER
	speak_emote = list("blorbles")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	var/obj/effect/proc_holder/tentacle_slap/tentacle_slap

/mob/living/simple_animal/hostile/vatbeast/Initialize()
	. = ..()
	tentacle_slap = new
	AddAbility(tentacle_slap)
	add_cell_sample()

/mob/living/simple_animal/hostile/vatbeast/tamed()
	. = ..()
	can_buckle = TRUE
	buckle_lying = FALSE
	var/datum/component/riding/D = LoadComponent(/datum/component/riding)
	D.set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 13), TEXT_SOUTH = list(0, 15), TEXT_EAST = list(-2, 12), TEXT_WEST = list(2, 12)))
	D.set_vehicle_dir_layer(SOUTH, ABOVE_MOB_LAYER)
	D.set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	D.set_vehicle_dir_layer(EAST, OBJ_LAYER)
	D.set_vehicle_dir_layer(WEST, OBJ_LAYER)
	D.drive_verb = "ride"
	D.override_allow_spacemove = TRUE

/mob/living/simple_animal/hostile/vatbeast/add_cell_sample()
	AddElement(/datum/element/swabable, CELL_LINE_TABLE_VATBEAST, CELL_VIRUS_TABLE_GENERIC_MOB, 1, 5)

///Ability that allows the owner to slap other mobs a short distance away
/obj/effect/proc_holder/tentacle_slap
	name = "Tentacle slap"
	desc = "Slap a creature with your tentacles."
	active = FALSE
	action_icon = 'icons/mob/actions/actions_animal.dmi'
	action_icon_state = "tentacle_slap"
	action_background_icon_state = "bg_revenant"
	var/cooldown = 12 SECONDS
	var/current_cooldown = 0

/obj/effect/proc_holder/tentacle_slap/Click(location, control, params)
	. = ..()
	if(!isliving(usr))
		return TRUE
	var/mob/living/user = usr
	fire(user)

/obj/effect/proc_holder/tentacle_slap/fire(mob/living/carbon/user)
	var/message
	if(current_cooldown > world.time)
		to_chat(user, "<span class='notice'>This ability is still on cooldown.</span>")
		return
	if(active)
		message = "<span class='notice'>You stop preparing to tentacle slap.</span>"
		remove_ranged_ability(message)
	else
		message = "<span class='notice'>You prepare your pimp-tentacle. <B>Left-click to slap a target!</B></span>"
		add_ranged_ability(user, message, TRUE)

/obj/effect/proc_holder/tentacle_slap/InterceptClickOn(mob/living/caller, params, atom/target)
	if(..())
		return

	if(!istype(ranged_ability_user, /mob/living/simple_animal/hostile/vatbeast) || ranged_ability_user.stat)
		remove_ranged_ability()
		return

	if(!caller.Adjacent(target))
		return

	if(!isliving(target))
		return

	var/mob/living/living_target = target

	var/mob/living/simple_animal/hostile/vatbeast/vatbeast = ranged_ability_user

	vatbeast.visible_message("<span class='warning>[vatbeast] slaps [living_target] with its tentacle!</span>", "<span class='notice'>You slap [living_target] with your tentacle.</span>")
	playsound(vatbeast, 'sound/effects/assslap.ogg', 70)
	var/atom/throw_target = get_edge_target_turf(target, vatbeast.dir)
	living_target.throw_at(throw_target, 6, 4, vatbeast)
	current_cooldown = world.time + cooldown
	remove_ranged_ability()

	return TRUE
