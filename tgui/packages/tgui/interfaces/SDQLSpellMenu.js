import { useBackend } from '../backend';
import { Box, Button, Collapsible, Dropdown, Icon, Input, Modal, NumberInput, Section, Stack, Tooltip} from '../components';
import { Window } from '../layouts';

const typevars = type => {
    var ret = [{ name: "name", type: "string", options: null, default: "" },
    { name: "desc", type: "string", options: null, default: "" },
    { name: "query", type: "string", options: null, default: "" },
    { name: "action_icon", type: "string", options: null, default: "" },
    { name: "action_icon_state", type: "string", options: null, default: "" },
    { name: "action_background_icon_state", type: "string", options: null, default: "" },
    { name: "sound", type: "string", options: null, default: "" },
    { name: "charge_type", type: "string_enum", options: ["recharge", "charges", "holder_var"], default: "recharge" },
    { name: "charge_max", type: "int", options: null, default: 100 },
    { name: "still_recharging_message", type: "string", options: null, default: "" },
    { name: "holder_var_type", type: "string", options: null, default: "" },
    { name: "holder_var_amount", type: "int", options: null, default: "" },
    { name: "clothes_req", type: "bool", options: null, default: false },
    { name: "cult_req", type: "bool", options: null, default: false },
    { name: "human_req", type: "bool", options: null, default: false },
    { name: "nonabstract_req", type: "bool", options: null, default: false },
    { name: "stat_allowed", type: "bool", options: null, default: false },
    { name: "phase_allowed", type: "bool", options: null, default: false },
    { name: "antimagic_allowed", type: "bool", options: null, default: false },
    { name: "invocation_type", type: "string_enum", options: ["none", "whisper", "emote", "shout"], default: "none" },
    { name: "invocation", type: "string", options: null, default: "" },
    { name: "invocation_emote_self", type: "string", options: null, default: "" },
    { name: "selection_type", type: "string_enum", options: ["view", "range"], default: "view" },
    { name: "range", type: "int", options: null, default: 7 },
    { name: "message", type: "string", options: null, default: "" },
    { name: "player_lock", type: "bool", options: null, default: true },
    { name: "sparks_spread", type: "bool", options: null, default: false },
    { name: "sparks_amt", type: "int", options: null, default: 0 },
    { name: "smoke_spread", type: "int_enum", options: ["none", "harmless", "harmful", "sleeping"], default: "none" },
    { name: "smoke_amt", type: "int", options: null, default: 0 },
    { name: "centcom_cancast", type: "bool", options: null, default: false }
];
    switch(type) {
        case "targeted":
            ret.push({ name: "overlay", type: "bool", options: null, default: false },
            { name: "overlay_icon", type: "string", options: null, default: "" },
            { name: "overlay_icon_state", type: "string", options: null, default: "" },
            { name: "overlay_lifespan", type: "int", options: null, default: 0 },
            { name: "max_targets", type: "int", options: null, default: false },
            { name: "target_ignore_prev", type: "bool", options: null, default: true },
            { name: "include_user", type: "bool", options: null, default: false },
            { name: "random_target", type: "bool", options: null, default: false },
            { name: "random_target_priority", type: "int_enum", options: ["closest", "random"], default: "closest" });
            break;
        case "aoe_turf":
            ret = ret.filter(variable => variable.name != "selection_type");
            ret.push({ name: "inner_radius", type: "int", options: null, default: -1 },
            { name: "overlay", type: "bool", options: null, default: false },
            { name: "overlay_icon", type: "string", options: null, default: "" },
            { name: "overlay_icon_state", type: "string", options: null, default: "" },
            { name: "overlay_lifespan", type: "int", options: null, default: 0 });
            break;
        case "self":
            ret = ret.filter(variable => variable.name != "range" && variable.name != "selection_type");
            break;
        case "aimed":
            ret.push({ name: "base_icon_state", type: "string", options: null, default: "" },
            { name: "ranged_mousepointer", type: "string", options: null, default: "" },
            { name: "deactive_msg", type: "string", options: null, default: "" },
            { name: "active_msg", type: "string", options: null, default: "" },
            { name: "projectile_amount", type: "int", options: null, default: 1 },
            { name: "projectiles_per_fire", type: "int", options: null, default: 1 },
            { name: "projectile_var_overrides", type: "list", options: null, default: []});
            break;
        case "cone":
        case "cone/staggered":
            ret = ret.filter(variable => variable.name != "range" && variable.name != "selection_type");
            ret.push({ name: "cone_level", type: "int", options: null, default: 3 },
            { name: "respect_density", type: "bool", options: null, default: false });
            break;
        case "pointed":
            ret.push({ name: "overlay", type: "bool", options: null, default: false },
            { name: "overlay_icon", type: "string", options: null, default: "" },
            { name: "overlay_icon_state", type: "string", options: null, default: "" },
            { name: "overlay_lifespan", type: "int", options: null, default: 0 },
            { name: "ranged_mousepointer", type: "string", options: null, default: "" },
            { name: "deactive_msg", type: "string", options: null, default: "" },
            { name: "active_msg", type: "string", options: null, default: "" },
            { name: "self_castable", type: "bool", options: null, default: false },
            { name: "aim_assist", type: "bool", options: null, default: true});
            break;
        case "targeted/touch":
            ret = ret.filter(variable => variable.name != "range" && variable.name != "invocation_type" && variable.name != "selection_type");
            ret.push({ name: "drawmessage", type: "string", options: null, default: "" },
            { name: "dropmessage", type: "string", options: null, default: "" },
            { name: "hand_var_overrides", type: "list", options: null, default: []});
            break;
        default:
            return [];
    }
    ret.push({ name: "scratchpad", type: "list", options: null, default: [] });
    return(ret);
};

