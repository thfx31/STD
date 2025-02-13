import { randomUUID } from "node:crypto";
import express from "express";

export const apiRoutes = express.Router();
const serverId = randomUUID();

apiRoutes.get("/server-id", (req, res) => {
	res.json({ id: serverId });
});
