import { useBackend } from '../backend';
import { Fragment } from 'inferno';
import { Section, LabeledList, Button } from '../components';

export const AutomatedAnnouncement = props => {
  const { act, data } = useBackend(props);
  return (
    <Fragment>
      <Section
        title="Arrival Announcement"
        buttons=<Button
          icon="power-off"
          selected={data.arrivalToggle}
          onClick={() => {
            return act('ArrivalToggle');
          }}
          content={data.arrivalToggle ? "On" : "Off"}
        />>
        <LabeledList>
          <LabeledList.Item label="Message">
            <Button content={data.arrival}
              onClick={() => { return act('ArrivalText'); }} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Departmental Head Announcement"
        buttons=<Button
          icon="power-off"
          selected={data.newheadToggle}
          onClick={() => {
            return act('NewheadToggle');
          }}
          content={data.newheadToggle ? "On" : "Off"}
        />>
        <LabeledList>
          <LabeledList.Item label="Message">
            <Button content={data.newhead}
              onClick={() => { return act('NewheadText'); }} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
  );
};
