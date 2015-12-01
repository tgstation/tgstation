//#define DEBUG_SLOT_MACHINES
#ifdef DEBUG_SLOT_MACHINES
	#warning Slot machines are being debugged! Turn this off in code/game/machinery/computer/slot_machine.dm
#endif

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

#define MINIMUM_WIN_TO_BROADCAST	15000
#define MINIMUM_MONEY_TO_PLAY		1000

/obj/machinery/computer/slot_machine
	name = "one-armed bandit"
	desc = "The arm is just for decoration."
	icon = 'icons/obj/slot_machine.dmi'
	icon_state = "slot"

	machine_flags = SCREWTOGGLE | CROWDESTROY | WRENCHMOVE | FIXED2WORK

	var/show_name

	var/image/overlay_1
	var/image/overlay_2
	var/image/overlay_3

	var/value_1 = 1
	var/value_2 = 1
	var/value_3 = 1

	//If rigged, the next spin will be a guaranteed win
	var/rigged = 0

	var/stored_money = 0 //Cash

	var/spin_cost = 15 //How much it costs to play
	var/spinning = 0

	var/id = 0 //The slot machine's ID. Fluff mostly
	var/datum/money_account/our_money_account

	var/obj/item/device/radio/radio

/obj/machinery/computer/slot_machine/New()
	.=..()

	id = rand(1,99999)

	our_money_account = create_account("slot machine ([id])", rand(30000,50000))
	radio = new(src)

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

	//The reason why there guys aren't actually added to the overlays list is that their icon_state has to be changed during the spin() proc,
	//which would be impossible if they were in the overlays list

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
		init_overlays()
		add_overlays()

		icon_state = initial_icon

/obj/machinery/computer/slot_machine/proc/spin_wheels(win = -1) //If win=-1, the result is pure randomness. If win=0, you NEVER win. If win is 1 to 10, you win.
	while(1)
		value_1 = rand(1,10)
		value_2 = rand(1,10)
		value_3 = rand(1,10)

		switch(win)
			if(-1)
				return //Pure randomness!
			if(0)
				if(!(value_1 == value_2 && value_2 == value_3)) //If we're NOT winning
					return //Else, run the loop again until the three values no longer match
			if(1 to 10)
				value_1 = win
				value_2 = win
				value_3 = win
				return
			else
				return

/obj/machinery/computer/slot_machine/proc/spin(mob/user)
	if(spinning) return

	//Charge money:
	if(stored_money >= spin_cost) //If there's cash in the machine
		stored_money -= spin_cost
	else
		return

	spinning = 1

	//Overlays are shit and can't be modified, so remove all overlays
	remove_overlays()


	//Pre-calculate results
	if(rigged)
		value_1 = Clamp(rigged, 1, TREE)
		value_2 = value_1
		value_3 = value_1

		rigged = 0

	else
		var/victory = rand(1,10)

		#ifdef DEBUG_SLOT_MACHINES
		to_chat(user, "Rolled [victory]!")
		#endif

		switch(victory)
			if(1) //1 in 10 for a guaranteed small reward
				spin_wheels(win = pick(BELL, MUSHROOM, TREE))
			if(2 to 10) //Otherwise, a fully random spin (1/1000 to get jackpot, 1/100 to get other reward)
				spin_wheels(win = -1)

	//If there's only one icon_state for spinning, everything looks weird
	var/list/spin_states = list("spin1","spin2","spin3")
	overlay_1.icon_state=pick(spin_states)
	spin_states -= overlay_1.icon_state

	overlay_2.icon_state=pick(spin_states)
	spin_states -= overlay_2.icon_state

	overlay_3.icon_state=pick(spin_states)
	spin_states -= overlay_3.icon_state

	//Readd all overlays
	add_overlays()

	var/sound/sound_to_play = pick('sound/effects/xylophone1.ogg','sound/effects/xylophone2.ogg','sound/effects/xylophone3.ogg')
	playsound(get_turf(src),sound(sound_to_play),30,-4)

	var/sleep_time = 48

	sleep(sleep_time/3)
	update_overlay_icon_state(overlay_1,"[value_1]")
	playsound(get_turf(src),'sound/machines/chime.ogg',50,-4)

	sleep(sleep_time/3)
	update_overlay_icon_state(overlay_2,"[value_2]")
	playsound(get_turf(src),'sound/machines/chime.ogg',50,-4)

	sleep(sleep_time/3)
	update_overlay_icon_state(overlay_3,"[value_3]")
	playsound(get_turf(src),'sound/machines/chime.ogg',50,-4)

	check_victory(user)

	spinning = 0

