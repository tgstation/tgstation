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

const FILENAME = process.argv[2]

if (!FILENAME) {
	console.error("No filename specified")
	process.exit(1)
}

async function main() {
	console.log(`Reading from ${FILENAME}`)
	const file = await (await fs.readFile(FILENAME, "utf8")).split("\n")

	console.log(`Logging in as ${USERNAME}`)

	const bot = new MWBot()

	await bot.loginGetEditToken({
		apiUrl: "https://tgstation13.org/wiki/api.php",
		username: USERNAME,
		password: PASSWORD,
	})

	console.log("Logged in")

	// This is not Promise.all as to not flood with a bunch of traffic at once
	for (const line of file) {
		if (line.length === 0) {
			continue
		}

		let { title, text } = JSON.parse(line)
		text = "<noinclude><b>This page is automated by Autowiki. Do NOT edit it manually.</b></noinclude>" + text

		console.log(`Editing ${title}...`)
		await bot.edit(
			title,
			text,
			`Autowiki edit @ ${ new Date().toISOString() }`,
		)
	}
}

main().catch(console.error)
