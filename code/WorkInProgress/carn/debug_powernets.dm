//Inefficient as hell so don't copypasta this anywhere! It's only here as a tool for debugging
//prints a map of the powernetworks on z-level 1
/client/verb/print_powernets()
	set name = "print powernets"

	var/file = file("powernets_map.html")

	var/list/grid[255][255]

	var/list/checklist = list()
	for(var/obj/structure/cable/C in world)
		if(C.z != 1)			continue
		if(C.x < 1 || C.x > 255)	continue
		if(C.y < 1 || C.y > 255)	continue
		grid[C.x][C.y] = C.netnum
		checklist |= C.netnum

	sleep(1)
	file << "<font size='1'><tt>"
	for(var/netnum in checklist)
		file << "[netnum]<br>"

	for(var/j=255, j>=1, j--)
		var/line = "<br>"
		for(var/i=1, i<=255, i++)
			switch(grid[i][j])
				if(null)	line += "&nbsp;"
				if(0 to 9)	line += "[grid[i][j]]"
				if(10)		line += "a"
				if(11)		line += "b"
				if(12)		line += "c"
				if(13)		line += "d"
				if(14)		line += "e"
				if(15)		line += "f"
				if(16)		line += "g"
				if(17)		line += "h"
				if(18)		line += "i"
				if(19)		line += "j"
				if(20)		line += "k"
				if(21)		line += "l"
				if(22)		line += "m"
				if(23)		line += "n"
				if(24)		line += "o"
				if(25)		line += "p"
				if(26)		line += "q"
				if(27)		line += "r"
				if(28)		line += "s"
				if(29)		line += "t"
				if(30)		line += "u"
				if(31)		line += "v"
				if(32)		line += "w"
				if(33)		line += "x"
				if(34)		line += "y"
				if(35)		line += "z"
				if(36)		line += "A"
				if(37)		line += "B"
				if(38)		line += "C"
				if(39)		line += "D"
				if(40)		line += "E"
				if(41)		line += "F"
				if(42)		line += "G"
				if(43)		line += "H"
				if(44)		line += "I"
				if(45)		line += "J"
				if(46)		line += "K"
				if(47)		line += "L"
				if(48)		line += "M"
				if(49)		line += "N"
				if(50)		line += "O"
				if(51)		line += "P"
				if(52)		line += "Q"
				if(53)		line += "R"
				if(54)		line += "S"
				if(55)		line += "T"
				if(56)		line += "U"
				if(57)		line += "V"
				if(58)		line += "W"
				if(59)		line += "X"
				if(60)		line += "Y"
				if(61)		line += "Z"
				else		line += "#"

		file << line
	file << "</tt></font>"
	src << "printed to powernets_map.html"
	src << browse(file)