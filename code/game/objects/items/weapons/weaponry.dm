/obj/item/weapon/banhammer
	desc = "A banhammer"
	name = "banhammer"
	icon = 'icons/obj/items.dmi'
	icon_state = "toyhammer"
	slot_flags = SLOT_BELT
	throwforce = 0
	w_class = 1.0
	throw_speed = 7
	throw_range = 15
	attack_verb = list("banned")

/obj/item/weapon/banhammer/suicide_act(mob/user)
		viewers(user) << "<span class='suicide'>[user] is hitting \himself with the [src.name]! It looks like \he's trying to ban \himself from life.</span>"
		return (BRUTELOSS|FIRELOSS|TOXLOSS|OXYLOSS)

/obj/item/weapon/banhammer/attack(mob/M, mob/user)
	M << "<font color='red'><b> You have been banned FOR NO REISIN by [user]<b></font>"
	user << "<font color='red'> You have <b>BANNED</b> [M]</font>"


/obj/item/weapon/nullrod
	name = "null rod"
	desc = "A rod of pure obsidian, its very presence disrupts and dampens the powers of Nar-Sie's followers."
	icon_state = "nullrod"
	item_state = "nullrod"
	slot_flags = SLOT_BELT
	force = 15
	throw_speed = 1
	throw_range = 4
	throwforce = 10
	w_class = 1

	suicide_act(mob/user)
		viewers(user) << "<span class='suicide'>[user] is impaling \himself with the [src.name]! It looks like \he's trying to commit suicide.</span>"
		return (BRUTELOSS|FIRELOSS)

/obj/item/weapon/sord
	name = "\improper SORD"
	desc = "This thing is so unspeakably shitty you are having a hard time even holding it."
	icon_state = "sord"
	item_state = "sord"
	slot_flags = SLOT_BELT
	force = 2
	throwforce = 1
	w_class = 3
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

	suicide_act(mob/user)
		viewers(user) << "<span class='suicide'>[user] is impaling \himself with the [src.name]! It looks like \he's trying to commit suicide.</span>"
		return(BRUTELOSS)

/obj/item/weapon/claymore
	name = "claymore"
	desc = "What are you standing around staring at this for? Get to killing!"
	icon_state = "claymore"
	item_state = "claymore"
	flags = CONDUCT
	slot_flags = SLOT_BELT
	force = 40
	throwforce = 10
	w_class = 3
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

	IsShield()
		return 1

	suicide_act(mob/user)
		viewers(user) << "<span class='suicide'>[user] is falling on the [src.name]! It looks like \he's trying to commit suicide.</span>"
		return(BRUTELOSS)

/obj/item/weapon/claymore/attack(mob/living/carbon/M as mob, mob/living/carbon/user as mob)
	playsound(loc, 'sound/weapons/bladeslice.ogg', 50, 1, -1)
	return ..()

/obj/item/weapon/katana
	name = "katana"
	desc = "Woefully underpowered in D20"
	icon_state = "katana"
	item_state = "katana"
	flags = CONDUCT
	slot_flags = SLOT_BELT | SLOT_BACK
	force = 40
	throwforce = 10
	w_class = 3
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "torn", "ripped", "diced", "cut")

	suicide_act(mob/user)
		viewers(user) << "<span class='suicide'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>"
		return(BRUTELOSS)

/obj/item/weapon/katana/IsShield()
		return 1

obj/item/weapon/wirerod
	name = "wired rod"
	desc = "A rod with some wire wrapped around the top. It'd be easy to attach something to the top bit."
	icon_state = "wiredrod"
	item_state = "rods"
	flags = CONDUCT
	force = 9
	throwforce = 10
	w_class = 3
	m_amt = 1875
	attack_verb = list("hit", "bludgeoned", "whacked", "bonked")

obj/item/weapon/wirerod/attackby(var/obj/item/I, mob/user as mob)
	..()
	if(istype(I, /obj/item/weapon/shard))
		var/obj/item/weapon/twohanded/spear/S = new /obj/item/weapon/twohanded/spear

		user.before_take_item(I)
		user.before_take_item(src)

		user.put_in_hands(S)
		user << "<span class='notice'>You fasten the glass shard to the top of the rod with the cable.</span>"
		del(I)
		del(src)

	else if(istype(I, /obj/item/weapon/wirecutters))
		var/obj/item/weapon/melee/baton/cattleprod/P = new /obj/item/weapon/melee/baton/cattleprod

		user.before_take_item(I)
		user.before_take_item(src)

		user.put_in_hands(P)
		user << "<span class='notice'>You fasten the wirecutters to the top of the rod with the cable, prongs outward.</span>"
		del(I)
		del(src)

