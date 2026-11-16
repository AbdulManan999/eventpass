// Shared test data.

/// Signed by the Node backend (backend/src/lib/ticket-token.ts), so this test
/// proves the phone and the server agree on the token format and signature.
const nodePublicKeyPem = '-----BEGIN PUBLIC KEY-----\n'
    'MCowBQYDK2VwAyEAHL0zYeiXqpQKdOCy5s4r2UcAV/Ffpv/tc+jGtzx2m38=\n'
    '-----END PUBLIC KEY-----\n';
const nodeToken =
    'EP1.eyJ0aWQiOiI2ZjFjMmE1NC0zZDdlLTRiOGEtOWMxZi0yZTVkOGE3YjRjM2QiLCJlaWQiOiJhMWIyYzNkNC1lNWY2LTRhN2ItOGM5ZC0wZTFmMmEzYjRjNWQiLCJuYW1lIjoiQXllc2hhIEtoYW4iLCJpYXQiOjE3NjMyOTAwMDB9'
    '.rRIbSirCePhb9VveBskQw6jPlekZBAw3798JdZZwAdN_HTkvH0C0AxzEh0wLGG7jfL8aAfJkqDwzuZoymVU8BQ';

/// The same claims signed with a different event's key.
const foreignToken =
    'EP1.eyJ0aWQiOiI2ZjFjMmE1NC0zZDdlLTRiOGEtOWMxZi0yZTVkOGE3YjRjM2QiLCJlaWQiOiJhMWIyYzNkNC1lNWY2LTRhN2ItOGM5ZC0wZTFmMmEzYjRjNWQiLCJuYW1lIjoiQXllc2hhIEtoYW4iLCJpYXQiOjE3NjMyOTAwMDB9'
    '.XTd-9NGWcGGPAvBTlSx0u5cBnS1k4HSwwi7PMqUDFEZEuuNoqt13qv2KRBSxKAFYsh-ij3iXfWeTTElU4Nj3Bw';

const eventId = 'a1b2c3d4-e5f6-4a7b-8c9d-0e1f2a3b4c5d';
const ticketId = '6f1c2a54-3d7e-4b8a-9c1f-2e5d8a7b4c3d';
