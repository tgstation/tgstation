import { useBackend } from '../backend';
import { AnimatedNumber, Button, LabeledList, NoticeBox, ProgressBar, Section } from '../components';

export const GravityGenerator = props => {
  const { act, data } = useBackend(props);
  const {
    breaker,
    charging_state,
    on,
    charge_count,
  } = data;
  return (
    <Section
      title="Gravity Generator"
      textAlign="center"
      buttons={(
        <Button
          icon="sync"
          content="Power"
          onClick={() => act('gentoggle')} />
      )}>
      <LabeledList>
        <LabeledList.Item label="Gravity Generator Breaker:">
          {!on && (
            <NoticeBox>Power off.</NoticeBox>
          ) || (
            <NoticeBox>Power on.</NoticeBox>
          )}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};
