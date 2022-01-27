

/obj/machinery/artillerycontrol
	var/reload = 120
	var/reload_cooldown = 120
	var/explosiondev = 3
	var/explosionmed = 6
	var/explosionlight = 12
	name = "bluespace artillery control"
	icon_state = "control_boxp1"
	icon = 'icons/obj/machines/particle_accelerator.dmi'
	density = TRUE

/obj/machinery/artillerycontrol/process(delta_time)
	if(reload < reload_cooldown)
		reload += delta_time

/obj/structure/artilleryplaceholder
	name = "artillery"
	icon = 'icons/obj/machines/artillery.dmi'
	anchored = TRUE
	density = TRUE

/obj/structure/artilleryplaceholder/decorative
	density = FALSE

/obj/machinery/artillerycontrol/ui_interact(mob/user)
	. = ..()
	var/dat = "<B>Bluespace Artillery Control:</B><BR>"
	dat += "Locked on<BR>"
	dat += "<B>Charge progress: [reload]/[reload_cooldown]:</B><BR>"
	dat += "<A href='byond://?src=[REF(src)];fire=1'>Open Fire</A><BR>"
	dat += "Deployment of weapon authorized by <br>Nanotrasen Naval Command<br><br>Remember, friendly fire is grounds for termination of your contract and life.<HR>"
	user << browse(dat, "window=scroll")
	onclose(user, "scroll")

/obj/machinery/artillerycontrol/Topic(href, href_list)
	if(..())
		return
	var/target_area = tgui_input_list(usr, "Area to bombard", "Open Fire", GLOB.teleportlocs)
	if(isnull(target_area))
		return
	if(isnull(GLOB.teleportlocs[target_area]))
		return
	var/area/thearea = GLOB.teleportlocs[target_area]
	if(usr.stat != CONSCIOUS || HAS_TRAIT(usr, TRAIT_HANDS_BLOCKED))
		return
	if(reload < reload_cooldown)
		return
	if(usr.contents.Find(src) || (in_range(src, usr) && isturf(loc)) || issilicon(usr))
		priority_announce("Bluespace artillery fire detected. Brace for impact.")
		message_admins("[ADMIN_LOOKUPFLW(usr)] has launched an artillery strike.")
		var/list/possible_turfs = list()
		for(var/turf/available_turf in get_area_turfs(thearea.type))
			possible_turfs += available_turf
		var/random_turf = pick(possible_turfs)
		explosion(random_turf, explosiondev, explosionmed, explosionlight, explosion_cause = src)
		reload = 0
