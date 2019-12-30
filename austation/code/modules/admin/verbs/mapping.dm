/client/proc/export_map()
	set category = "Mapping"
	set name = "Export Map"

	var/z_level = input("Export Which Z-Level?", "Map Exporter", 2) as num
	var/start_x = input("Start X?", "Map Exporter", 1) as num
	var/start_y = input("Start Y?", "Map Exporter", 1) as num
	var/end_x = input("End X?", "Map Exporter", world.maxx-1) as num
	var/end_y = input("End Y?", "Map Exporter", world.maxy-1) as num
	var/date = time2text(world.timeofday, "YYYY-MM-DD_hh-mm-ss")
	var/file_name = input("Filename?", "Map Exporter", "exportedmap_[date]") as text
	var/confirm = alert("Are you sure you want to do this? This will cause extreme lag!", "Map Exporter", "Yes", "No")

	if(confirm != "Yes")
		return

	var map_text = write_map(start_x, start_y, z_level, end_x, end_y, z_level, 24)
	text2file(map_text, "data/[file_name].dmm")
	usr << ftp("data/[file_name].dmm", "[file_name].dmm")