/obj/machinery/computer/slot_machine/proc/check_victory(mob/user)
	if(!our_money_account)
		return

	if((value_1 == value_2) && (value_1 == value_3))
		var/win_image = image('icons/obj/slot_machine.dmi', icon_state="win")
		overlays |= win_image

		var/win_value = 0

		switch(value_1)
			//1/1000 chance of winning the jackpot.
			if(SEVEN)
				win_value = our_money_account.money
				broadcast("[user] has just won the JACKPOT ($[win_value])!")

			//Roughly 6/1000 chance of winning either of the below six rewards. You spend 3000$
			//Average gain: 2837,5$

			if(CHICKEN)
				win_value = 400 * spin_cost //6000$
				var/mob/living/simple_animal/chicken/C = new(src.loc)
				C.name = "Pomf chicken"
				C.body_color = "white"
				C.icon_state = "chicken_white"
				C.icon_living = "chicken_white"
				C.icon_dead = "chicken_white_dead"
			if(DIAMOND)
				win_value = 300 * spin_cost //4500$
			if(CHERRY)
				win_value = 200 * spin_cost //3000$
			if(HEART)
				win_value = 100 * spin_cost //1500$
			if(MELON)
				win_value = 75 * spin_cost //1125$
			if(PLUM)
				win_value = 60 * spin_cost //900$

			//There is a 1/10 + 3/1000 chance of winning either of the below three rewards. This means you've got to play 10 times (and spend 150$) to get a
			//chance of winning either 180$,150$ or 60$
			//The rewards average to 130$, which means our machine comes out with 20$ profit!

			if(BELL)
				win_value = 12 * spin_cost //180$ by default
			if(MUSHROOM)
				win_value = 10 * spin_cost //150$ by default
			if(TREE)
				win_value = 4 * spin_cost //60$ by default

		if(win_value)
			win_value = min(win_value, our_money_account.money)

			spawn(10)
				if(our_money_account.charge(win_value,null,"Victory","one-armed bandit #[id]"))
					dispense_cash(win_value, get_turf(src))
					playsound(get_turf(src), "polaroid", 50, 1)

					to_chat(user, "<span class='notice'>You win $[win_value]!</span>")
				else
					src.visible_message("<span class='danger'>[src]'s screen flashes red.</span>")

		sleep(50)

		overlays -= win_image

//Broadcast something over the radio!
/obj/machinery/computer/slot_machine/proc/broadcast(var/message)
	if(!message) return

	Broadcast_Message(radio, all_languages[LANGUAGE_SOL_COMMON], null, radio, message, "[capitalize(src.name)]", "Money Snatcher", "Slot machine #[id]", 0, 0, list(0,1), 1459)

/obj/machinery/computer/slot_machine/attack_hand(mob/user as mob)
	if(..())
		return

	user.set_machine(src)

	var/dat = {"<h4><center>Current Jackpot: <b>[our_money_account ? "$[num2septext(our_money_account.money)]" : "---ERROR---"]</b></center></h4><br>"}

	if(stored_money > 0)
		dat += {"There are <span style="color:[stored_money<spin_cost?"red":"green"]"><b>$[num2septext(stored_money)]</b>
			space credits insterted. <span style="color:blue"><a href='?src=\ref[src];reclaim=1'>Reclaim</a></span><br>"}
	else
		dat += {"You need at least <b>$[spin_cost]</b> credits to play. Use a nearby ATM and retreive some cash from your money account!<br>"}

	if(can_play())
		if(stored_money >= spin_cost)
			dat += {"<span style="color:yellow"><a href='?src=\ref[src];spin=1'>Play! (<b>$[spin_cost]</b>)</a></span><br>"}

	else
		dat += {"<b>OUT OF SERVICE</b><br>"}

	var/datum/browser/popup = new(user, "slotmachine", "[src]", 500, 300, src)
	popup.set_content(dat)
	popup.open()

	onclose(user, "slotmachine")

/obj/machinery/computer/slot_machine/Topic(href, href_list)
	if(..())
		return
	if(spinning)
		return

	if(href_list["reclaim"])
		dispense_cash(stored_money, get_turf(src))
		stored_money = 0

	else if(href_list["spin"])
		if((stored_money >= spin_cost) && can_play())
			spin(usr)

	src.updateUsrDialog()


/obj/machinery/computer/slot_machine/attackby(obj/item/I as obj, mob/user as mob)
	..()

	if(istype(I,/obj/item/weapon/spacecash))
		if(!can_play())
			to_chat(user, "<span class='notice'>[src] rejects your money.</span>")
			return

		var/obj/item/weapon/spacecash/S = I
		var/money_add = S.amount * S.worth

		user.drop_item(I)
		qdel(I)

		src.stored_money += money_add
		src.updateUsrDialog()

/obj/machinery/computer/slot_machine/proc/can_play() //If no money in OUR account, return 0
	if(!our_money_account)
		return 0
	if(our_money_account.money < MINIMUM_MONEY_TO_PLAY)
		return 0

	return 1

#undef MINIMUM_WIN_TO_BROADCAST
#undef MINIMUM_MONEY_TO_PLAY

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
