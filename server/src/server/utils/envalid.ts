import { cleanEnv, str } from "envalid";

export const env = cleanEnv(process.env, {
    ELASTICACHE_ENDPOINT: str({
        default: "localhost",
    }),
})