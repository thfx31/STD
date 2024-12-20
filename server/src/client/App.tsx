import React, { useState, useEffect, useRef } from "react";
import { UsernameForm } from "./components/UsernameForm";
import { ChatHeader } from "./components/ChatHeader";
import { ChatMessage } from "./components/ChatMessage";
import { MessageForm } from "./components/MessageForm";
import { useSocket } from "./hooks/useSocket";

const App = () => {
  const [username, setUsername] = useState("");
  const [isUsernameSet, setIsUsernameSet] = useState(false);
  const [serverId, setServerId] = useState("");
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const { messages, sendMessage } = useSocket();

  useEffect(() => {
    fetch("/api/server-id")
      .then((res) => res.json())
      .then((data) => setServerId(data.id))
      .catch((err) => console.error("Error fetching server ID:", err));
  }, []);

  useEffect(() => {
    messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
  }, [messages]);

  const handleUsernameSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (username.trim()) {
      setIsUsernameSet(true);
    }
  };

  return (
    <div className="h-screen overflow-hidden bg-gray-50 flex flex-col w-screen">
      {!isUsernameSet ? (
        <UsernameForm
          username={username}
          serverId={serverId}
          onUsernameChange={setUsername}
          onSubmit={handleUsernameSubmit}
        />
      ) : (
        <>
          <ChatHeader username={username} serverId={serverId} />
          <main className="flex-1 max-w-6xl w-full mx-auto p-6">
            <div className="bg-white rounded-2xl shadow-lg h-full flex flex-col">
              {/* Zone de messages scrollable */}
              <div className="flex-1 relative">
                <div className="absolute inset-0 overflow-y-auto p-6">
                  <div className="space-y-6">
                    {messages.map((msg, index) => (
                      <ChatMessage
                        key={index}
                        message={msg}
                        currentUsername={username}
                      />
                    ))}
                    <div ref={messagesEndRef} />
                  </div>
                </div>
              </div>
              {/* Formulaire fixe en bas */}
              <MessageForm username={username} onSendMessage={sendMessage} />
            </div>
          </main>
        </>
      )}
    </div>
  );
};

export default App;
