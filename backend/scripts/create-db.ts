import 'dotenv/config';
import pg from 'pg';

// Creates the databases named in DATABASE_URL and DATABASE_URL_TEST if they
// don't exist yet, by connecting to the server's default `postgres` database.

const urls = [process.env.DATABASE_URL, process.env.DATABASE_URL_TEST].filter((u): u is string => !!u);
if (urls.length === 0) {
  console.error('Set DATABASE_URL in backend/.env first');
  process.exit(1);
}

for (const url of urls) {
  const target = new URL(url);
  const name = decodeURIComponent(target.pathname.slice(1));
  const server = new URL(url);
  server.pathname = '/postgres';

  const client = new pg.Client({ connectionString: server.toString() });
  try {
    await client.connect();
    const { rowCount } = await client.query('SELECT 1 FROM pg_database WHERE datname = $1', [name]);
    if (rowCount) {
      console.log(`database "${name}" already exists`);
    } else {
      await client.query(`CREATE DATABASE "${name.replaceAll('"', '""')}"`);
      console.log(`created database "${name}"`);
    }
  } catch (err) {
    console.error(`Could not set up "${name}": ${(err as Error).message}`);
    process.exitCode = 1;
  } finally {
    await client.end();
  }
}
