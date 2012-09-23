/obj/item/weapon/hand_labeler
	name = "hand labeler"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler0"
	item_state = "flight"
	var/label = null
	var/labels_left = 30
	var/mode = 0	//off or on.

/obj/item/weapon/hand_labeler/afterattack(atom/A, mob/user as mob)
	if(!mode)	//if it's off, give up.
		return
	if(A==loc)		// if placing the labeller into something (e.g. backpack)
		return		// don't set a label

	if(!labels_left)
		user << "<span class='notice'>No labels left.</span>"
		return
	if(!label || !length(label))
		user << "<span class='notice'>No text set.</span>"
		return
	if(length(A.name) + length(label) > 64)
		user << "<span class='notice'>Label too big.</span>"
		return
	if(ishuman(A))
		user << "<span class='notice'>You can't label humans.</span>"
		return
	if(issilicon(A))
		user << "<span class='notice'>You can't label cyborgs.</span>"
		return

	for(var/mob/M in viewers())
		if ((M.client && !( M.blinded )))
			M << "\blue [user] labels [A] as [label]."
	A.name = "[A.name] ([label])"

/obj/item/weapon/hand_labeler/attack_self()
	mode = !mode
	icon_state = "labeler[mode]"
	if(mode)
		usr << "<span class='notice'>You turn on \the [src].</span>"
		//Now let them chose the text.
		var/str = copytext(reject_bad_text(input(usr,"Label text?","Set label","")),1,MAX_NAME_LEN)
		if(!str || !length(str))
			usr << "<span class='notice'>Invalid text.</span>"
			return
		label = str
		usr << "<span class='notice'>You set the text to '[str]'.</span>"
	else
		usr << "<span class='notice'>You turn off \the [src].</span>"