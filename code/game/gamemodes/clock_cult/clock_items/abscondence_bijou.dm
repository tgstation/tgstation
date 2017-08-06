//A small gemstone linked with the Hierophant network. Servants can use to to go to and from Reebe.
/obj/item/clockwork/abscondence_bijou
	name = "abscondence bijou"
	desc = "A flawless, opaque gemstone formed out of bright pink stone. It fits neatly in the palm of your hand."
	clockwork_desc = "A chunk of gemstone linked to the Hierophant network, used to get to and from Space Station 13."
	flags = NOBLUDGEON
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon_state = "lens_gem"
	item_state = "abscondence_bijou"
	lefthand_file = 'icons/mob/inhands/antag/clockwork_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/clockwork_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	var/charged = TRUE //If the bijou is ready to use
	var/recharge_ticks = 0 //How many seconds are left for the bijou to recharge

/obj/item/clockwork/abscondence_bijou/Destroy()
	STOP_PROCESSING(SSprocessing, src)
	return ..()

/obj/item/clockwork/abscondence_bijou/process()
	recharge_ticks--
	if(!recharge_ticks)
		recharge()

/obj/item/clockwork/abscondence_bijou/examine(mob/user)
	..()
	if(!is_servant_of_ratvar(user) && !isobserver(user))
		return
	if(user.z == ZLEVEL_CITYOFCOGS)
		to_chat(user, "<span class='sevtug_small'>You're on Reebe, so it can be used to get to the station. Select a teleportation target by clicking on it \
		with the bijou in-hand through the camera observer consoles.</span>")
	else
		to_chat(user, "<span class='sevtug_small'>You're away from Reebe. Use the bijou in your hand to go back home.</span>")

/obj/item/clockwork/abscondence_bijou/afterattack(atom/movable/A, mob/living/user, proximity)
	if(!is_servant_of_ratvar(user))
		return
	if(!charged)
		to_chat(user, "<span class='danger'>[src]'s energy has been depleted for now. It will be charged in [recharge_ticks] second[recharge_ticks == 1 ? "" : "s"].</span>")
		return
	if(user.z != ZLEVEL_CITYOFCOGS || A.z != ZLEVEL_STATION)
		return
	if(isclosedturf(A))
		to_chat(user, "<span class='sevtug_small'>You can't teleport into a wall.</span>")
		return
	else if(isspaceturf(A))
		to_chat(user, "<span class='sevtug_small'>[prob(1) ? "Servant cannot into space." : "You can't teleport into space."]</span>")
		return
	var/area/AR = get_area(A)
	if(istype(AR, /area/ai_monitored))
		to_chat(user, "<span class='sevtug_small'>The structure there is too dense for [src] to pierce. (This is typical in high-security areas.)</span>")
		return
	if(alert(user, "Teleport to [A]?", name, "Teleport", "Cancel") == "Cancel" || !charged || !user.canUseTopic(src))
		return
	do_sparks(5, TRUE, user)
	do_sparks(5, TRUE, A)
	user.visible_message("<span class='warning'>[user]'s [src] flares, and they flicker and vanish!</span>", "<span class='sevtug_small'>You warp to [A]!</span>")
	A.visible_message("<span class='warning'>[user] warps in!</span>")
	playsound(user, 'sound/magic/magic_missile.ogg', 50, TRUE)
	playsound(A, 'sound/magic/magic_missile.ogg', 50, TRUE)
	user.forceMove(get_turf(A))
	flash_color(user, flash_color = "#AF0AAF", flash_time = 25)
	decharge(300) //30 second recharge time

/obj/item/clockwork/abscondence_bijou/attack_self(mob/living/user)
	if(!is_servant_of_ratvar(user))
		to_chat(user, "<span class='notice'>While [src] is pleasing to the eye, it doesn't seem to have any use.</span>")
		return
	if(!charged)
		to_chat(user, "<span class='danger'>[src]'s energy has been depleted for now. It will be charged in [recharge_ticks] second[recharge_ticks == 1 ? "" : "s"].</span>")
		return
	if(user.z == ZLEVEL_CITYOFCOGS)
		to_chat(user, "<span class='danger'>You're already at Reebe. Use the bijou to get to the station instead.</span>")
		return
	to_chat(user, "<span class='sevtug_small'>You grasp [src] in your hand and squeeze tightly...</span>")
	if(user.client)
		animate(user.client, color = "#AF0AAF", time = 50)
	if(!do_after(user, 50, target = user) || !charged|| !is_servant_of_ratvar(user)) //if they're somehow deconverted before it happens, no can-do
		if(user.client)
			animate(user.client, color = initial(user.client.color), time = 10)
		return
	user.visible_message("<span class='warning'>[user] flickers and disappears!</span>", \
	"<span class='sevtug_small'>You discharge [src]'s power and are yanked through time and space!</span>")
	playsound(user, 'sound/magic/magic_missile.ogg', 50, TRUE)
	do_sparks(5, TRUE, user)
	user.forceMove(get_turf(pick(GLOB.servant_spawns)))
	do_sparks(5, TRUE, user)
	if(user.client)
		animate(user.client, color = initial(user.client.color), time = 25)
	decharge()

/obj/item/clockwork/abscondence_bijou/proc/decharge(charge_time = 600)
	for(var/obj/item/clockwork/abscondence_bijou/B in loc.GetAllContents())
		B.charged = FALSE
		B.color = list(rgb(77,77,77), rgb(150,150,150), rgb(28,28,28), rgb(0,0,0))
		animate(B, color = initial(B.color), time = charge_time)
		B.recharge_ticks = charge_time / 10 //600 deciseconds = 60 seconds
		START_PROCESSING(SSprocessing, B)

/obj/item/clockwork/abscondence_bijou/proc/recharge()
	charged = TRUE
	if(isliving(loc))
		var/mob/living/L = loc
		to_chat(L, "<span class='sevtug_small'>[src] is fully recharged!</span>")
		L.playsound_local(L, 'sound/magic/magic_missile.ogg', 50, FALSE)
	STOP_PROCESSING(SSprocessing, src)
