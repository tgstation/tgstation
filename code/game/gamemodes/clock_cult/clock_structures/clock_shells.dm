//Useless on their own, these shells can create powerful constructs.
/obj/structure/destructible/clockwork/shell
	construction_value = 0
	anchored = FALSE
	density = FALSE
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/mobtype = /mob/living/simple_animal/hostile/clockwork
	var/spawn_message = " is an error and you should yell at whoever spawned this shell."

/obj/structure/destructible/clockwork/shell/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/device/mmi/posibrain/soul_vessel))
		if(!is_servant_of_ratvar(user))
			..()
			return 0
		var/obj/item/device/mmi/posibrain/soul_vessel/S = I
		if(!S.brainmob)
			to_chat(user, "<span class='warning'>[S] is inactive! Turn it on or capture a mind first.</span>")
			return 0
		if(S.brainmob && (!S.brainmob.client || !S.brainmob.mind))
			to_chat(user, "<span class='warning'>[S]'s trapped consciousness appears inactive!</span>")
			return 0
		user.visible_message("<span class='notice'>[user] places [S] in [src], where it fuses to the shell.</span>", "<span class='brass'>You place [S] in [src], fusing it to the shell.</span>")
		var/mob/living/simple_animal/A = new mobtype(get_turf(src))
		A.visible_message("<span class='brass'>[src][spawn_message]</span>")
		S.brainmob.mind.transfer_to(A)
		A.fully_replace_character_name(null, "[findtext(A.name, initial(A.name)) ? "[initial(A.name)]":"[A.name]"] ([S.brainmob.name])")
		user.drop_item()
		qdel(S)
		qdel(src)
		return 1
	else
		return ..()

/obj/structure/destructible/clockwork/shell/cogscarab
	name = "cogscarab shell"
	desc = "A small brass shell with a cube-shaped receptable in its center. It gives off an aura of obsessive perfectionism."
	clockwork_desc = "A dormant receptable that, when powered with a soul vessel, will become a weak construct with an inbuilt fabricator."
	icon_state = "clockdrone_shell"
	mobtype = /mob/living/simple_animal/drone/cogscarab
	spawn_message = "'s eyes blink open, glowing bright red."

/obj/structure/destructible/clockwork/shell/fragment
	name = "fragment shell"
	desc = "A massive brass shell with a small cube-shaped receptable in its center. It gives off an aura of contained power."
	clockwork_desc = "A dormant receptable that, when powered with a soul vessel, will become a powerful construct."
	icon_state = "anime_fragment"
	mobtype = /mob/living/simple_animal/hostile/clockwork/fragment
	spawn_message = " whirs and rises from the ground on a flickering jet of reddish fire."
