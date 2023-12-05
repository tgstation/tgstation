import { useBackend } from '../backend';
import { Button, LabeledList, Section, Box } from '../components';
import { Window } from '../layouts';

export const PsiWeb = (props, context) => {
  const { act, data } = useBackend(context);
  return (
    <Window width={900} height={480}>
      <Window.Content scrollable>
        <Section title="Psi Web">
          <LabeledList>
            <LabeledList.Item label="Lucidity" right>
              {data.lucidity}
            </LabeledList.Item>
          </LabeledList>
        </Section>
        <Section title="Abilities">
          <LabeledList>
            {data.abilities.map(ability => (

              <LabeledList.Item label={ability.name} key={ability.name}>
                <Box>{ability.desc}</Box>
                <Box>Psi use cost: {ability.psi_cost}</Box>
                <Box>Cost to unlock: {ability.lucidity_cost}</Box>
                <Button
                  selected={ability.owned}
                  disabled={!ability.can_purchase}
                  onClick={() => act('unlock', {
                    'id': ability.id,
                  })}
                  content={ability.owned ? "Unlocked" : "Unlock"}
                />
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
        <Section title="Upgrades">
          <LabeledList>
            {data.upgrades.map(upgrade => (

              <LabeledList.Item label={upgrade.name} key={upgrade.name}>
                <Box>{upgrade.desc}</Box>
                <Box>Cost to unlock: {upgrade.lucidity_cost}</Box>
                <Button
                  selected={upgrade.owned}
                  disabled={!upgrade.can_purchase}
                  onClick={() => act('upgrade', {
                    'id': upgrade.id,
                  })}
                  content={upgrade.owned ? "Unlocked" : "Unlock"}
                />
              </LabeledList.Item>
            ))}
          </LabeledList>
        </Section>
      </Window.Content>
    </Window>
  );
};
