/obj/effect/mob_spawn/human/superhero
	name = "cryostasis sleeper"
	desc = "A cryostasis sleeper containing somebody."
	icon = 'icons/obj/lavaland/spawners.dmi'
	icon_state = "cryostasis_sleeper"
	roundstart = FALSE
	death = FALSE
	show_flavour = FALSE
	anchored = TRUE
	density = FALSE
	mob_species = /datum/species/human
	short_desc = "You are a superhero."
	flavour_text = "You are a superhero aboard the OwlSkip. Help your fellow superheroes and catch those peskys villains!"
	assignedrole = "Superhero"
	outfit = /datum/outfit/superhero
	var/hero_role = "Coder's Fuckup"

/obj/effect/mob_spawn/human/superhero/Initialize()
	. = ..()
	notify_ghosts("[assignedrole]s are here! Click this button to become one.", source = src, action=NOTIFY_ATTACK, flashwindow = FALSE)

/obj/effect/mob_spawn/human/superhero/Destroy()
	new/obj/structure/fluff/empty_cryostasis_sleeper(get_turf(src))
	return ..()

/obj/effect/mob_spawn/human/superhero/special(mob/living/new_spawn)
	var/datum/antagonist/superhero/hero = new()
	hero.hero_role = hero_role
	new_spawn.mind.add_antag_datum(hero)
	hero.greet()
	message_admins("[ADMIN_LOOKUPFLW(new_spawn)] has been made into a [assignedrole].")
	log_game("[key_name(new_spawn)] was spawned as a [assignedrole]л.")

/obj/effect/mob_spawn/human/superhero/villain
	short_desc = "You are a supervillain."
	flavour_text = "You are a supervillain aboard the Dark Mothership. Help your fellow villins and catch those heroes!"
	assignedrole = "Supervillain"
	outfit = /datum/outfit/superhero/villain

/obj/effect/mob_spawn/human/superhero/villain/special(mob/living/new_spawn)
	var/datum/antagonist/supervillain/villain = new()
	villain.hero_role = hero_role
	new_spawn.mind.add_antag_datum(villain)

//Heroes

/obj/effect/mob_spawn/human/superhero/buzzon
	name = "BuzzOn's cryostasis sleeper"
	desc = "A cryostasis sleeper containing BuzzOn, the creator of the robotic bee suit. It smells of honey and flowers."

	outfit = /datum/outfit/superhero/buzzon_nude/spawner
	hero_role = "BuzzOn"

/obj/effect/mob_spawn/human/superhero/ianiser
	name = "Ianiser's cryostasis sleeper"
	desc = "A cryostasis sleeper containing Ianiser, the great electrofurry. It has a lot of dirt on it and is sparking a little."

	outfit = /datum/outfit/superhero/ianiser_spawner
	hero_role = "Ianiser"

/obj/effect/mob_spawn/human/superhero/owlman
	name = "Owlman's cryostasis sleeper"
	desc = "A cryostasis sleeper containing Owlman, the leader of the superhero team. It has a lot of scratches on it."

	outfit = /datum/outfit/superhero/owlman_nude
	hero_role = "Owlman"

//Villains

/obj/effect/mob_spawn/human/superhero/villain/skeledoom
	name = "SkeleDoom's cryostasis sleeper"
	desc = "A cryostasis sleeper containing an edgy teen looking like a skeleton. It's probably SkeleDoom."

	outfit = /datum/outfit/superhero/villain/skeledoom_nude/spawner
	hero_role = "SkeleDoom"

/obj/effect/mob_spawn/human/superhero/villain/nekometic
	name = "Nekometic's cryostasis sleeper"
	desc = "A cryostasis sleeper containing Nekometic. Is he a real catboy or just a pervert wearing an anime skirt?"

	outfit = /datum/outfit/superhero/villain/nekometic_nude
	hero_role = "Nekometic"

/obj/effect/mob_spawn/human/superhero/villain/griffin
	name = "Griffin's cryostasis sleeper"
	desc = "A cryostasis sleeper containing Griffin, the father of the Tide. It's covered in white feathers."

	outfit = /datum/outfit/superhero/villain/griffin_nude/spawner
	hero_role = "Griffin"

