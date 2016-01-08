import * as p from '../paths'

import del from 'del'
module.exports = function () {
  return del(`${p.out}/*`)
}
module.exports.displayName = 'clean'
