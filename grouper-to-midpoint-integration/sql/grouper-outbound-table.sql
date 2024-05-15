/*
 grouper to midpoint table
 */
create table public.grouper_to_midpoint
(
    subject_id           varchar(255),
    group_name           varchar(255),
    created_timestamp    timestamp with time zone default now() not null,
    lastupdate_timestamp timestamp with time zone default now() not null
);

-- function to update timestamps on delete
create function public.update_modified_on_delete() returns trigger
    language plpgsql
as
$$
begin
    update grouper_to_midpoint set lastupdate_timestamp = now()
    where subject_id  = old.subject_id;
    RETURN OLD;
END;
$$;

-- function to update timestamps on modifications
create function public.update_updated_at_column() returns trigger
    language plpgsql
as
$$
  BEGIN
    NEW.lastupdate_timestamp = NOW();
    RETURN NEW;
  END;
$$;

create trigger t1_updated_at_modtime
    before update
    on public.grouper_to_midpoint
    for each row
execute procedure public.update_updated_at_column();

create trigger t1_updated_at_inserttime
    before insert
    on public.grouper_to_midpoint
    for each row
execute procedure public.update_updated_at_column();

create trigger update_modified_on_delete
    after delete
    on public.grouper_to_midpoint
    for each row
execute procedure public.update_modified_on_delete();


/*
grouper to midpoint view
 */
create view public.grouper_to_midpoint_view(subject_id, roles, last_update) as
SELECT grouper_to_midpoint.subject_id,
       string_agg(grouper_to_midpoint.group_name::text, '|'::text) AS roles,
       max(grouper_to_midpoint.lastupdate_timestamp)               AS last_update
FROM grouper_to_midpoint
GROUP BY grouper_to_midpoint.subject_id;
