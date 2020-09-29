/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { createLogger } from 'common/logging.js';
import fs from 'fs';
import { basename } from 'path';
import SourceMap from 'source-map';
import { parse as parseStackTrace } from 'stacktrace-parser';
import { resolveGlob } from '../util.js';

const logger = createLogger('retrace');

const { SourceMapConsumer } = SourceMap;
const sourceMaps = [];

export const loadSourceMaps = async bundleDir => {
  // Destroy and garbage collect consumers
  while (sourceMaps.length !== 0) {
    const { consumer } = sourceMaps.shift();
    consumer.destroy();
  }
  // Load new sourcemaps
  const paths = await resolveGlob(bundleDir, '*.map');
  for (let path of paths) {
    try {
      const file = basename(path).replace('.map', '');
      const consumer = await new SourceMapConsumer(
        JSON.parse(fs.readFileSync(path, 'utf8')));
      sourceMaps.push({ file, consumer });
    }
    catch (err) {
      logger.error(err);
    }
  }
  logger.log(`loaded ${sourceMaps.length} source maps`);
};

export const retrace = stack => {
  if (typeof stack !== 'string') {
    logger.log('ERROR: Stack is not a string!', stack);
    return stack;
  }
  const header = stack.split(/\n\s.*at/)[0];
  const mappedStack = parseStackTrace(stack)
    .map(frame => {
      if (!frame.file) {
        return frame;
      }
      // Find the correct source map
      const sourceMap = sourceMaps.find(sourceMap => {
        return frame.file.includes(sourceMap.file);
      });
      if (!sourceMap) {
        return frame;
      }
      // Map the frame
      const { consumer } = sourceMap;
      const mappedFrame = consumer.originalPositionFor({
        source: basename(frame.file),
        line: frame.lineNumber,
        column: frame.column,
      });
      return {
        ...frame,
        file: mappedFrame.source,
        lineNumber: mappedFrame.line,
        column: mappedFrame.column,
      };
    })
    .map(frame => {
      // Stringify the frame
      const { file, methodName, lineNumber } = frame;
      if (!file) {
        return `  at ${methodName}`;
      }
      const compactPath = file
        .replace(/^webpack:\/\/\/?/, './')
        .replace(/.*node_modules\//, '');
      return `  at ${methodName} (${compactPath}:${lineNumber})`;
    })
    .join('\n');
  return header + '\n' + mappedStack;
};
