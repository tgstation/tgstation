#define SEVEN		1
#define DIAMOND		2
#define CHERRY		3
#define HEART		4
#define MELON		5
#define PLUM		6
#define BELL		7
#define MUSHROOM	8
#define CHICKEN		9
#define TREE		10
#define SIX			11

/obj/machinery/computer/slot_machine
	name = "one-armed bandit"
	desc = "The arm is just for decoration."
	icon = 'icons/obj/slot_machine.dmi'
	icon_state = "slot"

	machine_flags = EMAGGABLE | SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK
	emag_cost = 0

	var/show_name

	var/image/overlay_1
	var/image/overlay_2
	var/image/overlay_3

	var/value_1 = 1
	var/value_2 = 1
	var/value_3 = 1

	//If rigged, the next spin will be a guaranteed win
	var/rigged = 0

	var/obj/item/weapon/card/id/login
	var/stored_money = 0

	var/spin_cost = 15
	var/spinning = 0

	var/id = 0
	var/datum/money_account/money_account

/obj/machinery/computer/slot_machine/New()
	.=..()

	id = rand(1,99999)

	money_account = create_account("slot machine ([id])", rand(1000,20000))

	update_icon()

/obj/machinery/computer/slot_machine/proc/remove_overlays()
	overlays -= list(overlay_1,overlay_2,overlay_3)

/obj/machinery/computer/slot_machine/proc/add_overlays()
	overlays |= list(overlay_1,overlay_2,overlay_3)

/obj/machinery/computer/slot_machine/proc/update_overlay_icon_state(var/image/I, var/new_icon_state)
	overlays -= I
	I.icon_state = new_icon_state
	overlays |= I

/obj/machinery/computer/slot_machine/proc/init_overlays()
	overlay_1 = image('icons/obj/slot_machine.dmi',icon_state="[value_1]",loc = src)

	overlay_2 = image('icons/obj/slot_machine.dmi',icon_state="[value_2]",loc = src)
	overlay_2.pixel_x = 4

	overlay_3 = image('icons/obj/slot_machine.dmi',icon_state="[value_3]",loc = src)
	overlay_3.pixel_x = 8

	//The reason why there guys aren't actually added to the overlays list is that they have to be modified during the spin() proc,
	//which is impossible if they were in the overlays list

/obj/machinery/computer/slot_machine/update_icon()
	..()
	var/initial_icon = initial(icon_state)

	if(stat & BROKEN)
		icon_state = "[initial_icon]b"
		remove_overlays()
	else if(stat & NOPOWER)
		icon_state = "[initial_icon]0"
		remove_overlays()
	else
		icon_state = initial_icon
		init_overlays()

	if(emagged)
		icon_state = "[initial_icon]_emag"

/obj/machinery/computer/slot_machine/proc/spin()
	if(spinning || !login) return

	var/datum/money_account/acct = get_card_account(login)
	if(!acct || !acct.charge(spin_cost,money_account,"One-armed bandit","one-armed bandit #[id]"))
		return

	spinning = 1

	remove_overlays()

	value_1 = rand(1,10)
	value_2 = rand(1,10)
	value_3 = rand(1,10)

	if(rigged)
		value_2 = value_1
		value_3 = value_1

		rigged = 0

	//What happens here: if emagged AND all the values are equal (which normally results in a reward), replace all values with 11
	//This means you have 1/100 chance to win the secret reward if you emag the slot machine
	if(emagged)
		if((value_1 == value_2) && (value_1 == value_3))
			value_1 = 11
			value_2 = 11
			value_3 = 11

	overlay_1.icon_state="spin"
	overlay_2.icon_state="spin"
	overlay_3.icon_state="spin"

	add_overlays()

	var/sound/sound_to_play
	if(emagged)
		sound_to_play = pick('sound/misc/TestLoop1.ogg') //This sound is amazing
		playsound(get_turf(src),sound(sound_to_play),50,1)
	else
		sound_to_play = pick('sound/effects/xylophone1.ogg','sound/effects/xylophone2.ogg','sound/effects/xylophone3.ogg')
		playsound(get_turf(src),sound(sound_to_play),50,-4)

	var/sleep_time = rand(40,70)

	sleep(sleep_time/3)
	update_overlay_icon_state(overlay_1,value_1)
	playsound(get_turf(src),'sound/machines/chime.ogg',50,-4)

	sleep(sleep_time/3)
	update_overlay_icon_state(overlay_2,value_2)
	playsound(get_turf(src),'sound/machines/chime.ogg',50,-4)

	sleep(sleep_time/3)
	update_overlay_icon_state(overlay_3,value_3)
	playsound(get_turf(src),'sound/machines/chime.ogg',50,-4)

	check_victory()

	spinning = 0

