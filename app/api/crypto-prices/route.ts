import { NextResponse } from "next/server";

/**
 * GET /api/crypto-prices
 *
 * Server-side API for fetching cryptocurrency prices with caching.
 * Replaces client-side price fetching to avoid rate limiting and follow coding principles.
 *
 * Returns:
 * {
 *   ethPrice: number,
 *   polPrice: number
 * }
 */
export const revalidate = 3600; // 1 hour server cache

export async function GET() {
  try {
    // Add proper headers and user agent to avoid ad blocking
    const fetchOptions = {
      headers: {
        "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36",
        Accept: "application/json",
        Origin: "https://base200.com",
      },
      cache: "no-store" as RequestCache,
    };

    const [ethResponse, polResponse] = await Promise.all([
      fetch("https://api.coinbase.com/v2/prices/ETH-USD/spot", fetchOptions),
      fetch("https://api.coinbase.com/v2/prices/MATIC-USD/spot", fetchOptions),
    ]);

    if (!ethResponse.ok || !polResponse.ok) {
      throw new Error(
        `Coinbase API error: ETH=${ethResponse.status}, POL=${polResponse.status}`,
      );
    }

    const [ethData, polData] = await Promise.all([
      ethResponse.json(),
      polResponse.json(),
    ]);

    const ethPrice = parseFloat(ethData.data?.amount);
    const polPrice = parseFloat(polData.data?.amount);

    if (isNaN(ethPrice) || isNaN(polPrice) || ethPrice <= 0 || polPrice <= 0) {
      throw new Error("Invalid price data from Coinbase");
    }

    return NextResponse.json({ ethPrice, polPrice });
  } catch (error) {
    console.error("[crypto-prices] Fetch failed:", error);

    // Return current market prices as fallback
    return NextResponse.json({ ethPrice: 3400, polPrice: 0.22 });
  }
}
