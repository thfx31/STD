import { randomUUID } from "node:crypto";
import express from "express";

export const apiRoutes = express.Router();
const serverId = randomUUID();

apiRoutes.get("/server-id", (req, res) => {
	res.json({ id: serverId });
});

//fait moi une route a haute charge comme avec du fibonacci ou du factorielle

apiRoutes.get("/fibonacci/:number", (req, res) => {
	const number = Number.parseInt(req.params.number);
	const startTimestamp = Date.now();
	const result = fibonacci(number);
	const endTimestamp = Date.now();
	const duration = endTimestamp - startTimestamp;
	res.json({ result, duration: `${duration}ms` });
});

function fibonacci(n: number): number {
	if (n <= 1) return n;
	return fibonacci(n - 1) + fibonacci(n - 2);
}

//fait moi une route de test de charge qui consomme beaucoup de ram et de cpu
apiRoutes.get("/cpu", (req, res) => {
	const startTimestamp = Date.now();
	const result = cpu();
	const endTimestamp = Date.now();
	const duration = endTimestamp - startTimestamp;
	res.json({ result, duration: `${duration}ms` });
});

function cpu(): number {
	let result = 0;
	for (let i = 0; i < 1000000000; i++) {
		result += i;
	}
	return result;
}

//fait moi une route de test de charge qui consomme beaucoup de ram et de cpu
apiRoutes.get("/ram", (req, res) => {
	const startTimestamp = Date.now();
	const result = ram();
	const endTimestamp = Date.now();
	const duration = endTimestamp - startTimestamp;
	res.json({ result, duration: `${duration}ms` });
});

function ram(): number {
	const array = new Array(10000000).fill(0);
	return array.length;
}
