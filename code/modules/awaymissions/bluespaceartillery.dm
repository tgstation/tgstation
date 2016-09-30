
#define ARTILLERY_RELOAD_TIME 60
#define EXPLOSION_SIZE 3

/obj/machinery/artillerycontrol
	var/reload = ARTILLERY_RELOAD_TIME
	var/explosionsize = EXPLOSION_SIZE
	name = "bluespace artillery control"
	icon_state = "control_boxp1"
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	density = 1
	anchored = 1

/obj/machinery/artillerycontrol/process()
	if(reload < ARTILLERY_RELOAD_TIME)
		reload++

/obj/structure/artilleryplaceholder
	name = "artillery"
	icon = 'icons/obj/machines/artillery.dmi'
	anchored = 1
	density = 1

/obj/structure/artilleryplaceholder/decorative
	density = 0

/obj/machinery/artillerycontrol/attack_hand(mob/user)
	user.set_machine(src)
	var/dat = "<B>Bluespace Artillery Control:</B><BR>"
	dat += "Locked on<BR>"
	dat += "<B>Charge progress: [reload]/[ARTILLERY_RELOAD_TIME]:</B><BR>"
	dat += "<A href='byond://?src=\ref[src];fire=1'>Open Fire</A><BR>"
	dat += "Deployment of weapon authorized by <br>Nanotrasen Naval Command<br><br>Remember, friendly fire is grounds for termination of your contract and life.<HR>"
	user << browse(dat, "window=scroll")
	onclose(user, "scroll")
	return

/obj/machinery/artillerycontrol/Topic(href, href_list)
	if(..())
		return
	var/A
	A = input("Area to bombard", "Open Fire", A) in teleportlocs
	var/area/thearea = teleportlocs[A]
	if(usr.stat || usr.restrained())
		return
	if(src.reload < ARTILLERY_RELOAD_TIME)
		return
	if(usr.contents.Find(src) || (in_range(src, usr) && isturf(loc)) || issilicon(usr))
		priority_announce("Bluespace artillery fire detected. Brace for impact.")
		message_admins("[key_name_admin(usr)] has launched an artillery strike.")
		var/list/L = list()
		for(var/turf/T in get_area_turfs(thearea.type))
			L+=T
		var/loc = pick(L)
		explosion(loc,explosionsize,explosionsize*2,explosionsize*4)
		reload = 0

/*/mob/proc/openfire()
	var/A
	A = input("Area to jump bombard", "Open Fire", A) in teleportlocs
	var/area/thearea = teleportlocs[A]
	priority_announce("Bluespace artillery fire detected. Brace for impact.")
	spawn(30)
	var/list/L = list()

	for(var/turf/T in get_area_turfs(thearea.type))
		L+=T
	var/loc = pick(L)
	explosion(loc,2,5,11)*/
