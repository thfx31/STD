import express from "express";
import { randomUUID } from "crypto";

export const apiRoutes = express.Router();
const serverId = randomUUID();

apiRoutes.get("/server-id", (req, res) => {
    res.json({ id: serverId });
});
