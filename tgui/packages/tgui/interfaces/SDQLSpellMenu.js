import { useBackend } from '../backend';
import { Box, Button, Collapsible, Dropdown, Input, NumberInput, Section, Stack, Tooltip } from '../components';
import { Window } from '../layouts';

/**
 * Gets a list of objects that encode the parameters for the variables relevant
 * to the passed spell type.
 * @param type The type of the spell.
 * @returns A list of objects. Each object contains the name of the variable,
 * the variable's data type,
 * what options are valid (if the variable is an enum),
 * and what the variable's default value should be.
 */
const typevars = (type) => {
  let ret = [
    { name: 'name', type: 'string', options: null, default_value: '' },
    { name: 'desc', type: 'string', options: null, default_value: '' },
    { name: 'query', type: 'string', options: null, default_value: '' },
    { name: 'action_icon', type: 'string', options: null, default_value: '' },
    {
      name: 'action_icon_state',
      type: 'string',
      options: null,
      default_value: '',
    },
    {
      name: 'action_background_icon_state',
      type: 'string',
      options: null,
      default_value: '',
    },
    { name: 'sound', type: 'string', options: null, default_value: '' },
    {
      name: 'charge_type',
      type: 'string_enum',
      options: ['recharge', 'charges', 'holder_var'],
      default_value: 'recharge',
    },
    { name: 'charge_max', type: 'int', options: null, default_value: 100 },
    {
      name: 'still_recharging_message',
      type: 'string',
      options: null,
      default_value: '',
    },
    {
      name: 'holder_var_type',
      type: 'string',
      options: null,
      default_value: '',
    },
    {
      name: 'holder_var_amount',
      type: 'int',
      options: null,
      default_value: '',
    },
    { name: 'clothes_req', type: 'bool', options: null, default_value: false },
    { name: 'cult_req', type: 'bool', options: null, default_value: false },
    { name: 'human_req', type: 'bool', options: null, default_value: false },
    {
      name: 'nonabstract_req',
      type: 'bool',
      options: null,
      default_value: false,
    },
    { name: 'stat_allowed', type: 'bool', options: null, default_value: false },
    {
      name: 'phase_allowed',
      type: 'bool',
      options: null,
      default_value: false,
    },
    {
      name: 'antimagic_allowed',
      type: 'bool',
      options: null,
      default_value: false,
    },
    {
      name: 'invocation_type',
      type: 'string_enum',
      options: ['none', 'whisper', 'emote', 'shout'],
      default_value: 'none',
    },
    { name: 'invocation', type: 'string', options: null, default_value: '' },
    {
      name: 'invocation_emote_self',
      type: 'string',
      options: null,
      default_value: '',
    },
    {
      name: 'selection_type',
      type: 'string_enum',
      options: ['view', 'range'],
      default_value: 'view',
    },
    { name: 'range', type: 'int', options: null, default_value: 7 },
    { name: 'message', type: 'string', options: null, default_value: '' },
    { name: 'player_lock', type: 'bool', options: null, default_value: true },
    {
      name: 'sparks_spread',
      type: 'bool',
      options: null,
      default_value: false,
    },
    { name: 'sparks_amt', type: 'int', options: null, default_value: 0 },
    {
      name: 'smoke_spread',
      type: 'int_enum',
      options: ['none', 'harmless', 'harmful', 'sleeping'],
      default_value: 'none',
    },
    { name: 'smoke_amt', type: 'int', options: null, default_value: 0 },
    {
      name: 'centcom_cancast',
      type: 'bool',
      options: null,
      default_value: false,
    },
  ];
  switch (type) {
    case 'targeted':
      ret.push(
        { name: 'overlay', type: 'bool', options: null, default_value: false },
        {
          name: 'overlay_icon',
          type: 'string',
          options: null,
          default_value: '',
        },
        {
          name: 'overlay_icon_state',
          type: 'string',
          options: null,
          default_value: '',
        },
        {
          name: 'overlay_lifespan',
          type: 'int',
          options: null,
          default_value: 0,
        },
        {
          name: 'max_targets',
          type: 'int',
          options: null,
          default_value: false,
        },
        {
          name: 'target_ignore_prev',
          type: 'bool',
          options: null,
          default_value: true,
        },
        {
          name: 'include_user',
          type: 'bool',
          options: null,
          default_value: false,
        },
        {
          name: 'random_target',
          type: 'bool',
          options: null,
          default_value: false,
        },
        {
          name: 'random_target_priority',
          type: 'int_enum',
          options: ['closest', 'random'],
          default_value: 'closest',
        }
      );
      break;
    case 'aoe_turf':
      ret = ret.filter((variable) => variable.name !== 'selection_type');
      ret.push(
        { name: 'inner_radius', type: 'int', options: null, default_value: -1 },
        { name: 'overlay', type: 'bool', options: null, default_value: false },
        {
          name: 'overlay_icon',
          type: 'string',
          options: null,
          default_value: '',
        },
        {
          name: 'overlay_icon_state',
          type: 'string',
          options: null,
          default_value: '',
        },
        {
          name: 'overlay_lifespan',
          type: 'int',
          options: null,
          default_value: 0,
        }
      );
      break;
    case 'self':
      ret = ret.filter(
        (variable) =>
          variable.name !== 'range' && variable.name !== 'selection_type'
      );
      break;
    case 'aimed':
      ret.push(
        {
          name: 'base_icon_state',
          type: 'string',
          options: null,
          default_value: '',
        },
        {
          name: 'ranged_mousepointer',
          type: 'string',
          options: null,
          default_value: '',
        },
        {
          name: 'deactive_msg',
          type: 'string',
          options: null,
          default_value: '',
        },
        {
          name: 'active_msg',
          type: 'string',
          options: null,
          default_value: '',
        },
        {
          name: 'projectile_amount',
          type: 'int',
          options: null,
          default_value: 1,
        },
        {
          name: 'projectiles_per_fire',
          type: 'int',
          options: null,
          default_value: 1,
        },
        {
          name: 'projectile_var_overrides',
          type: 'list',
          options: null,
          default_value: [],
        }
      );
      break;
    case 'cone':
    case 'cone/staggered':
      ret = ret.filter(
        (variable) =>
          variable.name !== 'range' && variable.name !== 'selection_type'
      );
      ret.push(
        { name: 'cone_level', type: 'int', options: null, default_value: 3 },
        {
          name: 'respect_density',
          type: 'bool',
          options: null,
          default_value: false,
        }
      );
      break;
    case 'pointed':
      ret.push(
        { name: 'overlay', type: 'bool', options: null, default_value: false },
        {
          name: 'overlay_icon',
          type: 'string',
          options: null,
          default_value: '',
        },
        {
          name: 'overlay_icon_state',
          type: 'string',
          options: null,
          default_value: '',
        },
        {
          name: 'overlay_lifespan',
          type: 'int',
          options: null,
          default_value: 0,
        },
        {
          name: 'ranged_mousepointer',
          type: 'string',
          options: null,
          default_value: '',
        },
        {
          name: 'deactive_msg',
          type: 'string',
          options: null,
          default_value: '',
        },
        {
          name: 'active_msg',
          type: 'string',
          options: null,
          default_value: '',
        },
        {
          name: 'self_castable',
          type: 'bool',
          options: null,
          default_value: false,
        },
        { name: 'aim_assist', type: 'bool', options: null, default_value: true }
      );
      break;
    case 'targeted/touch':
      ret = ret.filter(
        (variable) =>
          variable.name !== 'range'
          && variable.name !== 'invocation_type'
          && variable.name !== 'selection_type'
      );
      ret.push(
        {
          name: 'drawmessage',
          type: 'string',
          options: null,
          default_value: '',
        },
        {
          name: 'dropmessage',
          type: 'string',
          options: null,
          default_value: '',
        },
        {
          name: 'hand_var_overrides',
          type: 'list',
          options: null,
          default_value: [],
        }
      );
      break;
    default:
      return [];
  }
  ret.push({
    name: 'scratchpad',
    type: 'list',
    options: null,
    default_value: [],
  });
  return ret;
};

