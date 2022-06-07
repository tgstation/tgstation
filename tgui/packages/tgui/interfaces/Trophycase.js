import { useBackend } from '../backend';
import { Icon, Box, Section, TextArea, Stack } from '../components';
import { Window } from '../layouts';

export const Trophycase = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    historian_mode,
    showpiece_name,
  } = data;
  return (
    <Window
      width={300}
      height={300}>
      <Window.Content>
        <Stack vertical fill>
          <Stack.Item>
            <Section align="center">
              <b>{showpiece_name ? showpiece_name : "Under construction."}</b>
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section align="center">
              <ShowpieceImage />
            </Section>
          </Stack.Item>
          <Stack.Item>
            <Section align="center">
              <ShowpieceDescription />
            </Section>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ShowpieceImage = (props, context) => {
  const { data } = useBackend(context);
  const {
    showpiece_icon,
  } = data;
  return (
    showpiece_icon ?(
      <Box as="img"
        m={1}
        src={`data:image/jpeg;base64,${showpiece_icon}`}
        height="96px"
        width="96px"
        style={{
          '-ms-interpolation-mode': 'nearest-neighbor',
        }} />
    ) : (
      <Box>
        <Icon name="landmark" spin />
      </Box>
    )
  );
};

const ShowpieceDescription = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    holographic_showpiece,
    historian_mode,
    showpiece_description,
  } = data;
  return (
    holographic_showpiece
      ? (
        <b>{showpiece_description}</b>
      )
      : historian_mode
        ? (
          <Box>
            <TextArea height="80px" maxLength={250} fluid placeholder="Let's make history!" value={showpiece_description}
              onChange={(e, value) => act('change_message', {
                passedMessage: value,
              })} />
          </Box>)
        : (
          <b>{showpiece_description ? showpiece_description : "This exhibit under construction. History awaits your contribution!"}</b>
        )
  );
};
