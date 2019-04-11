//Construct shells that can be activated by ghosts.
/obj/item/clockwork/construct_chassis
	name = "construct chassis"
	desc = "A shell formed out of brass, presumably for housing machinery."
	clockwork_desc = "A construct chassis. It can be activated at any time by a willing ghost."
	var/construct_name = "basic construct"
	var/construct_desc = "<span class='alloy'>There is no construct for this chassis. Report this to a coder.</span>"
	icon_state = "anime_fragment"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	w_class = WEIGHT_CLASS_HUGE
	var/creation_message = "<span class='brass'>The chassis shudders and hums to life!</span>"
	var/construct_type //The construct this shell will create

/obj/item/clockwork/construct_chassis/Initialize()
	. = ..()
	var/area/A = get_area(src)
	if(A && construct_type)
		notify_ghosts("A [construct_name] chassis has been created in [A.name]!", 'sound/magic/clockwork/fellowship_armory.ogg', notify_volume = 75, source = src, action = NOTIFY_ATTACK, flashwindow = FALSE, ignore_key = POLL_IGNORE_CONSTRUCT)
	GLOB.poi_list += src
	LAZYADD(GLOB.mob_spawners[name], src)

/obj/item/clockwork/construct_chassis/Destroy()
	GLOB.poi_list -= src
	var/list/spawners = GLOB.mob_spawners[name]
	LAZYREMOVE(spawners, src)
	. = ..()

/obj/item/clockwork/construct_chassis/examine(mob/user)
	clockwork_desc = "[clockwork_desc]<br>[construct_desc]"
	..()
	clockwork_desc = initial(clockwork_desc)

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/clockwork/construct_chassis/attack_hand(mob/living/user)
	if(w_class >= WEIGHT_CLASS_HUGE)
		to_chat(user, "<span class='warning'>[src] is too cumbersome to carry! Drag it around instead!</span>")
		return
	. = ..()

//ATTACK GHOST IGNORING PARENT RETURN VALUE
/obj/item/clockwork/construct_chassis/attack_ghost(mob/user)
	if(!SSticker.mode)
		to_chat(user, "<span class='danger'>You cannot use that before the game has started.</span>")
		return
	if(QDELETED(src))
		to_chat(user, "<span class='danger'>You were too late! Better luck next time.</span>")
		return
	user.forceMove(get_turf(src)) //If we attack through the alert, jump to the chassis so we know what we're getting into
	if(alert(user, "Become a [construct_name]? You can no longer be cloned!", construct_name, "Yes", "Cancel") == "Cancel")
		return
	if(QDELETED(src))
		to_chat(user, "<span class='danger'>You were too late! Better luck next time.</span>")
		return
	pre_spawn()
	visible_message(creation_message)
	var/mob/living/construct = new construct_type(get_turf(src))
	construct.key = user.key
	post_spawn(construct)
	qdel(user)
	qdel(src)

/obj/item/clockwork/construct_chassis/proc/pre_spawn() //Some things might change before the construct spawns; override those on a subtype basis in this proc
	return

/obj/item/clockwork/construct_chassis/proc/post_spawn(mob/living/construct) //And some things might change after it
	return


//Marauder armor, used to create clockwork marauders - sturdy frontline combatants that can deflect projectiles.
/obj/item/clockwork/construct_chassis/clockwork_marauder
	name = "marauder armor"
	desc = "A pile of sleek and well-polished brass armor. A small red gemstone sits in its faceplate."
	icon_state = "marauder_armor"
	construct_name = "clockwork marauder"
	construct_desc = "<span class='neovgre_small'>It will become a <b>clockwork marauder,</b> a well-rounded frontline combatant.</span>"
	creation_message = "<span class='neovgre_small bold'>Crimson fire begins to rage in the armor as it rises into the air with its armaments!</span>"
	construct_type = /mob/living/simple_animal/hostile/clockwork/marauder


//Cogscarab shell, used to create cogcarabs - fragile but zippy little drones that build and maintain the base.
/obj/item/clockwork/construct_chassis/cogscarab
	name = "cogscarab shell"
	desc = "A small, complex shell that resembles a repair drone, but much larger and made out of brass."
	icon_state = "cogscarab_shell"
	construct_name = "cogscarab"
	construct_desc = "<span class='alloy'>It will become a <b>cogscarab,</b> a small and fragile drone that builds, repairs, and maintains.</span>"
	creation_message = "<span class='alloy bold'>The cogscarab clicks and whirrs as it hops up and springs to life!</span>"
	construct_type = /mob/living/simple_animal/drone/cogscarab
	w_class = WEIGHT_CLASS_SMALL
	var/infinite_resources = TRUE
	var/static/obj/item/seasonal_hat //Share it with all other scarabs, since we're from the same cult!

/obj/item/clockwork/construct_chassis/cogscarab/Initialize()
	. = ..()
	if(GLOB.servants_active)
		infinite_resources = FALSE //For any that are somehow spawned in late

/obj/item/clockwork/construct_chassis/cogscarab/pre_spawn()
	if(infinite_resources)
		//During rounds where they can't interact with the station, let them experiment with builds
		construct_type = /mob/living/simple_animal/drone/cogscarab/ratvar
	if(!seasonal_hat)
		var/obj/item/drone_shell/D = locate() in GLOB.poi_list
		if(D && D.possible_seasonal_hats.len)
			seasonal_hat = pick(D.possible_seasonal_hats)
		else
			seasonal_hat = "none"

/obj/item/clockwork/construct_chassis/cogscarab/post_spawn(mob/living/construct)
	if(infinite_resources) //Allow them to build stuff and recite scripture
		var/list/cached_stuff = construct.GetAllContents()
		for(var/obj/item/clockwork/replica_fabricator/F in cached_stuff)
			F.uses_power = FALSE
		for(var/obj/item/clockwork/slab/S in cached_stuff)
			S.no_cost = TRUE
		if(seasonal_hat && seasonal_hat != "none")
			var/obj/item/hat = new seasonal_hat(construct)
			construct.equip_to_slot_or_del(hat, SLOT_HEAD)
