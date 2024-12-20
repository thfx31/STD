

import { useState, useEffect } from 'react';
import { io, Socket } from 'socket.io-client';

export interface Message {
    username: string;
    message: string;
}

export const useSocket = () => {
    const [messages, setMessages] = useState<Message[]>([]);
    const [socket, setSocket] = useState<Socket | null>(null);

    useEffect(() => {
        const newSocket = io();
        setSocket(newSocket);

        newSocket.on('connect', () => {
            console.log('✅ Connected to the server');
        });

        newSocket.on('previous messages', (previousMessages: Message[]) => {
            setMessages(previousMessages);
        });

        newSocket.on('chat message', (newMessage: Message) => {
            setMessages(prevMessages => [...prevMessages, newMessage]);
        });

        return () => {
            newSocket.off('connect');
            newSocket.off('previous messages');
            newSocket.off('chat message');
            newSocket.disconnect();
        };
    }, []);

    const sendMessage = (messageData: Message) => {
        socket?.emit('chat message', messageData);
    };

    return { messages, sendMessage };
};