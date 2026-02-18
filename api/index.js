export default async function handler(req, res) {
  const uri = req.query.url;

  if (!uri) {
    return res.status(400).send("Missing URL");
  }

  try {
    const response = await fetch(uri, {
      redirect: "follow",
      headers: {
        "User-Agent": "Mozilla/5.0",
        "Referer": "https://www.starhub.com/",
        "Origin": "https://www.starhub.com/"
      }
    });

    const finalUrl = response.url;

    if (response.ok && finalUrl) {
      res.setHeader("Content-Type", "text/plain");
      return res.status(200).send(finalUrl);
    } else {
      return res.status(response.status).send(`Failed (HTTP ${response.status})`);
    }

  } catch (err) {
    return res.status(500).send("Request failed");
  }
}
