import type { Server as ServerHttp } from "node:http";
import { createAdapter } from "@socket.io/redis-adapter";
import { Server, ServerOptions } from "socket.io";
import { REDIS_KEY, createRedisClient } from "./redis.js";

export const configureSocket = async (server: ServerHttp) => {
	const io = new Server(server);
	const pubClient = createRedisClient();
	const subClient = pubClient.duplicate();

	await Promise.all([pubClient.connect(), subClient.connect()]);

	io.adapter(createAdapter(pubClient, subClient));
	return io;
};
