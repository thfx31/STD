import React from "react";
import { User } from "lucide-react";

interface ChatHeaderProps {
  username: string;
  serverId: string;
}

export const ChatHeader: React.FC<ChatHeaderProps> = ({
  username,
  serverId,
}) => (
  <header className="bg-white shadow-sm px-6 py-4 sticky top-0 z-10">
    <div className="max-w-6xl mx-auto flex justify-between items-center">
      <h1 className="text-2xl font-bold text-gray-800">Chat en direct</h1>
      {serverId && (
        <div className=" text-sm text-gray-500 bg-gray-50 p-3 rounded-lg">
          ID du serveur: {serverId}
        </div>
      )}
      <div className="flex items-center space-x-3 bg-gray-50 px-4 py-2 rounded-xl">
        <User className="w-5 h-5 text-blue-500" />
        <span className="text-gray-700 font-medium">{username}</span>
      </div>
    </div>
  </header>
);
