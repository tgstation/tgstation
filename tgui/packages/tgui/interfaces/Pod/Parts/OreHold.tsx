import { useBackend } from 'tgui/backend';
import { Button, LabeledList, NoticeBox, Section } from 'tgui-core/components';

type Ore = {
  name: string;
  count: number;
};
type Props = {
  ores: Ore[];
  ref: string;
};

export default function CargoHold(props: { ourProps: Props }): JSX.Element {
  const { act } = useBackend();
  const { ourProps } = props;
  return (
    <Section
      title="Loaded"
      maxHeight="46%"
      overflowY="auto"
      overflowX="hidden"
      buttons={
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
        />
      }
    >
      {!ourProps.ores.length ? (
        <NoticeBox info>Nothing loaded.</NoticeBox>
      ) : (
        <LabeledList>
          {ourProps.ores.map((ore) => (
            <LabeledList.Item key={ore.name} label={ore.name}>
              {ore.count}
            </LabeledList.Item>
          ))}
        </LabeledList>
      )}
    </Section>
  );
}
