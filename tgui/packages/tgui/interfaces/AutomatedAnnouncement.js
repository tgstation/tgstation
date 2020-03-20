import { useBackend } from '../backend';
import { Fragment } from 'inferno';
import { Section, LabeledList, Button, Input } from '../components';

export const AutomatedAnnouncement = props => {
  const { act, data } = useBackend(props);
  return (
    <Fragment>
      <Section
        title="Arrival Announcement"
        buttons={(
          <Button
            icon="power-off"
            selected={data.arrivalToggle}
            onClick={() => act('ArrivalToggle')}
            content={data.arrivalToggle ? "On" : "Off"}
          />
        )}>
        <LabeledList>
          <LabeledList.Item label="Message">
            <Input
              value={data.arrival}
              width="290px"
              onChange={(e, value) => act('ArrivalText', {
                newText: value,
              })} />
            <Button
              icon="info"
              tooltip="%PERSON will be replaced with their name.\
              %RANK with their job."
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Departmental Head Announcement"
        buttons={(
          <Button
            icon="power-off"
            selected={data.newheadToggle}
            onClick={() => act('NewheadToggle')}
            content={data.newheadToggle ? "On" : "Off"}
          />
        )}>
        <LabeledList>
          <LabeledList.Item label="Message">
            <Input
              value={data.newhead}
              width="290px"
              onChange={(e, value) => act('NewheadText', {
                newText: value,
              })} />
            <Button
              icon="info"
              tooltip="%PERSON will be replaced with their name.\
              %RANK with their job."
            />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
  );
};
