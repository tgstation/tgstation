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
		notify_ghosts("A [construct_name] chassis has been created in [A.name]!", 'sound/magic/clockwork/fellowship_armory.ogg', source = src, action = NOTIFY_ORBIT, flashwindow = FALSE)
	GLOB.poi_list += src

/obj/item/clockwork/construct_chassis/Destroy()
	GLOB.poi_list -= src
	. = ..()

/obj/item/clockwork/construct_chassis/examine(mob/user)
	clockwork_desc = "[clockwork_desc]<br>[construct_desc]"
	..()
	clockwork_desc = initial(clockwork_desc)

/obj/item/clockwork/construct_chassis/attack_hand(mob/living/user)
	if(w_class >= WEIGHT_CLASS_HUGE)
		to_chat(user, "<span class='warning'>[src] is too cumbersome to carry! Drag it around instead!</span>")
		return
	. = ..()

/obj/item/clockwork/construct_chassis/attack_ghost(mob/user)
	if(alert(user, "Become a [construct_name]? You can no longer be cloned!", construct_name, "Yes", "Cancel") == "Cancel")
		return
	if(QDELETED(src))
		to_chat(user, "<span class='danger'>You were too late! Better luck next time.</span>")
		return
	visible_message(creation_message)
	var/mob/living/construct = new construct_type(get_turf(src))
	construct.key = user.key
	qdel(user)
	qdel(src)


//Marauder armor, used to create clockwork marauders - sturdy frontline combatants that can deflect projectiles.
/obj/item/clockwork/construct_chassis/clockwork_marauder
	name = "marauder armor"
	desc = "A pile of sleek and well-polished brass armor. A small red gemstone sits in its faceplate."
	icon_state = "marauder_armor"
	construct_name = "clockwork marauder"
	construct_desc = "<span class='neovgre_small'>It will become a <b>clockwork marauder,</b> a well-rounded frontline combatant.</span>"
	creation_message = "<span class='neovgre_small bold'>Crimson fire begins to rage in the armor as it rises into the air with its arnaments!</span>"
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
