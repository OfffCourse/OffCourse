package com.offcourse.certificate.controller;

import com.offcourse.security.CustomUserDetails;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;

import java.text.SimpleDateFormat;
import java.util.Date;

@Controller
@RequestMapping("/certificate")
@RequiredArgsConstructor
public class CertificateController {

    @PostMapping
    public String certificatePage(
            Long courseSeq,
            String courseName,
            String courseStartDate,
            String courseEndDate,
            Authentication authentication,
            Model model
    ) {
        SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd");
        model.addAttribute("courseSeq", courseSeq);
        model.addAttribute("courseName", courseName);
        model.addAttribute("courseStartDate", sdf.format(new Date(Long.parseLong(courseStartDate))));
        model.addAttribute("courseEndDate", sdf.format(new Date(Long.parseLong(courseEndDate))));
        model.addAttribute("studentName", ((CustomUserDetails) authentication.getPrincipal()).getMember().getMemberName());

        return "/certificate/certificate";
    }
}
