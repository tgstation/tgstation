/*
n_Json v11.3.21
*/

proc
	json2list(json)
		var/static/json_reader/_jsonr = new()
		return _jsonr.ReadObject(_jsonr.ScanJson(json))

	list2json(list/L)
		var/static/json_writer/_jsonw = new()
		return _jsonw.WriteObject(L)
