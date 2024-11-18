import { useBackend } from 'tgui/backend';
import { Button, LabeledList, NoticeBox, Section } from 'tgui-core/components';

type Ore = {
  name: string;
  count: number;
};
type Data = {
  ores: Ore[];
  ref: string;
};

export default function CargoHold(props: { ourData: Data }): JSX.Element {
  const { act } = useBackend();
  const { ourData } = props;
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
              partRef: ourData.ref,
            })
          }
          style={{
            textTransform: 'capitalize',
          }}
        />
      }
    >
      {!ourData.ores.length ? (
        <NoticeBox info>Nothing loaded.</NoticeBox>
      ) : (
        <LabeledList>
          {ourData.ores.map((ore) => (
            <LabeledList.Item key={ore.name} label={ore.name}>
              {ore.count}
            </LabeledList.Item>
          ))}
        </LabeledList>
      )}
    </Section>
  );
}
