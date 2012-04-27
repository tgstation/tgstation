/obj/item/weapon/hand_labeler
	name = "Hand labeler"
	icon = 'bureaucracy.dmi'
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
		user << "\blue No labels left."
		return
	if(!label || !length(label))
		user << "\blue No text set."
		return
	if(length(A.name) + length(label) > 64)
		user << "\blue Label too big."
		return
	if(ishuman(A))
		user << "\blue You can't label humans."
		return
	if(issilicon(A))
		user << "\blue You can't label cyborgs."
		return

	for(var/mob/M in viewers())
		if ((M.client && !( M.blinded )))
			M << "\blue [user] labels [A] as [label]."
	A.name = "[A.name] ([label])"

/obj/item/weapon/hand_labeler/attack_self()
	mode = !mode
	icon_state = "labeler[mode]"
	if(mode)
		usr << "\blue You turn on the hand labeler."
		//Now let them chose the text.
		var/str = input(usr,"Label text?","Set label","")
		if(!str || !length(str))
			usr << "\red Invalid text."
			return
		if(length(str) > 64)
			usr << "\red Text too long."
			return
		label = str
		usr << "\blue You set the text to '[str]'."
	else
		usr << "\blue You turn off the hand labeler."