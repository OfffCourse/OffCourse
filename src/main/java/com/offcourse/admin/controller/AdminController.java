package com.offcourse.admin.controller;

import com.offcourse.admin.model.dto.DashboardStat;
import com.offcourse.admin.model.dto.HandleDeleteRequest;
import com.offcourse.admin.model.service.AdminService;
import com.offcourse.common.DeleteRequestAjaxPageFactory;
import com.offcourse.deleterequest.model.dto.DeleteCourseRequestAll;
import com.offcourse.deleterequest.model.dto.DeleteRequestAllResponse;
import com.offcourse.deleterequest.model.dto.DeleteRequestStatus;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Controller
@RequiredArgsConstructor
@RequestMapping("/admin")
@Slf4j
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
            @RequestParam(required = false, defaultValue = "1") int page,
            @RequestParam(required = false, defaultValue = "1") int numPerPage
    ) {
        DeleteRequestStatus enumStatus = DeleteRequestStatus.statusToEnum(status);
        if (enumStatus == null) {
            throw new IllegalArgumentException("Invalid status: " + status);
        }

        String pageBar = DeleteRequestAjaxPageFactory.basicPageBar(page, numPerPage, adminService.countDeleteRequestAllByStatus(enumStatus), "loadAdminDeleteRequests", status);
        List<DeleteCourseRequestAll> deleteRequestAll = adminService.getDeleteRequestAll(Map.of("status", enumStatus, "cPage", page, "numPerPage", numPerPage));
        return DeleteRequestAllResponse.builder()
                .courseList(deleteRequestAll)
                .pageBar(pageBar)
                .build();
    }

    @PostMapping("/course/delete")
    @ResponseBody
    public boolean handleDeleteRequest(@RequestBody HandleDeleteRequest handleDeleteRequest) {
        log.info("action {}", handleDeleteRequest.getAction());
        return adminService.handleDeleteRequest(handleDeleteRequest.getDeleteRequestSeq(), handleDeleteRequest.getAction(), handleDeleteRequest.getCourseSeq());
    }

}
