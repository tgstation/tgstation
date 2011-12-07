/atom/var/list/labels

//how to place label:
//1: set label in labeller
//2: pick up label object
//3: click on label with the hand the label is in
//4: place label on something
//how to remove label
//1: use labeller on item
//2: select label to remove (if there is >1 label anyway, if there is only one it will just remove that one)
/obj/item/weapon/hand_labeler
	icon = 'items.dmi'
	icon_state = "labeler"
	item_state = "flight"
	name = "Hand labeler"

/obj/item/weapon/hand_labeler/afterattack(atom/A as obj|mob, mob/user as mob)
	if(A==loc)      // if placing the labeller into something (e.g. backpack)
		return      // don't remove any labels
	if(!A.labels)
		return
	if(A.labels.len == 1)
		var/t = A.labels[1]
		A.name = copytext(A.name,1,lentext(A.name) - (lentext(t) + 2))
		A.labels -= t
		return
	if(A.labels.len > 1)
		var/t = input(user, "Which label do you want to remove?") as null|anything in A.labels
		var/i = 1
		for(, i <= labels.len, i++) //find the thing of the label to remove
			if(A.labels[i] == t)
				break
		if(i != A.labels.len) //if we arent removing the last label
			var/k = 0
			for(var/j = i+1, j <= A.labels.len, j++)
				k += lentext(A.labels[j]) + 3 // 3 = " (" + ")"
			var/labelend = lentext(A.name) - (k-1)
			var/labelstart = labelend - (lentext(t)+3)
			A.name = addtext(copytext(A.name,1,labelstart),copytext(A.name,labelend,0))
			A.labels -= t
			return
		if(i == A.labels.len) //if this is the last label we don't need to find the length of the stuff infront of it
			var/labelstart = lentext(A.name) - (lentext(t)+3)
			A.name = copytext(A.name,1,labelstart)
			A.labels -= t
			return
		user << "\red Something broke. Please report this (that you were trying to remove a label and what the full name of the item was) to an admin or something."

/obj/item/weapon/hand_labeler/attack_self(mob/user as mob)
	var/str = input(usr,"Label text?","Set label","")
	if(!str || !length(str))
		usr << "\red Invalid text."
		return
	if(length(str) > 64)
		usr << "\red Text too long."
		return
	var/obj/item/weapon/label/A = new/obj/item/weapon/label
	A.label = str
	A.loc = user.loc
	A.name += " - '[str]'"

/obj/item/weapon/label
	icon = 'items.dmi'
	icon_state = "label"
	name = "Label"
	w_class = 2
	var/label = ""
	var/backing = 1 //now with added being able to be put on table-ness!

/obj/item/weapon/label/afterattack(atom/A, mob/user as mob)
	if(!backing)
		if(A==loc)      // if placing the label into something (e.g. backpack)
			return      // don't stick it on
		if(!label || !length(label))
			user << "\red This label doesn't have any text! How did this happen?!?"
			return
		if(length(A.name) + length(label) > 64) //this needs to be made bigger too. maybe number of labels instead of a fixed length
			user << "\red Label too big."
			return
		if(ishuman(A))
			user << "\red You can't label humans."
			return
		if(!A.labels)
			A.labels = new()
		for(var/i = 1, i < A.labels.len, i++)
			if(label == A.labels[i])
				user << "\red [A] already has that label!"
				return

		for(var/mob/M in viewers())
			M << "\blue [user] puts a label on [A]."
		A.name = "[A.name] ([label])"
		A.labels += label
		del(src)

/obj/item/weapon/label/attack_self(mob/user as mob)	//here so you can put them on tables and stuff more easily to stop them from being all over the floor until you want to use them
	if(backing)
		backing = 0
		user << "\blue You remove the backing from the label." //now it will stick to things