import { Fragment } from 'inferno';
import { act } from '../byond';
import { Box, Button, LabeledList, Section, Tabs, Icon } from '../components';
import { map } from 'common/fp';

export const CraftingList = props => {
  const {
    state,
    craftables = [],
  } = props;
  const { config, data } = state;
  const { ref } = config;
  const craftability = data.craftability || {};
  return (
    data.display_compact ? (
      <LabeledList>
        {craftables.map(craftable => {
          if (craftability[craftable.ref] || !data.display_craftable_only) {
            return (
              <LabeledList.Item
                key={craftable.name}
                label={craftable.name}
                className="candystripe"
                buttons={(
                  <Button
                    icon="cog"
                    content="Craft"
                    disabled={!craftability[craftable.ref]}
                    tooltip={(craftable.tool_text && ("Tools needed: " + craftable.tool_text))}
                    tooltipPosition="left"
                    onClick={() => act(ref, 'make', {recipe: craftable.ref})}
                  />
                )}
              >
                {craftable.req_text}
              </LabeledList.Item>
            );
          }
        })}
      </LabeledList>
    ) : (
      craftables.map(craftable => {
        if (craftability[craftable.ref] || !data.display_craftable_only) {
          return (
            <Section
              key={craftable.name}
              title={craftable.name}
              level={2}
              buttons={(
                <Button
                  icon="cog"
                  content="Craft"
                  disabled={!craftability[craftable.ref]}
                  onClick={() => act(ref, 'make', {recipe: craftable.ref})}
                />
              )}
            >
              <LabeledList>
                {!!craftable.req_text && (
                  <LabeledList.Item label="Required">
                    {craftable.req_text}
                  </LabeledList.Item>
                )}
                {!!craftable.catalyst_text && (
                  <LabeledList.Item label="Catalyst">
                    {craftable.catalyst_text}
                  </LabeledList.Item>
                )}
                {!!craftable.tool_text && (
                  <LabeledList.Item label="Tools">
                    {craftable.tool_text}
                  </LabeledList.Item>
                )}
              </LabeledList>
            </Section>
          );
        }
      })
    )
  );
};

export const PersonalCrafting = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const {
    busy,
    display_craftable_only,
    display_compact,
    crafting_recipes = {},
    craftability = {},
  } = data;

  if (busy) {
    return (
      <Fragment>
        <Box
          mt={30}
          width="100%"
          textAlign="center"
          fontSize="60px"
        >
        Crafting...
        </Box>
        <Box
          width="100%"
          textAlign="center"
        >
          <Icon
            name="cog"
            size={5}
            spin={1}
          />
        </Box>
      </Fragment>
    );
  }

  return (
    <Section
      title="Personal Crafting"
      buttons={(
        <Fragment>
          <Button
            icon={display_compact ? "check-square-o" : "square-o"}
            content="Compact"
            selected={display_compact}
            onClick={() => act(ref, 'toggle_compact')}
          />
          <Button
            icon={display_craftable_only ? "check-square-o" : "square-o"}
            content="Craftable Only"
            selected={display_craftable_only}
            onClick={() => act(ref, 'toggle_recipes')}
          />
        </Fragment>
      )}
    >
      <Tabs>
        {map((subcategory, category) => {
          const hasSubcats = ("has_subcats" in subcategory);
          return (
            <Tabs.Tab
              key={category}
              label={category}
              onClick={(e, key) => {
                let first = "";
                if (hasSubcats) {
                  map((value, name) => { // This is horrifically hacky but it works
                    if (name === "has_cubcats") { return; }
                    if (first !== "") { return; }
                    first = name;
                  })(subcategory);
                }
                act(ref, 'set_category', {category: category, subcategory: first});
              }}

            >
              {hasSubcats ? (
                <Tabs vertical>
                  {map((value, name) => {
                    if (name === "has_subcats") { return; }
                    return (
                      <Tabs.Tab
                        label={name}
                        onClick={(e, key) => act(ref, 'set_category', {subcategory: name})}
                      >
                        <CraftingList craftables={value} state={state} />
                      </Tabs.Tab>
                    );
                  })(subcategory)}
                </Tabs>
              ) : (
                <CraftingList craftables={subcategory} state={state} />
              )}
            </Tabs.Tab>
          );
        })(crafting_recipes)}
      </Tabs>
    </Section>
  );
};


