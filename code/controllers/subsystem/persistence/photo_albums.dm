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
	photo_albums_database = new("data/photo_albums.json")
	for (var/obj/item/storage/photo_album/album as anything in queued_photo_albums)
		if (isnull(album.persistence_id))
			continue

		var/album_data = photo_albums_database.get_key(album.persistence_id)
		if (!isnull(album_data))
			album.populate_from_id_list(album_data)

	photo_frames_database = new("data/photo_frames.json")
	for (var/obj/structure/sign/picture_frame/frame as anything in queued_photo_frames)
		if (isnull(frame.persistence_id))
			continue

		var/frame_data = photo_frames_database.get_key(frame.persistence_id)
		if (!isnull(frame_data))
			frame.load_from_id(frame_data)

	queued_photo_albums = null
	queued_photo_frames = null