/obj/machinery/computer/slot_machine/proc/check_victory()
	if(!money_account)
		return

	if((value_1 == value_2) && (value_1 == value_3))
		var/win_image = image('icons/obj/slot_machine.dmi', icon_state="win")
		overlays |= win_image

		var/win_value = 0

		switch(value_1)
			if(SEVEN) //
				win_value = money_account.money
			if(CHICKEN)
				win_value = 0.8 * money_account.money
				var/mob/living/simple_animal/chicken/C = new(src.loc)
				C.name = "Pomf chicken"
				C.body_color = "white"
				C.icon_state = "chicken_white"
				C.icon_living = "chicken_white"
				C.icon_dead = "chicken_white_dead"
			if(DIAMOND)
				win_value = 0.75 * money_account.money
			if(CHERRY)
				win_value = 0.5 * money_account.money
			if(HEART)
				win_value = 0.5 * money_account.money
			if(MELON)
				win_value = 0.3 * money_account.money
			if(PLUM)
				win_value = 0.3 * money_account.money
			if(BELL)
				win_value = 0.2 * money_account.money
			if(MUSHROOM)
				win_value = 0.1 * money_account.money
				for(var/i, i<rand(5,10), i++)
					var/obj/item/weapon/reagent_containers/food/snacks/grown/mushroom/libertycap/M = new(src.loc)
					M.name = "victory mushroom"
			if(TREE)
				win_value = max(money_account.money, spin_cost)
			if(SIX) //Only when emagged
				explosion(get_turf(src),-1,2,4)
				new/obj/item/weapon/veilrender/vealrender(get_turf(src))
				return qdel(src)

		spawn(10)
			dispense_cash(win_value, get_turf(src))
			playsound(get_turf(src), "polaroid", 50, 1)

		sleep(50)

		overlays -= win_image

/obj/machinery/computer/slot_machine/attack_hand(mob/user as mob)
	if(..())
		return

	user.set_machine(src)

	var/dat = {"<html><body[emagged?"bgcolor=\"#E50000\"":""]>
	<h4><center>Current Jackpot: <b>[money_account ? "$[num2septext(money_account.money)]" : "---ERROR---"]</b></center></h4><br>"}

	if(!login)
		dat+={"Please swipe your ID card to login and begin playing!"}
	else
		if(!emagged)
			var/account_money = login.GetBalance()
			dat +={"Welcome, <b>[login.registered_name]</b>! (<a href='?src=\ref[src];logout=1'>log out</a>)<br>
			Your account balance is: <span style="color:[account_money<spin_cost?"red":"green"]"><b>[login.GetBalance(1)]</b><br>"}

			if(stored_money > 0)
				dat += {"Additionally, there are <span style="color:[account_money<spin_cost?"red":"green"]"><b>$[num2septext(stored_money)]</b>
					space credits insterted. <span style="color:blue"><a href='?src=\ref[src];reclaim=1'>Reclaim</a></span><br>"}

			if(account_money >= spin_cost || stored_money >= spin_cost)
				dat += {"<span style="color:yellow"><a href='?src=\ref[src];spin=1'>Play! (<b>$[spin_cost]</b>)</a></span>"}
			else
				dat += {"<br><span style="color:red">You must have at least <b>$[spin_cost]</b> space credits to play.</span>"}
		else //EMAG STUFF--------------------------------------------------------------------------------------------------------------------
			dat +={"<span style="color:yellow">Welcome to hell, [login.registered_name]! (you can't escape)<br>
				<a href='?src=\ref[src];spin=1'>Play! (<b>$_free_</b>)</a><br><br>
				<b>Warning:</b> excessive gambling will turn you into a one-armed bandit."}

	dat += "</body></html>"

	user << browse(dat, "window=slotmachine")
	onclose(user, "slotmachine")

/obj/machinery/computer/slot_machine/Topic(href, href_list)
	if(..())
		return

	if(href_list["logout"])
		login = null
	else if(href_list["reclaim"])
		if(!login)
			return
		dispense_cash(stored_money, get_turf(src))
	else if(href_list["spin"])
		if(!login)
			return

		if(login.GetBalance() >= spin_cost)
			spin()

			if(emagged && usr)
				if(istype(usr,/mob/living/carbon/human))
					var/mob/living/carbon/human/H = usr

					var/datum/organ/external/nom = H.get_organ(pick("r_hand","l_hand","r_arm","l_arm","r_foot","l_foot","r_leg","l_leg"))
					if(!nom || (nom.status & ORGAN_DESTROYED))
						H << "<span class='notice'>You escape \the [src]'s wrath this time.</span>"
					else
						H << "<span class='danger'>[src] consumes your [nom.name]!</span>"
						nom.droplimb(1,0)

				else if(istype(usr,/mob/living))
					var/mob/living/L = usr
					L.adjustFireLoss(30)
					L << "<span class='danger'>You feel your soul burning.</span>"

	src.updateUsrDialog()


/obj/machinery/computer/slot_machine/attackby(obj/item/I as obj, mob/user as mob)
	..()

	if(istype(I,/obj/item/weapon/card/id))
		if((stat & NOPOWER) || (stat & BROKEN))
			user << "You swipe \the [I] at \the [src], but nothing happens."
		else if(login)
			user << "You swipe \the [I] at \the [src], but the screen briefly flashes red."
		else
			login = I
			user << "You swipe \the [I] at \the [src], and it lights up."
		src.updateUsrDialog()

/obj/machinery/computer/slot_machine/emag(mob/user as mob)
	emagged = 1

	user << "<span class='warning'>[src] starts radiating heat all of sudden! You feel an urge to play...</span>"

	flags -= SCREWTOGGLE

	update_icon()

#undef SEVEN
#undef DIAMOND
#undef CHERRY
#undef HEART
#undef MELON
#undef PLUM
#undef BELL
#undef MUSHROOM
#undef CHICKEN
#undef TREE
#undef SIX