/// Hero and villain equippers

/obj/machinery/outfit_equipper
	name = "automatic equipper unit"
	desc = "An advanced suit storage unit, capable of equipping the user with it's contents."
	icon = 'icons/obj/machines/suit_storage.dmi'
	icon_state = "close"
	state_open = TRUE
	density = TRUE
	max_integrity = 250

	var/used = FALSE
	var/list/equip_options = list()

/obj/machinery/outfit_equipper/update_overlays()
	. = ..()
	if(state_open)
		if(machine_stat & BROKEN)
			. += "broken"
			return

		. += "open"
		return

	if(occupant)
		. += "human"
		return

/obj/machinery/outfit_equipper/attack_hand(mob/living/user)
	if(!istype(user) || user.body_position == LYING_DOWN || !Adjacent(user))
		return

	if(user == occupant)
		show_choice_panel(user)
		return

	if(!state_open)
		to_chat(user, "<span class='warning'>The unit is already occupied!</span>")
		return

	if(!is_operational)
		to_chat(user, "<span class='warning'>The unit is not operational!</span>")
		return

	if(used)
		to_chat(user, "<span class='warning'>The unit is empty!</span>")
		return

	if(!do_mob(user, src, 30))
		return

	user.visible_message("<span class='warning'>[user] enters [src] and the door closes behind [user.p_them()].</span>", "<span class=notice'>You enter [src] and look at the choice panel.</span>")
	close_machine(user)
	occupant = user
	add_fingerprint(user)
	show_choice_panel(user)

/obj/machinery/outfit_equipper/Exited(atom/movable/user)
	if (!state_open && user == occupant)
		container_resist_act(user)

/obj/machinery/outfit_equipper/relaymove(mob/living/user, direction)
	if (!state_open)
		container_resist_act(user)

/obj/machinery/outfit_equipper/container_resist_act(mob/living/user)
	visible_message("<span class='notice'>[occupant] exits [src].</span>",
		"<span class='notice'>You climb out of [src]!</span>")
	open_machine()

/obj/machinery/outfit_equipper/proc/show_choice_panel(mob/living/user)
	var/list/outfit_options = list()
	for(var/option in equip_options)
		var/datum/outfit/option_outfit = new option()
		outfit_options[option_outfit] = equip_options[option]

	var/datum/outfit/choice = show_radial_menu(user, src, outfit_options, null, require_near = TRUE, tooltips = TRUE)
	if(!choice)
		return

	to_chat(user, "<span class='warning'>[src] clunks as it activates, equipping you with the chosen outfit.</span>")

	for(var/obj/item/item in user.get_equipped_items(TRUE)) //It deletes all the items you previously had! That's really important so holding items won't cause conflicts!
		qdel(item)

	choice.equip(user)
	used = TRUE
	container_resist_act(user)

/// Heroes
/obj/machinery/outfit_equipper/superhero
	var/hero_role

/obj/machinery/outfit_equipper/superhero/show_choice_panel(mob/living/user)
	if(!hero_role)
		return ..()

	var/datum/antagonist/superhero/hero = user.mind.has_antag_datum(/datum/antagonist/superhero)
	if(hero)
		if(hero.hero_role != hero_role)
			to_chat(user, "<span class='warning'>You feel that using other's equipment is probably not a good idea and exit [src].</span>")
			container_resist_act(user)
			return
		return ..()

	var/datum/antagonist/supervillain/baddie = user.mind.has_antag_datum(/datum/antagonist/supervillain)

	if(!baddie)
		to_chat(user, "<span class='warning'>You feel that using this particular [src] is really not a good idea and exit it.</span>")
		container_resist_act(user)
		return

	if(baddie.hero_role != hero_role)
		to_chat(user, "<span class='warning'>You feel that using other's equipment is probably not a good idea and exit [src].</span>")
		container_resist_act(user)
		return
	return ..()

/obj/machinery/outfit_equipper/superhero/buzzon
	hero_role = "BuzzOn"

