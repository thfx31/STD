import type React from "react";
import type { Message } from "../hooks/useSocket";

interface ChatMessageProps {
	message: Message;
	currentUsername: string;
}

export const ChatMessage: React.FC<ChatMessageProps> = ({
	message,
	currentUsername,
}) => {
	const isCurrentUser = message.username === currentUsername;

	return (
		<div
			className={`flex ${
				isCurrentUser ? "justify-end" : "justify-start"
			} animate-fadeIn`}
		>
			<div
				className={`max-w-[70%] rounded-2xl px-6 py-3 ${
					isCurrentUser
						? "bg-blue-500 text-white shadow-md shadow-blue-200"
						: "bg-gray-100 text-gray-800"
				}`}
			>
				<div className="text-sm opacity-75 mb-1 font-medium">
					{isCurrentUser ? "Vous" : message.username}
				</div>
				<div className="break-words text-lg">{message.message}</div>
			</div>
		</div>
	);
};
