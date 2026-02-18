<?php

// === Input validation ===
$uri = $_GET['url'] ?? '';

if (!$uri) {
    http_response_code(400);
    exit("Missing URL");
}

// Allow only http/https
$parsed = parse_url($uri);
if (
    !$parsed ||
    !isset($parsed['scheme']) ||
    !in_array(strtolower($parsed['scheme']), ['http','https'])
) {
    http_response_code(400);
    exit("Invalid URL");
}

// === cURL Fetch ===
$ch = curl_init();
curl_setopt($ch, CURLOPT_URL, $uri);
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_FOLLOWLOCATION, true);
curl_setopt($ch, CURLOPT_MAXREDIRS, 5);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "User-Agent: Mozilla/5.0"
]);

// Timeouts (IMPORTANT for Vercel)
curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, 10);
curl_setopt($ch, CURLOPT_TIMEOUT, 20);

// Prevent large body download (we only need redirect)
curl_setopt($ch, CURLOPT_NOBODY, true);

curl_exec($ch);

$finalUrl = curl_getinfo($ch, CURLINFO_EFFECTIVE_URL);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

curl_close($ch);

// === Output ===
header("Content-Type: text/plain; charset=utf-8");

if ($httpCode >= 200 && $httpCode < 400 && $finalUrl) {
    echo $finalUrl;
} else {
    echo "Failed (HTTP $httpCode)";
}
