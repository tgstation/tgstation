import { useBackend, useLocalState } from '../backend';
import { Section, Stack, Box, Divider, Button, NumberInput } from '../components';
import { Window } from '../layouts';

export const CargoGunConsole = (props, context) => {
  const [category, setCategory] = useLocalState(context, 'category', '');
  const [weapon, setArmament] = useLocalState(context, 'weapon');
  const { act, data } = useBackend(context);
  const {
    armaments_list = [],
    budget_points,
    budget_name,
    ammo_amount,
    self_paid,
  } = data;
  return (
    <Window
      theme="armament"
      title="Firearm Requisition Console"
      width={1000}
      height={600}>
      <Window.Content>
        <Section grow height="100%" title="Firearm Requisition Console">
          <Stack>
            <Stack.Item grow fill>
              <Button.Checkbox
                content="Buy Privately"
                checked={self_paid}
                onClick={() => act('toggleprivate')} />
              <Box>
                <b>Current Budget:</b> {budget_name}
              </Box>
              <Box>
                <b>Budget Remaining:</b> {budget_points}
              </Box>
            </Stack.Item>
          </Stack>
          <Divider />
          <Stack fill grow>
            <Stack.Item mr={1}>
              <Section title="Companies">
                <Stack vertical>
                  {armaments_list.map(armament_category => (
                    <Stack.Item key={armament_category.category}>
                      {armament_category.category_purchased ? (
                        <Button
                          width="100%"
                          content={armament_category.category}
                          selected={category === armament_category.category}
                          onClick={() =>
                            setCategory(armament_category.category)} />
                      ) : (
                        <Button
                          width="100%"
                          color="bad"
                          onClick={() => act('buy_company', {
                            selected_company: armament_category.category })}
                          content={'Purchase '
                          + (armament_category.category)
                          + ' ('
                          + (armament_category.handout ? 'Handout [Choose One]' : armament_category.cost)
                          + ' Cr)'} />
                      )}
                    </Stack.Item>
                  ))}
                </Stack>
              </Section>
            </Stack.Item>
            <Divider vertical />
            <Stack.Item grow mr={1}>
              <Section title={category} scrollable fill height="480px">
                {armaments_list.map(armament_category => (
                  armament_category.category === category && (
                    armament_category.subcategories.map(subcat => (
                      <Section
                        key={subcat.subcategory}
                        title={subcat.subcategory}>
                        <Stack vertical>
                          {subcat.items.map(item => (
                            <Stack.Item key={item.ref}>
                              <Button
                                fontSize="15px"
                                textAlign="center"
                                selected={weapon === item.ref}
                                color={item.cant_purchase ? "bad" : item.purchased >= item.quantity ? "bad" : "default"}
                                width="100%"
                                key={item.ref}
                                onClick={() =>
                                  setArmament(item.ref)}>
                                <img
                                  src={`data:image/jpeg;base64,${item.icon}`}
                                  style={{
                                    'vertical-align': 'middle',
                                    'horizontal-align': 'middle',
                                  }}
                                />
                                &nbsp;{item.name}
                              </Button>
                            </Stack.Item>
                          ))}
                        </Stack>
                      </Section>
                    ))
                  )
                ))}
              </Section>
            </Stack.Item>
            <Divider vertical />
            <Stack.Item width="20%">
              <Section title="Selected Armament">
                {armaments_list.map(armament_category => (
                  armament_category.subcategories.map(subcat => (
                    subcat.items.map(item => (
                      item.ref === weapon && (
                        <Stack vertical>
                          <Stack.Item>
                            <Box key={item.ref}>
                              <img
                                height="100%"
                                width="100%"
                                src={`data:image/jpeg;base64,${item.icon}`}
                                style={{
                                  'vertical-align': 'middle',
                                  'horizontal-align': 'middle',
                                  '-ms-interpolation-mode': 'nearest-neighbor',
                                }}
                              />
                            </Box>
                          </Stack.Item>
                          <Stack.Item>
                            {item.description}
                          </Stack.Item>
                          {!!item.cant_purchase && (
                            <Stack.Item
                              textColor={"red"}>
                              {'Company interest needs to be higher to buy this item!'}
                            </Stack.Item>
                          )}
                          <Stack.Item
                            textColor={(item.quantity) <= 0 ? "red" : "green"}>
                            {'Quantity Remaining: ' + (item.quantity)}
                          </Stack.Item>
                          <Stack.Item
                            textColor={(item.cost > budget_points) ? "red" : "green"}>
                            {'Cost: ' + item.cost}
                          </Stack.Item>
                          {!!item.buyable_ammo && (
                            <Stack.Item
                              textColor={(item.magazine_cost > budget_points) ? "red" : "green"}>
                              {'Ammo Cost: ' + item.magazine_cost}
                            </Stack.Item>
                          )}
                          <Stack.Item>
                            <Button
                              content="Buy"
                              textAlign="center"
                              width="100%"
                              disabled={item.cost > budget_points
                                || 0 >= item.quantity
                                || !!item.cant_purchase}
                              onClick={() => act('equip_item', {
                                armament_ref: item.ref })}
                            />
                          </Stack.Item>
                          {!!item.buyable_ammo && (
                            <Stack.Item>
                              <Button
                                content="Buy Ammo"
                                textAlign="center"
                                width="100%"
                                disabled={item.magazine_cost > budget_points}
                                onClick={() => act('buy_ammo', {
                                  armament_ref: item.ref })}
                              />
                            </Stack.Item>
                          )}
                          {!!item.buyable_ammo && (
                            <NumberInput
                              value={ammo_amount}
                              width="59px"
                              minValue={0}
                              maxValue={10}
                              step={1}
                              stepPixelSize={2}
                              onChange={(e, value) => act('set_ammo_amount', {
                                chosen_amount: value,
                              })} />
                          )}
                        </Stack>
                      )
                    ))
                  ))
                ))}
              </Section>
            </Stack.Item>
          </Stack>
        </Section>
      </Window.Content>
    </Window>
  );
};
