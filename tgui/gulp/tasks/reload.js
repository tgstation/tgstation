import child_process from 'child_process'
module.exports = function () {
  child_process.exec('reload.bat', (err, stdout, stderr) => {
    if (err) console.log(err)
  })
}
module.exports.displayName = 'reload'
