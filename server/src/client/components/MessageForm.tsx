import { Send } from "lucide-react";
import type React from "react";
import { useState } from "react";
import type { Message } from "../hooks/useSocket";

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
			className="border-t bg-white p-4 sm:p-6 sticky bottom-0 w-full"
		>
			<div className="max-w-6xl mx-auto flex items-center space-x-2 sm:space-x-4">
				<input
					type="text"
					value={message}
					onChange={(e) => setMessage(e.target.value)}
					className="flex-1 px-4 sm:px-6 py-2 sm:py-3 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none text-base sm:text-lg transition-all duration-200"
					placeholder="Votre message..."
					autoComplete="off"
					required
				/>
				<button
					type="submit"
					className="bg-blue-500 hover:bg-blue-600 text-white px-4 sm:px-6 py-2 sm:py-3 rounded-lg transition-all duration-200 flex items-center space-x-2 sm:space-x-3 font-medium shadow-md shadow-blue-200"
				>
					<Send className="w-5 h-5" />
					<span className="hidden sm:block">Envoyer</span>
				</button>
			</div>
		</form>
	);
};
