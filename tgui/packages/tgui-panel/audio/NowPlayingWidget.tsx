/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useAtomValue } from 'jotai';
import { Button, Collapsible, Flex, Knob, Section } from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';
import { useSettings } from '../settings/use-settings';
import { metaAtom, playingAtom } from './atoms';
import { player } from './handlers';

export function NowPlayingWidget(props) {
  const { settings, updateSettings } = useSettings();
  const meta = useAtomValue(metaAtom);
  const { duration, link, title } = meta || {};
  // `||` and not destructuring defaults, the server sends null when yt-dlp has no value
  const album = meta?.album || 'Unknown Album';
  const artist = meta?.artist || 'Unknown Artist';
  const upload_date = meta?.upload_date || 'Unknown Date';

  const playing = useAtomValue(playingAtom);

  const date = !Number.isNaN(Number(upload_date))
    ? upload_date?.substring(0, 4) +
      '-' +
      upload_date?.substring(4, 6) +
      '-' +
      upload_date?.substring(6, 8)
    : upload_date;

  return (
    <Flex align="center">
      {playing ? (
        <Flex.Item
          mx={0.5}
          grow={1}
          style={{
            whiteSpace: 'nowrap',
            overflow: 'hidden',
            textOverflow: 'ellipsis',
          }}
        >
          {
            <Collapsible title={title || 'Unknown Track'} color="blue">
              <Section>
                {link !== 'Song Link Hidden' && (
                  <Flex.Item grow={1} color="label">
                    URL: <a href={link}>{link}</a>
                  </Flex.Item>
                )}
                <Flex.Item grow={1} color="label">
                  Duration: {duration}
                </Flex.Item>
                {artist !== 'Song Artist Hidden' &&
                  artist !== 'Unknown Artist' && (
                    <Flex.Item grow={1} color="label">
                      Artist: {artist}
                    </Flex.Item>
                  )}
                {album !== 'Song Album Hidden' && album !== 'Unknown Album' && (
                  <Flex.Item grow={1} color="label">
                    Album: {album}
                  </Flex.Item>
                )}
                {upload_date !== 'Song Upload Date Hidden' &&
                  upload_date !== 'Unknown Date' && (
                    <Flex.Item grow={1} color="label">
                      Uploaded: {date}
                    </Flex.Item>
                  )}
              </Section>
            </Collapsible>
          }
        </Flex.Item>
      ) : (
        <Flex.Item grow={1} color="label">
          Nothing to play.
        </Flex.Item>
      )}
      {playing && (
        <Flex.Item mx={0.5} fontSize="0.9em">
          <Button tooltip="Stop" icon="stop" onClick={() => player.stop()} />
        </Flex.Item>
      )}
      <Flex.Item mx={0.5} fontSize="0.9em">
        <Knob
          minValue={0}
          maxValue={1}
          value={settings.adminMusicVolume}
          step={0.0025}
          stepPixelSize={1}
          format={(value) => `${toFixed(value * 100)}%`}
          onChange={(e, value) => {
            updateSettings({
              adminMusicVolume: value,
            });
            player.setVolume(value);
          }}
        />
      </Flex.Item>
    </Flex>
  );
}
