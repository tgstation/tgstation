/obj/item/weapon/hand_labeler
	name = "hand labeler"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler0"
	item_state = "labeler0"
	var/label = null
	var/labels_left = 30
	var/mode = 0	//off or on.

/obj/item/weapon/hand_labeler/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if (!proximity_flag)
		return

	if(!mode)	//if it's off, give up.
		return
	if(target == loc)	// if placing the labeller into something (e.g. backpack)
		return		// don't set a label

	if(!labels_left)
		user << "<span class='notice'>No labels left.</span>"
		return
	if(!label || !length(label))
		user << "<span class='notice'>No text set.</span>"
		return
	if(length(target.name) + length(label) > 64)
		user << "<span class='notice'>Label too big.</span>"
		return
	if(ishuman(target))
		user << "<span class='notice'>You can't label humans.</span>"
		return
	if(issilicon(target))
		user << "<span class='notice'>You can't label cyborgs.</span>"
		return
	if(istype(target, /obj/item/weapon/reagent_containers/glass))
		user << "<span class='notice'>The label can't stick to the [target.name].  (Try using a pen)</span>"
		return

	user.visible_message("<span class='notice'>[user] labels [target] as [label].</span>", \
						 "<span class='notice'>You label [target] as [label].</span>")
	target.name = "[target.name] ([label])"

/obj/item/weapon/hand_labeler/attack_self(mob/user as mob)
	mode = !mode
	icon_state = "labeler[mode]"
	if(mode)
		user << "<span class='notice'>You turn on \the [src].</span>"
		//Now let them chose the text.
		var/str = copytext(reject_bad_text(input(user,"Label text?","Set label","")),1,MAX_NAME_LEN)
		if(!str || !length(str))
			user << "<span class='notice'>Invalid text.</span>"
			return
		label = str
		user << "<span class='notice'>You set the text to '[str]'.</span>"
	else
		user << "<span class='notice'>You turn off \the [src].</span>"