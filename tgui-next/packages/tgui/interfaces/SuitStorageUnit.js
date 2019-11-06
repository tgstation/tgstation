import { Fragment } from 'inferno';
import { act } from '../byond';
import { Box, Button, LabeledList, Section, NoticeBox, Icon } from '../components';

export const SuitStorageUnit = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const {
    locked,
    open,
    safeties,
    uv_active,
    occupied,
    suit,
    helmet,
    mask,
    storage,
  } = data;
  return (
    <Fragment>
      {(!!occupied && !!safeties) && (
        <NoticeBox>
          Biological entity detected in suit chamber. Please remove before continuing with operation.
        </NoticeBox>
      )}
      {uv_active ? (
        <NoticeBox>
          Contents are currently being decontaminated. Please wait.
        </NoticeBox>
      ) : (
        <Section
          title="Storage"
          minHeight="260px"
          buttons={(
            <Fragment>
              {!open && (
                <Button
                  icon={locked ? "unlock" : "lock"}
                  content={locked ? "Unlock" : "Lock"}
                  onClick={() => act(ref, "lock")}
                />
              )}
              {!locked && (
                <Button
                  icon={open ? "sign-out-alt" : "sign-in-alt"}
                  content={open ? "Close" : "Open"}
                  onClick={() => act(ref, "door")}
                />
              )}
            </Fragment>
          )}
        >
          {locked ? (
            <Box
              mt={6}
              bold
              textAlign="center"
              fontSize="40px"
            >
              Unit Locked<br />
              <Icon
                name="lock"
              />
            </Box>
          ) : (
            open ? (
              <LabeledList>
                <LabeledList.Item label="Helmet">
                  <Button
                    icon={helmet ? "square" : "square-o"}
                    content={helmet || "Empty"}
                    disabled={!helmet}
                    onClick={() => act(ref, "dispense", {item: "helmet"})}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Suit">
                  <Button
                    icon={suit ? "square" : "square-o"}
                    content={suit || "Empty"}
                    disabled={!suit}
                    onClick={() => act(ref, "dispense", {item: "suit"})}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Mask">
                  <Button
                    icon={mask ? "square" : "square-o"}
                    content={mask || "Empty"}
                    disabled={!mask}
                    onClick={() => act(ref, "dispense", {item: "mask"})}
                  />
                </LabeledList.Item>
                <LabeledList.Item label="Storage">
                  <Button
                    icon={storage ? "square" : "square-o"}
                    content={storage || "Empty"}
                    disabled={!storage}
                    onClick={() => act(ref, "dispense", {item: "storage"})}
                  />
                </LabeledList.Item>
              </LabeledList>
            ) : (
              <Button
                fluid
                icon="recycle"
                content="Decontaminate"
                disabled={occupied && safeties}
                textAlign="center"
                onClick={() => act(ref, "uv")}
              />
            )
          )}
        </Section>
      )}
    </Fragment>
  );
};
