import { ChevronRight, User } from "lucide-react";
import type React from "react";

interface UsernameFormProps {
	username: string;
	serverId: string;
	onUsernameChange: (value: string) => void;
	onSubmit: (e: React.FormEvent) => void;
}

export const UsernameForm: React.FC<UsernameFormProps> = ({
	username,
	serverId,
	onUsernameChange,
	onSubmit,
}) => (
	<div className="h-full bg-gradient-to-br from-blue-50 to-indigo-50 flex items-center justify-center p-4">
		<div className="bg-white rounded-2xl shadow-xl p-8 w-full max-w-md border border-gray-100">
			<div className="flex items-center space-x-3 mb-8">
				<User className="w-8 h-8 text-blue-500" />
				<h1 className="text-3xl font-bold text-gray-800">Bienvenue</h1>
			</div>
			{serverId && (
				<div className="mb-6 text-sm text-gray-500 bg-gray-50 p-3 rounded-lg">
					ID du serveur: {serverId}
				</div>
			)}
			<form onSubmit={onSubmit} className="space-y-6">
				<input
					type="text"
					value={username}
					onChange={(e) => onUsernameChange(e.target.value)}
					className="w-full px-4 py-3 border border-gray-200 rounded-xl focus:ring-2 focus:ring-blue-500 focus:border-transparent outline-none text-lg transition-all duration-200"
					placeholder="Entrez votre pseudo..."
					autoComplete="off"
					required
				/>
				<button
					type="submit"
					className="w-full bg-blue-500 hover:bg-blue-600 text-white font-medium py-3 px-6 rounded-xl transition-all duration-200 flex items-center justify-center space-x-2 text-lg shadow-lg shadow-blue-200"
				>
					<span>Rejoindre</span>
					<ChevronRight className="w-5 h-5" />
				</button>
			</form>

			<p className="text-gray-500 mt-4 text-center">Crée par Sylvain</p>
		</div>
	</div>
);
