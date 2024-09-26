import { useBackend } from '../../../backend';
import { Box, Button, NoticeBox, Section } from '../../../components';
type Data = {
  storedName: string;
  ref: string;
};

export default function CargoHold(props: { partData: Data }): JSX.Element {
  const { act } = useBackend<{
    ourData: Data;
  }>();
  const ourData = props.partData as Data;
  return (
    <Box>
      <Section title="Loaded">
        {!ourData.storedName ? (
          <NoticeBox info>
            Nothing loaded. Drag something onto the pod.
          </NoticeBox>
        ) : (
          <Button
            fluid
            py={0.2}
            icon="eject"
            onClick={() =>
              act('eject', {
                partRef: ourData.ref,
              })
            }
            style={{
              textTransform: 'capitalize',
            }}
          >
            {ourData.storedName}
          </Button>
        )}
      </Section>
    </Box>
  );
}
