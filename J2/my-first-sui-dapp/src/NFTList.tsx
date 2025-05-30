import { useQuery } from "@tanstack/react-query";

export const NFTList = () => {
  const { data, isLoading, isError } = useQuery({
    queryKey: ["nftList"],
    queryFn: async () => {
      // Replace with your actual API call to fetch NFTs
      const response = await fetch(
        "http://localhost:3000/events/hero/hero-event",
      );
      if (!response.ok) {
        throw new Error("Network response was not ok");
      }
      return response.json();
    },
  });

  if (isLoading) {
    return <div>Loading...</div>;
  }

  if (!data || isError) {
    return <div>Error loading NFTs</div>;
  }

  return <pre>{JSON.stringify(data, null, 2)}</pre>;
};
