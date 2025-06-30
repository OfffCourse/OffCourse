package com.offcourse.common.pagefactory;

public class MemberAjaxPageFactory {
    public static String basicPageBar(int cPage, int numPerPage, int totalData, String jsFunctionName, String roleParam) {
        StringBuilder sb = new StringBuilder();
        int totalPage = (int) Math.ceil((double) totalData / numPerPage);
        int pageBarSize = 5;
        int pageNo = ((cPage - 1) / pageBarSize) * pageBarSize + 1;
        int pageEnd = pageNo + pageBarSize - 1;

        sb.append("<ul class='pagination justify-content-center pagination-sm'>");

        // 이전 버튼
        if (pageNo == 1) {
            sb.append("<li class='page-item disabled'><a class='page-link'>이전</a></li>");
        } else {
            sb.append("<li class='page-item'>")
                    .append("<a class='page-link' href='#' data-role='")
                    .append(roleParam)
                    .append("' data-page='")
                    .append(pageNo - 1)
                    .append("'>이전</a></li>");
        }

        // 페이지 번호
        while (!(pageNo > pageEnd || pageNo > totalPage)) {
            if (pageNo == cPage) {
                sb.append("<li class='page-item active'><a class='page-link'>")
                        .append(pageNo)
                        .append("</a></li>");
            } else {
                sb.append("<li class='page-item'>")
                        .append("<a class='page-link' href='#' data-role='")
                        .append(roleParam)
                        .append("' data-page='")
                        .append(pageNo)
                        .append("'>")
                        .append(pageNo)
                        .append("</a></li>");
            }
            pageNo++;
        }

        // 다음 버튼
        if (pageNo > totalPage) {
            sb.append("<li class='page-item disabled'><a class='page-link'>다음</a></li>");
        } else {
            sb.append("<li class='page-item'>")
                    .append("<a class='page-link' href='#' data-role='")
                    .append(roleParam)
                    .append("' data-page='")
                    .append(pageNo)
                    .append("'>다음</a></li>");
        }

        sb.append("</ul>");
        return sb.toString();
    }
}
