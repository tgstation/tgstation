const fs = require("fs").promises
const MWBot = require("mwbot")

const { USERNAME, PASSWORD } = process.env

if (!USERNAME) {
	console.error("USERNAME was not set.")
	process.exit(1)
}

if (!PASSWORD) {
	console.error("PASSWORD was not set.")
	process.exit(1)
}

const PAGE_EDIT_FILENAME = process.argv[2]

if (!PAGE_EDIT_FILENAME) {
	console.error("No filename specified to edit pages")
	process.exit(1)
}

const FILE_EDIT_FILENAME = process.argv[3]

if (!FILE_EDIT_FILENAME) {
	console.error("No filename specified to edit files")
	process.exit(1)
}

async function main() {
	console.log(`Reading from ${PAGE_EDIT_FILENAME}`)
	const editFile = await (await fs.readFile(PAGE_EDIT_FILENAME, "utf8")).split("\n")

	console.log(`Logging in as ${USERNAME}`)

	const bot = new MWBot()

	await bot.loginGetEditToken({
		apiUrl: "https://tgstation13.org/wiki/api.php",
		username: USERNAME,
		password: PASSWORD,
	})

	console.log("Logged in")

	// This is not Promise.all as to not flood with a bunch of traffic at once
	for (const editLine of editFile) {
		if (editLine.length === 0) {
			continue
		}

		let { title, text } = JSON.parse(editLine)
		text = "<noinclude><b>This page is automated by Autowiki. Do NOT edit it manually.</b></noinclude>" + text

		console.log(`Editing ${title}...`)
		await bot.edit(
			title,
			text,
			`Autowiki edit @ ${ new Date().toISOString() }`,
		)
	}

	// Same here
	for (const asset of await fs.readdir(FILE_EDIT_FILENAME)) {
		const assetPath = `${FILE_EDIT_FILENAME}/${asset}`
		const assetName = `Autowiki-${asset}`

		console.log(`Replacing ${assetName}...`)
		await bot.upload(
			assetName,
			assetPath,
			`Autowiki upload @ ${ new Date().toISOString() }`,
		).catch(error => {
			if (error.code === "fileexists-no-change") {
				console.log(`${assetName} is an exact duplicate`)
			} else {
				return Promise.reject(error)
			}
		})
	}
}

main().catch(console.error)
