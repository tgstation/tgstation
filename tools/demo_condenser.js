'use strict';
const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

let once = process.argv.includes("--once");

let condense_dir = "../data/replays";

function condense(dir = condense_dir) {
	fs.readdir(dir, (err, files) => {
		if(err) {console.error(err); return;}
		for(let file of files) {
			let full = path.join(dir, file);
			fs.stat(full, (err, stat) => {
				if(err) {console.error(err); return;}
				if(stat.isDirectory()) {
					condense(full);
				} else {
					condense_file(full);
				}
			});
		}
	});
}

function condense_file(filename) {
	console.log("Compressing " + filename + "...");
	let reader = fs.createReadStream(filename);
	let writer = fs.createWriteStream(filename + ".gz");
	let gzip = zlib.createGzip();
	reader.pipe(gzip).pipe(writer).on('finish', (err) => {
		if(err) {console.error(err); return;}
		console.log("Compressed " + filename + "!");
		// Delete it
		fs.unlink(filename, (err) => {
			if(err) {
				console.error(filename + " failed to delete (round probably not done)");
			} else {
				console.error("Deleted uncompressed demo at " + filename);
			}
		});
	});
}

condense();
if(!once) {
	setInterval(condense, 60 * 60 * 1000); // condense every hour.
}
