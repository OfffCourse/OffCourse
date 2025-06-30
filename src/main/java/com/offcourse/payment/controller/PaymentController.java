package com.offcourse.payment.controller;

import com.offcourse.config.PortOneConfig;
import com.offcourse.course.model.dto.CourseViewResponse;
import com.offcourse.course.model.service.CourseService;
import com.offcourse.enrollment.model.dto.Enrollment;
import com.offcourse.enrollment.model.service.EnrollmentService;
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

@Controller
@RequiredArgsConstructor
@RequestMapping("/payment")
public class PaymentController {

    private final PaymentService paymentService;
    private final PortOneConfig portOneConfig;
    private final PortOneApiUtil portOneApiUtil;
    private final CourseService courseService;
    private final EnrollmentService enrollmentService;

    // [결제 폼 화면]
    @GetMapping("/form")
    public String showPaymentForm(
            @RequestParam Long courseSeq,
            @RequestParam Long memberSeq,
            @RequestParam BigDecimal paymentPrice,
            Model model
    ) {
        CourseViewResponse course = courseService.getCourseBySeq(courseSeq);
        model.addAttribute("course", course);
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
        try {
            paymentService.processEnrollmentPayment(courseSeq, memberSeq, paymentPrice, orderId, impUid);
            ra.addFlashAttribute("msg", "결제가 완료되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("msg", "결제 실패하였습니다 :(");
        }
        return "redirect:/mypage/student";
    }
    // [환불 폼 화면]
    @GetMapping("/refund-form")
    public String showRefundForm(@RequestParam Long enrSeq,
                                 Model model) {
        PaymentHistory ph = paymentService.findPaymentHistoryByEnrSeq(enrSeq);
        Enrollment enrollment = enrollmentService.selectEnrollmentBySeq(enrSeq);
        CourseViewResponse course = courseService.getCourseBySeq(enrollment.getCourseSeq());
        model.addAttribute("paymentSeq", ph.getPaymentSeq());
        model.addAttribute("enrSeq", enrSeq);
        model.addAttribute("impUid", ph.getPaymentImpUid()); // 수정: paymentImpUid 사용
        model.addAttribute("amount", ph.getPaymentPrice());
        model.addAttribute("course", course);
        return "payment/refundForm";
    }
    // [환불]
    @PostMapping("/refund")
    public String refundPayment(@RequestParam Long paymentSeq,
                                @RequestParam Long enrSeq,
                                @RequestParam String reason,
                                RedirectAttributes ra) {
        try {
            paymentService.refundPayment(paymentSeq, enrSeq, reason);
            ra.addFlashAttribute("msg", "환불이 완료되었습니다.");
        } catch (Exception e) {
            ra.addFlashAttribute("msg", "환불 실패하였습니다 :(");
        }
        return "redirect:/mypage/student";
    }

}