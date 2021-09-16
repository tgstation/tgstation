import { filter, sortBy } from 'common/collections';
import { flow } from 'common/fp';
import { toFixed } from 'common/math';

import { Box, Icon, LabeledList, ProgressBar, Section, Tooltip } from '../../components';
import { getGasColor, getGasLabel } from '../../constants';

const moderator_gases_help = {
  plasma: "Produces basic gases. Has a modest heat bonus to help kick start the early fusion process. When added in large quantities, its high heat capacity can help to slow down temperature changes to manageable speeds.",
  bz: "Produces intermediate gases at Fusion Level 3 or higher. Massively increases radiation, and induces hallucinations in bystanders.",
  proto_nitrate: "Produces advanced gases. Massively increases radiation, and accelerates the rate of temperature change. Make sure you have enough cooling.",
  o2: "When added in high quantities, rapidly purges iron content. Does not purge iron content fast enough to keep up with damage at high Fusion Levels.",
  healium: "Directly heals a heavily damaged HFR core at high Fusion Levels, but is rapidly consumed in the process.",
  antinoblium: "Provides huge amounts of energy and radiation. Can cause dangerous electrical storms even from a healthy HFR core when present in more than trace amounts. Wear appropriate electrical protection when handling.",
  freon: "Saps most forms of energy expression. Slows the rate of temperature change."
};

const moderator_gases_sticky_order = [
  "plasma",
  "bz",
  "proto_nitrate",
];

const ensure_gases = (gas_array, gasids) => {
  const gases_by_id = {};
  gas_array.forEach(gas => gases_by_id[gas.id] = true);

  for (let gasid of gasids) {
    if (!gases_by_id[gasid]) {
      gas_array.push({id: gasid, amount: 0});
    }
  }
}

export const HypertorusGases = props => {
  const {
    fusionGases: raw_fusion_gases,
    moderatorGases: raw_moderator_gases,
    selectedFuel,
  } = props;

  const fusion_gases = flow([
    filter(gas => gas.amount >= 0.01),
    sortBy(gas => -gas.amount),
  ])(raw_fusion_gases || []);

  if (selectedFuel) {
    // Always display the requirement gases of the selected recipe.
    ensure_gases(fusion_gases, selectedFuel.requirements);
  }

  const moderator_gases = flow([
    filter(gas => gas.amount >= 0.01),
    sortBy(gas => -gas.amount),
  ])(raw_moderator_gases || []);

  // Make sure the "sticky" production gases are always visible. We want to display help for these.
  ensure_gases(moderator_gases, moderator_gases_sticky_order);

  const fusionMax = Math.max(500, ...fusion_gases.map(gas => gas.amount));
  const moderatorMax = Math.max(500, ...moderator_gases.map(gas => gas.amount));

  return (
    <>
      <Section title="Internal Fusion Gases">
        {selectedFuel ? (<LabeledList>
          {fusion_gases.map(gas => (
            <LabeledList.Item
              key={gas.id}
              label={getGasLabel(gas.id)}>
              <ProgressBar
                color={getGasColor(gas.id)}
                value={gas.amount}
                minValue={0}
                maxValue={fusionMax}>
                {toFixed(gas.amount, 2) + ' moles'}
              </ProgressBar>
            </LabeledList.Item>
          ))}
        </LabeledList>) :
        (<Box align="center" color="red">{"No recipe selected"}</Box>)
        }
      </Section>
      <Section title="Moderator Gases">
        <LabeledList>
          {moderator_gases.map(gas => {
            // Add in an icon to display tooltip help for interesting gases.
            let labelPrefix;
            if (moderator_gases_help[gas.id]) {
              labelPrefix = (
                <Tooltip content={moderator_gases_help[gas.id]}>
                  <Icon name="question-circle" width="12px" mr="6px"/>
                </Tooltip>
              );
            } else {
              // Empty icon for spacing purposes
              labelPrefix = (
                <Icon name="" width="12px" mr="6px" />
              )
            }
            return (
              <LabeledList.Item
                key={gas.id}
                label={
                <>
                  {labelPrefix}
                  {getGasLabel(gas.id)}:
                </>
                }>
                <ProgressBar
                  color={getGasColor(gas.id)}
                  value={gas.amount}
                  minValue={0}
                  maxValue={moderatorMax}>
                  {toFixed(gas.amount, 2) + ' moles'}
                </ProgressBar>
              </LabeledList.Item>
            );
          })}
        </LabeledList>
      </Section>
    </>
  );
};
