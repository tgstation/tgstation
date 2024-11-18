import { useBackend } from 'tgui/backend';
import { Box, Button, NoticeBox, Section } from 'tgui-core/components';
type Props = {
  storedName: string;
  ref: string;
};

export default function CargoHold(props: { ourProps: Props }): JSX.Element {
  const { act } = useBackend();
  const { ourProps } = props;
  return (
    <Box>
      <Section title="Loaded">
        {!ourProps.storedName ? (
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
                partRef: ourProps.ref,
              })
            }
            style={{
              textTransform: 'capitalize',
            }}
          >
            {ourProps.storedName}
          </Button>
        )}
      </Section>
    </Box>
  );
}
