//This is stuff implemented by the Shitty Suggestions thread on the forums
//These only work if an admin has triggered the Shitty Suggestion Activation event via buttons

//Smite Evil: A chaplain ability that can either heal a non-antag or damage an antag. Has a 2-minute cooldown.
/mob/living/carbon/human/proc/smite_evil(var/mob/living/carbon/heathen)
	set name = "Smite Evil"
	set category = "Thaumaturgy"

	if(!ticker.mode.shitty)
		usr << "<span class='warning'>You feel insufficiently powerful to use this ability.</span>"
		return

	if(usr.stat)
		return

	if(usr == heathen)
		return

	if(!in_range(usr, heathen))
		return

	usr << "<span class='notice'>You call upon [ticker.Bible_deity_name ? "the light of " + ticker.Bible_deity_name : "the light of the gods "] and envelop [heathen] in a cocoon!</span>"
	heathen.visible_message("<span class='danger'>[usr] makes a gesture, and [heathen] is wrapped in white light!</span>")

	if(heathen in ticker.mode || heathen.mind in ticker.mode)
		heathen << "<span class='userdanger'>A blinding white light envelops you, and you feel your skin burning!</span>"
		heathen.take_organ_damage(0,25)
		heathen.audible_message("<b>[heathen]</b> screams!")
	else
		heathen << "<span class='notice'>A blinding white light envelops you, and you feel your skin mending!</span>"
		heathen.heal_organ_damage(25,25)
	playsound(heathen.loc, 'sound/weapons/sear.ogg', 50, 1)

	sleep(20)
	heathen.visible_message("<span class='danger'>The white light around [heathen] dissipates as suddenly as it appeared.</span>")

	usr.verbs -= /mob/living/carbon/human/proc/smite_evil
	usr << "<span class='warning'>Your inner fire simmers down to embers. Perhaps in time it will recover?</span>"
	sleep(1200) //2 minutes
	usr.verbs += /mob/living/carbon/human/proc/smite_evil
	usr << "<span class='notice'>You feel a holy energy fill you once more.</span>"



//Faggot of the Damned: Lets you speak a single message to all dead mobs, but only once! 1% chance after being used to gain another message
/obj/item/weapon/reagent_containers/food/snacks/faggot/deadchat
	name = "faggot of the damned"
	desc = "This mystical artifact allows you to speak a single message to the realm of spirits... but only once. To use it, simply activate it in your hand. Eating it will nullify its powers."
	unacidable = 1
	var/active = 0

/obj/item/weapon/reagent_containers/food/snacks/faggot/deadchat/attack_self(mob/sodiumchloride as mob)
	if(active)
		return //only one message
	active = 1
	sodiumchloride << "<span class='deadsay'>You feel the eyes of countless deceased souls upon you. Speak your message to them.</span>"
	var/what_to_send = stripped_input("", "Message to the Damned", "")
	if(!what_to_send)
		sodiumchloride << "<span class='notice'>You abruptly lower \the [src] from your eyes. Perhaps you should think this through.</span>"
		active = 0
		return
	playsound(src.loc, 'sound/effects/ghost2.ogg', 50, 1)
	sodiumchloride.visible_message("<span class='danger'>[sodiumchloride]'s eyes and mouth glow a deep violet as they speak, before slowly dimming back to normal...</span>", \
								   "<span class='deadsay'>You speak into \the [src], its energies awash in your body.</span>")
	sodiumchloride.say(what_to_send)
	flags = NODROP

	for(var/mob/M in dead_mob_list)
		M << "<span class='deadsay'><b>A brief message comes from the realm of the living... </b> <i>[what_to_send]</i></span>"

	sleep(20)
	flags = null
	sodiumchloride.unEquip(src)
	if(prob(99))
		visible_message("<span class='warning'>Its unearthly powers expended, \the [src] falls to the ground. Within moments, it is just another faggot.</span>")
		new /obj/item/weapon/reagent_containers/food/snacks/faggot(loc)
		qdel(src)
	else
		visible_message("<span class='warning'>\The [src] glows a deep purple and vibrates with renewed energy. Its powers have not yet been expended.</span>")
		active = 0 //another message
	return



//Blade of Grass: Botanist arm-blade, instead of doing damage it injects people with space drugs and makes the attacker say hippie stuff
/obj/item/weapon/melee/arm_blade/grass
	name = "grass blade"
	desc = "Why make war when you can, like, make love, man?"
	force = 0
	attack_verb = list("tripped", "drugged", "totally far-outed", "conspiracied", "peaced")
	var/uses = 4 //5 hits total

/obj/item/weapon/melee/arm_blade/grass/attack(mob/living/carbon/human/druggie as mob, mob/living/carbon/human/hippie as mob)
	..()
	uses--
	var/trippy_phrases = list("Spread the love, maaaan...", "Duuuude...", "Make love, not war...", "Far out, bruh...", "It's all a conspiracy, duuuude...")
	druggie.reagents.add_reagent("space_drugs", 50)
	druggie << "<span class='userdanger'>[pick("Far out", "Trippy", "Woah")], m<font size=4>a</font><font size=3>a</font><font size=5>a</font><font size=3>a</font>an...</span>"
	if(prob(50))
		hippie.say(pick(trippy_phrases))

	if(uses <= 0)
		visible_message("<span class'danger'>\The [src] curls up, slipping off of [hippie]'s arm, and withers away.</span>")
		flags = ABSTRACT
		hippie.unEquip(src)
		qdel(src)



//Putting heads on spears
/obj/item/organ/limb/head/attackby(var/obj/item/weapon/W, var/mob/living/user, params)
	if(istype(W, /obj/item/weapon/twohanded/spear) && ticker.mode.shitty)
		user << "<span class='notice'>You stick the head onto the spear and stand it upright on the ground.</span>"
		new /obj/structure/headspear(user.loc)
		qdel(W)
		qdel(src)
		return
	return ..()

/obj/item/weapon/twohanded/spear/attackby(var/obj/item/I, var/mob/living/user)
	if(istype(I, /obj/item/organ/limb/head) && ticker.mode.shitty)
		user << "<span class='notice'>You stick the head onto the spear and stand it upright on the ground.</span>"
		new /obj/structure/headspear(user.loc)
		qdel(I)
		qdel(src)
		return
	return ..()

/obj/structure/headspear
	name = "head on a spear"
	desc = "How barbaric."
	icon_state = "headspear"
	density = 0
	anchored = 1

/obj/structure/headspear/attack_hand(mob/living/user)
	user.visible_message("<span class='warning'>[user] kicks over \the [src]!</span>", "<span class='danger'>You kick down \the [src]!</span>")
	new /obj/item/weapon/twohanded/spear(loc)
	new /obj/item/organ/limb/head(loc)
	qdel(src)
