package com.offcourse.enrollment.controller;

import com.offcourse.enrollment.model.service.EnrollmentService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

@Controller
@RequiredArgsConstructor
public class EnrollmentController {

    private final EnrollmentService enrollmentService;

    @PostMapping("/enrollment/enroll")
    public String enroll(@RequestParam Long courseSeq,
                         @RequestParam Long memberSeq,
                         RedirectAttributes ra) {
        enrollmentService.enrollCourse(courseSeq, memberSeq);
        ra.addFlashAttribute("msg", "수강신청 완료!");
        return "redirect:/courses/" + courseSeq;
    }

    @PostMapping("/enrollment/cancel")
    public String cancel(@RequestParam Long enrSeq,
                         RedirectAttributes ra) {
        enrollmentService.updateStatus(enrSeq, "1");
        ra.addFlashAttribute("msg", "환불(취소) 처리되었습니다.");
        return "redirect:/my/enrollments";
    }
}
