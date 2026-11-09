import {
  Box,
  Button,
  LabeledList,
  NoticeBox,
  Section,
} from 'tgui-core/components';
import type { BooleanLike } from 'tgui-core/react';

import { useBackend } from '../backend';
import { Window } from '../layouts';

type Data = {
  connected: BooleanLike;
  notice: string;
  unlocked: BooleanLike;
  visualizing: BooleanLike;
  target: string;
};

export const BluespaceArtillery = (props) => {
  const { act, data } = useBackend<Data>();
  const { connected, notice, unlocked, visualizing, target } = data;

  return (
    <Window width={400} height={220}>
      <Window.Content>
        {!!notice && <NoticeBox>{notice}</NoticeBox>}
        {connected ? (
          <>
            <Section
              title="Target"
              buttons={
                <Button
                  icon="crosshairs"
                  disabled={!unlocked}
                  onClick={() => act('recalibrate')}
                />
              }
            >
              <Box color={target ? 'average' : 'bad'} fontSize="25px">
                {target || 'No Target Set'}
              </Box>
            </Section>
            <Section>
              {unlocked ? (
                <Box style={{ margin: 'auto' }}>
                  <Button
                    fluid
                    content="FIRE"
                    color="bad"
                    disabled={!target}
                    fontSize="30px"
                    textAlign="center"
                    lineHeight="46px"
                    onClick={() => act('fire')}
                  />
                </Box>
              ) : (
                <>
                  <Box color="bad" fontSize="18px">
                    Bluespace artillery is currently locked.
                  </Box>
                  <Box mt={1}>
                    Awaiting authorization via keycard reader from at minimum
                    two station heads.
                  </Box>
                </>
              )}
            </Section>
          </>
        ) : (
          <Section>
            <LabeledList>
              <LabeledList.Item label="Maintenance">
                {(visualizing) ? (
                  <>
                    <Button color="good" onClick={() => act('build')}>
                      Confirm Position
                    </Button>
                    <Button color="bad" onClick={() => act('unvisualize')}>
                      Cancel
                    </Button>
                  </>
                ) : (
                  <Button icon="wrench" onClick={() => act('visualize')}>
                    Begin Deployment
                  </Button>
                )}
              </LabeledList.Item>
            </LabeledList>
          </Section>
        )}
      </Window.Content>
    </Window>
  );
};