export const SDQLSpellMenu = (props, context) => {
  const { act, data } = useBackend(context);
  const { type, types, alert } = data;

  return (
    <Window width={800} height={600}>
      <Window.Content>
        <Stack fill>
          <Stack.Item grow={1} basis={0}>
            <Stack fill vertical>
              <Stack.Item>
                <Dropdown
                  width="100%"
                  options={types}
                  displayText={type || 'Select a Spell Type'}
                  onSelected={(value) => act('type', { path: value })}
                />
              </Stack.Item>
              <Stack.Item grow={1} basis={0}>
                <SDQLSpellOptions />
              </Stack.Item>
              <Stack.Item>
                <Stack fill>
                  <Stack.Item>
                    <Button.Confirm
                      disabled={!type}
                      content="Confirm"
                      confirmContent="Are you sure?"
                      onClick={() => act('confirm')}
                    />
                    <Button
                      disabled={!type}
                      tooltip="Save the spell to a json file on your local system."
                      onClick={() => act('save')}>
                      Save Spell
                    </Button>
                    <Button
                      tooltip="Load a spell from a json file on your local system."
                      onClick={() => act('load')}>
                      Load Spell
                    </Button>
                  </Stack.Item>
                  <Stack.Item grow basis={0} />
                  <Stack.Item textColor="bad">{alert}</Stack.Item>
                </Stack>
              </Stack.Item>
            </Stack>
          </Stack.Item>
          <Stack.Item minWidth="128px">
            <SDQLSpellIcons />
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

/**
 * Used to determine whether or not to show a UI element corresponding to a
 * variable.
 * @param entry An object, from the list of objects returned by typevars(),
 * corresponding to the variable to be shown or hidden.
 * @param saved_vars The list of currently stored variable values.
 * @returns Whether or not to show the UI element corresponding to the variable
 * represented by the passed entry.
 */
const varCondition = (entry, saved_vars) => {
  switch (entry.name) {
    case 'charge_max':
      return saved_vars['charge_type'] !== 'holder_var';
    case 'holder_var_type':
    case 'holder_var_amount':
      return saved_vars['charge_type'] === 'holder_var';
    case 'human_req':
      return !saved_vars['clothes_req'];
    case 'invocation':
      return saved_vars['invocation_type'] !== 'none';
    case 'invocation_emote_self':
      return saved_vars['invocation_type'] === 'emote';
    case 'overlay_icon':
    case 'overlay_icon_state':
    case 'overlay_lifespan':
      return !!saved_vars['overlay'];
    case 'sparks_amt':
      return !!saved_vars['sparks_spread'];
    case 'smoke_amt':
      return !!saved_vars['smoke_spread'];
    case 'random_target_priority':
      return !!saved_vars['random_target'];
    default:
      return true;
  }
};

/**
 * A React component that wraps its contents in a tooltip object,
 * if one exists for the variable described by the object passed through the
 * entry property.
 *
 * @param entry An object, from the list of objects returned by typevars(),
 * corresponding to the variable whose tooltip is to be shown.
 */
const WrapInTooltip = (props, context) => {
  const { data } = useBackend(context);
  const { entry, children } = props;
  const { type, tooltips } = data;
  const tip = tooltips[entry.name]?.replace(
    '$type',
    tooltips[entry.name + '_' + type]
  );
  // TODO: Uncomment this block when tooltips no longer suck.
  if (tip) {
    return (
      <Tooltip position="bottom" content={tip}>
        {children}
      </Tooltip>
    );
  }
};

/**
 * A React component that contains a list of the meaningfully-editable variables
 * of the spell being edited.
 */
const SDQLSpellOptions = (props, context) => {
  const { data } = useBackend(context);
  const { type, saved_vars } = data;

  const vars = typevars(type);

  return (
    <Section fill scrollable>
      {vars
        .filter((entry) => varCondition(entry, saved_vars))
        .map((entry) => (
          <Stack key={entry.name} mb="6px">
            <Stack.Item>
              <WrapInTooltip entry={entry}>
                <Box inline bold color="label" mr="6px">
                  {entry.name}:
                </Box>
              </WrapInTooltip>
            </Stack.Item>
            <Stack.Item shrink basis="100%">
              <SDQLSpellInput entry={entry} />
            </Stack.Item>
          </Stack>
        ))}
    </Section>
  );
};

/**
 * A React component that contains the appropriate input element for the
 * variable described by the object passed through the entry property.
 * @param entry An object, from the list of objects returned by typevars(),
 * corresponding to the variable to provide an input element for.
 */
const SDQLSpellInput = (props, context) => {
  const { act, data } = useBackend(context);
  const { saved_vars } = data;
  const { entry } = props;
  const { name, type, options, default_value } = entry;
  switch (type) {
    case 'string':
      return (
        <Input
          width="100%"
          fluid
          value={saved_vars[name] ?? default_value}
          onChange={(e, value) => act('variable', { name, value })}
        />
      );
    case 'int':
      return (
        <NumberInput
          value={saved_vars[name] ?? default_value}
          onChange={(e, value) => act('variable', { name, value })}
        />
      );
    case 'bool':
      return (
        <Button.Checkbox
          checked={saved_vars[name] ?? default_value}
          onClick={() => act('bool_variable', { name })}
        />
      );
    case 'string_enum':
      return (
        <Dropdown
          options={options}
          displayText={saved_vars[name] ?? default_value}
          onSelected={(value) => act('variable', { name, value })}
        />
      );
    case 'int_enum':
      return (
        <Dropdown
          options={options}
          displayText={options[saved_vars[name]] ?? default_value}
          onSelected={(value) =>
            act('variable', { name, value: options.indexOf(value) })}
        />
      );
    case 'list':
      return <SDQLSpellListEntry list={name} />;
  }
};

/**
 * A React component containing the appropriate input fields for editing a list
 * variable.
 * @param {string} list The name of the list to show variables for.
 */
const SDQLSpellListEntry = (props, context) => {
  const { act, data } = useBackend(context);
  const { list_vars } = data;
  const { list } = props;
  return (
    <Collapsible>
      {Object.entries(list_vars[list]).map(([name, { type, value, flags }]) => (
        <Stack key={name} fill mb="6px">
          <Stack.Item grow>
            {
              // Can be renamed?
              (flags & 2) === 0 ? (
                <Input
                  value={name}
                  onChange={(e, value) =>
                    act('list_variable_rename', { list, name, new_name: value })}
                />
              ) : (
                <Box inline bold color="label" mr="6px">
                  {name}:
                </Box>
              )
            }
          </Stack.Item>
          <Stack.Item>
            {
              // Can type be changed?
              (flags & 1) === 0 && (
                <Dropdown
                  options={['num', 'bool', 'string', 'path', 'icon', 'list']}
                  displayText={type}
                  onSelected={(value) =>
                    act('list_variable_change_type', { list, name, value })}
                />
              )
            }
          </Stack.Item>
          <Stack.Item shrink basis="100%">
            <SDQLSpellListVarInput
              list={list}
              name={name}
              type={type}
              value={value}
            />
            <Button
              icon="minus-circle"
              color="red"
              title="remove"
              onClick={() => act('list_variable_remove', { list, name })}
            />
          </Stack.Item>
        </Stack>
      ))}
      <Button
        icon="plus-circle"
        color="blue"
        title="add variable"
        onClick={() => act('list_variable_add', { list })}
      />
    </Collapsible>
  );
};

/**
 * A React component that contains the appropriate input element for the
 * variable of a given name and type within a list.
 * @param list The name of the list containing the variable
 * @param name The name of the variable
 * @param type The type of the variable
 * @param value The current value of the variable
 */
const SDQLSpellListVarInput = (props, context) => {
  const { act } = useBackend(context);
  const { list, name, type, value } = props;
  switch (type) {
    case 'num':
      return (
        <NumberInput
          value={value}
          onChange={(e, value) =>
            act('list_variable_change_value', { list, name, value })}
        />
      );
    case 'bool':
      return (
        <Button.Checkbox
          checked={value === 1}
          onClick={() => act('list_variable_change_bool', { list, name })}
        />
      );
    case 'string':
    case 'path':
    case 'icon':
      return (
        <Input
          width="75%"
          fluid
          value={value}
          onChange={(e, value) =>
            act('list_variable_change_value', { list, name, value })}
        />
      );
    case 'list':
      return <SDQLSpellListEntry list={list + '/' + name} />;
    default:
      return (
        <Box bold textColor="bad">
          {"You shouldn't be seeing this!"}
        </Box>
      );
  }
};

const SDQLSpellIcons = (props, context) => {
  const { data } = useBackend(context);
  const {
    saved_vars,
    type,
    action_icon,
    hand_icon,
    projectile_icon,
    overlay_icon,
    mouse_icon,
  } = data;

  const vars = typevars(type);

  return (
    <Section fill>
      <Stack vertical>
        {type && (
          <Section title="Action Button Icon">
            <Box
              as="img"
              height="64px"
              width="auto"
              m={0}
              src={`data:image/jpeg;base64,${action_icon}`}
              style={{
                '-ms-interpolation-mode': 'nearest-neighbor',
              }}
            />
          </Section>
        )}
        {type === 'targeted/touch' && (
          <Section title="Touch Attack Icon">
            <Box
              as="img"
              height="64px"
              width="auto"
              m={0}
              src={`data:image/jpeg;base64,${hand_icon}`}
              style={{
                '-ms-interpolation-mode': 'nearest-neighbor',
              }}
            />
          </Section>
        )}
        {type === 'aimed' && (
          <Section title="Projectile Icon">
            <Box
              as="img"
              height="64px"
              width="auto"
              m={0}
              src={`data:image/jpeg;base64,${projectile_icon}`}
              style={{
                '-ms-interpolation-mode': 'nearest-neighbor',
              }}
            />
          </Section>
        )}
        {type
          && vars.some((entry) => entry.name === 'ranged_mousepointer')
          && saved_vars['ranged_mousepointer'] && (
          <Section title="Mouse Cursor">
            <Box
              as="img"
              height="64px"
              width="auto"
              m={0}
              src={`data:image/jpeg;base64,${mouse_icon}`}
              style={{
                '-ms-interpolation-mode': 'nearest-neighbor',
              }}
            />
          </Section>
        )}
        {type && 'overlay' in saved_vars && saved_vars['overlay'] === 1 && (
          <Section title="Overlay Icon">
            <Box
              as="img"
              height="64px"
              width="auto"
              m={0}
              src={`data:image/jpeg;base64,${overlay_icon}`}
              style={{
                '-ms-interpolation-mode': 'nearest-neighbor',
              }}
            />
          </Section>
        )}
      </Stack>
    </Section>
  );
};
