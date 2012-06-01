/obj/machinery/computer/arcade
	name = "arcade machine"
	desc = "Does not support Pinball."
	icon = 'computer.dmi'
	icon_state = "arcade"
	circuit = "/obj/item/weapon/circuitboard/arcade"
	var/enemy_name = "Space Villian"
	var/temp = "Winners Don't Use Spacedrugs" //Temporary message, for attack messages, etc
	var/player_hp = 30 //Player health/attack points
	var/player_mp = 10
	var/enemy_hp = 45 //Enemy health/attack points
	var/enemy_mp = 20
	var/gameover = 0
	var/blocked = 0 //Player cannot attack/heal while set

/obj/machinery/computer/arcade
	var/turtle = 0

/obj/machinery/computer/arcade/New()
	..()
	var/name_action
	var/name_part1
	var/name_part2

	name_action = pick("Defeat ", "Annihilate ", "Save ", "Strike ", "Stop ", "Destroy ", "Robust ", "Romance ", "Pwn ", "Own ")

	name_part1 = pick("the Automatic ", "Farmer ", "Lord ", "Professor ", "the Cuban ", "the Evil ", "the Dread King ", "the Space ", "Lord ", "the Great ", "Duke ", "General ")
	name_part2 = pick("Melonoid", "Murdertron", "Sorcerer", "Ruin", "Jeff", "Ectoplasm", "Crushulon", "Uhangoid", "Vhakoid", "Peteoid", "Metroid", "Griefer", "ERPer", "Lizard Man", "Unicorn")

	src.enemy_name = dd_replacetext((name_part1 + name_part2), "the ", "")
	src.name = (name_action + name_part1 + name_part2)


