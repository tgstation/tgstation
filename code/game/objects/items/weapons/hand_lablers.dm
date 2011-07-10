/obj/item/weapon/hand_labeler
	icon = 'items.dmi'
	icon_state = "labeler"
	item_state = "flight"
	name = "Hand labeler"
	var/label = null
	var/labels_left = 30

/obj/item/weapon/hand_labeler/afterattack(atom/A, mob/user as mob)
	if(A==loc)		// if placing the labeller into something (e.g. backpack)
		return		// don't set a label

	if(!labels_left)
		user << "\red No labels left."
		return
	if(!label || !length(label))
		user << "\red No text set."
		return
	if(length(A.name) + length(label) > 64)
		user << "\red Label too big."
		return
	if(ishuman(A))
		user << "\red You can't label humans."
		return

	for(var/mob/M in viewers())
		M << "\blue [user] labels [A] as [label]."
	A.name = "[A.name] ([label])"

/obj/item/weapon/hand_labeler/attack_self()
	var/str = input(usr,"Label text?","Set label","")
	if(!str || !length(str))
		usr << "\red Invalid text."
		return
	if(length(str) > 64)
		usr << "\red Text too long."
		return
	label = str
	usr << "\blue You set the text to '[str]'."