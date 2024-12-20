import { createClient } from "redis";
import { env } from "../utils/envalid.js";

export const MESSAGE_EXPIRATION = 1200; // 20 minutes in seconds
export const REDIS_KEY = "chat_messages";

export const createRedisClient = () => {
    return createClient({
        url: `redis://${env.ELASTICACHE_ENDPOINT}`
    });
};
