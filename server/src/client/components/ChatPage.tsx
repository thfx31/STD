import { useEffect, useRef } from "react";
import { useSocket } from "../hooks/useSocket";
import { ChatHeader } from "./ChatHeader";
import { ChatMessage } from "./ChatMessage";
import { MessageForm } from "./MessageForm";
import QRCodeGenerator from "./QRCode";

export const ChatPage = ({
	username,
	serverId,
}: {
	username: string;
	serverId: string;
}) => {
	const { messages, sendMessage } = useSocket();
	const messagesEndRef = useRef<HTMLDivElement>(null);

	// biome-ignore lint/correctness/useExhaustiveDependencies: to scroll to the bottom of the chat when a new message is sent
	useEffect(() => {
		messagesEndRef.current?.scrollIntoView({ behavior: "smooth" });
	}, [messages]);
	return (
		<>
			<ChatHeader username={username} serverId={serverId} />
			<main className="flex-1  w-full mx-auto p-6 lg:grid lg:grid-cols-3 gap-x-3">
				<div className="bg-white rounded-2xl shadow-lg h-full flex flex-col col-span-2">
					{/* Zone de messages scrollable */}
					<div className="flex-1 relative">
						<div className="absolute inset-0 overflow-y-auto p-6">
							<div className="space-y-6">
								{messages.map((msg, index) => (
									<ChatMessage
										key={`${msg}-${
											// biome-ignore lint/suspicious/noArrayIndexKey: <explanation>
											index
										}`}
										message={msg}
										currentUsername={username}
										serverId={serverId}
									/>
								))}
								<div ref={messagesEndRef} />
							</div>
						</div>
					</div>
					<MessageForm username={username} onSendMessage={sendMessage} />
				</div>
				<div className="hidden lg:flex">
					<QRCodeGenerator />
				</div>
			</main>
		</>
	);
};
