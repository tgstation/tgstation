/mob/var/skincmds = list()
/obj/proc/SkinCmd(mob/user as mob, var/data as text)
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""])  \\/obj/proc/SkinCmd() called tick#: [world.time]")

/proc/SkinCmdRegister(var/mob/user, var/name as text, var/O as obj)
			user.skincmds[name] = O

/mob/verb/skincmd(data as text)
	set hidden = 1
	//writepanic("[__FILE__].[__LINE__] ([src.type])([usr ? usr.ckey : ""]) \\/mob/verb/skincmd()  called tick#: [world.time]")

	var/ref = copytext(data, 1, findtext(data, ";"))
	if (src.skincmds[ref] != null)
		var/obj/a = src.skincmds[ref]
		a.SkinCmd(src, copytext(data, findtext(data, ";") + 1))