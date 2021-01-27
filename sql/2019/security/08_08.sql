#standardSQL
# 08_08 Modern cipher suites
#
# TLS 1.3 ciphers:
# 0x1301 TLS_AES_128_GCM_SHA256
# 0x1302 TLS_AES_256_GCM_SHA384
# 0x1303 TLS_CHACHA20_POLY1305_SHA256
# 0x1304 TLS_AES_128_CCM_SHA256
# 0x1305 TLS_AES_128_CCM_8_SHA256
#
# TLS 1.2 ciphers:
# 0xC02B TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256
# 0xC02C TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384
# 0xC02F TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256
# 0xC030 TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384
# 0xCCA8 TLS_ECDHE_RSA_WITH_CHACHA20_POLY1305_SHA256
# 0xCCA9 TLS_ECDHE_ECDSA_WITH_CHACHA20_POLY1305_SHA256
# 0xCCAC TLS_ECDHE_PSK_WITH_CHACHA20_POLY1305_SHA256
# 0xD001 TLS_ECDHE_PSK_WITH_AES_128_GCM_SHA256
# 0xD002 TLS_ECDHE_PSK_WITH_AES_256_GCM_SHA384
# 0xD005 TLS_ECDHE_PSK_WITH_AES_128_CCM_SHA256
CREATE TEMPORARY FUNCTION isModern(cipher STRING) RETURNS BOOLEAN AS (
  cipher IN ('1301', '1302', '1303', '1304', '1305',
    'C02B', 'C02C', 'C02F', 'C030', 'CCA8', 'CCA9',
    'CCAC', 'D001', 'D002', 'D005')
);

SELECT
  client,
  modern_cipher_count,
  total,
  ROUND(modern_cipher_count * 100 / total, 2) AS pct
FROM (
  SELECT
    _TABLE_SUFFIX AS client,
    COUNT(0) total,
    COUNTIF(isModern(FORMAT("%'x", CAST(JSON_EXTRACT(payload, '$._tls_cipher_suite') AS INT64)))) AS modern_cipher_count
  FROM
     `httparchive.requests.2019_07_01_*`
  WHERE
    JSON_EXTRACT(payload, '$._securityDetails') IS NOT NULL
  GROUP BY
    client)