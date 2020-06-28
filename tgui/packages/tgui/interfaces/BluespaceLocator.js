import { Fragment } from 'inferno';
import { useBackend } from '../backend';
import { Section, Divider, Collapsible, Tabs } from '../components';
import { Window } from '../layouts';

export const BluespaceLocator = (props, context) => {
  const { data } = useBackend(context);
  const {
    telebeacons, 
    trackimplants,
  } = data;
  return (
    <Window resizable>
      <Window.Content scrollable>
       {/*              FUCK THIS SO MUCH
        <Tabs>
            <Tabs.tab selected={tabIndex === 1} onClick={() => setTabIndex(1)}>Teleporter Beacons</Tabs.tab>
            <Tabs.tab selected={tabIndex === 2} onClick={() => setTabIndex(2)}>Tracking Implants</Tabs.tab>
        </Tabs>
        */}
        <Section title="Teleporter Beacons">
            {telebeacons.map(tpbeacon => (
                <Collapsible key={tpbeacon.name} title={tpbeacon.name}>
                    Direction : {tpbeacon.direction}, {tpbeacon.distance}
                </Collapsible>
                )
            )}
        </Section>
        <Divider></Divider>
        <Section title="Tracking implants">
            {trackimplants.map(implant => (
                <Collapsible key={implant.name} title={implant.name}>
                    Direction : {implant.direction}, {implant.distance}
                </Collapsible>
                )
            )}
        </Section>
      </Window.Content>
    </Window>
  );
};