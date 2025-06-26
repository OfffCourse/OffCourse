package com.offcourse.payment.util;

import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.util.HashMap;
import java.util.Map;

@Slf4j
@Component
@RequiredArgsConstructor
public class PortOneApiUtil {

    private final RestTemplate restTemplate;

    @Value("${portone.api-url}")
    private String portOneApiUrl;

    @Value("${portone.public-key}")
    private String apiKey;

    @Value("${portone.secret-key}")
    private String apiSecret;

    // 1. 액세스 토큰 요청
    public String getAccessToken() {
        String url = portOneApiUrl + "/users/getToken";
        Map<String, String> body = new HashMap<>();
        body.put("imp_key", apiKey);
        body.put("imp_secret", apiSecret);

        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        HttpEntity<Map<String, String>> entity = new HttpEntity<>(body, headers);

        ResponseEntity<Map> response = restTemplate.postForEntity(url, entity, Map.class);
        return (String)((Map)response.getBody().get("response")).get("access_token");
    }

    // 2. 결제 단건 조회
    public Map<String, Object> getPaymentInfo(String impUid) {
        String accessToken = getAccessToken();
        String url = portOneApiUrl + "/payments/" + impUid;

        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accessToken);
        HttpEntity<?> entity = new HttpEntity<>(headers);

        ResponseEntity<Map> response = restTemplate.exchange(url, HttpMethod.GET, entity, Map.class);
        return (Map<String, Object>) response.getBody().get("response");
    }

    // 3. 환불 API 메서드
    public void cancelPayment(String impUid, BigDecimal amount, String reason) {
        String accessToken = getAccessToken();
        String url = portOneApiUrl + "/payments/cancel";

        HttpHeaders headers = new HttpHeaders();
        headers.setBearerAuth(accessToken);
        headers.setContentType(MediaType.APPLICATION_JSON);

        Map<String, Object> body = new HashMap<>();
        body.put("imp_uid", impUid);
        body.put("amount", amount);
        body.put("reason", reason);

        HttpEntity<Map<String, Object>> entity = new HttpEntity<>(body, headers);
        ResponseEntity<Map> response = restTemplate.postForEntity(url, entity, Map.class);

        Map<String, Object> res = (Map<String, Object>) response.getBody().get("response");
        if (res == null || !"cancelled".equals(res.get("status"))) {
            throw new IllegalStateException("환불 실패: " + response.getBody());
        }
    }


}
