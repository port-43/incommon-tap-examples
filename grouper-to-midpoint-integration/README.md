# Grouper to Midpoint Integration
## Overview
The files in this directory outline the configuration required to integrate Grouper group membership with Midpoint. This configuration is a custom implementation and may or may not fit your use cases.

## Configuration
### Database Configuration
The implementation makes use of a Postgres table, a couple functions for timestamp handing and a view for aggregating the groups into one field. The sql to create the required elements can be found in the [grouper-outbound-table.sql](sql/grouper-outbound-table.sql) file. The overall structure is outlined below:
- `grouper_to_midpoint`: Database table for Grouper to provision the `subject_id` and group name
- `grouper_to_midpoint_view`: Database view that aggregates all of a users groups into one field based on the subject_id with a `last_updat`e timestamp for livesync. The `last_update` timestamp uses the most recent date associated with the `subject_id`.

Example record from `grouper_to_midpoint`:
| subject_id | group_name | lastupdate_timestamp | created_timestamp |
| ---------- | ----- | ----------- | ----------- |
| 1000 | group1| 2024-05-15 13:01:10.611317 -05:00 | 2024-05-15 13:01:10.611317 -05:00 |
| 1000 | group12| 2024-05-15 13:01:10.611317 -05:00 | 2024-05-15 13:01:10.611317 -05:00 |
| 1000 | group3| 2024-05-15 13:01:10.611317 -05:00 | 2024-05-15 13:01:10.611317 -05:00 |

Example record from `grouper_to_midpoint_view`:
| subject_id | roles | last_update |
| ---------- | ----- | ----------- |
| 1000 | group1\|group2\|group3 | 2024-05-15 13:01:10.611317 -05:00 |

When records are deleted from `grouper_to_midpoint` the `lastupdate_timestamp` is updated on all other records associated with that `subject_id`. This is needed to ensure Midpoint evaluates the record again during livesync.

### Midpoint Configuration
The Midpoint configuration consists of a couple standard objects. The first being the `grouper-to-midpoint` database resource. It's configured to connect to the `grouper_to_midpoint_view` with the `subject_id` being the key column.

Additionally, there is an inbound mapping that performs an assignmentTargetSearch across orgs with a subtype of Grouper (in 4.8+ this will need to be migrated to using archetypes). The `set` condition ensures that it only operates on groups with the relevant subtype.

Lastly, there is an example org that can be used to test out the integration and a livesync task that uses `last_update` to query for updated records.

All of the files listed can be found in the [midpoint](midpoint/) directory.

### Grouper Configuration
TBD
