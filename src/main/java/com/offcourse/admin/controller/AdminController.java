package com.offcourse.admin.controller;

import com.offcourse.admin.model.dto.DashboardStat;
import com.offcourse.admin.model.service.AdminService;
import com.offcourse.common.DeleteRequestAjaxPageFactory;
import com.offcourse.deleterequest.model.dto.DeleteCourseRequestAll;
import com.offcourse.deleterequest.model.dto.DeleteRequestAllResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.List;
import java.util.Map;

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
    public DeleteRequestAllResponse getDeleteRequestAll(
            String status,
            @RequestParam(required = false, defaultValue = "1") int cPage,
            @RequestParam(required = false, defaultValue = "5") int numPerPage
    ) {
        int st = -1;
        switch (status) {
            case "pending":
                st = 0;
                break;
            case "approved":
                st = 1;
                break;
            default:
                st = 2;
        }
        String pageBar = DeleteRequestAjaxPageFactory.basicPageBar(cPage, numPerPage, adminService.countDeleteRequestAllByStatus(st), "loadAdminDeleteRequests", status);
        List<DeleteCourseRequestAll> deleteRequestAll = adminService.getDeleteRequestAll(Map.of("status", st, "cPage", cPage, "numPerPage", numPerPage));
        return DeleteRequestAllResponse.builder()
                .courseList(deleteRequestAll)
                .pageBar(pageBar)
                .build();
    }

}
