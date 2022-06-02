import { useBackend } from '../backend';
import { Icon, Input, Box, Section, Flex } from '../components';
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
      height={270}>
      <Window.Content>
        <Flex direction="column" mb={1}>
          <Flex.Item mb={1}>
            <Section align="center">
              <b>{showpiece_name ? showpiece_name : "Under construction."}</b>
            </Section>
          </Flex.Item>
          <Flex.Item align="center" mb={1}>
            <Section fill>
              <ShowpieceImage />
            </Section>
          </Flex.Item>
          <Flex.Item mb={1}>
            <Section>
              <ShowpieceDescription />
            </Section>
          </Flex.Item>
        </Flex>
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
      <Section height="100%">
        <Box as="img"
          m={1}
          src={`data:image/jpeg;base64,${showpiece_icon}`}
          height="96px"
          width="96px"
          style={{
            '-ms-interpolation-mode': 'nearest-neighbor',
          }} />
      </Section>
    ) : (
      <Section height="100%">
        <Icon name="landmark" spin />
      </Section>)
  );
};

const ShowpieceDescription = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    added_roundstart,
    historian_mode,
    showpiece_description,
  } = data;
  return (
    added_roundstart
      ? (
        <Section>
          <b>{showpiece_description}</b>
        </Section>
      )
      : historian_mode
        ? (
          <Section>
            <Input fluid placeholder="Let's make history!" value={showpiece_description}
              onChange={(e, value) => act('changeMessage', {
                passedMessage: value,
              })} />
          </Section>
        )
        : (
          <Section>
            <b>{showpiece_description ? showpiece_description : "This exhibit under construction. History awaits your contribution!"}</b>
          </Section>
        )
  );
};
