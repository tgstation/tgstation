/obj/item/weapon/hand_labeler
	name = "hand labeler"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler0"
	item_state = "labeler0"
	var/label = null
	var/chars_left = 250 //Like in an actual label maker, uses an amount per character rather than per label.
	var/mode = 0	//off or on.

/obj/item/weapon/hand_labeler/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if (!proximity_flag)
		return

	if(!mode)	//if it's off, give up.
		return
	if(target == loc)	// if placing the labeller into something (e.g. backpack)
		return		// don't set a label

	if(!chars_left)
		user << "<span class='notice'>Out of label.</span>"
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
	if(target.labeled)
		target.remove_label()
	target.labeled = " ([label])"
	target.name = "[target.name] ([label])"
	new/atom/proc/remove_label(target)
	chars_left = max(chars_left - (length(label) + 2),0)

	if(!chars_left)
		user << "<span class='notice'>The labeler is empty.</span>"
		mode = 0
		icon_state = "labeler_e"
		return
	if(chars_left < length(label) + 2)
		user << "<span class='notice'>The labeler is almost empty.</span>"
		label = copytext(label,1,min(chars_left, length(label) + 1))

/obj/item/weapon/hand_labeler/attack_self(mob/user as mob)
	if(!chars_left)
		user << "<span class='notice'>It's empty.</span>"
		return
	mode = !mode
	icon_state = "labeler[mode]"
	if(mode)
		user << "<span class='notice'>You turn on \the [src].</span>"
		//Now let them chose the text.
		var/str = copytext(reject_bad_text(input(user,"Label text?","Set label","")),1,min(MAX_NAME_LEN,chars_left - 1))
		if(!str || !length(str))
			user << "<span class='notice'>Invalid text.</span>"
			return
		label = str
		user << "<span class='notice'>You set the text to '[str]'.</span>"
	else
		user << "<span class='notice'>You turn off \the [src].</span>"

/obj/item/weapon/hand_labeler/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/device/label_roll))
		if(mode)
			user << "<span class='notice'>Turn it off first.</span>"
			return
		var/obj/item/device/label_roll/LR = O
		var/holder = chars_left //I hate having to do this.
		chars_left = LR.left
		if(holder)
			LR.left = holder
			user << "<span class='notice'>You switch the label rolls.</span>"
		else
			del(LR)
			user << "<span class='notice'>You replace the label roll.</span>"
			icon_state = "labeler0"

/obj/item/weapon/hand_labeler/attack_hand(mob/user) //Shamelessly stolen from stack.dm.
	if(mode)
		user << "<span class='notice'>Turn it off first.</span>"
		return
	if (user.get_inactive_hand() == src)
		var/obj/item/device/label_roll/LR = new(user, amount=chars_left)
		user.put_in_hands(LR)
		user << "<span class='notice'>You remove the label roll.</span>"
		chars_left = 0
		icon_state = "labeler_e"
	else
		..()

/obj/item/weapon/hand_labeler/examine(mob/user) //Shamelessly stolen from the paper bin.
	..()
	if(chars_left)
		user << "<span class='info'>There " + (chars_left > 1 ? "are [chars_left] letters" : "is one letter") + " worth of label on the roll.</span>"
	else
		user << "<span class='info'>The label roll is all used up.</span>"

/atom/proc/remove_label()
	set name = "Remove label"
	set src in view(1)
	set category = "Object"
	var/atom/A = src
	A.name = replacetext(A.name, A.labeled, "")
	A.labeled = null
	A.verbs -= /atom/proc/remove_label

/obj/item/device/label_roll
	name = "label roll"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "label_cart" //Placeholder image; recolored police tape
	var/left = 250

/obj/item/device/label_roll/examine(mob/user) //Shamelessly stolen from above.
	..()
	if(left)
		user << "<span class='info'>There " + (left > 1 ? "are [left] letters" : "is one letter") + " worth of label on the roll.</span>"
	else
		user << "<span class='warning'>Something has fucked up and this item should have deleted itself. Throw it away for IMMERSION.</span>"

/obj/item/device/label_roll/New(var/loc, var/amount=null)
	..()
	if(amount)
		left = amount