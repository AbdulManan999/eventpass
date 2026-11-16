CREATE TABLE users (
  id            uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  email         text NOT NULL UNIQUE CHECK (email = lower(email)),
  password_hash text NOT NULL,
  name          text NOT NULL,
  role          text NOT NULL CHECK (role IN ('attendee', 'organizer')),
  created_at    timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE events (
  id                    uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  organizer_id          uuid NOT NULL REFERENCES users(id),
  title                 text NOT NULL,
  venue_name            text NOT NULL,
  latitude              double precision NOT NULL,
  longitude             double precision NOT NULL,
  geofence_radius_m     integer NOT NULL CHECK (geofence_radius_m > 0),
  starts_at             timestamptz NOT NULL,
  ends_at               timestamptz NOT NULL CHECK (ends_at > starts_at),
  capacity              integer NOT NULL CHECK (capacity > 0),
  -- Ed25519 key pair per event. The public key goes to scanner devices so they
  -- can verify tickets offline; the private key is AES-GCM encrypted at rest.
  public_key            text NOT NULL,
  private_key_encrypted text NOT NULL,
  created_at            timestamptz NOT NULL DEFAULT now()
);

CREATE TABLE event_staff (
  event_id uuid NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  user_id  uuid NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  PRIMARY KEY (event_id, user_id)
);

CREATE TABLE tickets (
  id         uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  event_id   uuid NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  user_id    uuid NOT NULL REFERENCES users(id),
  status     text NOT NULL DEFAULT 'valid' CHECK (status IN ('valid', 'revoked')),
  issued_at  timestamptz NOT NULL DEFAULT now(),
  UNIQUE (event_id, user_id)
);

-- One row per scan made on a device. The id is generated on the device, so a
-- scan that is synced twice (e.g. after a dropped connection) is stored once.
CREATE TABLE scans (
  id          uuid PRIMARY KEY,
  event_id    uuid NOT NULL REFERENCES events(id) ON DELETE CASCADE,
  ticket_id   uuid REFERENCES tickets(id) ON DELETE CASCADE,
  scanned_by  uuid NOT NULL REFERENCES users(id),
  device_id   text NOT NULL,
  scanned_at  timestamptz NOT NULL,
  synced_at   timestamptz NOT NULL DEFAULT now(),
  result      text NOT NULL CHECK (result IN ('accepted', 'duplicate', 'revoked', 'invalid'))
);

-- At most one accepted scan per ticket: the first one synced wins.
CREATE UNIQUE INDEX scans_one_accepted_per_ticket ON scans (ticket_id) WHERE result = 'accepted';
CREATE INDEX scans_event_idx ON scans (event_id, scanned_at);
