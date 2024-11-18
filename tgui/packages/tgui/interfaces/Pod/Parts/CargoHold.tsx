import { useBackend } from 'tgui/backend';
import { Box, Button, NoticeBox, Section } from 'tgui-core/components';
type Data = {
  storedName: string;
  ref: string;
};

export default function CargoHold(props: { ourData: Data }): JSX.Element {
  const { act } = useBackend();
  const { ourData } = props;
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
