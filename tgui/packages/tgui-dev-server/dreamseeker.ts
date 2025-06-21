/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { exec } from 'node:child_process';
import { promisify } from 'node:util';

import axios, { AxiosInstance, AxiosResponse } from 'axios';

import { createLogger } from './logging';

type Entry = {
  addr: string;
  pid: number;
};

const logger = createLogger('dreamseeker');

const instanceByPid = new Map();

export class DreamSeeker {
  public pid: number;
  public addr: string;
  public client: AxiosInstance;

  constructor(pid: number, addr: string) {
    this.pid = pid;
    this.addr = addr;
    this.client = axios.create({
      baseURL: `http://${addr}`,
    });
  }

  topic(params: Record<string, any> = {}): Promise<AxiosResponse> {
    const query = Object.keys(params)
      .map(
        (key) =>
          encodeURIComponent(key) + '=' + encodeURIComponent(params[key]),
      )
      .join('&');
    logger.log(
      `topic call at ${this.client.defaults.baseURL}/dummy.htm?${query}`,
    );
    return this.client.get('/dummy.htm?' + query);
  }

  static async getInstancesByPids(pids: number[]): Promise<DreamSeeker[]> {
    const instances: DreamSeeker[] = [];
    const pidsToResolve: number[] = [];

    for (let pid of pids) {
      const instance = instanceByPid.get(pid);
      if (instance) {
        instances.push(instance);
      } else {
        pidsToResolve.push(pid);
      }
    }

    if (pidsToResolve.length === 0) {
      return instances;
    }

    const command = 'netstat -ano | findstr TCP | findstr 0.0.0.0:0';

    try {
      const { stdout } = await promisify(exec)(command, {
        // Max buffer of 1MB (default is 200KB)
        maxBuffer: 1024 * 1024,
      });

      // Line format:
      // proto addr mask mode pid
      const entries: Entry[] = [];
      const lines = stdout.split('\r\n');

      for (let line of lines) {
        const words = line.match(/\S+/g);
        if (!words || words.length === 0) {
          continue;
        }
        const entry: Entry = {
          addr: words[1],
          pid: parseInt(words[4], 10),
        };
        if (pidsToResolve.includes(entry.pid)) {
          entries.push(entry);
        }
      }

      const len = entries.length;
      logger.log('found', len, plural('instance', len));
      for (let entry of entries) {
        const { pid, addr } = entry;
        const instance = new DreamSeeker(pid, addr);
        instances.push(instance);
        instanceByPid.set(pid, instance);
      }
    } catch (err) {
      if (err.code === 'ERR_CHILD_PROCESS_STDIO_MAXBUFFER') {
        logger.error(err.message, err.code);
      } else {
        logger.error(err);
      }
      return [];
    }
    return instances;
  }
}

function plural(word: string, n: number): string {
  return n !== 1 ? word + 's' : word;
}