/obj/machinery/outfit_equipper/superhero/buzzon/Initialize()
	. = ..()
	equip_options = list(/datum/outfit/superhero/buzzon = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "bee"),
						/datum/outfit/superhero/buzzon/cryo = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "bee_winter"),
						/datum/outfit/superhero/buzzon/space = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "bee_space"))

/obj/machinery/outfit_equipper/superhero/ianiser
	hero_role = "Ianiser"

/obj/machinery/outfit_equipper/superhero/ianiser/Initialize()
	. = ..()
	equip_options = list(/datum/outfit/superhero/ianiser = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "ian"),
						/datum/outfit/superhero/ianiser/winter = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "ian_winter"),
						/datum/outfit/superhero/ianiser/space = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "ian_space"))

/obj/machinery/outfit_equipper/superhero/owlman
	hero_role = "Owlman"

/obj/machinery/outfit_equipper/superhero/owlman/Initialize()
	. = ..()
	equip_options = list(/datum/outfit/superhero/owlman = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "owlman"),
						/datum/outfit/superhero/owlman/winter = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "owlman_winter"),
						/datum/outfit/superhero/owlman/space = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "owlman_space"))

/// Villains

/obj/machinery/outfit_equipper/superhero/skeledoom
	hero_role = "SkeleDoom"

/obj/machinery/outfit_equipper/superhero/skeledoom/Initialize()
	. = ..()
	equip_options = list(/datum/outfit/superhero/villain/skeledoom = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "skeledoom"),
						/datum/outfit/superhero/villain/skeledoom/cryo = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "skeledoom_winter"),
						/datum/outfit/superhero/villain/skeledoom/space = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "skeledoom_space"))

/obj/machinery/outfit_equipper/superhero/nekometic
	hero_role = "Nekometic"

/obj/machinery/outfit_equipper/superhero/nekometic/Initialize()
	. = ..()
	equip_options = list(/datum/outfit/superhero/villain/nekometic = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "neko"),
						/datum/outfit/superhero/villain/nekometic/winter = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "neko_winter"),
						/datum/outfit/superhero/villain/nekometic/space = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "neko_space"))

/obj/machinery/outfit_equipper/superhero/griffin
	hero_role = "Griffin"

/obj/machinery/outfit_equipper/superhero/griffin/Initialize()
	. = ..()
	equip_options = list(/datum/outfit/superhero/villain/griffin = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "griffin"),
						/datum/outfit/superhero/villain/griffin/winter = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "griffin_winter"),
						/datum/outfit/superhero/villain/griffin/space = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "griffin_space"))

/// Debug suit storage

/obj/machinery/outfit_equipper/superhero/debug/Initialize()
	. = ..()
	equip_options = list(/datum/outfit/superhero/buzzon = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "bee"),
						/datum/outfit/superhero/buzzon/cryo = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "bee_winter"),
						/datum/outfit/superhero/buzzon/space = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "bee_space"),
						/datum/outfit/superhero/ianiser = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "ian"),
						/datum/outfit/superhero/ianiser/winter = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "ian_winter"),
						/datum/outfit/superhero/ianiser/space = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "ian_space"),
						/datum/outfit/superhero/owlman = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "owlman"),
						/datum/outfit/superhero/owlman/winter = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "owlman_winter"),
						/datum/outfit/superhero/owlman/space = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "owlman_space"),
						/datum/outfit/superhero/villain/skeledoom = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "skeledoom"),
						/datum/outfit/superhero/villain/skeledoom/cryo = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "skeledoom_winter"),
						/datum/outfit/superhero/villain/skeledoom/space = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "skeledoom_space"),
						/datum/outfit/superhero/villain/nekometic = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "neko"),
						/datum/outfit/superhero/villain/nekometic/winter = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "neko_winter"),
						/datum/outfit/superhero/villain/nekometic/space = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "neko_space"),
						/datum/outfit/superhero/villain/griffin = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "griffin"),
						/datum/outfit/superhero/villain/griffin/winter = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "griffin_winter"),
						/datum/outfit/superhero/villain/griffin/space = image(icon = 'icons/hud/radial_heroes.dmi', icon_state = "griffin_space"))
