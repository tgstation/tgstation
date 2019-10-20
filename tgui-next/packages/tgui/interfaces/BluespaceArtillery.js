import { Fragment } from 'inferno';
import { act } from '../byond';
import { Box, Button, LabeledList, NoticeBox, Section } from '../components';

export const BluespaceArtillery = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  return (
    <Fragment>
      {!!data.notice && (
        <NoticeBox>
          {data.notice}
        </NoticeBox>
      )}
      {data.connected ? (
        <Fragment>
          <Section
            title="Target"
            buttons={(
              <Button
                icon="crosshairs"
                disabled={!data.unlocked}
                onclick={() => act(ref, 'recalibrate')} />
            )}>
            <Box
              color={data.target ? 'average' : 'bad'}
              style={{
                'font-size': '25px',
              }}>
              {data.target || 'No Target Set'}
            </Box>
          </Section>
          <Section>
            {data.unlocked ? (
              <Box style={{ margin: 'auto' }}>
                <Button
                  content="FIRE"
                  color="bad"
                  fluid={1}
                  disabled={!data.target}
                  style={{
                    'font-size': '30px',
                    'text-align': 'center',
                    'line-height': '46px',
                  }}
                  onClick={() => act(ref, 'fire')} />
              </Box>
            ) : (
              <Fragment>
                <Box
                  color="bad"
                  style={{
                    'font-size': '18px',
                  }}>
                  Bluespace artillery is currently locked.
                </Box>
                <Box mt={1}>
                  Awaiting authorization via keycard reader from at minimum
                  two station heads.
                </Box>
              </Fragment>
            )}
          </Section>
        </Fragment>
      ) : (
        <Section>
          <LabeledList>
            <LabeledList.Item label="Maintenance">
              <Button
                icon="wrench"
                content="Complete Deployment"
                onClick={() => act(ref, 'build')} />
            </LabeledList.Item>
          </LabeledList>
        </Section>
      )}
    </Fragment>
  );
};