export const SDQLSpellMenu = (props, context) => {
    const { act, data } = useBackend(context);
    const {
        type,
        types,
        saved_spell_count,
        alert
    } = data;

    return (
        <Window
        width={800}
        height={600}>
            <Window.Content>
                <Stack fill>
                    <Stack.Item grow={1} basis={0}>
                        <Stack fill vertical>
                            <Stack.Item>
                                <Dropdown
                                width="100%"
                                options={types}
                                displayText={type || "Select a Spell Type"}
                                onSelected={value => act('type', { path: value })}
                                />
                            </Stack.Item>
                            <Stack.Item grow={1} basis={0}>
                                <SDQLSpellOptions/>
                            </Stack.Item>
                            <Stack.Item>
                                <Stack fill>
                                    <Stack.Item>
                                        <Button.Confirm
                                        disabled={!type}
                                        content="Confirm"
                                        confirmContent="Are you sure?"
                                        onClick={() => act('confirm')}/>
                                        <Button.Confirm
                                        disabled={!type}
                                        content="Save"
                                        confirmContent="Are you sure?"
                                        onClick={() => act('save')}/>
                                        <Button
                                        disabled={saved_spell_count == 0}
                                        onClick={() => act('load')}>
                                            Load Spell
                                        </Button>
                                    </Stack.Item>
                                    <Stack.Item grow basis={0}/>
                                    <Stack.Item textColor="bad">
                                        {alert}
                                    </Stack.Item>
                                </Stack>
                            </Stack.Item>
                        </Stack>
                    </Stack.Item>
                    <Stack.Item minWidth="128px">
                        <SDQLSpellIcons/>
                    </Stack.Item>
                </Stack>
            </Window.Content>      
        </Window>
    );
};

