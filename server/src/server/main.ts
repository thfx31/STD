import express from "express";
import ViteExpress from "vite-express";
import { createServer } from "http";
import { env } from "./utils/envalid.js";
import { createRedisClient } from "./config/redis.js";
import { configureSocket } from "./config/socket.js";
import { handleSocketConnection } from "./handlers/socketHandlers.js";
import { apiRoutes } from "./routes/api.js";

const initializeServer = async () => {
  const app = express();
  const server = createServer(app);

  console.log("🚀 Starting server...");
  console.log(`🔌 Elasticache endpoint: redis://${env.ELASTICACHE_ENDPOINT}:6379`);

  // Redis setup
  const redisClient = createRedisClient();
  await redisClient.connect();
  console.log("Connected to Redis!");

  // Socket.io setup
  const io = await configureSocket(server);
  io.on("connection", (socket) => handleSocketConnection(socket, io, redisClient));

  // Routes
  app.use("/api", apiRoutes);

  // Start server
  server.listen(3001, () => {
    console.log("Server is listening!");
  });

  ViteExpress.bind(app, server);
};

initializeServer().catch(console.error);