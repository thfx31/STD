import React, { useState } from "react";
import { Send } from "lucide-react";
import { Message } from "../hooks/useSocket";

interface MessageFormProps {
  username: string;
  onSendMessage: (messageData: Message) => void;
}

export const MessageForm: React.FC<MessageFormProps> = ({
  username,
  onSendMessage,
}) => {
  const [message, setMessage] = useState("");

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    if (message.trim()) {
      onSendMessage({ username, message });
      setMessage("");
    }
  };

  return (
    <form
      onSubmit={handleSubmit}
      className="border-t bg-white p-6 sticky bottom-0"
    >
      <div className="max-w-6xl mx-auto flex space-x-4">
        <input
          type="text"
          value={message}
          onChange={(e) => setMessage(e.target.value)}
          className="flex-1 px-6 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none text-lg transition-all duration-200"
          placeholder="Votre message..."
          autoComplete="off"
          required
        />
        <button
          type="submit"
          className="bg-blue-500 hover:bg-blue-600 text-white px-8 py-3 rounded-xl transition-all duration-200 flex items-center space-x-3 font-medium shadow-lg shadow-blue-200"
        >
          <Send className="w-5 h-5" />
          <span>Envoyer</span>
        </button>
      </div>
    </form>
  );
};
