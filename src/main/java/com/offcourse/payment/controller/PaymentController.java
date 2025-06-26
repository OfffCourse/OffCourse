package com.offcourse.payment.controller;

import com.offcourse.payment.model.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;

@Controller
@RequiredArgsConstructor
@RequestMapping("/payment")
public class PaymentController {

    private final PaymentService paymentService;

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
        // orderId는 실제 PG 연동 시 생성되므로 여기서는 placeholder
        model.addAttribute("orderId", "PLACEHOLDER_ORDER_ID");
        return "payment/paymentForm";  // /WEB-INF/views/payment/paymentForm.jsp
    }
    // [결제]
    @PostMapping("/process")
    public String processPayment(@RequestParam Long courseSeq,
                                 @RequestParam Long memberSeq,
                                 @RequestParam BigDecimal paymentPrice,
                                 @RequestParam String orderId,
                                 RedirectAttributes ra) {
        paymentService.processEnrollmentPayment(courseSeq, memberSeq, paymentPrice, orderId);
        ra.addFlashAttribute("msg", "결제가 완료되었습니다.");
        return "redirect:/mypage/student";
    }
    // [환불 폼 화면]
    @GetMapping("/refund-form")
    public String showRefundForm(
            @RequestParam Long paymentSeq,
            @RequestParam Long enrSeq,
            Model model
    ) {
        model.addAttribute("paymentSeq", paymentSeq);
        model.addAttribute("enrSeq", enrSeq);
        return "payment/refundForm"; // /WEB-INF/views/payment/refundForm.jsp
    }
    // [환불]
    @PostMapping("/refund")
    public String refundPayment(@RequestParam Long paymentSeq,
                                @RequestParam Long enrSeq,
                                RedirectAttributes ra) {
        paymentService.refundPayment(paymentSeq, enrSeq);
        ra.addFlashAttribute("msg", "환불이 완료되었습니다.");
        return "redirect:/mypage/student";
    }
}