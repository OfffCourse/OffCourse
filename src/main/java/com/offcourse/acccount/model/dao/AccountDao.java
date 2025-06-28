package com.offcourse.acccount.model.dao;

import com.offcourse.admin.model.dto.AccountRequestAll;
import lombok.RequiredArgsConstructor;
import org.apache.ibatis.session.RowBounds;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;

@Repository
@RequiredArgsConstructor
public class AccountDao {
    private final SqlSessionTemplate session;

    public long countAccountRequestAll() {
        return session.selectOne("account.countAccountRequestAll");
    }

    public List<AccountRequestAll> getAccountRequestAll(Map param) {
        int cPage = (int) param.get("cPage");
        int numPerPage = (int) param.get("numPerPage");
        String status = (String) param.get("status");
        RowBounds rb = new RowBounds((cPage - 1) * numPerPage, numPerPage);
        return session.selectList("account.getAccountRequestAll", status, rb);
    }

    public int countAccountRequestsAllByStatus(String status) {
        return session.selectOne("account.countAccountRequestsAllByStatus", status);
    }
}
