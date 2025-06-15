export async function uploadToIPFS(file) {
  const url = `https://api.pinata.cloud/pinning/pinFileToIPFS`;
  const formData = new FormData();
  formData.append("file", file);

  const response = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: import.meta.env.VITE_PINATA_JWT,
    },
    body: formData,
  });

  if (!response.ok) {
    throw new Error("Upload failed.");
  }

  const data = await response.json();
  return `https://gateway.pinata.cloud/ipfs/${data.IpfsHash}`;
}
