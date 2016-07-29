<<<<<<< HEAD
/obj/item/weapon/hand_labeler
	name = "hand labeler"
	desc = "A combined label printer and applicator in a portable device, designed to be easy to operate and use."
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler0"
	item_state = "flight"
	var/label = null
	var/labels_left = 30
	var/mode = 0

/obj/item/weapon/hand_labeler/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is pointing \the [src] \
		at \himself. They're going to label themselves as a suicide!</span>")
	labels_left = max(labels_left - 1, 0)

	var/old_real_name = user.real_name
	user.real_name += " (suicide)"
	// no conflicts with their identification card
	for(var/atom/A in user.GetAllContents())
		if(istype(A, /obj/item/weapon/card/id))
			var/obj/item/weapon/card/id/their_card = A

			// only renames their card, as opposed to tagging everyone's
			if(their_card.registered_name != old_real_name)
				continue

			their_card.registered_name = user.real_name
			their_card.update_label()

	// NOT EVEN DEATH WILL TAKE AWAY THE STAIN
	user.mind.name += " (suicide)"

	mode = 1
	icon_state = "labeler[mode]"
	label = "suicide"

	return OXYLOSS

/obj/item/weapon/hand_labeler/afterattack(atom/A, mob/user,proximity)
	if(!proximity) return
	if(!mode)	//if it's off, give up.
		return

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
	if(!user.IsAdvancedToolUser())
		user << "<span class='warning'>You don't have the dexterity to use [src]!</span>"
		return
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

/obj/item/weapon/hand_labeler/borg
	name = "cyborg-hand labeler"

/obj/item/weapon/hand_labeler/borg/afterattack(atom/A, mob/user, proximity)
	..(A, user, proximity)
	if(!isrobot(user))
		return

	var/mob/living/silicon/robot/borgy = user

	var/starting_labels = initial(labels_left)
	var/diff = starting_labels - labels_left
	if(diff)
		labels_left = starting_labels
		// 50 per label. Magical cyborg paper doesn't come cheap.
		var/cost = diff * 50

		// If the cyborg manages to use a module without a cell, they get the paper
		// for free.
		if(borgy.cell)
			borgy.cell.use(cost)

/obj/item/hand_labeler_refill
	name = "hand labeler paper roll"
	icon = 'icons/obj/bureaucracy.dmi'
	desc = "A roll of paper. Use it on a hand labeler to refill it."
	icon_state = "labeler_refill"
	item_state = "electropack"
	w_class = 1
=======
/obj/item/weapon/hand_labeler
	name = "hand labeler"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "labeler0"
	item_state = "labeler0"
	origin_tech = "materials=1"
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
		to_chat(user, "<span class='notice'>Out of label.</span>")
		return

	if(!label || !length(label))
		to_chat(user, "<span class='notice'>No text set.</span>")
		return

	if(length(target.name) + min(length(label) + 2, chars_left) > 64)
		to_chat(user, "<span class='notice'>Label too big.</span>")
		return
	if(ishuman(target))
		to_chat(user, "<span class='notice'>You can't label humans.</span>")
		return
	if(issilicon(target))
		to_chat(user, "<span class='notice'>You can't label cyborgs.</span>")
		return
	if(istype(target, /obj/item/weapon/reagent_containers/glass))
		to_chat(user, "<span class='notice'>The label can't stick to the [target.name].  (Try using a pen)</span>")
		return

	if(target.labeled)
		target.remove_label()
	target.labeled = " ([label])"
	target.name = "[target.name] ([label])"
	new/atom/proc/remove_label(target)

	if(user.a_intent == I_HURT && target.min_harm_label)
		user.visible_message("<span class='warning'>[user] labels [target] as [label]... with malicious intent!</span>", \
							 "<span class='warning'>You label [target] as [label]... with malicious intent!</span>") //OK this is total shit but I don't want to add TOO many vars to /atom
		target.harm_labeled = min(length(label) + 2, chars_left)
		target.harm_label_update()
	else
		user.visible_message("<span class='notice'>[user] labels [target] as [label].</span>", \
							 "<span class='notice'>You label [target] as [label].</span>")

	chars_left = max(chars_left - (length(label) + 2),0)

	if(!chars_left)
		to_chat(user, "<span class='notice'>The labeler is empty.</span>")
		mode = 0
		icon_state = "labeler_e"
		return
	if(chars_left < length(label) + 2)
		to_chat(user, "<span class='notice'>The labeler is almost empty.</span>")
		label = copytext(label,1,min(chars_left, length(label) + 1))

