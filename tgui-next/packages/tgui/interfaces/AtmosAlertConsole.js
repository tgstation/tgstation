import { Fragment } from 'inferno';
import { act } from '../byond';
import { Button, Section } from '../components';

export const AtmosAlertConsole = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const priorityAlerts = data.priority || [];
  const minorAlerts = data.minor || [];
  return (
    <Fragment>
      <Section title="Alarms">
        <ul>
          {priorityAlerts.length > 0 ? (
            <Fragment>
              {priorityAlerts.map(alert => (
                <li>
                  <Button
                    icon="times"
                    content={alert}
                    color="bad"
                    onClick={() => act(ref, 'clear', { zone: alert })} />
                </li>
              ))}
            </Fragment>
          ) : (
            <Fragment>
              <li>
                <span className="color-good">
                  No Priority Alerts
                </span>
              </li>
            </Fragment>
          )}
          {minorAlerts.length > 0 ? (
            <Fragment>
              {minorAlerts.map(alert => (
                <li>
                  <Button
                    icon="times"
                    content={alert}
                    color="average"
                    onClick={() => act(ref, 'clear', { zone: alert })} />
                </li>
              ))}
            </Fragment>
          ) : (
            <Fragment>
              <li>
                <span className="color-good">
                  No Minor Alerts
                </span>
              </li>
            </Fragment>
          )}
        </ul>
      </Section>
    </Fragment>
  );
};
