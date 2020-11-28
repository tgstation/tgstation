/proc/vox_name()
	var/sounds = rand(2, 8)
	var/i = 0
	var/newname = ""

	while(i <= sounds)
		i++
		newname += pick(list("ti","hi","ki","ya","ta","ha","ka","ya","chi","cha","kah","ri","ra"))
	return newname
