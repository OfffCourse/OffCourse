package com.offcourse.payment.controller;

import com.offcourse.payment.model.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;

@Controller
@RequiredArgsConstructor
@RequestMapping("/payment")
public class PaymentController {

    private final PaymentService paymentService;

    @PostMapping("/process")
    public String processPayment(@RequestParam Long courseSeq,
                                 @RequestParam Long memberSeq,
                                 @RequestParam BigDecimal paymentPrice,
                                 @RequestParam String orderId,
                                 RedirectAttributes ra) {
        paymentService.processEnrollmentPayment(courseSeq, memberSeq, paymentPrice, orderId);
        ra.addFlashAttribute("msg", "결제가 완료되었습니다.");
        return "redirect:/mypage/student"; // TODO: 마이페이지 만들고 나서 수강 내역 항목으로 연결할 예정
    }

    @PostMapping("/refund")
    public String refundPayment(@RequestParam Long paymentSeq,
                                @RequestParam Long enrSeq,
                                RedirectAttributes ra) {
        paymentService.refundPayment(paymentSeq, enrSeq);
        ra.addFlashAttribute("msg", "환불이 완료되었습니다.");
        return "redirect:/mypage/student"; // TODO: 마이페이지 만들고 나서 수강 내역 항목으로 연결할 예정
    }
}