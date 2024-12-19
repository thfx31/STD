import express from 'express';
import { createServer } from 'http';
import { Server } from 'socket.io';

const app = express();
const server = createServer(app);
const io = new Server(server);

app.use(express.static('public'));

const messages: { username: string; message: string; }[] = []; // Stocke les messages en mémoire

io.on('connection', (socket) => {
    console.log('A user connected:', socket.id);

    // Envoyer les messages existants au nouveau client
    socket.emit('previous messages', messages);

    socket.on('chat message', ({ username, message }) => {
        const chatMessage = { username, message };
        messages.push(chatMessage); // Ajouter le message à la liste en mémoire
        io.emit('chat message', chatMessage); // Diffuser à tous les clients
    });

    socket.on('disconnect', () => {
        console.log('User disconnected:', socket.id);
    });
});

const PORT = 3000;
server.listen(PORT, () => {
    console.log(`Server is running on http://localhost:${PORT}`);
});
