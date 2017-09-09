/mob/var/skincmds = list()
/obj/proc/SkinCmd(mob/user as mob, var/data as text)

/proc/SkinCmdRegister(mob/user, name as text, obj/O)
			user.skincmds[name] = O

/mob/verb/skincmd(data as text)
	set hidden = 1

	var/ref = copytext(data, 1, findtext(data, ";"))
	if (skincmds[ref] != null)
		var/obj/a = skincmds[ref]
		a.SkinCmd(src, copytext(data, findtext(data, ";") + 1))