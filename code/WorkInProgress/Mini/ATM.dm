/*

TODO:
give money an actual use (QM stuff, vending machines)
send money to people (might be worth attaching money to custom database thing for this, instead of being in the ID)
log transactions

*/

/obj/item/weapon/card/id/var/money = 2000

/obj/machinery/atm
	name = "NanoTrasen Automatic Teller Machine"
	desc = "For all your monetary needs!"
	icon = 'terminals.dmi'
	icon_state = "atm"
	use_power = 1
	idle_power_usage = 10

/obj/machinery/atm/attackby(obj/item/I as obj, mob/user as mob)
	if(ishuman(user))
		var/obj/item/weapon/card/id/user_id = src.scan_user(user)
		if(istype(I,/obj/item/weapon/spacecash))
			user_id.money += I:worth
			del I

/obj/machinery/atm/attack_hand(mob/user as mob)
	var/obj/item/weapon/card/id/user_id = src.scan_user(user)
	if(..())
		return
	var/dat = ""
	dat += "<h1>NanoTrasen Automatic Teller Machine</h1><br/>"
	dat += "For all your monetary needs!<br/><br/>"
	dat += "Welcome, [user_id.registered_name].<br/>"
	dat += "You have $[user_id.money] in your account.<br/>"
	dat += "<a href=\"?src=\ref[src]&withdraw=1&id=\ref[user_id]\">Withdraw</a><br/>"
	user << browse(dat,"window=atm")

/obj/machinery/atm/Topic(var/href, var/href_list)
	if(href_list["withdraw"] && href_list["id"])
		var/amount = input("How much would you like to withdraw?", "Amount", 0) in list(1,10,20,50,100,200,500,1000, 0)
		var/obj/item/weapon/card/id/user_id = locate(href_list["id"])
		if(amount != 0 && user_id)
			if(amount <= user_id.money)
				user_id.money -= amount
				//hueg switch for giving moneh out
				switch(amount)
					if(1)
						new /obj/item/weapon/spacecash(loc)
					if(10)
						new /obj/item/weapon/spacecash/c10(loc)
					if(20)
						new /obj/item/weapon/spacecash/c20(loc)
					if(50)
						new /obj/item/weapon/spacecash/c50(loc)
					if(100)
						new /obj/item/weapon/spacecash/c100(loc)
					if(200)
						new /obj/item/weapon/spacecash/c200(loc)
					if(500)
						new /obj/item/weapon/spacecash/c500(loc)
					if(1000)
						new /obj/item/weapon/spacecash/c1000(loc)
			else
				usr << browse("You don't have that much money!<br/><a href=\"?src=\ref[src]\">Back</a>","window=atm")
				return
	src.attack_hand(usr)

//stolen wholesale and then edited a bit from newscasters, which are awesome and by Agouri
/obj/machinery/atm/proc/scan_user(mob/living/carbon/human/human_user as mob)
	if(human_user.wear_id)
		if(istype(human_user.wear_id, /obj/item/device/pda) )
			var/obj/item/device/pda/P = human_user.wear_id
			if(P.id)
				return P.id
			else
				return null
		else if(istype(human_user.wear_id, /obj/item/weapon/card/id) )
			return human_user.wear_id
		else
			return null
	else
		return null
