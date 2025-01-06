/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

import { useDispatch, useSelector } from 'tgui/backend';
import { Button, Collapsible, Flex, Knob, Section } from 'tgui-core/components';
import { toFixed } from 'tgui-core/math';

import { useSettings } from '../settings';
import { selectAudio } from './selectors';

export const NowPlayingWidget = (props) => {
  const audio = useSelector(selectAudio),
    dispatch = useDispatch(),
    settings = useSettings(),
    title = audio.meta?.title,
    URL = audio.meta?.link,
    Artist = audio.meta?.artist || 'Unknown Artist',
    upload_date = audio.meta?.upload_date || 'Unknown Date',
    album = audio.meta?.album || 'Unknown Album',
    duration = audio.meta?.duration,
    date = !isNaN(upload_date)
      ? upload_date?.substring(0, 4) +
        '-' +
        upload_date?.substring(4, 6) +
        '-' +
        upload_date?.substring(6, 8)
      : upload_date;

  return (
    <Flex align="center">
      {(audio.playing && (
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
            <Collapsible title={title || 'Unknown Track'} color={'blue'}>
              <Section>
                {URL !== 'Song Link Hidden' && (
                  <Flex.Item grow={1} color="label">
                    URL: {URL}
                  </Flex.Item>
                )}
                <Flex.Item grow={1} color="label">
                  Duration: {duration}
                </Flex.Item>
                {Artist !== 'Song Artist Hidden' &&
                  Artist !== 'Unknown Artist' && (
                    <Flex.Item grow={1} color="label">
                      Artist: {Artist}
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
      )) || (
        <Flex.Item grow={1} color="label">
          Nothing to play.
        </Flex.Item>
      )}
      {audio.playing && (
        <Flex.Item mx={0.5} fontSize="0.9em">
          <Button
            tooltip="Stop"
            icon="stop"
            onClick={() =>
              dispatch({
                type: 'audio/stopMusic',
              })
            }
          />
        </Flex.Item>
      )}
      <Flex.Item mx={0.5} fontSize="0.9em">
        <Knob
          minValue={0}
          maxValue={1}
          value={settings.adminMusicVolume}
          step={0.0025}
          stepPixelSize={1}
          format={(value) => toFixed(value * 100) + '%'}
          onDrag={(e, value) =>
            settings.update({
              adminMusicVolume: value,
            })
          }
        />
      </Flex.Item>
    </Flex>
  );
};
