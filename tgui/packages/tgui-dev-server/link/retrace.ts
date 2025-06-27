import path from 'node:path';

import { SourceMapConsumer } from 'source-map';
import { parse as parseStackTrace } from 'stacktrace-parser';

import { createLogger } from '../logging';
import { resolveGlob } from '../util';

type SourceMap = {
  file: string;
  consumer: SourceMapConsumer;
};

const logger = createLogger('retrace');

const sourceMaps: SourceMap[] = [];

export async function loadSourceMaps(bundleDir: string): Promise<void> {
  // Destroy and garbage collect consumers
  while (sourceMaps.length !== 0) {
    const map = sourceMaps.shift();
    if (!map?.consumer) continue;
    map.consumer.destroy();
  }

  // Load new sourcemaps
  const files = await resolveGlob(bundleDir, '*.map');
  for (let file of files) {
    try {
      const loc = path.resolve(bundleDir, file);
      const parsed = await Bun.file(loc).json();
      const consumer = await new SourceMapConsumer(parsed);

      sourceMaps.push({ file, consumer });
    } catch (err) {
      logger.error(err);
    }
  }

  logger.log(`loaded ${sourceMaps.length} source maps`);
}

export function retrace(stack: string): string | undefined {
  if (typeof stack !== 'string') {
    logger.log('ERROR: Stack is not a string!', stack);
    return stack;
  }
  const header = stack.split(/\n\s.*at/)[0];
  const mappedStack = parseStackTrace(stack)
    .map((frame) => {
      if (!frame.file) {
        return frame;
      }
      // Find the correct source map
      const sourceMap = sourceMaps.find((sourceMap) => {
        return frame.file!.includes(sourceMap.file);
      });
      if (!sourceMap) {
        return frame;
      }
      // Map the frame
      const { consumer } = sourceMap;
      const mappedFrame = consumer.originalPositionFor({
        line: frame.lineNumber || 0,
        column: frame.column || 0,
      });
      return {
        ...frame,
        file: mappedFrame.source,
        lineNumber: mappedFrame.line,
        column: mappedFrame.column,
      };
    })
    .map((frame) => {
      // Stringify the frame
      const { file, methodName, lineNumber } = frame;
      if (!file) {
        return `  at ${methodName}`;
      }
      const compactPath = file
        .replace(/^rspack:\/\/\/?/, './')
        .replace(/.*node_modules\//, '');
      return `  at ${methodName} (${compactPath}:${lineNumber})`;
    })
    .join('\n');

  return header + '\n' + mappedStack;
}
