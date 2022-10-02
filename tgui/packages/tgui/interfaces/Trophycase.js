import { decodeHtmlEntities } from 'common/string';
import { useBackend } from '../backend';
import { Icon, Box, Button, Dimmer, Section, TextArea, Stack } from '../components';
import { Window } from '../layouts';

export const Trophycase = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window width={300} height={400}>
      <Window.Content>
        <Stack fill vertical>
          <Stack.Item>
            <ShowpieceName />
          </Stack.Item>
          <Stack.Item>
            <ShowpieceImage />
          </Stack.Item>
          <Stack.Item>
            <ShowpieceDescription />
          </Stack.Item>
        </Stack>
        <Stack.Item>
          <HistorianPanel />
        </Stack.Item>
      </Window.Content>
    </Window>
  );
};

const HistorianPanel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    has_showpiece,
    historian_mode,
    holographic_showpiece,
    showpiece_description,
  } = data;

  return (
    <Section align="left">
      {!historian_mode && (
        <Button
          icon="key"
          content="Insert key"
          onClick={() => act('insert_key')}
        />
      )}
      {!!historian_mode && (
        <Button icon="times" content="Lock" onClick={() => act('lock')} />
      )}
      {!!historian_mode && !!holographic_showpiece && (
        <Box>
          A holographic trophy is already present. Replace it with a new trophy
          to create a new recording.
        </Box>
      )}
      {!!historian_mode && !has_showpiece && <Box>No trophies located.</Box>}
      {!!historian_mode &&
        !!has_showpiece &&
        !holographic_showpiece &&
        !!showpiece_description && (
          <Box>
            Recording has begun. Trophy data will be saved overnight, as long as
            the trophy stays within an intact case.
          </Box>
        )}
      {!!historian_mode &&
        !!has_showpiece &&
        !holographic_showpiece &&
        !showpiece_description && (
          <Box>
            New trophy detected. Please record a message to begin archival.
          </Box>
        )}
    </Section>
  );
};

const ShowpieceDescription = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    has_showpiece,
    holographic_showpiece,
    historian_mode,
    max_length,
    showpiece_description,
  } = data;
  return (
    <Section align="center">
      {!has_showpiece && (
        <Box fill className="Trophycase-description">
          <b>This exhibit is empty. History awaits your contribution!</b>
        </Box>
      )}
      {!!holographic_showpiece && <b>{showpiece_description}</b>}
      {!holographic_showpiece && !historian_mode && !!has_showpiece && (
        <Box fill className="Trophycase-description">
          {showpiece_description
            ? decodeHtmlEntities(showpiece_description)
            : "This exhibit under construction. Get the curator's key to finalize your contribution!"}
        </Box>
      )}
      {!holographic_showpiece && !!historian_mode && !!has_showpiece && (
        <Box fill>
          <TextArea
            height="60px"
            fluid
            maxLength={max_length}
            placeholder="Let's make history!"
            value={showpiece_description}
            onChange={(e, value) =>
              act('change_message', {
                passedMessage: value,
              })
            }
          />
        </Box>
      )}
    </Section>
  );
};

const ShowpieceImage = (props, context) => {
  const { data } = useBackend(context);
  const { showpiece_icon } = data;
  return showpiece_icon ? (
    <Section align="center">
      <Box
        as="img"
        m={1}
        src={`data:image/jpeg;base64,${showpiece_icon}`}
        height="96px"
        width="96px"
        style={{
          '-ms-interpolation-mode': 'nearest-neighbor',
        }}
      />
    </Section>
  ) : (
    <Section align="center">
      <Box height="96px" width="96px">
        <Dimmer fontSize="32px">
          <Icon name="landmark" spin />
        </Dimmer>
      </Box>
    </Section>
  );
};

const ShowpieceName = (props, context) => {
  const { data } = useBackend(context);
  const { showpiece_name } = data;
  return (
    <b>
      {showpiece_name
        ? decodeHtmlEntities(showpiece_name)
        : 'Under construction.'}
    </b>
  );
};
