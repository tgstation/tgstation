import { useBackend } from '../backend';
import { Icon, Box, Section } from '../components';
import { Window } from '../layouts';

export const Trophycase = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    showpiece_name,
    showpiece_description,
  } = data;
  return (
    <Window
      width={300}
      height={270}>
      <Window.Content>
        <Section
          fontSize="18px"
          align="center"
          height="20%">
          <b>{showpiece_name ? showpiece_name : "Under construction."}</b>
        </Section>
        <Section fill
          height="40%">
          <HistoryImage />
        </Section>
        <Section
          align="center"
          height="40%">
          <b>{showpiece_description ? showpiece_description : "This exhibit under construction. History awaits your contribution!"}</b>
        </Section>
      </Window.Content>
    </Window>
  );
};

const HistoryImage = (props, context) => {
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
