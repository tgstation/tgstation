///Loads up the photo album source file.
/datum/controller/subsystem/persistence/proc/get_photo_albums()
	var/album_path = file("data/photo_albums.json")
	if(fexists(album_path))
		return json_decode(file2text(album_path))

///Loads up the photo frames source file.
/datum/controller/subsystem/persistence/proc/get_photo_frames()
	var/frame_path = file("data/photo_frames.json")
	if(fexists(frame_path))
		return json_decode(file2text(frame_path))

/// Removes the identifier of a persistent photo frame from the json.
/datum/controller/subsystem/persistence/proc/remove_photo_frames(identifier)
	var/frame_path = file("data/photo_frames.json")
	if(!fexists(frame_path))
		return

	var/frame_json = json_decode(file2text(frame_path))
	frame_json -= identifier

	frame_json = json_encode(frame_json)
	fdel(frame_path)
	WRITE_FILE(frame_path, frame_json)

///Loads photo albums, and populates them; also loads and applies frames to picture frames.
/datum/controller/subsystem/persistence/proc/load_photo_persistence()
	var/album_path = file("data/photo_albums.json")
	var/frame_path = file("data/photo_frames.json")
	if(fexists(album_path))
		var/list/json = json_decode(file2text(album_path))
		if(json.len)
			for(var/i in photo_albums)
				var/obj/item/storage/photo_album/A = i
				if(!A.persistence_id)
					continue
				if(json[A.persistence_id])
					A.populate_from_id_list(json[A.persistence_id])

	if(fexists(frame_path))
		var/list/json = json_decode(file2text(frame_path))
		if(json.len)
			for(var/i in photo_frames)
				var/obj/structure/sign/picture_frame/PF = i
				if(!PF.persistence_id)
					continue
				if(json[PF.persistence_id])
					PF.load_from_id(json[PF.persistence_id])

///Saves the contents of photo albums and the picture frames.
/datum/controller/subsystem/persistence/proc/save_photo_persistence()
	var/album_path = file("data/photo_albums.json")
	var/frame_path = file("data/photo_frames.json")

	var/list/frame_json = list()
	var/list/album_json = list()

	if(fexists(album_path))
		album_json = json_decode(file2text(album_path))
		fdel(album_path)

	for(var/i in photo_albums)
		var/obj/item/storage/photo_album/A = i
		if(!istype(A) || !A.persistence_id)
			continue
		var/list/L = A.get_picture_id_list()
		album_json[A.persistence_id] = L

	album_json = json_encode(album_json)

	WRITE_FILE(album_path, album_json)

	if(fexists(frame_path))
		frame_json = json_decode(file2text(frame_path))
		fdel(frame_path)

	for(var/i in photo_frames)
		var/obj/structure/sign/picture_frame/F = i
		if(!istype(F) || !F.persistence_id)
			continue
		frame_json[F.persistence_id] = F.get_photo_id()

	frame_json = json_encode(frame_json)

	WRITE_FILE(frame_path, frame_json)

