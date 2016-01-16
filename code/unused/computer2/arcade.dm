/datum/computer/file/computer_program/arcade
	name = "Arcade 500"
	size = 8.0
	var/enemy_name = "Space Villian"
	var/temp = "Winners Don't Use Spacedrugs" //Temporary message, for attack messages, etc
	var/player_hp = 30 //Player health/attack points
	var/player_mp = 10
	var/enemy_hp = 45 //Enemy health/attack points
	var/enemy_mp = 20
	var/gameover = 0
	var/blocked = 0 //Player cannot attack/heal while set

	New(obj/holding as obj)
		if(holding)
			src.holder = holding

			if(istype(src.holder.loc,/obj/machinery/computer2))
				src.master = src.holder.loc

//		var/name_action = pick("Defeat ", "Annihilate ", "Save ", "Strike ", "Stop ", "Destroy ", "Robust ", "Romance ")

		var/name_part1 = pick("the Automatic ", "Farmer ", "Lord ", "Professor ", "the Evil ", "the Dread King ", "the Space ", "Lord ")
		var/name_part2 = pick("Melonoid", "Murdertron", "Sorcerer", "Ruin", "Jeff", "Ectoplasm", "Crushulon")

		src.enemy_name = replacetext((name_part1 + name_part2), "the ", "")
//		src.name = (name_action + name_part1 + name_part2)



/datum/computer/file/computer_program/arcade/return_text()
	if(..())
		return

	var/dat = "<a href='byond://?src=\ref[src];close=1'>Close</a> | "
	dat += "<a href='byond://?src=\ref[src];quit=1'>Quit</a>"

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

	return dat

/datum/computer/file/computer_program/arcade/Topic(href, href_list)
	if(..())
		return

	if (!src.blocked)
		if (href_list["attack"])
			src.blocked = 1
			var/attackamt = rand(2,6)
			src.temp = "You attack for [attackamt] damage!"
			src.master.updateUsrDialog()

			sleep(10)
			src.enemy_hp -= attackamt
			src.arcade_action()

		else if (href_list["heal"])
			src.blocked = 1
			var/pointamt = rand(1,3)
			var/healamt = rand(6,8)
			src.temp = "You use [pointamt] magic to heal for [healamt] damage!"
			src.master.updateUsrDialog()

			sleep(10)
			src.player_mp -= pointamt
			src.player_hp += healamt
			src.blocked = 1
			src.master.updateUsrDialog()
			src.arcade_action()

		else if (href_list["charge"])
			src.blocked = 1
			var/chargeamt = rand(4,7)
			src.temp = "You regain [chargeamt] points"
			src.player_mp += chargeamt

			src.master.updateUsrDialog()
			sleep(10)
			src.arcade_action()

	if (href_list["newgame"]) //Reset everything
		temp = "New Round"
		player_hp = 30
		player_mp = 10
		enemy_hp = 45
		enemy_mp = 20
		gameover = 0

	src.master.add_fingerprint(usr)
	src.master.updateUsrDialog()
	return

/datum/computer/file/computer_program/arcade/proc/arcade_action()
	if ((src.enemy_mp <= 0) || (src.enemy_hp <= 0))
		src.gameover = 1
		src.temp = "[src.enemy_name] has fallen! Rejoice!"
		src.peripheral_command("vend prize")

	else if ((src.enemy_mp <= 5) && (prob(70)))
		var/stealamt = rand(2,3)
		src.temp = "[src.enemy_name] steals [stealamt] of your power!"
		src.player_mp -= stealamt
		src.master.updateUsrDialog()

		if (src.player_mp <= 0)
			src.gameover = 1
			sleep(10)
			src.temp = "You have been drained! GAME OVER"

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

	src.blocked = 0
	return