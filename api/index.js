export default async function handler(req, res) {
  const uri = req.query.url;
  if (!uri) return res.status(400).send("Missing URL");

  // Validate URL
  try { new URL(uri); }
  catch { return res.status(400).send("Invalid URL"); }

  try {
    const controller = new AbortController();
    const timeout = setTimeout(() => controller.abort(), 20000);

    const response = await fetch(uri, {
      redirect: "follow",
      signal: controller.signal,
      headers: {
        "User-Agent": "Mozilla/5.0",
        "Referer": "https://www.starhub.com/",
        "Origin": "https://www.starhub.com/"
      }
    });

    clearTimeout(timeout);

    const finalUrl = response.url;
    if (response.ok && finalUrl) {
      res.setHeader("Content-Type", "text/plain; charset=utf-8");
      return res.status(200).send(finalUrl);
    } else {
      return res.status(response.status).send(`Failed (HTTP ${response.status})`);
    }
  } catch (e) {
    return res.status(500).send("Request failed");
  }
}