/obj/item/weapon/raidensword
	name = "high frequency blade"
	desc = "It's time to LET 'ER RIP!"
	icon_state = "raidensword"
	item_state = "raidensword"
	flags = FPRINT | TABLEPASS | CONDUCT

	slot_flags = SLOT_BELT | SLOT_BACK
	force = 45
	throwforce = 99
	w_class = 3
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("blade moded", "slashed", "stabbed", "zandatsued", "torn", "let 'er ripped", "diced", "rules of natured")

	suicide_act(mob/user)
		viewers(user) << "<span class='suicide'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit RULES OF NATURE.</span>"
		return(BRUTELOSS)

/obj/item/weapon/raidensword/IsShield()
		return 1

/obj/item/weapon/nigurslair
	name = "Nigürslair"
	desc = "The ancient sword summoned by Donkey for Shrek's quest for vengeance. It was thought to have been long lost. There's a foreign language etched onto the blade."
	icon_state = "nigurslair"
	item_state = "nigurslair"
	flags = FPRINT | TABLEPASS | CONDUCT
	slot_flags = SLOT_BELT
	force = 85
	throwforce = 99
	w_class = 3
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("shreked", "layered", "onioned", "swamped")

	suicide_act(mob/user)
		viewers(user) << "<span class='suicide'>[user] is stabbing \himself with the [src.name]! It looks like \he's trying to commit suicide.</span>"
		return(BRUTELOSS)

/obj/item/weapon/nigurslair/IsShield()
		return 1


/obj/item/weapon/samsword
	name = "high frequency murasama"
	desc = "Let's dance!"
	icon_state = "samsword"
	item_state = "samsword"
	flags = FPRINT | TABLEPASS | CONDUCT

	slot_flags = SLOT_BELT | SLOT_BACK
	force = 70
	throwforce = 30
	w_class = 3
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("brazil'd", "slashed", "stabbed", "charmed", "torn", "sam'd", "diced", "schooled")

	suicide_act(mob/user)
		viewers(user) << "<span class='suicide'>[user] is slitting \his stomach open with the [src.name]! It looks like \he's trying to commit seppuku.</span>"
		return(BRUTELOSS)

/obj/item/weapon/samsword/IsShield()
		return 1


//Telescopic baton
/obj/item/weapon/melee/telebaton
        name = "telescopic baton"
        desc = "A compact yet robust personal defense weapon. Can be concealed when folded."
        icon = 'icons/obj/weapons.dmi'
        icon_state = "telebaton_0"
        item_state = "telebaton_0"
        flags = FPRINT | TABLEPASS
        slot_flags = SLOT_BELT
        w_class = 2
        force = 3
        var/on = 0


/obj/item/weapon/melee/telebaton/attack_self(mob/user as mob)
        on = !on
        if(on)
                user.visible_message("\red With a flick of their wrist, [user] extends their telescopic baton.",\
                "\red You extend the baton.",\
                "You hear an ominous click.")
                icon_state = "telebaton_1"
                item_state = "telebaton_1"
                w_class = 3
                force = 15//quite robust
                attack_verb = list("smacked", "struck", "slapped")
        else
                user.visible_message("\blue [user] collapses their telescopic baton.",\
                "\blue You collapse the baton.",\
                "You hear a click.")
                icon_state = "telebaton_0"
                item_state = "telebaton_0"
                w_class = 2
                force = 3//not so robust now
                attack_verb = list("hit", "punched")

        if(istype(user,/mob/living/carbon/human))
                var/mob/living/carbon/human/H = user
                H.update_inv_l_hand()
                H.update_inv_r_hand()

        playsound(src.loc, 'sound/weapons/empty.ogg', 50, 1)
        add_fingerprint(user)

        if(blood_overlay && (blood_DNA.len >= 1)) //updates blood overlay, if any
                overlays.Cut()//this might delete other item overlays as well but eeeeeeeh

                var/icon/I = new /icon(src.icon, src.icon_state)
                I.Blend(new /icon('icons/effects/blood.dmi', rgb(255,255,255)),ICON_ADD)
                I.Blend(new /icon('icons/effects/blood.dmi', "itemblood"),ICON_MULTIPLY)
                blood_overlay = I

                overlays += blood_overlay

        return

/obj/item/weapon/melee/telebaton/attack(mob/target as mob, mob/living/user as mob)
        if(on)
                if ((CLUMSY in user.mutations) && prob(50))
                        user << "\red You club yourself over the head."
                        user.Weaken(3 * force)
                        if(ishuman(user))
                                var/mob/living/carbon/human/H = user
                                H.apply_damage(2*force, BRUTE, "head")
                        else
                                user.take_organ_damage(2*force)
                        return
                if(..())
                        playsound(src.loc, "swing_hit", 50, 1, -1)
                        target.Weaken(4)
                        return
        else
                return ..()

