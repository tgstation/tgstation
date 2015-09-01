/obj/item/weapon/hand_labeler
	name = "hand labeler"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler0"
	item_state = "flight"
	var/label = null
	var/labels_left = 30
	var/mode = 0


/obj/item/weapon/hand_labeler/afterattack(atom/A, mob/user,proximity)
	if(!proximity) return
	if(!mode)	//if it's off, give up.
		return
	if(A == loc)	// if placing the labeller into something (e.g. backpack)
		return		// don't set a label

	if(!labels_left)
		user << "<span class='warning'>No labels left!</span>"
		return
	if(!label || !length(label))
		user << "<span class='warning'>No text set!</span>"
		return
	if(length(A.name) + length(label) > 64)
		user << "<span class='warning'>Label too big!</span>"
		return
	if(ishuman(A))
		user << "<span class='warning'>You can't label humans!</span>"
		return
	if(issilicon(A))
		user << "<span class='warning'>You can't label cyborgs!</span>"
		return

	user.visible_message("[user] labels [A] as [label].", \
						 "<span class='notice'>You label [A] as [label].</span>")
	A.name = "[A.name] ([label])"
	labels_left--


/obj/item/weapon/hand_labeler/attack_self(mob/user)
	mode = !mode
	icon_state = "labeler[mode]"
	if(mode)
		user << "<span class='notice'>You turn on [src].</span>"
		//Now let them chose the text.
		var/str = copytext(reject_bad_text(input(user,"Label text?","Set label","")),1,MAX_NAME_LEN)
		if(!str || !length(str))
			user << "<span class='warning'>Invalid text!</span>"
			return
		label = str
		user << "<span class='notice'>You set the text to '[str]'.</span>"
	else
		user << "<span class='notice'>You turn off [src].</span>"

/obj/item/weapon/hand_labeler/attackby(obj/item/I, mob/user, params)
	..()
	if(istype(I, /obj/item/hand_labeler_refill))
		if(!user.unEquip(I))
			return
		user << "<span class='notice'>You insert [I] into [src].</span>"
		qdel(I)
		labels_left = initial(labels_left)
		return

/obj/item/hand_labeler_refill
	name = "hand labeler paper roll"
	icon = 'icons/obj/bureaucracy.dmi'
	desc = "A roll of paper. Use it on a hand labeler to refill it."
	icon_state = "labeler_refill"
	item_state = "electropack"
	w_class = 1.0