import { Fragment } from 'inferno';
import { act } from '../byond';
import { Section, Button } from '../components';

export const StationAlertConsole = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const categories = data.alarms || [];
  const fire = categories['Fire'] || [];
  const atmos = categories['Atmosphere'] || [];
  const power = categories['Power'] || [];
  return (
    <Fragment>
      <Section title="Fire Alarms">
        <ul>
          {fire.length > 0 ? (
            fire.map(alert => (
              <li key={alert}>
                {alert}
              </li>
            ))
          ) : (
            <li className="color-good">
              System Nominal
            </li>
          )}
        </ul>
      </Section>
      <Section title="Atmospherics Alarms">
        <ul>
          {atmos.length > 0 ? (
            atmos.map(alert => (
              <li key={alert}>
                {alert}
              </li>
            ))
          ) : (
            <li className="color-good">
                System Nominal
            </li>
          )}
        </ul>
      </Section>
      <Section title="Power Alarms">
        <ul>
          {power.length > 0 ? (
            power.map(alert => (
              <li key={alert}>
                {alert}
              </li>
            ))
          ) : (
            <li className="color-good">
              System Nominal
            </li>
          )}
        </ul>
      </Section>
    </Fragment>
  );
};
