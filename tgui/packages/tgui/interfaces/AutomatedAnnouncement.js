import { multiline } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, Input, LabeledList, Section } from '../components';

const TOOLTIP_TEXT = multiline`
  %PERSON will be replaced with their name.
  %RANK with their job.
`;

export const AutomatedAnnouncement = props => {
  const { act, data } = useBackend(props);
  const {
    arrivalToggle,
    arrival,
    newheadToggle,
    newhead,
  } = data;
  return (
    <Fragment>
      <Section
        title="Arrival Announcement"
        buttons={(
          <Button
            icon={arrivalToggle ? 'power-off' : 'times'}
            selected={arrivalToggle}
            content={arrivalToggle ? 'On' : 'Off'}
            onClick={() => act('ArrivalToggle')} />
        )}>
        <LabeledList>
          <LabeledList.Item
            label="Message"
            buttons={(
              <Button
                icon="info"
                tooltip={TOOLTIP_TEXT}
                tooltipPosition="left" />
            )}>
            <Input
              fluid
              value={arrival}
              onChange={(e, value) => act('ArrivalText', {
                newText: value,
              })} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section
        title="Departmental Head Announcement"
        buttons={(
          <Button
            icon={newheadToggle ? 'power-off' : 'times'}
            selected={newheadToggle}
            content={newheadToggle ? 'On' : 'Off'}
            onClick={() => act('NewheadToggle')} />
        )}>
        <LabeledList>
          <LabeledList.Item
            label="Message"
            buttons={(
              <Button
                icon="info"
                tooltip={TOOLTIP_TEXT}
                tooltipPosition="left" />
            )}>
            <Input
              fluid
              value={newhead}
              onChange={(e, value) => act('NewheadText', {
                newText: value,
              })} />
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Fragment>
  );
};
