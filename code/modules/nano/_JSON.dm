/*
n_Json v11.3.21
*/

proc
	json2list(json)
		var/static/json_reader/_jsonr = new()
		return _jsonr.ReadObject(_jsonr.ScanJson(json))

	list2json(list/L)
		var/static/json_writer/_jsonw = new()
		// Detect if it's just a list of things, or an associative list
		// (Used to just assume associative, which broke things.)
		if(_jsonw.is_associative(L))
			return _jsonw.WriteObject(L)
		else
			return _jsonw.write_array(L)