const var_condition = (entry, context) => {
    const { data } = useBackend(context);
    const {
        saved_vars
    } = data;
    switch(entry.name) {
        case "charge_max":
            return (saved_vars.hasOwnProperty("charge_type") && saved_vars["charge_type"]) != "holder_var";
        case "holder_var_type":
        case "holder_var_amount":
            return (saved_vars.hasOwnProperty("charge_type") && saved_vars["charge_type"]) == "holder_var";
        case "human_req":
            return (saved_vars.hasOwnProperty("clothes_req") && !saved_vars["clothes_req"]);
        case "invocation":
            return (saved_vars.hasOwnProperty("invocation_type") && saved_vars["invocation_type"]) != "none";
        case "invocation_emote_self":
            return (saved_vars.hasOwnProperty("invocation_type") && saved_vars["invocation_type"]) == "emote";
        case "overlay_icon":
        case "overlay_icon_state":
        case "overlay_lifespan":
            return (saved_vars.hasOwnProperty("overlay") && saved_vars["overlay"]);
        case "sparks_amt":
            return (saved_vars.hasOwnProperty("sparks_spread") && saved_vars["sparks_spread"]);
        case "smoke_amt":
            return (saved_vars.hasOwnProperty("smoke_spread") && saved_vars["smoke_spread"]);
        case "random_target_priority":
            return (saved_vars.hasOwnProperty("random_target") && saved_vars["random_target"]);
        default:
            return true;
    }
}

const WrapInTooltip = (props, context) => {
    const { data } = useBackend(context);
    const { entry } = props
    const {
        type,
        tooltips
    } = data;
    var tip = tooltips[entry.name]?.replace("$type", tooltips[(entry.name+"_"+type) || "Something went wrong."]);
    return (tip ? (
        <Tooltip
            position="bottom"
            content={tip}>
                {props.children}
        </Tooltip>
    ) : props.children)
}

const SDQLSpellOptions = (props, context) => {
    const { data } = useBackend(context);
    const {
        type
    } = data;

    const vars = typevars(type);

    return (
        <Section fill scrollable>
            {vars.filter(entry => var_condition(entry, context)).map(entry => (
                <Stack mb="6px">
                    <Stack.Item>
                        <WrapInTooltip entry={entry}>
                            <Box inline bold color="label" mr="6px">
                                {entry.name}:
                            </Box>
                        </WrapInTooltip>
                    </Stack.Item>
                    <Stack.Item shrink basis="100%">
                        <SDQLSpellOption entry={entry}/>
                    </Stack.Item>
                </Stack>
                ))}
        </Section>
    );
};

const SDQLSpellOption = (props, context) => {
    const { act, data } = useBackend(context);
    const {
        saved_vars
    } = data;
    const {
        entry
    } = props;
    switch(entry.type) {
        case "string":
            return (
                <Input
                width="100%"
                fluid
                value={(saved_vars.hasOwnProperty(entry.name) && saved_vars[entry.name]) ?? entry.default}
                onChange={(e, value) => act('variable', { name: entry.name, value: value })}/>
            );
        case "int":
            return (
                <NumberInput
                value={(saved_vars.hasOwnProperty(entry.name) && saved_vars[entry.name]) ?? entry.default}
                onChange={(e, value) => act('variable', { name: entry.name, value: value })}/>
            );
        case "bool":
            return (
                <Button.Checkbox
                checked={(saved_vars.hasOwnProperty(entry.name) && saved_vars[entry.name]) ?? entry.default}
                onClick={() => act('bool_variable', { name: entry.name })}/>
            );
        case "string_enum":
            return (
                <Dropdown
                options={entry.options}
                displayText={(saved_vars.hasOwnProperty(entry.name) && saved_vars[entry.name]) ?? entry.default}
                onSelected={value => act('variable', { name: entry.name, value: value })}/>
            );
        case "int_enum":
            return (
                <Dropdown
                options={entry.options}
                displayText={entry.options[(saved_vars.hasOwnProperty(entry.name) && saved_vars[entry.name])] ?? entry.default}
                onSelected={value => act('variable', { name: entry.name, value: entry.options.indexOf(value) })}/>
            );
        case "list":
            return (
              <SDQLSpellListEntry list={entry.name}/>
            );
    }
}

