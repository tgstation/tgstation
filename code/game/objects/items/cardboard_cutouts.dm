//Cardboard cutouts! They're man-shaped and can be colored with a crayon to look like a human in a certain outfit, although it's limited, discolored, and obvious to more than a cursory glance.
/obj/item/cardboard_cutout
	name = "cardboard cutout"
	desc = "A vaguely humanoid cardboard cutout. It's completely blank."
	icon = 'icons/obj/cardboard_cutout.dmi'
	icon_state = "cutout_basic"
	w_class = 4
	burn_state = FLAMMABLE
	var/list/possible_appearances = list("Assistant", "Clown", "Mime", "Traitor", "Nuke Op", "Cultist", "Clockwork Cultist", "Revolutionary", "Wizard", "Shadowling", "Xenomorph", "Swarmer", \
	"Ash Walker", "Deathsquad Officer", "Ian") //Possible restyles for the cutout; add an entry in change_appearance() if you add to here
	var/pushed_over = FALSE //If the cutout is pushed over and has to be righted
	var/deceptive = FALSE //If the cutout actually appears as what it portray and not a discolored version

/obj/item/cardboard_cutout/attack_hand(mob/living/user)
	if(user.a_intent == "help" || pushed_over)
		return ..()
	user.visible_message("<span class='warning'>[user] pushes over [src]!</span>", "<span class='danger'>You push over [src]!</span>")
	playsound(src, 'sound/weapons/Genhit.ogg', 50, 1)
	name = initial(name)
	desc = "[initial(desc)] It's been pushed over."
	icon_state = "cutout_pushed_over"
	color = initial(color)
	pushed_over = TRUE

/obj/item/cardboard_cutout/attack_self(mob/living/user)
	if(!pushed_over)
		return
	user << "<span class='notice'>You right [src].</span>"
	desc = initial(desc)
	icon_state = initial(icon_state) //This resets a cutout to its blank state - this is intentional to allow for resetting
	pushed_over = FALSE

/obj/item/cardboard_cutout/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/toy/crayon))
		change_appearance(I, user)
	else
		return ..()

/obj/item/cardboard_cutout/bullet_act(obj/item/projectile/P)
	visible_message("<span class='danger'>[src] has been hit by [P]!</span>")
	playsound(src, 'sound/weapons/slice.ogg', 50, 1)
	if(prob(P.damage))
		name = initial(name)
		desc = "[initial(desc)] It's been pushed over."
		icon_state = "cutout_pushed_over"
		color = initial(color)
		pushed_over = TRUE

/obj/item/cardboard_cutout/proc/change_appearance(obj/item/toy/crayon/crayon, mob/living/user)
	if(!crayon || !user)
		return
	if(pushed_over)
		user << "<span class='warning'>Right [src] first!</span>"
		return
	var/new_appearance = input(user, "Choose a new appearance for [src].", "26th Century Deception") as null|anything in possible_appearances
	if(!new_appearance || !crayon || !user.canUseTopic(src))
		return
	user.visible_message("<span class='notice'>[user] gives [src] a new look.</span>", "<span class='notice'>Voila! You give [src] a new look.</span>")
	crayon.use_charges(1)
	crayon.check_empty(user)
	alpha = 255
	if(!deceptive)
		color = "#FFD7A7"
	switch(new_appearance)
		if("Assistant")
			name = "[pick(first_names_male)] [pick(last_names)]"
			desc = "A cardboat cutout of an assistant."
			icon_state = "cutout_greytide"
		if("Clown")
			name = pick(clown_names)
			desc = "A cardboard cutout of a clown. You get the feeling that it should be in a corner."
			icon_state = "cutout_clown"
		if("Mime")
			name = pick(mime_names)
			desc = "...(A cardboard cutout of a mime.)"
			icon_state = "cutout_mime"
		if("Traitor")
			name = "[pick("Unknown", "Captain")]"
			desc = "A cardboard cutout of a traitor."
			icon_state = "cutout_traitor"
		if("Nuke Op")
			name = "[pick("Unknown", "COMMS", "Telecomms", "AI", "stealthy op", "STEALTH", "sneakybeaky", "MEDIC", "Medic")]"
			desc = "A cardboard cutout of a nuclear operative."
			icon_state = "cutout_fluke"
		if("Cultist")
			name = "Unknown"
			desc = "A cardboard cutout of a cultist."
			icon_state = "cutout_cultist"
		if("Clockwork Cultist")
			name = "[pick(first_names_male)] [pick(last_names)]"
			desc = "A cardboard cutout of a servant of Ratvar."
			icon_state = "cutout_servant"
		if("Revolutionary")
			name = "Unknown"
			desc = "A cardboard cutout of a revolutionary."
			icon_state = "cutout_viva"
		if("Wizard")
			name = "[pick(wizard_first)], [pick(wizard_second)]"
			desc = "A cardboard cutout of a wizard."
			icon_state = "cutout_wizard"
		if("Shadowling")
			name = "Unknown"
			desc = "A cardboard cutout of a shadowling."
			icon_state = "cutout_shadowling"
		if("Xenomorph")
			name = "alien hunter ([rand(1, 999)])"
			desc = "A cardboard cutout of a xenomorph."
			icon_state = "cutout_fukken_xeno"
			if(prob(25))
				alpha = 75 //Spooky sneaking!
		if("Swarmer")
			name = "Swarmer ([rand(1, 999)])"
			desc = "A cardboard cutout of a swarmer."
			icon_state = "cutout_swarmer"
		if("Ash Walker")
			name = lizard_name(pick(MALE, FEMALE))
			desc = "A cardboard cutout of an ash walker."
			icon_state = "cutout_free_antag"
		if("Deathsquad Officer")
			name = pick(commando_names)
			desc = "A cardboard cutout of a death commando."
			icon_state = "cutout_deathsquad"
		if("Ian")
			name = "Ian"
			desc = "A cardboard cutout of the HoP's beloved corgi."
			icon_state = "cutout_ian"
	return 1

/obj/item/cardboard_cutout/adaptive //Purchased by Syndicate agents, these cutouts are indistinguishable from normal cutouts but aren't discolored when their appearance is changed
	deceptive = TRUE
