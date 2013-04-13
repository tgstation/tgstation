/**********************Coin press computer**************************/
/obj/machinery/computer/mintcomp
	name = "Mint Computer"
	icon = 'icons/obj/computer.dmi'
	icon_state = "mintcomp"
	density = 1
	anchored = 1
	var/obj/machinery/mineral/mint/M

	// Locates the Mint
/obj/machinery/computer/mintcomp/New()
	..()
	spawn( 5 )
		for (var/dir in cardinal)
			M = locate(/obj/machinery/mineral/mint, get_step(src, dir))
			if(M) break
		return
	return

	// On use
obj/machinery/computer/mintcomp/attack_hand(var/mob/user as mob)
	if (!M) return
	var/dat = "<b>Coin Press</b><br>"

	if (!M.input)
		dat += text("input connection status: ")
		dat += text("<b><font color='red'>NOT CONNECTED</font></b><br>")
	if (!M.output)
		dat += text("<br>output connection status: ")
		dat += text("<b><font color='red'>NOT CONNECTED</font></b><br>")

	dat += text("<br><font color='#ffcc00'><b>Gold inserted: </b>[M.amt_gold]</font> ")
	if (M.chosen == "gold")
		dat += text("Chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=gold'>Choose</A>")
	dat += text("<br><font color='#888888'><b>Silver inserted: </b>[M.amt_silver]</font> ")
	if (M.chosen == "silver")
		dat += text("Chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=silver'>Choose</A>")
	dat += text("<br><font color='#555555'><b>Iron inserted: </b>[M.amt_iron]</font> ")
	if (M.chosen == "metal")
		dat += text("Chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=metal'>Choose</A>")
	dat += text("<br><font color='#8888FF'><b>Diamond inserted: </b>[M.amt_diamond]</font> ")
	if (M.chosen == "diamond")
		dat += text("Chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=diamond'>Choose</A>")
	dat += text("<br><font color='#FF8800'><b>Plasma inserted: </b>[M.amt_plasma]</font> ")
	if (M.chosen == "plasma")
		dat += text("Chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=plasma'>Choose</A>")
	dat += text("<br><font color='#008800'><b>Uranium inserted: </b>[M.amt_uranium]</font> ")
	if (M.chosen == "uranium")
		dat += text("Chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=uranium'>Choose</A>")
	if(M.amt_clown > 0)
		dat += text("<br><font color='#AAAA00'><b>Bananium inserted: </b>[M.amt_clown]</font> ")
		if (M.chosen == "clown")
			dat += text("Chosen")
		else
			dat += text("<A href='?src=\ref[src];choose=clown'>Choose</A>")
	dat += text("<br><font color='#888888'><b>Adamantine inserted: </b>[M.amt_adamantine]</font> ")//I don't even know these color codes, so fuck it.
	if (M.chosen == "adamantine")
		dat += text("Chosen")
	else
		dat += text("<A href='?src=\ref[src];choose=adamantine'>Choose</A>")

	dat += text("<br><br>Will produce [M.coinsToProduce] [M.chosen] coins if enough materials are available.<br>")
	//dat += text("The dial which controls the number of conins to produce seems to be stuck. A technician has already been dispatched to fix this.")
	dat += text("<A href='?src=\ref[src];chooseAmt=-10'>-10</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=-5'>-5</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=-1'>-1</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=1'>+1</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=5'>+5</A> ")
	dat += text("<A href='?src=\ref[src];chooseAmt=10'>+10</A> ")

	dat += text("<br><br>In total this machine produced <font color='green'><b>[M.newCoins]</b></font> coins.")
	dat += text("<br><A href='?src=\ref[src];makeCoins=[1]'>Make coins</A>")
	user << browse("[dat]", "window=mint")

/obj/machinery/computer/mintcomp/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if (!M) return
	M.Topic(href, href_list)
	..()
	src.updateUsrDialog()