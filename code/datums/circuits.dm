#define ALPHA 1
#define BETA 2
#define GAMMA 4
#define DELTA 8
#define ETA 16
#define THETA 32
#define IOTA 64
#define CHOOSE_FUSES 5 //Change this to affect how many fuses are needed to make a board.

/*
* A NOTE ON EDITING: We use 7 choose 5 to give 21 combinations. Be careful about expanding this. 9 choose 5 = 126 which would be insufferable to research through.
* You can increase the number of fuses needed by editing CHOOSE_FUSES. Increase the number of fuse options by adding fuse_point_names in the datum and newhash proc
* You can easily change the possible boards by adding, changing, or subtracting from the possible boards list, but if you go over the combination max (default 21), it will cause an infinite loop.
*/
/datum/circuits
	var/atom/holder = null //Which specific board are we pointing at?
	var/list/fuse_point_names = list("Alpha" = ALPHA, "Beta" = BETA, "Gamma" = GAMMA, "Delta" = DELTA, "Eta" = ETA, "Theta" = THETA, "Iota" = IOTA)
	var/list/possible_boards = list(/obj/item/weapon/circuitboard/autolathe,/obj/item/weapon/circuitboard/seed_extractor,/obj/item/weapon/circuitboard/conveyor,/obj/item/weapon/circuitboard/air_alarm,/obj/item/weapon/circuitboard/fire_alarm,/obj/item/weapon/circuitboard/airlock,/obj/item/weapon/circuitboard/power_control,/obj/item/weapon/circuitboard/vendomat,/obj/item/weapon/circuitboard/microwave)
	var/global/list/assigned_boards = list()
	//Each bitflag points to a board!
	var/localbit = 0 //What are WE programmed to? Always start as 0

	var/table_options = " align='center'"
	var/row_options1 = " width='80px'"
	var/row_options2 = " width='80px'"
	var/window_x = 240
	var/window_y = 300

/datum/circuits/New(var/atom/homeboard)
	..()
	holder = homeboard
	if(!(assigned_boards.len))
		generate_schema()

/datum/circuits/proc/generate_schema()
	for(var/C in possible_boards)
		var/newbit = newhash(CHOOSE_FUSES)
		while(!check_config(newbit))
			newbit = newhash(CHOOSE_FUSES)
		assigned_boards["[newbit]"] = C
	return

/datum/circuits/proc/check_config(var/proposed)
	for(var/bitflag in assigned_boards)
		if(text2num(proposed) == text2num(bitflag))
			return 0
	return 1

/datum/circuits/proc/newhash(var/choose) //Returns a bitflag
	var/list/fuse_point_list = list(ALPHA,BETA,GAMMA,DELTA,ETA,THETA,IOTA)
	var/build = 0
	var/choice = null
	while(choose>0)
		choice = pick_n_take(fuse_point_list)
		build |= choice
		choose--
	return build

//The greek being passed here is one of those previously mentioned defined variables. Each one is its own binary (e.g.: BETA = 2, GAMMA = 4)

/datum/circuits/proc/checkfuse(var/greek)
	return localbit & greek  //true if any bits in `localbit` and `greek` overlap, ie any are set in both
                             //this is because it returns the "intersection" (of the 2 sets), ie 1101 & 1010 returns 1000

/datum/circuits/proc/togglefuse(var/greek)
	localbit ^= greek //The ^= uses XOR and it basically toggles the given bits
                  //eg 1111 ^ 1000 = 0111
                  //eg 0000 ^ 1000 = 1000
	return

/datum/circuits/proc/Interact(var/mob/living/user)
	if(!istype(user))
		return 0
	var/html = null
	if(holder)
		html = GetInteractWindow()
	if(html)
		user.set_machine(holder)
	var/datum/browser/popup = new(user, "circuits", holder.name, window_x, window_y)
	popup.set_content(html)
	popup.set_title_image(user.browse_rsc_icon(holder.icon, holder.icon_state))
	popup.open()

/datum/circuits/proc/GetInteractWindow()
	var/html = "<div class='block'>"
	html += "<h3>Protoboard</h3>"
	html += "<table[table_options]>"

	for(var/fusepoint in fuse_point_names)
		html += {"<tr>
		<td[row_options1]><font color='blue'>[fusepoint]</font>
		</td>
		<td[row_options2]>
		<A href='?src=\ref[src];action=1;fuse=[fuse_point_names[fusepoint]]'>[checkfuse(text2num(fuse_point_names[fusepoint])) ? "Melt" :  "Fuse"]</A></td></tr>"}
	html += "</table>"
	html += "</div>"

	return html

/datum/circuits/Topic(href, href_list)
	if(..())
		return 1
	if(in_range(holder, usr) && isliving(usr))

		var/mob/living/L = usr
		if(href_list["action"])
			var/obj/item/I = L.get_active_hand()
			holder.add_hiddenprint(L)
			if(href_list["fuse"]) // Toggles the fuse/unfuse status
				if(issolder(I))
					var/obj/item/weapon/solder/S = I
					if(S.remove_fuel(1,L))
						playsound(L.loc, 'sound/items/Welder.ogg', 25, 1)
						var/greek = href_list["fuse"]
						togglefuse(text2num(greek))
				else
					to_chat(L, "<span class='error'>You need a soldering tool!</span>")

			Interact(usr) //Update

	if(href_list["close"])
		usr << browse(null, "window=wires")
		usr.unset_machine(holder)