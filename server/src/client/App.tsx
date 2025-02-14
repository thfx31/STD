import type React from "react";
import { useEffect, useState } from "react";
import { ChatPage } from "./components/ChatPage";
import { UsernameForm } from "./components/UsernameForm";

const App = () => {
	const [username, setUsername] = useState("");
	const [isUsernameSet, setIsUsernameSet] = useState(false);
	const [serverId, setServerId] = useState("");

	useEffect(() => {
		fetch("/api/server-id")
			.then((res) => res.json())
			.then((data) => setServerId(data.id))
			.catch((err) => console.error("Error fetching server ID:", err));
	}, []);

	const handleUsernameSubmit = (e: React.FormEvent) => {
		e.preventDefault();
		if (username.trim()) {
			setIsUsernameSet(true);
		}
	};

	// biome-ignore lint/correctness/noConstantCondition:  TESTING
	const newColor = true
		? "bg-gradient-to-br from-blue-500 to-emerald-500"
		: "bg-gradient-to-br from-red-500 to-purple-500";

	return (
		<div
			className={` overflow-hidden  flex flex-col w-screen h-[100dvh] ${newColor}`}
		>
			{!isUsernameSet ? (
				<UsernameForm
					username={username}
					serverId={serverId}
					onUsernameChange={setUsername}
					onSubmit={handleUsernameSubmit}
				/>
			) : (
				<ChatPage username={username} serverId={serverId} />
			)}
		</div>
	);
};

export default App;
