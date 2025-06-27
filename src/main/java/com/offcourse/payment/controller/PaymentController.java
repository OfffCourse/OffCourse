package com.offcourse.payment.controller;

import com.offcourse.config.PortOneConfig;
import com.offcourse.payment.model.dto.PaymentHistory;
import com.offcourse.payment.model.service.PaymentService;
import com.offcourse.payment.util.PortOneApiUtil;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@RequestMapping("/payment")
public class PaymentController {

    private final PaymentService paymentService;
    private final PortOneConfig portOneConfig;
    private final PortOneApiUtil portOneApiUtil;

    // [결제 폼 화면]
    @GetMapping("/form")
    public String showPaymentForm(
            @RequestParam Long courseSeq,
            @RequestParam Long memberSeq,
            @RequestParam BigDecimal paymentPrice,
            Model model
    ) {
        model.addAttribute("courseSeq", courseSeq);
        model.addAttribute("memberSeq", memberSeq);
        model.addAttribute("paymentPrice", paymentPrice);
        model.addAttribute("orderId", "OFFCOURSE_ORDER_ID_" + System.currentTimeMillis());
        model.addAttribute("impCode", portOneConfig.getImpCode());
        return "payment/paymentForm";  // /WEB-INF/views/payment/paymentForm.jsp
    }
    // [결제]
    @PostMapping("/process")
    public String processPayment(@RequestParam String impUid,
                                 @RequestParam String orderId,
                                 @RequestParam Long courseSeq,
                                 @RequestParam Long memberSeq,
                                 @RequestParam BigDecimal paymentPrice,
                                 RedirectAttributes ra) {
        // 1. 결제 정보 검증
        Map<String, Object> paymentInfo = portOneApiUtil.getPaymentInfo(impUid);
        String status = (String) paymentInfo.get("status");
        BigDecimal paidAmount = new BigDecimal(paymentInfo.get("amount").toString());
        // 2. 금액 및 상태 확인
        if (!"paid".equals(status) || paymentPrice.compareTo(paidAmount) != 0) {
            ra.addFlashAttribute("msg", "결제 검증 실패: 결제 금액 또는 상태 불일치");
            return "redirect:/payment/fail";
        }
        // 3. DB 저장
        paymentService.processEnrollmentPayment(courseSeq, memberSeq, paymentPrice, orderId);
        ra.addFlashAttribute("msg", "결제가 완료되었습니다.");
        return "redirect:/mypage/student";
    }
    // [환불 폼 화면]
    @GetMapping("/refund-form")
    public String showRefundForm(@RequestParam Long paymentSeq,
                                 @RequestParam Long enrSeq,
                                 Model model) {
        PaymentHistory ph = paymentService.findPaymentHistoryBySeq(paymentSeq);
        model.addAttribute("paymentSeq", paymentSeq);
        model.addAttribute("enrSeq", enrSeq);
        model.addAttribute("impUid", ph.getPaymentOrderId()); // imp_uid로 사용됨
        model.addAttribute("amount", ph.getPaymentPrice());
        return "payment/refundForm";
    }
    // [환불]
    @PostMapping("/refund")
    public String refundPayment(@RequestParam Long paymentSeq,
                                @RequestParam Long enrSeq,
                                @RequestParam String impUid,
                                @RequestParam BigDecimal amount,
                                @RequestParam String reason,
                                RedirectAttributes ra) {
        try {
            // 1. 포트원 환불 API 호출
            portOneApiUtil.cancelPayment(impUid, amount, reason);
            // 2. DB 상태 변경 (환불 완료 처리)
            paymentService.refundPayment(paymentSeq, enrSeq);
            ra.addFlashAttribute("msg", "환불이 완료되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("msg", "환불 처리 중 오류: " + e.getMessage());
        }
        return "redirect:/mypage/student";
    }

}