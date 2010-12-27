/mob/living/silicon/aihologram/examine()
	set src in oview()
	usr << "\blue *---------*"
	usr << text("\blue This is \icon[] <B>[]</B>!", src, src.name)
	return