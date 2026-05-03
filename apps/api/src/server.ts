import "dotenv/config";
import Fastify from "fastify";
import cors from "@fastify/cors";

const app = Fastify({ logger: true });

await app.register(cors, { origin: true });

app.get("/health", async () => ({
  status: "ok",
  service: "guestmemories-api",
  time: new Date().toISOString(),
}));

const port = Number(process.env.API_PORT ?? 4000);
const host = process.env.API_HOST ?? "0.0.0.0";

await app.listen({ port, host });
