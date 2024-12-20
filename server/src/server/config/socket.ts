import { Server, ServerOptions } from "socket.io";
import { createAdapter } from "@socket.io/redis-adapter";
import { createRedisClient, REDIS_KEY } from "./redis.js";

export const configureSocket = async (server: any) => {
    const io = new Server(server);
    const pubClient = createRedisClient();
    const subClient = pubClient.duplicate();

    await Promise.all([
        pubClient.connect(),
        subClient.connect()
    ]);

    io.adapter(createAdapter(pubClient, subClient));
    return io;
};