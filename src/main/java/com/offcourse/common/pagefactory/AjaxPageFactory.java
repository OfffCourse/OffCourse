package com.offcourse.common.pagefactory;

import org.springframework.stereotype.Component;

@Component
public class AjaxPageFactory {
    public String basicPageBar(int cPage, int numPerPage, int totalData) {
        StringBuilder sb = new StringBuilder();
        int totalPage = (int) (Math.ceil((double) totalData / numPerPage));
        int pageBarSize = 5;
        int pageNo = ((cPage - 1) / pageBarSize) * pageBarSize + 1;
        int pageEnd = pageNo + pageBarSize - 1;

        sb.append("<ul class='pagination justify-content-center pagination-sm'>");

        if (pageNo == 1) {
            sb.append("<li class='page-item disabled'><a class='page-link'>이전</a></li>");
        } else {
            sb.append("<li class='page-item'><a class='page-link' href='javascript:fn_paging(").append(pageNo - 1).append(")'>이전</a></li>");
        }

        while (!(pageNo > pageEnd || pageNo > totalPage)) {
            if (pageNo == cPage) {
                sb.append("<li class='page-item active'><a class='page-link'>").append(pageNo).append("</a></li>");
            } else {
                sb.append("<li class='page-item'><a class='page-link' href='javascript:fn_paging(").append(pageNo).append(")'>").append(pageNo).append("</a></li>");
            }
            pageNo++;
        }

        if (pageNo > totalPage) {
            sb.append("<li class='page-item disabled'><a class='page-link'>다음</a></li>");
        } else {
            sb.append("<li class='page-item'><a class='page-link' href='javascript:fn_paging(").append(pageNo).append(")'>다음</a></li>");
        }

        sb.append("</ul><script>function fn_paging(pageNo){ loadCourses(pageNo); }</script>");
        return sb.toString();
    }


}
