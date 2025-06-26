package com.offcourse.admin.controller;

import com.offcourse.admin.model.dto.DashboardStat;
import com.offcourse.admin.model.service.AdminService;
import com.offcourse.mypage.model.dto.DeleteCourseRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;

@Controller
@RequiredArgsConstructor
@RequestMapping("/admin")
public class AdminController {
    private final AdminService adminService;

    @GetMapping("/listpage")
    public String adminPage() {
        return "admin/adminPage";
    }

    @GetMapping("/dashboard")
    @ResponseBody
    public DashboardStat getDashboardStat() {
        return adminService.getDashboardStat();
    }

    @GetMapping("/delete-requests")
    @ResponseBody
    public List<DeleteCourseRequest> getDeleteRequestAll() {
        return adminService.getDeleteRequestAll();
    }


}
