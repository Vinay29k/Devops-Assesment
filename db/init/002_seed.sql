-- 002_seed.sql
-- Seeds ~150 hotel_bookings spread over the last 90 days across 4 orgs,
-- 5 cities, and 4 statuses, with booking_events for most of them.

DO $$
DECLARE
    v_org_ids      UUID[] := ARRAY[gen_random_uuid(), gen_random_uuid(), gen_random_uuid(), gen_random_uuid()];
    v_cities       TEXT[] := ARRAY['delhi', 'mumbai', 'bangalore', 'goa', 'jaipur'];
    v_statuses     TEXT[] := ARRAY['confirmed', 'cancelled', 'completed', 'pending'];
    v_event_types  TEXT[] := ARRAY['created', 'payment_received', 'checked_in', 'checked_out', 'cancelled'];
    v_booking_id   UUID;
    v_num_bookings INT := 150;
    v_num_events   INT;
BEGIN
    FOR i IN 1..v_num_bookings LOOP
        v_booking_id := gen_random_uuid();

        INSERT INTO hotel_bookings (
            id, org_id, hotel_id, city, checkin_date, checkout_date,
            amount, status, created_at
        ) VALUES (
            v_booking_id,
            v_org_ids[1 + floor(random() * array_length(v_org_ids, 1))::int],
            'HTL-' || lpad((1 + floor(random() * 40))::text, 4, '0'),
            v_cities[1 + floor(random() * array_length(v_cities, 1))::int],
            CURRENT_DATE - (floor(random() * 90))::int,
            CURRENT_DATE - (floor(random() * 90))::int + (1 + floor(random() * 5))::int,
            round((500 + random() * 15000)::numeric, 2),
            v_statuses[1 + floor(random() * array_length(v_statuses, 1))::int],
            now() - (random() * interval '90 days')
        );

        -- ~70% of bookings get 1-3 lifecycle events
        IF random() < 0.7 THEN
            v_num_events := 1 + floor(random() * 3)::int;
            FOR j IN 1..v_num_events LOOP
                INSERT INTO booking_events (booking_id, event_type, payload, created_at)
                VALUES (
                    v_booking_id,
                    v_event_types[1 + floor(random() * array_length(v_event_types, 1))::int],
                    jsonb_build_object('source', 'seed', 'sequence', j),
                    now() - (random() * interval '90 days')
                );
            END LOOP;
        END IF;
    END LOOP;
END $$;
