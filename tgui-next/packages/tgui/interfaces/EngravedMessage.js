import { decodeHtmlEntities } from 'common/string';
import { Fragment } from 'inferno';
import { act } from '../byond';
import { Box, Button, LabeledList, Section, Grid } from '../components';

export const EngravedMessage = props => {
  const { state } = props;
  const { config, data } = state;
  const { ref } = config;
  const {
    admin_mode,
    creator_key,
    creator_name,
    has_liked,
    has_disliked,
    hidden_message,
    is_creator,
    num_likes,
    num_dislikes,
    realdate,
  } = data;
  return (
    <Fragment>
      <Section>
        <Box
          bold
          textAlign="center"
          fontSize="20px"
          mb={2}
        >
          {decodeHtmlEntities(hidden_message)}
        </Box>
        <Grid>
          <Grid.Column>
            <Button
              fluid
              icon="arrow-up"
              content={" " + num_likes}
              disabled={is_creator}
              selected={has_liked}
              textAlign="center"
              fontSize="16px"
              lineHeight="24px"
              onClick={() => act(ref, "like")}
            />
          </Grid.Column>
          <Grid.Column>
            <Button
              fluid
              icon="circle"
              disabled={is_creator}
              selected={!has_disliked && !has_liked}
              textAlign="center"
              fontSize="16px"
              lineHeight="24px"
              onClick={() => act(ref, "neutral")}
            />
          </Grid.Column>
          <Grid.Column>
            <Button
              fluid
              icon="arrow-down"
              content={" " + num_dislikes}
              disabled={is_creator}
              selected={has_disliked}
              textAlign="center"
              fontSize="16px"
              lineHeight="24px"
              onClick={() => act(ref, "dislike")}
            />
          </Grid.Column>
        </Grid>
      </Section>
      <Section>
        <LabeledList>
          <LabeledList.Item label="Created On">
            {realdate}
          </LabeledList.Item>
        </LabeledList>
      </Section>
      <Section />
      {!!admin_mode && (
        <Section
          title="Admin Panel"
          buttons={(
            <Button
              icon="times"
              content="Delete"
              color="bad"
              onClick={() => act(ref, "delete")}
            />
          )}
        >
          <LabeledList>
            <LabeledList.Item label="Creator Ckey">
              {creator_key}
            </LabeledList.Item>
            <LabeledList.Item label="Creator Character Name">
              {creator_name}
            </LabeledList.Item>
          </LabeledList>
        </Section>
      )}
    </Fragment>
  );
};
