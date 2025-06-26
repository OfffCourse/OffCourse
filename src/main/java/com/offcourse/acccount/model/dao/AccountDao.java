package com.offcourse.acccount.model.dao;

import lombok.RequiredArgsConstructor;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

@Repository
@RequiredArgsConstructor
public class AccountDao {
    private final SqlSessionTemplate session;

    public long countAccountRequestAll() {
        return session.selectOne("account.countAccountRequestAll");
    }
}
