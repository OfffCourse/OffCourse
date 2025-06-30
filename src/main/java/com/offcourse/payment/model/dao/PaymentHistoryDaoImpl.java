package com.offcourse.payment.model.dao;

import com.offcourse.payment.model.dto.PaymentHistory;
import org.mybatis.spring.SqlSessionTemplate;
import org.springframework.stereotype.Repository;

import java.util.Map;

@Repository
public class PaymentHistoryDaoImpl implements PaymentHistoryDao {

    private final SqlSessionTemplate sqlSession;
    private static final String NAMESPACE = "paymentHistory.";

    public PaymentHistoryDaoImpl(SqlSessionTemplate sqlSession) {
        this.sqlSession = sqlSession;
    }

    @Override
    public int insertPaymentHistory(PaymentHistory paymentHistory) {
        return sqlSession.insert(NAMESPACE + "insertPaymentHistory", paymentHistory);
    }

    @Override
    public int updatePaymentStatus(Map<String, Object> param) {
        return sqlSession.update(NAMESPACE + "updatePaymentStatus", param);
    }

    @Override
    public PaymentHistory selectBySeq(Long paymentSeq) {
        return sqlSession.selectOne(NAMESPACE + "selectBySeq", paymentSeq);
    }

    @Override
    public PaymentHistory selectByEnrSeq(Long enrSeq) {
        return sqlSession.selectOne(NAMESPACE + "selectByEnrSeq", enrSeq);
    }

}
