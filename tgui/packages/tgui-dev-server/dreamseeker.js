/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import axios from 'axios';
import { exec } from 'child_process';
import { createLogger } from 'common/logging.js';
import { promisify } from 'util';

const logger = createLogger('dreamseeker');

const instanceByPid = new Map();

export class DreamSeeker {
  constructor(pid, addr) {
    this.pid = pid;
    this.addr = addr;
    this.client = axios.create({
      baseURL: `http://${addr}/`,
    });
  }

  topic(params = {}) {
    const query = Object.keys(params)
      .map(key => encodeURIComponent(key)
        + '=' + encodeURIComponent(params[key]))
      .join('&');
    return this.client.get('/dummy?' + query);
  }
}

/**
 * @param {number[]} pids
 * @returns {DreamSeeker[]}
 */
DreamSeeker.getInstancesByPids = async pids => {
  if (process.platform !== 'win32') {
    return [];
  }
  const instances = [];
  const pidsToResolve = [];
  for (let pid of pids) {
    const instance = instanceByPid.get(pid);
    if (instance) {
      instances.push(instance);
    }
    else {
      pidsToResolve.push(pid);
    }
  }
  if (pidsToResolve.length > 0) {
    try {
      const command = 'netstat -a -n -o';
      const { stdout } = await promisify(exec)(command);
      // Line format:
      // proto addr mask mode pid
      const entries = stdout
        .split('\r\n')
        .filter(line => line.includes('LISTENING'))
        .map(line => {
          const words = line.match(/\S+/g);
          return {
            addr: words[1],
            pid: parseInt(words[4], 10),
          };
        })
        .filter(entry => pidsToResolve.includes(entry.pid));
      const len = entries.length;
      logger.log('found', len, plural('instance', len));
      for (let entry of entries) {
        const { pid, addr } = entry;
        const instance = new DreamSeeker(pid, addr);
        instances.push(instance);
        instanceByPid.set(pid, instance);
      }
    }
    catch (err) {
      logger.error(err);
      return [];
    }
  }
  return instances;
};

const plural = (word, n) => n !== 1 ? word + 's' : word;
