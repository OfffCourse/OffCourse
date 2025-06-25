package com.offcourse.payment.controller;

import com.offcourse.enrollment.model.service.EnrollmentService;
import com.offcourse.payment.model.dto.PaymentHistory;
import com.offcourse.payment.model.service.PaymentService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import java.math.BigDecimal;

@Controller
@RequiredArgsConstructor
public class PaymentController {

    private final PaymentService paymentService;
    private final EnrollmentService enrollmentService;

    @PostMapping("/payment/process")
    public String processPayment(@RequestParam Long enrSeq,
                                 @RequestParam BigDecimal paymentPrice,
                                 @RequestParam String orderId,
                                 RedirectAttributes ra) {
        PaymentHistory ph = new PaymentHistory();
        ph.setEnrSeq(enrSeq);
        ph.setPaymentPrice(paymentPrice);
        ph.setPaymentOrderId(orderId);
        ph.setPaymentStatus("0");
        paymentService.recordPayment(ph);
        enrollmentService.updateStatus(enrSeq, "0");
        ra.addFlashAttribute("msg", "결제가 완료되었습니다.");
        return "redirect:/my/enrollments";
    }

    @GetMapping("/payment/callback")
    public String paymentCallback(@RequestParam String orderId,
                                  @RequestParam String status,
                                  RedirectAttributes ra) {
        PaymentHistory ph = paymentService.findByOrderId(orderId);
        if ("2".equals(status)) {
            paymentService.changePaymentStatus(ph.getPaymentSeq(), "2");
            enrollmentService.updateStatus(ph.getEnrSeq(), "1");
            ra.addFlashAttribute("msg", "환불이 완료되었습니다.");
        }
        return "redirect:/my/enrollments";
    }
}