/obj/machinery/computer/arcade/attack_ai(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/arcade/attack_paw(mob/user as mob)
	return src.attack_hand(user)

/obj/machinery/computer/arcade/attack_hand(mob/user as mob)
	if(..())
		return
	user.machine = src
	var/dat = "<a href='byond://?src=\ref[src];close=1'>Close</a>"
	dat += "<center><h4>[src.enemy_name]</h4></center>"

	dat += "<br><center><h3>[src.temp]</h3></center>"
	dat += "<br><center>Health: [src.player_hp] | Magic: [src.player_mp] | Enemy Health: [src.enemy_hp]</center>"

	if (src.gameover)
		dat += "<center><b><a href='byond://?src=\ref[src];newgame=1'>New Game</a>"
	else
		dat += "<center><b><a href='byond://?src=\ref[src];attack=1'>Attack</a> | "
		dat += "<a href='byond://?src=\ref[src];heal=1'>Heal</a> | "
		dat += "<a href='byond://?src=\ref[src];charge=1'>Recharge Power</a>"

	dat += "</b></center>"

	user << browse(dat, "window=arcade")
	onclose(user, "arcade")
	return

/obj/machinery/computer/arcade/Topic(href, href_list)
	if(..())
		return

	if (!src.blocked)
		if (href_list["attack"])
			src.blocked = 1
			var/attackamt = rand(2,6)
			src.temp = "You attack for [attackamt] damage!"
			src.updateUsrDialog()
			if(turtle > 0)
				turtle--

			sleep(10)
			src.enemy_hp -= attackamt
			src.arcade_action()

		else if (href_list["heal"])
			src.blocked = 1
			var/pointamt = rand(1,3)
			var/healamt = rand(6,8)
			src.temp = "You use [pointamt] magic to heal for [healamt] damage!"
			src.updateUsrDialog()
			turtle++

			sleep(10)
			src.player_mp -= pointamt
			src.player_hp += healamt
			src.blocked = 1
			src.updateUsrDialog()
			src.arcade_action()

		else if (href_list["charge"])
			src.blocked = 1
			var/chargeamt = rand(4,7)
			src.temp = "You regain [chargeamt] points"
			src.player_mp += chargeamt
			if(turtle > 0)
				turtle--

			src.updateUsrDialog()
			sleep(10)
			src.arcade_action()

	if (href_list["close"])
		usr.machine = null
		usr << browse(null, "window=arcade")

	else if (href_list["newgame"]) //Reset everything
		temp = "New Round"
		player_hp = 30
		player_mp = 10
		enemy_hp = 45
		enemy_mp = 20
		gameover = 0
		turtle = 0

		if(emagged)
			src.New()
			emagged = 0

	src.add_fingerprint(usr)
	src.updateUsrDialog()
	return

/obj/machinery/computer/arcade/proc/arcade_action()
	if ((src.enemy_mp <= 0) || (src.enemy_hp <= 0))
		src.gameover = 1
		src.temp = "[src.enemy_name] has fallen! Rejoice!"

		if(emagged)
			new /obj/effect/spawner/newbomb/timer/syndicate(src.loc)
			new /obj/item/clothing/head/collectable/petehat(src.loc)
			message_admins("[key_name_admin(usr)] has outbombed Cuban Pete and been awarded a bomb.")
			log_game("[key_name_admin(usr)] has outbombed Cuban Pete and been awarded a bomb.")
			src.New()
			emagged = 0

		else if(!contents.len)
			var/prizeselect = pick(1,2,3,4,5,6,7,8,9)
			switch(prizeselect)
				if(1)
					new /obj/item/toy/snappopbox(src.loc)
				if(2)
					new /obj/item/toy/blink(src.loc)
				if(3)
					new /obj/item/clothing/under/syndicate/tacticool(src.loc)
				if(4)
					new /obj/item/toy/sword(src.loc)
				if(5)
					new /obj/item/toy/ammo/gun(src.loc)
					new /obj/item/toy/gun(src.loc)
				if(6)
					new /obj/item/toy/crossbow(src.loc)
				if(7)
					new /obj/item/clothing/suit/syndicatefake(src.loc)
					new /obj/item/clothing/head/syndicatefake(src.loc)
				if(8)
					new /obj/item/weapon/storage/crayonbox(src.loc)
				if(9)
					new /obj/item/toy/spinningtoy(src.loc)
			//	if(10)									//Commented out on Urist-chan's orders~
			//		new /obj/item/toy/balloon(src.loc)	//Until it gets a better sprite~
		else
			var/atom/movable/Prize = pick(contents)
			Prize.loc = src.loc

	else if (emagged && (turtle >= 4))
		var/boomamt = rand(5,10)
		src.temp = "[src.enemy_name] throws a bomb, exploding you for [boomamt] damage!"
		src.player_hp -= boomamt

	else if ((src.enemy_mp <= 5) && (prob(70)))
		var/stealamt = rand(2,3)
		src.temp = "[src.enemy_name] steals [stealamt] of your power!"
		src.player_mp -= stealamt
		src.updateUsrDialog()

		if (src.player_mp <= 0)
			src.gameover = 1
			sleep(10)
			src.temp = "You have been drained! GAME OVER"
			if(emagged)
				usr.gib()

	else if ((src.enemy_hp <= 10) && (src.enemy_mp > 4))
		src.temp = "[src.enemy_name] heals for 4 health!"
		src.enemy_hp += 4
		src.enemy_mp -= 4

	else
		var/attackamt = rand(3,6)
		src.temp = "[src.enemy_name] attacks for [attackamt] damage!"
		src.player_hp -= attackamt

	if ((src.player_mp <= 0) || (src.player_hp <= 0))
		src.gameover = 1
		src.temp = "You have been crushed! GAME OVER"
		if(emagged)
			usr.gib()

	src.blocked = 0
	return

/obj/machinery/computer/arcade/power_change()

	if(stat & BROKEN)
		icon_state = "arcadeb"
	else
		if( powered() )
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				src.icon_state = "arcade0"
				stat |= NOPOWER

/obj/machinery/computer/arcade/attackby(I as obj, user as mob)
	if(istype(I, /obj/item/weapon/card/emag) && !emagged)
		var/obj/item/weapon/card/emag/E = I
		if(E.uses)
			E.uses--
		else
			return
		temp = "If you die in the game, you die for real!"
		player_hp = 30
		player_mp = 10
		enemy_hp = 45
		enemy_mp = 20
		gameover = 0
		blocked = 0

		emagged = 1

		enemy_name = "Cuban Pete"
		name = "Outbomb Cuban Pete"


		src.updateUsrDialog()
	else if(istype(I, /obj/item/weapon/screwdriver))
		playsound(src.loc, 'Screwdriver.ogg', 50, 1)
		if(do_after(user, 20))
			var/obj/structure/computerframe/A = new /obj/structure/computerframe( src.loc )
			var/obj/item/weapon/circuitboard/arcade/M = new /obj/item/weapon/circuitboard/arcade( A )
			for (var/obj/C in src)
				C.loc = src.loc
			A.circuit = M
			A.anchored = 1

			if (src.stat & BROKEN)
				user << "\blue The broken glass falls out."
				new /obj/item/weapon/shard( src.loc )
				A.state = 3
				A.icon_state = "3"
			else
				user << "\blue You disconnect the monitor."
				A.state = 4
				A.icon_state = "4"

			del(src)
