package com.offcourse.present.controller;

import com.offcourse.present.model.service.PresentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

@RequestMapping("/present")
@RequiredArgsConstructor
@Controller
@Slf4j
public class PresentController {
    private final PresentService service;

    @GetMapping
    @ResponseBody
    public String getPresentCode(Long courseSeq) {
        return service.getPresentCode(courseSeq);
    }

    @PostMapping
    public String checkPresentCode(String presentCode) {
        return null;
    }
}