/obj/item/weapon/hand_labeler/attack_self(mob/user as mob)
	if(!chars_left)
		to_chat(user, "<span class='notice'>It's empty.</span>")
		return
	mode = !mode
	icon_state = "labeler[mode]"
	if(mode)
		to_chat(user, "<span class='notice'>You turn on \the [src].</span>")
		//Now let them chose the text.
		var/str = copytext(reject_bad_text(input(user,"Label text?","Set label","")),1,min(MAX_NAME_LEN,chars_left))
		if(!str || !length(str))
			to_chat(user, "<span class='notice'>Invalid text.</span>")
			return
		label = str
		to_chat(user, "<span class='notice'>You set the text to '[str]'.</span>")
	else
		to_chat(user, "<span class='notice'>You turn off \the [src].</span>")

/obj/item/weapon/hand_labeler/attackby(obj/item/O, mob/user)
	if(istype(O, /obj/item/device/label_roll))
		if(mode)
			to_chat(user, "<span class='notice'>Turn it off first.</span>")
			return
		var/obj/item/device/label_roll/LR = O
		var/holder = chars_left //I hate having to do this.
		chars_left = LR.left
		if(holder)
			LR.left = holder
			to_chat(user, "<span class='notice'>You switch the label rolls.</span>")
		else
			qdel(LR)
			LR = null
			to_chat(user, "<span class='notice'>You replace the label roll.</span>")
			icon_state = "labeler0"

/obj/item/weapon/hand_labeler/attack_hand(mob/user) //Shamelessly stolen from stack.dm.
	if (!mode && user.get_inactive_hand() == src)
		var/obj/item/device/label_roll/LR = new(user, amount=chars_left)
		user.put_in_hands(LR)
		to_chat(user, "<span class='notice'>You remove the label roll.</span>")
		chars_left = 0
		icon_state = "labeler_e"
	else
		..()

/obj/item/weapon/hand_labeler/examine(mob/user) //Shamelessly stolen from the paper bin.
	..()
	if(chars_left)
		to_chat(user, "<span class='info'>There " + (chars_left > 1 ? "are [chars_left] letters" : "is one letter") + " worth of label on the roll.</span>")
	else
		to_chat(user, "<span class='info'>The label roll is all used up.</span>")

/atom/proc/remove_label()
	set name = "Remove label"
	set src in view(1)
	set category = "Object"
	var/atom/A = src
	A.name = replacetext(A.name, A.labeled, "")
	A.labeled = null
	if(A.harm_labeled)
		A.harm_labeled = 0
		A.harm_label_update()
	A.verbs -= /atom/proc/remove_label

/atom/proc/harm_label_update()
	return //To be assigned (or not, in most cases) on a per-item basis.

/obj/item/device/label_roll
	name = "label roll"
	icon = 'icons/obj/bureaucracy.dmi'
	icon_state = "label_cart" //Placeholder image; recolored police tape
	w_class = W_CLASS_TINY
	var/left = 250

/obj/item/device/label_roll/examine(mob/user) //Shamelessly stolen from above.
	..()
	if(left)
		to_chat(user, "<span class='info'>There " + (left > 1 ? "are [left] letters" : "is one letter") + " worth of label on the roll.</span>")
	else
		to_chat(user, "<span class='warning'>Something has fucked up and this item should have deleted itself. Throw it away for IMMERSION.</span>")

/obj/item/device/label_roll/New(var/loc, var/amount=null)
	..()
	if(amount)
		left = amount
>>>>>>> ccb55b121a3fd5338fc56a602424016009566488
