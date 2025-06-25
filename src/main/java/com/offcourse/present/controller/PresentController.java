package com.offcourse.present.controller;

import com.offcourse.present.model.dto.CheckPresentCode;
import com.offcourse.present.model.service.PresentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

@RequestMapping("/present")
@RequiredArgsConstructor
@Controller
@Slf4j
public class PresentController {
    private final PresentService service;

    @GetMapping("/{courseSeq}")
    @ResponseBody
    public String getPresentCode(@PathVariable Long courseSeq) {
        return service.getPresentCode(courseSeq);
    }


    @PostMapping("/check")
    @ResponseBody
    public ResponseEntity<String> checkPresentCode(@RequestBody CheckPresentCode checkPresentCode) {
        boolean result = service.checkPresentCode(checkPresentCode);
        if (!result) {
            return ResponseEntity.badRequest().body("출석 코드가 일치하지 않습니다. 출석 실패!");
        }
        return ResponseEntity.ok("출석 성공!");
    }
}