const SDQLSpellListEntry = (props, context) => {
    const { act, data } = useBackend(context);
    const {
        list_vars
    } = data;
    const {
        list
    } = props;
    return (
        <Collapsible>
            {list_vars.hasOwnProperty(list) && Object.entries(list_vars[list]).map(entry => (
                <Stack fill mb="6px">
                    <Stack.Item grow>
                        {((entry[1].flags & 2) == 0) ? (
                            <Input
                            value={entry[0]}
                            onChange={(e, value) => act('list_variable_rename', { list: list, name: entry[0], new_name: value })}/>)
                        : (
                            <Box inline bold color="label" mr="6px">
                                {entry[0]}:
                            </Box>)}
                    </Stack.Item>
                    <Stack.Item>
                        {((entry[1].flags & 1) == 0) && (
                            <Dropdown
                            options={["num","bool","string","path","list"]}
                            displayText={entry[1].type}
                            onSelected={value => act('list_variable_change_type', { list: list, name: entry[0], value: value })}/>)}
                    </Stack.Item>
                    <Stack.Item shrink basis="100%">
                        <SDQLSpellListVar list={list} entry={entry}/>
                        <Button
                        icon="minus-circle"
                        color="red"
                        title="remove"
                        onClick={() => act('list_variable_remove', { list: list, name: entry[0] })}/>
                    </Stack.Item>
                </Stack>
            ))}
            <Button
            icon="plus-circle"
            color="blue"
            title="add variable"
            onClick={() => act('list_variable_add', { list: list })}/>
        </Collapsible>
    );
};

const SDQLSpellListVar = (props, context) => {
    const { act } = useBackend(context);
    const {
        list,
        entry
    } = props;
    switch(entry[1].type) {
        case "num":
            return (
                <NumberInput
                value={entry[1].value}
                onChange={(e, value) => act('list_variable_change_value', { list: list, name: entry[0], value: value })}/>
            );
        case "bool":
            return (
                <Button.Checkbox
                checked={entry[1].value == 1}
                onClick={() => act('list_variable_change_bool', { list: list, name: entry[0] })}/>
            );
        case "string":
        case "path":
        case "icon":
            return (
                <Input
                width="75%"
                fluid
                value={entry[1].value}
                onChange={(e, value) => act('list_variable_change_value', { list: list, name: entry[0], value: value })}/>
            );
        case "list":
            return (
                <SDQLSpellListEntry list={list+"/"+entry[0]}/>
            );
        default:
            return (
                <Box bold color="bad">
                    You shouldn't be seeing this!
                </Box>
            )
    }
}

const SDQLSpellIcons = (props, context) => {
    const { data } = useBackend(context);
    const {
        saved_vars,
        type,
        action_icon,
        hand_icon,
        projectile_icon,
        overlay_icon,
        mouse_icon
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
                        }} />
                    </Section>
                )}
                {type === "targeted/touch" && (
                    <Section title="Touch Attack Icon">
                        <Box
                        as="img"
                        height="64px"
                        width="auto"
                        m={0}
                        src={`data:image/jpeg;base64,${hand_icon}`}
                        style={{
                            '-ms-interpolation-mode': 'nearest-neighbor',
                        }} />
                    </Section>
                )}
                {type === "aimed" && (
                    <Section title="Projectile Icon">
                        <Box
                        as="img"
                        height="64px"
                        width="auto"
                        m={0}
                        src={`data:image/jpeg;base64,${projectile_icon}`}
                        style={{
                        '-ms-interpolation-mode': 'nearest-neighbor',
                        }} />
                    </Section>
                )}
                {(type && vars.some(entry => entry.name == "ranged_mousepointer") && saved_vars["ranged_mousepointer"]) && (
                    <Section title="Mouse Cursor">
                        <Box
                        as="img"
                        height="64px"
                        width="auto"
                        m={0}
                        src={`data:image/jpeg;base64,${mouse_icon}`}
                        style={{
                        '-ms-interpolation-mode': 'nearest-neighbor',
                        }} />
                    </Section>
                )}
                {(type && (saved_vars.hasOwnProperty("overlay") && saved_vars["overlay"] == 1)) && (
                    <Section title="Overlay Icon">
                        <Box
                        as="img"
                        height="64"
                        width="auto"
                        m={0}
                        src={`data:image/jpeg;base64,${overlay_icon}`}
                        style={{
                        '-ms-interpolation-mode': 'nearest-neighbor',
                        }} />
                    </Section>
                )}
            </Stack>
        </Section>
    );
};