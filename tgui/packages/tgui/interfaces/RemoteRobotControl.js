import { decodeHtmlEntities } from 'common/string';
import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Button, Section, LabeledList } from '../components';

export const RemoteRobotControl = props => {
  const { act, data } = useBackend(props);
  const {
    robots = [],
  } = data;
  return (
    <Fragment>
      {robots.map(robot => (
        <Section
          key={robot.ref}
          title={robot.name + " (" + robot.model + ")"}
          level="1"
          buttons={(
            <Fragment>
              <Button
                icon="tools"
                content="Interface"
                onClick={() => act('interface', {
                  ref: robot.ref,
                })} />
              <Button
                icon="phone-alt"
                content="Call"
                onClick={() => act('callbot', {
                  ref: robot.ref,
                })} />
            </Fragment>
          )}>
          <LabeledList>
            <LabeledList.Item label="Status">
            {decodeHtmlEntities(robot.mode)}
            </LabeledList.Item>
            <LabeledList.Item label="Location">
              {robot.location}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      ))}
</Fragment>
  );
};
