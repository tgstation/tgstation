import { useBackend } from '../backend';
import { Button, Section, NumberInput, LabeledList } from '../components';

export const Nanobed = props => {
  const { act, data } = useBackend(props);
  const {
    active,
    cloud_id,
  } = data;
  return (
    <Section
      title="Nanite Bed"
      buttons={(
        <Button
          icon={active ? 'power-off' : 'times'}
          content={active ? 'Active' : 'Inactive'}
          selected={active}
          color="bad"
          bold
          onClick={() => act('toggle_active')} />
      )}>
      <LabeledList>
        <LabeledList.Item label="Cloud ID">
          <NumberInput
            value={cloud_id}
            width="47px"
            minValue={1}
            maxValue={100}
            onChange={(e, value) => act('set_cloud', {
              code: value,
            })} />
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
