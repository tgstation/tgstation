#define ARENA_RED_TEAM "red"
#define ARENA_GREEN_TEAM "green"
#define ARENA_DEFAULT_ID "arena_default"

/area/prophunt
	name = "PropHunt"
	icon_state = "Prophunt"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	flags_1 = 0
	hidden = TRUE

/area/prophunt/mg2
	name = "\improper PropHunt Area"

/area/prophunt/mg2/offline
	name = "PropHunt - Offline"

/area/prophunt/mg2/alpha
	name = "PropHunt - Maintanence"

/area/prophunt/mg2/bravo
	name = "PropHunt - Crused Meta Showroom"

/area/prophunt/mg2/charlie
	name = "PropHunt - AI Sat I"

/area/prophunt/mg2/delta
	name = "PropHunt - Bridge/Port Primary"

/area/prophunt/mg2/echo
	name = "PropHunt - Engineering/Atmos Aux"

/area/prophunt/mg2/foxtrot
	name = "PropHunt - Delta Brig"

/area/prophunt/mg2/golf
	name = "PropHunt - Pubby Brig"

/area/prophunt/mg2/hotel
	name = "PropHunt - Cursed Pubby Dorms"

/area/prophunt/mg2/india
	name = "PropHunt - Cargo Mashup"

/area/prophunt/mg2/juliett
	name = "PropHunt - Medbay Mishap"

/area/prophunt/mg2/kilo
	name = "PropHunt - ???"
/** Kilo doesn't even real **/

/area/prophunt/mg2/ligma
	name = "PropHunt - AI Sat II"

/area/prophunt/mg2/mike
	name = "PropHunt - Dereliction"

/area/prophunt/mg2/november
	name = "PropHunt - Into The Engine"

/obj/machinery/computer/prophunt_signup/
	maptext = "Prophunt signup"
	maptext_y = 32
	var/list/signed_up = list()
	var/autostart = FALSE // does not autostart
	var/obj/machinery/computer/arena/linked_machine
	var/autostart_timer
	var/obj/machinery/arena_spawn/green_spawn
	var/obj/machinery/arena_spawn/red_spawn

/obj/machinery/computer/prophunt_signup/Initialize(mapload, obj/item/circuitboard/C)
	. = ..()
	for(var/obj/machinery/computer/arena/A in GLOB.machines)
		linked_machine = A
	

/obj/machinery/computer/prophunt_signup/vv_edit_var(vname, vval)
	. = ..()
	switch(vname)
		if("autostart")
			toggle_autostart()

/obj/machinery/computer/prophunt_signup/attack_hand(mob/user)
	var/selection = input("Signup for prophunt?", "Signup", null, null) as null|anything in list("Yes","No")
	if(selection != "Yes")
		return
	if(user in signed_up)
		to_chat(user, "You're already signed up!")
		return
	signed_up += user

/obj/machinery/computer/prophunt_signup/proc/toggle_autostart()
	if(autostart)
		autostart_timer = addtimer(CALLBACK(src, .proc/try_starting), 1 MINUTES, TIMER_STOPPABLE)
	else
		if(autostart_timer)
			deltimer(autostart_timer)

/obj/machinery/computer/prophunt_signup/proc/try_starting()
	if(linked_machine && signed_up)
		manage_arena() // proc can be used to prepare the arena, can add more.
		for(var/obj/machinery/arena_spawn/S in GLOB.machines)
			if(S.color == "red")
				red_spawn = S
			if(S.color == "green")
				green_spawn = S
		var/i = 0
		var/mob/hunter = signed_up[1]
		linked_machine.add_team_member(hunter,ARENA_GREEN_TEAM,hunter.key)
		linked_machine.spawn_member(green_spawn,hunter.ckey,ARENA_GREEN_TEAM)
		pop(signed_up)
		while(i > 5 && signed_up) // gets 4 people, pops them from the list and adds them to the team
			var/mob/M = signed_up[1]
			if(!M.key)
				pop(signed_up)
				continue
			linked_machine.add_team_member(M,ARENA_RED_TEAM,M.key)
			linked_machine.spawn_member(red_spawn,M.ckey,ARENA_RED_TEAM)
			pop(signed_up)
			i++
		linked_machine.set_doors(closed = TRUE) // We need to lock up the hunter so he can't get out
		var/list/contestants = linked_machine.all_contestants()
		for(var/mob/contestant in contestants)
			to_chat(contestant,"<span class='userdanger'>Hiders are red team, seekers are green team. Hiders have 30 seconds to hide! Start now!</span>")
			new /obj/item/chameleon(contestant.loc)
		var/hiding_timer = addtimer(CALLBACK(linked_machine, /obj/machinery/computer/arena.proc/set_doors), 30 SECONDS, TIMER_STOPPABLE)
		autostart_timer = addtimer(CALLBACK(src, .proc/end_game), 2 MINUTES, TIMER_STOPPABLE)
	else
		deltimer(autostart_timer)
		autostart_timer = addtimer(CALLBACK(src, .proc/try_starting), 1 MINUTES, TIMER_STOPPABLE)
/obj/machinery/computer/prophunt_signup/proc/end_game()
	linked_machine.trophy_for_last_man_standing()
	sleep(5 SECONDS)
	linked_machine.reset_arena()
	deltimer(autostart_timer)
	autostart_timer = addtimer(CALLBACK(src, .proc/try_starting), 1 MINUTES, TIMER_STOPPABLE)

/obj/machinery/computer/prophunt_signup/proc/manage_arena()
	linked_machine.load_random_arena()


#undef ARENA_GREEN_TEAM
#undef ARENA_RED_TEAM
#undef ARENA_DEFAULT_ID