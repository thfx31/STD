import { useEffect, useState } from "react";
import QRCode from "react-qr-code";

export default function QRCodeGenerator() {
	const [url, setUrl] = useState("");

	useEffect(() => {
		setUrl(window.location.href);
	}, []);

	return (
		<div className="p-4 flex flex-col items-center h-full border rounded-2xl shadow-lg bg-white">
			<div className="flex flex-col items-center justify-center h-full">
				<QRCode value={url} size={400} />
				<p className="mt-4 text-sm text-gray-500">
					Scannez ce QR code pour accéder au chat.
				</p>
			</div>
		</div>
	);
}
